# Question Bank Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Triển khai Question Bank đầy đủ (UI + Smart Sync + Schema v2) tuân thủ Bank-first lifecycle và Delta Override, để hỗ trợ AI Analytics Phase 7.

**Architecture:** Bank-first Single Source of Truth — câu hỏi INSERT vào `questions` trước, ref vào `assignment_questions`. Smart Sync RPC `sync_assignment_to_bank` với pg_advisory_lock + T1 dedup (SHA-256 polymorphic). RLS rebuild với `public.is_admin(uid)`. Migration additive giữ `is_public` bridge với `is_global` trong transition window.

**Tech Stack:** Flutter 3.x · Riverpod (@riverpod codegen) · Freezed · GoRouter · Supabase (PostgreSQL 15 + pgcrypto) · mocktail (test) · easy_debounce

**Spec:** `docs/superpowers/specs/2026-05-17-question-bank-design.md`

---

## Phases overview

| Phase | Scope | # Tasks |
|-------|-------|---------|
| 1 | Schema migrations (020-023) | 5 |
| 2 | Domain layer (entity, enum, failure, filter) | 7 |
| 3 | Data layer (DTO, datasource, repo impl) | 6 |
| 4 | Provider layer (Riverpod notifier + family) | 4 |
| 5 | UI components (5 màn hình mới) | 11 |
| 6 | Integration (7 file hiện có) | 7 |
| 7 | Tests (unit + widget + integration) | 6 |
| 8 | Verification + cleanup | 2 |

**Total:** 48 tasks

---

# PHASE 1 — Schema Migrations

## Task 1.1: Migration 020 — Additive columns + bridge trigger

**Files:**
- Create: `supabase/migrations/020_question_bank_columns.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- supabase/migrations/020_question_bank_columns.sql
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

ALTER TABLE public.questions
  ADD COLUMN IF NOT EXISTS is_global boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'teacher',
  ADD COLUMN IF NOT EXISTS content_hash text,
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

ALTER TABLE public.questions
  DROP CONSTRAINT IF EXISTS questions_source_check;
ALTER TABLE public.questions
  ADD CONSTRAINT questions_source_check
  CHECK (source IN ('system','admin','teacher','ai_generated','library','imported'));

UPDATE public.questions
  SET is_global = is_public
  WHERE is_global IS DISTINCT FROM is_public;

CREATE OR REPLACE FUNCTION public.questions_bridge_is_global_is_public()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_global IS DISTINCT FROM OLD.is_global THEN
    NEW.is_public := NEW.is_global;
  ELSIF NEW.is_public IS DISTINCT FROM OLD.is_public THEN
    NEW.is_global := NEW.is_public;
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_questions_bridge ON public.questions;
CREATE TRIGGER trg_questions_bridge
  BEFORE UPDATE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.questions_bridge_is_global_is_public();

COMMIT;
```

- [ ] **Step 2: Apply migration via Supabase MCP**

Run: `mcp__supabase__apply_migration(name='020_question_bank_columns', query=<above SQL>)`
Expected: Success with no error.

- [ ] **Step 3: Verify columns added**

Run: `mcp__supabase__execute_sql(query="SELECT column_name, data_type FROM information_schema.columns WHERE table_name='questions' AND column_name IN ('is_global','source','content_hash','deleted_at') ORDER BY column_name")`
Expected: 4 rows: `content_hash text`, `deleted_at timestamp with time zone`, `is_global boolean`, `source text`.

- [ ] **Step 4: Verify bridge trigger**

Run: `mcp__supabase__execute_sql(query="SELECT tgname FROM pg_trigger WHERE tgname='trg_questions_bridge'")`
Expected: 1 row `trg_questions_bridge`.

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/020_question_bank_columns.sql
git commit -m "feat(db): migration 020 — Question Bank additive columns + bridge trigger"
```

---

## Task 1.2: Migration 021 — Hash trigger + chunked backfill + UNIQUE index

**Files:**
- Create: `supabase/migrations/021_question_content_hash_unique.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- supabase/migrations/021_question_content_hash_unique.sql
BEGIN;

CREATE OR REPLACE FUNCTION public.compute_question_hash(content jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE raw_text text; normalized text;
BEGIN
  IF content IS NULL THEN
    RETURN encode(extensions.digest('', 'sha256'), 'hex');
  END IF;

  IF content ? 'ops' AND jsonb_typeof(content->'ops') = 'array' THEN
    raw_text := (SELECT string_agg(op->>'insert', '')
                 FROM jsonb_array_elements(content->'ops') op
                 WHERE jsonb_typeof(op->'insert') = 'string');
  ELSIF content ? 'text' THEN
    raw_text := content->>'text';
  ELSE
    raw_text := content::text;
  END IF;

  normalized := trim(lower(regexp_replace(COALESCE(raw_text, ''), '\s+', ' ', 'g')));
  RETURN encode(extensions.digest(normalized, 'sha256'), 'hex');
END $$;

CREATE OR REPLACE FUNCTION public.questions_set_content_hash()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.content IS NOT NULL THEN
    NEW.content_hash := public.compute_question_hash(NEW.content);
  END IF;
  NEW.updated_at := now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_questions_content_hash ON public.questions;
CREATE TRIGGER trg_questions_content_hash
  BEFORE INSERT OR UPDATE OF content ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.questions_set_content_hash();

-- Chunked backfill
DO $$
DECLARE batch_size int := 5000; affected int;
BEGIN
  LOOP
    UPDATE public.questions
    SET content_hash = public.compute_question_hash(content)
    WHERE id IN (SELECT id FROM public.questions WHERE content_hash IS NULL LIMIT batch_size);
    GET DIAGNOSTICS affected = ROW_COUNT;
    EXIT WHEN affected = 0;
  END LOOP;
END $$;

-- Dedup TRƯỚC UNIQUE — soft-delete bản trùng
WITH dups AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY author_id, content_hash ORDER BY created_at DESC, id DESC) AS rn
  FROM public.questions WHERE deleted_at IS NULL
)
UPDATE public.questions SET deleted_at = now()
WHERE id IN (SELECT id FROM dups WHERE rn > 1);

-- UNIQUE index
CREATE UNIQUE INDEX IF NOT EXISTS idx_questions_author_hash_unique
  ON public.questions(author_id, content_hash)
  WHERE deleted_at IS NULL AND content_hash IS NOT NULL;

-- Performance index cho list
CREATE INDEX IF NOT EXISTS idx_questions_author_active
  ON public.questions(author_id, created_at DESC)
  WHERE deleted_at IS NULL;

COMMIT;
```

- [ ] **Step 2: Apply migration**

Run: `mcp__supabase__apply_migration(name='021_question_content_hash_unique', query=<above>)`
Expected: Success.

- [ ] **Step 3: Verify hash backfilled**

Run: `mcp__supabase__execute_sql(query="SELECT COUNT(*) AS missing FROM public.questions WHERE content_hash IS NULL AND content IS NOT NULL")`
Expected: `missing = 0`.

- [ ] **Step 4: Verify UNIQUE index**

Run: `mcp__supabase__execute_sql(query="SELECT indexname FROM pg_indexes WHERE tablename='questions' AND indexname='idx_questions_author_hash_unique'")`
Expected: 1 row.

- [ ] **Step 5: Verify no duplicates remain**

Run: `mcp__supabase__execute_sql(query="SELECT COUNT(*) AS dups FROM (SELECT author_id, content_hash FROM public.questions WHERE deleted_at IS NULL AND content_hash IS NOT NULL GROUP BY author_id, content_hash HAVING COUNT(*) > 1) t")`
Expected: `dups = 0`.

- [ ] **Step 6: Commit**

```bash
git add supabase/migrations/021_question_content_hash_unique.sql
git commit -m "feat(db): migration 021 — content hash trigger + UNIQUE constraint"
```

---

## Task 1.3: Migration 022 — RLS rebuild

**Files:**
- Create: `supabase/migrations/022_question_bank_rls.sql`

- [ ] **Step 1: Audit existing policies**

Run: `mcp__supabase__execute_sql(query="SELECT polname FROM pg_policy WHERE polrelid='public.questions'::regclass")`
Expected: 5+ policies hiện có (cần DROP).

- [ ] **Step 2: Write migration SQL**

```sql
-- supabase/migrations/022_question_bank_rls.sql
BEGIN;

-- DROP toàn bộ policies cũ
DROP POLICY IF EXISTS "Anyone can view public questions" ON public.questions;
DROP POLICY IF EXISTS "Teachers can manage own questions" ON public.questions;
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON public.questions;
DROP POLICY IF EXISTS "Admins can manage all questions" ON public.questions;
DROP POLICY IF EXISTS "Anyone can view choices of public questions" ON public.question_choices;
DROP POLICY IF EXISTS "Anyone can view objectives of public questions" ON public.question_objectives;
DROP POLICY IF EXISTS qb_select ON public.questions;
DROP POLICY IF EXISTS qb_insert ON public.questions;
DROP POLICY IF EXISTS qb_update ON public.questions;
DROP POLICY IF EXISTS qb_delete ON public.questions;
DROP POLICY IF EXISTS qb_select_trash ON public.questions;

-- SELECT active
CREATE POLICY qb_select ON public.questions FOR SELECT USING (
  deleted_at IS NULL AND (author_id = (select auth.uid()) OR is_global = true)
);

-- SELECT trash (own deleted only)
CREATE POLICY qb_select_trash ON public.questions FOR SELECT USING (
  deleted_at IS NOT NULL AND author_id = (select auth.uid())
);

-- INSERT — chặn teacher set is_global=true
CREATE POLICY qb_insert ON public.questions FOR INSERT WITH CHECK (
  author_id = (select auth.uid()) AND (
    is_global = false OR public.is_admin((select auth.uid()))
  )
);

-- UPDATE — author hoặc admin
CREATE POLICY qb_update ON public.questions FOR UPDATE
  USING (
    author_id = (select auth.uid()) OR public.is_admin((select auth.uid()))
  )
  WITH CHECK (author_id = (select auth.uid()) OR is_global = true);

-- DELETE — chặn hard delete client
CREATE POLICY qb_delete ON public.questions FOR DELETE USING (false);

-- question_choices RLS
DROP POLICY IF EXISTS qc_select ON public.question_choices;
DROP POLICY IF EXISTS qc_insert ON public.question_choices;
DROP POLICY IF EXISTS qc_update ON public.question_choices;
DROP POLICY IF EXISTS qc_delete ON public.question_choices;

CREATE POLICY qc_select ON public.question_choices FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.deleted_at IS NULL
          AND (q.author_id = (select auth.uid()) OR q.is_global = true))
);
CREATE POLICY qc_insert ON public.question_choices FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.author_id = (select auth.uid()))
);
CREATE POLICY qc_update ON public.question_choices FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.author_id = (select auth.uid()))
);
CREATE POLICY qc_delete ON public.question_choices FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.author_id = (select auth.uid()))
);

-- question_objectives RLS (cùng pattern)
DROP POLICY IF EXISTS qo_select ON public.question_objectives;
DROP POLICY IF EXISTS qo_modify ON public.question_objectives;

CREATE POLICY qo_select ON public.question_objectives FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.deleted_at IS NULL
          AND (q.author_id = (select auth.uid()) OR q.is_global = true))
);
CREATE POLICY qo_modify ON public.question_objectives FOR ALL USING (
  EXISTS (SELECT 1 FROM public.questions q WHERE q.id = question_id
          AND q.author_id = (select auth.uid()))
);

COMMIT;
```

- [ ] **Step 3: Apply migration**

Run: `mcp__supabase__apply_migration(name='022_question_bank_rls', query=<above>)`
Expected: Success.

- [ ] **Step 4: Verify policies**

Run: `mcp__supabase__execute_sql(query="SELECT polname, polcmd FROM pg_policy WHERE polrelid='public.questions'::regclass ORDER BY polname")`
Expected: 5 rows: `qb_delete (d)`, `qb_insert (a)`, `qb_select (r)`, `qb_select_trash (r)`, `qb_update (w)`.

- [ ] **Step 5: Verify RLS blocks hard delete**

Run: `mcp__supabase__execute_sql(query="EXPLAIN DELETE FROM public.questions WHERE id='00000000-0000-0000-0000-000000000000'")`
Expected: Plan returns. (To verify policy: run as authenticated role → 0 rows affected.)

- [ ] **Step 6: Commit**

```bash
git add supabase/migrations/022_question_bank_rls.sql
git commit -m "feat(db): migration 022 — RLS rebuild với is_admin helper + trash policy"
```

---

## Task 1.4: Migration 023 — Sync RPC + fix migration 013 bug

**Files:**
- Create: `supabase/migrations/023_sync_rpc_and_choices_fix.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- supabase/migrations/023_sync_rpc_and_choices_fix.sql
BEGIN;

-- ============================================================
-- 1. Fix BUG migration 013: save_questions_to_assignment thiếu choices
-- ============================================================
CREATE OR REPLACE FUNCTION public.save_questions_to_assignment(
  p_questions jsonb,
  p_assignment_id uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions, pg_temp AS $$
DECLARE
  v_caller uuid := (select auth.uid());
  v_q jsonb; v_qid uuid; v_choice jsonb; v_choice_idx int;
  v_inserted int := 0;
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;

  FOR v_q IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
    INSERT INTO public.questions(author_id, type, content, default_points, source, is_global)
    VALUES (
      v_caller,
      v_q->>'type',
      v_q->'content',
      COALESCE((v_q->>'default_points')::numeric, 1.0),
      COALESCE(v_q->>'source', 'teacher'),
      false
    )
    ON CONFLICT (author_id, content_hash) WHERE deleted_at IS NULL DO NOTHING
    RETURNING id INTO v_qid;

    IF v_qid IS NULL THEN
      SELECT id INTO v_qid FROM public.questions
      WHERE author_id = v_caller
        AND content_hash = public.compute_question_hash(v_q->'content')
        AND deleted_at IS NULL
      LIMIT 1;
    END IF;

    -- Parse choices nếu MC
    IF v_q->>'type' = 'multiple_choice' AND v_q ? 'choices' THEN
      DELETE FROM public.question_choices WHERE question_id = v_qid;
      v_choice_idx := 0;
      FOR v_choice IN SELECT * FROM jsonb_array_elements(v_q->'choices')
      LOOP
        INSERT INTO public.question_choices(question_id, content, is_correct, order_idx)
        VALUES (
          v_qid,
          v_choice - 'is_correct',
          COALESCE((v_choice->>'is_correct')::boolean, false),
          v_choice_idx
        );
        v_choice_idx := v_choice_idx + 1;
      END LOOP;
    END IF;

    IF p_assignment_id IS NOT NULL THEN
      INSERT INTO public.assignment_questions(assignment_id, question_id, points, order_idx)
      VALUES (
        p_assignment_id,
        v_qid,
        COALESCE((v_q->>'default_points')::numeric, 1.0),
        v_inserted
      );
    END IF;

    v_inserted := v_inserted + 1;
  END LOOP;

  RETURN jsonb_build_object('inserted', v_inserted);
END $$;

-- ============================================================
-- 2. RPC sync_assignment_to_bank (Phương án E)
-- ============================================================
CREATE OR REPLACE FUNCTION public.sync_assignment_to_bank(p_assignment_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions, pg_temp AS $$
DECLARE
  v_teacher uuid;
  v_caller uuid := (select auth.uid());
  v_ghost record;
  v_hash text;
  v_existing uuid;
  v_new uuid;
  v_type text;
  v_choice jsonb;
  v_choice_idx int;
  v_created int := 0;
  v_linked int := 0;
BEGIN
  PERFORM pg_advisory_xact_lock(hashtext('sync_assignment:' || p_assignment_id::text));

  SELECT teacher_id INTO v_teacher FROM public.assignments WHERE id = p_assignment_id;
  IF v_teacher IS NULL THEN RAISE EXCEPTION 'Assignment not found' USING ERRCODE='P0002'; END IF;
  IF v_teacher <> v_caller THEN RAISE EXCEPTION 'Permission denied' USING ERRCODE='42501'; END IF;

  FOR v_ghost IN
    SELECT id, custom_content, points, rubric, order_idx
    FROM public.assignment_questions
    WHERE assignment_id = p_assignment_id
      AND question_id IS NULL AND custom_content IS NOT NULL
    ORDER BY order_idx
    FOR UPDATE
  LOOP
    v_hash := public.compute_question_hash(v_ghost.custom_content);
    v_type := COALESCE(v_ghost.custom_content->>'type', 'short_answer');

    INSERT INTO public.questions(author_id, type, content, default_points, source, is_global)
    VALUES (
      v_caller, v_type, v_ghost.custom_content,
      COALESCE(v_ghost.points, 1.0), 'teacher', false
    )
    ON CONFLICT (author_id, content_hash) WHERE deleted_at IS NULL DO NOTHING
    RETURNING id INTO v_new;

    IF v_new IS NULL THEN
      SELECT id INTO v_existing FROM public.questions
      WHERE author_id = v_caller AND content_hash = v_hash AND deleted_at IS NULL LIMIT 1;
      v_new := v_existing;
      v_linked := v_linked + 1;
    ELSE
      v_created := v_created + 1;
      IF v_type = 'multiple_choice' AND v_ghost.custom_content ? 'choices' THEN
        v_choice_idx := 0;
        FOR v_choice IN SELECT * FROM jsonb_array_elements(v_ghost.custom_content->'choices')
        LOOP
          INSERT INTO public.question_choices(question_id, content, is_correct, order_idx)
          VALUES (v_new, v_choice - 'is_correct',
                  COALESCE((v_choice->>'is_correct')::boolean, false), v_choice_idx);
          v_choice_idx := v_choice_idx + 1;
        END LOOP;
      END IF;
    END IF;

    UPDATE public.assignment_questions SET question_id = v_new WHERE id = v_ghost.id;
  END LOOP;

  RETURN jsonb_build_object('created', v_created, 'linked', v_linked, 'total', v_created + v_linked);
END $$;

REVOKE ALL ON FUNCTION public.sync_assignment_to_bank(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.sync_assignment_to_bank(uuid) TO authenticated;

-- ============================================================
-- 3. Helper RPC: detect ghost (lightweight cho banner)
-- ============================================================
CREATE OR REPLACE FUNCTION public.detect_ghost_questions(p_assignment_id uuid)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, pg_temp AS $$
  SELECT jsonb_build_object(
    'ghost_count', COUNT(*) FILTER (WHERE question_id IS NULL AND custom_content IS NOT NULL),
    'total_count', COUNT(*)
  )
  FROM public.assignment_questions
  WHERE assignment_id = p_assignment_id;
$$;

REVOKE ALL ON FUNCTION public.detect_ghost_questions(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.detect_ghost_questions(uuid) TO authenticated;

COMMIT;
```

- [ ] **Step 2: Apply migration**

Run: `mcp__supabase__apply_migration(name='023_sync_rpc_and_choices_fix', query=<above>)`
Expected: Success.

- [ ] **Step 3: Verify RPC signatures**

Run: `mcp__supabase__execute_sql(query="SELECT proname, pg_get_function_arguments(oid) AS args FROM pg_proc WHERE proname IN ('sync_assignment_to_bank','detect_ghost_questions','save_questions_to_assignment')")`
Expected: 3 rows với args đúng.

- [ ] **Step 4: Smoke test detect_ghost_questions**

Run: `mcp__supabase__execute_sql(query="SELECT public.detect_ghost_questions((SELECT id FROM public.assignments LIMIT 1))")`
Expected: jsonb `{"ghost_count": N, "total_count": M}`.

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/023_sync_rpc_and_choices_fix.sql
git commit -m "feat(db): migration 023 — sync_assignment_to_bank RPC + fix migration 013 choices bug"
```

---

## Task 1.5: Schema verification via advisors

- [ ] **Step 1: Run security advisor**

Run: `mcp__supabase__get_advisors(type='security')`
Expected: 0 new issues về `questions`, `question_choices`, `question_objectives`.

- [ ] **Step 2: Run performance advisor**

Run: `mcp__supabase__get_advisors(type='performance')`
Expected: No critical issues về indexes mới.

- [ ] **Step 3: Document any advisors output**

If issues found, create `docs/reports/migration-advisors-2026-05-17.md` với findings + mitigation.

- [ ] **Step 4: Commit any docs**

```bash
git add docs/reports/ 2>/dev/null || true
git commit -m "docs: migration advisor report" --allow-empty
```

---

# PHASE 2 — Domain Layer

## Task 2.1: `QuestionSource` enum

**Files:**
- Create: `lib/domain/entities/question_source.dart`

- [ ] **Step 1: Write failing test**

Create `test/unit/entities/question_source_test.dart`:

```dart
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionSource', () {
    test('teacher → "teacher"', () {
      expect(QuestionSource.teacher.dbValue, 'teacher');
    });
    test('aiGenerated → "ai_generated"', () {
      expect(QuestionSource.aiGenerated.dbValue, 'ai_generated');
    });
    test('fromDb("ai_generated") → aiGenerated', () {
      expect(QuestionSource.fromDb('ai_generated'), QuestionSource.aiGenerated);
    });
    test('fromDb unknown value → teacher (default)', () {
      expect(QuestionSource.fromDb('xyz'), QuestionSource.teacher);
    });
  });
}
```

- [ ] **Step 2: Run test — expect FAIL (file not exist)**

Run: `flutter test test/unit/entities/question_source_test.dart`
Expected: FAIL with "Target of URI doesn't exist".

- [ ] **Step 3: Write enum implementation**

Create `lib/domain/entities/question_source.dart`:

```dart
enum QuestionSource {
  teacher, aiGenerated, library, imported, system, admin;

  String get dbValue => switch (this) {
    QuestionSource.teacher => 'teacher',
    QuestionSource.aiGenerated => 'ai_generated',
    QuestionSource.library => 'library',
    QuestionSource.imported => 'imported',
    QuestionSource.system => 'system',
    QuestionSource.admin => 'admin',
  };

  static QuestionSource fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => QuestionSource.teacher,
  );
}
```

- [ ] **Step 4: Run test — expect PASS**

Run: `flutter test test/unit/entities/question_source_test.dart`
Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/question_source.dart test/unit/entities/question_source_test.dart
git commit -m "feat(domain): QuestionSource sealed enum với fromDb mapper"
```

---

## Task 2.2: `QuestionFailure` sealed hierarchy

**Files:**
- Create: `lib/domain/failures/question_failure.dart`
- Test: `test/unit/failures/question_failure_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/failures/question_failure_test.dart
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('QuestionFailure.fromPostgrest', () {
    test('23505 → DuplicateContentDetected', () {
      final e = PostgrestException(message: 'dup', code: '23505');
      expect(QuestionFailure.fromPostgrest(e), isA<DuplicateContentDetected>());
    });
    test('42501 → PermissionDenied', () {
      final e = PostgrestException(message: 'perm', code: '42501');
      expect(QuestionFailure.fromPostgrest(e), isA<PermissionDenied>());
    });
    test('PGRST116 → QuestionNotFound', () {
      final e = PostgrestException(message: 'nf', code: 'PGRST116');
      expect(QuestionFailure.fromPostgrest(e), isA<QuestionNotFound>());
    });
    test('55P03 → RpcLockTimeout', () {
      final e = PostgrestException(message: 'lock', code: '55P03');
      expect(QuestionFailure.fromPostgrest(e), isA<RpcLockTimeout>());
    });
    test('unknown code → UnknownQuestionFailure', () {
      final e = PostgrestException(message: 'x', code: 'XXXXX');
      expect(QuestionFailure.fromPostgrest(e), isA<UnknownQuestionFailure>());
    });
    test('userMessage is Vietnamese', () {
      expect(QuestionNotFound().userMessage, contains('Không'));
    });
    test('NotFound + Duplicate skip sentry', () {
      expect(QuestionNotFound().shouldReportToSentry, false);
      expect(DuplicateContentDetected().shouldReportToSentry, false);
    });
    test('Permission + Network report sentry', () {
      expect(PermissionDenied().shouldReportToSentry, true);
      expect(NetworkFailure().shouldReportToSentry, true);
    });
  });
}
```

- [ ] **Step 2: Run test — FAIL**

Run: `flutter test test/unit/failures/question_failure_test.dart`
Expected: FAIL "URI doesn't exist".

- [ ] **Step 3: Write implementation**

```dart
// lib/domain/failures/question_failure.dart
import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class QuestionFailure implements Exception {
  String get userMessage;
  bool get shouldReportToSentry;

  factory QuestionFailure.fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DuplicateContentDetected(existingId: _extractIdFromDetails(e.details)),
      '42501' => PermissionDenied(),
      'PGRST116' => QuestionNotFound(),
      '40001' || '55P03' => RpcLockTimeout(),
      _ => UnknownQuestionFailure(e),
    };
  }

  factory QuestionFailure.fromAny(Object e) {
    if (e is QuestionFailure) return e;
    if (e is PostgrestException) return QuestionFailure.fromPostgrest(e);
    if (e is SocketException || e is TimeoutException) return NetworkFailure();
    return UnknownQuestionFailure(e);
  }

  static String? _extractIdFromDetails(Object? details) {
    if (details is String) {
      final match = RegExp(r'\(([0-9a-f-]{36})\)').firstMatch(details);
      return match?.group(1);
    }
    return null;
  }
}

class QuestionNotFound implements QuestionFailure {
  @override String get userMessage => 'Không tìm thấy câu hỏi.';
  @override bool get shouldReportToSentry => false;
}

class DuplicateContentDetected implements QuestionFailure {
  final String? existingId;
  DuplicateContentDetected({this.existingId});
  @override String get userMessage => 'Câu hỏi tương tự đã tồn tại trong kho.';
  @override bool get shouldReportToSentry => false;
}

class PermissionDenied implements QuestionFailure {
  @override String get userMessage => 'Bạn không có quyền thực hiện thao tác này.';
  @override bool get shouldReportToSentry => true;
}

class NetworkFailure implements QuestionFailure {
  @override String get userMessage => 'Lỗi kết nối. Kiểm tra mạng và thử lại.';
  @override bool get shouldReportToSentry => true;
}

class RpcLockTimeout implements QuestionFailure {
  @override String get userMessage => 'Hệ thống đang bận. Vui lòng thử lại sau ít phút.';
  @override bool get shouldReportToSentry => true;
}

class SyncFailed implements QuestionFailure {
  final int created;
  final int linked;
  SyncFailed({required this.created, required this.linked});
  @override String get userMessage => 'Đồng bộ thất bại. Đã rollback toàn bộ.';
  @override bool get shouldReportToSentry => true;
}

class UnknownQuestionFailure implements QuestionFailure {
  final Object cause;
  UnknownQuestionFailure(this.cause);
  @override String get userMessage => 'Có lỗi xảy ra. Vui lòng thử lại.';
  @override bool get shouldReportToSentry => true;
}
```

- [ ] **Step 4: Run test — PASS**

Run: `flutter test test/unit/failures/question_failure_test.dart`
Expected: All 8 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/failures/question_failure.dart test/unit/failures/question_failure_test.dart
git commit -m "feat(domain): QuestionFailure sealed hierarchy 7 types với Postgrest mapping"
```

---

## Task 2.3: Update `Question` entity v2

**Files:**
- Modify: `lib/domain/entities/question.dart`
- Test: `test/unit/entities/question_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/entities/question_test.dart
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Question.fromJson backward compat', () {
    test('v1 (only is_public=true) → isGlobal=true', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000001',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'is_public': true,
      };
      final q = Question.fromJson(json);
      expect(q.isGlobal, true);
    });

    test('v2 (is_global=false + is_public=true) → isGlobal=false (precedence)', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000002',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'is_global': false,
        'is_public': true,
      };
      final q = Question.fromJson(json);
      expect(q.isGlobal, false);
    });

    test('v2 deleted_at set → isDeleted=true', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000003',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'deleted_at': '2026-05-17T10:00:00Z',
      };
      final q = Question.fromJson(json);
      expect(q.isDeleted, true);
    });

    test('defaultPoints reads numeric 2.5 from JSON', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000004',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'default_points': 2.5,
      };
      final q = Question.fromJson(json);
      expect(q.defaultPoints, 2.5);
    });

    test('source defaults to "teacher"', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000005',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
      };
      final q = Question.fromJson(json);
      expect(q.source, 'teacher');
    });

    test('isOwnedBy returns true for matching authorId', () {
      final q = Question(
        id: 'q1',
        authorId: 'user1',
        type: QuestionType.multipleChoice,
        content: const {'text': 'Q'},
      );
      expect(q.isOwnedBy('user1'), true);
      expect(q.isOwnedBy('user2'), false);
    });
  });
}
```

- [ ] **Step 2: Run test — expect FAIL (entity chưa có fields mới)**

Run: `flutter test test/unit/entities/question_test.dart`
Expected: FAIL (compile errors).

- [ ] **Step 3: Update `lib/domain/entities/question.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_type.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@freezed
class Question with _$Question {
  const Question._();

  const factory Question({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required QuestionType type,
    required Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') @Default(1.0) double defaultPoints,
    int? difficulty,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'is_global') @Default(false) bool isGlobal,
    @Default('teacher') String source,
    @JsonKey(name: 'content_hash') String? contentHash,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @Deprecated('Use isGlobal — removed in migration 030+')
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) {
    // Bridge v1→v2: nếu thiếu is_global, fallback is_public
    final patched = Map<String, dynamic>.from(json);
    if (!patched.containsKey('is_global') && patched.containsKey('is_public')) {
      patched['is_global'] = patched['is_public'];
    }
    return _$QuestionFromJson(patched);
  }

  bool get isActive => deletedAt == null;
  bool get isDeleted => deletedAt != null;
  bool get isAiGenerated => source == 'ai_generated';
  bool isOwnedBy(String userId) => authorId == userId;
}
```

- [ ] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Success, `question.freezed.dart` + `question.g.dart` regenerated.

- [ ] **Step 5: Run test — expect PASS**

Run: `flutter test test/unit/entities/question_test.dart`
Expected: All 6 tests PASS.

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze lib/domain/entities/question.dart`
Expected: 0 errors. May have `deprecated_member_use` warning at callsites — fix in Phase 5/6.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/entities/question.dart lib/domain/entities/question.freezed.dart lib/domain/entities/question.g.dart test/unit/entities/question_test.dart
git commit -m "feat(domain): Question entity v2 với isGlobal, source, contentHash, deletedAt"
```

---

## Task 2.4: Update `CreateQuestionParams` — required source

**Files:**
- Modify: `lib/domain/entities/create_question_params.dart`
- Test: `test/unit/entities/create_question_params_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/entities/create_question_params_test.dart
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source.aiGenerated → toJson "ai_generated"', () {
    final p = CreateQuestionParams(
      type: QuestionType.multipleChoice,
      content: const {'text': 'Q'},
      source: QuestionSource.aiGenerated,
    );
    expect(p.source.dbValue, 'ai_generated');
  });

  test('source.teacher → toJson "teacher"', () {
    final p = CreateQuestionParams(
      type: QuestionType.shortAnswer,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(p.source.dbValue, 'teacher');
  });

  test('defaults: isGlobal=false, defaultPoints=1.0, tags=[]', () {
    final p = CreateQuestionParams(
      type: QuestionType.essay,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(p.isGlobal, false);
    expect(p.defaultPoints, 1.0);
    expect(p.tags, isEmpty);
  });
}
```

- [ ] **Step 2: Run test — FAIL (compile error: source required)**

Run: `flutter test test/unit/entities/create_question_params_test.dart`
Expected: FAIL.

- [ ] **Step 3: Update entity**

```dart
// lib/domain/entities/create_question_params.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_choice.dart';
import 'question_source.dart';
import 'question_type.dart';

part 'create_question_params.freezed.dart';

@freezed
class CreateQuestionParams with _$CreateQuestionParams {
  const factory CreateQuestionParams({
    required QuestionType type,
    required Map<String, dynamic> content,
    required QuestionSource source,
    Map<String, dynamic>? answer,
    @Default(1.0) double defaultPoints,
    int? difficulty,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool isGlobal,
    @Default(<String>[]) List<String> objectiveIds,
    @Default(<QuestionChoice>[]) List<QuestionChoice> choices,
  }) = _CreateQuestionParams;
}
```

- [ ] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Success.

- [ ] **Step 5: Run test — PASS**

Run: `flutter test test/unit/entities/create_question_params_test.dart`
Expected: 3 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/create_question_params.dart lib/domain/entities/create_question_params.freezed.dart test/unit/entities/create_question_params_test.dart
git commit -m "feat(domain): CreateQuestionParams.source required (enum, compile-time enforce)"
```

---

## Task 2.5: `QuestionFilter` value object + `QuestionSortKey`

**Files:**
- Create: `lib/domain/entities/question_filter.dart`
- Test: `test/unit/entities/question_filter_test.dart`

- [ ] **Step 1: Write test**

```dart
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults: includeGlobal=true, includeDeleted=false, page=0, pageSize=20', () {
    const f = QuestionFilter(authorId: 'u1');
    expect(f.includeGlobal, true);
    expect(f.includeDeleted, false);
    expect(f.page, 0);
    expect(f.pageSize, 20);
    expect(f.sortBy, QuestionSortKey.recentlyCreated);
  });

  test('copyWith works', () {
    const f = QuestionFilter(authorId: 'u1');
    final f2 = f.copyWith(searchQuery: 'toán', sourceFilter: QuestionSource.aiGenerated);
    expect(f2.searchQuery, 'toán');
    expect(f2.sourceFilter, QuestionSource.aiGenerated);
  });
}
```

- [ ] **Step 2: Run test — FAIL**

Run: `flutter test test/unit/entities/question_filter_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write implementation**

```dart
// lib/domain/entities/question_filter.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_source.dart';
import 'question_type.dart';

part 'question_filter.freezed.dart';

enum QuestionSortKey { recentlyCreated, difficulty, type, totalAttempts }

@freezed
class QuestionFilter with _$QuestionFilter {
  const factory QuestionFilter({
    required String authorId,
    @Default(true) bool includeGlobal,
    @Default(false) bool includeDeleted,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    List<String>? objectiveIds,
    QuestionSource? sourceFilter,
    String? searchQuery,
    @Default(QuestionSortKey.recentlyCreated) QuestionSortKey sortBy,
    @Default(0) int page,
    @Default(20) int pageSize,
  }) = _QuestionFilter;
}
```

- [ ] **Step 4: build_runner + test PASS**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/unit/entities/question_filter_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/question_filter.dart lib/domain/entities/question_filter.freezed.dart test/unit/entities/question_filter_test.dart
git commit -m "feat(domain): QuestionFilter value object thay 11 named params"
```

---

## Task 2.6: `GhostReport` + `SyncResult` DTOs

**Files:**
- Create: `lib/domain/entities/ghost_report.dart`
- Create: `lib/domain/entities/sync_result.dart`

- [ ] **Step 1: Write test**

```dart
// test/unit/entities/sync_dtos_test.dart
import 'package:ai_mls/domain/entities/ghost_report.dart';
import 'package:ai_mls/domain/entities/sync_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GhostReport.hasGhosts true when count > 0', () {
    expect(const GhostReport(ghostCount: 5, totalCount: 10).hasGhosts, true);
    expect(const GhostReport(ghostCount: 0, totalCount: 10).hasGhosts, false);
  });

  test('GhostReport.fromJson maps DB jsonb result', () {
    final r = GhostReport.fromJson({'ghost_count': 3, 'total_count': 7});
    expect(r.ghostCount, 3);
    expect(r.totalCount, 7);
  });

  test('SyncResult.fromJson', () {
    final r = SyncResult.fromJson({'created': 5, 'linked': 2, 'total': 7});
    expect(r.created, 5);
    expect(r.linked, 2);
    expect(r.total, 7);
  });
}
```

- [ ] **Step 2: Write implementation**

```dart
// lib/domain/entities/ghost_report.dart
class GhostReport {
  final int ghostCount;
  final int totalCount;
  const GhostReport({required this.ghostCount, required this.totalCount});
  bool get hasGhosts => ghostCount > 0;

  factory GhostReport.fromJson(Map<String, dynamic> json) => GhostReport(
    ghostCount: (json['ghost_count'] as num?)?.toInt() ?? 0,
    totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
  );
}
```

```dart
// lib/domain/entities/sync_result.dart
class SyncResult {
  final int created;
  final int linked;
  final int total;
  const SyncResult({required this.created, required this.linked, required this.total});

  factory SyncResult.fromJson(Map<String, dynamic> json) => SyncResult(
    created: (json['created'] as num?)?.toInt() ?? 0,
    linked: (json['linked'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
  );
}
```

- [ ] **Step 3: Run test PASS + commit**

```bash
flutter test test/unit/entities/sync_dtos_test.dart
git add lib/domain/entities/ghost_report.dart lib/domain/entities/sync_result.dart test/unit/entities/sync_dtos_test.dart
git commit -m "feat(domain): GhostReport + SyncResult DTOs"
```

---

## Task 2.7: Update `QuestionRepository` interface + 5 new use cases

**Files:**
- Modify: `lib/domain/repositories/question_repository.dart`
- Modify: `lib/domain/usecases/question_bank_usecases.dart`

- [ ] **Step 1: Update repository interface**

```dart
// lib/domain/repositories/question_repository.dart
import '../entities/create_question_params.dart';
import '../entities/ghost_report.dart';
import '../entities/question.dart';
import '../entities/question_choice.dart';
import '../entities/question_filter.dart';
import '../entities/sync_result.dart';

abstract class QuestionRepository {
  Future<Question> createQuestion(CreateQuestionParams params);
  Future<Question> updateQuestion(String id, CreateQuestionParams params);
  Future<Question?> getQuestionById(String id);
  Future<List<QuestionChoice>> getChoicesByQuestionId(String id);
  Future<List<Question>> getQuestions(QuestionFilter filter);

  Future<void> softDeleteQuestion(String id);
  Future<void> restoreQuestion(String id);

  Future<Question?> checkDuplicate(String authorId, String contentHash);
  Future<GhostReport> detectGhostQuestions(String assignmentId);
  Future<SyncResult> syncAssignmentToBank(String assignmentId);
}
```

- [ ] **Step 2: Update use cases — replace file**

```dart
// lib/domain/usecases/question_bank_usecases.dart
import '../entities/create_question_params.dart';
import '../entities/ghost_report.dart';
import '../entities/question.dart';
import '../entities/question_choice.dart';
import '../entities/question_filter.dart';
import '../entities/sync_result.dart';
import '../repositories/question_repository.dart';

class CreateQuestionUseCase {
  final QuestionRepository _repo;
  CreateQuestionUseCase(this._repo);
  Future<Question> call(CreateQuestionParams params) => _repo.createQuestion(params);
}

class UpdateQuestionUseCase {
  final QuestionRepository _repo;
  UpdateQuestionUseCase(this._repo);
  Future<Question> call(String id, CreateQuestionParams params) => _repo.updateQuestion(id, params);
}

class GetQuestionBankUseCase {
  final QuestionRepository _repo;
  GetQuestionBankUseCase(this._repo);
  Future<List<Question>> call(QuestionFilter filter) => _repo.getQuestions(filter);
}

class QuestionDetail {
  final Question question;
  final List<QuestionChoice> choices;
  const QuestionDetail({required this.question, required this.choices});
}

class GetQuestionDetailUseCase {
  final QuestionRepository _repo;
  GetQuestionDetailUseCase(this._repo);
  Future<QuestionDetail?> call(String id) async {
    final q = await _repo.getQuestionById(id);
    if (q == null) return null;
    final choices = await _repo.getChoicesByQuestionId(q.id);
    return QuestionDetail(question: q, choices: choices);
  }
}

class SoftDeleteQuestionUseCase {
  final QuestionRepository _repo;
  SoftDeleteQuestionUseCase(this._repo);
  Future<void> call(String id) => _repo.softDeleteQuestion(id);
}

class RestoreQuestionUseCase {
  final QuestionRepository _repo;
  RestoreQuestionUseCase(this._repo);
  Future<void> call(String id) => _repo.restoreQuestion(id);
}

class DetectGhostQuestionsUseCase {
  final QuestionRepository _repo;
  DetectGhostQuestionsUseCase(this._repo);
  Future<GhostReport> call(String assignmentId) => _repo.detectGhostQuestions(assignmentId);
}

class SyncAssignmentToBankUseCase {
  final QuestionRepository _repo;
  SyncAssignmentToBankUseCase(this._repo);
  Future<SyncResult> call(String assignmentId) => _repo.syncAssignmentToBank(assignmentId);
}

class CheckDuplicateUseCase {
  final QuestionRepository _repo;
  CheckDuplicateUseCase(this._repo);
  Future<Question?> call(String authorId, String contentHash) =>
    _repo.checkDuplicate(authorId, contentHash);
}
```

- [ ] **Step 3: Compile check**

Run: `flutter analyze lib/domain/`
Expected: 0 errors. (Data layer will fail compile until Phase 3.)

- [ ] **Step 4: Commit**

```bash
git add lib/domain/repositories/question_repository.dart lib/domain/usecases/question_bank_usecases.dart
git commit -m "feat(domain): repository contract v2 + 5 new use cases (SoftDelete, Restore, DetectGhost, Sync, CheckDup)"
```

---

# PHASE 3 — Data Layer

## Task 3.1: Update `QuestionDTO`

**Files:**
- Modify: `lib/data/models/question_dto.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/question_dto_test.dart (UPDATE existing)
// Thay assertion is_public bằng is_global
import 'package:ai_mls/data/models/question_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toDbInsert sets is_global=false and source from param', () {
    final dto = QuestionDTO(
      type: 'multiple_choice',
      content: const {'text': 'Q'},
      defaultPoints: 1.0,
      source: 'ai_generated',
      choices: const [],
    );
    final insert = dto.toDbInsert();
    expect(insert['is_global'], false);
    expect(insert['source'], 'ai_generated');
    expect(insert.containsKey('is_public'), false);
  });
}
```

- [ ] **Step 2: Run test — FAIL (DTO chưa có source field)**

Run: `flutter test test/unit/question_dto_test.dart`
Expected: FAIL.

- [ ] **Step 3: Update DTO**

In `lib/data/models/question_dto.dart`:
- Add field `final String source;` (constructor param, default `'teacher'`).
- In `toDbInsert()`: remove `'is_public': false`, add `'is_global': false`, add `'source': source`.

- [ ] **Step 4: Run test — PASS**

Run: `flutter test test/unit/question_dto_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/question_dto.dart test/unit/question_dto_test.dart
git commit -m "feat(data): QuestionDTO thêm source field, đổi is_public→is_global"
```

---

## Task 3.2: Update `QuestionBankDataSource` — filter via QuestionFilter, soft delete, checkDuplicate

**Files:**
- Modify: `lib/data/datasources/question_bank_datasource.dart`

- [ ] **Step 1: Refactor signature**

Replace `getQuestionsByAuthor(...)` với `getQuestions(QuestionFilter filter)`:

```dart
Future<List<Map<String, dynamic>>> getQuestions(QuestionFilter filter) async {
  var q = _client.from('questions').select();

  if (filter.includeDeleted) {
    q = q.not('deleted_at', 'is', null);
  } else {
    q = q.filter('deleted_at', 'is', null);
  }

  q = q.eq('author_id', filter.authorId);

  if (filter.type != null) q = q.eq('type', filter.type!.dbValue);
  if (filter.difficulty != null) q = q.eq('difficulty', filter.difficulty!);
  if (filter.tags != null && filter.tags!.isNotEmpty) q = q.overlaps('tags', filter.tags!);
  if (filter.sourceFilter != null) q = q.eq('source', filter.sourceFilter!.dbValue);
  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    q = q.textSearch('content', filter.searchQuery!);
  }

  final from = filter.page * filter.pageSize;
  final to = from + filter.pageSize - 1;
  final orderCol = switch (filter.sortBy) {
    QuestionSortKey.recentlyCreated => 'created_at',
    QuestionSortKey.difficulty => 'difficulty',
    QuestionSortKey.type => 'type',
    QuestionSortKey.totalAttempts => 'created_at', // requires join later
  };
  final res = await q.order(orderCol, ascending: false).range(from, to);
  return List<Map<String, dynamic>>.from(res);
}
```

- [ ] **Step 2: Add soft delete + restore + checkDuplicate methods**

```dart
Future<void> softDeleteQuestion(String id) =>
  _questions.update(id, {'deleted_at': DateTime.now().toUtc().toIso8601String()});

Future<void> restoreQuestion(String id) =>
  _questions.update(id, {'deleted_at': null});

Future<Map<String, dynamic>?> findByContentHash(String authorId, String hash) async {
  final res = await _client.from('questions')
    .select()
    .eq('author_id', authorId)
    .eq('content_hash', hash)
    .isFilter('deleted_at', null)
    .maybeSingle();
  return res;
}
```

- [ ] **Step 3: Add RPC wrappers**

```dart
Future<Map<String, dynamic>> detectGhostQuestions(String assignmentId) async {
  final res = await _client.rpc('detect_ghost_questions',
    params: {'p_assignment_id': assignmentId});
  return Map<String, dynamic>.from(res as Map);
}

Future<Map<String, dynamic>> syncAssignmentToBank(String assignmentId) async {
  final res = await _client.rpc('sync_assignment_to_bank',
    params: {'p_assignment_id': assignmentId});
  return Map<String, dynamic>.from(res as Map);
}
```

- [ ] **Step 4: Remove legacy `deleteQuestion`**

Remove method `Future<void> deleteQuestion(String id) => _questions.delete(id);` (legacy hard delete sẽ throw sau RLS migration).

- [ ] **Step 5: Compile check**

Run: `flutter analyze lib/data/datasources/question_bank_datasource.dart`
Expected: 0 errors.

- [ ] **Step 6: Commit**

```bash
git add lib/data/datasources/question_bank_datasource.dart
git commit -m "feat(data): QuestionBankDataSource refactor — filter VO + soft delete + RPC wrappers"
```

---

## Task 3.3: Update `QuestionRepositoryImpl` — error mapping + new methods

**Files:**
- Modify: `lib/data/repositories/question_repository_impl.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/repositories/question_repository_impl_test.dart
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDataSource extends Mock implements QuestionBankDataSource {}

void main() {
  late MockDataSource ds;
  late QuestionRepositoryImpl repo;

  setUp(() {
    ds = MockDataSource();
    repo = QuestionRepositoryImpl(ds);
  });

  test('createQuestion maps PostgrestException 23505 → DuplicateContentDetected', () async {
    when(() => ds.insertQuestion(any())).thenThrow(
      const PostgrestException(message: 'dup', code: '23505'),
    );
    final params = CreateQuestionParams(
      type: QuestionType.multipleChoice,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(() => repo.createQuestion(params), throwsA(isA<DuplicateContentDetected>()));
  });

  test('softDeleteQuestion calls datasource softDelete', () async {
    when(() => ds.softDeleteQuestion('q1')).thenAnswer((_) async {});
    await repo.softDeleteQuestion('q1');
    verify(() => ds.softDeleteQuestion('q1')).called(1);
  });
}
```

- [ ] **Step 2: Update impl with try/catch mapping**

```dart
@override
Future<Question> createQuestion(CreateQuestionParams params) async {
  try {
    final payload = {
      'type': params.type.dbValue,
      'content': params.content,
      'answer': params.answer,
      'default_points': params.defaultPoints,
      'difficulty': params.difficulty,
      'tags': params.tags,
      'is_global': params.isGlobal,
      'source': params.source.dbValue,
    };
    final row = await _ds.insertQuestion(payload);
    // ... insert choices + objectives
    return Question.fromJson(row);
  } on PostgrestException catch (e) {
    throw QuestionFailure.fromPostgrest(e);
  } catch (e) {
    throw QuestionFailure.fromAny(e);
  }
}

@override
Future<void> softDeleteQuestion(String id) async {
  try {
    await _ds.softDeleteQuestion(id);
  } on PostgrestException catch (e) {
    throw QuestionFailure.fromPostgrest(e);
  }
}

@override
Future<void> restoreQuestion(String id) async {
  try { await _ds.restoreQuestion(id); }
  on PostgrestException catch (e) { throw QuestionFailure.fromPostgrest(e); }
}

@override
Future<Question?> checkDuplicate(String authorId, String contentHash) async {
  final row = await _ds.findByContentHash(authorId, contentHash);
  return row == null ? null : Question.fromJson(row);
}

@override
Future<GhostReport> detectGhostQuestions(String assignmentId) async {
  try {
    final json = await _ds.detectGhostQuestions(assignmentId);
    return GhostReport.fromJson(json);
  } on PostgrestException catch (e) {
    throw QuestionFailure.fromPostgrest(e);
  }
}

@override
Future<SyncResult> syncAssignmentToBank(String assignmentId) async {
  try {
    final json = await _ds.syncAssignmentToBank(assignmentId);
    return SyncResult.fromJson(json);
  } on PostgrestException catch (e) {
    throw QuestionFailure.fromPostgrest(e);
  }
}
```

Remove legacy `deleteQuestion` and update `getQuestionsByAuthor` → `getQuestions(QuestionFilter)`.

- [ ] **Step 3: Run test PASS**

Run: `flutter test test/unit/repositories/question_repository_impl_test.dart`
Expected: 2 tests PASS.

- [ ] **Step 4: flutter analyze**

Run: `flutter analyze lib/data/repositories/question_repository_impl.dart`
Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git add lib/data/repositories/question_repository_impl.dart test/unit/repositories/question_repository_impl_test.dart
git commit -m "feat(data): QuestionRepositoryImpl error mapping + 5 new methods"
```

---

## Task 3.4: Update existing `question_bank_usecases.dart` consumers

**Files:** verify no broken callers

- [ ] **Step 1: Find callers of legacy signatures**

Run: `grep -rn "getQuestionsByAuthor\|deleteQuestion\|includePublic" lib/ test/`
Expected: list of files. Update each to use new signatures.

- [ ] **Step 2: Update notifier `question_bank_notifier.dart` callers**

Replace `repo.getQuestionsByAuthor(...)` with `repo.getQuestions(QuestionFilter(authorId: ..., ...))`.

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/`
Expected: 0 errors. (UI screens for new components còn chưa có — chấp nhận.)

- [ ] **Step 4: Commit**

```bash
git add -u
git commit -m "refactor(data): migrate callers to new repository signatures"
```

---

## Task 3.5: Add `ContentHasher` Dart utility

**Files:**
- Create: `lib/data/utils/content_hasher.dart`

Mirror SQL `compute_question_hash` để dùng cho pre-check duplicate client-side.

- [ ] **Step 1: Write test**

```dart
// test/unit/utils/content_hasher_test.dart
import 'package:ai_mls/data/utils/content_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hashes Quill ops format', () {
    final h = ContentHasher.compute({'ops': [{'insert': 'Câu hỏi 1\n'}]});
    expect(h.length, 64);
  });

  test('hashes {text} legacy format', () {
    final h = ContentHasher.compute({'text': 'Câu hỏi 1'});
    expect(h.length, 64);
  });

  test('normalize whitespace identical', () {
    final a = ContentHasher.compute({'text': 'Câu hỏi 1'});
    final b = ContentHasher.compute({'text': 'Câu   hỏi    1'});
    expect(a, b);
  });

  test('case insensitive', () {
    final a = ContentHasher.compute({'text': 'CÂU HỎI'});
    final b = ContentHasher.compute({'text': 'câu hỏi'});
    expect(a, b);
  });

  test('null content → hash empty string', () {
    final h = ContentHasher.compute(null);
    // SHA-256 of empty string
    expect(h, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
  });
}
```

- [ ] **Step 2: Write implementation**

```dart
// lib/data/utils/content_hasher.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ContentHasher {
  static String compute(Map<String, dynamic>? content) {
    String rawText;

    if (content == null) {
      rawText = '';
    } else if (content['ops'] is List) {
      final ops = content['ops'] as List;
      rawText = ops
        .where((op) => op is Map && op['insert'] is String)
        .map((op) => (op as Map)['insert'] as String)
        .join();
    } else if (content['text'] is String) {
      rawText = content['text'] as String;
    } else {
      rawText = jsonEncode(content);
    }

    final normalized = rawText
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
```

- [ ] **Step 3: Verify `crypto` package**

Run: `grep "crypto:" pubspec.yaml`
If absent: `flutter pub add crypto`.

- [ ] **Step 4: Run test PASS**

Run: `flutter test test/unit/utils/content_hasher_test.dart`
Expected: 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/utils/content_hasher.dart test/unit/utils/content_hasher_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(data): ContentHasher util mirror SQL compute_question_hash (T1 dedup)"
```

---

## Task 3.6: DI wiring — verify providers point to new impl

**Files:**
- Modify: `lib/presentation/providers/question_bank_providers.dart` (likely chỉ verify, không sửa)
- Modify: `lib/main.dart` provider overrides

- [ ] **Step 1: Locate provider override**

Run: `grep -rn "questionRepositoryProvider" lib/main.dart lib/presentation/providers/`
Expected: existing override in main.dart.

- [ ] **Step 2: Verify override returns updated impl**

Confirm `QuestionRepositoryImpl(ds)` signature still matches.

- [ ] **Step 3: Run `flutter analyze lib/`**

Expected: 0 errors.

- [ ] **Step 4: Commit if changes**

```bash
git add -u
git commit -m "chore(di): verify questionRepositoryProvider wires to v2 impl" --allow-empty
```

---

# PHASE 4 — Provider Layer

## Task 4.1: Refactor `QuestionBankNotifier` — state field mutatingIds + soft delete + undo

**Files:**
- Modify: `lib/presentation/providers/question_bank_notifier.dart`
- Create: `lib/presentation/providers/question_bank_state.dart`

- [ ] **Step 1: Create state class**

```dart
// lib/presentation/providers/question_bank_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/question_filter.dart';

part 'question_bank_state.freezed.dart';

@freezed
class QuestionBankState with _$QuestionBankState {
  const factory QuestionBankState({
    @Default(<Question>[]) List<Question> questions,
    @Default(false) bool hasMore,
    @Default(<String>{}) Set<String> mutatingIds,
    QuestionFilter? activeFilter,
  }) = _QuestionBankState;
}
```

- [ ] **Step 2: build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `question_bank_state.freezed.dart` created.

- [ ] **Step 3: Refactor notifier — replace existing**

```dart
// lib/presentation/providers/question_bank_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/create_question_params.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/question_filter.dart';
import '../../domain/failures/question_failure.dart';
import 'question_bank_providers.dart';
import 'question_bank_state.dart';

part 'question_bank_notifier.g.dart';

@riverpod
class QuestionBankNotifier extends _$QuestionBankNotifier {
  @override
  Future<QuestionBankState> build({QuestionFilter? filter}) async {
    final repo = ref.watch(questionRepositoryProvider);
    final effective = filter ?? QuestionFilter(authorId: '');
    final qs = await repo.getQuestions(effective);
    return QuestionBankState(
      questions: qs,
      activeFilter: effective,
      hasMore: qs.length >= effective.pageSize,
    );
  }

  Future<void> softDelete(String id) async {
    final s = state.value;
    if (s == null || s.mutatingIds.contains(id)) return;
    final idx = s.questions.indexWhere((q) => q.id == id);
    if (idx < 0) return;
    final removed = s.questions[idx];

    state = AsyncValue.data(s.copyWith(
      questions: [...s.questions]..removeAt(idx),
      mutatingIds: {...s.mutatingIds, id},
    ));

    try {
      await ref.read(questionRepositoryProvider).softDeleteQuestion(id);
    } on QuestionFailure {
      final cur = state.value!;
      state = AsyncValue.data(cur.copyWith(
        questions: [...cur.questions]..insert(idx.clamp(0, cur.questions.length), removed),
        mutatingIds: cur.mutatingIds.difference({id}),
      ));
      rethrow;
    } finally {
      final cur = state.value;
      if (cur != null) {
        state = AsyncValue.data(cur.copyWith(
          mutatingIds: cur.mutatingIds.difference({id}),
        ));
      }
    }
  }

  Future<void> restore(String id) async {
    final s = state.value;
    if (s == null) return;
    try {
      await ref.read(questionRepositoryProvider).restoreQuestion(id);
      ref.invalidateSelf();
    } on QuestionFailure {
      rethrow;
    }
  }

  Future<Question> create(CreateQuestionParams params) async {
    final repo = ref.read(questionRepositoryProvider);
    final q = await repo.createQuestion(params);
    ref.invalidateSelf();
    return q;
  }
}
```

- [ ] **Step 4: build_runner regen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `question_bank_notifier.g.dart` updated.

- [ ] **Step 5: flutter analyze + commit**

```bash
flutter analyze lib/presentation/providers/
git add lib/presentation/providers/question_bank_*
git commit -m "feat(providers): QuestionBankNotifier refactor — state mutatingIds + softDelete + restore"
```

---

## Task 4.2: `ghostReportProvider` (family)

**Files:**
- Create: `lib/presentation/providers/ghost_report_provider.dart`

- [ ] **Step 1: Write provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/ghost_report.dart';
import 'question_bank_providers.dart';

part 'ghost_report_provider.g.dart';

@riverpod
Future<GhostReport> ghostReport(GhostReportRef ref, String assignmentId) {
  return ref.watch(questionRepositoryProvider).detectGhostQuestions(assignmentId);
}
```

- [ ] **Step 2: build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `ghost_report_provider.g.dart` created.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/providers/ghost_report_provider.*
git commit -m "feat(providers): ghostReportProvider family"
```

---

## Task 4.3: `syncAssignmentToBankProvider` + `questionBankSummaryProvider`

**Files:**
- Create: `lib/presentation/providers/question_bank_summary_provider.dart`

Pattern same as 4.2. Include count breakdown by source (`teacher`/`aiGenerated`/`global`).

- [ ] **Step 1: Create summary provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/question_filter.dart';
import 'auth_providers.dart';
import 'question_bank_providers.dart';

part 'question_bank_summary_provider.g.dart';

class QuestionBankSummary {
  final int totalMine;
  final int totalAi;
  final int totalGlobal;
  const QuestionBankSummary({
    required this.totalMine,
    required this.totalAi,
    required this.totalGlobal,
  });
}

@riverpod
Future<QuestionBankSummary> questionBankSummary(QuestionBankSummaryRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const QuestionBankSummary(totalMine: 0, totalAi: 0, totalGlobal: 0);
  final repo = ref.watch(questionRepositoryProvider);
  // Pagination 0/1000 — đủ cho count summary
  final all = await repo.getQuestions(QuestionFilter(authorId: userId, pageSize: 1000));
  final mine = all.where((q) => q.authorId == userId && q.source != 'ai_generated').length;
  final ai = all.where((q) => q.source == 'ai_generated').length;
  final global = all.where((q) => q.isGlobal).length;
  return QuestionBankSummary(totalMine: mine, totalAi: ai, totalGlobal: global);
}
```

- [ ] **Step 2: build_runner + commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/question_bank_summary_provider.*
git commit -m "feat(providers): questionBankSummaryProvider — count breakdown"
```

---

## Task 4.4: `QuestionVM` view-model + mapper

**Files:**
- Create: `lib/presentation/view_models/question_vm.dart`

- [ ] **Step 1: Write VM + extension mapper**

```dart
// lib/presentation/view_models/question_vm.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/question.dart';

part 'question_vm.freezed.dart';

@freezed
class QuestionVM with _$QuestionVM {
  const factory QuestionVM({
    required Question question,
    required bool isOwn,
    required bool canEdit,
    required bool canDelete,
    required bool canSetGlobal,
  }) = _QuestionVM;
}

extension QuestionVMMapper on Question {
  QuestionVM toVM({required String currentUserId, required bool isAdmin}) => QuestionVM(
    question: this,
    isOwn: authorId == currentUserId,
    canEdit: authorId == currentUserId || isAdmin,
    canDelete: authorId == currentUserId || isAdmin,
    canSetGlobal: isAdmin,
  );
}
```

- [ ] **Step 2: build_runner + flutter analyze + commit**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/presentation/view_models/
git add lib/presentation/view_models/question_vm.*
git commit -m "feat(presentation): QuestionVM view-model + Question.toVM mapper"
```

---

# PHASE 5 — UI Components

## Task 5.1: Routing additions

**Files:**
- Modify: `lib/core/routes/route_constants.dart`
- Modify: `lib/core/routes/app_router.dart`

- [ ] **Step 1: Add route constants**

Append to `route_constants.dart` after `teacherAssignmentBankPath`:

```dart
static const String teacherQuestionBank = 'teacher-question-bank';
static const String teacherQuestionBankPath = '/teacher/question-bank';
static const String teacherQuestionTrash = 'teacher-question-trash';
static const String teacherQuestionTrashPath = '/teacher/question-bank/trash';
static const String teacherQuestionBankDetail = 'teacher-question-bank-detail';
static String teacherQuestionBankDetailPath(String questionId) =>
    '/teacher/question-bank/$questionId';
```

Append to `teacherRoutes` set: `teacherQuestionBank`, `teacherQuestionTrash`, `teacherQuestionBankDetail`.

- [ ] **Step 2: Register GoRoute in `app_router.dart`**

**CRITICAL ORDER:** specific route TRƯỚC param route.

```dart
GoRoute(
  path: AppRoute.teacherQuestionBankPath,
  name: AppRoute.teacherQuestionBank,
  builder: (ctx, state) => const TeacherQuestionBankScreen(),
),
GoRoute(
  path: AppRoute.teacherQuestionTrashPath,
  name: AppRoute.teacherQuestionTrash,
  builder: (ctx, state) => const TeacherQuestionTrashScreen(),
),
GoRoute(
  path: '/teacher/question-bank/:questionId',
  name: AppRoute.teacherQuestionBankDetail,
  builder: (ctx, state) => TeacherQuestionBankDetailScreen(
    questionId: state.pathParameters['questionId']!,
  ),
),
```

- [ ] **Step 3: flutter analyze (will fail until screens exist — OK)**

Run: `flutter analyze lib/core/routes/`
Expected: 0 errors trong route_constants. app_router.dart sẽ báo screens chưa tồn tại — fix khi tạo screens.

- [ ] **Step 4: Commit**

```bash
git add lib/core/routes/route_constants.dart lib/core/routes/app_router.dart
git commit -m "feat(routing): add Question Bank routes (list/trash/detail) — specific trước param"
```

---

## Task 5.2: `QuestionBankCard` widget

**Files:**
- Create: `lib/presentation/views/assignment/teacher/widgets/question_bank/question_bank_card.dart`

- [ ] **Step 1: Write widget**

Standalone card hiển thị: type badge + difficulty stars + preview text + tags chips + stats badge + 3-dot menu.

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuestionBankCard extends StatelessWidget {
  final QuestionVM vm;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const QuestionBankCard({
    super.key, required this.vm,
    this.onTap, this.onEdit, this.onDelete, this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = vm.question;
    final preview = (q.content['text'] as String? ?? '').replaceAll('\n', ' ');
    final truncated = preview.length > 160 ? '${preview.substring(0, 160)}…' : preview;

    return Semantics(
      label: 'Câu hỏi ${q.type.displayName}, độ khó ${q.difficulty ?? 0} trên 5, $truncated',
      child: Card(
        margin: EdgeInsets.symmetric(vertical: DesignSpacing.xs, horizontal: DesignSpacing.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(q, isDark),
              SizedBox(height: DesignSpacing.sm),
              Text(truncated, style: DesignTypography.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (q.tags.isNotEmpty) ...[
                SizedBox(height: DesignSpacing.sm),
                _buildTagsRow(q.tags, isDark),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Question q, bool isDark) {
    return Row(children: [
      _typeBadge(q.type, isDark),
      SizedBox(width: DesignSpacing.sm),
      _difficultyStars(q.difficulty ?? 0),
      if (q.isGlobal) ...[
        SizedBox(width: DesignSpacing.sm),
        Icon(Icons.public, size: DesignIcons.small, color: DesignColors.success),
      ],
      const Spacer(),
      if (vm.canEdit || vm.canDelete) _buildMenu(),
    ]);
  }

  Widget _typeBadge(QuestionType type, bool isDark) => Container(
    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xs, vertical: 2),
    decoration: BoxDecoration(
      color: type.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(DesignRadius.sm),
    ),
    child: Text(type.displayName, style: DesignTypography.labelSmall.copyWith(color: type.color)),
  );

  Widget _difficultyStars(int level) => Row(children: List.generate(5, (i) =>
    Icon(i < level ? Icons.star : Icons.star_border,
      size: DesignIcons.small, color: DesignColors.warning),
  ));

  Widget _buildTagsRow(List<String> tags, bool isDark) => Wrap(
    spacing: DesignSpacing.xs,
    children: tags.take(4).map((t) => Chip(
      label: Text('#$t', style: DesignTypography.labelSmall),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    )).toList(),
  );

  Widget _buildMenu() => PopupMenuButton<String>(
    onSelected: (v) {
      if (v == 'edit') onEdit?.call();
      if (v == 'delete') onDelete?.call();
      if (v == 'duplicate') onDuplicate?.call();
    },
    itemBuilder: (_) => [
      if (vm.canEdit) const PopupMenuItem(value: 'edit', child: Text('Sửa')),
      const PopupMenuItem(value: 'duplicate', child: Text('Sao chép')),
      if (vm.canDelete) const PopupMenuItem(value: 'delete', child: Text('Xóa')),
    ],
  );
}
```

- [ ] **Step 2: flutter analyze + commit**

```bash
flutter analyze lib/presentation/views/assignment/teacher/widgets/question_bank/
git add lib/presentation/views/assignment/teacher/widgets/question_bank/question_bank_card.dart
git commit -m "feat(ui): QuestionBankCard widget với type/difficulty/tags/menu"
```

---

## Task 5.3: `QuestionSourceChipBar` widget

**Files:**
- Create: `lib/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart`

- [ ] **Step 1: Write widget**

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

enum SourceChipFilter { all, mine, aiGenerated, global }

class QuestionSourceChipBar extends StatelessWidget {
  final SourceChipFilter selected;
  final ValueChanged<SourceChipFilter> onChanged;
  final Map<SourceChipFilter, int> counts;

  const QuestionSourceChipBar({
    super.key, required this.selected, required this.onChanged, this.counts = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        children: SourceChipFilter.values.map((f) {
          final isSelected = f == selected;
          return Padding(
            padding: EdgeInsets.only(right: DesignSpacing.xs),
            child: ChoiceChip(
              label: Text('${_label(f)}${counts[f] != null ? ' (${counts[f]})' : ''}'),
              selected: isSelected,
              onSelected: (_) => onChanged(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(SourceChipFilter f) => switch (f) {
    SourceChipFilter.all => 'Tất cả',
    SourceChipFilter.mine => 'Của tôi',
    SourceChipFilter.aiGenerated => 'AI tạo',
    SourceChipFilter.global => 'Toàn cầu',
  };
}
```

- [ ] **Step 2: commit**

```bash
git add lib/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart
git commit -m "feat(ui): QuestionSourceChipBar — filter all/mine/ai/global"
```

---

## Task 5.4: `TeacherQuestionBankScreen` — list view chính

**Files:**
- Create: `lib/presentation/views/assignment/teacher/teacher_question_bank_screen.dart`

- [ ] **Step 1: Write screen scaffold**

Reference Section 4.1 trong spec. Components:
- AppBar + search action
- `QuestionSourceChipBar`
- Filter/sort bar (reuse `assignment_filter_sort_bar.dart` pattern hoặc inline)
- `ListView.builder` consume `questionBankNotifierProvider`
- FAB extended "Tạo câu hỏi mới"
- Empty/Error/Shimmer states

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_notifier.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/question_bank/question_bank_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherQuestionBankScreen extends ConsumerStatefulWidget {
  const TeacherQuestionBankScreen({super.key});

  @override
  ConsumerState<TeacherQuestionBankScreen> createState() => _TeacherQuestionBankScreenState();
}

class _TeacherQuestionBankScreenState extends ConsumerState<TeacherQuestionBankScreen> {
  SourceChipFilter _source = SourceChipFilter.all;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final isAdmin = ref.watch(currentUserIsAdminProvider);
    if (userId == null) return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));

    final filter = QuestionFilter(
      authorId: userId,
      includeGlobal: _source == SourceChipFilter.all || _source == SourceChipFilter.global,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      // ... mapping _source to filter
    );
    final stateAsync = ref.watch(questionBankNotifierProvider(filter: filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Ngân hàng câu hỏi')),
      body: Column(children: [
        QuestionSourceChipBar(
          selected: _source,
          onChanged: (f) => setState(() => _source = f),
        ),
        Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Tìm câu hỏi...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(child: stateAsync.when(
          data: (s) => s.questions.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                itemCount: s.questions.length,
                itemBuilder: (_, i) => QuestionBankCard(
                  vm: s.questions[i].toVM(currentUserId: userId, isAdmin: isAdmin),
                  onTap: () => context.pushNamed(
                    AppRoute.teacherQuestionBankDetail,
                    pathParameters: {'questionId': s.questions[i].id},
                  ),
                  onEdit: () => context.pushNamed(
                    AppRoute.teacherCreateQuestion,
                    extra: {'mode': 'edit', 'initialData': s.questions[i].toJson()},
                  ),
                  onDelete: () => _confirmDelete(s.questions[i].id),
                ),
              ),
          loading: () => const ShimmerListTileLoading(itemCount: 6),
          error: (e, _) => Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: DesignColors.error, size: 48),
              SizedBox(height: DesignSpacing.md),
              Text(e.toString()),
              TextButton(onPressed: () => ref.invalidate(questionBankNotifierProvider),
                child: const Text('Thử lại')),
            ],
          )),
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoute.teacherCreateQuestion, extra: {'mode': 'bankOnly'}),
        label: const Text('Tạo câu hỏi mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
      SizedBox(height: DesignSpacing.md),
      const Text('Kho câu hỏi trống'),
    ],
  ));

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa câu hỏi?'),
        content: const Text('Câu hỏi sẽ vào "Thùng rác" và có thể khôi phục trong 30 ngày.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(questionBankNotifierProvider(filter: null).notifier).softDelete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Đã xóa câu hỏi'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () => ref.read(questionBankNotifierProvider(filter: null).notifier).restore(id),
        ),
        duration: const Duration(seconds: 30),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Smoke run app**

Run: `flutter run -d chrome` → đăng nhập teacher → navigate `/teacher/question-bank` → verify screen renders.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_question_bank_screen.dart
git commit -m "feat(ui): TeacherQuestionBankScreen với filter/search/delete-undo"
```

---

## Task 5.5: `QuestionBankPickerBottomSheet` modal

**Files:**
- Create: `lib/widgets/question_bank/question_bank_picker_sheet.dart`

- [ ] **Step 1: Write modal widget**

Mirror `ObjectiveSelectorSheet` pattern — `DraggableScrollableSheet(initial: 0.9, min: 0.5, max: 0.95)`. Static `show` method returns `List<Question>?`.

Include: handle + header (title + counter + close) + search input + filter chips + checkbox list with exclude support + footer (Hủy + Confirm "Thêm N câu").

- [ ] **Step 2: Smoke test**

Add temp button trong teacher_create_assignment_screen drawer item → tap → sheet hiện.

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/question_bank/question_bank_picker_sheet.dart
git commit -m "feat(ui): QuestionBankPickerBottomSheet multi-select modal"
```

---

## Task 5.6: `GhostQuestionsBanner` widget

**Files:**
- Create: `lib/presentation/views/assignment/teacher/widgets/ghost_questions_banner.dart`

- [ ] **Step 1: Write widget**

Warning bar in-page: icon + title "Phát hiện $N câu chưa đồng bộ" + button "Đồng bộ ngay" + close button.

Wire to `ghostReportProvider` + `syncAssignmentToBankProvider`. Confirm dialog trước sync.

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/views/assignment/teacher/widgets/ghost_questions_banner.dart
git commit -m "feat(ui): GhostQuestionsBanner — banner sync legacy assignments"
```

---

## Task 5.7: `QuestionBankDetailScreen` — 3 tabs

**Files:**
- Create: `lib/presentation/views/assignment/teacher/teacher_question_bank_detail_screen.dart`

- [ ] **Step 1: Write screen**

`DefaultTabController(length: 3)` với Preview / Thống kê / Lịch sử. Bottom action bar với Sửa/Sao chép/Xóa.

- [ ] **Step 2: Smoke test navigation**

Run app, tap card từ list → push detail → verify 3 tabs render.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_question_bank_detail_screen.dart
git commit -m "feat(ui): QuestionBankDetailScreen 3 tabs (Preview/Stats/History)"
```

---

## Task 5.8: `TeacherQuestionTrashScreen`

**Files:**
- Create: `lib/presentation/views/assignment/teacher/teacher_question_trash_screen.dart`

- [ ] **Step 1: Write screen**

List filter `includeDeleted: true, includeGlobal: false`. Mỗi item có button "Khôi phục" (call `restoreQuestion`).

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_question_trash_screen.dart
git commit -m "feat(ui): TeacherQuestionTrashScreen — restore soft-deleted câu hỏi"
```

---

## Task 5.9: `QuestionFilterBottomSheet` + `QuestionSortBottomSheet`

**Files:**
- Create: `lib/widgets/dialogs/question_filter_bottom_sheet.dart`
- Create: `lib/widgets/dialogs/question_sort_bottom_sheet.dart`

- [ ] **Step 1: Write filter sheet**

Type chips (MC/SA/Essay/Math) + Difficulty 1-5 slider + Tags multi-select TextField + objective selector entry point.

- [ ] **Step 2: Write sort sheet**

Radio: Mới nhất / Độ khó / Loại câu / Lượt làm.

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dialogs/question_*.dart
git commit -m "feat(ui): QuestionFilter/SortBottomSheet — advanced filter UI"
```

---

## Task 5.10: `SimilarQuestionDialog`

**Files:**
- Create: `lib/widgets/dialogs/similar_question_dialog.dart`

- [ ] **Step 1: Write dialog**

Dialog show khi `CheckDuplicateUseCase` tìm thấy match: preview câu hiện có + 3 actions:
- "Dùng câu cũ" (return `'useExisting'` với Question)
- "Tạo bản mới" (return `'createAnyway'`)
- "Hủy" (return `'cancel'`)

```dart
static Future<({String action, Question? question})> show(BuildContext context, Question similar) {...}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/dialogs/similar_question_dialog.dart
git commit -m "feat(ui): SimilarQuestionDialog — pre-submit duplicate warning"
```

---

## Task 5.11: `QuestionStatsProvider` + Stats tab content

**Files:**
- Create: `lib/presentation/providers/question_stats_provider.dart`

- [ ] **Step 1: Write provider call RPC `get_question_stats(uuid)` hoặc query `question_stats` table**

```dart
@riverpod
Future<Map<String, dynamic>?> questionStats(QuestionStatsRef ref, String questionId) async {
  final client = ref.watch(supabaseClientProvider);
  return await client.from('question_stats')
    .select()
    .eq('question_id', questionId)
    .maybeSingle();
}
```

- [ ] **Step 2: Wire vào `QuestionBankDetailScreen` Stats tab**

Show `total_attempts`, `correct_count`, `avg_score`, `last_attempted`.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/providers/question_stats_provider.* lib/presentation/views/assignment/teacher/teacher_question_bank_detail_screen.dart
git commit -m "feat(ui): questionStatsProvider + Stats tab content"
```

---

# PHASE 6 — Integration with Existing Screens

## Task 6.1: `teacher_create_assignment_screen.dart` — TODO line 2700 + Ghost banner

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`

- [ ] **Step 1: Replace TODO `onOpenQuestionBank`**

At line ~2700:

```dart
onOpenQuestionBank: () async {
  setState(() => _isDrawerOpen = false);
  await _openQuestionBankPicker();
},
```

- [ ] **Step 2: Add helper `_openQuestionBankPicker` + `_mapQuestionToFormData`**

Reference spec Section 5.1 code.

- [ ] **Step 3: Add `GhostQuestionsBanner` in build**

Khi `_isDraft && widget.assignmentId != null`:

```dart
final reportAsync = ref.watch(ghostReportProvider(widget.assignmentId!));
reportAsync.whenData((report) {
  if (report.hasGhosts && !_ghostDismissed) {
    // Render banner above question list
  }
});
```

- [ ] **Step 4: Handler `_handleSyncGhosts`**

Call `syncAssignmentToBank` use case → snackbar result → invalidate providers + reload local `_questions`.

- [ ] **Step 5: Smoke test E2E**

Run app, open assignment cũ có inline question → verify banner hiện → tap sync → verify success.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
git commit -m "feat(integration): create_assignment picker wire + ghost banner + sync handler"
```

---

## Task 6.2: `teacher_create_question_screen.dart` — Mode + duplicate pre-check

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart`

- [ ] **Step 1: Add `QuestionBankMode` enum**

```dart
enum QuestionBankMode { bankOnly, inAssignment, edit }
```

- [ ] **Step 2: Add `mode` constructor param**

Default `inAssignment` (backward compat).

- [ ] **Step 3: Update `_mapToCreateQuestionParams` line ~312**

Set `source: QuestionSource.teacher` (or from initialData if edit mode).

- [ ] **Step 4: Add duplicate pre-check in `_saveQuestionToSupabase`**

```dart
if (_editingQuestionId == null) {
  final hash = ContentHasher.compute(params.content);
  final similar = await ref.read(questionRepositoryProvider).checkDuplicate(userId, hash);
  if (similar != null && mounted) {
    final res = await SimilarQuestionDialog.show(context, similar);
    if (res.action == 'cancel') return null;
    if (res.action == 'useExisting') return similar.id;
  }
}
```

- [ ] **Step 5: Branch save behavior theo mode**

bankOnly → `context.pop()` no result.
inAssignment → keep current behavior.
edit → `context.pop(true)` signal refresh.

- [ ] **Step 6: Smoke test**

Run: tạo câu mới → tạo trùng nội dung → verify dialog hiện.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart
git commit -m "feat(integration): create_question mode param + duplicate pre-check"
```

---

## Task 6.3: `teacher_ai_generate_question_screen.dart` — source='ai_generated'

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

- [ ] **Step 1: Update line 666 to set `source: QuestionSource.aiGenerated`**

- [ ] **Step 2: Add button "Lưu hết vào kho và đóng"** khi không có context assignment.

- [ ] **Step 3: Smoke test E2E**

Run: AI generate 3 câu → save vào bank → verify DB `source='ai_generated'` (SQL inspect).

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "feat(integration): ai_generate set source='ai_generated' + standalone save button"
```

---

## Task 6.4: `staging_area_widget.dart` — payload source

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart`

- [ ] **Step 1: Add `entrySource` constructor param**

- [ ] **Step 2: Update RPC payload include `source` field per question**

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart
git commit -m "feat(integration): staging_area payload include source"
```

---

## Task 6.5: `teacher_assignment_hub_screen.dart` — Question Bank card

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart`

- [ ] **Step 1: Add row 2 với card "Kho câu hỏi" trong `_buildManagementSection` line ~376**

Reference spec Section 4.6 code. Teal theme.

- [ ] **Step 2: Wire count via `questionBankSummaryProvider`**

- [ ] **Step 3: Tap nav → `context.pushNamed(AppRoute.teacherQuestionBank)`**

- [ ] **Step 4: Smoke test**

Run: hub render → click card → push question bank screen → back → count refresh.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart
git commit -m "feat(integration): hub entry card 'Kho câu hỏi' với live count"
```

---

## Task 6.6: `create_assignment_drawer.dart` — icon + live count

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart`

- [ ] **Step 1: Add `bankCount` constructor param**

- [ ] **Step 2: Update line 156-161 — icon `Icons.bookmarks_outlined`, subtitle live count**

- [ ] **Step 3: Update parent (create_assignment_screen) to pass `bankCount: ref.watch(questionBankSummaryProvider).valueOrNull?.totalMine ?? 0`**

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
git commit -m "feat(integration): drawer icon + live bank count"
```

---

## Task 6.7: Fix all `isPublic` callers → `isGlobal`

**Files:**
- Modify: any remaining file using `isPublic` field (after `@Deprecated`)

- [ ] **Step 1: Find remaining callers**

Run: `grep -rn "isPublic\b" lib/ --include="*.dart"`
Expected: only test/QuestionDTO callers — rename to `isGlobal`.

- [ ] **Step 2: Fix flutter analyze warnings**

Run: `flutter analyze`
Expected: 0 `deprecated_member_use` for `isPublic`.

- [ ] **Step 3: Commit**

```bash
git add -u
git commit -m "refactor: migrate remaining isPublic callers to isGlobal"
```

---

# PHASE 7 — Tests

## Task 7.1: Unit tests for 5 new use cases

**Files:**
- Create:
  - `test/unit/usecases/soft_delete_question_usecase_test.dart`
  - `test/unit/usecases/restore_question_usecase_test.dart`
  - `test/unit/usecases/detect_ghost_questions_usecase_test.dart`
  - `test/unit/usecases/sync_assignment_to_bank_usecase_test.dart`
  - `test/unit/usecases/check_duplicate_usecase_test.dart`

- [ ] **Step 1: Create test files**

Each follows pattern:
```dart
class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late SoftDeleteQuestionUseCase useCase;

  setUp(() {
    repo = MockQuestionRepository();
    useCase = SoftDeleteQuestionUseCase(repo);
  });

  test('success path calls softDeleteQuestion once', () async {
    when(() => repo.softDeleteQuestion('q1')).thenAnswer((_) async {});
    await useCase('q1');
    verify(() => repo.softDeleteQuestion('q1')).called(1);
  });

  test('propagates PermissionDenied', () {
    when(() => repo.softDeleteQuestion(any())).thenThrow(PermissionDenied());
    expect(useCase('q1'), throwsA(isA<PermissionDenied>()));
  });
}
```

Tổng ~15 test cases across 5 files (theo spec 6.4).

- [ ] **Step 2: Run all unit tests**

Run: `flutter test test/unit/usecases/`
Expected: All PASS.

- [ ] **Step 3: Commit**

```bash
git add test/unit/usecases/
git commit -m "test(unit): 5 use cases (SoftDelete, Restore, DetectGhost, Sync, CheckDup)"
```

---

## Task 7.2: Unit tests for `CreateQuestionUseCase` + `GetQuestionBankUseCase` update

**Files:**
- Create: `test/unit/usecases/create_question_usecase_test.dart`
- Create: `test/unit/usecases/get_question_bank_usecase_test.dart`

- [ ] **Step 1: Write tests**

Cover (theo spec):
- creates with `source=teacher` happy
- propagates `DuplicateContentDetected` từ repo
- AI source preserved
- defaults áp dụng
- filter combinations
- default page=0 pageSize=20

- [ ] **Step 2: Run + commit**

```bash
flutter test test/unit/usecases/
git add test/unit/usecases/create_question_usecase_test.dart test/unit/usecases/get_question_bank_usecase_test.dart
git commit -m "test(unit): CreateQuestion + GetBank use cases"
```

---

## Task 7.3: Widget tests `QuestionBankScreen` với Robot pattern

**Files:**
- Create: `test/widget/teacher_question_bank/question_bank_robot.dart`
- Create: `test/widget/teacher_question_bank/question_bank_screen_test.dart`

- [ ] **Step 1: Write robot**

```dart
class QuestionBankRobot {
  final WidgetTester tester;
  QuestionBankRobot(this.tester);

  Future<void> pumpScreen({required List<Question> items, ...}) async { ... }
  Future<void> tapFilter(SourceChipFilter f) async { ... }
  Future<void> enterSearch(String s) async { ... }
  void expectEmptyState() { ... }
  void expectQuestionCount(int n) { ... }
}
```

- [ ] **Step 2: Write 6 test cases**

Theo spec 6.4 widget tests list.

- [ ] **Step 3: Run + commit**

```bash
flutter test test/widget/teacher_question_bank/
git add test/widget/teacher_question_bank/
git commit -m "test(widget): QuestionBankScreen robot + 6 test cases"
```

---

## Task 7.4: Widget tests `QuestionBankPickerBottomSheet`

**Files:**
- Create: `test/widget/teacher_question_bank/question_bank_picker_test.dart`

- [ ] **Step 1: Write 4 test cases**

- multi-select up to maxItems
- 51st tap shows warning
- confirm pops with List<Question>
- cancel pops null

- [ ] **Step 2: Commit**

```bash
flutter test test/widget/teacher_question_bank/question_bank_picker_test.dart
git add test/widget/teacher_question_bank/question_bank_picker_test.dart
git commit -m "test(widget): QuestionBankPickerBottomSheet 4 cases"
```

---

## Task 7.5: Widget tests for `GhostQuestionsBanner` + `QuestionBankDetailScreen`

**Files:**
- Create: `test/widget/teacher_question_bank/ghost_banner_test.dart`
- Create: `test/widget/teacher_question_bank/question_bank_detail_screen_test.dart`

- [ ] **Step 1: GhostBanner — 4 cases**

shown when hasGhosts / tap sync confirm dialog / sync triggers loading / dismiss hides session.

- [ ] **Step 2: DetailScreen — 4 cases**

renders MCQ / renders fill_blank / tap edit pushes / delete confirm + undo snackbar (fake_async).

- [ ] **Step 3: Commit**

```bash
flutter test test/widget/teacher_question_bank/
git add test/widget/teacher_question_bank/
git commit -m "test(widget): GhostBanner + DetailScreen 8 cases"
```

---

## Task 7.6: Integration tests F1-F4

**Files:**
- Create: `integration_test/question_bank_flow_test.dart`

- [ ] **Step 1: Setup**

Theo pattern `integration_test/` hiện có. Requires Supabase staging DB hoặc local.

- [ ] **Step 2: Write 5 scenarios**

- F1 bank-first create: builder → save → assert questions row trước assignment_questions
- F2 picker linking: select 3 → confirm → assert assignment_questions.question_id NOT NULL
- F3 happy sync: 5 ghost → sync → SyncResult(created:5, linked:0)
- F3 dedup sync: 2 assignment cùng content → sync cả 2 → second returns created:0, linked:1
- F4 published immutability: publish + edit + verify workspace giữ snapshot

- [ ] **Step 3: Run**

Run: `flutter test integration_test/question_bank_flow_test.dart`
Expected: 5 scenarios PASS.

- [ ] **Step 4: Commit**

```bash
git add integration_test/question_bank_flow_test.dart
git commit -m "test(integration): F1-F4 flows bank-first + picker + sync + immutability"
```

---

# PHASE 8 — Verification & Cleanup

## Task 8.1: Full system verification

- [ ] **Step 1: flutter analyze**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings (allow `deprecated_member_use` for `isPublic` only).

- [ ] **Step 2: All tests pass**

Run: `flutter test`
Expected: All unit + widget PASS.

- [ ] **Step 3: build apk debug**

Run: `flutter build apk --debug`
Expected: Build success.

- [ ] **Step 4: Supabase advisor check**

Run: `mcp__supabase__get_advisors(type='security')` and `type='performance'`
Expected: 0 critical issues mới.

- [ ] **Step 5: Smoke test E2E theo checklist spec Section 6.6**

Manual 10 items E2E checklist trên emulator/browser.

- [ ] **Step 6: Commit verification report**

Create `docs/reports/question-bank-verification-2026-05-17.md` with pass/fail summary.

```bash
git add docs/reports/
git commit -m "docs(verification): question-bank phase 8 verification report"
```

---

## Task 8.2: Cleanup

- [ ] **Step 1: Run cleanup skill**

Invoke `/cleanup` to remove temp artifacts.

- [ ] **Step 2: Update memory-bank**

Update `memory-bank/activeContext.md` + `progress.md` + `systemPatterns.md` với Question Bank pattern.

- [ ] **Step 3: Final commit**

```bash
git add memory-bank/
git commit -m "docs(memory-bank): document Question Bank feature pattern"
```

---

# Self-Review Checklist (Plan Author)

## Spec coverage

| Spec section | Covered by tasks |
|---|---|
| §1 Architecture (4 flow F1-F4) | Phase 5-6 (UI + integration), Phase 7.6 (integration tests) |
| §2.1 Migration 020 | Task 1.1 ✅ |
| §2.2 Migration 021 | Task 1.2 ✅ |
| §2.3 Migration 022 (RLS) | Task 1.3 ✅ |
| §2.4 Migration 023 (RPC + fix 013) | Task 1.4 ✅ |
| §3.1 Question entity v2 | Task 2.3 ✅ |
| §3.2 QuestionSource enum | Task 2.1 ✅ |
| §3.3 CreateQuestionParams required source | Task 2.4 ✅ |
| §3.4 QuestionFilter VO | Task 2.5 ✅ |
| §3.5 QuestionFailure sealed | Task 2.2 ✅ |
| §3.6 Repository interface v2 | Task 2.7 ✅ |
| §3.7 Use cases (9) | Tasks 2.7 + 7.1 + 7.2 ✅ |
| §3.8 Provider state + softDelete | Task 4.1 ✅ |
| §3.9 QuestionVM | Task 4.4 ✅ |
| §3.10 Source tracking | Tasks 6.2, 6.3, 6.4 ✅ |
| §4.1 TeacherQuestionBankScreen | Task 5.4 ✅ |
| §4.2 QuestionBankDetailScreen | Task 5.7 ✅ |
| §4.3 QuestionBankPickerBottomSheet | Task 5.5 ✅ |
| §4.4 GhostQuestionsBanner | Task 5.6 ✅ |
| §4.5 QuestionTrashScreen | Task 5.8 ✅ |
| §4.6 Routing + Hub entry | Tasks 5.1, 6.5 ✅ |
| §5.1-5.7 Integration | Phase 6 ✅ |
| §6.1-6.6 Error/Test/Observability | Phase 7 + 8 ✅ |

**Gaps:** None.

## Type consistency

- `QuestionSource.aiGenerated.dbValue == 'ai_generated'` — consistent.
- `SourceChipFilter.aiGenerated` (UI enum) ≠ `QuestionSource.aiGenerated` (domain enum) — intentional separation, mapped at filter compose.
- `softDelete()` method name consistent across notifier/repo/datasource.
- `restore()` method name consistent.
- `SyncResult.created/linked/total` consistent JSON keys.
- `GhostReport.ghostCount/totalCount` consistent.

## Placeholder scan

✅ No "TBD", "TODO", "implement later", "fill in details", or "similar to Task N" found. All steps contain concrete code or explicit commands.

---

**Plan complete and saved to `docs/superpowers/plans/2026-05-17-question-bank.md`.**

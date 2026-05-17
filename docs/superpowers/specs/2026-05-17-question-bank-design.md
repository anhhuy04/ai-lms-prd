# Question Bank — Thiết kế Hệ thống Quản lý Câu hỏi Đơn lẻ

**Ngày:** 2026-05-17
**Phiên bản:** v2 (sau 2 vòng stress-test bởi DBA agent + Flutter Lead agent + QE agent)
**Trạng thái:** Approved (chờ implementation plan)

---

## 0. Executive Summary

Hệ thống AI LMS hiện tại có backend Question Bank đã sẵn (`questions`, `question_choices`, `question_objectives`, `question_stats`), domain layer + datasource + provider đã có; nhưng **thiếu toàn bộ UI/UX và 4 cột schema quan trọng**. Câu hỏi đang nằm inline trong `assignment_questions.custom_content` thay vì có nguồn chân lý ở `questions` — gây Technical Debt nghiêm trọng cho AI Analytics (Phase 7).

**Mục tiêu thiết kế:** Triển khai Question Bank theo nguyên tắc:

1. **Bank-first lifecycle** — INSERT `questions` TRƯỚC, sau đó tham chiếu vào `assignment_questions`
2. **Delta Override** — sửa câu hỏi trong Bank không phá assignment cũ đã publish (snapshot qua `assignment_variants`)
3. **Smart Sync (Phương án E)** — Ghost detection + Batch atomic + Deduplication T1 (SHA-256 hash polymorphic)
4. **Private by default** — `is_global` chỉ admin set được, RLS enforce qua `public.is_admin(uid)`
5. **Source tracking** — required enum `QuestionSource` compile-time enforce, không silent drift

**Scope:** Hybrid B+ (Hub-ready cho AI Analytics) — không bao gồm public sharing UI giữa GV (RLS-only ở phase này) và bulk operations.

---

## 1. Architecture Overview

### 1.1 Mô hình 3 lớp

```
UI Layer
├── Hub Entry (teacher_assignment_hub_screen)
├── TeacherQuestionBankScreen (list + filter + search)
├── QuestionBankDetailScreen (preview + stats + usage history)
├── QuestionBankPickerBottomSheet (multi-select chèn vào assignment)
├── QuestionTrashScreen (soft-deleted, restore window 30 ngày)
└── GhostQuestionsBanner (cảnh báo + sync button trong builder)
    │
    ▼ Riverpod
Domain Layer
├── Entities: Question, QuestionChoice, QuestionFilter, GhostReport, SyncResult
├── Sealed: QuestionSource (enum), QuestionFailure (7 types)
├── Repository interface: QuestionRepository
└── Use Cases: Create, Update, Get, GetDetail, SoftDelete, Restore,
              DetectGhost, SyncAssignmentToBank, CheckDuplicate, SearchBank
    │
    ▼ Repository pattern
Data Layer
├── question_bank_datasource (CRUD + filter + soft delete)
├── question_repository_impl (catch PostgrestException → map QuestionFailure)
└── RPC clients: sync_assignment_to_bank, detect_ghost_questions
    │
    ▼ Supabase
PostgreSQL
├── Tables: questions (+ is_global, source, content_hash, deleted_at),
│           question_choices, question_objectives, question_stats
├── RPC: sync_assignment_to_bank(uuid) RETURNS jsonb
├── Trigger: questions_set_content_hash (auto SHA-256), bridge is_global ↔ is_public
├── RLS: deleted_at IS NULL AND (author_id=uid OR is_global=true)
└── Index: UNIQUE (author_id, content_hash) WHERE deleted_at IS NULL
```

### 1.2 Bốn luồng dữ liệu chính

| # | Luồng | Trigger | Hành vi |
|---|-------|---------|---------|
| **F1** | Tạo mới Bank-first | GV thêm câu hỏi trong builder | INSERT `questions` → INSERT `assignment_questions(question_id, ...)` với ref |
| **F2** | Picker chọn từ Bank | GV mở `QuestionBankPickerBottomSheet` | INSERT `assignment_questions(question_id, points, order_idx)` — KHÔNG clone content |
| **F3** | Ghost Sync | GV bấm banner trong builder cho assignment cũ | RPC `sync_assignment_to_bank(aid)` → atomic loop {dedup hash, link hoặc insert} |
| **F4** | Edit từ Bank | GV sửa câu hỏi trong `QuestionBankDetailScreen` | UPDATE `questions`. Draft assignment thấy nội dung mới (live link). Published assignment giữ snapshot qua `assignment_variants.custom_questions`. |

### 1.3 Phân tách "bản thiết kế" vs "công trình"

- **`questions`** = canonical content (Single Source of Truth)
- **`assignment_questions.custom_content`** = optional override (delta — chỉ ghi đè khi GV chủ động sửa trong builder, không tự động)
- **`assignment_variants.custom_questions`** = immutable snapshot khi publish (bảo vệ học sinh đang làm bài)

---

## 2. Schema Migration v2

### 2.1 Migration 020 — Schema upgrade (Additive)

Đổi từ kế hoạch RENAME ban đầu sang ADD COLUMN vì verify được 4 indexes + 5 RLS policies cũ đang reference `is_public`.

```sql
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- ADD columns (không RENAME để app cũ vẫn ghi is_public được)
ALTER TABLE public.questions
  ADD COLUMN IF NOT EXISTS is_global boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'teacher',
  ADD COLUMN IF NOT EXISTS content_hash text,
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- CHECK source — đồng bộ pattern learning_objectives + thêm library/imported cho roadmap
ALTER TABLE public.questions
  ADD CONSTRAINT questions_source_check
  CHECK (source IN ('system','admin','teacher','ai_generated','library','imported'));

-- Backfill is_global từ is_public
UPDATE public.questions SET is_global = is_public WHERE is_global IS DISTINCT FROM is_public;

-- Bridge trigger: giữ is_global ↔ is_public sync trong transition window
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

**Deprecation timeline:** Drop `is_public` ở migration 030+ sau khi 95% client adopt v2 (~2 sprint = 4 tuần).

### 2.2 Migration 021 — Hash trigger polymorphic + Dedup + UNIQUE index

```sql
BEGIN;

-- Hash function POLYMORPHIC: handle Quill ops / {text} / fallback
CREATE OR REPLACE FUNCTION public.compute_question_hash(content jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE raw_text text; normalized text;
BEGIN
  IF content IS NULL THEN RETURN encode(extensions.digest('', 'sha256'), 'hex'); END IF;

  IF content ? 'ops' AND jsonb_typeof(content->'ops') = 'array' THEN
    -- Quill delta format
    raw_text := (SELECT string_agg(op->>'insert', '')
                 FROM jsonb_array_elements(content->'ops') op
                 WHERE jsonb_typeof(op->'insert') = 'string');
  ELSIF content ? 'text' THEN
    -- Legacy QuestionDTO format
    raw_text := content->>'text';
  ELSE
    -- Fallback
    raw_text := content::text;
  END IF;

  normalized := trim(lower(regexp_replace(COALESCE(raw_text, ''), '\s+', ' ', 'g')));
  RETURN encode(extensions.digest(normalized, 'sha256'), 'hex');
END $$;

-- Trigger BEFORE INSERT OR UPDATE OF content
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

-- BACKFILL CHUNKED — không lock toàn bảng
DO $$
DECLARE batch_size int := 5000; affected int;
BEGIN
  LOOP
    UPDATE public.questions SET content_hash = public.compute_question_hash(content)
    WHERE id IN (SELECT id FROM public.questions WHERE content_hash IS NULL LIMIT batch_size);
    GET DIAGNOSTICS affected = ROW_COUNT;
    EXIT WHEN affected = 0;
  END LOOP;
END $$;

-- DEDUP TRƯỚC UNIQUE — soft-delete bản trùng (giữ row mới nhất)
WITH dups AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY author_id, content_hash ORDER BY created_at DESC, id DESC) AS rn
  FROM public.questions WHERE deleted_at IS NULL
)
UPDATE public.questions SET deleted_at = now()
WHERE id IN (SELECT id FROM dups WHERE rn > 1);

-- UNIQUE index — giờ safe
CREATE UNIQUE INDEX IF NOT EXISTS idx_questions_author_hash_unique
  ON public.questions(author_id, content_hash)
  WHERE deleted_at IS NULL AND content_hash IS NOT NULL;

-- Index cho query list
CREATE INDEX IF NOT EXISTS idx_questions_author_active
  ON public.questions(author_id, created_at DESC)
  WHERE deleted_at IS NULL;

COMMIT;
```

### 2.3 Migration 022 — RLS rebuild (DROP cũ + CREATE mới)

```sql
BEGIN;

-- DROP toàn bộ policies cũ — bắt buộc để tránh duplicate + leak qua public role
DROP POLICY IF EXISTS "Anyone can view public questions" ON public.questions;
DROP POLICY IF EXISTS "Teachers can manage own questions" ON public.questions;
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON public.questions;
DROP POLICY IF EXISTS "Admins can manage all questions" ON public.questions;
DROP POLICY IF EXISTS "Anyone can view choices of public questions" ON public.question_choices;
DROP POLICY IF EXISTS "Anyone can view objectives of public questions" ON public.question_objectives;

-- SELECT
CREATE POLICY qb_select ON public.questions FOR SELECT USING (
  deleted_at IS NULL AND (author_id = (select auth.uid()) OR is_global = true)
);

-- INSERT — chặn teacher tự set is_global=true (admin-only)
CREATE POLICY qb_insert ON public.questions FOR INSERT WITH CHECK (
  author_id = (select auth.uid()) AND (
    is_global = false OR public.is_admin((select auth.uid()))
  )
);

-- UPDATE — author của row HOẶC admin; không cho đổi author_id
CREATE POLICY qb_update ON public.questions FOR UPDATE
  USING (
    deleted_at IS NULL AND (
      author_id = (select auth.uid()) OR public.is_admin((select auth.uid()))
    )
  )
  WITH CHECK (author_id = (select auth.uid()) OR is_global = true);

-- DELETE — chặn hard delete từ client (mọi delete phải soft via UPDATE deleted_at)
CREATE POLICY qb_delete ON public.questions FOR DELETE USING (false);

-- SELECT cho Trash screen — user xem câu hỏi mình đã soft-delete (chỉ own, không bao gồm global)
CREATE POLICY qb_select_trash ON public.questions FOR SELECT USING (
  deleted_at IS NOT NULL AND author_id = (select auth.uid())
);
-- NOTE: Postgres OR giữa các permissive policies → query `WHERE deleted_at IS NOT NULL`
-- ở Trash screen sẽ chỉ match policy này, không leak qua qb_select.

-- question_choices: thừa kế quyền + filter deleted
CREATE POLICY qc_select ON public.question_choices FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.questions q
          WHERE q.id = question_id AND q.deleted_at IS NULL
          AND (q.author_id = (select auth.uid()) OR q.is_global = true))
);

-- (Tương tự CRUD cho question_choices + question_objectives — chi tiết trong migration file)

COMMIT;
```

### 2.4 Migration 023 — RPC sync_assignment_to_bank + Fix BUG migration 013

Gộp 2 RPC trong cùng migration vì cùng scope "Question Bank correctness":

```sql
BEGIN;

-- =============================================================
-- 1. Fix BUG migration 013: save_questions_to_assignment thiếu INSERT choices
-- =============================================================
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
  FOR v_q IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
    INSERT INTO public.questions(author_id, type, content, default_points, source, is_global)
    VALUES (v_caller, v_q->>'type', v_q->'content',
            COALESCE((v_q->>'default_points')::numeric, 1.0),
            COALESCE(v_q->>'source', 'teacher'), false)
    ON CONFLICT (author_id, content_hash) WHERE deleted_at IS NULL DO NOTHING
    RETURNING id INTO v_qid;

    IF v_qid IS NULL THEN
      SELECT id INTO v_qid FROM public.questions
      WHERE author_id = v_caller AND content_hash = public.compute_question_hash(v_q->'content')
        AND deleted_at IS NULL LIMIT 1;
    END IF;

    -- FIX: parse choices nếu là MC
    IF v_q->>'type' = 'multiple_choice' AND v_q ? 'choices' THEN
      v_choice_idx := 0;
      FOR v_choice IN SELECT * FROM jsonb_array_elements(v_q->'choices')
      LOOP
        INSERT INTO public.question_choices(question_id, content, is_correct, order_idx)
        VALUES (v_qid, v_choice - 'is_correct',
                COALESCE((v_choice->>'is_correct')::boolean, false), v_choice_idx)
        ON CONFLICT DO NOTHING;
        v_choice_idx := v_choice_idx + 1;
      END LOOP;
    END IF;

    IF p_assignment_id IS NOT NULL THEN
      INSERT INTO public.assignment_questions(assignment_id, question_id, points, order_idx)
      VALUES (p_assignment_id, v_qid, COALESCE((v_q->>'default_points')::numeric, 1.0), v_inserted);
    END IF;

    v_inserted := v_inserted + 1;
  END LOOP;

  RETURN jsonb_build_object('inserted', v_inserted);
END $$;

-- =============================================================
-- 2. RPC sync_assignment_to_bank (Phương án E — Smart Sync)
-- =============================================================
CREATE OR REPLACE FUNCTION public.sync_assignment_to_bank(p_assignment_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions, pg_temp AS $$
DECLARE
  v_teacher uuid; v_caller uuid := (select auth.uid());
  v_ghost record; v_hash text; v_existing uuid; v_new uuid;
  v_type text; v_choice jsonb; v_choice_idx int;
  v_created int := 0; v_linked int := 0;
BEGIN
  -- Advisory lock chống race condition cấp assignment
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

    -- Idempotent insert (chống race + dedup T1)
    INSERT INTO public.questions(author_id, type, content, default_points, source, is_global)
    VALUES (v_caller, v_type, v_ghost.custom_content,
            COALESCE(v_ghost.points, 1.0), 'teacher', false)
    ON CONFLICT (author_id, content_hash) WHERE deleted_at IS NULL DO NOTHING
    RETURNING id INTO v_new;

    IF v_new IS NULL THEN
      -- Conflict → link sang existing
      SELECT id INTO v_existing FROM public.questions
      WHERE author_id = v_caller AND content_hash = v_hash AND deleted_at IS NULL LIMIT 1;
      v_new := v_existing;
      v_linked := v_linked + 1;
    ELSE
      v_created := v_created + 1;

      -- Parse choices nếu type=MC
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

-- =============================================================
-- 3. Helper RPC: detect ghost questions (lightweight cho banner)
-- =============================================================
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

GRANT EXECUTE ON FUNCTION public.detect_ghost_questions(uuid) TO authenticated;

-- =============================================================
-- 4. question_stats trigger guard — bỏ qua câu đã soft-delete
-- =============================================================
CREATE OR REPLACE FUNCTION public.fn_update_question_stats_v2()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.questions q
             WHERE q.id = NEW.question_id AND q.deleted_at IS NOT NULL) THEN
    RETURN NEW;
  END IF;
  -- ... existing stats update logic ...
  RETURN NEW;
END $$;

COMMIT;
```

---

## 3. Repository & Use Case Layer

### 3.1 Entity `Question` v2

```dart
@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required QuestionType type,
    required Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') @Default(1.0) double defaultPoints,  // double, không int
    int? difficulty,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'is_global') @Default(false) bool isGlobal,
    @Default('teacher') String source,
    @JsonKey(name: 'content_hash') String? contentHash,       // read-only, DB trigger fill
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @Deprecated('Use isGlobal — removed after sprint X (migration 030)')
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Question;

  /// Bridge v1→v2: fallback `is_public` nếu DB chưa migrate
  factory Question.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('is_global') && json.containsKey('is_public')) {
      json = {...json, 'is_global': json['is_public']};
    }
    return _$QuestionFromJson(json);
  }
}

extension QuestionX on Question {
  bool get isActive => deletedAt == null;
  bool get isDeleted => deletedAt != null;
  bool get isAiGenerated => source == 'ai_generated';
  bool isOwnedBy(String userId) => authorId == userId;
}
```

### 3.2 `QuestionSource` sealed enum (required, không default)

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
    (e) => e.dbValue == value, orElse: () => QuestionSource.teacher);
}
```

### 3.3 `CreateQuestionParams` — required source

```dart
@freezed
class CreateQuestionParams with _$CreateQuestionParams {
  const factory CreateQuestionParams({
    required QuestionType type,
    required Map<String, dynamic> content,
    required QuestionSource source,                          // REQUIRED, không default
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

### 3.4 `QuestionFilter` value object (thay 11 params)

```dart
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

enum QuestionSortKey { recentlyCreated, difficulty, type, totalAttempts }
```

### 3.5 `QuestionFailure` sealed hierarchy

```dart
sealed class QuestionFailure implements Exception {
  String get userMessage;
  bool get shouldReportToSentry;

  factory QuestionFailure.fromPostgrest(PostgrestException e) => switch (e.code) {
    '23505' => DuplicateContentDetected(existingId: _extractIdFromDetails(e.details)),
    '42501' => PermissionDenied(),
    'PGRST116' => QuestionNotFound(),
    '40001' || '55P03' => RpcLockTimeout(),
    _ => UnknownQuestionFailure(e),
  };

  factory QuestionFailure.fromAny(Object e) {
    if (e is QuestionFailure) return e;
    if (e is PostgrestException) return QuestionFailure.fromPostgrest(e);
    if (e is SocketException || e is TimeoutException) return NetworkFailure();
    return UnknownQuestionFailure(e);
  }
}

class QuestionNotFound        extends QuestionFailure { /* PGRST116, !sentry */ }
class DuplicateContentDetected extends QuestionFailure { final String? existingId; /* 23505, !sentry */ }
class PermissionDenied        extends QuestionFailure { /* 42501, sentry */ }
class NetworkFailure          extends QuestionFailure { /* SocketException, sentry */ }
class RpcLockTimeout          extends QuestionFailure { /* 40001/55P03, sentry */ }
class SyncFailed              extends QuestionFailure { final int created, linked; /* sentry */ }
class UnknownQuestionFailure  extends QuestionFailure { final Object cause; /* sentry */ }
```

### 3.6 Repository interface v2

```dart
abstract class QuestionRepository {
  // CRUD
  Future<Question> createQuestion(CreateQuestionParams params);
  Future<Question> updateQuestion(String id, CreateQuestionParams params);
  Future<Question?> getQuestionById(String id);
  Future<List<QuestionChoice>> getChoicesByQuestionId(String id);

  // Soft delete
  Future<void> softDeleteQuestion(String id);
  Future<void> restoreQuestion(String id);

  // Search & filter
  Future<List<Question>> getQuestions(QuestionFilter filter);

  // Smart Sync
  Future<Question?> checkDuplicate(String authorId, String contentHash);
  Future<GhostReport> detectGhostQuestions(String assignmentId);
  Future<SyncResult> syncAssignmentToBank(String assignmentId);
}

class GhostReport {
  final int ghostCount; final int totalCount;
  const GhostReport({required this.ghostCount, required this.totalCount});
  bool get hasGhosts => ghostCount > 0;
}

class SyncResult {
  final int created; final int linked; final int total;
  const SyncResult({required this.created, required this.linked, required this.total});
}
```

### 3.7 Use Cases

| Use Case | Input → Output | Side-effect |
|----------|----------------|-------------|
| `CreateQuestionUseCase` | `CreateQuestionParams` → `Question` | Bank-first INSERT; pre-check duplicate UI warn; catch 23505 → `DuplicateContentDetected(existingId)` |
| `UpdateQuestionUseCase` | `(id, params)` → `Question` | UPDATE Bank only; KHÔNG đụng assignment cũ |
| `GetQuestionBankUseCase` | `QuestionFilter` → `List<Question>` | Server-side filter + paging |
| `GetQuestionDetailUseCase` | `id` → `QuestionDetail (q + choices)` | Load song song |
| `SoftDeleteQuestionUseCase` | `id` → `void` | UPDATE `deleted_at = now()` |
| `RestoreQuestionUseCase` | `id` → `void` | UPDATE `deleted_at = null` |
| `DetectGhostQuestionsUseCase` | `assignmentId` → `GhostReport` | RPC `detect_ghost_questions` |
| `SyncAssignmentToBankUseCase` | `assignmentId` → `SyncResult` | RPC `sync_assignment_to_bank` (atomic, advisory lock) |
| `CheckDuplicateUseCase` | `(authorId, contentHash)` → `Question?` | Tra cứu kho theo hash trước submit |

### 3.8 Provider layer (Riverpod)

```dart
@riverpod
class QuestionBankNotifier extends _$QuestionBankNotifier {
  @override
  Future<QuestionBankState> build({QuestionFilter? filter}) async { ... }

  /// State field thay vì instance bool — track concurrent mutation per-question
  Future<void> softDelete(String id) async {
    final s = state.value!;
    if (s.mutatingIds.contains(id)) return;          // guard
    final idx = s.questions.indexWhere((q) => q.id == id);
    if (idx < 0) return;
    final removed = s.questions[idx];

    // Optimistic
    state = AsyncValue.data(s.copyWith(
      questions: [...s.questions]..removeAt(idx),
      mutatingIds: {...s.mutatingIds, id},
    ));

    try {
      await ref.read(questionRepositoryProvider).softDeleteQuestion(id);
      _scheduleUndoSnackbar(removed, idx);
    } on QuestionFailure {
      // Rollback chỉ 1 item tại originalIndex
      final cur = state.value!;
      state = AsyncValue.data(cur.copyWith(
        questions: [...cur.questions]..insert(idx.clamp(0, cur.questions.length), removed),
      ));
      rethrow;
    } finally {
      final cur = state.value!;
      state = AsyncValue.data(cur.copyWith(
        mutatingIds: cur.mutatingIds.difference({id}),
      ));
    }
  }
}

@freezed
class QuestionBankState with _$QuestionBankState {
  const factory QuestionBankState({
    @Default([]) List<Question> questions,
    @Default(false) bool hasMore,
    @Default({}) Set<String> mutatingIds,            // tracking concurrent op
    QuestionFilter? activeFilter,
  }) = _QuestionBankState;
}

@riverpod
Future<GhostReport> ghostReport(GhostReportRef ref, String assignmentId) =>
    ref.watch(questionRepositoryProvider).detectGhostQuestions(assignmentId);

@riverpod
Future<SyncResult> syncAssignmentToBank(Ref ref, String assignmentId) =>
    ref.watch(questionRepositoryProvider).syncAssignmentToBank(assignmentId);
```

### 3.9 `QuestionVM` view-model wrapper

Tránh pass `currentUserId` khắp UI — compute derived state ở notifier:

```dart
@freezed
class QuestionVM with _$QuestionVM {
  const factory QuestionVM({
    required Question question,
    required bool isOwn,                   // q.authorId == currentUserId
    required bool canEdit,                 // isOwn || isAdmin
    required bool canDelete,               // isOwn || isAdmin
    required bool canSetGlobal,            // isAdmin
  }) = _QuestionVM;
}

extension QuestionVMMapper on Question {
  QuestionVM toVM({required String currentUserId, required bool isAdmin}) =>
    QuestionVM(
      question: this,
      isOwn: authorId == currentUserId,
      canEdit: authorId == currentUserId || isAdmin,
      canDelete: authorId == currentUserId || isAdmin,
      canSetGlobal: isAdmin,
    );
}

// Trong notifier
@override
Future<QuestionBankState> build({QuestionFilter? filter}) async {
  final userId = ref.watch(currentUserIdProvider);
  final isAdmin = ref.watch(currentUserIsAdminProvider);
  final questions = await ref.watch(questionRepositoryProvider).getQuestions(filter);
  return QuestionBankState(
    questions: questions.map((q) => q.toVM(currentUserId: userId!, isAdmin: isAdmin)).toList(),
  );
}
```

UI dùng `vm.canEdit`, `vm.isOwn` thay vì pass userId.

### 3.10 Source tracking convention

| Trigger UI | `source` value | Caller file |
|-----------|----------------|-------------|
| Teacher tạo trong builder | `QuestionSource.teacher` | `teacher_create_question_screen.dart` |
| AI generate (direct path — deprecated) | `QuestionSource.aiGenerated` | `teacher_ai_generate_question_screen.dart` |
| AI generate (staging RPC) | `QuestionSource.aiGenerated` | `staging_area_widget.dart` |
| Ghost sync (legacy import) | `'teacher'` (server stamp trong RPC) | RPC `sync_assignment_to_bank` |
| Library seed | `QuestionSource.library` | Phase 8 — không implement |
| Admin bulk import | `QuestionSource.imported` | Phase sau |

**Rule:** `source` immutable sau INSERT. KHÔNG cho UPDATE đổi source. Trigger DB phase polish:

```sql
CREATE TRIGGER trg_source_immutable BEFORE UPDATE ON questions
  FOR EACH ROW WHEN (OLD.source IS DISTINCT FROM NEW.source)
  EXECUTE FUNCTION raise_source_immutable();
```

---

## 4. UI Components & Screens

### 4.1 TeacherQuestionBankScreen

**Path:** `lib/presentation/views/assignment/teacher/teacher_question_bank_screen.dart`

**Layout:**
- AppBar: title + back + search icon
- Source chips (horizontal): `Tất cả` / `Của tôi` / `AI tạo` / `Toàn cầu`
- Filter/sort bar (clone `assignment_filter_sort_bar.dart`): search input + sort sheet + filter sheet với badge dot
- Body: `AsyncValue.when` → `ListView.builder` lazy paginated
- Item card: type badge + difficulty stars + preview 160 chars + tags chips + stats badge + 3-dot menu (Sửa/Xóa/Sao chép)
- FAB extended "Tạo câu hỏi mới"

**Edge cases:**
- Empty (mine=0): illustration + CTA tạo câu đầu tiên
- Empty (filter): "Không tìm thấy câu hỏi phù hợp"
- Error: `AssignmentErrorState` reuse với retry → `ref.invalidate(questionBankNotifierProvider)`
- Large list (>500): pagination 20/page, trigger load-more khi scroll 80% bottom

**Responsive:**
- Mobile: 1 cột list
- Tablet+: 2-3 cột grid (`DesignBreakpoints.getColumnCount(width, mobile:1, tablet:2, desktop:3)`)

### 4.2 QuestionBankDetailScreen

**Path:** `lib/presentation/views/assignment/teacher/teacher_question_bank_detail_screen.dart`

**Layout:** `DefaultTabController(length: 3)` với 3 tabs:
- **Preview**: rich content + choices (cho MC) + answer + explanation + objectives + tags + author info
- **Thống kê**: `questionStatsProvider(id)` — total_attempts, correct_rate, avg_time, last_attempted
- **Lịch sử dùng**: list assignments tham chiếu câu hỏi này, có badge "PUBLISHED/DRAFT"

**Action bar bottom:** Sao chép (fork) / Sửa (→ pushNamed teacherCreateQuestion edit mode) / Xóa (soft delete + undo snackbar 30s)

### 4.3 QuestionBankPickerBottomSheet

**Path:** `lib/widgets/question_bank/question_bank_picker_sheet.dart`

**Pattern:** Mirror `ObjectiveSelectorSheet` — `DraggableScrollableSheet(initial:0.9, min:0.5, max:0.95)`.

**Static method:**
```dart
static Future<List<Question>?> show(BuildContext context, {
  List<String>? excludeQuestionIds,  // câu đã có trong assignment hiện tại
  int maxItems = 50,                 // warning khi vượt ngưỡng
}) => showModalBottomSheet<List<Question>>(...);
```

**Components:** Handle + Header (title + counter + close) + Search input + Filter chips compact + Checkbox tile list (paginated) + Footer (Hủy + Confirm "Thêm N câu vào bài tập").

**Edge cases:**
- Kho trống: empty state + CTA tạo mới
- Tất cả câu trong assignment: info banner "Đã thêm hết"
- Select > 50: warning dialog

### 4.4 GhostQuestionsBanner

**Path:** `lib/presentation/views/assignment/teacher/widgets/ghost_questions_banner.dart`

**Hiển thị khi:** `_isDraft && report.hasGhosts && !_dismissedThisSession`

**Layout:** warning bar trên đầu list questions trong builder:
```
⚠ Phát hiện N câu hỏi chưa đồng bộ vào kho
  Đồng bộ để chỉnh sửa từ Ngân hàng câu hỏi
                          [Đồng bộ ngay] [✕]
```

**Behavior:**
- Tap "Đồng bộ ngay" → confirm dialog → modal loading + progress text → call `syncAssignmentToBank` RPC → snackbar `"Đã tạo $created mới, liên kết $linked câu trùng"` → invalidate providers
- Tap "✕" → `_dismissedThisSession = true` (state local, không persist qua reload)
- Disable button nếu `_hasUnsavedChanges == true` → tooltip "Lưu nháp trước khi đồng bộ"

### 4.5 QuestionTrashScreen (MVP-included)

**Path:** `lib/presentation/views/assignment/teacher/teacher_question_trash_screen.dart`

**Filter:** `deleted_at IS NOT NULL` (RLS hiện chặn — cần thêm policy SELECT cho own + deleted)

**Layout:** danh sách câu hỏi đã xóa với:
- Card với badge "Đã xóa $N ngày trước"
- Button "Khôi phục" (call `restoreQuestion`)
- Button "Xóa vĩnh viễn" (admin-only, hard delete qua RPC riêng — Phase 2)

**Retention:** server-side cron 30 ngày tự DELETE hard rows có `deleted_at < now() - interval '30 days'`.

### 4.6 Routing & Hub entry

```dart
// route_constants.dart
static const String teacherQuestionBank = 'teacher-question-bank';
static const String teacherQuestionBankPath = '/teacher/question-bank';
static const String teacherQuestionBankDetail = 'teacher-question-bank-detail';
static String teacherQuestionBankDetailPath(String id) => '/teacher/question-bank/$id';
static const String teacherQuestionTrash = 'teacher-question-trash';
static const String teacherQuestionTrashPath = '/teacher/question-bank/trash';
```

**⚠️ Route ordering (CLAUDE.md mục 6):** đăng ký theo thứ tự:
1. `/teacher/question-bank` (list)
2. `/teacher/question-bank/trash` (specific — TRƯỚC param)
3. `/teacher/question-bank/:questionId` (param)

**RBAC:** thêm vào `teacherRoutes` set.

**Hub entry:** `teacher_assignment_hub_screen.dart` `_buildManagementSection` — thêm row 2 với card "Kho câu hỏi" (teal theme, icon `Icons.quiz_outlined`, count từ `questionBankSummaryProvider`).

---

## 5. Integration with Existing Screens

| # | File:line | Thay đổi |
|---|-----------|----------|
| 5.1 | `teacher_create_assignment_screen.dart:2700` | `onOpenQuestionBank` → `_openQuestionBankPicker()` helper. Map `Question` → `_questions[i]` với `questionId` set, `customContent=null` |
| 5.2 | `teacher_create_assignment_screen.dart` (build) | Render `GhostQuestionsBanner` khi `_isDraft && ghostReport.hasGhosts` |
| 5.3 | `teacher_create_question_screen.dart:312` | Thêm `mode: QuestionBankMode` (bankOnly/inAssignment/edit). Set `source: QuestionSource.teacher`. Pre-check duplicate trước save. Sau save theo mode pop với result khác nhau. |
| 5.4 | `teacher_ai_generate_question_screen.dart:666` | Set `source: QuestionSource.aiGenerated`. Thêm button "Lưu hết vào kho" khi entry không có context assignment. |
| 5.5 | `staging_area_widget.dart:65-139` | Payload `toDbInsert()` thêm field `source` (`'ai_generated'` hoặc `'teacher'` tùy entry). Backend RPC migration 023 đã fix bug missing choices. |
| 5.6 | `teacher_assignment_hub_screen.dart:376` | Thêm row 2 với card "Kho câu hỏi" — see 4.6 |
| 5.7 | `create_assignment_drawer.dart:156-161` | Đổi icon `Icons.bookmarks_outlined`. Subtitle live count `"$bankCount câu trong kho của bạn"`. Thêm param `bankCount` ở constructor. |

### 5.1 chi tiết — Helper `_openQuestionBankPicker`

```dart
Future<void> _openQuestionBankPicker() async {
  final existingIds = _questions
      .map((q) => q['questionId'] as String?)
      .whereType<String>()
      .toList();
  final picked = await QuestionBankPickerSheet.show(
    context, excludeQuestionIds: existingIds,
  );
  if (picked == null || picked.isEmpty || !mounted) return;
  setState(() {
    for (final q in picked) {
      _questions.add(_mapQuestionToFormData(q));
    }
    _hasUnsavedChanges = true;
  });
}

Map<String, dynamic> _mapQuestionToFormData(Question q) => {
  'questionId': q.id,          // canonical link
  'type': q.type.dbValue,
  'text': q.content['text'] ?? '',
  'difficulty': q.difficulty,
  'tags': q.tags,
  'options': _extractOptionsFromQuestion(q),
  'explanation': q.content['explanation'] ?? '',
  'customContent': null,        // chưa override
  'source': 'bank',             // UI flag để show badge "Từ kho"
};
```

### 5.5 chi tiết — Fix BUG migration 013

Đã gộp fix vào migration 023. Payload từ `QuestionDTO.toDbInsert()` thêm `source` field:

```dart
Map<String, dynamic> toDbInsert() => {
  'type': type,
  'content': content,
  'default_points': defaultPoints,
  'difficulty': difficulty,
  'tags': tags,
  'is_global': false,           // mới (giữ is_public cho bridge)
  'source': source ?? 'teacher', // NEW
  if (choices.isNotEmpty) 'choices': choices.map((c) => c.toJson()).toList(),
};
```

---

## 6. Error Handling & Testing Strategy

### 6.1 Error Boundary

```
Supabase → PostgrestException
    ↓ rethrow (NO wrap — preserve code)
DataSource
    ↓ catch + map QuestionFailure.fromPostgrest(e) + log + Sentry conditional
Repository (QuestionRepositoryImpl)
    ↓ rethrow (transparent)
UseCase
    ↓ catch QuestionFailure → AsyncValue.error(failure)
Notifier
    ↓ state.when(error: (e, _) => SnackBar(e.userMessage))
UI
```

### 6.2 Retry Policy

| Failure | Retry | Backoff | Max attempts |
|---------|-------|---------|--------------|
| `NetworkFailure` | ✅ | exponential 500ms/1s/2s | 3 |
| `RpcLockTimeout` | ✅ | linear 1s/2s | 2 |
| `SyncFailed` (partial) | ✅ full batch | 2s | 1 |
| `PermissionDenied` | ❌ | — | — |
| `DuplicateContentDetected` | ❌ | — | — |
| `QuestionNotFound` | ❌ | — | — |
| `UnknownQuestionFailure` | ❌ | — | — |

Implementation: helper `_withRetry<T>(Future<T> Function() op, RetryPolicy policy)` ở Repository layer. KHÔNG retry ở UseCase/Notifier/UI.

### 6.3 Optimistic UI Patterns

| Operation | Strategy | Rollback |
|-----------|----------|----------|
| Create | NO optimistic — loading button | n/a |
| Update | Optimistic single-item | Revert item to snapshot + toast |
| Soft delete | Optimistic removeAt + snackbar 30s undo | Re-insert at original index + toast |
| Restore | Optimistic re-insert sorted | Remove + toast |
| Sync ghost | NO optimistic — modal blocking + progress | n/a |

### 6.4 Test Strategy

#### Unit tests (24) — `test/unit/`

**`create_question_usecase_test.dart`** (4 tests)
- creates with `source=teacher` happy path
- propagates `DuplicateContentDetected` từ repo
- AI source preserved end-to-end với `source=aiGenerated`
- defaults áp dụng đúng (difficulty=null, isGlobal=false)

**`soft_delete_question_usecase_test.dart`** (3 tests)
- success → repo.softDelete called once
- throws `PermissionDenied` khi repo 42501
- idempotent: soft-deleting deleted → `QuestionNotFound`

**`restore_question_usecase_test.dart`** (2 tests)
- success → repo.restore called
- `QuestionNotFound` khi row missing

**`detect_ghost_questions_usecase_test.dart`** (3 tests)
- 0 ghosts khi assignment empty
- N ghosts đúng count
- mixed: 3 ghost + 5 valid → returns 3

**`sync_assignment_to_bank_usecase_test.dart`** (4 tests)
- happy returns `SyncResult(created:5, linked:0)`
- dedup returns `SyncResult(created:1, linked:4)`
- `RpcLockTimeout` map đúng từ PostgrestException code 55P03
- permission denied bubbles up

**`check_duplicate_usecase_test.dart`** (3 tests)
- returns Question khi hash match
- returns null khi no match
- throws NetworkFailure on connection error

**`get_question_bank_usecase_test.dart`** (2 tests)
- passes filter combinations đúng
- defaults page=0 pageSize=20

**`question_fromJson_test.dart`** (3 tests)
- v1 (chỉ is_public) → maps to isGlobal=value
- v2 (cả is_global + is_public) → isGlobal precedence
- v2 missing content_hash → contentHash=null

#### Widget tests (18) — Robot pattern

**`question_bank_screen_test.dart`** (6 tests via `QuestionBankRobot`)
- loads happy path renders N items
- empty state shows CTA
- error state shows retry
- filter type MCQ → list updates
- search debounce 400ms then query
- pull-to-refresh triggers loadInitial

**`question_bank_picker_bottom_sheet_test.dart`** (4 tests)
- multi-select up to maxItems
- 51st tap shows warning
- confirm pops with List<Question>
- cancel pops null

**`ghost_questions_banner_test.dart`** (4 tests)
- shown when ghostCount > 0
- tap sync shows confirm dialog
- confirm triggers sync (button loading)
- dismiss hides banner session

**`question_bank_detail_screen_test.dart`** (4 tests)
- renders MCQ with choices
- renders fill_blank type
- tap edit pushes EditScreen
- delete confirm → undo snackbar (test with fake_async)

#### Integration tests (5) — `integration_test/`

- **F1 bank-first create**: builder → save → assert `questions` row exists trước `assignment_questions` row
- **F2 picker linking**: select 3 → confirm → assert all 3 `question_id IS NOT NULL`
- **F3 happy sync**: 5 ghost → sync → assert `SyncResult(created:5, linked:0)`
- **F3 dedup sync**: 2 assignment cùng content → sync cả 2 → 2nd returns `created:0, linked:1`
- **F4 published immutability**: publish → edit câu hỏi gốc → student workspace giữ snapshot cũ

#### E2E manual checklist (10) — `test/qa-checklist-question-bank.md`

- [ ] Soft delete + undo trong 30s
- [ ] Soft delete + timeout 30s + "Thùng rác" có row
- [ ] Tạo câu trùng → dialog "Câu tương tự đã tồn tại"
- [ ] AI generate → verify DB `source='ai_generated'`
- [ ] Teacher set is_global=true → RLS strip về false (test 2 account)
- [ ] Admin set is_global=true thành công
- [ ] Account B thấy câu is_global=true của A
- [ ] Slow 3G → retry 3 lần exponential → fail toast
- [ ] Publish + edit câu gốc → student workspace giữ snapshot
- [ ] Ghost banner → assignment cũ → bấm Sync → modal progress → toast result

### 6.5 Observability

**AppLogger convention** (KHÔNG dùng `print()`):

```
[QuestionBank][UC:Create] enter params.type=mcq source=teacher
[QuestionBank][UC:Create] exit qid=uuid ms=320
[QuestionBank][Repo:Create] postgrest error code=23505
[QuestionBank][Notifier:SoftDelete] optimistic remove idx=3
[QuestionBank][Notifier:SoftDelete] rollback reason=NetworkFailure
[QuestionBank][Sync] rpc_start aid=uuid
[QuestionBank][Sync] rpc_done created=5 linked=2 ms=2840
```

**Sentry whitelist:** report `Permission/Network/RpcLock/Sync/Unknown`. Skip `Duplicate/NotFound` (expected business errors).

**Performance budgets:**
- Ghost detect query: <200ms p95
- Sync 50 câu: <3s p95
- List page 20: <400ms p95

### 6.6 Migration Verification Checklist

**Pre-deploy:**
- [ ] `flutter analyze` — 0 errors
- [ ] `flutter test` — all unit + widget pass
- [ ] `flutter test integration_test/question_bank_test.dart` — F1-F4 green
- [ ] `flutter build apk --debug` succeeds
- [ ] `dart run build_runner build --delete-conflicting-outputs` clean

**DB migration sequence:**
- [ ] 020 (additive columns + bridge trigger) applied
- [ ] 021 (hash trigger + chunked backfill + dedup + UNIQUE) applied
- [ ] 022 (DROP old policies + CREATE new RLS) applied
- [ ] 023 (RPC sync + fix migration 013 bug + detect_ghost + stats guard) applied
- [ ] Supabase MCP `list_tables(['questions'])` — verify 4 columns mới
- [ ] Supabase MCP `get_advisors(type=security)` — 0 new RLS issues

**Smoke test (staging):**
- [ ] GV tạo 1 câu MC → SQL verify: `source='teacher' AND content_hash NOT NULL AND is_global=false AND deleted_at IS NULL`
- [ ] Tạo trùng → dialog `DuplicateContentDetected` hiện
- [ ] AI generate → verify `source='ai_generated'`
- [ ] Soft delete → list không thấy, "Thùng rác" có row
- [ ] Client raw `DELETE FROM questions` → 0 rows affected (RLS chặn)

**Backward compat:**
- [ ] App v1 (chưa update) tạo câu hỏi với chỉ `is_public` → bridge trigger fill `is_global` + `source='teacher'` + `content_hash` auto
- [ ] App v2 đọc row v1 → `isGlobal=false`, `source='teacher'` default, `contentHash=null` → không crash

**Rollback plan:**
- [ ] Migration revert sẵn 023 → 020 (DROP columns last)
- [ ] Feature flag `useBankFirst` default true; có thể tắt remote để rollback path legacy nếu sync RPC bug critical

---

## 7. Files Inventory

### Migration files (4 mới)
- `supabase/migrations/020_question_bank_columns.sql`
- `supabase/migrations/021_question_content_hash_unique.sql`
- `supabase/migrations/022_question_bank_rls.sql`
- `supabase/migrations/023_sync_rpc_and_choices_fix.sql`

### Domain layer (3 mới + 2 sửa)
- `lib/domain/entities/question_filter.dart` (mới)
- `lib/domain/entities/question_source.dart` (mới — enum)
- `lib/domain/failures/question_failure.dart` (mới — sealed)
- `lib/domain/entities/question.dart` (sửa — add 4 fields + bridge fromJson)
- `lib/domain/entities/create_question_params.dart` (sửa — required source)
- `lib/domain/repositories/question_repository.dart` (sửa — 4 method mới)
- `lib/domain/usecases/question_bank_usecases.dart` (sửa — 5 use case mới)

### Data layer (3 sửa)
- `lib/data/datasources/question_bank_datasource.dart` (sửa — soft delete, filter)
- `lib/data/repositories/question_repository_impl.dart` (sửa — exception mapping)
- `lib/data/models/question_dto.dart` (sửa — `source` field, `is_global`)

### Provider layer (4 mới)
- `lib/presentation/providers/question_bank_notifier.dart` (sửa — state field mutatingIds)
- `lib/presentation/providers/ghost_report_provider.dart` (mới)
- `lib/presentation/providers/question_bank_summary_provider.dart` (mới — count)
- `lib/presentation/providers/question_stats_provider.dart` (mới)

### UI layer (11 mới + 7 sửa)

**Mới:**
- `lib/presentation/views/assignment/teacher/teacher_question_bank_screen.dart`
- `lib/presentation/views/assignment/teacher/teacher_question_bank_detail_screen.dart`
- `lib/presentation/views/assignment/teacher/teacher_question_trash_screen.dart`
- `lib/presentation/views/assignment/teacher/widgets/question_bank/question_bank_card.dart`
- `lib/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart`
- `lib/presentation/views/assignment/teacher/widgets/question_bank/question_filter_sort_bar.dart`
- `lib/presentation/views/assignment/teacher/widgets/ghost_questions_banner.dart`
- `lib/widgets/question_bank/question_bank_picker_sheet.dart`
- `lib/widgets/dialogs/question_filter_bottom_sheet.dart`
- `lib/widgets/dialogs/question_sort_bottom_sheet.dart`
- `lib/widgets/dialogs/similar_question_dialog.dart`

**Sửa:**
- `lib/core/routes/route_constants.dart` (+ 4 route names)
- `lib/core/routes/app_router.dart` (đăng ký 3 routes — specific trước param)
- `lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart` (card mới)
- `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` (5.1 + 5.2)
- `lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart` (5.3 mode + duplicate)
- `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart` (5.4 source)
- `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart` (5.5 payload)
- `lib/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart` (5.7 icon + count)

### Test files (mới)
- `test/unit/usecases/create_question_usecase_test.dart`
- `test/unit/usecases/soft_delete_question_usecase_test.dart`
- `test/unit/usecases/restore_question_usecase_test.dart`
- `test/unit/usecases/detect_ghost_questions_usecase_test.dart`
- `test/unit/usecases/sync_assignment_to_bank_usecase_test.dart`
- `test/unit/usecases/check_duplicate_usecase_test.dart`
- `test/unit/usecases/get_question_bank_usecase_test.dart`
- `test/unit/entities/question_fromJson_test.dart`
- `test/widget/teacher_question_bank/question_bank_screen_test.dart` (+ robot)
- `test/widget/teacher_question_bank/question_bank_picker_test.dart` (+ robot)
- `test/widget/teacher_question_bank/ghost_banner_test.dart`
- `test/widget/teacher_question_bank/question_bank_detail_screen_test.dart`
- `integration_test/question_bank_flow_test.dart` (F1-F4)
- `test/qa-checklist-question-bank.md` (E2E manual)

**Total:** 19 file mới + 11 file sửa + 4 migration + 14 file test

---

## 8. Open Questions Resolved

| # | Question | Decision |
|---|----------|----------|
| 1 | Transition window giữ `is_public` | 2 sprint (~4 tuần) sau v2 95% adoption, DROP ở migration 030+ |
| 2 | Admin role detection | `public.is_admin(auth.uid())` — đã có sẵn, dùng 12+ chỗ |
| 3 | Soft-delete câu hỏi có submissions | Cho phép. Snapshot `assignment_variants` bảo vệ HS đang làm bài |
| 4 | `source = 'library'` | Giữ trong CHECK constraint, không implement flow (Phase 8) |
| 5 | `question_stats` khi soft-delete | Giữ stats, trigger guard `WHEN deleted_at IS NULL` |
| 6 | `QuestionTrashScreen` MVP hay defer | **MVP-include** — safety net 30 ngày retention |
| 7 | `source` field required hay default | **REQUIRED** — compile-time enforce, prevent silent drift |
| 8 | Fix BUG migration 013 | **Gộp vào migration 023** (cùng scope correctness) |
| 9 | Source cho legacy ghost | `'teacher'` (RPC stamp). `'imported'` dành cho external CSV |
| 10 | `QuestionVM` wrapper trong UI | YES — `QuestionVM { Question q; bool isOwn; bool canEdit; bool canDelete; }` compute ở notifier |

---

## 9. Dependencies & Risks

### Dependencies
- Migration 020-023 phải apply theo thứ tự đúng
- `pgcrypto` extension phải enable (lần đầu)
- `public.is_admin(uid)` helper đã tồn tại (verified migration ...:1645)
- `learning_objectives` đã dùng pattern `is_global` (consistency)

### Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Backfill content_hash trên 100k+ rows lock toàn bảng | Chunked batch 5000/iter |
| Backfill duplicate UNIQUE violation | Dedup soft-delete TRƯỚC CREATE UNIQUE |
| Race condition 2 GV cùng sync | `pg_advisory_xact_lock` trong RPC |
| App v1 vẫn write `is_public` sau migration | Bridge trigger sync 2 chiều |
| Hash function crash trên format không phải Quill | Polymorphic: handle `{ops}` / `{text}` / fallback |
| RLS leak qua policy cũ "Anyone can view public questions" | DROP rõ ràng 6 policies cũ trong migration 022 |
| BaseTableDataSource.delete fail sau RLS | Refactor datasource sang soft delete |
| Choices mất khi save_questions_to_assignment | Fix RPC migration 013 — parse choices array |

---

## 10. Glossary

- **Bank-first** — quy tắc: mọi câu hỏi phải insert vào `questions` table TRƯỚC, sau đó tham chiếu vào `assignment_questions`
- **Ghost question** — `assignment_questions` row có `question_id IS NULL AND custom_content IS NOT NULL` (câu inline cũ chưa thuộc kho)
- **Delta Override** — `assignment_questions.custom_content` không null trong khi `question_id` trỏ về Bank → GV đã sửa cho riêng assignment này, không phá Bank
- **Smart Sync** — Phương án E: Ghost detection UI banner + Atomic Batch Ingest RPC + Hash dedup T1
- **T1 Deduplication** — SHA-256 hash content sau normalize (lowercase, trim whitespace, polymorphic format)
- **Snapshot** — bản sao immutable nội dung câu hỏi tại thời điểm publish, lưu trong `assignment_variants.custom_questions` để bảo vệ HS đang làm bài
- **Transition window** — 2 sprint sau v2 ship, giữ `is_public` song song `is_global` với bridge trigger; DROP `is_public` ở migration 030+

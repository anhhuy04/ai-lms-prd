-- supabase/migrations/20260517181500_022_question_bank_rls.sql
-- Purpose: RLS rebuild for Question Bank. Replaces legacy policies (15 audited).
-- Uses public.is_admin(uid) helper. Hard DELETE blocked from client.
-- Spec: docs/superpowers/specs/2026-05-17-question-bank-design.md §2.3
-- Plan: docs/superpowers/plans/2026-05-17-question-bank.md Task 1.3

BEGIN;

-- ============================================================
-- DROP legacy policies (idempotent) — audit before run returned 15
-- ============================================================

-- questions (6 legacy + any prior qb_* attempts)
DROP POLICY IF EXISTS "Anyone can view public questions" ON public.questions;
DROP POLICY IF EXISTS "Teachers can manage own questions" ON public.questions;
DROP POLICY IF EXISTS "Teachers can view own questions" ON public.questions;
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON public.questions;
DROP POLICY IF EXISTS "Admins can manage all questions" ON public.questions;
DROP POLICY IF EXISTS "Admins can view all questions" ON public.questions;
DROP POLICY IF EXISTS qb_select ON public.questions;
DROP POLICY IF EXISTS qb_select_trash ON public.questions;
DROP POLICY IF EXISTS qb_insert ON public.questions;
DROP POLICY IF EXISTS qb_update ON public.questions;
DROP POLICY IF EXISTS qb_delete ON public.questions;

-- question_choices (6 legacy + any prior qc_* attempts)
DROP POLICY IF EXISTS "Anyone can view choices of public questions" ON public.question_choices;
DROP POLICY IF EXISTS "Teachers can manage choices of own questions" ON public.question_choices;
DROP POLICY IF EXISTS "Teachers can view choices of own questions" ON public.question_choices;
DROP POLICY IF EXISTS "Students can view choices in assigned assignments" ON public.question_choices;
DROP POLICY IF EXISTS "Admins can manage all question choices" ON public.question_choices;
DROP POLICY IF EXISTS "Admins can view all question choices" ON public.question_choices;
DROP POLICY IF EXISTS qc_select ON public.question_choices;
DROP POLICY IF EXISTS qc_insert ON public.question_choices;
DROP POLICY IF EXISTS qc_update ON public.question_choices;
DROP POLICY IF EXISTS qc_delete ON public.question_choices;

-- question_objectives (3 legacy + any prior qo_* attempts)
DROP POLICY IF EXISTS "Anyone can view objectives of public questions" ON public.question_objectives;
DROP POLICY IF EXISTS "Teachers can manage objectives of own questions" ON public.question_objectives;
DROP POLICY IF EXISTS "Admins can manage all question objectives" ON public.question_objectives;
DROP POLICY IF EXISTS qo_select ON public.question_objectives;
DROP POLICY IF EXISTS qo_modify ON public.question_objectives;

-- ============================================================
-- questions — 5 new policies
-- ============================================================

-- L1: active rows visible to owner OR everyone for global
CREATE POLICY qb_select ON public.questions FOR SELECT USING (
  deleted_at IS NULL
  AND (author_id = (select auth.uid()) OR is_global = true)
);

-- L1b: trash view — only owner sees own deleted rows
CREATE POLICY qb_select_trash ON public.questions FOR SELECT USING (
  deleted_at IS NOT NULL
  AND author_id = (select auth.uid())
);

-- L1: INSERT — author must be self; non-admin cannot set is_global=true
CREATE POLICY qb_insert ON public.questions FOR INSERT WITH CHECK (
  author_id = (select auth.uid())
  AND (
    is_global = false
    OR public.is_admin((select auth.uid()))
  )
);

-- UPDATE — owner OR admin; WITH CHECK keeps row ownership / globality consistent
CREATE POLICY qb_update ON public.questions FOR UPDATE
  USING (
    author_id = (select auth.uid())
    OR public.is_admin((select auth.uid()))
  )
  WITH CHECK (
    author_id = (select auth.uid()) OR is_global = true
  );

-- DELETE — block hard delete from client; soft delete via UPDATE deleted_at
CREATE POLICY qb_delete ON public.questions FOR DELETE USING (false);

-- ============================================================
-- question_choices — gate qua parent question (deleted_at filter = L2)
-- ============================================================

CREATE POLICY qc_select ON public.question_choices FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id
      AND q.deleted_at IS NULL
      AND (q.author_id = (select auth.uid()) OR q.is_global = true)
  )
);

CREATE POLICY qc_insert ON public.question_choices FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id AND q.author_id = (select auth.uid())
  )
);

CREATE POLICY qc_update ON public.question_choices FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id AND q.author_id = (select auth.uid())
  )
);

CREATE POLICY qc_delete ON public.question_choices FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id AND q.author_id = (select auth.uid())
  )
);

-- ============================================================
-- question_objectives — same pattern (select gate + ALL for mutations)
-- ============================================================

CREATE POLICY qo_select ON public.question_objectives FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id
      AND q.deleted_at IS NULL
      AND (q.author_id = (select auth.uid()) OR q.is_global = true)
  )
);

CREATE POLICY qo_modify ON public.question_objectives FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.questions q
    WHERE q.id = question_id AND q.author_id = (select auth.uid())
  )
);

COMMIT;

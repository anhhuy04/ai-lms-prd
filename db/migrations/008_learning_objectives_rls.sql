-- ==============================================================================
-- AI LMS - Migration 008: Learning Objectives Multi-Tenancy + RLS
-- Purpose:
--   1. Add is_global / created_by / source columns (idempotent – ADD COLUMN IF NOT EXISTS)
--   2. Enable Row Level Security on learning_objectives
--   3. Create 3 RLS policies: lo_select, lo_insert, lo_update_delete
--   4. Backfill source='ai_generated' for legacy user-owned rows
-- Wave: Audit Fix — April 2026
-- ==============================================================================

-- ─── Step 1: Add multi-tenancy columns (safe / idempotent) ──────────────────

ALTER TABLE public.learning_objectives
  ADD COLUMN IF NOT EXISTS is_global  boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS source     text NOT NULL DEFAULT 'system'
                                      CHECK (source IN ('system', 'admin', 'ai_generated', 'teacher'));

-- ─── Step 2: Enable Row Level Security ──────────────────────────────────────

ALTER TABLE public.learning_objectives ENABLE ROW LEVEL SECURITY;

-- ─── Step 3: Drop stale policies (idempotent) ───────────────────────────────

DROP POLICY IF EXISTS lo_select        ON public.learning_objectives;
DROP POLICY IF EXISTS lo_insert        ON public.learning_objectives;
DROP POLICY IF EXISTS lo_update_delete ON public.learning_objectives;

-- ─── Step 4: Create policies ────────────────────────────────────────────────

-- SELECT: global objectives OR objectives I created
CREATE POLICY lo_select ON public.learning_objectives
  FOR SELECT
  USING (
    is_global = true
    OR created_by = (SELECT auth.uid())
  );

-- INSERT: teacher inserts private (is_global=false, created_by=me)
--         admin inserts global (is_global=true)
CREATE POLICY lo_insert ON public.learning_objectives
  FOR INSERT
  WITH CHECK (
    (
      is_global = false
      AND created_by = (SELECT auth.uid())
    )
    OR
    (
      is_global = true
      AND (SELECT (auth.jwt() -> 'app_metadata' ->> 'role')) = 'admin'
    )
  );

-- UPDATE / DELETE: only owner OR admin
CREATE POLICY lo_update_delete ON public.learning_objectives
  FOR ALL
  USING (
    created_by = (SELECT auth.uid())
    OR (SELECT (auth.jwt() -> 'app_metadata' ->> 'role')) = 'admin'
  );

-- ─── Step 5: Backfill source for legacy user-owned rows (H1) ────────────────
-- Rows with created_by IS NOT NULL and is_global=false existed before Migration 008.
-- They were inserted by the AI Generate screen which already set correct intent
-- but source defaulted to 'system'. Re-classify them as 'ai_generated'.
-- Teacher-created rows will have source='teacher' from the moment of creation
-- (ObjectiveSelectorSheet sets source='teacher' explicitly).

UPDATE public.learning_objectives
  SET source = 'ai_generated'
  WHERE created_by IS NOT NULL
    AND is_global  = false
    AND source     = 'system';

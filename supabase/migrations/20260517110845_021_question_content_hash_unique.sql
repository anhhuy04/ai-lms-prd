-- supabase/migrations/20260517110845_021_question_content_hash_unique.sql
-- Purpose: T1 deduplication — install SHA-256 content hash on questions table.
-- Polymorphic hash handles Quill ops, legacy {text}, and fallback formats.
-- See: docs/superpowers/plans/2026-05-17-question-bank.md §1.2

BEGIN;

-- ============================================================
-- 1. Polymorphic hash function
-- ============================================================
CREATE OR REPLACE FUNCTION public.compute_question_hash(content jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
  raw_text text;
  normalized text;
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

-- ============================================================
-- 2. Trigger: auto-set content_hash on INSERT or UPDATE of content
-- ============================================================
CREATE OR REPLACE FUNCTION public.questions_set_content_hash()
RETURNS trigger LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
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
  FOR EACH ROW
  EXECUTE FUNCTION public.questions_set_content_hash();

-- ============================================================
-- 3. Chunked backfill — không lock toàn bảng
-- ============================================================
DO $$
DECLARE
  batch_size int := 5000;
  affected int;
BEGIN
  LOOP
    UPDATE public.questions
    SET content_hash = public.compute_question_hash(content)
    WHERE id IN (
      SELECT id FROM public.questions
      WHERE content_hash IS NULL
      LIMIT batch_size
    );
    GET DIAGNOSTICS affected = ROW_COUNT;
    EXIT WHEN affected = 0;
  END LOOP;
END $$;

-- ============================================================
-- 4. Dedup TRƯỚC UNIQUE — soft-delete bản trùng (giữ row mới nhất)
-- ============================================================
WITH dups AS (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY author_id, content_hash
           ORDER BY created_at DESC, id DESC
         ) AS rn
  FROM public.questions
  WHERE deleted_at IS NULL
    AND content_hash IS NOT NULL
)
UPDATE public.questions SET deleted_at = now()
WHERE id IN (SELECT id FROM dups WHERE rn > 1);

-- ============================================================
-- 5. UNIQUE index — chống tạo trùng tương lai
-- ============================================================
CREATE UNIQUE INDEX IF NOT EXISTS idx_questions_author_hash_unique
  ON public.questions(author_id, content_hash)
  WHERE deleted_at IS NULL AND content_hash IS NOT NULL;

-- ============================================================
-- 6. Performance index cho list query
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_questions_author_active
  ON public.questions(author_id, created_at DESC)
  WHERE deleted_at IS NULL;

COMMIT;

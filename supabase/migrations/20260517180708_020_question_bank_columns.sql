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
RETURNS trigger LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
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

-- ==============================================================================
-- Migration 007: question_stats AFTER INSERT trigger on submission_answers
-- Phase 07 - AI Analytics Pipeline (Plan 02)
-- Purpose: Auto-populate question_stats (total_attempts, correct_count, avg_score)
--          whenever a submission_answer row is inserted with a final_score.
-- ==============================================================================

-- ── Trigger function ──────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.fn_update_question_stats()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_question_id uuid;
  v_points      numeric;
  v_is_correct  boolean;
BEGIN
  -- Guard: skip ungraded essays (final_score not yet set)
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;

  -- Lookup question_id and points from assignment_questions
  SELECT aq.question_id, aq.points
    INTO v_question_id, v_points
    FROM public.assignment_questions aq
   WHERE aq.id = NEW.assignment_question_id;

  -- Guard: D-07 — skip custom/inline questions (question_id IS NULL)
  IF v_question_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Determine correctness: full points awarded = correct
  v_is_correct := (NEW.final_score = v_points);

  -- UPSERT into question_stats
  INSERT INTO public.question_stats (
    question_id,
    total_attempts,
    correct_count,
    avg_score,
    last_attempted
  )
  VALUES (
    v_question_id,
    1,
    CASE WHEN v_is_correct THEN 1 ELSE 0 END,
    NEW.final_score / NULLIF(v_points, 0),
    now()
  )
  ON CONFLICT (question_id)
  DO UPDATE SET
    total_attempts = question_stats.total_attempts + 1,
    correct_count  = question_stats.correct_count
                     + CASE WHEN v_is_correct THEN 1 ELSE 0 END,
    avg_score      = (
                       question_stats.avg_score * question_stats.total_attempts
                       + NEW.final_score / NULLIF(v_points, 0)
                     ) / (question_stats.total_attempts + 1),
    last_attempted = now();

  RETURN NEW;
END;
$$;

-- ── Trigger definition ────────────────────────────────────────────────────────
-- Name prefix trg_sa_02_ ensures alphabetical ordering after trg_sa_01_ (skill
-- mastery trigger from plan 01), so skill mastery is recorded first.
DROP TRIGGER IF EXISTS trg_sa_02_question_stats ON public.submission_answers;

CREATE TRIGGER trg_sa_02_question_stats
  AFTER INSERT ON public.submission_answers
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_update_question_stats();

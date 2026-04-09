-- ==============================================================================
-- AI LMS - Migration 007: Grade Override Recalculation AFTER UPDATE Trigger
-- Purpose: Full mastery recount when teacher overrides final_score
-- Wave: 1 — DB Foundation (7-01)
-- Decisions: D-09
-- ==============================================================================

-- ─── Function: fn_recalculate_skill_mastery ──────────────────────────────────
-- Fires AFTER UPDATE OF final_score on submission_answers.
-- Decision D-09: Full recount (NOT incremental delta) for correctness.
-- Only fires when final_score actually changed (IS DISTINCT FROM).
-- For each (student_id, objective_id) affected by this answer row:
--   1. Re-aggregate ALL submission_answers for that student+objective
--   2. UPSERT student_skill_mastery with fresh totals

CREATE OR REPLACE FUNCTION fn_recalculate_skill_mastery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only proceed when final_score actually changed
  IF OLD.final_score IS NOT DISTINCT FROM NEW.final_score THEN
    RETURN NEW;
  END IF;

  -- Full recount: re-aggregate ALL submission_answers for each
  -- (student_id, objective_id) pair affected by this changed row.
  --
  -- Step 1: Identify affected student (via work_sessions) and
  --         affected objective_ids (via assignment_questions → question_objectives).
  -- Step 2: Re-aggregate from scratch and UPSERT.
  --
  -- D-07: aq2.question_id IS NOT NULL — skip custom (ad-hoc) questions.
  -- D-08: final_score IS NOT NULL — 0 counts as attempt (already handled by IS NOT NULL).

  INSERT INTO student_skill_mastery (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  SELECT
    ws2.student_id,
    qo2.objective_id,
    COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL),
    COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL),
    CASE
      WHEN COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL) = 0 THEN 0
      ELSE COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL)::numeric
           / COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL)
    END,
    now()
  FROM submission_answers sa2
  JOIN assignment_questions aq2 ON aq2.id = sa2.assignment_question_id
  JOIN question_objectives qo2  ON qo2.question_id = aq2.question_id
  JOIN work_sessions ws2        ON ws2.id = sa2.session_id
  WHERE ws2.student_id = (
          SELECT ws3.student_id FROM work_sessions ws3 WHERE ws3.id = NEW.session_id
        )
    AND qo2.objective_id IN (
          SELECT qo4.objective_id
          FROM assignment_questions aq4
          JOIN question_objectives qo4 ON qo4.question_id = aq4.question_id
          WHERE aq4.id = NEW.assignment_question_id
        )
    AND aq2.question_id IS NOT NULL
    AND sa2.final_score IS NOT NULL
  GROUP BY ws2.student_id, qo2.objective_id
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts      = EXCLUDED.attempts,
    correct       = EXCLUDED.correct,
    mastery_level = EXCLUDED.mastery_level,
    last_updated  = now();

  RETURN NEW;
END;
$$;


-- ─── Trigger: trg_sa_update_recalc_mastery ───────────────────────────────────
-- Fires only when final_score column is updated (column-level trigger).
-- This avoids unnecessary executions when other columns (feedback, flags) change.

DROP TRIGGER IF EXISTS trg_sa_update_recalc_mastery ON submission_answers;

CREATE TRIGGER trg_sa_update_recalc_mastery
  AFTER UPDATE OF final_score ON submission_answers
  FOR EACH ROW
  EXECUTE FUNCTION fn_recalculate_skill_mastery();

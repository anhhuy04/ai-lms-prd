-- ==============================================================================
-- AI LMS - Migration 007: Grade Override Recalculation AFTER UPDATE Trigger
-- Purpose: Full mastery recount when teacher overrides final_score
-- Wave: 1 — DB Foundation (7-01)
-- Decisions: D-09
-- Updated: April 2026 — Added Path 2 for custom questions (C4 fix)
-- ==============================================================================

-- ─── Function: fn_recalculate_skill_mastery ──────────────────────────────────
-- Fires AFTER UPDATE OF final_score on submission_answers.
-- Decision D-09: Full recount (NOT incremental delta) for correctness.
-- Only fires when final_score actually changed (IS DISTINCT FROM).
-- Paths:
--   - Path 1: Linked question → question_objectives join
--   - Path 2: Custom inline question → custom_content['objective_ids'] OR
--             custom_content['learningObjectives'] (legacy fallback)

CREATE OR REPLACE FUNCTION fn_recalculate_skill_mastery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.final_score IS NOT DISTINCT FROM NEW.final_score THEN
    RETURN NEW;
  END IF;

  INSERT INTO student_skill_mastery
    (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  WITH affected_objectives AS (
    -- Path 1: linked question
    SELECT qo4.objective_id
    FROM assignment_questions aq4
    JOIN question_objectives qo4 ON qo4.question_id = aq4.question_id
    WHERE aq4.id = NEW.assignment_question_id

    UNION

    -- Path 2: custom question — objective_ids preferred, learningObjectives fallback
    SELECT obj_id::uuid AS objective_id
    FROM assignment_questions aq4,
         jsonb_array_elements_text(
           COALESCE(
             NULLIF(aq4.custom_content -> 'objective_ids',      'null'::jsonb),
             NULLIF(aq4.custom_content -> 'learningObjectives', 'null'::jsonb),
             '[]'::jsonb
           )
         ) AS obj_id
    WHERE aq4.id = NEW.assignment_question_id
      AND aq4.question_id IS NULL
      AND obj_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  )
  SELECT
    ws2.student_id,
    ao.objective_id,
    COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL),
    COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL),
    CASE
      WHEN COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL) = 0 THEN 0
      ELSE COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL)::numeric
           / COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL)
    END,
    now()
  FROM affected_objectives ao
  JOIN submission_answers sa2   ON sa2.final_score IS NOT NULL
  JOIN assignment_questions aq2 ON aq2.id = sa2.assignment_question_id
  JOIN work_sessions ws2        ON ws2.id = sa2.session_id
  WHERE ws2.student_id = (
          SELECT ws3.student_id FROM work_sessions ws3 WHERE ws3.id = NEW.session_id
        )
    AND (
      -- Path 1: linked answer shares same objective via question bank
      EXISTS (
        SELECT 1 FROM assignment_questions aq5
        JOIN question_objectives qo5 ON qo5.question_id = aq5.question_id
        WHERE aq5.id = sa2.assignment_question_id
          AND qo5.objective_id = ao.objective_id
      )
      OR
      -- Path 2: custom answer references same objective (both key variants)
      EXISTS (
        SELECT 1 FROM assignment_questions aq5
        WHERE aq5.id = sa2.assignment_question_id
          AND aq5.question_id IS NULL
          AND (
            aq5.custom_content -> 'objective_ids'      ? ao.objective_id::text
            OR
            aq5.custom_content -> 'learningObjectives' ? ao.objective_id::text
          )
      )
    )
  GROUP BY ws2.student_id, ao.objective_id
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

DROP TRIGGER IF EXISTS trg_sa_update_recalc_mastery ON submission_answers;

CREATE TRIGGER trg_sa_update_recalc_mastery
  AFTER UPDATE OF final_score ON submission_answers
  FOR EACH ROW
  EXECUTE FUNCTION fn_recalculate_skill_mastery();

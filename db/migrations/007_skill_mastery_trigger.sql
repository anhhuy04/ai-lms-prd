-- ==============================================================================
-- AI LMS - Migration 007: Skill Mastery AFTER INSERT Trigger
-- Purpose: Auto-populate student_skill_mastery when submission_answers are inserted
-- Wave: 1 — DB Foundation (7-01)
-- Decisions: D-01, D-06, D-07, D-08
-- Updated: April 2026 — Added Path 2 for custom questions (C3 fix)
-- ==============================================================================

-- ─── Function: fn_update_skill_mastery ───────────────────────────────────────
-- Fires AFTER INSERT on submission_answers.
-- Guards:
--   - D-06: Skips rows where final_score IS NULL (essay awaiting AI)
-- Paths:
--   - Path 1: Linked question (question_id IS NOT NULL) → question_objectives
--   - Path 2: Custom inline question (question_id IS NULL) → custom_content
--             Reads 'objective_ids' (preferred, Flutter >= H2) OR
--             'learningObjectives' (legacy fallback)

CREATE OR REPLACE FUNCTION fn_update_skill_mastery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- D-06: Skip essay/fill-blank rows where AI has not graded yet
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO student_skill_mastery
    (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  WITH objectives AS (
    -- Path 1: linked question → question_objectives
    SELECT qo.objective_id
    FROM assignment_questions aq
    JOIN question_objectives qo ON qo.question_id = aq.question_id
    WHERE aq.id = NEW.assignment_question_id

    UNION

    -- Path 2: custom question → custom_content
    -- Ưu tiên 'objective_ids' (Flutter >= H2), fallback 'learningObjectives' (legacy)
    SELECT obj_id::uuid AS objective_id
    FROM assignment_questions aq,
         jsonb_array_elements_text(
           COALESCE(
             NULLIF(aq.custom_content -> 'objective_ids',      'null'::jsonb),
             NULLIF(aq.custom_content -> 'learningObjectives', 'null'::jsonb),
             '[]'::jsonb
           )
         ) AS obj_id
    WHERE aq.id = NEW.assignment_question_id
      AND aq.question_id IS NULL
      AND obj_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  )
  SELECT
    ws.student_id,
    o.objective_id,
    1,
    CASE WHEN NEW.final_score = aq2.points THEN 1 ELSE 0 END,
    CASE WHEN NEW.final_score = aq2.points THEN 1.0 ELSE 0.0 END,
    now()
  FROM objectives o
  JOIN work_sessions ws         ON ws.id = NEW.session_id
  JOIN assignment_questions aq2 ON aq2.id = NEW.assignment_question_id
  WHERE o.objective_id IS NOT NULL
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts      = student_skill_mastery.attempts + 1,
    correct       = student_skill_mastery.correct +
                    CASE WHEN NEW.final_score = (
                           SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id
                         )
                         THEN 1 ELSE 0
                    END,
    mastery_level = (
                      student_skill_mastery.correct +
                      CASE WHEN NEW.final_score = (
                             SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id
                           )
                           THEN 1 ELSE 0
                      END
                    )::numeric / (student_skill_mastery.attempts + 1),
    last_updated  = now();

  RETURN NEW;
END;
$$;


-- ─── Trigger: trg_sa_01_skill_mastery ────────────────────────────────────────
-- Prefix trg_sa_01_ ensures alphabetical ordering before question_stats trigger
-- (trg_sa_02_...) so mastery is written first (Research pitfall 1).

DROP TRIGGER IF EXISTS trg_sa_01_skill_mastery ON submission_answers;

CREATE TRIGGER trg_sa_01_skill_mastery
  AFTER INSERT ON submission_answers
  FOR EACH ROW
  EXECUTE FUNCTION fn_update_skill_mastery();

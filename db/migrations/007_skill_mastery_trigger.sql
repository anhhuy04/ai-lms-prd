-- ==============================================================================
-- AI LMS - Migration 007: Skill Mastery AFTER INSERT Trigger
-- Purpose: Auto-populate student_skill_mastery when submission_answers are inserted
-- Wave: 1 — DB Foundation (7-01)
-- Decisions: D-01, D-06, D-07, D-08
-- ==============================================================================

-- ─── Function: fn_update_skill_mastery ───────────────────────────────────────
-- Fires AFTER INSERT on submission_answers.
-- Guards:
--   - D-06: Skips rows where final_score IS NULL (essay awaiting AI)
--   - D-07: Skips custom questions (assignment_questions.question_id IS NULL)
--   - D-08: final_score = 0 is NOT NULL → counts as failed attempt

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

  -- UPSERT student_skill_mastery for each learning objective linked to this question
  -- D-07: AND aq.question_id IS NOT NULL skips custom (ad-hoc) questions
  INSERT INTO student_skill_mastery (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  SELECT
    ws.student_id,
    qo.objective_id,
    1,
    CASE WHEN NEW.final_score = aq.points THEN 1 ELSE 0 END,
    CASE WHEN NEW.final_score = aq.points THEN 1.0 ELSE 0.0 END,
    now()
  FROM work_sessions ws
  JOIN assignment_questions aq ON aq.id = NEW.assignment_question_id
  JOIN question_objectives qo ON qo.question_id = aq.question_id
  WHERE ws.id = NEW.session_id
    AND aq.question_id IS NOT NULL
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

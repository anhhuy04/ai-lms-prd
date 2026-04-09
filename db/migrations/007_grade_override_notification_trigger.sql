-- Phase 7: Notify student when teacher overrides grade (D-04, D-13)
-- Applies to ALL question types (MCQ + essay) per D-04

CREATE OR REPLACE FUNCTION fn_notify_grade_override()
RETURNS TRIGGER AS $$
DECLARE
  v_student_id uuid;
  v_question_text text;
BEGIN
  -- Get student_id via submission_answers -> work_sessions
  SELECT ws.student_id INTO v_student_id
  FROM submission_answers sa
  JOIN work_sessions ws ON ws.id = sa.session_id
  WHERE sa.id = NEW.submission_answer_id;

  -- Get question text for notification body
  SELECT COALESCE(q.question_text, 'Cau hoi') INTO v_question_text
  FROM submission_answers sa
  JOIN assignment_questions aq ON aq.id = sa.assignment_question_id
  LEFT JOIN questions q ON q.id = aq.question_id
  WHERE sa.id = NEW.submission_answer_id;

  -- Truncate question text for notification
  IF length(v_question_text) > 50 THEN
    v_question_text := left(v_question_text, 47) || '...';
  END IF;

  -- Insert notification for the student
  INSERT INTO in_app_notifications (user_id, type, title, body, payload)
  VALUES (
    v_student_id,
    'grade_override',
    'Giao vien da chinh diem',
    format('"%s": %s -> %s diem', v_question_text,
           COALESCE(NEW.old_score::text, '?'), NEW.new_score::text),
    jsonb_build_object(
      'submission_answer_id', NEW.submission_answer_id,
      'old_score', NEW.old_score,
      'new_score', NEW.new_score,
      'overridden_by', NEW.overridden_by
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_grade_override_notify
  AFTER INSERT ON grade_overrides
  FOR EACH ROW
  EXECUTE FUNCTION fn_notify_grade_override();

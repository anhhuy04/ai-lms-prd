-- Batch A / Track 2: chấm hàng loạt câu giống nhau trong 1 đợt giao (distribution)
-- Học pattern từ batch_regrade_assignment: SECURITY DEFINER + guard teacher + recompute + audit grade_overrides.

-- RPC 1: lấy mọi câu trả lời của 1 assignment_question trong 1 distribution
CREATE OR REPLACE FUNCTION public.get_distribution_answers_by_question(
  p_distribution_id uuid, p_assignment_question_id uuid)
RETURNS TABLE(
  answer_id uuid, session_id uuid, student_id uuid, student_name text,
  answer jsonb, ai_score numeric, ai_confidence numeric, final_score numeric,
  ai_feedback jsonb, graded_at timestamptz, attempt integer)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_teacher uuid;
BEGIN
  -- [SECURITY] teacher phải sở hữu class của distribution
  SELECT c.teacher_id INTO v_teacher
  FROM assignment_distributions d
  JOIN classes c ON c.id = d.class_id
  WHERE d.id = p_distribution_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Distribution % not found', p_distribution_id;
  END IF;
  IF v_teacher IS NULL OR auth.uid() <> v_teacher THEN
    RAISE EXCEPTION 'Permission denied: not class owner';
  END IF;

  RETURN QUERY
  SELECT sa.id, sa.session_id, ws.student_id, p.full_name,
         sa.answer, sa.ai_score, sa.ai_confidence, sa.final_score,
         sa.ai_feedback, sa.graded_at, ws.attempt
  FROM submission_answers sa
  JOIN work_sessions ws ON ws.id = sa.session_id
  LEFT JOIN profiles p ON p.id = ws.student_id
  WHERE ws.assignment_distribution_id = p_distribution_id
    AND sa.assignment_question_id = p_assignment_question_id
  ORDER BY p.full_name NULLS LAST, ws.attempt;
END $$;

-- RPC 2: duyệt hàng loạt ai_score -> final_score (chỉ trong class GV sở hữu)
CREATE OR REPLACE FUNCTION public.batch_approve_ai_scores(
  p_answer_ids uuid[], p_graded_by uuid)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_count integer := 0;
  rec record;
  v_sessions uuid[] := ARRAY[]::uuid[];
BEGIN
  IF auth.uid() <> p_graded_by THEN
    RAISE EXCEPTION 'Permission denied';
  END IF;

  FOR rec IN
    SELECT sa.id AS sa_id, sa.session_id AS sid, sa.ai_score AS ai_score, sa.final_score AS old_score
    FROM submission_answers sa
    JOIN work_sessions ws ON ws.id = sa.session_id
    JOIN assignment_distributions d ON d.id = ws.assignment_distribution_id
    JOIN classes c ON c.id = d.class_id
    WHERE sa.id = ANY(p_answer_ids)
      AND c.teacher_id = p_graded_by
      AND sa.ai_score IS NOT NULL
  LOOP
    -- audit nếu điểm thay đổi (đồng nhất pattern batch_regrade)
    IF rec.old_score IS DISTINCT FROM rec.ai_score THEN
      INSERT INTO grade_overrides (submission_answer_id, old_score, new_score, reason, overridden_by, created_at)
      VALUES (rec.sa_id, rec.old_score, rec.ai_score, 'batch_approve: AI score approved (by question)', p_graded_by, NOW());
    END IF;

    UPDATE submission_answers
      SET final_score = rec.ai_score, graded_by = p_graded_by, graded_at = NOW(), updated_at = NOW()
      WHERE id = rec.sa_id;

    v_sessions := array_append(v_sessions, rec.sid);
    v_count := v_count + 1;
  END LOOP;

  -- recompute + maybe mark graded cho các session bị ảnh hưởng (dedup)
  FOR rec IN SELECT DISTINCT unnest(v_sessions) AS sid LOOP
    PERFORM public.recompute_submission_total(rec.sid);
    PERFORM public.maybe_mark_session_graded(rec.sid);
  END LOOP;

  RETURN v_count;
END $$;

GRANT EXECUTE ON FUNCTION public.get_distribution_answers_by_question(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.batch_approve_ai_scores(uuid[], uuid) TO authenticated;

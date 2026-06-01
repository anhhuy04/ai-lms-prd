-- Batch A / Track 2 SECURITY HARDENING (fix anon fail-open + PUBLIC/anon EXECUTE + search_path)
-- Lý do: SECURITY DEFINER chạy quyền owner nhưng auth.uid() vẫn là CALLER. Với anon, auth.uid()=NULL.
-- Guard cũ "auth.uid() <> v_teacher" => NULL => IF không raise => rò rỉ chéo lớp. Sửa: IS DISTINCT FROM + chặn NULL.
-- REVOKE PUBLIC và anon (Supabase default privileges tự cấp anon=X khi CREATE FUNCTION). Thêm SET search_path.

CREATE OR REPLACE FUNCTION public.get_distribution_answers_by_question(
  p_distribution_id uuid, p_assignment_question_id uuid)
RETURNS TABLE(
  answer_id uuid, session_id uuid, student_id uuid, student_name text,
  answer jsonb, ai_score numeric, ai_confidence numeric, final_score numeric,
  ai_feedback jsonb, graded_at timestamptz, attempt integer)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_teacher uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

  SELECT c.teacher_id INTO v_teacher
  FROM assignment_distributions d JOIN classes c ON c.id = d.class_id
  WHERE d.id = p_distribution_id;

  IF NOT FOUND THEN RAISE EXCEPTION 'Distribution % not found', p_distribution_id; END IF;
  IF v_teacher IS NULL OR auth.uid() IS DISTINCT FROM v_teacher THEN
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

CREATE OR REPLACE FUNCTION public.batch_approve_ai_scores(
  p_answer_ids uuid[], p_graded_by uuid)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_count integer := 0;
  rec record;
  v_sessions uuid[] := ARRAY[]::uuid[];
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_graded_by IS DISTINCT FROM v_uid THEN RAISE EXCEPTION 'Permission denied'; END IF;

  FOR rec IN
    SELECT sa.id AS sa_id, sa.session_id AS sid, sa.ai_score AS ai_score, sa.final_score AS old_score
    FROM submission_answers sa
    JOIN work_sessions ws ON ws.id = sa.session_id
    JOIN assignment_distributions d ON d.id = ws.assignment_distribution_id
    JOIN classes c ON c.id = d.class_id
    WHERE sa.id = ANY(p_answer_ids) AND c.teacher_id = v_uid AND sa.ai_score IS NOT NULL
  LOOP
    IF rec.old_score IS DISTINCT FROM rec.ai_score THEN
      INSERT INTO grade_overrides (submission_answer_id, old_score, new_score, reason, overridden_by, created_at)
      VALUES (rec.sa_id, rec.old_score, rec.ai_score, 'batch_approve: AI score approved (by question)', v_uid, NOW());
    END IF;
    UPDATE submission_answers
      SET final_score = rec.ai_score, graded_by = v_uid, graded_at = NOW(), updated_at = NOW()
      WHERE id = rec.sa_id;
    v_sessions := array_append(v_sessions, rec.sid);
    v_count := v_count + 1;
  END LOOP;

  FOR rec IN SELECT DISTINCT unnest(v_sessions) AS sid LOOP
    PERFORM public.recompute_submission_total(rec.sid);
    PERFORM public.maybe_mark_session_graded(rec.sid);
  END LOOP;

  RETURN v_count;
END $$;

-- H1: harden pre-existing batch_regrade_assignment (cùng lớp lỗ hổng); body giữ nguyên, chỉ siết guard + search_path
CREATE OR REPLACE FUNCTION public.batch_regrade_assignment(p_assignment_id uuid, p_graded_by uuid)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $function$
DECLARE
  v_count INTEGER := 0; rec RECORD; v_new_score NUMERIC;
  v_correct_ids JSONB; v_selected_ids JSONB; v_max_points NUMERIC; v_teacher_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  SELECT teacher_id INTO v_teacher_id FROM assignments WHERE id = p_assignment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Assignment % not found', p_assignment_id; END IF;
  IF v_teacher_id IS DISTINCT FROM auth.uid() OR p_graded_by IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Permission denied: only assignment owner can regrade';
  END IF;

  FOR rec IN
    SELECT sa.id AS sa_id, sa.assignment_question_id AS aq_id, sa.answer AS student_answer,
           sa.final_score AS old_score, aq.points AS max_points,
           aq.custom_content AS custom_content, aq.question_id AS question_id
    FROM submission_answers sa JOIN assignment_questions aq ON aq.id = sa.assignment_question_id
    WHERE aq.assignment_id = p_assignment_id
  LOOP
    v_max_points := rec.max_points;
    IF rec.custom_content IS NOT NULL AND rec.custom_content ? 'choices' THEN
      SELECT jsonb_agg(c->'id') INTO v_correct_ids
      FROM jsonb_array_elements(rec.custom_content->'choices') c
      WHERE (c->>'isCorrect')::BOOLEAN = true OR (c->>'is_correct')::BOOLEAN = true;
    ELSIF rec.question_id IS NOT NULL THEN
      SELECT jsonb_agg(qc.id) INTO v_correct_ids
      FROM question_choices qc WHERE qc.question_id = rec.question_id AND qc.is_correct = true;
    ELSE v_correct_ids := '[]'::JSONB; END IF;

    v_correct_ids := COALESCE(v_correct_ids, '[]'::JSONB);
    v_selected_ids := COALESCE(rec.student_answer->'selected_choice_ids', '[]'::JSONB);
    IF v_correct_ids = '[]'::JSONB OR v_selected_ids = '[]'::JSONB THEN v_new_score := 0;
    ELSIF v_correct_ids @> v_selected_ids AND v_selected_ids @> v_correct_ids THEN v_new_score := v_max_points;
    ELSE v_new_score := 0; END IF;

    IF v_new_score IS DISTINCT FROM rec.old_score THEN
      INSERT INTO grade_overrides (submission_answer_id, old_score, new_score, reason, overridden_by, created_at)
      VALUES (rec.sa_id, rec.old_score, v_new_score, 'batch_regrade: assignment questions updated by teacher', p_graded_by, NOW());
      UPDATE submission_answers SET final_score = v_new_score, updated_at = NOW() WHERE id = rec.sa_id;
      v_count := v_count + 1;
    END IF;
  END LOOP;

  UPDATE submissions s
  SET total_score = (SELECT COALESCE(SUM(sa2.final_score), 0) FROM submission_answers sa2 WHERE sa2.session_id = s.session_id),
      updated_at = NOW()
  WHERE s.assignment_id = p_assignment_id AND (s.is_voided IS NULL OR s.is_voided = false);
  RETURN v_count;
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.get_distribution_answers_by_question(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.batch_approve_ai_scores(uuid[], uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.batch_regrade_assignment(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_distribution_answers_by_question(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.batch_approve_ai_scores(uuid[], uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.batch_regrade_assignment(uuid, uuid) TO authenticated;

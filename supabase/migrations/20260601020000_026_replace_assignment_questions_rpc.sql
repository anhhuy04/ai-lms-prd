-- 026_replace_assignment_questions_rpc.sql
-- Bịt lỗ hổng đường saveDraft: trước đây datasource.replaceAssignmentQuestions()
-- insert THẲNG custom_content full payload (có 'type') + question_id → vi phạm
-- constraint aq_bank_linked_must_be_delta (migration 025).
--
-- RPC này gói trọn logic cũ (guard work_sessions) + chuẩn hoá qua
-- fn_normalize_aq_content cho MỌI câu, đảm bảo đúng khế ước Delta Override.
--
-- Hành vi (giữ nguyên semantics cũ):
--   * Có work_sessions → KHÔNG xoá (FK submission_answers). Update custom_content
--     + points cho câu đã tồn tại (match theo assignment_questions.id), insert câu mới.
--   * Chưa có work_sessions → delete all + insert lại toàn bộ.
-- Mỗi item: {id?, question_id?, custom_content?, points?, rubric?, order_idx}
--   - id        = assignment_questions.id (để update câu cũ; có thể NULL cho câu mới)
--   - question_id = bank link (UUID) hoặc NULL (inline)

BEGIN;

CREATE OR REPLACE FUNCTION public.replace_assignment_questions(
  p_assignment_id uuid,
  p_questions jsonb
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_uid          uuid := auth.uid();
  v_is_admin     boolean := false;
  v_owner        uuid;
  v_has_sessions boolean := false;
  v_item         jsonb;
  v_norm         jsonb;
  v_aq_id        uuid;
  v_question_id  uuid;
  v_custom       jsonb;
  v_existing     boolean;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Authz: chủ assignment hoặc admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = v_uid AND role = 'admin') INTO v_is_admin;
  SELECT teacher_id INTO v_owner FROM public.assignments WHERE id = p_assignment_id;
  IF v_owner IS NULL THEN
    RAISE EXCEPTION 'Assignment not found';
  END IF;
  IF NOT v_is_admin AND v_owner <> v_uid THEN
    RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
  END IF;

  IF jsonb_typeof(p_questions) <> 'array' THEN
    RAISE EXCEPTION 'QUESTIONS_MUST_BE_ARRAY';
  END IF;

  SELECT EXISTS(SELECT 1 FROM public.work_sessions WHERE assignment_id = p_assignment_id LIMIT 1)
    INTO v_has_sessions;

  IF v_has_sessions THEN
    -- Đã có học sinh làm → chỉ update câu hiện có + insert câu mới (KHÔNG xoá)
    FOR v_item IN SELECT value FROM jsonb_array_elements(p_questions)
    LOOP
      v_norm := public.fn_normalize_aq_content(
        nullif(v_item->>'question_id', '')::uuid, v_item->'custom_content');
      v_question_id := nullif(v_norm->>'question_id', '')::uuid;
      v_custom := CASE WHEN v_norm->'custom_content' = 'null'::jsonb THEN NULL ELSE v_norm->'custom_content' END;

      v_aq_id := nullif(v_item->>'id', '')::uuid;
      v_existing := false;
      IF v_aq_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM public.assignment_questions
                      WHERE id = v_aq_id AND assignment_id = p_assignment_id) INTO v_existing;
      END IF;

      IF v_existing THEN
        UPDATE public.assignment_questions
        SET custom_content = v_custom,
            question_id    = v_question_id,
            points         = COALESCE((v_item->>'points')::numeric, points)
        WHERE id = v_aq_id;
      ELSE
        INSERT INTO public.assignment_questions
          (assignment_id, question_id, custom_content, points, rubric, order_idx)
        VALUES (
          p_assignment_id, v_question_id, v_custom,
          COALESCE((v_item->>'points')::numeric, 1),
          v_item->'rubric',
          (v_item->>'order_idx')::int
        );
      END IF;
    END LOOP;
  ELSE
    -- Chưa có học sinh làm → replace toàn bộ an toàn
    DELETE FROM public.assignment_questions WHERE assignment_id = p_assignment_id;
    IF jsonb_array_length(p_questions) > 0 THEN
      INSERT INTO public.assignment_questions
        (assignment_id, question_id, custom_content, points, rubric, order_idx)
      SELECT
        p_assignment_id,
        nullif(norm->>'question_id', '')::uuid,
        CASE WHEN norm->'custom_content' = 'null'::jsonb THEN NULL ELSE norm->'custom_content' END,
        COALESCE((q->>'points')::numeric, 1),
        q->'rubric',
        (q->>'order_idx')::int
      FROM jsonb_array_elements(p_questions) AS q
      CROSS JOIN LATERAL public.fn_normalize_aq_content(
        nullif(q->>'question_id', '')::uuid, q->'custom_content') AS norm;
    END IF;
  END IF;
END;
$function$;

REVOKE ALL ON FUNCTION public.replace_assignment_questions(uuid, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.replace_assignment_questions(uuid, jsonb) TO authenticated;

COMMIT;

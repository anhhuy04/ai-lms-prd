-- 027_fix_deep_clone_inline.sql
-- Lỗi tiềm ẩn (phát hiện khi rà mạng lưới sau Hướng C):
-- deep_clone_assignment LUÔN set custom_content = NULL khi copy câu hỏi.
-- Với câu INLINE (question_id IS NULL), nội dung câu nằm TRỌN trong
-- custom_content → NULL hoá = clone ra câu RỖNG (read path bỏ qua → mất câu).
-- Ảnh hưởng tiềm tàng: 251 dòng inline / 19 assignments.
--
-- FIX: inline (question_id IS NULL) → copy custom_content as-is.
--      bank-linked (question_id NOT NULL) → giữ NULL (bản sao sạch, bỏ
--      override cũ — đúng chủ ý ban đầu "bản sao bắt đầu clean", và tuân
--      thủ constraint aq_bank_linked_must_be_delta).

BEGIN;

CREATE OR REPLACE FUNCTION public.deep_clone_assignment(
  p_src_assignment_id uuid,
  p_cloned_by uuid
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_src    RECORD;
  v_new_id UUID;
  v_aq     RECORD;
BEGIN
  SELECT * INTO v_src FROM public.assignments WHERE id = p_src_assignment_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assignment % not found', p_src_assignment_id;
  END IF;

  IF v_src.teacher_id != p_cloned_by OR auth.uid() != p_cloned_by THEN
    RAISE EXCEPTION 'Permission denied: only assignment owner can clone';
  END IF;

  INSERT INTO public.assignments (
    class_id, teacher_id, title, description, is_published, total_points,
    default_shuffle_questions, default_shuffle_choices, created_at, updated_at
  ) VALUES (
    v_src.class_id, p_cloned_by, v_src.title || ' (Bản sao)', v_src.description,
    false, v_src.total_points,
    v_src.default_shuffle_questions, v_src.default_shuffle_choices, NOW(), NOW()
  )
  RETURNING id INTO v_new_id;

  FOR v_aq IN
    SELECT * FROM public.assignment_questions
    WHERE assignment_id = p_src_assignment_id
    ORDER BY order_idx
  LOOP
    INSERT INTO public.assignment_questions (
      assignment_id, question_id, custom_content, points, rubric, order_idx
    ) VALUES (
      v_new_id,
      v_aq.question_id,
      -- FIX: inline câu hỏi mang nội dung trong custom_content → phải copy.
      --      bank-linked → NULL (bản sao sạch, bỏ override).
      CASE WHEN v_aq.question_id IS NULL THEN v_aq.custom_content ELSE NULL END,
      v_aq.points,
      v_aq.rubric,
      v_aq.order_idx
    );
  END LOOP;

  RETURN v_new_id;
END;
$function$;

COMMIT;

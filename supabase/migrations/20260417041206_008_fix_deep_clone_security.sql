-- =============================================================
-- FIX: deep_clone_assignment — add auth.uid() verification
-- Issue: SECURITY DEFINER function didn't verify auth.uid() = p_cloned_by,
--        allowing spoofing if another user obtained a valid teacher UUID.
-- =============================================================
CREATE OR REPLACE FUNCTION public.deep_clone_assignment(
  p_src_assignment_id UUID,
  p_cloned_by         UUID   -- teacher user id
)
RETURNS UUID AS $$
DECLARE
  v_src       RECORD;
  v_new_id    UUID;
  v_aq        RECORD;
BEGIN
  -- Lấy thông tin assignment gốc
  SELECT * INTO v_src
  FROM public.assignments
  WHERE id = p_src_assignment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assignment % not found', p_src_assignment_id;
  END IF;

  -- [SECURITY] Verify caller là teacher sở hữu assignment
  -- auth.uid() phải khớp p_cloned_by để tránh spoofing trong SECURITY DEFINER context
  IF v_src.teacher_id != p_cloned_by OR auth.uid() != p_cloned_by THEN
    RAISE EXCEPTION 'Permission denied: only assignment owner can clone';
  END IF;

  -- INSERT assignment mới
  INSERT INTO public.assignments (
    class_id,
    teacher_id,
    title,
    description,
    is_published,
    total_points,
    default_shuffle_questions,
    default_shuffle_choices,
    created_at,
    updated_at
  ) VALUES (
    v_src.class_id,
    p_cloned_by,
    v_src.title || ' (Bản sao)',
    v_src.description,
    false,         -- Bắt đầu ở trạng thái draft
    v_src.total_points,
    v_src.default_shuffle_questions,
    v_src.default_shuffle_choices,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_new_id;

  -- Copy assignment_questions sang ID mới
  -- Giữ: question_id (tham chiếu bank), points, order_idx, rubric
  -- Reset: custom_content = NULL (bản sao bắt đầu clean)
  FOR v_aq IN
    SELECT * FROM public.assignment_questions
    WHERE assignment_id = p_src_assignment_id
    ORDER BY order_idx
  LOOP
    INSERT INTO public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    ) VALUES (
      v_new_id,
      v_aq.question_id,
      NULL,             -- Bản sao không copy override cũ
      v_aq.points,
      v_aq.rubric,
      v_aq.order_idx
    );
  END LOOP;

  RETURN v_new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.deep_clone_assignment(UUID, UUID) TO authenticated;

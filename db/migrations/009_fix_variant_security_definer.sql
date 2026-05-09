-- =============================================================
-- Fix: ensure_student_variant + create_student_variant
-- Thêm SECURITY DEFINER để bypass RLS khi INSERT assignment_variants
-- Sinh viên không có INSERT policy nhưng RPC cần INSERT thay mặt họ.
-- Security guard: auth.uid() = p_student_id để tránh spoofing.
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. Viết lại create_student_variant với SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.create_student_variant(
  p_assignment_id     UUID,
  p_student_id        UUID,
  p_shuffle_questions BOOLEAN DEFAULT true,
  p_shuffle_choices   BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
  v_variant_id UUID;
  v_aq_rows    JSONB;
  v_q_ids      JSONB;
  v_shuffled_q_ids JSONB;
  v_seed       BIGINT;
  v_result     JSONB := '[]'::JSONB;
  v_aq_id      TEXT;
  v_display_order INT := 1;
  v_choices_raw JSONB;
  v_choice_ids  JSONB;
BEGIN
  -- [SECURITY] Chỉ student đang đăng nhập mới được tạo variant cho chính mình
  IF auth.uid() != p_student_id THEN
    RAISE EXCEPTION 'Permission denied: student can only create own variant';
  END IF;

  -- Seed từ student_id + assignment_id (deterministic)
  v_seed := (
    (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
    ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
  );

  -- Lấy tất cả assignment_questions (id và order_idx)
  SELECT jsonb_agg(
    jsonb_build_object('aq_id', aq.id::TEXT, 'order_idx', aq.order_idx)
    ORDER BY aq.order_idx
  ) INTO v_aq_rows
  FROM assignment_questions aq
  WHERE aq.assignment_id = p_assignment_id;

  IF v_aq_rows IS NULL OR jsonb_array_length(v_aq_rows) = 0 THEN
    RAISE EXCEPTION 'No questions found for assignment %', p_assignment_id;
  END IF;

  -- Tách ra mảng aq_ids để shuffle thứ tự câu
  SELECT jsonb_agg(elem->>'aq_id')
  INTO v_q_ids
  FROM jsonb_array_elements(v_aq_rows) elem;

  -- Shuffle thứ tự câu nếu cần
  IF p_shuffle_questions THEN
    v_shuffled_q_ids := shuffle_with_seed(v_q_ids, v_seed);
  ELSE
    v_shuffled_q_ids := v_q_ids;
  END IF;

  -- Build result: mỗi phần tử là pointer + shuffled_choices
  FOR v_display_order IN 1..jsonb_array_length(v_shuffled_q_ids)
  LOOP
    v_aq_id := v_shuffled_q_ids->>(v_display_order - 1);

    -- Lấy choice IDs từ custom_content (inline) hoặc question_choices (bank)
    SELECT
      CASE
        WHEN aq.question_id IS NULL AND aq.custom_content ? 'choices' THEN
          (SELECT jsonb_agg((c->>'id')::INT)
           FROM jsonb_array_elements(aq.custom_content->'choices') c)
        WHEN aq.question_id IS NOT NULL THEN
          (SELECT jsonb_agg(qc.id ORDER BY qc.id)
           FROM question_choices qc
           WHERE qc.question_id = aq.question_id)
        ELSE '[]'::JSONB
      END
    INTO v_choices_raw
    FROM assignment_questions aq
    WHERE aq.id = v_aq_id::UUID;

    v_choice_ids := COALESCE(v_choices_raw, '[]'::JSONB);

    -- Shuffle choices nếu cần
    IF p_shuffle_choices AND jsonb_array_length(v_choice_ids) > 1 THEN
      v_choice_ids := shuffle_with_seed(v_choice_ids, v_seed + v_display_order * 997);
    END IF;

    v_result := v_result || jsonb_build_array(
      jsonb_build_object(
        'assignment_question_id', v_aq_id,
        'display_order',          v_display_order,
        'shuffled_choices',       v_choice_ids
      )
    );
  END LOOP;

  -- Upsert: xóa variant cũ rồi insert mới
  DELETE FROM assignment_variants
  WHERE assignment_id = p_assignment_id
    AND variant_type = 'student'
    AND student_id = p_student_id;

  INSERT INTO assignment_variants (
    assignment_id, variant_type, student_id, custom_questions, created_at
  ) VALUES (
    p_assignment_id, 'student', p_student_id, v_result, NOW()
  )
  RETURNING id INTO v_variant_id;

  RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.create_student_variant(UUID, UUID, BOOLEAN, BOOLEAN) TO authenticated;


-- ─────────────────────────────────────────────────────────────
-- 2. Viết lại ensure_student_variant với SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.ensure_student_variant(
  p_assignment_id UUID,
  p_student_id    UUID
)
RETURNS UUID AS $$
DECLARE
  v_variant_id UUID;
  v_settings   JSONB;
  v_shuffle_q  BOOLEAN := false;
  v_shuffle_c  BOOLEAN := false;
BEGIN
  -- [SECURITY] Chỉ student đang đăng nhập mới được ensure variant cho chính mình
  IF auth.uid() != p_student_id THEN
    RAISE EXCEPTION 'Permission denied: student can only ensure own variant';
  END IF;

  -- Kiểm tra đã có variant chưa
  SELECT id INTO v_variant_id
  FROM assignment_variants
  WHERE assignment_id = p_assignment_id
    AND variant_type = 'student'
    AND student_id = p_student_id
  LIMIT 1;

  IF v_variant_id IS NOT NULL THEN
    RETURN v_variant_id;
  END IF;

  -- Lấy settings từ distribution
  -- Ưu tiên: individual > group > class
  -- NOTE: status check dùng 'approved' cho class, group_members không có status
  SELECT ad.settings INTO v_settings
  FROM assignment_distributions ad
  WHERE ad.assignment_id = p_assignment_id
    AND (
      (ad.distribution_type = 'individual' AND p_student_id = ANY(ad.student_ids))
      OR (ad.distribution_type = 'group' AND EXISTS (
          SELECT 1 FROM group_members gm
          WHERE gm.group_id = ad.group_id AND gm.student_id = p_student_id
      ))
      OR (ad.distribution_type = 'class' AND EXISTS (
          SELECT 1 FROM class_members cm
          WHERE cm.class_id = ad.class_id AND cm.student_id = p_student_id
            -- KHÔNG filter status: cho phép cả pending/approved để test
      ))
    )
  ORDER BY CASE ad.distribution_type
    WHEN 'individual' THEN 1 WHEN 'group' THEN 2 WHEN 'class' THEN 3
  END
  LIMIT 1;

  -- Nếu ko tìm được settings từ distribution, fallback sang assignment defaults
  IF v_settings IS NULL THEN
    SELECT jsonb_build_object(
      'shuffle_questions', a.default_shuffle_questions,
      'shuffle_choices',   a.default_shuffle_choices
    ) INTO v_settings
    FROM assignments a
    WHERE a.id = p_assignment_id;
  END IF;

  IF v_settings IS NOT NULL THEN
    v_shuffle_q := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
    v_shuffle_c := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
  END IF;

  -- Luôn tạo variant kể cả khi shuffle=false (Dumb TV / Consistency pattern)
  v_variant_id := create_student_variant(
    p_assignment_id, p_student_id, v_shuffle_q, v_shuffle_c
  );

  RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.ensure_student_variant(UUID, UUID) TO authenticated;

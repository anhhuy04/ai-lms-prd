-- =============================================================
-- Migration 008: Rewrite shuffle functions
-- Format mới của custom_questions (assignment_variants):
-- [{
--   "assignment_question_id": "uuid",
--   "display_order": 1,
--   "shuffled_choices": [2, 0, 3, 1]   -- mảng INT IDs đã đảo
-- }]
-- KHÔNG snapshot content! Frontend JOIN với assignment_questions.
-- =============================================================

-- Giữ nguyên hàm helper shuffle_with_seed (đã đúng, không đổi)
-- shuffle_with_seed đã tồn tại trong DB

-- =============================================================
-- Viết lại create_student_variant
-- =============================================================
CREATE OR REPLACE FUNCTION create_student_variant(
  p_assignment_id UUID,
  p_student_id    UUID,
  p_shuffle_questions BOOLEAN DEFAULT true,
  p_shuffle_choices   BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
  v_variant_id UUID;
  v_aq_rows    JSONB;   -- mảng {id, order_idx, choices_ids[]}
  v_q_ids      JSONB;   -- mảng UUID string để shuffle thứ tự câu
  v_shuffled_q_ids JSONB;
  v_seed       BIGINT;
  v_result     JSONB := '[]'::JSONB;
  v_elem       JSONB;
  v_aq_id      TEXT;
  v_display_order INT := 1;
  v_choices_raw JSONB;
  v_choice_ids  JSONB;
  v_c           JSONB;
BEGIN
  -- Seed từ student_id + assignment_id (deterministic)
  v_seed := (
    (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
    ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
  );

  -- Lấy tất cả assignment_questions (chỉ lấy id và order_idx, không lấy content)
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

  -- Build result array: mỗi phần tử là pointer + shuffled_choices
  FOR v_display_order IN 1..jsonb_array_length(v_shuffled_q_ids)
  LOOP
    v_aq_id := v_shuffled_q_ids->>(v_display_order - 1);

    -- Lấy choice IDs (INT) từ custom_content.choices của assignment_question này
    -- Hỗ trợ cả câu từ bank (question_choices) và câu custom (custom_content.choices)
    SELECT
      CASE
        -- Câu custom: lấy từ custom_content.choices[].id (đã là INT sau migration)
        WHEN aq.question_id IS NULL AND aq.custom_content ? 'choices' THEN
          (SELECT jsonb_agg((c->>'id')::INT)
           FROM jsonb_array_elements(aq.custom_content->'choices') c)
        -- Câu từ bank: lấy từ question_choices.id (INT)
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

    -- Append pointer vào result
    v_result := v_result || jsonb_build_array(
      jsonb_build_object(
        'assignment_question_id', v_aq_id,
        'display_order',          v_display_order,
        'shuffled_choices',       v_choice_ids
      )
    );
  END LOOP;

  -- Upsert: nếu đã có variant cũ thì replace
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
$$ LANGUAGE plpgsql;


-- =============================================================
-- Viết lại ensure_student_variant (logic giữ nguyên, gọi hàm mới)
-- =============================================================
CREATE OR REPLACE FUNCTION ensure_student_variant(
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

  -- Lấy settings từ distribution (ưu tiên individual > group > class)
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
            AND cm.status = 'approved'
      ))
    )
  ORDER BY CASE ad.distribution_type
    WHEN 'individual' THEN 1 WHEN 'group' THEN 2 WHEN 'class' THEN 3
  END
  LIMIT 1;

  IF v_settings IS NOT NULL THEN
    v_shuffle_q := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
    v_shuffle_c := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
  END IF;

  -- Luôn tạo variant kể cả khi shuffle=false (Consistency: Dumb TV pattern)
  v_variant_id := create_student_variant(
    p_assignment_id, p_student_id, v_shuffle_q, v_shuffle_c
  );

  RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql;

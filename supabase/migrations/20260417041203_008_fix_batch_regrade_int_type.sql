-- =============================================================
-- FIX: batch_regrade_assignment — correct INT type + permission check
-- Issues fixed:
--   1. c->>'id' (TEXT) → c->'id' (preserves INT) for custom_content choices
--   2. qc.id::TEXT → qc.id (keep INTEGER to match student answer format)
--   3. v_correct_ids = v_selected_ids → @> <@ (order-independent set comparison)
--   4. Added teacher ownership + auth.uid() permission check
-- =============================================================
CREATE OR REPLACE FUNCTION batch_regrade_assignment(
  p_assignment_id UUID,
  p_graded_by     UUID  -- teacher user id
)
RETURNS INTEGER AS $$
DECLARE
  v_count     INTEGER := 0;
  rec         RECORD;
  v_new_score NUMERIC;
  v_correct_ids JSONB;
  v_selected_ids JSONB;
  v_max_points NUMERIC;
  v_teacher_id UUID;
BEGIN
  -- [SECURITY] Verify caller là teacher sở hữu assignment
  SELECT teacher_id INTO v_teacher_id
  FROM assignments
  WHERE id = p_assignment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assignment % not found', p_assignment_id;
  END IF;

  IF v_teacher_id != p_graded_by OR auth.uid() != p_graded_by THEN
    RAISE EXCEPTION 'Permission denied: only assignment owner can regrade';
  END IF;

  -- Lặp qua tất cả submission_answers của assignment này
  FOR rec IN
    SELECT
      sa.id                         AS sa_id,
      sa.assignment_question_id     AS aq_id,
      sa.answer                     AS student_answer,
      sa.final_score                AS old_score,
      aq.points                     AS max_points,
      aq.custom_content             AS custom_content,
      aq.question_id                AS question_id
    FROM submission_answers sa
    JOIN assignment_questions aq ON aq.id = sa.assignment_question_id
    WHERE aq.assignment_id = p_assignment_id
  LOOP
    v_max_points := rec.max_points;

    -- Lấy correct_choice_ids mới nhất từ custom_content (delta override ưu tiên)
    -- Fallback về question_choices nếu không có override
    -- CRITICAL: Dùng -> (giữ nguyên INT type từ JSONB), KHÔNG dùng ->> (trả về TEXT)
    IF rec.custom_content IS NOT NULL AND rec.custom_content ? 'choices' THEN
      -- Lấy từ custom_content.choices (đã sửa bởi GV)
      -- c->'id' giữ nguyên INT (0,1,2...) — match với student selected_choice_ids
      SELECT jsonb_agg(c->'id')
      INTO v_correct_ids
      FROM jsonb_array_elements(rec.custom_content->'choices') c
      WHERE (c->>'isCorrect')::BOOLEAN = true
         OR (c->>'is_correct')::BOOLEAN = true;

    ELSIF rec.question_id IS NOT NULL THEN
      -- Lấy từ question bank — qc.id là INTEGER, không cast TEXT
      SELECT jsonb_agg(qc.id)
      INTO v_correct_ids
      FROM question_choices qc
      WHERE qc.question_id = rec.question_id
        AND qc.is_correct = true;
    ELSE
      v_correct_ids := '[]'::JSONB;
    END IF;

    v_correct_ids := COALESCE(v_correct_ids, '[]'::JSONB);

    -- Lấy selected_choice_ids từ student answer (lưu dạng INT array)
    v_selected_ids := COALESCE(
      rec.student_answer->'selected_choice_ids',
      '[]'::JSONB
    );

    -- Tính điểm mới: trắc nghiệm → đúng hết = full points, còn lại = 0
    -- Dùng @> và <@ thay = để so sánh không phụ thuộc thứ tự (set containment)
    IF v_correct_ids = '[]'::JSONB OR v_selected_ids = '[]'::JSONB THEN
      v_new_score := 0;
    ELSIF v_correct_ids @> v_selected_ids AND v_selected_ids @> v_correct_ids THEN
      v_new_score := v_max_points;
    ELSE
      v_new_score := 0;
    END IF;

    -- Chỉ insert grade_override nếu điểm thay đổi
    IF v_new_score IS DISTINCT FROM rec.old_score THEN
      INSERT INTO grade_overrides (
        submission_answer_id,
        old_score,
        new_score,
        reason,
        overridden_by,
        created_at
      ) VALUES (
        rec.sa_id,
        rec.old_score,
        v_new_score,
        'batch_regrade: assignment questions updated by teacher',
        p_graded_by,
        NOW()
      );

      -- Update final_score trực tiếp
      UPDATE submission_answers
      SET final_score = v_new_score,
          updated_at  = NOW()
      WHERE id = rec.sa_id;

      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION batch_regrade_assignment(UUID, UUID) TO authenticated;

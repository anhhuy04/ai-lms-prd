-- =============================================================
-- RPC: batch_regrade_assignment
-- Khi GV sửa đề/đáp án, gọi RPC này để chấm lại toàn bộ bài nộp.
-- Logic:
--   1. Lấy tất cả submission_answers cho assignment này
--   2. Với mỗi câu trắc nghiệm: so sánh selected_choice_ids với correct IDs mới
--   3. INSERT vào grade_overrides (Trigger D-01 sẽ tự update skill_mastery)
-- Returns: số bài được chấm lại
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
BEGIN
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
    IF rec.custom_content IS NOT NULL AND rec.custom_content ? 'choices' THEN
      -- Lấy từ custom_content.choices (đã sửa bởi GV)
      SELECT jsonb_agg(c->>'id')
      INTO v_correct_ids
      FROM jsonb_array_elements(rec.custom_content->'choices') c
      WHERE (c->>'isCorrect')::BOOLEAN = true
         OR (c->>'is_correct')::BOOLEAN = true;

    ELSIF rec.question_id IS NOT NULL THEN
      -- Lấy từ question bank
      SELECT jsonb_agg(qc.id::TEXT)
      INTO v_correct_ids
      FROM question_choices qc
      WHERE qc.question_id = rec.question_id
        AND qc.is_correct = true;
    ELSE
      v_correct_ids := '[]'::JSONB;
    END IF;

    v_correct_ids := COALESCE(v_correct_ids, '[]'::JSONB);

    -- Lấy selected_choice_ids từ student answer
    v_selected_ids := COALESCE(
      rec.student_answer->'selected_choice_ids',
      '[]'::JSONB
    );

    -- Tính điểm mới: trắc nghiệm → đúng hết = full points, còn lại = 0
    IF v_correct_ids = '[]'::JSONB OR v_selected_ids = '[]'::JSONB THEN
      v_new_score := 0;
    ELSIF v_correct_ids = v_selected_ids THEN
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

-- Grant execute cho authenticated users (GV sẽ gọi)
GRANT EXECUTE ON FUNCTION batch_regrade_assignment(UUID, UUID) TO authenticated;

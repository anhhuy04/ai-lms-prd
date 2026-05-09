-- Migration 014: Fix save_questions_to_assignment — lưu choices vào question_choices
-- Bug: RPC trước chỉ INSERT vào questions, bỏ qua question_choices hoàn toàn.
-- Kết quả: MCQ/TF questions saved từ staging area không có đáp án trong DB.

CREATE OR REPLACE FUNCTION public.save_questions_to_assignment(
  p_questions     JSONB,        -- array of QuestionDTO objects (with choices)
  p_assignment_id UUID          -- target assignment (NULL → save to bank only)
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_question     JSONB;
  v_question_id  UUID;
  v_question_ids UUID[] := '{}';
  v_order_idx    INT := 0;
  v_result       JSONB;
BEGIN
  FOR v_question IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
    -- 1. Insert vào questions
    INSERT INTO public.questions (
      author_id,
      type,
      content,
      answer,
      default_points,
      difficulty,
      tags,
      is_public
    )
    VALUES (
      (SELECT auth.uid()),
      (v_question->>'type'),
      (v_question->'content'),
      (v_question->'answer'),
      COALESCE((v_question->>'default_points')::NUMERIC, 1),
      COALESCE((v_question->>'difficulty')::INT, 3),
      COALESCE(
        ARRAY(SELECT jsonb_array_elements_text(v_question->'tags')),
        ARRAY[]::text[]
      ),
      false
    )
    RETURNING id INTO v_question_id;

    v_question_ids := array_append(v_question_ids, v_question_id);

    -- 2. Insert choices vào question_choices (nếu có)
    --    Format mong đợi: choices = [{id: int, content: {text: str}, is_correct: bool}]
    IF jsonb_typeof(v_question->'choices') = 'array' THEN
      INSERT INTO public.question_choices (id, question_id, content, is_correct)
      SELECT
        (choice->>'id')::INT,
        v_question_id,
        choice->'content',
        COALESCE((choice->>'is_correct')::BOOLEAN, false)
      FROM jsonb_array_elements(v_question->'choices') AS choice;
    END IF;
  END LOOP;

  -- 3. Link questions vào assignment (nếu có)
  IF p_assignment_id IS NOT NULL THEN
    FOREACH v_question_id IN ARRAY v_question_ids
    LOOP
      INSERT INTO public.assignment_questions (
        assignment_id,
        question_id,
        points,
        order_idx
      )
      VALUES (
        p_assignment_id,
        v_question_id,
        1,
        v_order_idx
      );
      v_order_idx := v_order_idx + 1;
    END LOOP;
  END IF;

  v_result := jsonb_build_object(
    'saved_count', array_length(v_question_ids, 1),
    'question_ids', to_jsonb(v_question_ids),
    'added_to_assignment', p_assignment_id IS NOT NULL
  );

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.save_questions_to_assignment(JSONB, UUID) TO authenticated;

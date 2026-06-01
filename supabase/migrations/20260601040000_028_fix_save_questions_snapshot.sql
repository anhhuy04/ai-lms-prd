-- 028_fix_save_questions_snapshot.sql
-- Lỗi tiềm ẩn (rà mạng lưới sau Hướng C):
-- save_questions_to_assignment(p_questions, p_assignment_id) khi p_assignment_id
-- KHÔNG NULL → tạo question is_global=false (private) rồi link vào
-- assignment_questions với custom_content = NULL (S1).
-- Nhưng câu private → RLS chặn học sinh đọc bank → học sinh thấy CÂU TRẮNG.
-- (Cùng class lỗi với 112 dòng đã xử lý ở Hướng C, nhưng ở đường AI-generate
--  "Lưu & thêm vào đề".)
--
-- FIX: khi link vào assignment, set custom_content = full snapshot (S3 inline,
-- question_id NULL) thay vì link tới bank private. Bank vẫn được tạo (để GV
-- reuse trong thư viện cá nhân), nhưng assignment_questions tự chứa nội dung
-- → học sinh đọc được + tuân thủ khế ước (qid NULL → full payload hợp lệ).

BEGIN;

CREATE OR REPLACE FUNCTION public.save_questions_to_assignment(
  p_questions     jsonb,
  p_assignment_id uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
  v_caller       uuid := (select auth.uid());
  v_q            jsonb;
  v_qid          uuid;
  v_qids         uuid[] := ARRAY[]::uuid[];
  v_hash         text;
  v_choice       jsonb;
  v_choice_idx   int;
  v_choice_content jsonb;
  v_type         text;
  v_order_idx    int := 0;
  v_inserted     int := 0;
  v_snapshot     jsonb;
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;

  FOR v_q IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
    v_type := COALESCE(v_q->>'type', 'short_answer');
    v_hash := public.compute_question_hash(v_q->'content');
    v_qid  := NULL;

    INSERT INTO public.questions(
      author_id, type, content, answer,
      default_points, difficulty, tags,
      source, is_global, is_public
    )
    VALUES (
      v_caller, v_type, v_q->'content', v_q->'answer',
      COALESCE((v_q->>'default_points')::numeric, 1.0),
      COALESCE((v_q->>'difficulty')::int, 3),
      COALESCE(ARRAY(SELECT jsonb_array_elements_text(v_q->'tags')), ARRAY[]::text[]),
      COALESCE(v_q->>'source', 'teacher'),
      false, false
    )
    ON CONFLICT (author_id, content_hash)
      WHERE deleted_at IS NULL AND content_hash IS NOT NULL
    DO NOTHING
    RETURNING id INTO v_qid;

    IF v_qid IS NULL THEN
      SELECT id INTO v_qid FROM public.questions
      WHERE author_id = v_caller AND content_hash = v_hash AND deleted_at IS NULL
      LIMIT 1;
    END IF;

    -- Mirror choices vào question_choices (cho bank reuse)
    IF v_type IN ('multiple_choice', 'true_false', 'multiple_select')
       AND jsonb_typeof(v_q->'choices') = 'array' THEN
      DELETE FROM public.question_choices WHERE question_id = v_qid;
      v_choice_idx := 0;
      FOR v_choice IN SELECT * FROM jsonb_array_elements(v_q->'choices')
      LOOP
        IF v_choice ? 'content' THEN
          v_choice_content := v_choice->'content';
        ELSE
          v_choice_content := jsonb_build_object('text', COALESCE(v_choice->>'text',''), 'image', v_choice->'image');
        END IF;
        INSERT INTO public.question_choices(id, question_id, content, is_correct)
        VALUES (v_choice_idx, v_qid, v_choice_content,
          COALESCE((v_choice->>'is_correct')::boolean, (v_choice->>'isCorrect')::boolean, false));
        v_choice_idx := v_choice_idx + 1;
      END LOOP;
    END IF;

    v_qids := array_append(v_qids, v_qid);

    IF p_assignment_id IS NOT NULL THEN
      -- FIX: bank vừa tạo là PRIVATE (is_global=false) → học sinh không đọc được.
      -- KHÔNG link question_id; thay vào đó SNAPSHOT nội dung vào custom_content
      -- (S3 inline) để học sinh đọc được + tuân thủ khế ước Delta Override.
      v_snapshot := jsonb_strip_nulls(
        jsonb_build_object(
          'type', v_type,
          'override_text', COALESCE(v_q->'content'->>'text', v_q->'content'->>'override_text'),
          'choices', v_q->'choices',
          'expected_answer', v_q->'answer'->>'expected_answer',
          'ai_grading_keywords', v_q->'answer'->'ai_grading_keywords',
          'blanks', v_q->'answer'->'blanks',
          'general_explanation', v_q->'content'->>'explanation'
        )
      );

      INSERT INTO public.assignment_questions(
        assignment_id, question_id, custom_content, points, order_idx
      )
      VALUES (
        p_assignment_id,
        NULL,                 -- inline (private bank không link được)
        v_snapshot,
        COALESCE((v_q->>'default_points')::numeric, 1.0),
        v_order_idx
      );
      v_order_idx := v_order_idx + 1;
    END IF;

    v_inserted := v_inserted + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'saved_count', v_inserted,
    'question_ids', to_jsonb(v_qids),
    'added_to_assignment', p_assignment_id IS NOT NULL
  );
END $$;

REVOKE ALL ON FUNCTION public.save_questions_to_assignment(jsonb, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_questions_to_assignment(jsonb, uuid) TO authenticated;

COMMIT;

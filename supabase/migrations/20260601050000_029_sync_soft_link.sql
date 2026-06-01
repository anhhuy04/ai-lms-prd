-- 029_sync_soft_link.sql
-- Lỗi tiềm ẩn (rà mạng lưới): sync_assignment_to_bank (Smart Sync) chạy
--   UPDATE assignment_questions SET question_id = v_new  (giữ custom_content full)
-- → question_id NOT NULL + custom_content có 'type' → VI PHẠM constraint
--   aq_bank_linked_must_be_delta (migration 025) → RPC CRASH (đã probe xác nhận).
--
-- Mâu thuẫn gốc: bank tạo ra là PRIVATE (is_global=false). Nếu hard-link
-- question_id, RLS chặn học sinh đọc bank → câu trắng (chính lỗi Hướng C né).
--
-- FIX (soft-link): vẫn tạo bản bank private cho GV reuse trong thư viện cá nhân,
-- nhưng KHÔNG set assignment_questions.question_id. Thay vào đó ghi cờ
-- custom_content.synced_to_bank_id = <uuid bank>.
-- detect_ghost_questions: loại trừ dòng đã có synced_to_bank_id khỏi "ghost".

BEGIN;

CREATE OR REPLACE FUNCTION public.sync_assignment_to_bank(p_assignment_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $function$
DECLARE
  v_caller     uuid := (select auth.uid());
  v_teacher    uuid;
  v_ghost      record;
  v_hash       text;
  v_existing   uuid;
  v_new        uuid;
  v_type       text;
  v_choice     jsonb;
  v_choice_content jsonb;
  v_choice_idx int;
  v_created    int := 0;
  v_linked     int := 0;
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('sync_assignment:' || p_assignment_id::text));

  SELECT teacher_id INTO v_teacher FROM public.assignments WHERE id = p_assignment_id;
  IF v_teacher IS NULL THEN
    RAISE EXCEPTION 'Assignment not found' USING ERRCODE='P0002';
  END IF;
  IF v_teacher <> v_caller THEN
    RAISE EXCEPTION 'Permission denied' USING ERRCODE='42501';
  END IF;

  FOR v_ghost IN
    SELECT id, custom_content, points, rubric, order_idx
    FROM public.assignment_questions
    WHERE assignment_id = p_assignment_id
      AND question_id IS NULL
      AND custom_content IS NOT NULL
      AND NOT (custom_content ? 'synced_to_bank_id')
    ORDER BY order_idx
    FOR UPDATE
  LOOP
    v_type := COALESCE(v_ghost.custom_content->>'type', 'short_answer');
    v_hash := public.compute_question_hash(v_ghost.custom_content);
    v_new  := NULL;

    INSERT INTO public.questions(
      author_id, type, content, answer, default_points, source, is_global, is_public
    )
    VALUES (
      v_caller, v_type, v_ghost.custom_content, v_ghost.custom_content->'answer',
      COALESCE(v_ghost.points, 1.0), 'teacher', false, false
    )
    ON CONFLICT (author_id, content_hash)
      WHERE deleted_at IS NULL AND content_hash IS NOT NULL
    DO NOTHING
    RETURNING id INTO v_new;

    IF v_new IS NULL THEN
      SELECT id INTO v_existing FROM public.questions
      WHERE author_id = v_caller AND content_hash = v_hash AND deleted_at IS NULL
      LIMIT 1;
      v_new := v_existing;
      v_linked := v_linked + 1;
    ELSE
      v_created := v_created + 1;

      IF v_type IN ('multiple_choice', 'true_false', 'multiple_select')
         AND jsonb_typeof(v_ghost.custom_content->'choices') = 'array' THEN
        v_choice_idx := 0;
        FOR v_choice IN SELECT * FROM jsonb_array_elements(v_ghost.custom_content->'choices')
        LOOP
          IF v_choice ? 'content' THEN
            v_choice_content := v_choice->'content';
          ELSE
            v_choice_content := jsonb_build_object('text', COALESCE(v_choice->>'text',''), 'image', v_choice->'image');
          END IF;
          INSERT INTO public.question_choices(id, question_id, content, is_correct)
          VALUES (v_choice_idx, v_new, v_choice_content,
            COALESCE((v_choice->>'is_correct')::boolean, (v_choice->>'isCorrect')::boolean, false));
          v_choice_idx := v_choice_idx + 1;
        END LOOP;
      END IF;
    END IF;

    -- SOFT-LINK: KHÔNG set question_id (RLS private chặn học sinh). Đánh dấu đã sync.
    UPDATE public.assignment_questions
    SET custom_content = custom_content || jsonb_build_object('synced_to_bank_id', v_new)
    WHERE id = v_ghost.id;
  END LOOP;

  RETURN jsonb_build_object('created', v_created, 'linked', v_linked, 'total', v_created + v_linked);
END;
$function$;

REVOKE ALL ON FUNCTION public.sync_assignment_to_bank(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_assignment_to_bank(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.detect_ghost_questions(p_assignment_id uuid)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT jsonb_build_object(
    'ghost_count', COUNT(*) FILTER (
      WHERE question_id IS NULL AND custom_content IS NOT NULL
        AND NOT (custom_content ? 'synced_to_bank_id')
    ),
    'total_count', COUNT(*)
  )
  FROM public.assignment_questions
  WHERE assignment_id = p_assignment_id;
$$;

REVOKE ALL ON FUNCTION public.detect_ghost_questions(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.detect_ghost_questions(uuid) TO authenticated;

COMMIT;

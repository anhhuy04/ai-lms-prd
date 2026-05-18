-- supabase/migrations/20260517182336_023_sync_rpc_and_choices_fix.sql
-- Purpose: Smart Sync RPC (Phương án E) + fix migration 013 bug (choices skipped).
-- See: docs/superpowers/plans/2026-05-17-question-bank.md §1.4
--
-- Schema adaptations from plan §1.4:
--   * question_choices PK is (id INT, question_id UUID) — there is no `order_idx`
--     column and `id` has no sequence/default. Each choice id is the per-question
--     ordinal (0,1,2,...) supplied by the caller. We adapt by using the loop
--     index as the `id` value (matches migration 014 pattern).
--   * Existing question_choices.content rows store either a string (legacy) or
--     {text, image?} jsonb object. Ghost custom_content.choices store
--     {id, text, isCorrect} (camelCase). When syncing we normalize to
--     {text, image} to stay consistent with current writers.
--   * Migration 013/014's CREATE OR REPLACE here preserves existing GRANT to
--     authenticated; no extra GRANT statement needed.

BEGIN;

-- ============================================================
-- 1. Fix BUG migration 013/014: save_questions_to_assignment
--    * Adds source/is_global columns (migration 020)
--    * Uses ON CONFLICT (author_id, content_hash) dedup
--    * Always parses choices for multiple_choice + true_false types
-- ============================================================
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
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;

  FOR v_q IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
    v_type := COALESCE(v_q->>'type', 'short_answer');
    v_hash := public.compute_question_hash(v_q->'content');
    v_qid  := NULL;

    -- Try insert; if (author_id, content_hash) already exists, link to existing
    INSERT INTO public.questions(
      author_id, type, content, answer,
      default_points, difficulty, tags,
      source, is_global, is_public
    )
    VALUES (
      v_caller,
      v_type,
      v_q->'content',
      v_q->'answer',
      COALESCE((v_q->>'default_points')::numeric, 1.0),
      COALESCE((v_q->>'difficulty')::int, 3),
      COALESCE(
        ARRAY(SELECT jsonb_array_elements_text(v_q->'tags')),
        ARRAY[]::text[]
      ),
      COALESCE(v_q->>'source', 'teacher'),
      false,
      false
    )
    ON CONFLICT (author_id, content_hash)
      WHERE deleted_at IS NULL AND content_hash IS NOT NULL
    DO NOTHING
    RETURNING id INTO v_qid;

    -- If dedup hit, find the existing question
    IF v_qid IS NULL THEN
      SELECT id INTO v_qid FROM public.questions
      WHERE author_id = v_caller
        AND content_hash = v_hash
        AND deleted_at IS NULL
      LIMIT 1;
    END IF;

    -- Parse choices for choice-style questions (FIX original migration 013 bug)
    IF v_type IN ('multiple_choice', 'true_false', 'multiple_select')
       AND jsonb_typeof(v_q->'choices') = 'array' THEN
      DELETE FROM public.question_choices WHERE question_id = v_qid;
      v_choice_idx := 0;
      FOR v_choice IN SELECT * FROM jsonb_array_elements(v_q->'choices')
      LOOP
        -- Accept either {content: {...}, is_correct} (legacy DTO)
        -- or flat {text, isCorrect} / {text, is_correct} (current writer)
        IF v_choice ? 'content' THEN
          v_choice_content := v_choice->'content';
        ELSE
          v_choice_content := jsonb_build_object(
            'text',  COALESCE(v_choice->>'text', ''),
            'image', v_choice->'image'
          );
        END IF;

        INSERT INTO public.question_choices(id, question_id, content, is_correct)
        VALUES (
          v_choice_idx,
          v_qid,
          v_choice_content,
          COALESCE(
            (v_choice->>'is_correct')::boolean,
            (v_choice->>'isCorrect')::boolean,
            false
          )
        );
        v_choice_idx := v_choice_idx + 1;
      END LOOP;
    END IF;

    v_qids := array_append(v_qids, v_qid);

    IF p_assignment_id IS NOT NULL THEN
      INSERT INTO public.assignment_questions(
        assignment_id, question_id, points, order_idx
      )
      VALUES (
        p_assignment_id,
        v_qid,
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

-- Tighten grants inherited from migration 013/014 (anon/PUBLIC had EXECUTE).
REVOKE ALL ON FUNCTION public.save_questions_to_assignment(jsonb, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_questions_to_assignment(jsonb, uuid) TO authenticated;

-- ============================================================
-- 2. RPC sync_assignment_to_bank (Phương án E — Smart Sync)
--    Converts ghost assignment_questions (question_id IS NULL,
--    custom_content IS NOT NULL) into real bank entries owned by the teacher.
--    Uses pg_advisory_xact_lock to serialize concurrent syncs on the same
--    assignment.
-- ============================================================
CREATE OR REPLACE FUNCTION public.sync_assignment_to_bank(p_assignment_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
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

  -- Serialize per-assignment to prevent race on dedup window
  PERFORM pg_advisory_xact_lock(
    hashtext('sync_assignment:' || p_assignment_id::text)
  );

  SELECT teacher_id INTO v_teacher
  FROM public.assignments WHERE id = p_assignment_id;

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
    ORDER BY order_idx
    FOR UPDATE
  LOOP
    v_type := COALESCE(v_ghost.custom_content->>'type', 'short_answer');
    v_hash := public.compute_question_hash(v_ghost.custom_content);
    v_new  := NULL;

    INSERT INTO public.questions(
      author_id, type, content, answer,
      default_points, source, is_global, is_public
    )
    VALUES (
      v_caller,
      v_type,
      v_ghost.custom_content,
      v_ghost.custom_content->'answer',
      COALESCE(v_ghost.points, 1.0),
      'teacher',
      false,
      false
    )
    ON CONFLICT (author_id, content_hash)
      WHERE deleted_at IS NULL AND content_hash IS NOT NULL
    DO NOTHING
    RETURNING id INTO v_new;

    IF v_new IS NULL THEN
      -- Dedup hit: link to existing question
      SELECT id INTO v_existing FROM public.questions
      WHERE author_id = v_caller
        AND content_hash = v_hash
        AND deleted_at IS NULL
      LIMIT 1;
      v_new := v_existing;
      v_linked := v_linked + 1;
    ELSE
      v_created := v_created + 1;

      -- Mirror choices into question_choices for choice-style types
      IF v_type IN ('multiple_choice', 'true_false', 'multiple_select')
         AND jsonb_typeof(v_ghost.custom_content->'choices') = 'array' THEN
        v_choice_idx := 0;
        FOR v_choice IN
          SELECT * FROM jsonb_array_elements(v_ghost.custom_content->'choices')
        LOOP
          IF v_choice ? 'content' THEN
            v_choice_content := v_choice->'content';
          ELSE
            v_choice_content := jsonb_build_object(
              'text',  COALESCE(v_choice->>'text', ''),
              'image', v_choice->'image'
            );
          END IF;

          INSERT INTO public.question_choices(
            id, question_id, content, is_correct
          )
          VALUES (
            v_choice_idx,
            v_new,
            v_choice_content,
            COALESCE(
              (v_choice->>'is_correct')::boolean,
              (v_choice->>'isCorrect')::boolean,
              false
            )
          );
          v_choice_idx := v_choice_idx + 1;
        END LOOP;
      END IF;
    END IF;

    UPDATE public.assignment_questions
    SET question_id = v_new
    WHERE id = v_ghost.id;
  END LOOP;

  RETURN jsonb_build_object(
    'created', v_created,
    'linked',  v_linked,
    'total',   v_created + v_linked
  );
END $$;

REVOKE ALL ON FUNCTION public.sync_assignment_to_bank(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_assignment_to_bank(uuid) TO authenticated;

-- ============================================================
-- 3. Helper RPC: detect ghost questions (lightweight banner)
-- ============================================================
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
    ),
    'total_count', COUNT(*)
  )
  FROM public.assignment_questions
  WHERE assignment_id = p_assignment_id;
$$;

REVOKE ALL ON FUNCTION public.detect_ghost_questions(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.detect_ghost_questions(uuid) TO authenticated;

COMMIT;

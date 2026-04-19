-- Migration 013: teacher-documents Storage bucket RLS + save_questions_to_assignment RPC
-- Phase 9: AI Settings Refactor & Document Import

-- ============================================================
-- Storage bucket: teacher-documents (private)
-- ============================================================
-- NOTE: Storage bucket creation must be done via Supabase Dashboard or Management API.
-- This migration covers RLS policies only (SQL-applicable portion).
-- Bucket name: 'teacher-documents'
-- Public: false (private bucket)
-- File size limit: 10MB
-- Allowed MIME types: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,
--                     application/vnd.openxmlformats-officedocument.wordprocessingml.document

-- Storage RLS: teacher can upload to their own folder
-- Path pattern: teachers/{teacher_id}/{filename}
-- Drop existing policies first (idempotent safeguard)
DROP POLICY IF EXISTS "teacher_upload_own_files" ON storage.objects;
DROP POLICY IF EXISTS "teacher_read_own_files" ON storage.objects;
DROP POLICY IF EXISTS "teacher_delete_own_files" ON storage.objects;

CREATE POLICY "teacher_upload_own_files"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'teacher-documents'
    AND (storage.foldername(name))[1] = 'teachers'
    AND (storage.foldername(name))[2] = (SELECT auth.uid())::text
  );

CREATE POLICY "teacher_read_own_files"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'teacher-documents'
    AND (storage.foldername(name))[1] = 'teachers'
    AND (storage.foldername(name))[2] = (SELECT auth.uid())::text
  );

CREATE POLICY "teacher_delete_own_files"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'teacher-documents'
    AND (storage.foldername(name))[1] = 'teachers'
    AND (storage.foldername(name))[2] = (SELECT auth.uid())::text
  );

-- ============================================================
-- save_questions_to_assignment RPC (D-27, D-28)
-- Atomic DB transaction: INSERT questions → INSERT assignment_questions
-- Bug fixes applied:
--   - difficulty: use INT cast with default 3 (not string 'medium') — questions.difficulty is integer
--   - tags: use ARRAY(SELECT jsonb_array_elements_text(...)) — questions.tags is text[]
-- ============================================================
CREATE OR REPLACE FUNCTION public.save_questions_to_assignment(
  p_questions     JSONB,        -- array of QuestionDTO objects
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
  -- Insert each question into questions table
  FOR v_question IN SELECT * FROM jsonb_array_elements(p_questions)
  LOOP
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
      COALESCE((v_question->>'difficulty')::INT, 3),   -- INT default 3 = medium (NOT string 'medium')
      COALESCE(
        ARRAY(SELECT jsonb_array_elements_text(v_question->'tags')),
        ARRAY[]::text[]
      ),                                               -- text[] (NOT jsonb)
      false
    )
    RETURNING id INTO v_question_id;

    v_question_ids := array_append(v_question_ids, v_question_id);
  END LOOP;

  -- If assignment_id provided, link questions to assignment
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
        1,  -- default points, teacher can edit later
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

-- Grant execute to authenticated users (teacher calls this from Flutter)
GRANT EXECUTE ON FUNCTION public.save_questions_to_assignment(JSONB, UUID) TO authenticated;

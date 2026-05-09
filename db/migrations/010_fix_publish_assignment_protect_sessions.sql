-- Migration 010: Fix publish_assignment RPC để bảo vệ data khi đã có work_sessions
-- Bug cũ: DELETE assignment_questions/distributions vô điều kiện → FK violation
--         khi submission_answers hoặc work_sessions đang tham chiếu đến chúng.
--
-- Fix:
--   1. Khi has_sessions = true → KHÔNG xóa questions hoặc distributions.
--   2. Khi p_distributions rỗng → KHÔNG xóa distributions (giữ nguyên).

CREATE OR REPLACE FUNCTION public.publish_assignment(
  p_assignment jsonb,
  p_questions jsonb DEFAULT '[]'::jsonb,
  p_distributions jsonb DEFAULT '[]'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_is_admin boolean := false;
  v_teacher_id uuid;
  v_assignment_id uuid;
  v_assignment_row public.assignments%rowtype;
  v_class_id uuid;
  v_has_sessions boolean := false;
BEGIN
  -- Auth
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = v_uid AND role = 'admin'
  ) INTO v_is_admin;

  IF v_is_admin THEN
    v_teacher_id := COALESCE((p_assignment->>'teacher_id')::uuid, v_uid);
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = v_uid AND role = 'teacher'
    ) THEN
      RAISE EXCEPTION 'Forbidden: only teachers can publish assignments';
    END IF;
    v_teacher_id := v_uid;
  END IF;

  v_class_id := (p_assignment->>'class_id')::uuid;
  IF v_class_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.classes c
      WHERE c.id = v_class_id
        AND (v_is_admin OR c.teacher_id = v_teacher_id)
    ) THEN
      RAISE EXCEPTION 'Forbidden: class not owned by teacher';
    END IF;
  END IF;

  -- Upsert assignment metadata
  v_assignment_id := (p_assignment->>'id')::uuid;
  IF v_assignment_id IS NOT NULL THEN
    IF NOT v_is_admin AND NOT EXISTS (
      SELECT 1 FROM public.assignments a
      WHERE a.id = v_assignment_id AND a.teacher_id = v_teacher_id
    ) THEN
      RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
    END IF;

    UPDATE public.assignments
    SET
      class_id = v_class_id,
      title = COALESCE(p_assignment->>'title', title),
      description = p_assignment->>'description',
      total_points = (p_assignment->>'total_points')::numeric,
      is_published = TRUE,
      published_at = now()
    WHERE id = v_assignment_id
    RETURNING * INTO v_assignment_row;
  ELSE
    INSERT INTO public.assignments (
      class_id,
      teacher_id,
      title,
      description,
      is_published,
      published_at,
      total_points
    ) VALUES (
      v_class_id,
      v_teacher_id,
      COALESCE(p_assignment->>'title', 'Bài tập mới'),
      p_assignment->>'description',
      TRUE,
      now(),
      (p_assignment->>'total_points')::numeric
    )
    RETURNING * INTO v_assignment_row;

    v_assignment_id := v_assignment_row.id;
  END IF;

  -- Kiểm tra có học sinh đã làm bài chưa (work_sessions tồn tại)
  -- Nếu có → KHÔNG xóa questions/distributions (FK violation: submission_answers, work_sessions)
  SELECT EXISTS(
    SELECT 1 FROM public.work_sessions
    WHERE assignment_id = v_assignment_id
    LIMIT 1
  ) INTO v_has_sessions;

  -- Replace assignment_questions
  IF NOT v_has_sessions THEN
    -- Chưa có học sinh làm bài → replace toàn bộ an toàn
    DELETE FROM public.assignment_questions WHERE assignment_id = v_assignment_id;
    IF jsonb_typeof(p_questions) = 'array' AND jsonb_array_length(p_questions) > 0 THEN
      INSERT INTO public.assignment_questions (
        assignment_id,
        question_id,
        custom_content,
        points,
        rubric,
        order_idx
      )
      SELECT
        v_assignment_id,
        (q->>'question_id')::uuid,
        q->'custom_content',
        COALESCE((q->>'points')::numeric, 1),
        q->'rubric',
        (q->>'order_idx')::int
      FROM jsonb_array_elements(p_questions) AS q;
    END IF;
  END IF;
  -- has_sessions = true → giữ nguyên assignment_questions

  -- Replace assignment_distributions
  -- Chỉ replace nếu p_distributions không rỗng VÀ chưa có sessions.
  -- Nếu rỗng = màn hình tạo bài không quản lý distributions → giữ nguyên.
  -- Nếu has_sessions = true → KHÔNG xóa (work_sessions.assignment_distribution_id FK).
  IF NOT v_has_sessions AND jsonb_typeof(p_distributions) = 'array' AND jsonb_array_length(p_distributions) > 0 THEN
    DELETE FROM public.assignment_distributions WHERE assignment_id = v_assignment_id;
    INSERT INTO public.assignment_distributions (
      assignment_id,
      distribution_type,
      class_id,
      group_id,
      student_ids,
      available_from,
      due_at,
      time_limit_minutes,
      allow_late,
      late_policy
    )
    SELECT
      v_assignment_id,
      (d->>'distribution_type')::text,
      (d->>'class_id')::uuid,
      (d->>'group_id')::uuid,
      CASE
        WHEN d ? 'student_ids' AND d->'student_ids' IS NOT NULL THEN
          ARRAY(
            SELECT jsonb_array_elements_text(d->'student_ids')::uuid
          )
        ELSE NULL
      END,
      (d->>'available_from')::timestamptz,
      (d->>'due_at')::timestamptz,
      (d->>'time_limit_minutes')::int,
      COALESCE((d->>'allow_late')::boolean, TRUE),
      d->'late_policy'
    FROM jsonb_array_elements(p_distributions) AS d;
  END IF;

  SELECT * INTO v_assignment_row FROM public.assignments WHERE id = v_assignment_id;
  RETURN to_jsonb(v_assignment_row);
END;
$$;

-- Multi-lens dashboard stats cho danh sách bài tập của giáo viên.
-- Khắc phục bug: học sinh làm lại N lần → submitted_count = N (sai).
-- Sau fix:
--   participation_count  = số HS đã nộp ÍT NHẤT 1 lần (DISTINCT student_id, status != 'in_progress')
--   total_expected       = mẫu số theo distribution_type (class/group/individual)
--   pending_action_count = số HS có latest session = submitted (chưa graded) → "việc cần xử lý"
--   graded_count         = số HS có latest session = graded
--   late_count           = số HS có latest non-in_progress session submit muộn so với due_at
-- Tất cả đều DISTINCT student per distribution → 1 HS làm lại 3 lần chỉ đếm 1.
CREATE OR REPLACE FUNCTION public.get_teacher_distribution_dashboard_stats(
  p_class_id UUID DEFAULT NULL
)
RETURNS TABLE(
  distribution_id      UUID,
  participation_count  BIGINT,
  total_expected       BIGINT,
  pending_action_count BIGINT,
  graded_count         BIGINT,
  late_count           BIGINT
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
#variable_conflict use_column
DECLARE
  v_teacher_id UUID;
BEGIN
  v_teacher_id := auth.uid();
  IF v_teacher_id IS NULL THEN
    RAISE EXCEPTION 'permission_denied' USING HINT = 'Authentication required';
  END IF;

  RETURN QUERY
  WITH teacher_dists AS (
    SELECT ad.id, ad.class_id, ad.group_id, ad.student_ids,
           ad.distribution_type, ad.due_at
    FROM public.assignment_distributions ad
    JOIN public.assignments a ON a.id = ad.assignment_id
    WHERE a.teacher_id = v_teacher_id
      AND a.is_published = true
      AND (p_class_id IS NULL OR ad.class_id = p_class_id)
  ),
  expected AS (
    SELECT
      td.id AS dist_id,
      CASE td.distribution_type
        WHEN 'class' THEN (
          SELECT COUNT(*)
          FROM public.class_members cm
          WHERE cm.class_id = td.class_id AND cm.status = 'approved'
        )
        WHEN 'group' THEN (
          SELECT COUNT(*) FROM public.group_members gm WHERE gm.group_id = td.group_id
        )
        WHEN 'individual' THEN COALESCE(array_length(td.student_ids, 1), 0)
        WHEN 'student' THEN COALESCE(array_length(td.student_ids, 1), 0)
        ELSE 0
      END AS total_expected
    FROM teacher_dists td
  ),
  latest_session AS (
    SELECT DISTINCT ON (ws.student_id, ws.assignment_distribution_id)
      ws.student_id,
      ws.assignment_distribution_id AS dist_id,
      ws.status,
      ws.submitted_at
    FROM public.work_sessions ws
    JOIN teacher_dists td ON td.id = ws.assignment_distribution_id
    ORDER BY ws.student_id, ws.assignment_distribution_id, ws.attempt DESC, ws.created_at DESC
  ),
  any_completed AS (
    SELECT DISTINCT ws.student_id, ws.assignment_distribution_id AS dist_id
    FROM public.work_sessions ws
    JOIN teacher_dists td ON td.id = ws.assignment_distribution_id
    WHERE ws.status <> 'in_progress'
  )
  SELECT
    td.id AS distribution_id,
    COALESCE((SELECT COUNT(*) FROM any_completed ac WHERE ac.dist_id = td.id), 0)::BIGINT AS participation_count,
    COALESCE((SELECT total_expected FROM expected e WHERE e.dist_id = td.id), 0)::BIGINT AS total_expected,
    COALESCE((SELECT COUNT(*) FROM latest_session ls
              WHERE ls.dist_id = td.id
                AND ls.submitted_at IS NOT NULL
                AND ls.status <> 'graded'), 0)::BIGINT AS pending_action_count,
    COALESCE((SELECT COUNT(*) FROM latest_session ls
              WHERE ls.dist_id = td.id AND ls.status = 'graded'), 0)::BIGINT AS graded_count,
    COALESCE((SELECT COUNT(*) FROM latest_session ls
              WHERE ls.dist_id = td.id
                AND ls.submitted_at IS NOT NULL
                AND td.due_at IS NOT NULL
                AND ls.submitted_at > td.due_at), 0)::BIGINT AS late_count
  FROM teacher_dists td;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_teacher_distribution_dashboard_stats(UUID) TO authenticated;

-- Index hỗ trợ truy vấn latest-attempt-per-(student, dist).
-- DISTINCT ON cần index theo (student_id, assignment_distribution_id, attempt DESC).
CREATE INDEX IF NOT EXISTS idx_work_sessions_latest_lookup
  ON public.work_sessions (student_id, assignment_distribution_id, attempt DESC, created_at DESC);

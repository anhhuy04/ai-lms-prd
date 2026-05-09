-- Migration 017: get_class_final_scores(p_class_id UUID)
-- Trả về 1 row per (student, distribution) — "Verdict" cuối theo đúng rule của mỗi bài.
-- Dùng cho getClassAnalytics() thay thế raw submissions query.
-- is_late = BOOL_OR(attempt.is_late) — học sinh bị đánh dấu late nếu BẤT KỲ lần nộp nào trễ.
-- Auth: classes.teacher_id = auth.uid()

CREATE OR REPLACE FUNCTION public.get_class_final_scores(
  p_class_id UUID
)
RETURNS TABLE(
  student_id      UUID,
  distribution_id UUID,
  student_name    TEXT,
  final_score     NUMERIC,
  is_late         BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path TO 'public'
AS $$
DECLARE
  v_teacher_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Authentication required';
  END IF;

  SELECT c.teacher_id INTO v_teacher_id
  FROM public.classes c
  WHERE c.id = p_class_id;

  IF v_teacher_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Only the teacher of this class can view class analytics';
  END IF;

  RETURN QUERY
  WITH dist_rules AS (
    SELECT
      ad.id                                                          AS dist_id,
      COALESCE(ad.settings->>'score_aggregation_rule', 'latest')    AS rule
    FROM public.assignment_distributions ad
    WHERE ad.class_id = p_class_id
  ),
  scored AS (
    SELECT
      ws.student_id,
      ws.assignment_distribution_id                                   AS dist_id,
      s.total_score,
      dr.rule,
      -- latest
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY ws.attempt DESC, ws.created_at DESC
      )                                                               AS rn_latest,
      -- first
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY ws.attempt ASC, ws.created_at ASC
      )                                                               AS rn_first,
      -- max
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
      )                                                               AS rn_max,
      -- average
      ROUND(
        AVG(s.total_score) OVER (
          PARTITION BY ws.student_id, ws.assignment_distribution_id
        )::NUMERIC, 2
      )                                                               AS avg_score,
      -- is_late: true nếu BẤT KỲ lần nộp nào trong distribution này bị trễ
      BOOL_OR(COALESCE(s.is_late, false)) OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
      )                                                               AS any_late
    FROM  public.work_sessions ws
    JOIN  public.submissions s  ON s.session_id = ws.id
    JOIN  dist_rules dr         ON dr.dist_id = ws.assignment_distribution_id
    WHERE COALESCE(s.is_voided, false) = false
      AND s.total_score IS NOT NULL
  ),
  verdicts AS (
    SELECT
      student_id,
      dist_id,
      any_late,
      CASE rule
        WHEN 'average' THEN avg_score
        WHEN 'max'     THEN total_score
        WHEN 'first'   THEN total_score
        ELSE                total_score   -- 'latest'
      END AS final_score
    FROM scored
    WHERE
      CASE rule
        WHEN 'average' THEN rn_latest = 1
        WHEN 'max'     THEN rn_max    = 1
        WHEN 'first'   THEN rn_first  = 1
        ELSE                rn_latest = 1
      END
  )
  SELECT
    v.student_id,
    v.dist_id                                   AS distribution_id,
    COALESCE(p.full_name, 'Học sinh')::TEXT     AS student_name,
    v.final_score,
    v.any_late                                  AS is_late
  FROM  verdicts v
  JOIN  public.profiles p ON p.id = v.student_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_class_final_scores(UUID) TO authenticated;

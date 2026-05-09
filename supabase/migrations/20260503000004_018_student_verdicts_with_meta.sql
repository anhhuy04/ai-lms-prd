-- Migration 018: get_student_verdicts_with_meta(p_student_id, p_class_id)
-- Trả về 1 row per distribution — Verdict cuối theo đúng rule, kèm is_late và submitted_at.
-- Dùng cho getBasicMetrics() để tính avgScore, onTimeRate, trendDirection chính xác.
-- Auth: học sinh chỉ xem dữ liệu của chính mình (auth.uid() = p_student_id).
-- p_class_id = NULL → tất cả bài đã làm; p_class_id != NULL → filter theo lớp.

CREATE OR REPLACE FUNCTION public.get_student_verdicts_with_meta(
  p_student_id UUID,
  p_class_id   UUID DEFAULT NULL
)
RETURNS TABLE(
  distribution_id   UUID,
  final_score       NUMERIC,
  is_late           BOOLEAN,
  last_submitted_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path TO 'public'
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Authentication required';
  END IF;

  IF auth.uid() != p_student_id THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Students can only view their own metrics';
  END IF;

  RETURN QUERY
  WITH dist_rules AS (
    SELECT
      ad.id                                                          AS dist_id,
      COALESCE(ad.settings->>'score_aggregation_rule', 'latest')    AS rule
    FROM public.assignment_distributions ad
    WHERE (p_class_id IS NULL OR ad.class_id = p_class_id)
  ),
  scored AS (
    SELECT
      ws.assignment_distribution_id                                   AS dist_id,
      s.total_score,
      dr.rule,
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY ws.attempt DESC, ws.created_at DESC
      )                                                               AS rn_latest,
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY ws.attempt ASC, ws.created_at ASC
      )                                                               AS rn_first,
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
      )                                                               AS rn_max,
      ROUND(
        AVG(s.total_score) OVER (
          PARTITION BY ws.assignment_distribution_id
        )::NUMERIC, 2
      )                                                               AS avg_score,
      BOOL_OR(COALESCE(s.is_late, false)) OVER (
        PARTITION BY ws.assignment_distribution_id
      )                                                               AS any_late,
      MAX(s.submitted_at) OVER (
        PARTITION BY ws.assignment_distribution_id
      )                                                               AS last_submitted
    FROM  public.work_sessions ws
    JOIN  public.submissions s  ON s.session_id = ws.id
    JOIN  dist_rules dr         ON dr.dist_id = ws.assignment_distribution_id
    WHERE ws.student_id                = p_student_id
      AND COALESCE(s.is_voided, false) = false
      AND s.total_score IS NOT NULL
  )
  SELECT
    dist_id                 AS distribution_id,
    CASE rule
      WHEN 'average' THEN avg_score
      WHEN 'max'     THEN total_score
      WHEN 'first'   THEN total_score
      ELSE                total_score   -- 'latest'
    END                     AS final_score,
    any_late                AS is_late,
    last_submitted          AS last_submitted_at
  FROM scored
  WHERE
    CASE rule
      WHEN 'average' THEN rn_latest = 1
      WHEN 'max'     THEN rn_max    = 1
      WHEN 'first'   THEN rn_first  = 1
      ELSE                rn_latest = 1
    END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_student_verdicts_with_meta(UUID, UUID) TO authenticated;

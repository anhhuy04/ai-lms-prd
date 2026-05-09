-- Migration 016: Batch RPC get_student_final_scores_batch
-- Tính điểm cuối cho nhiều distributions cùng lúc (dùng cho màn hình danh sách bài tập).
-- Mỗi distribution áp đúng score_aggregation_rule của riêng nó.
-- Single-pass Window Function — không gọi RPC N lần.

CREATE OR REPLACE FUNCTION public.get_student_final_scores_batch(
  p_distribution_ids UUID[],
  p_student_id       UUID
)
RETURNS TABLE(distribution_id UUID, final_score NUMERIC)
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
      USING HINT = 'Students can only view their own scores';
  END IF;

  RETURN QUERY
  WITH dist_rules AS (
    SELECT
      id                                                        AS dist_id,
      COALESCE(settings->>'score_aggregation_rule', 'latest')  AS rule
    FROM public.assignment_distributions
    WHERE id = ANY(p_distribution_ids)
  ),
  scored AS (
    SELECT
      ws.assignment_distribution_id                                     AS dist_id,
      s.total_score,
      dr.rule,
      -- latest: attempt số lớn nhất
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY ws.attempt DESC, ws.created_at DESC
      )                                                                  AS rn_latest,
      -- first: attempt số nhỏ nhất
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY ws.attempt ASC, ws.created_at ASC
      )                                                                  AS rn_first,
      -- max: điểm cao nhất, tie-break bằng attempt mới nhất
      ROW_NUMBER() OVER (
        PARTITION BY ws.assignment_distribution_id
        ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
      )                                                                  AS rn_max,
      -- average: tính sẵn trên toàn partition, lấy 1 row đại diện
      ROUND(
        AVG(s.total_score) OVER (PARTITION BY ws.assignment_distribution_id)::NUMERIC,
        2
      )                                                                  AS avg_score
    FROM  public.work_sessions ws
    JOIN  public.submissions s  ON s.session_id = ws.id
    JOIN  dist_rules dr         ON dr.dist_id   = ws.assignment_distribution_id
    WHERE ws.assignment_distribution_id = ANY(p_distribution_ids)
      AND ws.student_id                 = p_student_id
      AND COALESCE(s.is_voided, false)  = false
      AND s.total_score IS NOT NULL
  )
  SELECT
    dist_id AS distribution_id,
    CASE rule
      WHEN 'average' THEN avg_score
      WHEN 'max'     THEN total_score
      WHEN 'first'   THEN total_score
      ELSE                total_score   -- 'latest'
    END     AS final_score
  FROM scored
  WHERE
    CASE rule
      WHEN 'average' THEN rn_latest = 1   -- 1 row đại diện, score = avg_score
      WHEN 'max'     THEN rn_max    = 1
      WHEN 'first'   THEN rn_first  = 1
      ELSE                rn_latest = 1   -- 'latest'
    END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_student_final_scores_batch(UUID[], UUID) TO authenticated;

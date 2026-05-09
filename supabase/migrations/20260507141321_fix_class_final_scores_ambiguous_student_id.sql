-- Fix: get_class_final_scores throw "column reference student_id is ambiguous"
-- Lý do: RETURNS TABLE khai báo student_id làm OUT variable trong PL/pgSQL,
-- mà CTE verdicts dùng SELECT student_id không qualify → đụng độ.
-- Cách sửa:
--   1. Thêm directive #variable_conflict use_column để Postgres ưu tiên column khi tên trùng OUT variable.
--   2. Qualify mọi reference student_id/dist_id/... bằng tên CTE (scored.*) trong verdicts CTE.
-- Triệu chứng trước fix: ClassAnalytics rỗng (totalStudents=0, classAverage=0)
-- ở mọi lớp, do datasource catch lỗi 42702 và trả entity rỗng.
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
#variable_conflict use_column
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
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY ws.attempt DESC, ws.created_at DESC
      )                                                               AS rn_latest,
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY ws.attempt ASC, ws.created_at ASC
      )                                                               AS rn_first,
      ROW_NUMBER() OVER (
        PARTITION BY ws.student_id, ws.assignment_distribution_id
        ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
      )                                                               AS rn_max,
      ROUND(
        AVG(s.total_score) OVER (
          PARTITION BY ws.student_id, ws.assignment_distribution_id
        )::NUMERIC, 2
      )                                                               AS avg_score,
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
      scored.student_id,
      scored.dist_id,
      scored.any_late,
      CASE scored.rule
        WHEN 'average' THEN scored.avg_score
        WHEN 'max'     THEN scored.total_score
        WHEN 'first'   THEN scored.total_score
        ELSE                scored.total_score
      END AS final_score
    FROM scored
    WHERE
      CASE scored.rule
        WHEN 'average' THEN scored.rn_latest = 1
        WHEN 'max'     THEN scored.rn_max    = 1
        WHEN 'first'   THEN scored.rn_first  = 1
        ELSE                scored.rn_latest = 1
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

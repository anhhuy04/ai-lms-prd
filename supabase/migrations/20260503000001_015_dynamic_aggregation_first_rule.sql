-- Migration 015: Dynamic Aggregation — thêm 'first' rule + scalar RPC get_student_final_score
-- Mô hình "Verdict vs Archives": điểm cuối luôn tính động từ submissions gốc,
-- không bao giờ cache kết quả tổng hợp. Hỗ trợ 4 rules: latest/max/average/first.

-- ─────────────────────────────────────────────────────────────
-- 1. Scalar RPC: get_student_final_score — dùng cho màn hình học sinh
--    Tính điểm cuối của 1 học sinh theo score_aggregation_rule của distribution.
--    Auth: chỉ học sinh tự query điểm của mình (p_student_id = auth.uid()).
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_student_final_score(
  p_distribution_id UUID,
  p_student_id      UUID
)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path TO 'public'
AS $$
DECLARE
  v_rule  TEXT;
  v_score NUMERIC;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Authentication required';
  END IF;

  -- Học sinh chỉ được xem điểm của chính mình
  IF auth.uid() != p_student_id THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Students can only view their own scores';
  END IF;

  SELECT COALESCE(settings->>'score_aggregation_rule', 'latest')
  INTO   v_rule
  FROM   public.assignment_distributions
  WHERE  id = p_distribution_id;

  IF v_rule = 'max' THEN
    SELECT MAX(s.total_score) INTO v_score
    FROM   public.submissions s
    JOIN   public.work_sessions ws ON ws.id = s.session_id
    WHERE  ws.assignment_distribution_id = p_distribution_id
      AND  ws.student_id                 = p_student_id
      AND  COALESCE(s.is_voided, false)  = false
      AND  s.total_score IS NOT NULL;

  ELSIF v_rule = 'average' THEN
    SELECT ROUND(AVG(s.total_score)::NUMERIC, 2) INTO v_score
    FROM   public.submissions s
    JOIN   public.work_sessions ws ON ws.id = s.session_id
    WHERE  ws.assignment_distribution_id = p_distribution_id
      AND  ws.student_id                 = p_student_id
      AND  COALESCE(s.is_voided, false)  = false
      AND  s.total_score IS NOT NULL;

  ELSIF v_rule = 'first' THEN
    -- Bài đầu tiên = attempt nhỏ nhất chưa bị voided
    SELECT s.total_score INTO v_score
    FROM   public.submissions s
    JOIN   public.work_sessions ws ON ws.id = s.session_id
    WHERE  ws.assignment_distribution_id = p_distribution_id
      AND  ws.student_id                 = p_student_id
      AND  COALESCE(s.is_voided, false)  = false
      AND  s.total_score IS NOT NULL
    ORDER BY ws.attempt ASC, ws.created_at ASC
    LIMIT 1;

  ELSE -- 'latest' (default)
    SELECT s.total_score INTO v_score
    FROM   public.submissions s
    JOIN   public.work_sessions ws ON ws.id = s.session_id
    WHERE  ws.assignment_distribution_id = p_distribution_id
      AND  ws.student_id                 = p_student_id
      AND  COALESCE(s.is_voided, false)  = false
      AND  s.total_score IS NOT NULL
    ORDER BY ws.attempt DESC, ws.created_at DESC
    LIMIT 1;
  END IF;

  RETURN v_score;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_student_final_score(UUID, UUID) TO authenticated;

-- ─────────────────────────────────────────────────────────────
-- 2. Cập nhật get_aggregated_scores_for_distribution — thêm 'first' branch
--    (teacher gradebook, đã có sẵn, chỉ thiếu 'first' rule)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_aggregated_scores_for_distribution(
  p_distribution_id UUID,
  p_rule            TEXT DEFAULT NULL
)
RETURNS TABLE(
  student_id          UUID,
  final_score         NUMERIC,
  attempts_count      INTEGER,
  final_submission_id UUID,
  final_session_id    UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_rule       TEXT;
  v_teacher_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Authentication required';
  END IF;

  SELECT a.teacher_id INTO v_teacher_id
  FROM   public.assignment_distributions ad
  JOIN   public.assignments a ON a.id = ad.assignment_id
  WHERE  ad.id = p_distribution_id;

  IF v_teacher_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Only the teacher who owns this assignment can view aggregated scores';
  END IF;

  IF p_rule IS NOT NULL THEN
    v_rule := p_rule;
  ELSE
    SELECT COALESCE(d.settings->>'score_aggregation_rule', 'latest')
    INTO   v_rule
    FROM   public.assignment_distributions d
    WHERE  d.id = p_distribution_id;
  END IF;

  -- ── average ──────────────────────────────────────────────
  IF v_rule = 'average' THEN
    RETURN QUERY
      SELECT
        ws.student_id,
        ROUND(AVG(s.total_score)::NUMERIC, 2)  AS final_score,
        COUNT(*)::INTEGER                       AS attempts_count,
        NULL::UUID                              AS final_submission_id,
        NULL::UUID                              AS final_session_id
      FROM  public.work_sessions ws
      JOIN  public.submissions s ON s.session_id = ws.id
      WHERE ws.assignment_distribution_id = p_distribution_id
        AND COALESCE(s.is_voided, false)   = false
        AND s.total_score IS NOT NULL
      GROUP BY ws.student_id;

  -- ── max ──────────────────────────────────────────────────
  ELSIF v_rule = 'max' THEN
    RETURN QUERY
      WITH ranked AS (
        SELECT
          ws.student_id,
          ws.id         AS session_id,
          s.id          AS submission_id,
          s.total_score,
          COUNT(*) OVER (PARTITION BY ws.student_id)::INTEGER AS attempts_count,
          ROW_NUMBER() OVER (
            PARTITION BY ws.student_id
            ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
          ) AS rn
        FROM  public.work_sessions ws
        JOIN  public.submissions s ON s.session_id = ws.id
        WHERE ws.assignment_distribution_id = p_distribution_id
          AND COALESCE(s.is_voided, false)   = false
          AND s.total_score IS NOT NULL
      )
      SELECT student_id, total_score AS final_score, attempts_count,
             submission_id AS final_submission_id, session_id AS final_session_id
      FROM ranked WHERE rn = 1;

  -- ── first ─────────────────────────────────────────────────
  ELSIF v_rule = 'first' THEN
    RETURN QUERY
      WITH ranked AS (
        SELECT
          ws.student_id,
          ws.id         AS session_id,
          s.id          AS submission_id,
          s.total_score,
          COUNT(*) OVER (PARTITION BY ws.student_id)::INTEGER AS attempts_count,
          ROW_NUMBER() OVER (
            PARTITION BY ws.student_id
            ORDER BY ws.attempt ASC, ws.created_at ASC
          ) AS rn
        FROM  public.work_sessions ws
        JOIN  public.submissions s ON s.session_id = ws.id
        WHERE ws.assignment_distribution_id = p_distribution_id
          AND COALESCE(s.is_voided, false)   = false
          AND s.total_score IS NOT NULL
      )
      SELECT student_id, total_score AS final_score, attempts_count,
             submission_id AS final_submission_id, session_id AS final_session_id
      FROM ranked WHERE rn = 1;

  -- ── latest (default) ─────────────────────────────────────
  ELSE
    RETURN QUERY
      WITH ranked AS (
        SELECT
          ws.student_id,
          ws.id         AS session_id,
          s.id          AS submission_id,
          s.total_score,
          COUNT(*) OVER (PARTITION BY ws.student_id)::INTEGER AS attempts_count,
          ROW_NUMBER() OVER (
            PARTITION BY ws.student_id
            ORDER BY ws.attempt DESC
          ) AS rn
        FROM  public.work_sessions ws
        JOIN  public.submissions s ON s.session_id = ws.id
        WHERE ws.assignment_distribution_id = p_distribution_id
          AND COALESCE(s.is_voided, false)   = false
          AND s.total_score IS NOT NULL
      )
      SELECT student_id, total_score AS final_score, attempts_count,
             submission_id AS final_submission_id, session_id AS final_session_id
      FROM ranked WHERE rn = 1;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_aggregated_scores_for_distribution(UUID, TEXT) TO authenticated;

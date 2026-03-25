-- ==============================================================================
-- MIGRATION: Phase 5 - Personalized Recommendations
-- Created: 2026-03-25
-- Purpose: RPC for peer comparison (REC-03) + RLS policies for ai_recommendations
-- ==============================================================================

-- ══════════════════════════════════════════════════════════════════════════════
-- 1. RPC: get_student_peer_comparison (SECURITY DEFINER)
--    Computes percentile and class average server-side.
--    Per REC-03: NO raw scores ever sent to the Flutter client.
-- ══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.get_student_peer_comparison(
  p_student_id UUID,
  p_class_id UUID
) RETURNS JSONB
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
  v_student_avg NUMERIC;
  v_class_avg NUMERIC;
  v_percentile NUMERIC;
  v_rank INTEGER;
  v_total INTEGER;
BEGIN
  -- Step 1: Get this student's average score for this class's assignments
  WITH class_distributions AS (
    SELECT id FROM public.assignment_distributions
    WHERE class_id = p_class_id
  )
  SELECT COALESCE(AVG(s.total_score), 0)
  INTO v_student_avg
  FROM public.submissions s
  WHERE s.student_id = p_student_id
    AND s.assignment_distribution_id IN (SELECT id FROM class_distributions)
    AND s.total_score IS NOT NULL;

  -- Step 2: Compute per-student averages for this class
  WITH class_distributions AS (
    SELECT id FROM public.assignment_distributions
    WHERE class_id = p_class_id
  ),
  student_avgs AS (
    SELECT
      s.student_id,
      AVG(s.total_score) AS avg_score
    FROM public.submissions s
    WHERE s.assignment_distribution_id IN (SELECT id FROM class_distributions)
      AND s.total_score IS NOT NULL
    GROUP BY s.student_id
  ),
  ranked AS (
    SELECT
      avg_score,
      ROW_NUMBER() OVER (ORDER BY avg_score DESC) AS rn,
      COUNT(*) OVER () AS total
    FROM student_avgs
  )
  SELECT
    (SELECT AVG(avg_score) FROM student_avgs),
    (SELECT ROUND(
      COUNT(*) FILTER (WHERE avg_score < v_student_avg) * 100.0 / NULLIF(MAX(r.total), 0), 1
    ) FROM ranked r),
    (SELECT COALESCE(MIN(rn), 1) FROM ranked r WHERE r.avg_score <= v_student_avg),
    (SELECT MAX(total) FROM ranked)
  INTO v_class_avg, v_percentile, v_rank, v_total
  FROM ranked LIMIT 1;

  RETURN jsonb_build_object(
    'class_average', ROUND(COALESCE(v_class_avg, 0)::numeric, 2),
    'percentile', ROUND(COALESCE(v_percentile, 0)::numeric, 1),
    'rank', COALESCE(v_rank, 0),
    'total_students', COALESCE(v_total, 0)
  );
END;
$$;

-- ══════════════════════════════════════════════════════════════════════════════
-- 2. RLS Policies for ai_recommendations table
--    Teachers can see their own recommendations.
--    Students can see their own recommendations.
-- ══════════════════════════════════════════════════════════════════════════════

-- Enable RLS on ai_recommendations
ALTER TABLE public.ai_recommendations ENABLE ROW LEVEL SECURITY;

-- Policy: Teachers can read recommendations where teacher_id matches auth.uid()
CREATE POLICY "teachers_read_own_recommendations" ON public.ai_recommendations
  FOR SELECT
  USING (teacher_id = (SELECT auth.uid()));

-- Policy: Teachers can update (dismiss) their own recommendations
CREATE POLICY "teachers_update_own_recommendations" ON public.ai_recommendations
  FOR UPDATE
  USING (teacher_id = (SELECT auth.uid()))
  WITH CHECK (teacher_id = (SELECT auth.uid()));

-- Policy: Students can read their own recommendations (student_id = auth.uid())
CREATE POLICY "students_read_own_recommendations" ON public.ai_recommendations
  FOR SELECT
  USING (student_id = (SELECT auth.uid()));

-- Policy: Students can update (dismiss) their own recommendations
CREATE POLICY "students_update_own_recommendations" ON public.ai_recommendations
  FOR UPDATE
  USING (student_id = (SELECT auth.uid()))
  WITH CHECK (student_id = (SELECT auth.uid()));

-- Drop the old policy if it exists (was teacher-only)
DROP POLICY IF EXISTS "ai_recommendations_teacher_policy" ON public.ai_recommendations;

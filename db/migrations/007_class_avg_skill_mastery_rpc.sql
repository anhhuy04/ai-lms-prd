-- Phase 7 Plan 09 (D-22): RPC for class average skill mastery
-- Returns average mastery per learning objective for all students in a class.
-- SECURITY DEFINER to bypass RLS (teacher needs to see aggregate across students).
--
-- Students link to classes via public.class_members (status = 'approved').
-- learning_objectives uses (code, description), not (name) — see schema_02.

CREATE OR REPLACE FUNCTION public.get_class_average_skill_mastery(p_class_id uuid)
RETURNS TABLE (
  objective_id              uuid,
  objective_code            text,
  objective_description     text,
  subject_code              text,
  avg_mastery               numeric,
  total_students            bigint,
  students_below_threshold  bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ssm.objective_id,
    lo.code                                      AS objective_code,
    lo.description                               AS objective_description,
    lo.subject_code                              AS subject_code,
    AVG(ssm.mastery_level)::numeric              AS avg_mastery,
    COUNT(DISTINCT ssm.student_id)               AS total_students,
    COUNT(DISTINCT ssm.student_id)
      FILTER (WHERE ssm.mastery_level < 0.6)     AS students_below_threshold
  FROM public.student_skill_mastery ssm
  JOIN public.learning_objectives lo
    ON lo.id = ssm.objective_id
  WHERE ssm.student_id IN (
    SELECT cm.student_id
    FROM public.class_members cm
    WHERE cm.class_id = p_class_id
      AND cm.status = 'approved'
  )
  GROUP BY ssm.objective_id, lo.code, lo.description, lo.subject_code
  ORDER BY avg_mastery ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_class_average_skill_mastery(uuid) TO authenticated;

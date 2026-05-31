-- ============================================================================
-- Migration 038: ai_recommendations — REC-01/REC-02 split + subject_student_id (Phase 5a, Q4)
-- Plan: .planning/phases/05-personalized-recommendations/05-06-PLAN.md (Task 6)
-- Verified live (2026-05-31):
--   - Index 3 cột (teacher_id, subject_student_id, objective_id) FULL + NULLS DISTINCT:
--     student rows (3 cột NULL) KHÔNG va; teacher rows dedupe qua bare ON CONFLICT (không 42P10).
--   - RLS students_read = student_id=auth.uid() → dòng teacher (student_id NULL) student KHÔNG đọc được.
-- subject_student_id = "rec NÓI VỀ học sinh nào" (chỉ data, KHÔNG nằm trong RLS policy) → chống rò.
-- ============================================================================

-- 1) Cột subject_student_id (teacher REC-01 rows tham chiếu HS; student rows để NULL).
ALTER TABLE public.ai_recommendations
  ADD COLUMN IF NOT EXISTS subject_student_id uuid;

ALTER TABLE public.ai_recommendations
  DROP CONSTRAINT IF EXISTS ai_recommendations_subject_student_id_fkey;
ALTER TABLE public.ai_recommendations
  ADD CONSTRAINT ai_recommendations_subject_student_id_fkey
  FOREIGN KEY (subject_student_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2) FULL unique index cho teacher REC-01 rows (1 rec / teacher / HS / objective).
--    NULLS DISTINCT (mặc định) → student rows (teacher_id+subject_student_id NULL) tự thoát.
--    Bare ON CONFLICT (teacher_id,subject_student_id,objective_id) dùng được (đã verify không 42P10).
CREATE UNIQUE INDEX IF NOT EXISTS idx_ai_recs_teacher_subject_obj_unique
  ON public.ai_recommendations (teacher_id, subject_student_id, objective_id);

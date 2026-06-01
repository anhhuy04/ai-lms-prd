-- ============================================================================
-- Migration 037: ai_recommendations — idempotency + category (Phase 5a)
-- Plan: .planning/phases/05-personalized-recommendations/05-06-PLAN.md (Task 1)
-- Verified live (2026-05-31): total=50, 19 dòng teacher_id NULL source='ai_queue_analysis'
--   (= 19 dòng trùng), seed teacher_id NOT NULL=31, chưa có cột category/objective_id, chưa unique index.
-- DELETE 19 gộp luôn dedup → còn 31. Edge sinh lại đúng teacher_id/class_id ở lần submit kế.
-- THỨ TỰ: DELETE trước → ADD COLUMN → FK → CREATE UNIQUE INDEX cuối (index trước delete sẽ fail trùng).
-- ============================================================================

-- 1) DỌN 19 dòng generator cũ (teacher_id NULL — không backfill được teacher_id vì resources jsonb
--    không chứa session/distribution linkage). Gộp luôn dedup (9 + 5×2 = 19).
DELETE FROM public.ai_recommendations
WHERE teacher_id IS NULL
  AND resources->>'source' = 'ai_queue_analysis';

-- 2) Cột thật objective_id (nullable: seed/teacher rows không có objective).
ALTER TABLE public.ai_recommendations
  ADD COLUMN IF NOT EXISTS objective_id uuid;

-- 3) Cột category (phân loại, TÁCH khỏi type=scope). NOT NULL DEFAULT 'study_tip'
--    → 31 dòng cũ tự nhận default, không sinh NULL. CHECK 9 giá trị khớp Recommendation._typeToString.
ALTER TABLE public.ai_recommendations
  ADD COLUMN IF NOT EXISTS category text NOT NULL DEFAULT 'study_tip';

ALTER TABLE public.ai_recommendations
  DROP CONSTRAINT IF EXISTS ai_recommendations_category_check;
ALTER TABLE public.ai_recommendations
  ADD CONSTRAINT ai_recommendations_category_check
  CHECK (category = ANY (ARRAY[
    'study_tip', 'intervention', 'peer_comparison', 'assignment_suggestion',
    'skill_gap', 'engagement_alert', 'at_risk_warning', 'improvement_opportunity',
    'late_submission_alert'
  ]::text[]));

-- 4) FK objective_id → learning_objectives ON DELETE SET NULL (survivors objective_id NULL → validate OK).
ALTER TABLE public.ai_recommendations
  DROP CONSTRAINT IF EXISTS ai_recommendations_objective_id_fkey;
ALTER TABLE public.ai_recommendations
  ADD CONSTRAINT ai_recommendations_objective_id_fkey
  FOREIGN KEY (objective_id) REFERENCES public.learning_objectives(id)
  ON DELETE SET NULL;

-- 5) FULL unique index (NULLS DISTINCT mặc định) — KHÔNG partial (42P10 đã verify với PostgREST .upsert).
--    Seed rows (objective_id NULL) tự thoát. Chỉ rec generator (student_id + objective_id non-null) bị
--    ràng buộc 1-rec/(student,objective). onConflict cho supabase-js: 'student_id,objective_id'.
CREATE UNIQUE INDEX IF NOT EXISTS idx_ai_recs_student_objective_unique
  ON public.ai_recommendations (student_id, objective_id);

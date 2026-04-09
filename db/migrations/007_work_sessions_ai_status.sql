-- Phase 7: Extend work_sessions.status for AI workflow
-- Adds: ai_processing, pending_review
-- Zero breaking changes: existing values (in_progress, submitted, graded) still valid

ALTER TABLE public.work_sessions
  DROP CONSTRAINT IF EXISTS work_sessions_status_check;

ALTER TABLE public.work_sessions
  ADD CONSTRAINT work_sessions_status_check
  CHECK (status IN ('in_progress', 'submitted', 'ai_processing', 'pending_review', 'graded'));

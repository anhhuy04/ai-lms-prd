-- Migration 012: Add vectorize_document to ai_queue.request_type CHECK constraint
-- Phase 9: AI Settings Refactor & Document Import

-- Drop existing constraint (if named), recreate with new value
ALTER TABLE public.ai_queue
  DROP CONSTRAINT IF EXISTS ai_queue_request_type_check;

ALTER TABLE public.ai_queue
  ADD CONSTRAINT ai_queue_request_type_check
  CHECK (request_type IN ('score', 'feedback', 'analysis', 'vectorize_document'));

-- Add unique constraint for autosave_answers upsert
ALTER TABLE public.autosave_answers ADD CONSTRAINT autosave_answers_session_question_unique UNIQUE (session_id, assignment_question_id);

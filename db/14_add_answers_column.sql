-- Remove answers and uploaded_files columns (using autosave_answers table instead)
ALTER TABLE public.work_sessions DROP COLUMN IF EXISTS answers;
ALTER TABLE public.work_sessions DROP COLUMN IF EXISTS uploaded_files;

BEGIN;

-- ============================================================
-- FIX 1: Convert raw string 'content' in question_choices to object
-- ============================================================
-- Background: 
-- Earlier seed data incorrectly generated question_choices 'content' as 
-- simple string jsonb (e.g., '"5 tầng"'). The Flutter frontend uses 
-- QuestionChoice.fromJson which strictly expects Map<String, dynamic>.
-- This update wraps any raw string inside {"text": "..."_} to match the system form.
UPDATE question_choices 
SET content = jsonb_build_object('text', content #>> '{}')
WHERE jsonb_typeof(content) = 'string';

-- ============================================================
-- FIX 2: Mark all submitted work_sessions as graded
-- ============================================================
-- Background: 
-- A significant number of seeded work_sessions remained at 'submitted' status. 
-- In the Teacher Dashboard, assignments with 'submitted' count > 'graded' count 
-- are displayed in the "Chưa chấm" filter bucket.
-- Setting them all to 'graded' pushes them completely into the 'Đã chấm' workflow.
UPDATE work_sessions 
SET status = 'graded' 
WHERE status = 'submitted';

COMMIT;

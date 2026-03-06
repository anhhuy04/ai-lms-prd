-- ============================================================
-- Migration: sync_schema_with_sql_flow_decisions
-- Purpose: Apply all decisions from docs/guides/development/sql-flow-decisions.md
-- Date: 2026-03-06
-- ============================================================

-- ============================================================
-- Flow 1: Class Management - class_members
-- ============================================================

-- Thêm enrolled_by và join_method vào class_members
ALTER TABLE class_members 
ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users,
ADD COLUMN IF NOT EXISTS join_method text DEFAULT 'manual_add';

-- Xóa cột role không cần thiết (role nằm ở profiles)
-- ALTER TABLE class_members DROP COLUMN IF EXISTS role;

-- ============================================================
-- Flow 2: Groups - groups table
-- ============================================================

-- Xóa teacher_id không cần thiết (nhóm thuộc về lớp, không thuộc về teacher)
ALTER TABLE groups DROP COLUMN IF EXISTS teacher_id;

-- Set class_id NOT NULL
ALTER TABLE groups ALTER COLUMN class_id SET NOT NULL;

-- ============================================================
-- Flow 2: Groups - group_members
-- ============================================================

-- Thêm role và enrolled_by vào group_members
ALTER TABLE group_members 
ADD COLUMN IF NOT EXISTS role text DEFAULT 'member',
ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users;

-- ============================================================
-- Flow 3: Assignments - Template vs Deployment
-- ============================================================

-- Xóa các cột đã chuyển sang assignment_distributions
ALTER TABLE assignments
DROP COLUMN IF EXISTS due_at,
DROP COLUMN IF EXISTS available_from,
DROP COLUMN IF EXISTS time_limit_minutes,
DROP COLUMN IF EXISTS allow_late;

-- ============================================================
-- Flow 4: Work Sessions - Remove 'late' status
-- ============================================================

-- Xóa constraint cũ và thêm mới không có 'late'
ALTER TABLE work_sessions
DROP CONSTRAINT IF EXISTS work_sessions_status_check;

ALTER TABLE work_sessions
ADD CONSTRAINT work_sessions_status_check
CHECK (status IN ('in_progress', 'submitted', 'graded'));

-- ============================================================
-- Flow 4: Submissions - Update is_late computation
-- ============================================================

-- is_late được tính toán từ assignment_distributions
-- (đã có trong schema gốc, chỉ cần đảm bảo logic đúng)

-- ============================================================
-- Flow 6: Questions - Soft Delete
-- ============================================================

ALTER TABLE questions ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;

-- ============================================================
-- Flow 6: Question Choices - UUID conversion
-- ============================================================

-- Đổi id từ integer sang uuid
-- Lưu ý: Cần migration phức tạp hơn vì có foreign key
-- Tạm thời comment out, cần chạy thủ công với care
-- ALTER TABLE question_choices ALTER COLUMN id TYPE uuid USING gen_random_uuid();

-- ============================================================
-- Flow 7: Files - Soft Delete
-- ============================================================

ALTER TABLE files ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;

-- ============================================================
-- Flow 9: Teacher Notes - Add class_id và metadata
-- ============================================================

ALTER TABLE teacher_notes 
ADD COLUMN IF NOT EXISTS class_id uuid REFERENCES classes(id),
ADD COLUMN IF NOT EXISTS metadata jsonb;

-- ============================================================
-- Indexes (đảm bảo đã tạo)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_class_members_enrolled_by ON public.class_members(enrolled_by);
CREATE INDEX IF NOT EXISTS idx_class_members_join_method ON public.class_members(join_method);
CREATE INDEX IF NOT EXISTS idx_groups_class_id ON public.groups(class_id);
CREATE INDEX IF NOT EXISTS idx_group_members_enrolled_by ON public.group_members(enrolled_by);
CREATE INDEX IF NOT EXISTS idx_questions_is_deleted ON public.questions(is_deleted);
CREATE INDEX IF NOT EXISTS idx_files_is_deleted ON public.files(is_deleted);
CREATE INDEX IF NOT EXISTS idx_teacher_notes_class_id ON public.teacher_notes(class_id);

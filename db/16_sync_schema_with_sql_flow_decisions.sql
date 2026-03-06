-- ==============================================================================
-- MIGRATION SCRIPT: CAP NHAT KIEN TRUC AI LMS (CHUAN ENTERPRISE)
-- ==============================================================================

-- 1. QUAN LY LOP HOC (Class Management)
-- Xoa cot role (da duoc quan ly o bang profiles), them audit trail
ALTER TABLE public.class_members
  DROP COLUMN IF EXISTS role,
  ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS join_method text DEFAULT 'manual_add';

-- 2. QUAN LY NHOM (Group Management)
-- Nhom phai thuoc ve lop, khong thuoc ve giao vien ca nhan
ALTER TABLE public.groups
  DROP COLUMN IF EXISTS teacher_id;

-- XU LY NULL VALUES TRUOC KHI SET NOT NULL
-- Xoa cac group co class_id = NULL (orphan data)
DELETE FROM public.groups WHERE class_id IS NULL;

-- Set class_id NOT NULL
ALTER TABLE public.groups
  ALTER COLUMN class_id SET NOT NULL;

ALTER TABLE public.group_members
  ADD COLUMN IF NOT EXISTS role text DEFAULT 'member',
  ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users(id);

-- 3. NGAN HANG BAI TAP (Assignments - Tach biet Noi dung & Phan phoi)
-- Don dep bang assignments thanh mot Template nguyen thuy
ALTER TABLE public.assignments
  DROP COLUMN IF EXISTS due_at,
  DROP COLUMN IF EXISTS available_from,
  DROP COLUMN IF EXISTS time_limit_minutes,
  DROP COLUMN IF EXISTS allow_late;

-- 4. PHIEN LAM BAI & NOP BAI (Work Sessions & Submissions)
-- Gioi han lai trang thai (Bo 'late')
ALTER TABLE public.work_sessions
  DROP CONSTRAINT IF EXISTS work_sessions_status_check;

ALTER TABLE public.work_sessions
  ADD CONSTRAINT work_sessions_status_check
  CHECK (status IN ('in_progress', 'submitted', 'graded'));

-- Xoa Generated Column gay loi Subquery, doi thanh cot Boolean tinh
ALTER TABLE public.submissions
  DROP COLUMN IF EXISTS is_late;

ALTER TABLE public.submissions
  ADD COLUMN IF NOT EXISTS is_late boolean DEFAULT false;

-- 5. LUU VET & XOA MEM (Soft Deletes)
-- Cuc ky quan trong de bao ve du lieu khi tich hop AI va Analytics
ALTER TABLE public.questions
  ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;

ALTER TABLE public.files
  ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;

-- 6. GHI CHU GIAO VIEN (Teacher Notes)
-- Them Context lop hoc va Metadata de mo rong cho AI
ALTER TABLE public.teacher_notes
  ADD COLUMN IF NOT EXISTS class_id uuid REFERENCES public.classes(id),
  ADD COLUMN IF NOT EXISTS metadata jsonb;

-- ==============================================================================
-- HOTFIX MIGRATION: FIX HIDDEN BUGS & OPTIMIZE RELATIONSHIPS
-- ==============================================================================

-- FIX 1: Dich chuyen mo neo cua bien the bai tap (Variants)
ALTER TABLE public.assignment_variants
  ADD COLUMN IF NOT EXISTS assignment_distribution_id uuid REFERENCES public.assignment_distributions(id) ON DELETE CASCADE;

-- FIX 2: Toi uu hoa CQRS cho bang Submissions (Dashboard Analytics)
-- Buoc 1: Them cot moi
ALTER TABLE public.submissions
  ADD COLUMN IF NOT EXISTS assignment_distribution_id uuid REFERENCES public.assignment_distributions(id) ON DELETE CASCADE;

-- Buoc 2: Copy du lieu tu cot cu sang cot moi (neu co du lieu cu)
UPDATE public.submissions
SET assignment_distribution_id = distribution_id::uuid
WHERE distribution_id IS NOT NULL
  AND assignment_distribution_id IS NULL;

-- Buoc 3: Xoa cot cu sau khi da copy
ALTER TABLE public.submissions
  DROP COLUMN IF EXISTS distribution_id;

-- Them Index de giao vien tai bang diem chop nhoang (Dashboard Optimization)
CREATE INDEX IF NOT EXISTS idx_submissions_distribution
  ON public.submissions(assignment_distribution_id);

-- FIX 3: Chuan hoa lai Khoa ngoai (Dua tat ca ve auth.users de dong nhat)
-- Sua group_members
ALTER TABLE public.group_members
  DROP CONSTRAINT IF EXISTS group_members_student_id_fkey,
  ADD CONSTRAINT group_members_student_id_fkey
  FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Sua work_sessions
ALTER TABLE public.work_sessions
  DROP CONSTRAINT IF EXISTS work_sessions_student_id_fkey,
  ADD CONSTRAINT work_sessions_student_id_fkey
  FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Sua submissions
ALTER TABLE public.submissions
  DROP CONSTRAINT IF EXISTS submissions_student_id_fkey,
  ADD CONSTRAINT submissions_student_id_fkey
  FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE;

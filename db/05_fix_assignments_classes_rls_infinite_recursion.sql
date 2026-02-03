-- Fix infinite recursion in assignments and classes RLS policies
-- 
-- Problem: Policies on assignments and classes are querying class_members, 
-- group_members, and classes tables which have RLS enabled, causing infinite recursion:
-- 1. Query assignments → RLS checks policy → queries class_members/group_members
-- 2. Query class_members → RLS checks policy → may query other tables → infinite loop
-- 3. Query classes → RLS checks policy → queries class_members → infinite loop
--
-- Solution: Create SECURITY DEFINER functions that bypass RLS when checking 
-- membership and ownership relationships

-- ===========================
-- 1. Function: Check if student is member of a class
-- ===========================
CREATE OR REPLACE FUNCTION public.is_student_in_class(
  student_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class.student_id
      AND cm.class_id = is_student_in_class.class_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- ===========================
-- 2. Function: Check if student is member of a class (pending or approved)
-- ===========================
CREATE OR REPLACE FUNCTION public.is_student_in_class_any_status(
  student_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class_any_status.student_id
      AND cm.class_id = is_student_in_class_any_status.class_id
      AND cm.status IN ('approved', 'pending')
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- ===========================
-- 3. Function: Check if student is member of a group
-- ===========================
CREATE OR REPLACE FUNCTION public.is_student_in_group(
  student_id UUID,
  group_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM group_members gm
    WHERE gm.student_id = is_student_in_group.student_id
      AND gm.group_id = is_student_in_group.group_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- ===========================
-- 4. Function: Check if teacher owns a class
-- ===========================
CREATE OR REPLACE FUNCTION public.is_teacher_owner_of_class(
  teacher_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM classes c
    WHERE c.id = is_teacher_owner_of_class.class_id
      AND c.teacher_id = is_teacher_owner_of_class.teacher_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- ===========================
-- 5. Fix assignments policies
-- ===========================

-- Xóa policy cũ gây infinite recursion
DROP POLICY IF EXISTS "Students can view assigned assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can create assignments" ON assignments;

-- Tạo lại policy "Students can view assigned assignments" sử dụng functions
-- Note: Teachers đã có policy riêng "Teachers can view own assignments"
CREATE POLICY "Students can view assigned assignments"
ON assignments
FOR SELECT
TO public
USING (
  -- Student có thể xem assignments đã được phân phối cho họ
  EXISTS (
    SELECT 1
    FROM assignment_distributions ad
    WHERE ad.assignment_id = assignments.id
      AND assignments.is_published = true
      AND (
        -- Distribution cho class
        (ad.distribution_type = 'class' 
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        -- Distribution cho group
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        -- Distribution cá nhân
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  )
);

-- Tạo lại policy "Teachers can create assignments" sử dụng function
CREATE POLICY "Teachers can create assignments"
ON assignments
FOR INSERT
TO public
WITH CHECK (
  auth.uid() = teacher_id
  AND (
    class_id IS NULL
    OR public.is_teacher_owner_of_class(auth.uid(), class_id)
  )
);

-- ===========================
-- 6. Fix classes policies
-- ===========================

-- Xóa policy cũ gây infinite recursion
DROP POLICY IF EXISTS "Students view enrolled classes" ON classes;
DROP POLICY IF EXISTS "Teachers manage own classes" ON classes;

-- Tạo lại policy "Students view enrolled classes" sử dụng function
CREATE POLICY "Students view enrolled classes"
ON classes
FOR SELECT
TO public
USING (
  -- Teacher có thể xem classes của mình
  (get_user_role_safe() = 'teacher' AND teacher_id = auth.uid())
  OR
  -- Student có thể xem classes mà họ đã đăng ký (pending hoặc approved)
  public.is_student_in_class_any_status(auth.uid(), classes.id)
);

-- Tạo lại policy "Teachers manage own classes" sử dụng function
CREATE POLICY "Teachers manage own classes"
ON classes
FOR ALL
TO public
USING (
  get_user_role_safe() = 'teacher'
  AND public.is_teacher_owner_of_class(auth.uid(), classes.id)
)
WITH CHECK (
  get_user_role_safe() = 'teacher'
  AND public.is_teacher_owner_of_class(auth.uid(), classes.id)
);

-- ===========================
-- Comments
-- ===========================
COMMENT ON FUNCTION public.is_student_in_class(UUID, UUID) IS 
'Check if a student is an approved member of a class. Bypasses RLS to prevent infinite recursion.';

COMMENT ON FUNCTION public.is_student_in_class_any_status(UUID, UUID) IS 
'Check if a student is a member of a class (pending or approved). Bypasses RLS to prevent infinite recursion.';

COMMENT ON FUNCTION public.is_student_in_group(UUID, UUID) IS 
'Check if a student is a member of a group. Bypasses RLS to prevent infinite recursion.';

COMMENT ON FUNCTION public.is_teacher_owner_of_class(UUID, UUID) IS 
'Check if a teacher owns a class. Bypasses RLS to prevent infinite recursion.';

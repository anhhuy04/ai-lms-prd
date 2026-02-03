-- Fix infinite recursion in class_members RLS policy
-- 
-- Problem: The teacher_read_student_profiles policy on profiles table was querying 
-- the class_members table to check if a teacher can view a student's profile.
-- When RLS on class_members is checked, it can trigger queries that create infinite recursion:
-- 1. Query profiles → RLS checks teacher_read_student_profiles policy
-- 2. Policy queries class_members → RLS checks class_members policies
-- 3. If class_members policies query profiles or other tables with RLS → Infinite loop
--
-- Solution: Create a SECURITY DEFINER function that bypasses RLS when checking 
-- class membership relationships

-- Tạo function SECURITY DEFINER để kiểm tra teacher có dạy class mà student là member không
-- Function này bypass RLS để tránh infinite recursion
CREATE OR REPLACE FUNCTION public.is_teacher_of_student_class(
  teacher_id UUID,
  student_id UUID
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
  -- Kiểm tra xem teacher có dạy class nào mà student là member không
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    JOIN classes c ON c.id = cm.class_id
    WHERE cm.student_id = is_teacher_of_student_class.student_id
      AND c.teacher_id = is_teacher_of_student_class.teacher_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- Xóa policy cũ gây infinite recursion
DROP POLICY IF EXISTS "teacher_read_student_profiles" ON profiles;

-- Tạo lại policy sử dụng function thay vì query trực tiếp
CREATE POLICY "teacher_read_student_profiles"
ON profiles
FOR SELECT
TO public
USING (
  -- User có thể đọc profile của chính mình
  auth.uid() = id
  OR
  -- Teacher có thể đọc profile của học sinh trong lớp mình dạy
  public.is_teacher_of_student_class(auth.uid(), id)
);

-- Comment để giải thích
COMMENT ON FUNCTION public.is_teacher_of_student_class(UUID, UUID) IS 
'Check if a teacher teaches a class where a student is a member. Bypasses RLS to prevent infinite recursion in policies.';

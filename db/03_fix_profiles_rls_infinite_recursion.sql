-- Fix infinite recursion in profiles RLS policy
-- 
-- Problem: The admin_full_access_profiles policy was querying the profiles table
-- to check if a user is an admin, which caused infinite recursion because:
-- 1. Query profiles → RLS checks policy
-- 2. Policy queries profiles to check role → RLS checks policy again
-- 3. Infinite loop
--
-- Solution: Create a SECURITY DEFINER function that bypasses RLS when checking role

-- Tạo function SECURITY DEFINER để lấy role mà không bị ảnh hưởng bởi RLS
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role TEXT;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT role INTO user_role
  FROM profiles
  WHERE id = user_id
  LIMIT 1;
  
  RETURN user_role;
END;
$$;

-- Xóa policy cũ gây infinite recursion
DROP POLICY IF EXISTS "admin_full_access_profiles" ON profiles;

-- Tạo lại policy sử dụng function thay vì query trực tiếp
CREATE POLICY "admin_full_access_profiles"
ON profiles
FOR ALL
TO public
USING (
  public.get_user_role(auth.uid()) = 'admin'
)
WITH CHECK (
  public.get_user_role(auth.uid()) = 'admin'
);

-- Comment để giải thích
COMMENT ON FUNCTION public.get_user_role(UUID) IS 
'Get user role bypassing RLS to prevent infinite recursion in policies';

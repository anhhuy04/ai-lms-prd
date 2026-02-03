-- ===========================
-- Reset All RLS Policies
-- ===========================
-- File: db/06_reset_all_rls_policies.sql
-- Description: Xóa toàn bộ RLS policies và thiết lập lại từ đầu
--              với logic đơn giản, rõ ràng, tránh infinite recursion
-- Date: 2026-01-29
-- ===========================

-- ===========================
-- STEP 1: Xóa tất cả policies hiện tại
-- ===========================

-- Assignment related tables
DROP POLICY IF EXISTS "Admins have full access to assignments" ON assignments;
DROP POLICY IF EXISTS "Students can view assigned assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can create assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can delete own unpublished assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can update own assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can view own assignments" ON assignments;

DROP POLICY IF EXISTS "Admins have full access to assignment questions" ON assignment_questions;
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON assignment_questions;
DROP POLICY IF EXISTS "Teachers can manage questions in own assignments" ON assignment_questions;

DROP POLICY IF EXISTS "Admins have full access to assignment variants" ON assignment_variants;
DROP POLICY IF EXISTS "Students can view own variants" ON assignment_variants;
DROP POLICY IF EXISTS "Teachers can manage variants in own assignments" ON assignment_variants;

DROP POLICY IF EXISTS "Admins have full access to assignment distributions" ON assignment_distributions;
DROP POLICY IF EXISTS "Students can view distributions for assigned assignments" ON assignment_distributions;
DROP POLICY IF EXISTS "Teachers can manage distributions for own assignments" ON assignment_distributions;

-- Class related tables
DROP POLICY IF EXISTS "Admins full access classes" ON classes;
DROP POLICY IF EXISTS "Students view enrolled classes" ON classes;
DROP POLICY IF EXISTS "Teachers manage own classes" ON classes;

DROP POLICY IF EXISTS "Students view their class_members" ON class_members;
DROP POLICY IF EXISTS "Teachers manage class_members of own classes" ON class_members;

DROP POLICY IF EXISTS "Admins full access class_teachers" ON class_teachers;
DROP POLICY IF EXISTS "Main teacher manages class_teachers" ON class_teachers;

-- Group related tables
DROP POLICY IF EXISTS "Admins full access groups" ON groups;
DROP POLICY IF EXISTS "Students view groups they belong to" ON groups;
DROP POLICY IF EXISTS "Teachers manage groups of own classes" ON groups;

DROP POLICY IF EXISTS "Students view their group memberships" ON group_members;
DROP POLICY IF EXISTS "Teachers manage group_members of own classes" ON group_members;

-- Question related tables
DROP POLICY IF EXISTS "Admins have full access to questions" ON questions;
DROP POLICY IF EXISTS "Anyone can view public questions" ON questions;
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON questions;
DROP POLICY IF EXISTS "Teachers can delete own questions" ON questions;
DROP POLICY IF EXISTS "Teachers can insert own questions" ON questions;
DROP POLICY IF EXISTS "Teachers can update own questions" ON questions;
DROP POLICY IF EXISTS "Teachers can view own questions" ON questions;

DROP POLICY IF EXISTS "Admins have full access to question choices" ON question_choices;
DROP POLICY IF EXISTS "Anyone can view choices of public questions" ON question_choices;
DROP POLICY IF EXISTS "Question authors can manage choices" ON question_choices;
DROP POLICY IF EXISTS "Students can view choices in assigned assignments" ON question_choices;

DROP POLICY IF EXISTS "Admins have full access to question objectives" ON question_objectives;
DROP POLICY IF EXISTS "Anyone can view objectives of public questions" ON question_objectives;
DROP POLICY IF EXISTS "Question authors can manage objectives" ON question_objectives;

DROP POLICY IF EXISTS "Anyone can view learning objectives" ON learning_objectives;
DROP POLICY IF EXISTS "Teachers and admins can manage learning objectives" ON learning_objectives;

-- Profile and school tables
DROP POLICY IF EXISTS "read_own_profile" ON profiles;
DROP POLICY IF EXISTS "teacher_read_student_profiles" ON profiles;
DROP POLICY IF EXISTS "update_own_profile" ON profiles;
DROP POLICY IF EXISTS "admin_full_access_profiles" ON profiles;

DROP POLICY IF EXISTS "Admins full access schools" ON schools;
DROP POLICY IF EXISTS "Users view schools they are related to via classes" ON schools;

-- ===========================
-- STEP 2: Tạo helper functions với SECURITY DEFINER
-- ===========================

-- Function: Get user role (bypass RLS)
CREATE OR REPLACE FUNCTION public.get_user_role_safe(user_id UUID DEFAULT auth.uid())
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  user_role TEXT;
BEGIN
  SELECT role INTO user_role
  FROM profiles
  WHERE id = user_id
  LIMIT 1;
  
  RETURN COALESCE(user_role, 'student');
END;
$$;

-- Function: Check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'admin';
END;
$$;

-- Function: Check if user is teacher
CREATE OR REPLACE FUNCTION public.is_teacher(user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'teacher';
END;
$$;

-- Function: Check if teacher owns a class (bypass RLS)
CREATE OR REPLACE FUNCTION public.is_teacher_owner_of_class(
  teacher_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM classes c
    WHERE c.id = is_teacher_owner_of_class.class_id
      AND c.teacher_id = is_teacher_owner_of_class.teacher_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- Function: Check if student is in class (bypass RLS)
CREATE OR REPLACE FUNCTION public.is_student_in_class(
  student_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  result BOOLEAN;
BEGIN
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

-- Function: Check if student is in class (any status - bypass RLS)
CREATE OR REPLACE FUNCTION public.is_student_in_class_any_status(
  student_id UUID,
  class_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  result BOOLEAN;
BEGIN
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

-- Function: Check if student is in group (bypass RLS)
CREATE OR REPLACE FUNCTION public.is_student_in_group(
  student_id UUID,
  group_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  result BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM group_members gm
    WHERE gm.student_id = is_student_in_group.student_id
      AND gm.group_id = is_student_in_group.group_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;

-- Function: Check if teacher teaches student (bypass RLS)
CREATE OR REPLACE FUNCTION public.is_teacher_of_student_class(
  teacher_id UUID,
  student_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  result BOOLEAN;
BEGIN
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

-- ===========================
-- STEP 3: Tạo lại RLS Policies đơn giản
-- ===========================

-- ===========================
-- 3.1. Profiles
-- ===========================
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
TO public
USING (auth.uid() = id);

CREATE POLICY "Teachers can read student profiles in their classes"
ON profiles FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_of_student_class(auth.uid(), id)
);

CREATE POLICY "Admins can read all profiles"
ON profiles FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO public
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can update all profiles"
ON profiles FOR UPDATE
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.2. Classes
-- ===========================
CREATE POLICY "Teachers can view own classes"
ON classes FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), id)
);

CREATE POLICY "Students can view enrolled classes"
ON classes FOR SELECT
TO public
USING (
  public.is_student_in_class_any_status(auth.uid(), id)
);

CREATE POLICY "Admins can view all classes"
ON classes FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage own classes"
ON classes FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), id)
)
WITH CHECK (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), id)
);

CREATE POLICY "Admins can manage all classes"
ON classes FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.3. Class Members
-- ===========================
CREATE POLICY "Students can view own memberships"
ON class_members FOR SELECT
TO public
USING (student_id = auth.uid());

CREATE POLICY "Teachers can view members of own classes"
ON class_members FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
);

CREATE POLICY "Admins can view all class members"
ON class_members FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage members of own classes"
ON class_members FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
)
WITH CHECK (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
);

CREATE POLICY "Admins can manage all class members"
ON class_members FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.4. Assignments
-- ===========================
CREATE POLICY "Teachers can view own assignments"
ON assignments FOR SELECT
TO public
USING (teacher_id = auth.uid());

CREATE POLICY "Students can view assigned assignments"
ON assignments FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1
    FROM assignment_distributions ad
    WHERE ad.assignment_id = assignments.id
      AND assignments.is_published = true
      AND (
        (ad.distribution_type = 'class' 
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  )
);

CREATE POLICY "Admins can view all assignments"
ON assignments FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can create assignments"
ON assignments FOR INSERT
TO public
WITH CHECK (
  teacher_id = auth.uid()
  AND (
    class_id IS NULL
    OR public.is_teacher_owner_of_class(auth.uid(), class_id)
  )
);

CREATE POLICY "Admins can create assignments"
ON assignments FOR INSERT
TO public
WITH CHECK (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can update own assignments"
ON assignments FOR UPDATE
TO public
USING (teacher_id = auth.uid())
WITH CHECK (teacher_id = auth.uid());

CREATE POLICY "Admins can update all assignments"
ON assignments FOR UPDATE
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can delete own unpublished assignments"
ON assignments FOR DELETE
TO public
USING (
  teacher_id = auth.uid()
  AND is_published = false
);

CREATE POLICY "Admins can delete all assignments"
ON assignments FOR DELETE
TO public
USING (public.is_admin(auth.uid()));

-- ===========================
-- 3.5. Assignment Questions
-- ===========================
CREATE POLICY "Teachers can manage questions in own assignments"
ON assignment_questions FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_questions.assignment_id
      AND a.teacher_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_questions.assignment_id
      AND a.teacher_id = auth.uid()
  )
);

CREATE POLICY "Students can view questions in assigned assignments"
ON assignment_questions FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1
    FROM assignments a
    JOIN assignment_distributions ad ON ad.assignment_id = a.id
    WHERE a.id = assignment_questions.assignment_id
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class' 
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  )
);

CREATE POLICY "Admins can manage all assignment questions"
ON assignment_questions FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.6. Assignment Distributions
-- ===========================
CREATE POLICY "Teachers can manage distributions for own assignments"
ON assignment_distributions FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_distributions.assignment_id
      AND a.teacher_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_distributions.assignment_id
      AND a.teacher_id = auth.uid()
  )
);

CREATE POLICY "Students can view distributions for assigned assignments"
ON assignment_distributions FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_distributions.assignment_id
      AND a.is_published = true
      AND (
        (distribution_type = 'class'
          AND class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), class_id))
        OR
        (distribution_type = 'group'
          AND group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), group_id))
        OR
        (distribution_type = 'individual'
          AND auth.uid() = ANY(student_ids))
      )
      AND (available_from IS NULL OR available_from <= now())
  )
);

CREATE POLICY "Admins can manage all assignment distributions"
ON assignment_distributions FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.7. Assignment Variants
-- ===========================
CREATE POLICY "Teachers can manage variants in own assignments"
ON assignment_variants FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_variants.assignment_id
      AND a.teacher_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.id = assignment_variants.assignment_id
      AND a.teacher_id = auth.uid()
  )
);

CREATE POLICY "Students can view own variants"
ON assignment_variants FOR SELECT
TO public
USING (
  (variant_type = 'student' AND student_id = auth.uid())
  OR
  (variant_type = 'group' AND public.is_student_in_group(auth.uid(), group_id))
  OR
  (variant_type = 'global' AND EXISTS (
    SELECT 1
    FROM assignment_distributions ad
    JOIN assignments a ON a.id = ad.assignment_id
    WHERE ad.assignment_id = assignment_variants.assignment_id
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class'
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
  ))
);

CREATE POLICY "Admins can manage all assignment variants"
ON assignment_variants FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.8. Questions
-- ===========================
CREATE POLICY "Teachers can view own questions"
ON questions FOR SELECT
TO public
USING (author_id = auth.uid());

CREATE POLICY "Anyone can view public questions"
ON questions FOR SELECT
TO public
USING (is_public = true);

CREATE POLICY "Students can view questions in assigned assignments"
ON questions FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1
    FROM assignment_questions aq
    JOIN assignments a ON a.id = aq.assignment_id
    JOIN assignment_distributions ad ON ad.assignment_id = a.id
    WHERE aq.question_id = questions.id
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class'
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  )
);

CREATE POLICY "Admins can view all questions"
ON questions FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage own questions"
ON questions FOR ALL
TO public
USING (author_id = auth.uid())
WITH CHECK (author_id = auth.uid());

CREATE POLICY "Admins can manage all questions"
ON questions FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.9. Question Choices
-- ===========================
CREATE POLICY "Anyone can view choices of public questions"
ON question_choices FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_choices.question_id
      AND q.is_public = true
  )
);

CREATE POLICY "Teachers can view choices of own questions"
ON question_choices FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_choices.question_id
      AND q.author_id = auth.uid()
  )
);

CREATE POLICY "Students can view choices in assigned assignments"
ON question_choices FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1
    FROM questions q
    JOIN assignment_questions aq ON aq.question_id = q.id
    JOIN assignments a ON a.id = aq.assignment_id
    JOIN assignment_distributions ad ON ad.assignment_id = a.id
    WHERE q.id = question_choices.question_id
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class'
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(auth.uid(), ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(auth.uid(), ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND auth.uid() = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  )
);

CREATE POLICY "Admins can view all question choices"
ON question_choices FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage choices of own questions"
ON question_choices FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_choices.question_id
      AND q.author_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_choices.question_id
      AND q.author_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all question choices"
ON question_choices FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.10. Question Objectives
-- ===========================
CREATE POLICY "Anyone can view objectives of public questions"
ON question_objectives FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_objectives.question_id
      AND q.is_public = true
  )
);

CREATE POLICY "Teachers can manage objectives of own questions"
ON question_objectives FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_objectives.question_id
      AND q.author_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM questions q
    WHERE q.id = question_objectives.question_id
      AND q.author_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all question objectives"
ON question_objectives FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.11. Learning Objectives
-- ===========================
CREATE POLICY "Anyone can view learning objectives"
ON learning_objectives FOR SELECT
TO public
USING (true);

CREATE POLICY "Teachers and admins can manage learning objectives"
ON learning_objectives FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  OR public.is_admin(auth.uid())
)
WITH CHECK (
  public.is_teacher(auth.uid())
  OR public.is_admin(auth.uid())
);

-- ===========================
-- 3.12. Groups
-- ===========================
CREATE POLICY "Teachers can view groups of own classes"
ON groups FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
);

CREATE POLICY "Students can view groups they belong to"
ON groups FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM group_members gm
    WHERE gm.group_id = groups.id
      AND gm.student_id = auth.uid()
  )
);

CREATE POLICY "Admins can view all groups"
ON groups FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage groups of own classes"
ON groups FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
)
WITH CHECK (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
);

CREATE POLICY "Admins can manage all groups"
ON groups FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.13. Group Members
-- ===========================
CREATE POLICY "Students can view own group memberships"
ON group_members FOR SELECT
TO public
USING (student_id = auth.uid());

CREATE POLICY "Teachers can view members of groups in own classes"
ON group_members FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
      AND public.is_teacher_owner_of_class(auth.uid(), g.class_id)
  )
);

CREATE POLICY "Admins can view all group members"
ON group_members FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Teachers can manage members of groups in own classes"
ON group_members FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  AND EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
      AND public.is_teacher_owner_of_class(auth.uid(), g.class_id)
  )
)
WITH CHECK (
  public.is_teacher(auth.uid())
  AND EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
      AND public.is_teacher_owner_of_class(auth.uid(), g.class_id)
  )
);

CREATE POLICY "Admins can manage all group members"
ON group_members FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.14. Class Teachers
-- ===========================
CREATE POLICY "Main teacher can manage class teachers"
ON class_teachers FOR ALL
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
)
WITH CHECK (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
);

CREATE POLICY "Admins can manage all class teachers"
ON class_teachers FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- 3.15. Schools
-- ===========================
CREATE POLICY "Users can view schools they are related to"
ON schools FOR SELECT
TO public
USING (
  EXISTS (
    SELECT 1 FROM classes c
    WHERE c.school_id = schools.id
      AND (
        c.teacher_id = auth.uid()
        OR public.is_student_in_class_any_status(auth.uid(), c.id)
      )
  )
);

CREATE POLICY "Admins can view all schools"
ON schools FOR SELECT
TO public
USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage all schools"
ON schools FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- Comments
-- ===========================
COMMENT ON FUNCTION public.get_user_role_safe(UUID) IS 
'Get user role bypassing RLS to prevent infinite recursion.';

COMMENT ON FUNCTION public.is_admin(UUID) IS 
'Check if user is admin. Bypasses RLS.';

COMMENT ON FUNCTION public.is_teacher(UUID) IS 
'Check if user is teacher. Bypasses RLS.';

COMMENT ON FUNCTION public.is_teacher_owner_of_class(UUID, UUID) IS 
'Check if teacher owns a class. Bypasses RLS.';

COMMENT ON FUNCTION public.is_student_in_class(UUID, UUID) IS 
'Check if student is approved member of a class. Bypasses RLS.';

COMMENT ON FUNCTION public.is_student_in_class_any_status(UUID, UUID) IS 
'Check if student is member of a class (pending or approved). Bypasses RLS.';

COMMENT ON FUNCTION public.is_student_in_group(UUID, UUID) IS 
'Check if student is member of a group. Bypasses RLS.';

COMMENT ON FUNCTION public.is_teacher_of_student_class(UUID, UUID) IS 
'Check if teacher teaches a class where student is member. Bypasses RLS.';

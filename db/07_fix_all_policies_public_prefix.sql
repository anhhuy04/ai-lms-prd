-- ===========================
-- Fix All Policies - Add public. prefix
-- ===========================
-- File: db/07_fix_all_policies_public_prefix.sql
-- Description: Fix tất cả policies thiếu public. prefix cho functions
-- Date: 2026-01-29
-- ===========================

-- Note: PostgreSQL có thể tự động resolve functions nếu search_path đúng,
-- nhưng để chắc chắn và tránh lỗi, chúng ta sẽ thêm public. prefix rõ ràng

-- ===========================
-- Classes
-- ===========================
DROP POLICY IF EXISTS "Teachers can view own classes" ON classes;
DROP POLICY IF EXISTS "Students can view enrolled classes" ON classes;
DROP POLICY IF EXISTS "Admins can view all classes" ON classes;
DROP POLICY IF EXISTS "Teachers can manage own classes" ON classes;
DROP POLICY IF EXISTS "Admins can manage all classes" ON classes;

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
-- Class Members
-- ===========================
DROP POLICY IF EXISTS "Teachers can view members of own classes" ON class_members;
DROP POLICY IF EXISTS "Admins can view all class members" ON class_members;
DROP POLICY IF EXISTS "Teachers can manage members of own classes" ON class_members;
DROP POLICY IF EXISTS "Admins can manage all class members" ON class_members;

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
-- Assignments (chỉ fix các policies có functions)
-- ===========================
DROP POLICY IF EXISTS "Students can view assigned assignments" ON assignments;
DROP POLICY IF EXISTS "Admins can view all assignments" ON assignments;
DROP POLICY IF EXISTS "Teachers can create assignments" ON assignments;
DROP POLICY IF EXISTS "Admins can create assignments" ON assignments;
DROP POLICY IF EXISTS "Admins can update all assignments" ON assignments;
DROP POLICY IF EXISTS "Admins can delete all assignments" ON assignments;

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

CREATE POLICY "Admins can update all assignments"
ON assignments FOR UPDATE
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

CREATE POLICY "Admins can delete all assignments"
ON assignments FOR DELETE
TO public
USING (public.is_admin(auth.uid()));

-- ===========================
-- Assignment Questions
-- ===========================
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON assignment_questions;
DROP POLICY IF EXISTS "Admins can manage all assignment questions" ON assignment_questions;

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
-- Assignment Distributions
-- ===========================
DROP POLICY IF EXISTS "Students can view distributions for assigned assignments" ON assignment_distributions;
DROP POLICY IF EXISTS "Admins can manage all assignment distributions" ON assignment_distributions;

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
-- Assignment Variants
-- ===========================
DROP POLICY IF EXISTS "Students can view own variants" ON assignment_variants;
DROP POLICY IF EXISTS "Admins can manage all assignment variants" ON assignment_variants;

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
-- Questions
-- ===========================
DROP POLICY IF EXISTS "Students can view questions in assigned assignments" ON questions;
DROP POLICY IF EXISTS "Admins can view all questions" ON questions;
DROP POLICY IF EXISTS "Admins can manage all questions" ON questions;

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

CREATE POLICY "Admins can manage all questions"
ON questions FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- Question Choices
-- ===========================
DROP POLICY IF EXISTS "Students can view choices in assigned assignments" ON question_choices;
DROP POLICY IF EXISTS "Admins can view all question choices" ON question_choices;
DROP POLICY IF EXISTS "Admins can manage all question choices" ON question_choices;

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

CREATE POLICY "Admins can manage all question choices"
ON question_choices FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- Question Objectives
-- ===========================
DROP POLICY IF EXISTS "Admins can manage all question objectives" ON question_objectives;

CREATE POLICY "Admins can manage all question objectives"
ON question_objectives FOR ALL
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

-- ===========================
-- Learning Objectives
-- ===========================
DROP POLICY IF EXISTS "Teachers and admins can manage learning objectives" ON learning_objectives;

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
-- Groups
-- ===========================
DROP POLICY IF EXISTS "Teachers can view groups of own classes" ON groups;
DROP POLICY IF EXISTS "Admins can view all groups" ON groups;
DROP POLICY IF EXISTS "Teachers can manage groups of own classes" ON groups;
DROP POLICY IF EXISTS "Admins can manage all groups" ON groups;

CREATE POLICY "Teachers can view groups of own classes"
ON groups FOR SELECT
TO public
USING (
  public.is_teacher(auth.uid())
  AND public.is_teacher_owner_of_class(auth.uid(), class_id)
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
-- Group Members
-- ===========================
DROP POLICY IF EXISTS "Teachers can view members of groups in own classes" ON group_members;
DROP POLICY IF EXISTS "Admins can view all group members" ON group_members;
DROP POLICY IF EXISTS "Teachers can manage members of groups in own classes" ON group_members;
DROP POLICY IF EXISTS "Admins can manage all group members" ON group_members;

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
-- Class Teachers
-- ===========================
DROP POLICY IF EXISTS "Main teacher can manage class teachers" ON class_teachers;
DROP POLICY IF EXISTS "Admins can manage all class teachers" ON class_teachers;

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
-- Schools
-- ===========================
DROP POLICY IF EXISTS "Users can view schools they are related to" ON schools;
DROP POLICY IF EXISTS "Admins can view all schools" ON schools;
DROP POLICY IF EXISTS "Admins can manage all schools" ON schools;

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
-- Profiles
-- ===========================
DROP POLICY IF EXISTS "Teachers can read student profiles in their classes" ON profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;

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

CREATE POLICY "Admins can update all profiles"
ON profiles FOR UPDATE
TO public
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

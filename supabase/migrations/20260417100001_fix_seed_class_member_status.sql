-- Fix: Update class_members status sang 'approved' cho hs1@gmail.com
-- (Seed P08 đã chạy nhưng dùng DO NOTHING nên status vẫn là 'pending' nếu row đã có)
DO $$
DECLARE
  v_student_id UUID;
BEGIN
  SELECT id INTO v_student_id FROM auth.users WHERE email = 'hs1@gmail.com' LIMIT 1;
  IF v_student_id IS NOT NULL THEN
    UPDATE class_members
    SET status = 'approved'
    WHERE student_id = v_student_id
      AND status != 'approved';
    RAISE NOTICE 'Updated class_members status to approved for hs1@gmail.com (id=%)', v_student_id;
  ELSE
    RAISE NOTICE 'hs1@gmail.com not found, skipping';
  END IF;
END $$;

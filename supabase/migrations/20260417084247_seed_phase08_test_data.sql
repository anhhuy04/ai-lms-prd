-- SEED: Phase 08 Test Data (inline questions via custom_content, no question bank needed)
DO $$
DECLARE
  v_teacher_id    UUID;
  v_student_id    UUID;
  v_class_id      UUID;
  v_assignment_id UUID;
  v_dist_id       UUID;
BEGIN
  SELECT id INTO v_teacher_id FROM auth.users WHERE email = 'ha@gmail.com'  LIMIT 1;
  SELECT id INTO v_student_id  FROM auth.users WHERE email = 'hs1@gmail.com' LIMIT 1;
  IF v_teacher_id IS NULL THEN RAISE EXCEPTION 'No ha@gmail.com'; END IF;
  IF v_student_id  IS NULL THEN RAISE EXCEPTION 'No hs1@gmail.com'; END IF;

  SELECT id INTO v_class_id FROM classes WHERE teacher_id = v_teacher_id ORDER BY created_at DESC LIMIT 1;
  IF v_class_id IS NULL THEN
    INSERT INTO classes (teacher_id, name, subject, created_at, updated_at)
    VALUES (v_teacher_id, 'Lop Test P08', 'Tong hop', NOW(), NOW())
    RETURNING id INTO v_class_id;
  END IF;

  INSERT INTO class_members (class_id, student_id, joined_at, status)
  VALUES (v_class_id, v_student_id, NOW(), 'approved')
  ON CONFLICT (class_id, student_id) DO UPDATE SET status = 'approved';

  -- Assignment (published, shuffle ON)
  INSERT INTO assignments (teacher_id, class_id, title, description,
    is_published, total_points, default_shuffle_questions, default_shuffle_choices,
    created_at, updated_at)
  VALUES (v_teacher_id, v_class_id, '[TEST-P08] Shuffle & Hotfix Test',
    'Phase08: shuffle, hotfix, clone', true, 30, true, true, NOW(), NOW())
  RETURNING id INTO v_assignment_id;

  -- 3 inline questions via custom_content (no question bank link, question_id=NULL)
  INSERT INTO assignment_questions (assignment_id, question_id, custom_content, points, order_idx)
  VALUES
  (v_assignment_id, NULL,
   '{"type":"multiple_choice","text":"Nam VN gianh doc lap la nam nao?","choices":[{"id":0,"text":"1954","isCorrect":false},{"id":1,"text":"1945","isCorrect":true},{"id":2,"text":"1975","isCorrect":false},{"id":3,"text":"1930","isCorrect":false}]}'::jsonb,
   10, 1),
  (v_assignment_id, NULL,
   '{"type":"multiple_choice","text":"7 x 8 bang bao nhieu?","choices":[{"id":0,"text":"48","isCorrect":false},{"id":1,"text":"54","isCorrect":false},{"id":2,"text":"56","isCorrect":true},{"id":3,"text":"64","isCorrect":false}]}'::jsonb,
   10, 2),
  (v_assignment_id, NULL,
   '{"type":"multiple_choice","text":"Nguyen to O la gi?","choices":[{"id":0,"text":"Oxy","isCorrect":true},{"id":1,"text":"Vang","isCorrect":false},{"id":2,"text":"Sat","isCorrect":false},{"id":3,"text":"Hydro","isCorrect":false}]}'::jsonb,
   10, 3);

  -- Distribute (class type, 7 days)
  INSERT INTO assignment_distributions (assignment_id, class_id, distribution_type,
    available_from, due_at, allow_late)
  VALUES (v_assignment_id, v_class_id, 'class',
    NOW(), NOW() + INTERVAL '7 days', false)
  RETURNING id INTO v_dist_id;

  RAISE NOTICE '=== SEED OK ===';
  RAISE NOTICE 'Teacher   : % (ha@gmail.com)', v_teacher_id;
  RAISE NOTICE 'Student   : % (hs1@gmail.com)', v_student_id;
  RAISE NOTICE 'Class     : %', v_class_id;
  RAISE NOTICE 'Assignment: %', v_assignment_id;
  RAISE NOTICE 'Distrib   : %', v_dist_id;
  RAISE NOTICE '[1] SHUFFLE : login hs1 → open bai → thu tu xao';
  RAISE NOTICE '[2] HOTFIX  : login ha → icon cam Q2 → doi dap an → Luu';
  RAISE NOTICE '[3] REGRADE : bam Cham lai tat ca';
  RAISE NOTICE '[4] CLONE   : bam Nhan ban';
  RAISE NOTICE '[5] DIST    : bam Giao lop khac';
END $$;

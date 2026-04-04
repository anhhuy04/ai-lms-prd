-- SEED: Phase 05 - Test data for ai_recommendations
-- IDs: teacher=d810df06-78c5-441c-8eaf-90e6e505adad, student=076de02d-75ba-4e79-898d-1b5e43141894, class=1872e253-05cd-4635-a4ec-cf8195fb3f0a
DO $$
DECLARE
  v_teacher_id UUID := 'd810df06-78c5-441c-8eaf-90e6e505adad';
  v_student_id UUID := '076de02d-75ba-4e79-898d-1b5e43141894';
  v_class_id UUID := '1872e253-05cd-4635-a4ec-cf8195fb3f0a';
BEGIN

-- Xoa test data cu neu co
DELETE FROM public.ai_recommendations WHERE title LIKE 'TEST:%';

-- TEACHER RECOMMENDATIONS (REC-01)

-- 1: High priority - Student at risk (priority=1)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 1,
  'TEST: Học sinh cần hỗ trợ khẩn',
  'Học sinh có 3 bài tập liên tiếp điểm thấp dưới trung bình. Cần liên hệ phụ huynh.',
  '{"exercises": ["ex1"], "videos": [], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '1 day');

-- 2: High priority - Engagement alert (priority=2)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 2,
  'TEST: Em nghỉ học 5 buổi liên tiếp',
  'Học sinh có tỷ lệ tham gia dưới 70%. Cần kiểm tra và liên hệ gia đình.',
  '{"exercises": [], "videos": ["https://youtube.com"], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '2 days');

-- 3: Medium priority - Assignment suggestion (priority=3)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 3,
  'TEST: Gợi ý bài ôn tập Hình học',
  'Học sinh có điểm yếu ở phần Hình học không gian.',
  '{"exercises": ["ex2", "ex3"], "videos": [], "documents": ["https://docs.google.com"]}'::jsonb,
  false, NOW() - INTERVAL '3 days');

-- 4: Low priority - Improvement opportunity (priority=4)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 4,
  'TEST: Cơ hội cải thiện cho học sinh',
  'Học sinh có tiến bộ rõ rệt. Có thể giao bài nâng cao.',
  '{"exercises": ["ex4"], "videos": [], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '5 days');

-- 5: Low priority - Skill gap (priority=5)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 5,
  'TEST: Cần ôn luyện Đại số',
  'Kết quả kiểm tra cho thấy chưa nắm vững Phương trình bậc 2.',
  '{"exercises": ["ex5"], "videos": ["https://youtube.com"], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '7 days');

-- 6: Already dismissed (test dismiss)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 2,
  'TEST: [DA_AN] Bài đã được giải quyết',
  'Bài tập đã được xử lý.',
  '{"exercises": [], "videos": [], "documents": []}'::jsonb,
  true, NOW() - INTERVAL '10 days');

-- 7: Class-level (no specific student)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, NULL, 'class', 3,
  'TEST: Lớp cần ôn tập trước kỳ thi',
  '20/35 học sinh có điểm dưới trung bình.',
  '{"exercises": ["ex6"], "videos": [], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '4 days');

-- 8: Small group
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, NULL, 'small_group', 2,
  'TEST: 5 học sinh nhóm Yếu cần bổ trợ',
  'Nhóm 5 học sinh có điểm thấp nhất lớp.',
  '{"exercises": [], "videos": [], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '6 days');

-- STUDENT RECOMMENDATIONS (REC-02)
INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 2,
  'TEST: Bạn cần ôn Hình học không gian',
  'Kết quả học tập gần đây cho thấy cần củng cố Hình học.',
  '{"exercises": ["ex7"], "videos": ["https://youtube.com"], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '1 day');

INSERT INTO public.ai_recommendations (teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES (v_teacher_id, v_class_id, v_student_id, 'individual', 3,
  'TEST: Bài tập Đại số được gợi ý',
  'Hệ thống gợi ý bài ôn tập phù hợp với năng lực của bạn.',
  '{"exercises": ["ex8", "ex9"], "videos": [], "documents": []}'::jsonb,
  false, NOW() - INTERVAL '2 days');

END $$;

-- Cleanup sau test:
-- DELETE FROM public.ai_recommendations WHERE title LIKE 'TEST:%';

-- ============================================
-- SQL Cleanup Script for Assignment Testing
-- Xóa dữ liệu test để test lại từ đầu
-- ============================================

-- Thứ tự xóa: Xóa theo chiều dependent → independent (FK constraint)

-- 1. Xóa AI queue (phụ thuộc submissions)
DELETE FROM public.ai_queue;

-- 2. Xóa submission_answers (phụ thuộc submissions)
DELETE FROM public.submission_answers;

-- 3. Xóa submissions
DELETE FROM public.submissions;

-- 4. Xóa autosave_answers (phụ thuộc work_sessions)
DELETE FROM public.autosave_answers;

-- 5. Xóa work_sessions (phụ thuộc assignment_distributions)
DELETE FROM public.work_sessions;

-- 6. Xóa assignment_questions (phụ thuộc assignments & questions)
-- Lưu ý: Chỉ xóa những câu hỏi thuộc assignment cụ thể nếu cần
-- DELETE FROM public.assignment_questions WHERE assignment_id = 'YOUR_ASSIGNMENT_ID';

-- 7. Xóa assignment_distributions (phụ thuộc assignments)
-- Lưu ý: Chỉ xóa những bản phân phối cụ thể nếu cần
-- DELETE FROM public.assignment_distributions WHERE assignment_id = 'YOUR_ASSIGNMENT_ID';

-- 8. Xóa assignments (nếu muốn xóa luôn bài tập test)
-- DELETE FROM public.assignments WHERE id = 'YOUR_ASSIGNMENT_ID';

-- ============================================
-- Verify: Kiểm tra dữ liệu còn lại
-- ============================================
SELECT 'work_sessions' as table_name, COUNT(*) as count FROM public.work_sessions
UNION ALL
SELECT 'autosave_answers', COUNT(*) FROM public.autosave_answers
UNION ALL
SELECT 'submissions', COUNT(*) FROM public.submissions
UNION ALL
SELECT 'submission_answers', COUNT(*) FROM public.submission_answers
UNION ALL
SELECT 'ai_queue', COUNT(*) FROM public.ai_queue;

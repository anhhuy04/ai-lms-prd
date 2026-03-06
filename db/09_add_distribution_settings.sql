-- =====================================================
-- Migration: Thêm cột settings vào assignment_distributions
-- Mục đích: Lưu cấu hình shuffle (đảo câu hỏi, đảo đáp án, hiển thị điểm ngay)
-- Ngày: 2024-02-24
-- =====================================================

-- Thêm cột settings dạng JSONB vào bảng assignment_distributions
ALTER TABLE public.assignment_distributions
ADD COLUMN IF NOT EXISTS settings jsonb DEFAULT '{"shuffle_questions": false, "shuffle_choices": false, "show_score_immediately": true}';

-- Cập nhật comment để giải thích mục đích
COMMENT ON COLUMN public.assignment_distributions.settings IS 'Cấu hình bài tập: shuffle_questions, shuffle_choices (đảo đáp án), show_score_immediately (hiển thị điểm ngay)';

-- =====================================================
-- Migration: Đảm bảo custom_questions trong assignment_variants đúng format
-- =====================================================

-- Tạo index để tăng performance khi query theo student_id
CREATE INDEX IF NOT EXISTS idx_assignment_variants_student
ON public.assignment_variants(student_id)
WHERE variant_type = 'student';

-- Tạo index để tăng performance khi query theo group_id
CREATE INDEX IF NOT EXISTS idx_assignment_variants_group
ON public.assignment_variants(group_id)
WHERE variant_type = 'group';

-- =====================================================
-- Migration: Thêm shuffle_settings vào assignments (bảng gốc - optional)
-- Dùng cho preview/soạn thảo, KHÔNG dùng khi phân phối
-- =====================================================

ALTER TABLE public.assignments
ADD COLUMN IF NOT EXISTS default_shuffle_questions boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS default_shuffle_choices boolean DEFAULT false;

COMMENT ON COLUMN public.assignments.default_shuffle_questions IS 'Cấu hình mặc định: có nên đảo câu hỏi khi phân phối không';
COMMENT ON COLUMN public.assignments.default_shuffle_choices IS 'Cấu hình mặc định: có nên đảo đáp án khi phân phối không';

-- =====================================================
-- Verification: Kiểm tra các cột đã được thêm
-- =====================================================

SELECT
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'assignment_distributions'
AND column_name IN ('settings', 'shuffle_questions', 'shuffle_answers', 'show_score_immediately')
ORDER BY column_name;

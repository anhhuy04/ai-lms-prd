-- ===========================
-- Migration: Refactor Groups for Cross-class Support
-- Date: 2026-02-24
-- ===========================

-- 1. Cho phép class_id của bảng groups được phép NULL (hỗ trợ nhóm liên lớp)
ALTER TABLE public.groups ALTER COLUMN class_id DROP NOT NULL;

-- 2. Thêm cột teacher_id để quản lý sở hữu nhóm (thay vì phụ thuộc hoàn toàn vào class_id)
-- Liên kết với auth.users
ALTER TABLE public.groups ADD COLUMN teacher_id uuid REFERENCES auth.users;

-- (Tùy chọn) Chuyển data cũ: Nếu hệ thống đã có data groups, ta nên cập nhật teacher_id từ classes trước khi thiết lập NOT NULL
-- UPDATE public.groups g
-- SET teacher_id = c.teacher_id
-- FROM public.classes c
-- WHERE g.class_id = c.id;

-- 3. Thiết lập NOT NULL cho teacher_id (Bỏ comment sau khi đã update data cũ nếu đã deploy chạy thực tế)
-- ALTER TABLE public.groups ALTER COLUMN teacher_id SET NOT NULL;

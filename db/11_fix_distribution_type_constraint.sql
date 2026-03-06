-- ===========================
-- Migration: Fix distribution_type constraint
-- File: db/11_fix_distribution_type_constraint.sql
-- Description: Cho phép class_id tồn tại song song với group_id/student_ids
--              để giữ context "HS thuộc lớp nào" cho mọi distribution type.
-- Date: 2026-02-25
-- ===========================

-- ============================================================
-- 1. Drop constraint cũ (XOR: mỗi type chỉ cho phép 1 field)
-- ============================================================
ALTER TABLE public.assignment_distributions
DROP CONSTRAINT IF EXISTS check_distribution_type_match;

-- ============================================================
-- 2. Tạo constraint mới: class_id là anchor cho tất cả types
--    - 'class':      class_id required, group_id NULL, student_ids NULL
--    - 'group':       class_id required, group_id required, student_ids NULL
--    - 'individual':  class_id required, student_ids required (>0), group_id NULL
-- ============================================================
ALTER TABLE public.assignment_distributions
ADD CONSTRAINT check_distribution_type_match CHECK (
  (distribution_type = 'class'
    AND class_id IS NOT NULL
    AND group_id IS NULL
    AND student_ids IS NULL)
  OR (distribution_type = 'group'
    AND class_id IS NOT NULL
    AND group_id IS NOT NULL
    AND student_ids IS NULL)
  OR (distribution_type = 'individual'
    AND class_id IS NOT NULL
    AND student_ids IS NOT NULL
    AND array_length(student_ids, 1) > 0
    AND group_id IS NULL)
);

-- ============================================================
-- 3. Thêm comment giải thích thiết kế mới
-- ============================================================
COMMENT ON CONSTRAINT check_distribution_type_match
  ON public.assignment_distributions
  IS 'class_id luôn required (context). group_id chỉ cho type group. student_ids chỉ cho type individual.';

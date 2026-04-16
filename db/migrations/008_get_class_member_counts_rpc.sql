-- RPC: get_class_member_counts
-- Trả về số học sinh đã duyệt (approved) cho danh sách class_ids.
-- SECURITY DEFINER để bypass RLS — an toàn vì chỉ trả về count, không expose records cá nhân.
-- Học sinh dùng hàm này để hiển thị sĩ số lớp mà không cần quyền đọc class_members của người khác.

CREATE OR REPLACE FUNCTION public.get_class_member_counts(p_class_ids uuid[])
RETURNS TABLE(class_id uuid, member_count bigint)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT cm.class_id, COUNT(*)::bigint AS member_count
  FROM class_members cm
  WHERE cm.class_id = ANY(p_class_ids)
    AND cm.status = 'approved'
  GROUP BY cm.class_id;
$$;

-- Chỉ cho phép authenticated users gọi hàm này
REVOKE ALL ON FUNCTION public.get_class_member_counts(uuid[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_class_member_counts(uuid[]) TO authenticated;

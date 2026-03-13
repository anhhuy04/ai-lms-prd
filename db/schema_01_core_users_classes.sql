-- ==============================================================================
-- AI LMS - SCHEMA PHASE 1: CORE (Users, Schools, Classes, Groups)
-- Cập nhật: 2026-03-12 (đồng bộ từ Supabase production)
-- ==============================================================================

-- ═══ 1. PROFILES ═══
-- Hồ sơ người dùng, tự động tạo khi auth.users insert (trigger)
-- Link 1-1 với auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id),  -- ID = auth.users.id
  full_name   text,                                         -- Họ tên đầy đủ
  role        text DEFAULT 'student'                        -- Vai trò: 'teacher' | 'student' | 'admin'
              CHECK (role IN ('teacher', 'student', 'admin')),
  avatar_url  text,                                         -- URL ảnh đại diện (Supabase Storage)
  bio         text,                                         -- Giới thiệu ngắn
  phone       text,                                         -- Số điện thoại
  gender      text                                          -- Giới tính: 'male' | 'female' | 'other'
              CHECK (gender IN ('male', 'female', 'other')),
  metadata    jsonb,                                        -- Metadata mở rộng (xem mẫu bên dưới)
  updated_at  timestamptz DEFAULT now()
);
-- JSONB: profiles.metadata
-- Chưa có dữ liệu mẫu. Dự kiến:
-- {
--   "preferences": { "theme": "dark", "language": "vi" },
--   "school_info": { "student_code": "HS001", "class_name": "10A1" }
-- }


-- ═══ 2. SCHOOLS ═══
-- Trường học - container cấp cao nhất
CREATE TABLE IF NOT EXISTS public.schools (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,                                -- Tên trường
  domain      text UNIQUE,                                  -- Domain email (vd: "school.edu.vn") - dùng cho auto-assign
  metadata    jsonb,                                        -- Thông tin mở rộng về trường
  created_at  timestamptz DEFAULT now()
);
-- JSONB: schools.metadata
-- Chưa có dữ liệu mẫu. Dự kiến:
-- {
--   "address": "123 Đường ABC, TP.HCM",
--   "phone": "028-1234-5678",
--   "logo_url": "https://..."
-- }


-- ═══ 3. CLASSES ═══
-- Lớp học - đơn vị quản lý chính
CREATE TABLE IF NOT EXISTS public.classes (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id       uuid REFERENCES public.schools(id),       -- Thuộc trường nào (nullable = lớp độc lập)
  teacher_id      uuid NOT NULL REFERENCES auth.users(id),  -- Giáo viên chủ nhiệm / tạo lớp
  name            text NOT NULL,                             -- Tên lớp (vd: "Toán 10A1")
  subject         text,                                      -- Môn học
  academic_year   text,                                      -- Năm học (vd: "2025-2026")
  description     text,                                      -- Mô tả lớp
  class_settings  jsonb,                                     -- Cấu hình lớp (xem mẫu chi tiết bên dưới)
  created_at      timestamptz DEFAULT now()
);
-- JSONB: classes.class_settings
-- Default value từ DB:
-- {
--   "defaults": {
--     "lock_class": false              -- Khóa lớp (không cho thêm/bớt HS)
--   },
--   "enrollment": {
--     "qr_code": {
--       "is_active": false,            -- QR code có đang hoạt động không
--       "join_code": null,             -- Mã tham gia lớp (string)
--       "expires_at": null,            -- Thời hạn QR code
--       "require_approval": true       -- Cần GV phê duyệt khi HS quét QR
--     },
--     "manual_join_limit": null        -- Giới hạn số HS tham gia (null = không giới hạn)
--   },
--   "group_management": {
--     "lock_groups": false,            -- Khóa nhóm (không cho thay đổi)
--     "allow_student_switch": false,   -- Cho phép HS tự chuyển nhóm
--     "is_visible_to_students": true   -- HS có thể nhìn thấy nhóm
--   },
--   "student_permissions": {
--     "auto_lock_on_submission": false, -- Tự khóa HS sau khi nộp bài
--     "can_edit_profile_in_class": true -- HS có thể sửa profile trong lớp
--   }
-- }


-- ═══ 4. CLASS_MEMBERS ═══
-- Danh sách học sinh trong lớp (bảng nối N-N)
CREATE TABLE IF NOT EXISTS public.class_members (
  class_id    uuid NOT NULL REFERENCES public.classes(id),
  student_id  uuid NOT NULL REFERENCES auth.users(id),
  role        text DEFAULT 'student',                        -- Vai trò trong lớp
  joined_at   timestamptz DEFAULT now(),                     -- Thời điểm tham gia
  status      text DEFAULT 'pending'                         -- Trạng thái: 'pending' | 'approved' | 'rejected'
              CHECK (status IN ('pending', 'approved', 'rejected')),
  PRIMARY KEY (class_id, student_id)
);


-- ═══ 5. CLASS_TEACHERS ═══
-- Giáo viên phụ trách lớp (hỗ trợ nhiều GV/lớp)
CREATE TABLE IF NOT EXISTS public.class_teachers (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id    uuid REFERENCES public.classes(id),
  teacher_id  uuid REFERENCES auth.users(id),
  role        text DEFAULT 'teacher'                         -- 'teacher' | 'assistant' (trợ giảng)
);


-- ═══ 6. GROUPS ═══
-- Nhóm học sinh trong lớp (dùng cho phân phối bài tập theo nhóm)
CREATE TABLE IF NOT EXISTS public.groups (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id    uuid REFERENCES public.classes(id),            -- Thuộc lớp nào
  teacher_id  uuid REFERENCES auth.users(id),                -- GV tạo nhóm (legacy, nên dùng class_id)
  name        text NOT NULL,                                  -- Tên nhóm
  description text,
  created_at  timestamptz DEFAULT now()
);


-- ═══ 7. GROUP_MEMBERS ═══
-- Thành viên trong nhóm
CREATE TABLE IF NOT EXISTS public.group_members (
  group_id    uuid NOT NULL REFERENCES public.groups(id),
  student_id  uuid NOT NULL REFERENCES public.profiles(id),  -- FK → profiles (không phải auth.users)
  role        text DEFAULT 'member',                          -- 'member' | 'leader'
  enrolled_by uuid REFERENCES auth.users(id),                 -- Ai thêm vào nhóm
  joined_at   timestamptz DEFAULT now(),
  PRIMARY KEY (group_id, student_id)
);

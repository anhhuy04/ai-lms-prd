# Tổng Hợp Schema Database - AI LMS

**Ngày tạo:** 2026-01-15  
**Nguồn:** Supabase MCP Server - Schema `public`

---

## Tổng Quan

Database hiện tại có **7 bảng** đã được tạo trong schema `public`. Các bảng này tập trung vào quản lý tổ chức và lớp học cơ bản.

### Trạng thái Database
- **Bảng đã tạo:** 7/30+ (theo thiết kế trong README_SUPABASE.md)
- **RLS Policies:** Chưa được bật (rls_enabled: false)
- **Extensions:** pgcrypto, pg_net, uuid-ossp (theo README_SUPABASE.md)

---

## Chi Tiết Các Bảng

### 1. **profiles** - Hồ sơ người dùng
**Mục đích:** Lưu thông tin profile của người dùng, liên kết với auth.users

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `id` | uuid | NO | - | Primary key, FK → auth.users.id |
| `full_name` | text | YES | - | Tên đầy đủ |
| `role` | text | YES | 'student' | Vai trò: 'teacher', 'student', 'admin' (check constraint) |
| `avatar_url` | text | YES | - | URL ảnh đại diện |
| `bio` | text | YES | - | Tiểu sử |
| `metadata` | jsonb | YES | - | Dữ liệu metadata bổ sung |
| `updated_at` | timestamptz | YES | now() | Thời gian cập nhật |
| `phone` | text | YES | - | Số điện thoại |
| `gender` | text | YES | - | Giới tính: 'male', 'female', 'other' (check constraint) |

**Ràng buộc:**
- Primary key: `id`
- Foreign key: `id` → `auth.users.id`
- Check constraint: `role IN ('teacher', 'student', 'admin')`
- Check constraint: `gender IN ('male', 'female', 'other')`

**Số dòng hiện tại:** 11

---

### 2. **schools** - Trường học
**Mục đích:** Quản lý thông tin các trường học/tổ chức

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `name` | text | NO | - | Tên trường học |
| `domain` | text | YES | - | Domain email (unique) |
| `metadata` | jsonb | YES | - | Metadata bổ sung |
| `created_at` | timestamptz | YES | now() | Thời gian tạo |

**Ràng buộc:**
- Primary key: `id`
- Unique: `domain`

**Số dòng hiện tại:** 0

---

### 3. **classes** - Lớp học
**Mục đích:** Quản lý các lớp học trong hệ thống

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `school_id` | uuid | YES | - | FK → schools.id |
| `teacher_id` | uuid | NO | - | FK → auth.users.id (giáo viên chủ nhiệm) |
| `name` | text | NO | - | Tên lớp học |
| `subject` | text | YES | - | Môn học |
| `academic_year` | text | YES | - | Năm học |
| `description` | text | YES | - | Mô tả lớp học |
| `class_settings` | jsonb | YES | (default JSON) | Cài đặt lớp học (enrollment, group_management, student_permissions) |
| `created_at` | timestamptz | YES | now() | Thời gian tạo |

**Ràng buộc:**
- Primary key: `id`
- Foreign keys:
  - `school_id` → `schools.id`
  - `teacher_id` → `auth.users.id`

**Cấu trúc `class_settings` (mặc định):**
```json
{
  "defaults": {
    "lock_class": false
  },
  "enrollment": {
    "qr_code": {
      "is_active": false,
      "join_code": null,
      "expires_at": null,
      "require_approval": true
    },
    "manual_join_limit": null
  },
  "group_management": {
    "lock_groups": false,
    "allow_student_switch": false,
    "is_visible_to_students": true
  },
  "student_permissions": {
    "auto_lock_on_submission": false,
    "can_edit_profile_in_class": true
  }
}
```

**Số dòng hiện tại:** 0

---

### 4. **class_members** - Thành viên lớp học
**Mục đích:** Quan hệ nhiều-nhiều giữa lớp học và học sinh

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `class_id` | uuid | NO | - | FK → classes.id |
| `student_id` | uuid | NO | - | FK → auth.users.id |
| `role` | text | YES | 'student' | Vai trò trong lớp |
| `joined_at` | timestamptz | YES | now() | Thời gian tham gia |
| `status` | text | YES | 'pending' | Trạng thái: 'pending', 'approved', 'rejected' (check constraint) |

**Ràng buộc:**
- Primary key: (`class_id`, `student_id`) - Composite key
- Foreign keys:
  - `class_id` → `classes.id`
  - `student_id` → `auth.users.id`
- Check constraint: `status IN ('pending', 'approved', 'rejected')`

**Số dòng hiện tại:** 0

---

### 5. **class_teachers** - Giáo viên lớp học
**Mục đích:** Quan hệ nhiều-nhiều giữa lớp học và giáo viên (hỗ trợ đồng giảng dạy)

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `class_id` | uuid | YES | - | FK → classes.id |
| `teacher_id` | uuid | YES | - | FK → auth.users.id |
| `role` | text | YES | 'teacher' | Vai trò giáo viên |

**Ràng buộc:**
- Primary key: `id`
- Foreign keys:
  - `class_id` → `classes.id`
  - `teacher_id` → `auth.users.id`

**Số dòng hiện tại:** 0

---

### 6. **groups** - Nhóm học tập
**Mục đích:** Quản lý các nhóm học tập trong lớp học (cho phân phối bài tập khác biệt)

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `class_id` | uuid | YES | - | FK → classes.id |
| `name` | text | NO | - | Tên nhóm |
| `description` | text | YES | - | Mô tả nhóm |
| `created_at` | timestamptz | YES | now() | Thời gian tạo |

**Ràng buộc:**
- Primary key: `id`
- Foreign key: `class_id` → `classes.id`

**Số dòng hiện tại:** 0

---

### 7. **group_members** - Thành viên nhóm
**Mục đích:** Quan hệ nhiều-nhiều giữa nhóm và học sinh

**Các cột:**
| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| `group_id` | uuid | NO | - | FK → groups.id |
| `student_id` | uuid | NO | - | FK → profiles.id |
| `joined_at` | timestamptz | YES | now() | Thời gian tham gia |

**Ràng buộc:**
- Primary key: (`group_id`, `student_id`) - Composite key
- Foreign keys:
  - `group_id` → `groups.id`
  - `student_id` → `profiles.id`

**Số dòng hiện tại:** 0

---

## Các Bảng Chưa Được Tạo (Theo Thiết Kế)

Theo file `docs/ai/README_SUPABASE.md`, hệ thống cần thêm các bảng sau:

### Nhóm 3: Learning Objectives
- `learning_objectives` - Mục tiêu học tập
- `question_objectives` - Liên kết câu hỏi với mục tiêu học tập

### Nhóm 4: Question Bank
- `questions` - Ngân hàng câu hỏi
- `question_choices` - Lựa chọn cho câu hỏi trắc nghiệm

### Nhóm 5: Files & Attachments
- `files` - Metadata file
- `file_links` - Liên kết file với các đối tượng

### Nhóm 6: Assignments
- `assignments` - Bài tập
- `assignment_questions` - Câu hỏi trong bài tập
- `assignment_variants` - Biến thể bài tập (phân hóa)
- `assignment_distributions` - Phân phối bài tập

### Nhóm 7: Workspace & Submissions
- `work_sessions` - Phiên làm bài
- `autosave_answers` - Tự động lưu câu trả lời
- `submission_answers` - Câu trả lời đã nộp
- `submissions` - Tổng hợp bài nộp

### Nhóm 8: AI Grading
- `ai_queue` - Hàng đợi chấm điểm AI
- `ai_evaluations` - Kết quả đánh giá AI
- `grade_overrides` - Ghi đè điểm của giáo viên

### Nhóm 9: Analytics
- `student_skill_mastery` - Mức độ thành thạo kỹ năng
- `question_stats` - Thống kê câu hỏi
- `submission_analytics` - Phân tích bài nộp

### Nhóm 10: Recommendations
- `ai_recommendations` - Đề xuất từ AI
- `teacher_notes` - Ghi chú của giáo viên

---

## Quan Hệ Giữa Các Bảng

```
auth.users
  └─ profiles (1:1)
      └─ group_members (1:N)

schools (1:N)
  └─ classes
      ├─ class_members (N:M với auth.users qua student_id)
      ├─ class_teachers (N:M với auth.users qua teacher_id)
      └─ groups (1:N)
          └─ group_members (N:M với profiles qua student_id)
```

---

## Ghi Chú Quan Trọng

1. **RLS Policies:** Hiện tại tất cả bảng đều có `rls_enabled: false`. Cần bật RLS và tạo policies để đảm bảo bảo mật.

2. **Foreign Key Constraints:** 
   - `class_members.student_id` → `auth.users.id` (không phải profiles.id)
   - `group_members.student_id` → `profiles.id` (khác với class_members)

3. **Composite Primary Keys:**
   - `class_members`: (`class_id`, `student_id`)
   - `group_members`: (`group_id`, `student_id`)

4. **JSONB Fields:**
   - `profiles.metadata`: Dữ liệu metadata tùy chỉnh
   - `classes.class_settings`: Cài đặt lớp học phức tạp

5. **Check Constraints:**
   - `profiles.role`: 'teacher', 'student', 'admin'
   - `profiles.gender`: 'male', 'female', 'other'
   - `class_members.status`: 'pending', 'approved', 'rejected'

---

## Indexes (Theo README_SUPABASE.md)

Các indexes đã được định nghĩa trong README_SUPABASE.md nhưng chưa được tạo:
- `idx_classes_teacher` trên `classes(teacher_id)`
- `idx_class_members_student` trên `class_members(student_id)`
- `idx_questions_author` trên `questions(author_id)` (chưa có bảng)
- `idx_assignments_class` trên `assignments(class_id)` (chưa có bảng)
- Và nhiều indexes khác...

---

## Bước Tiếp Theo

1. **Kiểm tra và tạo các bảng còn thiếu** theo README_SUPABASE.md
2. **Bật RLS và tạo policies** cho tất cả các bảng
3. **Tạo indexes** để tối ưu hiệu suất truy vấn
4. **Tạo triggers và functions** nếu cần (ví dụ: auto-update updated_at)
5. **Kiểm tra advisors** để phát hiện vấn đề bảo mật và hiệu suất

---

**Tài liệu tham khảo:**
- `docs/ai/README_SUPABASE.md` - Schema design đầy đủ
- `memory-bank/techContext.md` - Technical context
- `memory-bank/systemPatterns.md` - System architecture patterns

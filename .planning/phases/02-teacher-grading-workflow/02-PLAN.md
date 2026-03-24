# Phase 2 Plan: Teacher Grading Workflow

**Phase:** 02-teacher-grading-workflow
**Type:** execute
**Depends_on:** Phase 1 (student workflow must be complete)

---

## Mô hình tư duy

| Model | Ý nghĩa |
|-------|-----------|
| **ATC (Air Traffic Control)** | Dashboard nhìn lướt biết bài nào có vấn đề |
| **All-in-One List** | Tất cả câu hỏi trong 1 ListView scroll (UI hiện tại) |
| **Human-in-the-loop** | AI là assistant, teacher là final approver |
| **Stage Curtain** | Điểm chỉ hiện khi teacher "Publish" |
| **Skepticism Thermometer** | AI confidence < 0.7 → vàng cảnh báo |

---

## Database hiện tại (Đã có)

### Bảng work_sessions
- `status`: 'in_progress', 'submitted', 'graded'
- `student_id`, `assignment_distribution_id`

### Bảng submissions
- `is_late`: Tính tự động
- `total_score`: Điểm tổng
- `ai_graded`: Boolean

### Bảng submission_answers
- `ai_confidence`: numeric(3,2) - Độ tin cậy AI

---

## Tasks

### Task 1: Teacher Submission List (ATC Dashboard)

**Mô tả:** Tạo danh sách submissions với "Air Traffic Control" - nhìn lướt biết vấn đề

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_list_screen.dart`
- `lib/presentation/providers/teacher_submission_providers.dart`

**Chức năng:**
1. Danh sách học sinh đã nộp
2. Badge "Nộp muộn" (is_late) - màu đỏ
3. Hiển thị điểm tạm tính (total_score)
4. **AI Loading indicator**: Nếu đang chờ AI → skeleton/spinner + "AI đang phân tích..."
5. Filter: Tất cả / Chưa chấm / Đã chấm / Nộp muộn

---

### Task 2: Submission Detail - All-in-One List Layout

**Mô tả:** Tất cả câu hỏi hiển thị trong 1 ListView scroll (không còn side-by-side hay bottom sheet)

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`

**Header:**
- Avatar HS + tên HS + lớp
- Tên bài tập + deadline + thời gian nộp
- Badge "Nộp muộn" nếu is_late = true

**Mỗi câu hỏi card hiển thị:**
1. **Header row**: Badge loại câu hỏi (TRẮC NGHIỆM / TỰ LUẬN / ĐÚNG/Sai) + ô điểm (màu xanh nếu đạt, đỏ nếu chưa)
2. **Câu hỏi**: Nội dung câu hỏi
3. **Bài làm HS**:
   - Trắc nghiệm: Hiển thị tất cả lựa chọn, tô màu theo đúng/sai
     - HS chọn sai → viền đỏ + nền đỏ + icon X
     - Đáp án đúng → viền xanh + nền xanh + icon check
     - HS chưa chọn → cảnh báo "Học sinh chưa chọn đáp án"
   - Tự luận: Hiển thị text bài làm, hoặc "Học sinh không có câu trả lời"
4. **AI Feedback box**: Hiển thị teacher_feedback nếu có, không thì hiển thị ai_feedback
5. **AI Confidence indicator**: Thanh confidence + cảnh báo nếu < 0.7
6. **Comment section**:
   - Icon chat bubble (có feedback → icon filled, không → outline)
   - **⚠️ QUAN TRỌNG**: Nếu có teacher_feedback → tự động expand + hiển thị nội dung
   - Reload → comment vẫn expand + hiển thị nội dung đã lưu
   - TextField với debounce 1 giây tự lưu
7. **Action buttons**: Nút "Duyệt" + "Sửa điểm" (nếu có ai_score)
8. **Grade Audit Trail**: Lịch sử override (điểm cũ → mới, lý do, thời gian)

**Footer (Bottom Navigation Bar):**
- Tổng điểm hiện tại (scale /10)
- Nút "Hoàn thành" → Dialog xác nhận xuất bản → update work_sessions.status = 'graded'
- Sau khi xuất bản → quay về màn trước

---

### Task 3: Grading Interface - Human-in-the-Loop

**Mô tả:** Teacher chấm điểm với quyền lực tối thượng - mỗi câu hỏi có nút Duyệt/Sửa điểm riêng

**Logic:**

| Loại câu hỏi | Hành vi |
|---------------|---------|
| Trắc nghiệm/Đúng Sai | Auto-graded → Read-only, nút "Sửa điểm" nhỏ nếu cần override |
| Tự luận | AI đưa điểm sơ bộ + feedback |

**Actions:**
- **Approve**: Dùng điểm AI → `final_score = ai_score`
- **Override**: Nhập điểm mới → INSERT vào `grade_overrides` (old_score, new_score, reason)

**⚠️ QUAN TRỌNG #1: Teacher Feedback - Auto-expand & Persist**
- Database có 2 cột riêng: `ai_feedback` (jsonb) và `teacher_feedback` (jsonb)
- **Bắt buộc có Textbox** cho phép giáo viên:
  - Sửa lời phê của AI
  - Thêm lời phê mới
- **⚠️ QUAN TRỌNG**: Khi load dữ liệu:
  - Nếu `teacher_feedback` có nội dung → comment tự động expand
  - Reload / thoát ra vào lại → comment vẫn expand + hiển thị nội dung
  - Không được để text mất sau reload

**⚠️ QUAN TRỌNG #2: Publish Grades (Xuất bản điểm)**
- **THIẾU NÚT PUBLISH = LỖ HỔNG BẢO MẬT LỚN**
- Khi teacher bấm "Hoàn thành" → Dialog xác nhận
- Confirm → `UPDATE work_sessions SET status = 'graded'`
- Chỉ khi publish, học sinh mới thấy điểm
- **Sau khi xuất bản**: SnackBar thông báo thành công + tự động quay về màn trước

---

### Task 4: Grade Override Audit Trail

**Mô tả:** Lưu log khi teacher sửa điểm AI

**Database (Đã có từ db/13_create_remaining_tables.sql):**
- Bảng `grade_overrides` đã tồn tại
- Schema chuẩn:
```sql
CREATE TABLE grade_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_answer_id UUID NOT NULL,  -- FK đến submission_answers
  overridden_by UUID NOT NULL,          -- FK đến auth.users
  old_score NUMERIC(7,2),
  new_score NUMERIC(7,2) NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Migration (2026-03-12):**
- ✅ File: `db/21_update_grade_overrides_constraints.sql`
- Đã update NOT NULL constraints
- Đã thêm FK constraints

**Files:**
- `lib/data/datasources/grade_override_datasource.dart`
- `lib/domain/repositories/grade_override_repository.dart`

---

### Task 5: Publish Grades - Hoàn thành Button

**Mô tả:** "Kéo rèm" - chỉ khi publish học sinh mới thấy điểm

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`
- `lib/data/datasources/submission_datasource.dart`

**Logic:**
1. Footer hiển thị nút "Hoàn thành" + tổng điểm
2. Backend: `UPDATE work_sessions SET status = 'graded' WHERE id = ?`
3. Sau khi xuất bản → thông báo + quay về màn trước

**⚠️ Feedback quan trọng:**
- Sau khi bấm "Hoàn thành" → SnackBar "Đã xuất bản điểm" thành công
- Nếu lỗi → SnackBar báo lỗi cụ thể
- Không để teacher không biết đã xuất bản thành công hay chưa

---

### Task 6: Quick Navigation

**Mô tả:** Navigation siêu tốc giữa các bài nộp

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`

**UI:**
- Nếu có `allSubmissionIds`: hiển thị nút ← / → trong AppBar hoặc footer
- Swipe gesture để chuyển bài (nếu muốn)

---

## Verification

```bash
flutter analyze
```

## Success Criteria

- [ ] Teacher xem được danh sách submissions với ATC model
- [ ] Badge "Nộp muộn" hiển thị đỏ
- [ ] AI loading indicator khi đang chờ AI
- [ ] **All-in-One List**: tất cả câu hỏi trong 1 ListView
- [ ] MCQ tô màu đúng/sai theo spec
- [ ] AI confidence indicator hiển thị (thanh confidence)
- [ ] AI confidence < 0.7 → nền vàng + cảnh báo text
- [ ] Teacher approve/override điểm AI (nút mỗi câu hỏi)
- [ ] **Teacher có thể sửa Feedback (teacher_feedback textbox)**
- [ ] **⚠️ Feedback auto-expand**: nếu có teacher_feedback → tự động expand + hiển thị nội dung sau reload
- [ ] **⚠️ Feedback persist**: reload / thoát vào → comment vẫn expand + nội dung không mất
- [ ] Grade override lưu audit trail vào bảng grade_overrides
- [ ] **⚠️ Nút "Hoàn thành" + SnackBar feedback rõ ràng** sau khi xuất bản
- [ ] Publish grades chỉ khi teacher bấm nút (status = 'graded')
- [ ] Next/Prev navigation hoạt động (nếu có allSubmissionIds)
- [ ] Debounce autosave cho feedback (1000ms)

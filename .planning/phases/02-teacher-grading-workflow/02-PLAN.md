# Phase 2 Plan: Teacher Grading Workflow

**Phase:** 02-teacher-grading-workflow
**Type:** execute
**Depends_on:** Phase 1 (student workflow must be complete)

---

## Mô hình tư duy

| Model | Ý nghĩa |
|-------|-----------|
| **ATC (Air Traffic Control)** | Dashboard nhìn lướt biết bài nào có vấn đề |
| **Side-by-Side** | Cột trái: Bài làm, Cột phải: Đáp án chuẩn |
| **Human-in-the-loop** | AI là assistant, teacher là final approver |
| **Stage Curtain** | Điểm chỉ hiện khi teacher "Publish" |
| **Focus Lens** | Mobile: Bottom Sheet thay vì side-by-side |
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

### Task 2: Submission Detail - Side-by-Side Layout

**Mô tả:** Xem chi tiết bài nộp với "Focus Lens" - Mobile: Bottom Sheet

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`

**Chức năng Desktop:**
- 2 cột: Cột trái (Bài làm) | Cột phải (Đáp án + Rubric)

**Chức năng Mobile:**
- Câu hỏi + Câu trả lời HS + Ô nhập điểm (luôn hiển thị)
- FAB/Button "Xem Rubric & Đáp án" → Bottom Sheet trượt lên

**Hiển thị:**
- Câu hỏi + Đáp án học sinh chọn
- File đính kèm (nếu có)

**⚠️ QUAN TRỌNG: Skepticism Thermometer (AI Confidence)**
- Database có sẵn cột `ai_confidence` trong `submission_answers`
- **Bắt buộc hiển thị** thanh confidence indicator
- Nếu `ai_confidence < 0.7`:
  - Toàn bộ khung AI đổi sang viền vàng/đỏ
  - Hiển thị dòng text: "AI phân vân (Độ tin cậy thấp) - Yêu cầu giáo viên kiểm tra kỹ"

---

### Task 3: Grading Interface - Human-in-the-Loop

**Mô tả:** Teacher chấm điểm với quyền lực tối thượng

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`
- `lib/data/repositories/submission_repository_impl.dart`

**Logic:**

| Loại câu hỏi | Hành vi |
|---------------|---------|
| Trắc nghiệm/Đúng Sai | Auto-graded → Read-only, nút "Sửa điểm" nhỏ nếu cần override |
| Tự luận | AI đưa điểm sơ bộ + feedback |

**Actions:**
- **Approve**: Dùng điểm AI → `final_score = ai_score`
- **Override**: Nhập điểm mới → INSERT vào `grade_overrides` (old_score, new_score, reason)

**⚠️ QUAN TRỌNG #1: Feedback Override (Lời phê)**
- Database có 2 cột riêng: `ai_feedback` (jsonb) và `teacher_feedback` (jsonb)
- **Bắt buộc có Textbox** cho phép giáo viên:
  - Sửa lời phê của AI
  - Thêm lời phê mới
- UI mẫu:
```
📝 Feedback AI:
"Lời giải chưa đầy đủ..."

✏️ Lời phê của giáo viên:
[ Khung nhập liệu cho phép edit ]
```

**⚠️ QUAN TRỌNG #2: Publish Grades (Xuất bản điểm) - TỬ HUYỆT!**
- **THIẾU NÚT PUBLISH = LỖ HỔNG BẢO MẬT LỚN**
- Khi teacher bấm "Duyệt" → Điểm lưu vào DB (status = 'submitted')
- **Cần nút "Xuất bản"** riêng biệt:
  - Nút màu xanh nổi bật trong Submission List
  - Khi bấm: `UPDATE work_sessions SET status = 'graded'`
  - Chỉ khi publish, học sinh mới thấy điểm
- **Supabase Realtime**: Student app subscribe `work_sessions` changes
  - Khi `status = 'graded'` → Student app tự động hiển thị điểm mới

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

### Task 5: Publish Grades - Stage Curtain

**Mô tả:** "Kéo rèm" - chỉ khi publish học sinh mới thấy điểm

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_list_screen.dart`
- `lib/data/datasources/submission_datasource.dart`

**Logic:**
1. Nút "Xuất bản điểm toàn lớp" trong submission list
2. Backend: `UPDATE work_sessions SET status = 'graded' WHERE assignment_distribution_id = ?`
3. Gửi notification cho học sinh

**Settings:**
- Kiểm tra `assignment_distributions.settings.show_score_immediately`
- Nếu true + toàn bài trắc nghiệm → auto publish

---

### Task 6: Quick Navigation

**Mô tả:** Navigation siêu tốc giữa các bài nộp

**Files:**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`

**UI:**
- Nút Next/Previous to đùng ở cuối màn hình
- Hoặc swipe gesture

---

## Verification

```bash
flutter analyze
```

## Success Criteria

- [ ] Teacher xem được danh sách submissions với ATC model
- [ ] Badge "Nộp muộn" hiển thị đỏ
- [ ] AI loading indicator khi đang chờ AI
- [ ] Side-by-side (Desktop) / Bottom Sheet (Mobile) hoạt động
- [ ] AI confidence indicator hiển thị (thanh confidence)
- [ ] AI confidence < 0.7 → nền vàng + cảnh báo text
- [ ] Teacher approve/override điểm AI
- [ ] **Teacher có thể sửa Feedback (teacher_feedback textbox)**
- [ ] **Có nút "Xuất bản điểm" (Publish) riêng biệt**
- [ ] Grade override lưu audit trail vào bảng grade_overrides
- [ ] Publish grades chỉ khi teacher bấm nút (status = 'graded')
- [ ] Next/Prev navigation hoạt động
- [ ] Debounce autosave cho feedback (1000ms)

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
- **AI Confidence**: Nếu < 0.7 → nền vàng cảnh báo

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

---

### Task 4: Grade Override Audit Trail

**Mô tả:** Lưu log khi teacher sửa điểm AI

**Database:**
- Tạo bảng `grade_overrides` nếu chưa có

**Schema:**
```sql
CREATE TABLE grade_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID REFERENCES submissions(id),
  question_id UUID REFERENCES assignment_questions(id),
  old_score DOUBLE PRECISION,
  new_score DOUBLE PRECISION,
  reason TEXT,
  teacher_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

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
- [ ] AI confidence < 0.7 → nền vàng cảnh báo
- [ ] Teacher approve/override điểm AI
- [ ] Grade override lưu audit trail
- [ ] Publish grades chỉ khi teacher bấm nút
- [ ] Next/Prev navigation hoạt động

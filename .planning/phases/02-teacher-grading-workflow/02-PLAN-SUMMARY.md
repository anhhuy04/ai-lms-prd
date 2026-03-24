# Phase 2 Plan 02: Teacher Grading Workflow Summary

**Phase:** 02-teacher-grading-workflow
**Plan:** 02-PLAN.md
**Status:** ✅ COMPLETED
**Date:** 2026-03-12

---

## Mục tiêu

Hoàn thiện Teacher Grading Workflow với 6 tasks:
1. ✅ Teacher Submission List (ATC Dashboard)
2. ✅ Submission Detail - Side-by-Side
3. ✅ Grading Interface - Human-in-the-Loop
4. ✅ Grade Override Audit Trail
5. ✅ Publish Grades - Stage Curtain
6. ✅ Quick Navigation

---

## Các file đã tạo/sửa đổi

### Core Screens
| File | Mô tả | Status |
|------|--------|--------|
| `lib/presentation/views/assignment/teacher/teacher_submission_list_screen.dart` | ATC Dashboard - Danh sách submissions | ✅ |
| `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` | Side-by-Side Layout + AI Confidence | ✅ |

### Providers
| File | Mô tả | Status |
|------|--------|--------|
| `lib/presentation/providers/teacher_submission_providers.dart` | Providers cho submission + grading | ✅ |

### Widgets
| File | Mô tả | Status |
|------|--------|--------|
| `lib/presentation/views/assignment/teacher/widgets/submission/submission_filter_chips.dart` | Filter chips | ✅ |
| `lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart` | Badge "Nộp muộn", AI loading | ✅ |
| `lib/presentation/views/assignment/teacher/widgets/submission/ai_confidence_indicator.dart` | Skepticism Thermometer | ✅ |
| `lib/presentation/views/assignment/teacher/widgets/submission/grading_action_buttons.dart` | Approve/Override buttons + Feedback Editor | ✅ |
| `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` | Question + Answer display | ✅ |
| `lib/presentation/views/assignment/teacher/widgets/submission/teacher_feedback_editor.dart` | **MỚI** - Feedback Override textbox | ✅ |

### Data Layer
| File | Mô tả | Status |
|------|--------|--------|
| `lib/data/datasources/grade_override_datasource.dart` | Grade overrides CRUD | ✅ |
| `lib/domain/repositories/grade_override_repository.dart` | Repository interface + impl | ✅ |

---

## Deviation Documentation

### Auto-fixed Issues

**1. [Rule 2 - Missing Feature] Teacher Feedback Editor**
- **Issue:** Grading interface thiếu textbox để GV sửa feedback AI
- **Fix:** Tạo `TeacherFeedbackEditor` widget với debounce 1000ms
- **Files:** `teacher_feedback_editor.dart`, `grading_action_buttons.dart`, `teacher_submission_detail_screen.dart`
- **Commit:** [Trong commit tiếp theo]

---

## Features Implemented

### 1. ATC Dashboard (Air Traffic Control)
- Badge "Nộp muộn" màu đỏ
- AI Loading indicator khi đang chờ AI
- Filter: Tất cả / Chưa chấm / Đã chấm / Nộp muộn

### 2. All-in-One List Layout
- Tất cả câu hỏi trong 1 ListView scroll (không còn side-by-side hay bottom sheet)
- Header: Avatar HS + tên + lớp + deadline + thời gian nộp
- MCQ tô màu: đỏ (sai), xanh (đúng), cảnh báo (chưa chọn)
- AI Feedback box: hiển thị teacher_feedback > ai_feedback

### 3. Skepticism Thermometer
- Hiển thị AI confidence (thanh confidence)
- Khi confidence < 0.7: nền vàng + cảnh báo text

### 4. Human-in-the-Loop
- Approve: Dùng điểm AI
- Override: Nhập điểm mới + lý do (lưu vào grade_overrides)

### 5. Feedback Override
- Hiển thị AI feedback (read-only)
- Textbox cho phép GV sửa/thêm lời phê
- Debounce 1000ms + nút "Lưu ngay"
- Lưu vào teacher_feedback column

### 6. Stage Curtain (Publish Grades)
- Nút "Xuất bản điểm" trong AppBar
- Dialog xác nhận trước khi publish
- Cập nhật work_sessions.status = 'graded'
- HS chỉ thấy điểm sau khi publish

### 7. Quick Navigation
- Next/Previous buttons trong AppBar
- Navigation dots trên mobile
- PageView swipe gesture

---

## Database Schema

```sql
-- submissions table
is_late: boolean
total_score: numeric
ai_graded: boolean
status: 'draft' | 'submitted' | 'graded'

-- submission_answers table
ai_score: numeric
ai_confidence: numeric (0.0 - 1.0)
ai_feedback: jsonb
teacher_feedback: jsonb
graded_by: uuid
graded_at: timestamptz

-- grade_overrides table
submission_answer_id: uuid NOT NULL
overridden_by: uuid NOT NULL
old_score: numeric
new_score: numeric NOT NULL
reason: text
created_at: timestamptz NOT NULL DEFAULT now()

-- work_sessions table
status: 'in_progress' | 'submitted' | 'graded'
```

---

## Verification Results

| Check | Result |
|-------|--------|
| flutter analyze | ✅ 55 warnings (pre-existing) |
| flutter build apk --debug | ✅ Built successfully |
| Feedback Override textbox | ✅ Hoạt động với debounce |
| Publish Grades button | ✅ Dialog xác nhận + API call |
| Grade Override Audit | ✅ Lưu vào grade_overrides |

---

## Dependencies

- `grade_override_datasource.dart` - CRUD cho grade_overrides
- `grade_override_repository.dart` - Repository pattern
- `teacher_submission_providers.dart` - State management với Riverpod

---

## Key Decisions

1. **Feedback storage:** Teacher feedback lưu vào column `teacher_feedback` riêng biệt, không ghi đè AI feedback
2. **Debounce strategy:** 1000ms debounce + force save on blur/onNext
3. **Publish model:** Stage Curtain - điểm chỉ hiện khi teacher bấm "Xuất bản"
4. **Override audit:** Mỗi lần override đều lưu vào grade_overrides với old_score, new_score, reason

---

## Deviation Documentation

### UI Redesign (2026-03-24)

**Thay đổi lớn:** User đã custom lại UI Submission Detail thành all-in-one list layout thay vì side-by-side / bottom sheet.

**Lý do:** User muốn tối ưu trải nghiệm, hiển thị tất cả câu hỏi trong 1 trang.

### Issues Found (UAT)

**1. [major] Teacher Feedback - Auto-expand & Persist**
- **Issue:** Reload thì mục thêm nhận xét bị mất. Thoát ra vào lại thì mục đã thêm bị ẩn, bật lên thì không thấy gì.
- **Yêu cầu:** Câu hỏi có nhận xét thì tự động hiển thị cùng nội dung.
- **Status:** Diagnosing

**2. [major] Publish Grades - Feedback rõ ràng**
- **Issue:** Bấm "Hoàn thành" nhưng không rõ đã hoạt động hay chưa.
- **Yêu cầu:** Cần cách để check.
- **Status:** Diagnosing

---

## Next Steps

- Fix 2 issues từ UAT (Feedback auto-expand, Publish feedback)
- Test toàn bộ flow với dữ liệu thực
- Verify Supabase Realtime cho student app
- Thêm notification cho HS khi có điểm mới

---

*Generated: 2026-03-12*

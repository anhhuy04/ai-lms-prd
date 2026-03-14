---
status: testing
phase: 02-teacher-grading-workflow
source: 02-PLAN-SUMMARY.md
started: 2026-03-13T00:00:00Z
updated: 2026-03-13T01:10:00Z
---

## Current Test

number: 4
name: Skepticism Thermometer - AI Confidence Display
expected: |
  Thanh confidence hiển thị mức độ tin cậy của AI
  Khi confidence < 0.7: nền vàng + cảnh báo text "AI phân vân - Yêu cầu giáo viên kiểm tra kỹ"
awaiting: user response

## Session Progress

- Test 1: PASS ✓
- Test 2: PASS ✓
- Test 3: PASS ✓ (Data fixed - query via work_sessions)
- Test 4: In Progress
- Remaining: 5 tests

## Tests

### 1. ATC Dashboard - View Submission List
expected: Assignment Hub → Nút "Kiểm tra" → Grading Hub hiển thị danh sách bài tập đã giao với tên bài + tên lớp
result: pass

### 2. ATC Dashboard - Filter by Status
expected: Tap vào filter chip "Chỉ đợi chấm" chỉ hiển thị submissions chưa được chấm, "Nộp muộn" chỉ hiển thị bài nộp muộn
result: pass

### 3. Submission Detail - Side-by-Side Layout
expected: Màn hình chấm bài hiển thị 2 cột: bài làm của HS bên trái, đáp án + rubric bên phải (trên desktop)
result: pass
note: "Data hiển thị đúng, nhưng UI layout cần kiểm tra lại"

### 4. Skepticism Thermometer - AI Confidence Display
expected: Thanh confidence hiển thị mức độ tin cậy của AI. Khi confidence < 0.7: nền vàng + cảnh báo text "AI phân vân - Yêu cầu giáo viên kiểm tra kỹ"
result: pending

### 5. Human-in-the-Loop - Approve Grade
expected: Nhấn nút "Duyệt" sử dụng điểm AI, cập nhật trạng thái submission thành đã chấm
result: pending

### 6. Human-in-the-Loop - Override Grade
expected: Nhấn nút "Sửa điểm", nhập điểm mới + lý do, lưu vào grade_overrides table với audit trail
result: pending

### 7. Feedback Override - Edit Teacher Feedback
expected: Textbox cho phép GV sửa/thêm lời phê. Có debounce 1000ms và nút "Lưu ngay". Lưu vào teacher_feedback column
result: pending

### 8. Stage Curtain - Publish Grades
expected: Nhấn "Xuất bản điểm" trong AppBar hiển thị dialog xác nhận. Sau khi confirm, cập nhật work_sessions.status = 'graded'. HS chỉ thấy điểm sau khi publish
result: pending

### 9. Quick Navigation - Next/Previous
expected: Nút Next/Previous trong AppBar cho phép di chuyển giữa các submission. Trên mobile có navigation dots
result: pending

## Summary

total: 9
passed: 3
issues: 1
pending: 5
skipped: 0

## Gaps

- truth: "Màn hình chấm bài hiển thị 2 cột: bài làm của HS bên trái, đáp án + rubric bên phải"
  status: fixed
  reason: "Đã fix query: submissions -> work_sessions -> submission_answers -> assignment_questions -> questions"
  severity: blocker
  test: 3

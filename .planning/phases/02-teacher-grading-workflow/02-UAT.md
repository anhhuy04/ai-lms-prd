---
status: testing
phase: 02-teacher-grading-workflow
source: 02-PLAN-SUMMARY.md
started: 2026-03-13T00:00:00Z
updated: 2026-03-13T00:00:00Z
---

## Current Test

number: 1
name: ATC Dashboard - View Submission List
expected: |
  Teacher Assignment Hub hiển thị danh sách submissions với:
  - Badge "Nộp muộn" màu đỏ cho bài nộp muộn
  - AI Loading indicator khi đang chờ AI grading
  - Filter chips: Tất cả / Chưa chấm / Đã chấm / Nộp muộn
awaiting: user response

## Tests

### 1. ATC Dashboard - View Submission List
expected: Teacher Assignment Hub hiển thị danh sách submissions với badge "Nộp muộn" màu đỏ, AI Loading indicator, và filter chips (Tất cả / Chưa chấm / Đã chấm / Nộp muộn)
result: pending

### 2. ATC Dashboard - Filter by Status
expected: Tap vào filter chip "Chỉ đợi chấm" chỉ hiển thị submissions chưa được chấm, "Nộp muộn" chỉ hiển thị bài nộp muộn
result: pending

### 3. Submission Detail - Side-by-Side Layout
expected: Màn hình chấm bài hiển thị 2 cột: bài làm của HS bên trái, đáp án + rubric bên phải (trên desktop)
result: pending

### 4. Skepticism Thermometer - AI Confidence Display
expected: Thanh confidence hiển thị mức độ tin cậy của AI. Khi confidence < 0.7: nền vàng + cảnh báo text
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
passed: 0
issues: 0
pending: 9
skipped: 0

## Gaps

[none yet]

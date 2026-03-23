---
status: testing
phase: 02-teacher-grading-workflow
source: 02-PLAN-SUMMARY.md
started: 2026-03-23T10:00:00Z
updated: 2026-03-23T10:00:00Z
---

## Current Test

number: 6
name: Human-in-the-Loop - Override Grade
expected: |
  Nhấn nút "Sửa điểm", nhập điểm mới + lý do, lưu vào grade_overrides table với audit trail
awaiting: user response

## Tests

### 1. ATC Dashboard - View Submission List
expected: Assignment Hub → Nút "Kiểm tra" → Grading Hub hiển thị danh sách bài tập đã giao với tên bài + tên lớp
result: pass

### 2. ATC Dashboard - Filter by Status
expected: Tap vào filter chip "Chỉ đợi chấm" chỉ hiển thị submissions chưa được chấm, "Nộp muộn" chỉ hiển thị bài nộp muộn
result: skipped
reason: Data source cần review lại - lấy dữ liệu từ bảng nào chưa rõ ràng

### 3. Submission Detail - Side-by-Side Layout
expected: Màn hình chấm bài hiển thị 2 cột: bài làm của HS bên trái, đáp án + rubric bên phải (trên desktop)
result: pass

### 4. Skepticism Thermometer - AI Confidence Display
expected: Thanh confidence hiển thị mức độ tin cậy của AI. Khi confidence < 0.7: nền vàng + cảnh báo text "AI phân vân - Yêu cầu giáo viên kiểm tra kỹ"
result: skipped
reason: Chưa có dữ liệu AI để test - cần submission có ai_confidence

### 5. Human-in-the-Loop - Approve Grade
expected: Nhấn nút "Duyệt" sử dụng điểm AI, cập nhật trạng thái submission thành đã chấm
result: skipped
reason: User skip

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
passed: 2
issues: 0
pending: 4
skipped: 3

## Gaps

- truth: "Assignment Hub có nút 'Kiểm tra' để vào Grading Hub xem danh sách submissions"
  status: fixed
  reason: "User reported: Chưa có nút để bấm vào. Thay nút tạo bằng AI sang kiểm tra."
  severity: major
  test: 1
  root_cause: "Assignment Hub có nút 'Tạo bằng AI' với TODO trống. Grading Hub thiết kế sai - hiển thị distributions thay vì assignments, thiếu stats row và 2 nút action"
  artifacts:
    - path: "lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart"
      issue: "Thiếu QuickActionButton 'Kiểm tra' - đã thay thế nút 'Tạo bằng AI' TODO"
    - path: "lib/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart"
      issue: "Thiết kế sai - hiển thị distribution cards thay vì assignment cards"
  missing:
    - "Thêm nút 'Kiểm tra' với icon Icons.fact_check_outlined, isGradient: true, navigate đến AppRoute.teacherGrading"
    - "Rewrite Grading Hub: mỗi card = 1 assignment với stats row + 2 nút (Xem đề | Danh sách)"
    - "Tạo GradingAssignmentCard widget + ClassBottomSheet widget"
  debug_session: ""

- truth: "Grading Hub: số liệu Nộp/Chưa chấm/Đã chấm hoạt động đúng, bottom sheet chọn lớp và navigation hoạt động"
  status: fixed
  reason: "User reported: Các chức năng và số ở trên danh sách và bottom sheet chưa hoạt động hết"
  severity: major
  test: 1
  root_cause: "1) Stats trên card dùng submissions.count thay vì work_sessions.status (submitted/graded). 2) Filter chips nằm trong ListView nên bị mất khi empty. 3) class_enrollments table không tồn tại - đổi sang work_sessions. 4) getSubmissionById join trực tiếp submissions → submission_answers nhưng FK nằm ở submission_answers.session_id → work_sessions.id."
  artifacts:
    - path: "lib/data/datasources/assignment_datasource.dart"
      issue: "submitted_count/graded_count đếm từ submissions thay vì work_sessions"
    - path: "lib/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart"
      issue: "Filter chips trong ListView + filter logic sai"
    - path: "lib/data/datasources/submission_datasource.dart"
      issue: "getSubmissionById join submissions → submission_answers (FK không tồn tại)"
  missing:
    - "Fix: tách 2 queries; submissions → work_sessions → submission_answers"
  debug_session: ""

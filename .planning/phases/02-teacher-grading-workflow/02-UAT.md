---
status: complete
phase: 02-teacher-grading-workflow
source: 02-PLAN-SUMMARY.md
started: 2026-03-23T10:00:00Z
updated: 2026-03-24T00:00:00Z
---

## Current Test

[testing complete]

## Tests

### 1. ATC Dashboard - View Submission List
expected: Assignment Hub → Nút "Kiểm tra" → Grading Hub hiển thị danh sách bài tập đã giao với tên bài + tên lớp
result: pass

### 2. ATC Dashboard - Filter by Status
expected: Tap vào filter chip "Chỉ đợi chấm" chỉ hiển thị submissions chưa được chấm, "Nộp muộn" chỉ hiển thị bài nộp muộn
result: skipped
reason: Data source cần review lại - lấy dữ liệu từ bảng nào chưa rõ ràng

### 3. Submission Detail - All-in-One List Layout
expected: Màn Submission Detail hiển thị TẤT CẢ câu hỏi trong 1 ListView scroll. Header hiển thị avatar HS + tên bài + lớp + thời gian nộp. Mỗi câu hỏi hiển thị đầy đủ: loại câu hỏi, điểm, nội dung, bài làm HS, đáp án đúng (trắc nghiệm tô màu), AI feedback, comment.
result: pass

### 4. Submission Detail - MCQ Color Coding
expected: Câu trắc nghiệm hiển thị tất cả lựa chọn. Đáp án HS chọn sai → viền đỏ + nền đỏ + icon X. Đáp án đúng → viền xanh + nền xanh + icon check. Nếu HS chưa chọn → hiển thị cảnh báo "Học sinh chưa chọn đáp án".
result: pass

### 5. Submission Detail - AI Confidence Indicator
expected: Thanh confidence hiển thị mức độ tin cậy của AI. Khi confidence < 0.7: nền vàng + cảnh báo text "AI phân vân - Yêu cầu giáo viên kiểm tra kỹ"
result: skipped
reason: Chưa có dữ liệu AI để test - cần submission có ai_confidence

### 6. Teacher Feedback - Auto-expand & Persist
expected: Khi có teacher_feedback → comment tự động expand và hiển thị nội dung. Reload trang → comment vẫn expand + hiển thị nội dung đã lưu. Textbox có debounce 1 giây tự lưu.
result: issue
reported: "Reload thì mục thêm nhận xét bị mất. Thoát ra vào lại thì mục đã thêm bị ẩn, bật lên thì không thấy gì. Cần: câu hỏi có nhận xét thì tự động hiển thị cùng nội dung."
severity: major

### 7. Grade Audit Trail
expected: Mỗi câu hỏi hiển thị lịch sử chỉnh sửa điểm (override) bên dưới card câu hỏi. Hiển thị: điểm cũ → điểm mới, lý do, thời gian.
result: skipped
reason: Chưa có dữ liệu override để test

### 8. Human-in-the-Loop - Approve/Override Buttons
expected: Mỗi câu hỏi có nút "Duyệt" (sử dụng điểm AI) và "Sửa điểm" (nhập điểm mới + lý do, lưu vào grade_overrides). Nút nằm dưới mỗi card câu hỏi.
result: skipped
reason: Chưa có dữ liệu AI submission để test

### 9. Publish Grades - Hoàn thành Button
expected: Footer hiển thị tổng điểm hiện tại + nút "Hoàn thành". Nhấn → dialog xác nhận "Xuất bản điểm". Confirm → cập nhật work_sessions.status = 'graded'. HS chỉ thấy điểm sau khi publish. Sau khi xuất bản → quay về màn trước.
result: issue
reported: "Bấm xuất bản nhưng không rõ đã hoạt động hay chưa. Cần cách để check."
severity: major

### 10. Quick Navigation - Next/Previous
expected: Trên màn Submission Detail có nút ← / → để di chuyển giữa các submission (nếu có allSubmissionIds). Hoặc: vuốt (swipe) để chuyển bài.
result: skipped
reason: User skip - không test tiếp Phase 2

## Summary

total: 10
passed: 3
issues: 2
pending: 0
skipped: 5

## Gaps

- truth: "Teacher feedback tự động hiển thị khi có nội dung, không bị mất sau reload"
  status: fixed
  reason: "Datasource lưu key 'comment' nhưng screen đọc key 'text' → luôn null. Fix: đổi datasource sang lưu key 'text'."
  severity: major
  test: 6
  root_cause: "submission_datasource.dart lưu teacher_feedback với key 'comment' nhưng submission_detail_screen.dart đọc với key 'text'. Data format không khớp."
  artifacts:
    - path: "lib/data/datasources/submission_datasource.dart"
      issue: "Lưu {'comment': teacherFeedback} thay vì {'text': teacherFeedback}"
  missing:
    - "Đổi key 'comment' → 'text' trong datasource"
  debug_session: ""

- truth: "Bấm Hoàn thành → xuất bản điểm → có feedback rõ ràng cho teacher"
  status: fixed
  reason: "Thêm SnackBar cho cả auto-publish để teacher biết đã xuất bản."
  severity: major
  test: 9
  root_cause: "_autoPublishGrades() không hiển thị SnackBar, chỉ log. Teacher không biết đã xuất bản tự động."
  artifacts:
    - path: "lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart"
      issue: "_autoPublishGrades không có SnackBar feedback"
  missing:
    - "Thêm SnackBar trong _autoPublishGrades"
  debug_session: ""

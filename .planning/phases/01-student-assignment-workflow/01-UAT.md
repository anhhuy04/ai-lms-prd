---
status: testing
phase: 01-student-assignment-workflow
source: 01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md, 01-04-SUMMARY.md
started: 2026-03-05T12:15:00Z
updated: 2026-03-10T07:35:00.000Z
---

## Current Test

number: 7
name: Xem lịch sử nộp bài
expected: |
  Vào màn lịch sử nộp bài. Hiển thị danh sách các bài đã nộp với: tên bài tập, ngày nộp, điểm (nếu đã chấm).
awaiting: user response

## Tests

### 1. Xem danh sách bài tập
expected: Học sinh đăng nhập, vào màn danh sách bài tập. Hiển thị danh sách bài tập với: tiêu đề, môn học, hạn nộp, trạng thái, % hoàn thành. Có thể filter: All / Pending / Submitted / Graded.
result: pass

### 2. Xem chi tiết bài tập
expected: Tap vào một bài tập trong danh sách. Chuyển đến màn chi tiết bài tập. Hiển thị: tiêu đề, mô tả, điểm, hạn nộp, thời gian còn lại, thống kê loại câu hỏi. Có nút "Bắt đầu làm bài".
result: pass

### 3. Làm bài trong Workspace
expected: Từ màn chi tiết bài tập, tap "Bắt đầu làm bài". Vào workspace. Hiển thị các câu hỏi: trắc nghiệm (radio), đúng/sai (toggle), tự luận (text field), điền trống (text fields). Có progress indicator "Question X of Y answered".
result: pass

### 4. Auto-save hoạt động
expected: Gõ câu trả lời vào một câu hỏi. Đợi 2 giây. Thấy indicator "Saving..." rồi "Saved". Tắt app, mở lại, câu trả lời vẫn còn.
result: pass

### 5. Upload file
expected: Trong workspace, có phần upload file. Upload một file (ảnh hoặc PDF). Thấy progress bar. Sau khi upload xong, hiển thị thumbnail/preview của file đã upload.
result: issue
reported: "Tính năng này đã làm hay chưa vì sao chưa thấy"
severity: major

### 6. Nộp bài
expected: Làm xong các câu hỏi, tap nút "Nộp bài". Hiển thị dialog xác nhận. Xác nhận nộp. Hiển thị màn hình thành công với timestamp và confirmation number.
result: issue
reported: "chưa"
severity: major

### 7. Xem lịch sử nộp bài
expected: Vào màn lịch sử nộp bài. Hiển thị danh sách các bài đã nộp với: tên bài tập, ngày nộp, điểm (nếu đã chấm).
result: [pending]

## Summary

total: 7
passed: 4
issues: 2
pending: 1
skipped: 0

## Gaps

- truth: "Trong workspace, có phần upload file. Upload một file (ảnh hoặc PDF). Thấy progress bar. Sau khi upload xong, hiển thị thumbnail/preview của file đã upload."
  status: resolved
  reason: "Implemented in Plan 04 - file upload UI added with ImagePicker"
  severity: major
  test: 5
- truth: "Làm xong các câu hỏi, tap nút Nộp bài. Hiển thị dialog xác nhận. Xác nhận nộp. Hiển thị màn hình thành công với timestamp và confirmation number."
  status: resolved
  reason: "Implemented in Plan 04 - success dialog with timestamp and confirmation number"
  severity: major
  test: 6

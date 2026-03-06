---
status: in_progress
phase: 01-student-assignment-workflow
source: 01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md
started: 2026-03-05T12:15:00Z
updated: 2026-03-05T21:07:00.000Z
---

## Current Test

Testing in progress - Test 2 (View assignment detail) is being fixed

## Tests

### 1. Xem danh sách bài tập
expected: Học sinh đăng nhập, vào màn danh sách bài tập. Hiển thị danh sách bài tập với: tiêu đề, môn học, hạn nộp, trạng thái, % hoàn thành. Có thể filter: All / Pending / Submitted / Graded.
result: pass

### 2. Xem chi tiết bài tập
expected: Tap vào một bài tập trong danh sách. Chuyển đến màn chi tiết bài tập. Hiển thị: tiêu đề, mô tả, điểm, hạn nộp, thời gian còn lại, danh sách câu hỏi với loại câu hỏi và điểm. Có nút "Bắt đầu làm bài".
result: in_progress
fixes_applied:
  - "Fixed getDistributionDetail query to fetch questions from custom_content when question_id is null"
  - "Updated UI to parse JSON content: content.text, content.type"
  - "Updated workspace_provider to parse custom_content.options for choices"
  - "Fixed back button in student_assignment_detail_screen.dart - changed Navigator.pop() to context.pop()"
  - "Fixed back button in student_assignment_workspace_screen.dart - added go_router import and context.pop()"

### 3. Làm bài trong Workspace
expected: Từ màn chi tiết bài tập, tap "Bắt đầu làm bài". Vào workspace. Hiển thị các câu hỏi: trắc nghiệm (radio), đúng/sai (toggle), tự luận (text field), điền trống (text fields). Có progress indicator "Question X of Y answered".
result: pending
reason: "Phụ thuộc Test 2 - đang fix"

### 4. Auto-save hoạt động
expected: Gõ câu trả lời vào một câu hỏi. Đợi 2 giây. Thấy indicator "Saving..." rồi "Saved". Tắt app, mở lại, câu trả lời vẫn còn.
result: pending
reason: "Phụ thuộc Test 2 - đang fix"

### 5. Upload file
expected: Trong workspace, có phần upload file. Upload một file (ảnh hoặc PDF). Thấy progress bar. Sau khi upload xong, hiển thị thumbnail/preview của file đã upload.
result: pending
reason: "Phụ thuộc Test 2 - đang fix"

### 6. Nộp bài
expected: Làm xong các câu hỏi, tap nút "Nộp bài". Hiển thị dialog xác nhận. Xác nhận nộp. Hiển thị màn hình thành công với timestamp và confirmation number.
result: pending
reason: "Phụ thuộc Test 2 - đang fix"

### 7. Xem lịch sử nộp bài
expected: Vào màn lịch sử nộp bài. Hiển thị danh sách các bài đã nộp với: tên bài tập, ngày nộp, điểm (nếu đã chấm).
result: pending
reason: "Phụ thuộc Test 2 - đang fix"

## Summary

total: 7
passed: 1
issues: 0
in_progress: 1
pending: 5

## Fixes Applied

### Root Cause: questions array empty in getDistributionDetail
1. **assignment_datasource.dart** - Changed query to:
   - Fetch assignment_questions with custom_content field
   - Handle two cases: question_id (from question bank) and custom_content (new questions)
   - Parse custom_content.options for MultipleChoice choices

2. **student_assignment_detail_screen.dart** - Updated UI:
   - Parse content as String or JSON object
   - Extract text from content.text
   - Extract type from content.type

3. **workspace_provider.dart** - Updated QuestionState:
   - Parse content as String or Map
   - Extract choices from custom_content.options format

4. **Navigation fixes**:
   - student_assignment_detail_screen.dart: Changed Navigator.pop() to context.pop()
   - student_assignment_workspace_screen.dart: Added go_router import, changed Navigator.pop() to context.pop()

## Remaining Issues

- Need to verify Test 2 passes after fixes
- May need to verify workspace screen displays questions correctly

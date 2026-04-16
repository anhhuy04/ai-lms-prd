---
status: complete
phase: 03-rubric-system
source: [03-RubricBuilderComponent-SUMMARY.md, 03-RubricSummaryButton-SUMMARY.md, 03-RubricTemplatePickerSheet-SUMMARY.md, 03-RubricTemplateDatasource-SUMMARY.md, 03-InteractiveRubricGrader-SUMMARY.md, 03-ReadOnlyRubricViewer-SUMMARY.md, 03-TeacherCreateAssignmentScreen-SUMMARY.md, 03-StudentAssignmentDetailScreen-SUMMARY.md, 03-StudentWorkspaceScreen-SUMMARY.md]
started: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:02:00Z
---

## Current Test

number: 10
name: Student xem rubric khi đang làm bài trong workspace
expected: |
  Câu essay trong workspace → nút "Xem Tiêu chí" bên trên ô nhập.
  Tap → sheet read-only mở với ReadOnlyRubricViewer.
awaiting: complete

## Tests

### 1. RubricSummaryButton hiển thị đúng trạng thái
expected: |
  Vào màn hình tạo/sửa bài tập (teacher). Thêm một câu hỏi loại "Tự luận" (essay).
  Bên dưới editor câu hỏi đó phải có nút "Thêm Rubric" viền xanh với icon dấu +.
  Nếu đã có rubric: hiển thị container xanh lá "Đã cấu hình X tiêu chí" + "(Nhấn để sửa)".
result: pass

### 2. Mở RubricBuilderComponent bottom sheet
expected: |
  Tap nút "Thêm Rubric" trên câu essay. Bottom sheet kéo được mở với tiêu đề "Thiết lập Rubric".
  Nút X đóng ở góc trên phải. Phần dưới: "Chọn từ Mẫu", "Lưu thành Mẫu", nút "Lưu Rubric" màu xanh.
result: issue
reported: "đổi chữ template thành tiếng việt và căn chỉnh cho đều chữ ví dụ căn giữa"
severity: minor
fixed: true
fix_note: "Đổi Template → Mẫu toàn bộ UI, thêm textAlign: center + alignment: Alignment.center cho buttons"

### 3. Thêm tiêu chí và mức điểm trong builder
expected: |
  Tap "Thêm tiêu chí", card mới xuất hiện với field tên và badge "0đ".
  Mở rộng → thêm mức điểm → badge cập nhật theo max(level.points).
result: issue
reported: "giao diện hiện chưa đồng nhất và còn xấu ô text cái to cái nhỏ"
severity: minor
fix_note: "Cần UI audit riêng — xem 03-PENDING-PLAN.md"

### 4. Lưu rubric và auto-sync điểm câu hỏi
expected: |
  Tap "Lưu Rubric" → sheet đóng, RubricSummaryButton chuyển xanh lá "Đã cấu hình X tiêu chí".
  Trường "Điểm" câu hỏi tự cập nhật = tổng criteria max_points (D-06).
result: pass

### 5. Publish bị chặn khi thiếu rubric (D-08)
expected: |
  Câu essay không có rubric → tap Xuất bản → bị chặn, viền đỏ + SnackBar (kể cả khi chỉ 1 câu).
result: issue
reported: "text lỗi trên card câu hỏi thiếu dấu tiếng Việt"
severity: minor
fixed: true
fix_note: "'Cau hoi tu luan phai co Rubric truoc khi phat hanh.' → 'Câu hỏi tự luận phải có Rubric trước khi phát hành.'"

### 6. Lưu và load mẫu
expected: |
  Lưu rubric thành mẫu qua dialog tên → SnackBar xác nhận.
  Mở builder khác → Chọn từ Mẫu → picker hiện danh sách, tap mẫu → load criteria vào builder.
result: issue
reported: "Flutter assertion lỗi khi đóng dialog 'Lưu thành Mẫu' — màn hình đỏ. Save thực tế thành công."
severity: minor
fixed: false
fix_note: "Flutter framework bug: _HighlightModeManager notifies deactivated widget khi dialog có focused TextField đóng. Cần investigate deeper."

### 7. Xóa mẫu — list cập nhật ngay
expected: |
  Tap thùng rác trong picker → dialog xác nhận → mẫu biến mất NGAY khỏi list (không cần reopen).
result: pass

### 8. Rubric bị lock khi có học sinh đang làm bài (D-09)
expected: |
  Bài tập đã phân phối có work_session → mở builder → banner vàng "Rubric đã bị khóa".
  Tất cả inputs disabled. Bottom chỉ có nút "Đóng".
result: skipped
reason: "Thiếu data — cần bài tập đã phân phối có học sinh đang làm bài (work_session tồn tại)"

### 9. Student xem rubric preview trước khi làm bài
expected: |
  Màn hình chi tiết bài tập → section "Tiêu chí chấm điểm" bên dưới câu hỏi.
  Collapsed: tóm tắt. Tap → expand xem đầy đủ levels và mô tả.
result: issue
reported: "Section 'Tiêu chí chấm điểm' không hiển thị bên dưới câu hỏi essay"
severity: major
fixed: false
fix_note: "Cần kiểm tra ReadOnlyRubricViewer có được render trong StudentAssignmentDetailScreen không"

### 10. Student xem rubric khi đang làm bài trong workspace
expected: |
  Câu essay trong workspace → nút "Xem Tiêu chí" bên trên ô nhập.
  Tap → sheet read-only mở với ReadOnlyRubricViewer.
result: issue
reported: "Không tìm thấy nút 'Xem Tiêu chí' trong workspace"
severity: major
fixed: false
fix_note: "Cần kiểm tra nút có được render trong StudentWorkspaceScreen cho câu essay có rubric không"

## Summary

total: 10
passed: 3
issues: 6
pending: 0
skipped: 1
blocked: 0

## Gaps

- truth: "UI RubricBuilderComponent không đồng nhất — ô text cái to cái nhỏ"
  status: open
  reason: "User reported: giao diện hiện chưa đồng nhất và còn xấu ô text cái to cái nhỏ"
  severity: minor
  test: 3
  artifacts: [lib/widgets/rubric/rubric_builder_component_builders.dart]
  missing: [UI audit + chuẩn hóa typography/spacing trong builder]

- truth: "Giáo viên cần được cảnh báo khi D-06 override điểm câu hỏi đáng kể"
  status: backlog
  reason: "Không có feedback khi điểm bị thay đổi âm thầm (VD: 10 → 1)"
  severity: minor
  test: 3-note
  suggestion: |
    Option A: Dialog xác nhận khi điểm thay đổi lớn
    Option B: Làm nổi bật dòng "Tổng điểm" trong bottom actions
  artifacts: [lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart]
  missing: []

---
status: deferred
phase: 03-rubric-system
source: [03-StudentWorkspaceScreen-SUMMARY.md, 03-StudentAssignmentDetailScreen-SUMMARY.md]
round: 2 (post-fix verification)
started: 2026-04-08T00:00:00Z
updated: 2026-04-08T00:00:00Z
---

## Current Test

number: 1
name: Nút "Xem Tiêu chí" trong workspace
expected: |
  Vào workspace câu essay có rubric đã cấu hình.
  Ngay trên ô nhập bài nên thấy TextButton.icon "Xem Tiêu chí".
  Tap nút → DraggableScrollableSheet mở (60–85% màn hình) với ReadOnlyRubricViewer.
  Sheet hiển thị đầy đủ tiêu chí và mức điểm. Sheet đóng khi kéo xuống.
awaiting: user response

## Tests

### 1. Nút "Xem Tiêu chí" trong workspace
expected: |
  Vào workspace câu essay có rubric đã cấu hình.
  Ngay trên ô nhập bài nên thấy TextButton.icon "Xem Tiêu chí".
  Tap nút → DraggableScrollableSheet mở (60–85% màn hình) với ReadOnlyRubricViewer.
  Sheet hiển thị đầy đủ tiêu chí và mức điểm. Sheet đóng khi kéo xuống.
result: [pending]

### 2. Section "Tiêu chí chấm điểm" trong detail screen
expected: |
  Màn hình chi tiết bài tập (trước khi bấm vào làm).
  Câu essay/short_answer có rubric → hiện card "Tiêu chí chấm điểm".
  Collapsed: tên tiêu chí + điểm max tóm tắt.
  Tap expand icon → full ReadOnlyRubricViewer với levels và mô tả.
result: [pending]

### 3. Dialog "Lưu thành Mẫu" không crash
expected: |
  Trong RubricBuilderComponent, tap "Lưu thành Mẫu".
  Dialog nhập tên mở, nhập tên → tap "Lưu".
  Dialog đóng sạch — KHÔNG có màn hình đỏ/assertion error.
  SnackBar xác nhận "Đã lưu mẫu [tên]" hiện ra.
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0

## Gaps

[none yet]

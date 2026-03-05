---
phase: 01-student-assignment-workflow
plan: "01"
subsystem: student-assignment
tags: [flutter, riverpod, assignment, student]
dependency_graph:
  requires: []
  provides: [student-assignment-list, student-assignment-detail]
  affects: [assignment-workflow]
tech_stack:
  added: [submission-entity, student-assignment-providers]
  patterns: [riverpod-future-provider, freezed-entity]
key_files:
  created:
    - lib/domain/entities/submission.dart
    - lib/domain/entities/submission.freezed.dart
    - lib/presentation/providers/student_assignment_providers.dart
    - lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
  modified:
    - lib/core/routes/app_router.dart
    - lib/presentation/views/assignment/assignment_list_screen.dart
decisions:
  - Reuse ClassDetailAssignmentListItem for student assignment list
  - Use existing studentAssignmentListProvider for data fetching
  - Follow existing design patterns from teacher views
metrics:
  duration: ~15 minutes
  completed: 2026-03-05
---

# Phase 1 Plan 1: Student Assignment Workflow Summary

## Mục tiêu

Tạo danh sách bài tập và màn hình chi tiết cho học sinh với routing.

## Hoàn thành

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create Submission entity | e356594 | submission.dart, submission.freezed.dart |
| 2 | Create student assignment providers | e356594 | student_assignment_providers.dart |
| 3 | Create student assignment list screen | e356594 | assignment_list_screen.dart |
| 4 | Create student assignment detail screen | e356594 | student_assignment_detail_screen.dart |

## Chi tiết thực hiện

### Task 1 & 2: Entity và Providers
- **Submission entity** đã tồn tại với Freezed annotation
- **student_assignment_providers.dart** đã tồn tại với các providers:
  - `studentAssignmentListProvider` - lấy danh sách bài tập
  - `studentAssignmentDetailProvider` - lấy chi tiết bài tập
  - `studentSubmissionProvider` - lấy hoặc tạo bài nộp

### Task 3: Student Assignment List Screen
- Cập nhật `AssignmentListScreen._buildStudentView()`
- Sử dụng `studentAssignmentListProvider` để fetch dữ liệu
- Tái sử dụng `ClassDetailAssignmentListItem` với `AssignmentViewMode.student`
- Thêm filter chips: All / Pending / Submitted / Graded (placeholder for future)
- Pull-to-refresh functionality
- Navigation đến detail screen khi tap

### Task 4: Student Assignment Detail Screen
- Tạo mới `StudentAssignmentDetailScreen`
- Hiển thị:
  - Header: title, description, điểm, hạn nộp
  - Thời gian còn lại (time remaining)
  - Status badge (đang mở/đã nộp/đã hết hạn)
  - Danh sách câu hỏi với type icon và điểm
  - Nút "Bắt đầu làm bài" / "Đã nộp bài"
- Thêm route trong app_router.dart:
  - `/student/assignment/:assignmentId`

## Deviations from Plan

None - plan executed exactly as written.

## Auth Gates

None - all tasks completed without authentication issues.

## Verification

```bash
flutter analyze lib/presentation/views/assignment/assignment_list_screen.dart
flutter analyze lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
flutter analyze lib/core/routes/app_router.dart
```

All passed with no issues.

## Self-Check: PASSED

- ✅ Files created exist
- ✅ Commit e356594 exists
- ✅ flutter analyze passes

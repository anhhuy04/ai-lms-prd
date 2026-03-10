---
plan: 05
phase: 01-student-assignment-workflow
status: complete
wave: 1
started: 2026-03-10
completed: 2026-03-10
---

## Summary

Gap closure plan to add navigation links to the existing submission history screen.

## Changes Made

### Task 1: Assignment List Screen ✅
**File:** `lib/presentation/views/assignment/assignment_list_screen.dart`

Added history button in AppBar for student role:
```dart
actions: [
  if (userRole == 'student')
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Lịch sử nộp bài',
      onPressed: () => context.goNamed(AppRoute.studentSubmissionHistory),
    ),
],
```

### Task 2: Submission Confirm Screen ✅
**File:** `lib/presentation/views/assignment/student/student_submission_confirm_screen.dart`

Added import for routing:
```dart
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:go_router/go_router.dart';
```

Added "Xem lịch sử nộp bài" button after "Về trang chủ" button:
```dart
const SizedBox(height: DesignSpacing.md),

// View submission history button
TextButton(
  onPressed: () {
    context.goNamed(AppRoute.studentSubmissionHistory);
  },
  child: Text(
    'Xem lịch sử nộp bài',
    style: TextStyle(
      fontSize: 16,
      color: DesignColors.primary,
      fontWeight: FontWeight.w600,
    ),
  ),
),
```

## Verification

- `flutter analyze` passed with no errors (only existing info warnings)
- Both navigation buttons are properly integrated
- Navigation uses GoRouter's `goNamed` for type-safe routing

## Gap Closure

| Test | Status |
|------|--------|
| Test 7: Xem lịch sử nộp bài | ✅ Resolved |

## Files Modified

- `lib/presentation/views/assignment/assignment_list_screen.dart`
- `lib/presentation/views/assignment/student/student_submission_confirm_screen.dart`

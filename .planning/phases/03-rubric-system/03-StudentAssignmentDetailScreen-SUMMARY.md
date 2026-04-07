---
plan: 03-StudentAssignmentDetailScreen
phase: 03-rubric-system
status: complete
wave: 4
completed: 2026-04-07
commit: 803781c
---

# Summary: StudentAssignmentDetailScreen

## What was built

Rubric preview cards integrated into `student_assignment_detail_screen.dart` — D-03 Giai đoạn 1 and 3.

## Key files

- `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart` (+159 lines net)

## Implementation

- `_buildRubricPreviewSection()` — filters essay/shortAnswer questions with rubric != null, renders one card per question
- `_RubricPreviewCard` StatefulWidget — expand/collapse toggle (Icons.expand_more/less)
  - Collapsed: compact mode (criterion names + max_points overview via ReadOnlyRubricViewer)
  - Expanded: full ReadOnlyRubricViewer with levels and descriptions
- D-03 Giai đoạn 3: same card shown in `_SubmittedView` with `selectedLevels=null` (Phase 6 placeholder)
- 100% DesignToken compliance — no raw Color/EdgeInsets/TextStyle values

## Acceptance criteria

- [x] ReadOnlyRubricViewer imported and used
- [x] Rubric preview shown before entering workspace
- [x] Submitted view has rubric foundation (selectedLevels=null)
- [x] flutter analyze: 0 errors

---
plan_id: 03-StudentWorkspaceScreen
status: complete
tasks_completed: 1/1
---
# StudentWorkspaceScreen — Summary
## What was done
- Added `rubric` field to `QuestionState` in workspace_provider.dart
- Added `_buildRubricButton()` method — shows "Xem Tiêu chí" TextButton.icon for questions with rubric != null
- Added `_showRubricSheet()` method — opens DraggableScrollableSheet (initialChildSize: 0.6, maxChildSize: 0.85) with ReadOnlyRubricViewer
- Modified `_buildEssay()` to wrap EssayAnswerField in Column with rubric button above
- D-03 compliant: sheet is purely read-only, no setState/provider mutations
- Also added `read_only_rubric_viewer.dart` to worktree (missing from worktree branch, present in main)
## Files modified
- lib/presentation/providers/workspace_provider.dart
- lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
- lib/widgets/rubric/read_only_rubric_viewer.dart (added to worktree — file from main, no changes)
## Verification
- flutter analyze: No issues found (ran in 2.8s)

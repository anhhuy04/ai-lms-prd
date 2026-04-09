---
plan: 07-04
phase: 07-ai-analytics-pipeline
status: complete
completed: 2026-04-09
self_check: PASSED
---

## What Was Built

Per-question timer in student workspace + non-blocking `submission_analytics` INSERT after submit.

**Task 1 — Per-question Stopwatch:**
- Added `_questionTimers: Map<String, Stopwatch>` and `_currentQuestionId` to workspace screen state
- `_onQuestionChanged(id)`: stops old timer, starts/resumes new timer
- `getTimeLog()`: stops active timer, returns `Map<String, int>` (seconds per question)
- Timer starts for first question on workspace load
- Question cards wrapped in `GestureDetector` to trigger `_onQuestionChanged`
- Timers disposed in `dispose()`
- `timeLog` threaded through: screen → `WorkspaceNotifier.submit()` → `AssignmentRepository` → `AssignmentDatasource`

**Task 2 — `_insertSubmissionAnalytics()`:**
- Added `timeLog: Map<String, int>?` parameter to `submitAssignment()` at all layers
- Added `settings` to `distributionFuture.select()` (D-11)
- Non-blocking try-catch wraps the analytics call — submission succeeds even if analytics fails
- `_insertSubmissionAnalytics()` method:
  - Fetches `submissions.id` from sessionId
  - Fetches `submission_answers` with final scores
  - Fetches `assignment_questions → questions(tags)` for accuracy_by_tag
  - Validates timeLog sum vs `work_sessions.time_spent_seconds` (tolerance: 60s)
  - INSERTs into `submission_analytics` with `metrics.time_per_question` and `metrics.accuracy_by_tag`

## Key Decisions

- **ListView not PageView**: Workspace uses scrollable list, not PageView. `GestureDetector(onTap)` on each card triggers `_onQuestionChanged` instead of `onPageChanged`
- **timeLog nullable**: If validation fails (sum > timeSpent + 60s), logs warning and sets null — analytics still written with accuracy_by_tag only
- **Non-blocking design (D-03)**: Analytics INSERT in try-catch after submission completes — never blocks the submit flow

## Files Modified

- `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`
- `lib/presentation/providers/workspace_provider.dart`
- `lib/domain/repositories/assignment_repository.dart`
- `lib/data/repositories/assignment_repository_impl.dart`
- `lib/data/datasources/assignment_datasource.dart`

## Commits

- `86c3074 feat(07-04): add per-question Stopwatch tracking to student workspace (D-10)`
- `2c051a0 feat(07-04): add _insertSubmissionAnalytics() + thread timeLog through submit chain (D-03, D-10)`

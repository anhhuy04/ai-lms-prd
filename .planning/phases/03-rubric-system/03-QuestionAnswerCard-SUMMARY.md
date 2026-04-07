---
phase: 3
plan: QuestionAnswerCard
subsystem: presentation
tags: [rubric, grading, widget, teacher, submission]
dependency_graph:
  requires:
    - 03-InteractiveRubricGrader
    - 03-ReadOnlyRubricViewer
  provides:
    - QuestionAnswerCard with dual rubric display modes
  affects:
    - TeacherSubmissionDetailScreen (caller)
tech_stack:
  added: []
  patterns:
    - Dumb widget with callback props for grading mode
    - Conditional widget rendering based on isGrading flag
key_files:
  modified:
    - lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
decisions:
  - Used callback-based API (not provider access) inside widget to keep it dumb/reusable
  - Guard: all 4 grading conditions must be non-null before showing InteractiveRubricGrader
  - Pre-existing bug fix: choice.id -> choice.toString() in _buildAnswerContent (Rule 1)
  - Pre-existing token violation fix: Color(0xFFF5F5F5) -> DesignColors.moonLight (Rule 2)
metrics:
  duration: ~30 minutes
  completed: 2026-04-07T00:30:00Z
  tasks_completed: 1
  tasks_total: 1
  files_modified: 1
---

# Phase 3 Plan QuestionAnswerCard: Summary

## One-liner

Replaced ad-hoc `_buildRubric()` (wrong `max_score` key, D-02 violation) with `ReadOnlyRubricViewer` for read-only and `InteractiveRubricGrader` for grading mode via new `isGrading` prop.

## What Was Built

Modified `QuestionAnswerCard` (101 → 157 lines) to:

1. **Remove** `_buildRubric()` — used incorrect `max_score` key instead of D-02's `max_points`, and didn't show level descriptions.
2. **Add** four new constructor parameters with safe defaults:
   - `isGrading: bool = false`
   - `submissionAnswerId: String?`
   - `onLevelSelected: void Function(double points, String criterionId)?`
   - `onManualOverride: void Function(double score, String reason)?`
3. **Add** `_buildRubricSection()` — conditionally renders:
   - `InteractiveRubricGrader` when `isGrading=true` and all callbacks are non-null
   - `ReadOnlyRubricViewer` in all other cases
4. All existing callers unaffected (new params default to non-grading mode).

## Commits

| Hash | Message |
|------|---------|
| f37ac62 | feat(03-QuestionAnswerCard): replace _buildRubric with ReadOnlyRubricViewer and InteractiveRubricGrader |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `choice.id.toString()` in `_buildAnswerContent`**
- **Found during:** Task 3.8 (while reading the existing file)
- **Issue:** `(choice as dynamic).id` would throw NoSuchMethodError at runtime since `choice` is a plain `dynamic` from JSON, not an object with an `.id` field.
- **Fix:** Changed to `choice.toString()` — safe for any JSON primitive.
- **Files modified:** `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart`
- **Commit:** f37ac62

**2. [Rule 2 - Missing Critical] Replaced raw color token violation**
- **Found during:** Task 3.8 (CLAUDE.md design token requirement)
- **Issue:** `Color(0xFFF5F5F5)` violates mandatory `DesignColors.*` token rule.
- **Fix:** Replaced with `DesignColors.moonLight` (light background token).
- **Files modified:** `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart`
- **Commit:** f37ac62

## Acceptance Criteria Verification

- [x] `ReadOnlyRubricViewer` imported and used in question_answer_card.dart
- [x] `InteractiveRubricGrader` imported and used in question_answer_card.dart
- [x] `isGrading` field added with `false` default
- [x] `onLevelSelected` field added as nullable callback
- [x] `onManualOverride` field added as nullable callback
- [x] `max_score` NOT present (old wrong key removed)
- [x] `_buildRubric` NOT present (replaced by `_buildRubricSection`)
- [x] `flutter analyze --no-pub`: No issues found

## Known Stubs

None. The rubric section now correctly delegates to fully-implemented Wave 1/2 widgets.

## Self-Check: PASSED

- File exists: `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` ✓
- Commit exists: f37ac62 ✓
- flutter analyze 0 errors ✓
- Plan file NOT deleted ✓

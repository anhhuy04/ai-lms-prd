---
phase: 07-ai-analytics-pipeline
plan: "05"
subsystem: teacher-grading
tags: [bug-fix, filter, grade-override, audit-trail, phase2-uat-closure]
dependency_graph:
  requires: [07-03]
  provides: [phase-2-uat-7-10a, phase-2-uat-7-10b, phase-2-uat-7-10c]
  affects: [teacher_submission_list_screen, teacher_submission_detail_screen]
tech_stack:
  added: []
  patterns: [client-side-filter, gradeOverride-invalidation]
key_files:
  created: []
  modified:
    - lib/data/datasources/submission_datasource.dart
    - lib/presentation/providers/teacher_submission_providers.dart
    - lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart
decisions:
  - "Use DB is_late from submissions table directly (set at submit time), not client-side recomputation"
  - "Show GradingActionButtons when aiScore != null OR finalScore != null (MCQ only sets finalScore)"
  - "Invalidate gradeOverrideHistoryProvider after override to refresh audit trail"
metrics:
  duration: "16m"
  completed_date: "2026-04-09"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 3
---

# Phase 7 Plan 05: Phase 2 UAT Closure — Filter + Grade Override Summary

Close Phase 2 UAT debt: fixed `is_late` filter bug and MCQ grade override visibility; grade override wiring verified end-to-end with audit trail auto-refresh.

## Tasks Completed

| Task | Description | Commit |
|------|-------------|--------|
| 1 | Fix Filter by Status bug (D-23) | 95b0d8a |
| 2 | Verify grade override wiring + audit trail (7-10b, 7-10c) | f231000 |

## What Was Built

### Task 1: Filter by Status Fix (D-23)

**Root cause found**: `getSubmissionsByDistribution()` in `submission_datasource.dart` selected `is_late` from DB (line 156) but then overwrote it with client-side computation (lines 188-199). If `assignment_distributions.due_at` was null → `is_late = false` regardless of actual value.

**Fix**: Removed client-side `is_late` overwrite. DB value (set correctly at submission time) is now used as-is.

**Filter logic was already correct** in `teacher_submission_providers.dart`:
- `SubmissionFilter.pending` ("Chưa chấm") → `status == 'submitted'` ✓
- `SubmissionFilter.late` ("Nộp muộn") → `isLate == true` ✓

Added `AppLogger.info` for filter state changes to aid debugging.

### Task 2: Grade Override Wiring + Audit Trail (7-10b, 7-10c)

**Critical bug found**: `GradingActionButtons` was guarded by `if (aiScore != null)`. MCQ auto-grading sets `final_score` only — `ai_score` stays null. This meant the "Sửa điểm" override button never appeared for MCQ submissions!

**Fix**: Changed condition to `if (aiScore != null || finalScore != null)`.

**Audit trail refresh bug found**: After `_overrideScore()`, only `teacherSubmissionDetailProvider` was invalidated. The `gradeOverrideHistoryProvider` was not invalidated, so the audit trail wouldn't refresh to show the new override record.

**Fix**: Added `ref.invalidate(gradeOverrideHistoryProvider(submissionAnswerId: answerId))` after override.

**Grade override chain verified end-to-end**:
1. `GradingActionButtons` "Sửa điểm" → `_showOverrideDialog()` → `onOverride(score, reason)` ✓
2. `_overrideScore()` → `submissionGradingNotifierProvider.overrideScore()` ✓
3. `overrideScore()` → `datasource.updateSubmissionAnswerGrade()` (updates `submission_answers.final_score`) ✓
4. `overrideScore()` → `gradeOverrideDatasource.createGradeOverride()` (inserts `grade_overrides` record) ✓
5. Audit trail: `_buildGradeAuditTrail()` → `gradeOverrideHistoryProvider` → `datasource.getOverrideHistory()` ✓
6. After override: both `teacherSubmissionDetailProvider` and `gradeOverrideHistoryProvider` invalidated ✓

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] MCQ override button never visible**
- **Found during:** Task 2
- **Issue:** `GradingActionButtons` guarded by `if (aiScore != null)`. MCQ auto-grade sets only `final_score`, not `ai_score`. Override button never shown for MCQ answers.
- **Fix:** Changed condition to `if (aiScore != null || finalScore != null)`
- **Files modified:** `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`
- **Commit:** f231000

**2. [Rule 1 - Bug] Audit trail not refreshed after override**
- **Found during:** Task 2
- **Issue:** `_overrideScore()` only invalidated `teacherSubmissionDetailProvider`, not `gradeOverrideHistoryProvider`. Audit trail showed stale data after override.
- **Fix:** Added `ref.invalidate(gradeOverrideHistoryProvider(...))` in `_overrideScore()`
- **Files modified:** `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`
- **Commit:** f231000

## Checkpoint

This plan pauses at `type="checkpoint:human-verify"` before the SUMMARY is finalized.
Human verification required: test Filter chips + grade override end-to-end in app.

## Self-Check: PASSED

- `lib/data/datasources/submission_datasource.dart` ✓ exists and modified
- `lib/presentation/providers/teacher_submission_providers.dart` ✓ exists and modified
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` ✓ exists and modified
- Commit `95b0d8a` ✓ exists
- Commit `f231000` ✓ exists

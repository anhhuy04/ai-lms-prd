---
phase: 3
plan: TeacherCreateAssignmentScreen
subsystem: presentation/assignment/teacher
tags: [rubric, assignment, teacher, wave3]
dependency_graph:
  requires:
    - 03-RubricSummaryButton
    - 03-RubricBuilderComponent
  provides:
    - RUB-03 (Attach rubric to assignment questions)
  affects:
    - teacher_create_assignment_screen.dart
tech_stack:
  added: []
  patterns:
    - showModalBottomSheet for RubricBuilderComponent
    - setState-based rubric state management
    - Supabase direct query for lock check (D-09)
key_files:
  created:
    - lib/widgets/rubric/rubric_summary_button.dart
    - lib/widgets/rubric/rubric_builder_component.dart
    - lib/widgets/rubric/rubric_builder_component_builders.dart
    - lib/widgets/rubric/rubric_template_picker_sheet.dart
    - lib/widgets/rubric/read_only_rubric_viewer.dart
    - lib/data/datasources/rubric_template_datasource.dart
  modified:
    - lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
decisions:
  - D-06 auto-sync points from rubric criteria sum when rubric saved
  - D-07 show RubricSummaryButton for both essay AND shortAnswer
  - D-08 publish hard block with per-question error border + SnackBar
  - D-09 rubric lock via assignment_distributions + work_sessions query
metrics:
  duration: ~45min
  completed: "2026-04-07"
  tasks_completed: 1
  files_changed: 7
---

# Phase 3 Plan TeacherCreateAssignmentScreen: Summary

**One-liner:** Rubric integration in TeacherCreateAssignmentScreen — RubricSummaryButton shown for essay/shortAnswer, builder opens via bottom sheet, points auto-sync (D-06), publish validation hard block (D-08), rubric edit lock from work sessions (D-09).

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 3.7 | Integrate rubric into TeacherCreateAssignmentScreen | 027cbfa | teacher_create_assignment_screen.dart + rubric widgets |

## Changes Made

### New State Variables
- `Set<int> _publishValidationErrors = {}` — tracks question indices with missing rubric on publish attempt
- `bool _isRubricLocked = false` — true when assignment has active distributions or work_sessions

### New Methods
- `_checkRubricLock()` — queries `assignment_distributions` (status='active') and `work_sessions` for this assignment, sets `_isRubricLocked`
- `_buildRubricSection(questionIndex)` — returns `RubricSummaryButton` for essay/shortAnswer, `SizedBox.shrink()` otherwise
- `_openRubricBuilder(questionIndex)` — `showModalBottomSheet` with `RubricBuilderComponent`
- `_updateRubricPoints(questionIndex, rubric)` — updates question rubric in state, auto-calculates points from criteria sum, removes publish validation error for that index
- `_validatePublishRubrics()` — iterates questions, collects essay/shortAnswer without rubric, triggers error UI, returns bool

### Modified Flows
- `_handleSaveAndPublish()` — now calls `_validatePublishRubrics()` before RPC; returns early if errors
- `_checkAndLoadAssignment()` — calls `_checkRubricLock()` after loading existing assignment
- `_buildQuestionCard()` — added `questionIndex` parameter, adds `_buildRubricSection()` before actions, adds error border + error row when index is in `_publishValidationErrors`
- `_mapQuestionsToAssignmentQuestions()` — includes `rubric` key in result if question has rubric
- `_reloadQuestionsSection()` — preserves rubric from `q.rubric` when rebuilding questions list
- `_loadAssignment()` — preserves rubric from `q.rubric` when populating UI

### New Imports
- `package:ai_mls/core/services/supabase_service.dart`
- `package:ai_mls/widgets/rubric/rubric_builder_component.dart`
- `package:ai_mls/widgets/rubric/rubric_summary_button.dart`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Rubric widget files not present in worktree**
- **Found during:** Task 3.7 start
- **Issue:** Wave 1 (RubricSummaryButton) and Wave 2 (RubricBuilderComponent) outputs were in other agent worktrees, not available in this worktree
- **Fix:** Copied all rubric widget files from parent repo (`/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD/lib/widgets/rubric/`) which already had merged outputs from other wave agents
- **Files modified:** Created `lib/widgets/rubric/` directory with 5 files, `lib/data/datasources/rubric_template_datasource.dart`
- **Commit:** 027cbfa

**2. [Rule 2 - Missing critical] Rubric not persisted through reload cycles**
- **Found during:** Task 3.7 implementation
- **Issue:** `_reloadQuestionsSection()` and `_loadAssignment()` did not include rubric when rebuilding question maps, causing rubric to be lost after reload
- **Fix:** Added `if (q.rubric != null) 'rubric': q.rubric` to both methods
- **Commit:** 027cbfa (part of main task)

## Known Stubs

None — all rubric logic is fully wired. Draft save passes rubric as-is (null allowed per D-08). Publish validation actively checks rubric presence.

## flutter analyze Result

2 pre-existing warnings (unused_local_variable, unnecessary_cast) — not introduced by this plan. 0 new errors.

## Self-Check: PASSED

- [x] `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` — modified with all required integrations
- [x] `lib/widgets/rubric/rubric_summary_button.dart` — created
- [x] `lib/widgets/rubric/rubric_builder_component.dart` — created
- [x] Commit 027cbfa — verified via `git rev-parse --short HEAD`
- [x] All acceptance criteria grep patterns match
- [x] Plan file NOT deleted

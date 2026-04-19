---
phase: 09-ai-settings-refactor-document-import
plan: "07"
subsystem: ai-generate-questions
tags: [staging-area, question-dto, freezed, polling, supabase-rpc, draggable-sheet]
dependency_graph:
  requires: [09-01, 09-04, 09-05, 09-06]
  provides: [QuestionDTO, StagingAreaWidget, polling-mechanism]
  affects: [teacher_ai_generate_question_screen, app_router]
tech_stack:
  added: [freezed, json_serializable, supabase_flutter/rpc]
  patterns: [TDD-red-green, ConsumerStatefulWidget, DraggableScrollableSheet, polling-with-timeout]
key_files:
  created:
    - lib/data/models/question_dto.dart
    - lib/data/models/question_dto.freezed.dart
    - lib/data/models/question_dto.g.dart
    - lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart
  modified:
    - lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
    - lib/core/routes/app_router.dart
    - test/unit/question_dto_test.dart
decisions:
  - "QuestionDTO uses int difficulty 1-5 (NOT string 'medium') — matches questions table schema constraint"
  - "toDbInsert() extension excludes author_id — RPC adds it server-side via auth.uid()"
  - "StagingAreaWidget: showStagingArea() helper wraps showModalBottomSheet — caller controls lifecycle"
  - "Polling reads result.extraction.questions (nested) — Plan 06 Edge Function stores extraction under result.extraction to avoid overwrite by result.vectorize checkpointing"
  - "assignmentId added to TeacherAiGenerateQuestionScreen constructor — passed from app_router extra map"
metrics:
  duration_minutes: 35
  completed_date: "2026-04-19"
  tasks_completed: 2
  tasks_total: 2
  files_created: 4
  files_modified: 3
---

# Phase 09 Plan 07: Staging Area — Output UI for Both AI Pipelines Summary

**One-liner:** StagingAreaWidget as DraggableScrollableSheet with QuestionDTO Freezed model, dual-action save via save_questions_to_assignment RPC, and ai_queue polling for the extraction pipeline.

## What Was Built

### Task 1: QuestionDTO Freezed Model (TDD Red-Green)

- `QuestionDTO`: unified DTO for both AI pipelines (extraction + generation) — fields: `type`, `content`, `choices`, `answer`, `difficulty` (int 1-5), `tags`, `defaultPoints`
- `ChoiceDTO`: nested model for multiple choice answers — fields: `id`, `text`, `isCorrect`
- `toDbInsert()` extension: converts to questions table INSERT format (excludes `author_id` — RPC adds server-side)
- `build_runner` generated `.freezed.dart` + `.g.dart` without errors
- 6 unit tests covering: fromJson (MC, TF, SA, defaults), toDbInsert, pipeline agnosticism
- TDD flow: RED (tests compile-fail) → GREEN (model created, all 6 pass)

### Task 2: StagingAreaWidget + Screen Wiring

**StagingAreaWidget** (`lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart`):
- `ConsumerStatefulWidget` displayed via `showStagingArea()` helper → `showModalBottomSheet` with `DraggableScrollableSheet` (initial 55%, min 30%, max 92%)
- Drag handle indicator (centered bar)
- Header: "Xem trước câu hỏi AI (N câu)"
- Question cards: text from `content['text']`, lettered choices (A/B/C/D), correct answer highlighted with `DesignColors.success`
- Sticky action bar with two buttons:
  - `[Lưu vào Ngân hàng]` (OutlinedButton): calls RPC with `p_assignment_id: null` — bank only (D-28: no orphan data)
  - `[Lưu và Thêm vào Đề thi]` (ElevatedButton): calls RPC with `p_assignment_id` — atomic bank+link; disabled if `assignmentId == null`
  - Both disabled with `CircularProgressIndicator` while `_isSaving`

**TeacherAiGenerateQuestionScreen** changes:
- Added `assignmentId` constructor parameter (passed through from app_router route extra)
- Added `_isPolling` + `_pollingStatus` state variables
- Added `_pollForDocumentResults(queueId)`: polls `ai_queue` every 3s, max 20 attempts (60s); on `status='completed'` reads `result.extraction.questions` → shows `showStagingArea()`; on `status='failed'` throws Exception; on timeout throws Exception
- In `_handleGenerate`: when `_processingMode == ProcessingMode.extraction && _selectedFileIds.isNotEmpty`, queries most recent ai_queue row for selected files, then calls `_pollForDocumentResults()`
- Loading overlay now shows `_pollingStatus` text (animated progress message) while polling

**app_router.dart**: reads `assignmentId` from route extra and passes to screen constructor.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Feature] Added assignmentId to screen constructor**
- **Found during:** Task 2 implementation
- **Issue:** Plan's polling code calls `widget.assignmentId` but the original constructor only had `questions` parameter. The advisor flagged this before work started.
- **Fix:** Added `final String? assignmentId` to `TeacherAiGenerateQuestionScreen` constructor; updated `app_router.dart` to read `extra?['assignmentId']` and pass it through
- **Files modified:** `teacher_ai_generate_question_screen.dart`, `app_router.dart`
- **Commit:** 33877ef

**2. [Rule 1 - Bug] ProcessingMode duplicate check**
- **Found during:** Orientation phase
- **Issue:** Plan mentioned that ContextSourcesSection might redefine `ProcessingMode` — verified via grep it's only in the screen file (Plan 05 did NOT put it in context_sources_section.dart)
- **Fix:** No action needed — no duplicate
- **Files modified:** None

**3. [Rule 2 - Missing Feature] Extraction pipeline fallback guard**
- **Found during:** Task 2 implementation
- **Issue:** Plan didn't specify what happens when extraction mode is selected but no files are chosen
- **Fix:** Added guard in `_handleGenerate`: shows warning SnackBar and returns early when `_selectedFileIds.isEmpty` in extraction mode
- **Files modified:** `teacher_ai_generate_question_screen.dart`
- **Commit:** 33877ef

## Known Stubs

None. Both save actions are fully wired to the RPC. The polling mechanism is complete. The staging area shows real data from `result.extraction.questions`.

Note: The generation pipeline (RAG path via `match_document_chunks`) is NOT implemented in this plan — the plan's scope for Task 2 focused on the extraction pipeline polling. The generation pipeline falls through to the existing inline AI generation which shows the legacy `_generatedQuestions` list view (not StagingAreaWidget). This is consistent with the plan scope.

## Self-Check: PASSED

All created files exist on disk. All commits verified in git log:
- 1d64b23: test(09-07) — failing tests (RED)
- a00d365: feat(09-07) — QuestionDTO model (GREEN)
- 33877ef: feat(09-07) — StagingAreaWidget + screen wiring

---
phase: 09-ai-settings-refactor-document-import
plan: "05"
subsystem: ui
tags: [file-picker, teacher-files, context-sources, ai-mode-toggle, riverpod, consumer-widget]
dependency_graph:
  requires: [09-02-file_picker-installed, 09-04-TeacherFileDataSource-provider]
  provides: [ContextSourcesSection widget, ProcessingMode enum, AiQuestionSettingsScreen wired to real data]
  affects: [09-07-generate-action-wiring]
tech_stack:
  added: [file_picker ^11.0.2 added to main pubspec (was missing from main branch)]
  patterns: [ConsumerStatefulWidget for local selection state + ref.watch, ConsumerWidget conversion for settings screen]
key_files:
  created:
    - lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart
  modified:
    - lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
    - lib/presentation/views/settings/ai_question_settings_screen.dart
    - pubspec.yaml
decisions:
  - file_picker added to main pubspec.yaml directly (parallel agent worktree had it, main branch did not)
  - FilePicker.pickFiles() static method used (v11 API, not FilePicker.platform.pickFiles())
  - _selectedFileIds and _processingMode logged in generate action as placeholder for Plan 07 wiring
  - AiQuestionSettingsScreen converted from StatelessWidget to ConsumerWidget to watch teacherFilesProvider
metrics:
  duration: ~15 minutes
  completed: 2026-04-19
  tasks_completed: 2
  files_modified: 4
---

# Phase 9 Plan 05: ContextSourcesSection + AI Mode Toggle + Settings Document Library Summary

**One-liner:** New ContextSourcesSection ConsumerStatefulWidget with selectable file chips and [+] upload ActionChip; AI mode toggle (Extraction/Generation) integrated into TeacherAiGenerateQuestionScreen; AiQuestionSettingsScreen converted to ConsumerWidget showing real teacherFilesProvider file list.

## What Was Done

### Task 1: Create ContextSourcesSection widget

Created `lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart`.

- `ConsumerStatefulWidget` + `ConsumerState` for local `_selectedFileIds` Set state
- `ref.watch(teacherFilesProvider)` with three branches:
  - `AsyncLoading` → `Shimmer.fromColors` row of 3 placeholder chip-shaped containers
  - `AsyncError` → error text + retry button via `ref.invalidate(teacherFilesProvider)`
  - `AsyncData(files)` → `Wrap` of `FilterChip` per `TeacherFileModel` + `ActionChip` [+] at end
- `FilterChip`: label truncated to 20 chars, `selected` drives visual, `CircularProgressIndicator` avatar when `processingStatus == 'queued'/'processing'`
- `_pickAndUploadFile()` uses `FilePicker.pickFiles()` (v11 static API, `withData: true`, xlsx/docx extensions)
- After upload: `ref.read(teacherFilesProvider.notifier).uploadFile(bytes, filename, mimeType)`
- All colors via `DesignColors.*`, spacing via `DesignSpacing.*`

**Deviation (Rule 3 - Blocker):** `file_picker: ^11.0.2` was missing from `pubspec.yaml` in the main branch (the feat commit `ff6a829` from Plan 02 only existed in the parallel agent worktree, not merged to main). Added it directly and ran `flutter pub get`. Additionally, the correct API for file_picker v11 is `FilePicker.pickFiles()` (static method) not `FilePicker.platform.pickFiles()` (older API). Fixed to resolve analyze error.

### Task 2: Integrate into TeacherAiGenerateQuestionScreen + update AiQuestionSettingsScreen

**TeacherAiGenerateQuestionScreen:**
- Added `enum ProcessingMode { extraction, generation }` at file level
- Added `_selectedFileIds` and `_processingMode` state variables
- Added `_buildModeToggle()` — `SegmentedButton<ProcessingMode>` with Extraction/Generation options and description text
- Added `_buildContextSources()` — wraps `ContextSourcesSection` with `onSelectionChanged` callback
- Both sections inserted into form Column after `_buildQuestionTypeSection()` with `DesignSpacing.xxl` separators
- `AppLogger.info()` logs `_selectedFileIds` + `_processingMode` in the generate action (placeholder for Plan 07 wiring, also resolves `unused_field` warning)

**AiQuestionSettingsScreen:**
- Converted from `StatelessWidget` to `ConsumerWidget` (build signature → `build(context, ref)`)
- `_buildDocumentLibrarySection` now accepts `WidgetRef ref` parameter
- `ref.watch(teacherFilesProvider)` drives three states: shimmer loading (3 ListTile skeletons), error text, or file list
- File list shows `ListTile` per file with icon, filename, processing status subtitle + trailing indicator
- Empty state preserves friendly "Chưa có tài liệu nào" message

## Verification

```
flutter analyze lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart
→ No issues found.

flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart lib/presentation/views/settings/ai_question_settings_screen.dart
→ No issues found.

flutter analyze lib/presentation/views/assignment/teacher/ lib/presentation/views/settings/
→ 2 pre-existing unused_element warnings in unrelated files (not in plan scope). Zero new issues.
```

## Commits

| Task | Hash | Message |
|------|------|---------|
| Task 1 | b2a3f27 | feat(09-05): create ContextSourcesSection widget + add file_picker to pubspec |
| Task 2 | 0611fc2 | feat(09-05): integrate ContextSourcesSection + AI mode toggle into generate screen; wire teacherFilesProvider to settings screen |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocker] file_picker missing from main pubspec.yaml**
- **Found during:** Task 1
- **Issue:** Plan 02 feat commit `ff6a829` only existed on branch `worktree-agent-aa9dac85`, not merged to main. Main branch pubspec.yaml didn't have `file_picker: ^11.0.2`.
- **Fix:** Added `file_picker: ^11.0.2` to pubspec.yaml, ran `flutter pub get`
- **Files modified:** pubspec.yaml, pubspec.lock
- **Commit:** b2a3f27

**2. [Rule 1 - Bug] Wrong FilePicker API for v11**
- **Found during:** Task 1 (analyze error)
- **Issue:** Plan spec used `FilePicker.platform.pickFiles()` (file_picker v8 API). v11 uses static `FilePicker.pickFiles()`.
- **Fix:** Changed to `FilePicker.pickFiles()` static method
- **Files modified:** context_sources_section.dart
- **Commit:** b2a3f27

## Known Stubs

- `_selectedFileIds` and `_processingMode` are captured in state and logged but not yet passed to the AI generate RPC call. Plan 07 will wire these into the actual API request payload.

## Self-Check: PASSED

- `lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart` FOUND
- `ContextSourcesSection` is `ConsumerStatefulWidget`: FOUND
- `teacherFilesProvider` imported and watched: FOUND
- `ProcessingMode` enum defined at file level: FOUND
- `_buildModeToggle()` in generate screen: FOUND
- `_buildContextSources()` in generate screen: FOUND
- AiQuestionSettingsScreen extends ConsumerWidget: FOUND
- commit b2a3f27: FOUND (git log confirms)
- commit 0611fc2: FOUND (git log confirms)

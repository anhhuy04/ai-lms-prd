---
phase: 09-ai-settings-refactor-document-import
plan: "04"
subsystem: database
tags: [flutter, riverpod, freezed, supabase, file-upload, clean-architecture]

requires:
  - phase: 09-01
    provides: files + file_links + ai_queue DB tables, Storage bucket teacher-documents
  - phase: 09-02
    provides: file_picker approved and installed

provides:
  - TeacherFileModel (Freezed, @JsonKey snake_case mapping, processingStatus default='queued')
  - TeacherFileDataSource (uploadAndRegisterFile D-05 pipeline, getTeacherFiles via file_links join)
  - ITeacherFileRepository interface in domain layer
  - TeacherFileRepositoryImpl delegating to datasource with error logging
  - teacherFilesProvider (AsyncNotifier, exposes uploadFile action)
  - teacherFileRepositoryProvider (builds with Supabase.instance.client)

affects:
  - 09-05 (ContextSourcesSection uses teacherFilesProvider)
  - 09-06 (StagingArea uses TeacherFileModel)
  - 09-07 (RAG wiring uses file_id from TeacherFileModel)

tech-stack:
  added: []
  patterns:
    - "D-05 upload pipeline: Storage → files INSERT → file_links INSERT → ai_queue INSERT → return immediately"
    - "Private bucket: createSignedUrl() 7-day expiry (NOT getPublicUrl)"
    - "Supabase.instance.client (no supabaseClientProvider in codebase)"
    - "@JsonKey snake_case mapping on all DB column name differences"
    - "getTeacherFiles null-guard: whereType<Map<String,dynamic>>() after r['files'] cast"

key-files:
  created:
    - lib/data/models/teacher_file_model.dart
    - lib/data/models/teacher_file_model.freezed.dart
    - lib/data/models/teacher_file_model.g.dart
    - lib/data/datasources/teacher_file_datasource.dart
    - lib/domain/repositories/teacher_file_repository.dart
    - lib/data/repositories/teacher_file_repository_impl.dart
    - lib/presentation/providers/teacher_file_notifier.dart
    - lib/presentation/providers/teacher_file_notifier.g.dart
  modified:
    - test/unit/teacher_file_datasource_test.dart

key-decisions:
  - "processingStatus is NOT a DB column — injected client-side as 'queued' on upload, @Default('queued') handles absent key in fromJson"
  - "Private bucket teacher-documents uses createSignedUrl() (7-day expiry), NOT getPublicUrl()"
  - "ai_queue column is 'payload' NOT 'request_payload' — confirmed from existing process-ai-queue edge function"
  - "Supabase.instance.client used directly (no supabaseClientProvider exists in codebase)"
  - "flutter_riverpod import needed for Ref type in provider function signature"

patterns-established:
  - "TeacherFiles class name → generator produces teacherFilesProvider"
  - "uploadFile optimistic: state = AsyncLoading() → AsyncValue.guard → prepend new file"

requirements-completed: ["9-02"]

duration: 25min
completed: 2026-04-19
---

# Phase 09 Plan 04: TeacherFileDataSource + Clean Architecture Upload Pipeline Summary

**Freezed TeacherFileModel + 5-step upload pipeline (Storage → files → file_links → ai_queue) + teacherFilesProvider AsyncNotifier for Plan 05 consumption**

## Performance

- **Duration:** 25 min
- **Started:** 2026-04-19T08:15:00Z
- **Completed:** 2026-04-19T08:40:00Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- TeacherFileModel with full @JsonKey snake_case mapping and @Default('queued') processingStatus
- TeacherFileDataSource implements D-05 5-step pipeline atomically (uploadAndRegisterFile)
- ITeacherFileRepository interface in domain layer; impl delegates with error logging
- teacherFilesProvider (AsyncNotifier) ready for Plan 05 ContextSourcesSection to consume
- 4 model unit tests pass (fromJson, default field, round-trip, copyWith)

## Task Commits

1. **Task 1: TeacherFileModel (Freezed) + TeacherFileDataSource** - `9953d76` (feat)
2. **Task 2: Repository interface + impl + Riverpod provider** - `ddb2839` (feat)

## Files Created/Modified

- `lib/data/models/teacher_file_model.dart` — Freezed model with @JsonKey annotations
- `lib/data/models/teacher_file_model.freezed.dart` — Generated Freezed code
- `lib/data/models/teacher_file_model.g.dart` — Generated JSON serialization
- `lib/data/datasources/teacher_file_datasource.dart` — D-05 upload pipeline (4 Supabase ops)
- `lib/domain/repositories/teacher_file_repository.dart` — ITeacherFileRepository interface
- `lib/data/repositories/teacher_file_repository_impl.dart` — Implementation with error logging
- `lib/presentation/providers/teacher_file_notifier.dart` — TeacherFiles AsyncNotifier
- `lib/presentation/providers/teacher_file_notifier.g.dart` — Generated provider code
- `test/unit/teacher_file_datasource_test.dart` — 4 model tests enabled (W0 stub updated)

## Decisions Made

- `processingStatus` is a client-side field (not in `files` DB schema) — injected via `{...fileRow, 'processing_status': 'queued'}` on upload; `@Default('queued')` handles absent key in getTeacherFiles
- Private bucket requires `createSignedUrl()` with 7-day expiry — `getPublicUrl()` does not work on private buckets
- `payload` column name confirmed (NOT `request_payload`) from existing `process-ai-queue/index.ts`
- `Supabase.instance.client` used directly — no `supabaseClientProvider` exists in this codebase
- `flutter_riverpod` import needed for `Ref` type alongside `riverpod_annotation` for `@riverpod` annotation

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Added flutter_riverpod import for Ref type**
- **Found during:** Task 2 (analyzing notifier)
- **Issue:** Plan's code snippet didn't import `flutter_riverpod` — `Ref` was undefined
- **Fix:** Added `import 'package:flutter_riverpod/flutter_riverpod.dart';` to notifier
- **Files modified:** lib/presentation/providers/teacher_file_notifier.dart
- **Verification:** `flutter analyze` exits 0 after fix
- **Committed in:** ddb2839 (Task 2 commit)

**2. [Rule 2 - Missing Critical] Added null-guard in getTeacherFiles**
- **Found during:** Task 1 (code review per advisor guidance)
- **Issue:** `r['files'] as Map<String, dynamic>` would throw if join returns null
- **Fix:** Changed to `.whereType<Map<String, dynamic>>()` filter after nullable cast
- **Files modified:** lib/data/datasources/teacher_file_datasource.dart
- **Verification:** Dart type-safe, no runtime cast exception possible
- **Committed in:** 9953d76 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical null-guard)
**Impact on plan:** Both necessary for correctness. No scope creep.

## Issues Encountered

None — plan executed cleanly after the 2 auto-fixes above.

## Known Stubs

None — all required functionality implemented. Datasource tests remain skipped (W0 contract: require live Supabase).

## Next Phase Readiness

- `teacherFilesProvider` is ready for Plan 05 (ContextSourcesSection) to consume via `ref.watch(teacherFilesProvider)`
- `uploadFile(bytes, filename, mimeType)` action exposed for file picker integration
- Plan 05 can use `teacherFileRepositoryProvider` for direct repo access if needed

---
*Phase: 09-ai-settings-refactor-document-import*
*Completed: 2026-04-19*

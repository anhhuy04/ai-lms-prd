---
phase: 09-ai-settings-refactor-document-import
verified: 2026-04-19T00:00:00Z
status: passed
score: 3/3 success criteria verified
re_verification: false
---

# Phase 09: AI Settings Refactor + Document Import — Verification Report

**Phase Goal:** Cải thiện trải nghiệm tạo câu hỏi AI — refactor trang cài đặt AI và thêm tính năng import tài liệu (Excel/Word) để AI tự động phân tích và sinh câu hỏi
**Verified:** 2026-04-19
**Status:** PASSED
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths (Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Trang cài đặt AI (gear icon) chỉ hiển thị config liên quan đến AI tạo câu hỏi | VERIFIED | `AiQuestionSettingsScreen` has 3 sections: API Key, Thư viện Tài liệu, Công cụ — no unrelated settings. Gear icon at line 1061 in `teacher_ai_generate_question_screen.dart` calls `context.pushNamed(AppRoute.aiQuestionSettings)` |
| 2 | Giáo viên có thể upload file Excel/Word từ màn hình tạo câu hỏi AI | VERIFIED | `ContextSourcesSection` uses `file_picker` with `allowedExtensions: ['xlsx', 'docx']`, bytes flow through `ref.read(teacherFilesProvider.notifier).uploadFile(...)` → `TeacherFileRepositoryImpl` → `TeacherFileDataSource.uploadAndRegisterFile()` → Supabase Storage + files + file_links + ai_queue tables |
| 3 | AI phân tích tài liệu và trả về danh sách câu hỏi có thể lưu vào Question Bank | VERIFIED | Edge Function `process-document-queue/index.ts` (362 lines): heuristic router (Fast Track/LLM Fallback), mammoth.js for Word, Gemini extraction prompt, stores `result.extraction.questions`. `_pollForDocumentResults()` in teacher screen polls `ai_queue` every 3s (max 60s), on completion calls `showStagingArea()` → `StagingAreaWidget` with two save buttons calling `save_questions_to_assignment` RPC |

**Score: 3/3 truths verified**

---

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `lib/presentation/views/settings/ai_question_settings_screen.dart` | VERIFIED | 383 lines. Full ConsumerWidget with API Key tile, Thư viện Tài liệu section (real file list from `teacherFilesProvider` with shimmer loading), Công cụ section with Excel template download |
| `lib/core/routes/route_constants.dart` | VERIFIED | `aiQuestionSettings = 'ai-question-settings'`, path `/settings/ai-questions`, included in `canAccessRoute` teacher set at line 449 |
| `lib/core/routes/app_router.dart` | VERIFIED | GoRoute at line 841: `path: AppRoute.aiQuestionSettingsPath`, `name: AppRoute.aiQuestionSettings`, `builder: (context, state) => const AiQuestionSettingsScreen()` |
| `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart` | VERIFIED | Gear icon at line 1061: `context.pushNamed(AppRoute.aiQuestionSettings)`. Imports `context_sources_section.dart` and `staging_area_widget.dart`. `ProcessingMode` enum, `_selectedFileIds`, `_pollForDocumentResults()` all present |
| `lib/data/models/teacher_file_model.dart` | VERIFIED | Freezed model with 9 fields: id, filename, storagePath, url, mimeType, sizeBytes, uploadedBy, processingStatus (default 'queued'), createdAt. Generated files `.freezed.dart` and `.g.dart` exist |
| `lib/data/datasources/teacher_file_datasource.dart` | VERIFIED | 100 lines. Full 5-step pipeline: Storage upload, `files` INSERT, `file_links` INSERT (target_type='teacher'), `ai_queue` INSERT (request_type='vectorize_document'), returns immediately |
| `lib/domain/repositories/teacher_file_repository.dart` | VERIFIED | `ITeacherFileRepository` abstract class with `uploadFile()` and `getTeacherFiles()` |
| `lib/data/repositories/teacher_file_repository_impl.dart` | VERIFIED | Delegates to datasource, wraps errors with `AppLogger.error()` + rethrow |
| `lib/presentation/providers/teacher_file_notifier.dart` | VERIFIED | `@riverpod` generator. `teacherFileRepositoryProvider` and `teacherFilesProvider` (class `TeacherFiles`) with `uploadFile()` action — optimistic prepend to list |
| `lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart` | VERIFIED | 183 lines. ConsumerStatefulWidget. `FilePicker.pickFiles()` with xlsx/docx, shimmer loading, selectable `FilterChip`s, `ActionChip` to add file |
| `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart` | VERIFIED | 421 lines. `DraggableScrollableSheet` (55%/30%/92%), question cards with lettered choices, correct answer highlighted, two save buttons: `[Lưu vào Ngân hàng]` (p_assignment_id=null) and `[Lưu và Thêm vào Đề thi]` (requires assignmentId), CircularProgressIndicator while `_isSaving` |
| `lib/data/models/question_dto.dart` | VERIFIED | `QuestionDTO` Freezed model (type, content, choices, answer, difficulty as int 1-5, tags, defaultPoints). `ChoiceDTO` nested model. `toDbInsert()` extension excludes author_id. Generated `.freezed.dart` and `.g.dart` exist |
| `supabase/functions/process-document-queue/index.ts` | VERIFIED | 362 lines. Full implementation: `detectFastTrack()` heuristic router, `fastTrackMap()`, `callLLMForExtraction()` (Word + Excel LLM paths), `vectorizeDocument()` with stateful checkpointing (processed_chunks), SHA-256 content hashing (`sha256()`), Gemini text-embedding-004 (768-dim), `splitText()` chunker |

---

### Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| `teacher_ai_generate_question_screen.dart` | `AiQuestionSettingsScreen` | `context.pushNamed(AppRoute.aiQuestionSettings)` at line 1061 | WIRED |
| `app_router.dart` | `AiQuestionSettingsScreen` | GoRoute `builder` at line 843 | WIRED |
| `context_sources_section.dart` | `teacherFilesProvider` | `ref.watch(teacherFilesProvider)` + `ref.read(teacherFilesProvider.notifier).uploadFile(...)` | WIRED |
| `ai_question_settings_screen.dart` | `teacherFilesProvider` | `ref.watch(teacherFilesProvider)` in `_buildDocumentLibrarySection()` | WIRED |
| `teacher_file_notifier.dart` | `TeacherFileRepositoryImpl` | `ref.read(teacherFileRepositoryProvider).getTeacherFiles()` + `uploadFile()` | WIRED |
| `TeacherFileRepositoryImpl` | `TeacherFileDataSource` | `_dataSource.uploadAndRegisterFile()` + `_dataSource.getTeacherFiles()` | WIRED |
| `teacher_ai_generate_question_screen.dart` | `showStagingArea()` | `_pollForDocumentResults()` → `showStagingArea(questions, assignmentId, ...)` at line 416 | WIRED |
| `StagingAreaWidget` | `save_questions_to_assignment` RPC | `Supabase.instance.client.rpc('save_questions_to_assignment', params: {...})` | WIRED |
| `teacher_ai_generate_question_screen.dart` | `ContextSourcesSection` | Imported at line 15, instantiated with `onSelectionChanged` callback at line ~1891 | WIRED |

---

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `AiQuestionSettingsScreen` | `filesAsync` | `ref.watch(teacherFilesProvider)` → `ITeacherFileRepository.getTeacherFiles()` → `file_links JOIN files` Supabase query | Yes — real DB join | FLOWING |
| `ContextSourcesSection` | `filesAsync` | Same `teacherFilesProvider` — shared state | Yes — real DB join | FLOWING |
| `StagingAreaWidget` | `questions` | Prop from `showStagingArea()`, populated by `_pollForDocumentResults()` reading `ai_queue.result.extraction.questions` from Supabase | Yes — from Edge Function output | FLOWING |
| `process-document-queue/index.ts` | `result.extraction.questions` | `callLLMForExtraction()` or `fastTrackMap()` → parsed JSON array, stored via `supabase.from('ai_queue').update({result: {...}})` | Yes — real LLM/Fast Track processing | FLOWING |

---

### Behavioral Spot-Checks

Step 7b: SKIPPED for Flutter/Edge Function code (no runnable entry points without device/Supabase connection). All logic verified statically.

---

### Requirements Coverage

| Requirement | Plans | Description | Status | Evidence |
|-------------|-------|-------------|--------|----------|
| 9-01 | 09-03 | AI Settings Screen — only AI-relevant settings | SATISFIED | `AiQuestionSettingsScreen` created, gear icon route wired, no non-AI settings present |
| 9-02 | 09-04, 09-05 | Document Upload — teacher uploads Excel/Word | SATISFIED | Full upload pipeline in `TeacherFileDataSource`, `ContextSourcesSection` with `file_picker` |
| 9-03 | 09-06, 09-07 | AI analyzes document and generates questions per form template | SATISFIED | Edge Function with heuristic router + extraction pipeline; `StagingAreaWidget` with `save_questions_to_assignment` RPC |

---

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `ai_question_settings_screen.dart` | 20 | `TODO: replace <YOUR_SUPABASE_PROJECT>` in `_templateUrl` constant | Warning | Excel template download copies a placeholder URL. Does not block core AI workflows (upload, generate, save). Needs actual Supabase project ref to work. |

---

### Human Verification Required

#### 1. Excel Fast Track end-to-end

**Test:** Upload an Excel file with standard Vietnamese headers (Câu hỏi, Đáp án A, Đáp án B, Đáp án đúng) from `ContextSourcesSection`, wait for Edge Function to process, trigger extraction mode generate, verify StagingAreaWidget shows correct questions
**Expected:** Questions appear in staging area without LLM cost (fast track path), save to Question Bank succeeds
**Why human:** Requires real Supabase project with deployed Edge Function, file_picker device access, and ai_queue processing

#### 2. Word .docx extraction pipeline

**Test:** Upload a .docx exam document, trigger extraction mode, observe pollingStatus text updates, verify StagingAreaWidget appears with extracted questions
**Expected:** Questions extracted by Gemini LLM, staging area displays them, both save actions work
**Why human:** Requires running device, Supabase Edge Function deployed, Gemini API key configured

#### 3. Excel template download

**Test:** Tap "Xuất file mẫu Excel" in AiQuestionSettingsScreen
**Expected:** SnackBar appears saying URL copied. The URL itself is a placeholder (`<YOUR_SUPABASE_PROJECT>`) — this will fail in production until the TODO at line 20 is resolved
**Why human:** Requires verifying the TODO is addressed before release; functional path of Clipboard.setData works but URL is wrong

#### 4. Polling timeout handling

**Test:** Upload a file, trigger extraction mode with a very slow/failed Edge Function, wait 60 seconds
**Expected:** Error SnackBar appears "Xử lý tài liệu quá thời gian" after 20 polling attempts
**Why human:** Requires controlled test environment to simulate timeout

---

### Gaps Summary

No blocking gaps found. All 3 success criteria are fully implemented with real (non-stub) code. The only identified issue is the TODO placeholder for the Supabase project reference in the Excel template URL — this is a minor configuration item that does not block AI question generation or document upload.

**Wave completion note:** The git commit history shows all 8 plans (09-00 through 09-07) were completed, despite the git status message at conversation start referring to "paused at wave 2/4". All subsequent waves (3 and 4) were completed per the SUMMARY files and commit log.

---

_Verified: 2026-04-19_
_Verifier: Claude (gsd-verifier)_

# Phase 9 Code Review Report
**Date:** 2026-04-19  
**Reviewer:** Senior Code Review Agent  
**Scope:** Phase 9 — AI Settings Refactor + Document Import pipeline

---

## Critical Bugs (phải fix ngay)

### [BUG-01] TeacherFiles.uploadFile — Race condition xóa toàn bộ file list
**File:** `lib/presentation/providers/teacher_file_notifier.dart:43-55`  
**Severity:** Critical  
**Description:**  
`uploadFile()` gán `state = const AsyncLoading()` rồi bên trong callback của `AsyncValue.guard()` lại đọc `state.valueOrNull`. Tại thời điểm đọc, `state` đang là `AsyncLoading` nên `valueOrNull` trả về `null`. Kết quả list chỉ có 1 phần tử (file vừa upload), tất cả file cũ bị mất.

**Root Cause:**  
`AsyncLoading` không có value — `valueOrNull` trả `null`. Guard đọc state sau khi đã set Loading.

**Reproduction:**  
1. Upload file A → list có [A].  
2. Upload file B → `state = AsyncLoading` → `state.valueOrNull = null` → list = [B].  
3. File A biến mất.

**Fix:**
```dart
Future<void> uploadFile(Uint8List bytes, String filename, String mimeType) async {
  // Capture current list BEFORE setting AsyncLoading
  final current = state.valueOrNull ?? [];
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final repo = ref.read(teacherFileRepositoryProvider);
    final newFile = await repo.uploadFile(bytes: bytes, filename: filename, mimeType: mimeType);
    AppLogger.info('[TeacherFiles] Upload success: ${newFile.filename}');
    return [newFile, ...current]; // use captured list
  });
}
```

---

### [BUG-02] processingStatus mãi là 'queued' — UI không bao giờ show "Sẵn sàng"
**File:** `lib/data/models/teacher_file_model.dart:21`, `lib/presentation/views/settings/ai_question_settings_screen.dart:212`  
**Severity:** Critical (UI lie — sai trạng thái toàn bộ)  
**Description:**  
`processingStatus` là client-side field, không có trong DB `files` table. Khi `getTeacherFiles()` gọi Supabase, response JSON không có `processing_status` → Freezed dùng `@Default('queued')` → mọi file luôn show "Đang xử lý...".

Thêm vào đó: `AiQuestionSettingsScreen._buildFileListTile()` check `file.processingStatus == 'done'` nhưng Edge Function mark job là `status: 'completed'` trong `ai_queue` — không phải `'done'`. Hai giá trị này không bao giờ match dù có cơ chế sync.

**Root Cause:**  
- Không có mechanism nào cập nhật `processingStatus` trong model sau khi AI xử lý xong.  
- `ai_queue.status = 'completed'` nhưng UI check `processingStatus == 'done'` (giá trị không bao giờ được set).

**Reproduction:**  
1. Upload bất kỳ file nào.  
2. Vào Settings → Thư viện Tài liệu → mọi file đều show "Đang xử lý..." mãi mãi.  
3. Ngay cả khi AI đã hoàn thành (ai_queue.status='completed').

**Fix (2 options):**  
Option A — Join ai_queue khi query files:
```dart
// Trong getTeacherFiles(), join thêm ai_queue để đọc status thực
final rows = await _supabase
    .from('file_links')
    .select('files(*, ai_queue(status))')
    .eq('target_type', 'teacher')
    .eq('target_id', teacherId);
// Map ai_queue[0].status: 'completed' → processingStatus: 'done'
//                          'failed'    → processingStatus: 'error'
//                          other       → processingStatus: 'queued'
```
Option B — Thêm `processing_status` column vào `files` table và update sau khi Edge Function hoàn thành (DB-level tracking).

---

### [BUG-03] fastTrackMap — correctKey ambiguity → wrong answer mapping
**File:** `supabase/functions/process-document-queue/index.ts:108-111`  
**Severity:** Critical (data corruption — câu trả lời đúng bị gán sai)  
**Description:**  
`findIndex` tìm cột đáp án đúng theo thứ tự ưu tiên: `'đáp án đúng'` → `'correct'` → `'đáp án'`. Nếu không có cột `'đáp án đúng'` hoặc `'correct'` nhưng có `'đáp án A'`, `'đáp án B'`, thì `h.includes('đáp án')` sẽ match `'đáp án A'` → `correctKey = 'đáp án A'`.

Sau đó `choiceKeys` filter out `correctKey`:  
`choiceKeys = ['đáp án A', 'đáp án B', 'đáp án C'].filter(k => k !== 'đáp án A') = ['đáp án B', 'đáp án C']`

→ Đáp án A bị mất khỏi choices, và `correct_index` sẽ là index của value của ô `'đáp án A'` trong `choiceKeys` = -1 (không tìm thấy).

**Root Cause:**  
`h.includes('đáp án đúng')` match cả `'đáp án A'`, `'đáp án B'` vì chúng đều `includes('đáp án')`. `findIndex` trả về index đầu tiên match.

**Reproduction:**  
Excel có headers: `câu hỏi | đáp án A | đáp án B | đáp án C | đáp án đúng` sẽ đúng.  
Excel có headers: `câu hỏi | đáp án A | đáp án B | đáp án C` (không có cột đáp án đúng) → `correctKey = 'đáp án A'` → mọi câu hỏi bị sai đáp án.

**Fix:**
```typescript
// Tìm theo thứ tự nghiêm ngặt — chính xác hơn
const correctKey = headers[lower.findIndex(h => 
  h === 'đáp án đúng' || h === 'correct answer' || h === 'correct'
)] ?? headers[lower.findIndex(h =>
  h.includes('đáp án đúng') || h.includes('correct answer')
)];
```
Ngoài ra cần check `correct_index` là `-1` và handle gracefully thay vì silently store `-1`.

---

### [BUG-08] _templateUrl hardcoded placeholder — functional bug
**File:** `lib/presentation/views/settings/ai_question_settings_screen.dart:22`  
**Severity:** High  
**Description:**  
URL chứa `<YOUR_SUPABASE_PROJECT>` chưa được thay. Khi user tap "Xuất file mẫu Excel", URL này được copy vào clipboard. User không thể tải được template.

```dart
static const String _templateUrl =
    'https://<YOUR_SUPABASE_PROJECT>.supabase.co/storage/v1/object/public/...';
```

**Root Cause:** TODO comment chưa được resolve trước merge.  
**Fix:** Thay `<YOUR_SUPABASE_PROJECT>` bằng project ref thực tế (đọc từ `envied` hoặc environment variable), hoặc dùng `Supabase.instance.client.storageUrl` để build URL dynamically.

---

## High Severity Issues

### [BUG-04] splitText — large text không chunk, chunk cuối bị bỏ
**File:** `supabase/functions/process-document-queue/index.ts:56-81`  
**Severity:** High  
**Description:**  
Khi `sep = ''` (empty string), `sep ? text.split(sep) : [text]` → `parts = [text]` (không split). Logic vào loop với 1 part duy nhất là `text`, nếu `text > CHUNK_SIZE`:
- `candidate = text` → `candidate.length > CHUNK_SIZE` → push `currentChunk` (rỗng ban đầu, không push gì)  
- `currentChunk = overlap + text` = text (overlap từ empty chunk = '')  
- Loop kết thúc → push `currentChunk` (full text)

Kết quả: text quá lớn không thể split bằng bất kỳ separator nào sẽ tạo 1 chunk duy nhất > CHUNK_SIZE. Embedding API có thể bị truncate hoặc reject.

**Fix:**
```typescript
// Khi sep = '', thực sự split theo character (hoặc dùng slice)
const parts = sep === '' 
  ? [text] // Terminal case: push as-is, let filter(c => c.length > 20) handle
  : text.split(sep);
```
Thêm fallback chunk by `CHUNK_SIZE` slice khi không có separator nào work.

---

### [BUG-05] Polling — result có thể là null nhưng không guard đúng cách
**File:** `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart:402-405`  
**Severity:** High  
**Description:**  
```dart
final result = row['result'] as Map<String, dynamic>?;
final extraction = result?['extraction'] as Map<String, dynamic>?;
final rawQuestions = extraction?['questions'] as List? ?? [];
```
Code này AN TOÀN (null-safe). NHƯNG có vấn đề khác: `rawQuestions` chứa dynamic objects được cast `q as Map<String, dynamic>` — nếu Edge Function trả về QuestionDTO sai format, `QuestionDTO.fromJson()` sẽ throw và crash màn hình (không có try/catch xung quanh map()).

**Fix:**
```dart
final questions = rawQuestions
    .whereType<Map<String, dynamic>>()
    .map((q) {
      try {
        return QuestionDTO.fromJson(q);
      } catch (e) {
        AppLogger.warning('[Polling] Invalid question format: $e');
        return null;
      }
    })
    .whereType<QuestionDTO>()
    .toList();
```

---

### [BUG-06] Extraction result bị overwrite khi vectorize retry
**File:** `supabase/functions/process-document-queue/index.ts:324-326`  
**Severity:** High  
**Description:**  
Khi Excel extraction xong, code update:
```typescript
await supabase.from('ai_queue').update({
  result: { extraction: { questions, path: 'fast_track' } },
}).eq('id', job.id);
```
Đây là REPLACE toàn bộ `result` column. Nếu job đã có `result.vectorize` từ lần chạy trước (partial vectorize), toàn bộ `vectorize` checkpoint bị xóa. Job retry sẽ phải vectorize lại từ đầu (không resume được).

**Root Cause:** Supabase `.update()` với JSON object là replace, không merge. `vectorizeDocument` đọc `job.result` (stale — trước khi extraction update) làm `existingResult` → sau khi extraction update `result`, `vectorizeDocument` merge từ stale result → overwrite extraction.

**Fix:** Đọc lại `result` từ DB sau extraction update, trước khi pass vào `vectorizeDocument`:
```typescript
const { data: freshJob } = await supabase
  .from('ai_queue').select('result').eq('id', job.id).single();
await vectorizeDocument(supabase, fileId, job.id, fileBytes, file.mime_type, apiKey, freshJob?.result);
```

---

### [BUG-07] getTeacherFiles — order by `created_at` trên `file_links` nhưng cột thuộc `files`
**File:** `lib/data/datasources/teacher_file_datasource.dart:91`  
**Severity:** High  
**Description:**  
```dart
.order('created_at', ascending: false)
```
Query đang join `file_links` và select `files(*)`. `created_at` được order trên bảng `file_links` (không phải `files`). Nếu `file_links` không có `created_at` hoặc có timestamp khác `files.created_at`, sort order sẽ sai.

**Fix:**
```dart
.order('files(created_at)', ascending: false)
// Hoặc order trên file_links nếu file_links cũng có created_at và đây là intent
```
Cần verify `file_links` schema có `created_at` không.

---

### [BUG-09] teacherFileRepository dùng `Ref` thay vì generated `TeacherFileRepositoryRef`
**File:** `lib/presentation/providers/teacher_file_notifier.dart:17`  
**Severity:** Medium  
**Description:**  
```dart
@riverpod
ITeacherFileRepository teacherFileRepository(Ref ref) { ... }
```
Riverpod generator tạo `typedef TeacherFileRepositoryRef = AutoDisposeProviderRef<ITeacherFileRepository>` và deprecate nó. Dùng `Ref` là pattern đúng trong Riverpod 3.x (generator deprecates typed refs). Tuy nhiên trong codebase này (Riverpod 2.x với generator), `Ref` là `ProviderRef<Object?>` — vẫn compile nhưng mất type safety.

**Severity:** Low (chỉ là incorrect pattern, không runtime bug do generated code vẫn đúng)

---

## Architecture Issues

### [ARCH-01] `processingStatus` là ephemeral client field nhưng được dùng như persistent state
**File:** `lib/data/models/teacher_file_model.dart`  
**Description:**  
`processingStatus` là client-side field (không có trong DB). Khi app restart hoặc navigate away và back, `getTeacherFiles()` trả về models với `processingStatus='queued'` (default) cho tất cả files — kể cả file đã xử lý xong từ trước. UI luôn sai. Thiết kế này thiếu source of truth.

**Recommended Fix:** Thêm cột `processing_status` vào DB `files` table và update từ Edge Function, hoặc join với `ai_queue.status` khi query.

---

### [ARCH-02] StagingAreaWidget gọi Supabase.instance trực tiếp — bypass Clean Architecture
**File:** `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart:69-75`  
**Description:**  
```dart
await Supabase.instance.client.rpc('save_questions_to_assignment', ...);
```
Widget tầng Presentation gọi trực tiếp Supabase. Theo Clean Architecture pattern của codebase, cần đi qua DataSource → Repository → UseCase/Provider.

---

### [ARCH-03] TeacherAiGenerateQuestionScreen gọi Supabase.instance trực tiếp cho polling
**File:** `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart:394`  
**Description:**  
Screen chứa Supabase query logic (`ai_queue` polling) trực tiếp trong UI layer. Nếu polling logic cần thay đổi (e.g., dùng Realtime subscriptions thay polling), phải sửa UI code.

---

### [ARCH-04] `onComplete` callback trong StagingAreaWidget — confused responsibility
**File:** `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart:84`  
**Description:**  
`onComplete` callback gọi `setState(() { _generatedQuestions = questions.map((q) => q.content).toList(); })` trong parent, nhưng `q.content` là `Map<String, dynamic>` (metadata) thay vì full question data. Mapping này không nhất quán với cách `_generatedQuestions` được dùng ở chỗ khác trong screen.

---

## Minor Issues

### [MINOR-01] ContextSourcesSection — emoji trong Text widget
**File:** `lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart:76`  
**Description:** `'📚 Nguồn Dữ Liệu Tham Khảo'` dùng emoji inline. Theo project convention (CLAUDE.md: "Avoid adding emojis to files unless asked").

---

### [MINOR-02] AppLogger không được dùng trong StagingAreaWidget
**File:** `lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart`  
**Description:** Errors trong `_saveToBank()` và `_saveAndAddToAssignment()` chỉ show SnackBar mà không log. Nên thêm `AppLogger.error()` để trace lỗi production.

---

### [MINOR-03] AiQuestionSettingsScreen._buildDocumentLibraryLoading — raw hardcoded sizes
**File:** `lib/presentation/views/settings/ai_question_settings_screen.dart:137-154`  
**Description:** Dùng `width: 40`, `height: 40`, `width: double.infinity`, `height: 14`, `height: 12` là raw values. Theo Design System, nên dùng `DesignSpacing.*` và `DesignRadius.*`.

---

### [MINOR-04] _SectionCard dùng raw `const SizedBox(height: 12)` và `const SizedBox(width: 8)`
**File:** `lib/presentation/views/settings/ai_question_settings_screen.dart:344-345`  
**Description:** Raw spacing values thay vì `DesignSpacing.*` tokens.

---

### [MINOR-05] getTeacherFiles dùng `ref.read()` trong `build()` — nên dùng `ref.watch()`
**File:** `lib/presentation/providers/teacher_file_notifier.dart:33`  
**Description:**  
```dart
Future<List<TeacherFileModel>> build() async {
  return ref.read(teacherFileRepositoryProvider).getTeacherFiles();
}
```
Trong `build()`, nên dùng `ref.watch(teacherFileRepositoryProvider)` để provider rebuild khi repository thay đổi. `ref.read()` trong build là anti-pattern theo Riverpod docs.

---

### [MINOR-06] AiQuestionSettingsScreen — `error` state không có retry button
**File:** `lib/presentation/views/settings/ai_question_settings_screen.dart:107-114`  
**Description:** Error state chỉ show text "Lỗi tải tài liệu" mà không có nút Retry, khác với `ContextSourcesSection` đã implement retry đúng.

---

### [MINOR-07] TeacherFileDataSource — signed URL có 7-day expiry có thể stale
**File:** `lib/data/datasources/teacher_file_datasource.dart:39-41`  
**Description:** URL được tạo một lần khi upload và lưu vào `files.url`. Sau 7 ngày, URL hết hạn nhưng DB vẫn lưu URL cũ. Các lần query sau sẽ trả về URL đã expired. Cần refresh URL khi `getTeacherFiles()` hoặc handle 403 gracefully.

---

### [MINOR-08] Missing `_isPolling` guard trong `_handleGenerate`
**File:** `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart:511-545`  
**Description:** Khi `_processingMode == extraction` và đang poll, user có thể tap Generate lại vì button disable check chỉ dùng `_isGenerating`. Sau khi `_pollForDocumentResults` set `_isGenerating = true` và `_isPolling = true`, button vẫn disabled. NHƯNG khi poll kết thúc (success/fail), cả hai được reset. Nếu user tap lại ngay lúc `_isPolling = false` nhưng staging area đang mở, sẽ tạo thêm poll request thứ 2. Minor race window.

---

## Security Notes

### [SEC-01] teacherId lấy từ `supabase.auth.currentUser?.id ?? ''`
**File:** `lib/presentation/providers/teacher_file_notifier.dart:19`  
**Description:** Nếu `currentUser` là null (not logged in), `teacherId = ''`. Query `getTeacherFiles('')` sẽ trả về rỗng (OK nhờ RLS). Upload với `teacherId=''` sẽ upload vào `teachers//filename` path và tạo record với `uploaded_by=''` — cần RLS block để ngăn. Nên guard: `if (teacherId.isEmpty) throw Exception('Not authenticated')`.

---

### [SEC-02] file_links join không filter target_type trong model layer
**File:** `lib/data/datasources/teacher_file_datasource.dart:88-92`  
**Description:** Query đã filter `target_type='teacher'` ở datasource — đúng. RLS cũng cần đảm bảo teacher chỉ thấy file_links của mình (via `target_id = auth.uid()`). Đây là note để verify RLS policy, không phải bug trong code.

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| Critical | 3 | BUG-01 (race condition mất files), BUG-02 (processingStatus never updated), BUG-03 (wrong answer mapping) |
| High | 5 | BUG-04 (splitText edge case), BUG-05 (QuestionDTO parse crash), BUG-06 (extraction overwrite on retry), BUG-07 (wrong order-by column), BUG-08 (placeholder URL) |
| Medium | 2 | BUG-09 (Ref type), SEC-01 (empty teacherId guard) |
| Low | 8 | ARCH-01~04, MINOR-01~08 |

**Total: 3 Critical, 5 High, 2 Medium, 8 Low/Architecture**

### Top 3 Fix Priority:
1. **BUG-01** — Fix race condition in `uploadFile()` (1 line change, instant data loss fix)
2. **BUG-02** — Fix processingStatus never updating (need DB join or column — architectural fix)  
3. **BUG-03** — Fix `fastTrackMap` correctKey matching (wrong answers silently stored in DB)

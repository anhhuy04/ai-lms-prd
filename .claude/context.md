# AI LMS Flutter Android — Context tổng hợp

## BỐI CẢNH DỰ ÁN

Dự án: AI LMS Flutter Android
Working dir: `/mnt/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD`
Git branch: `main`
Ngày cập nhật context: 2026-04-29
Model tốt nhất để làm việc: claude-opus-4-7

## VẤN ĐỀ GỐC ĐÃ ĐƯỢC FIX

**Bug:** Mode 3 (RAG Generation) của màn hình tạo câu hỏi AI (`TeacherAiGenerateQuestionScreen`) sao chép câu hỏi nguyên văn từ file Excel mẫu thay vì tạo câu mới. Hai root cause:
- Root A: Code cũ gửi toàn bộ text câu hỏi gốc lên AI → AI có thể paraphrase/copy
- Root B: Tags như `"r=5, S=78.5"` leak đáp án cho AI qua side channel

## KIẾN TRÚC GIẢI PHÁP (ĐÃ IMPLEMENT)

### 2 Sub-mode cho Template
- `TemplateMode.styleOnly` (default, anti-leak): AI chỉ thấy metadata (type + difficulty + tags đã sanitize). KHÔNG gửi text câu hỏi gốc, KHÔNG gửi options. AI buộc tạo hoàn toàn mới.
- `TemplateMode.sameForm` (math drill): Gửi text + options đã shuffle (ẩn đáp án đúng). AI giữ cấu trúc, đổi số liệu. Chỉ dùng khi toàn bộ template là MCQ.

### 5 Lớp phòng thủ
1. Schema-only context (`_buildSchemaOnlyContext`) — không gửi text câu gốc
2. Tags sanitization (`_sanitizeTagsForSchema`) — strip số, operator, keyword đáp án
3. Universal prompt với CẤM TUYỆT ĐỐI ở primacy VÀ recency
4. Post-hoc similarity verification (Levenshtein + Jaccard bigram, CPU-only)
5. Validation per-call (choices count, dedup, empty text)

---

## FILE PATHS QUAN TRỌNG

### Files mới tạo
```
lib/domain/entities/template_mode.dart
  → enum TemplateMode { styleOnly, sameForm }

lib/core/services/template_similarity_verifier.dart
  → TemplateSimilarityVerifier class
  → CPU-only: Levenshtein normalized + Jaccard bigram
  → Thresholds: 0.55=warn, 0.75=regenerate, 0.88=drop
  → SimilarityAction enum: pass | warn | regenerate | drop
```

### Files đã chỉnh sửa (Tier 1)
```
lib/presentation/providers/ai_generation_settings_notifier.dart
  → AiGenerationConfig thêm: templateMode = TemplateMode.styleOnly
  → AiGenerationSettingsNotifier thêm: void setTemplateMode(TemplateMode mode)

lib/domain/repositories/ai_repository.dart
  → generateQuestions() thêm params: TemplateMode? templateMode, List<Map>? templateQuestions

lib/data/datasources/ai_datasource.dart
  → generateQuestions() pass-through TemplateMode? templateMode

lib/data/repositories/ai_repository_impl.dart
  → Import: template_similarity_verifier.dart, template_mode.dart
  → generateQuestions() thêm params templateMode + templateQuestions
  → Resolver: useAsStyleTemplate=true + templateMode=null → TemplateMode.styleOnly (backward compat)
  → Method _applyTemplateVerification(): chạy verifier, xử lý warn/regenerate/drop, retry budget=1
  → Method _mapAiQuestionToStandardFormat(): extended validation:
    - Dedup choices theo text (giữ thứ tự, bỏ trùng) — TRƯỚC correct count check
    - Trim true_false → 2 (giữ correct trước)
    - Pad MCQ → 4 (thêm dummy)
    - Validate question text không rỗng

lib/core/services/ai_service.dart
  → getGenerateQuestionsPrompt() thêm: TemplateMode? templateMode param
  → Template branch switch trên resolvedMode:
    - styleOnly → _buildStyleOnlyPrompt()
    - sameForm → _buildSameFormPrompt()
  → _buildStyleOnlyPrompt(): primacy "OUTPUT: JSON ARRAY thuần túy..." + "CẤM TUYỆT ĐỐI..."
  → _buildSameFormPrompt(): 3 chain-of-thought examples toán học

lib/presentation/providers/local_temp_file_notifier.dart
  → getKnowledgeContextForIds(ids, {TemplateMode templateMode}) — new signature
  → styleOnly → _buildSchemaOnlyContext(f): metadata only, no question text
  → sameForm → _buildTemplateStyleContext(f): text + options shuffled
  → _sanitizeTagsForSchema(): strip số, "=", "→", "≈", keywords đáp án
  → _formatTypeForSchema(): convert QuestionType → human string

lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
  → State fields mới:
    - TemplateMode? _effectiveTemplateMode (null=not detected yet)
    - List<Map>? _templateQuestionsForVerify (câu mẫu gốc cho verifier)
    - bool _templateAllMcq (chip "Cùng dạng" chỉ enable khi true)
  → _handleGenerate() Mode 3:
    - Detect allMcq, auto-downgrade sameForm→styleOnly nếu non-MCQ
    - Set _effectiveTemplateMode, _templateQuestionsForVerify, _templateAllMcq
    - Truyền templateMode: + templateQuestions: vào cả 2 call (auto + multi-type)
  → _handleRegenerateSingle():
    - getKnowledgeContextForIds(..., templateMode: _effectiveTemplateMode ?? styleOnly)
    - generateQuestions(..., templateMode: _effectiveTemplateMode, templateQuestions: _templateQuestionsForVerify)
  → UI: _buildTemplateModeChips() — 2 chip "Tạo mới" / "Cùng dạng"
    - Chỉ hiện khi _useAsStyleTemplate == true (sau detect Excel mẫu)
    - Chip "Cùng dạng" disabled + lock icon nếu !_templateAllMcq
    - Tooltip giải thích cho từng chip
  → UI: _buildModeChip() helper widget
  → UI: Similarity badge trong question card Stack (bottom-left)
    - Chỉ hiện khi q['_similarityWarning'] is Map
    - Format: "⚠ Tương tự mẫu #N (XX%)"
```

---

## TRẠNG THÁI HIỆN TẠI (ĐÃ TEST)

### Log đã verify (2026-04-29)
```
✅ hasExcelTemplate=true → useAsStyleTemplate=true
✅ mode=styleOnly → schema-only branch (KHÔNG có text câu gốc)
✅ Context output (cũ): "Câu 1: MCQ 4 lựa chọn độ khó 2/5 — Tags: flutter, cơ bản"
   → (mới 2026-05-02): "[Slot 1] MCQ 4 lựa chọn độ khó 2/5 — Tags: flutter, cơ bản"
✅ resolvedMode=styleOnly, templateQCount=2
✅ Prompt bắt đầu "CẤM TUYỆT ĐỐI..." + "OUTPUT: JSON ARRAY thuần túy..."
✅ Câu sinh ra mới hoàn toàn (không copy template)
✅ Model: llama-3.1-8b-instant (Groq) — yếu nhưng parser heuristic xử lý được
```

### Vấn đề nhỏ còn lại (không block)
- Model đôi khi thêm preamble text "Dưới đây là JSON ARRAY..." trước JSON → parser heuristic xử lý được
- Model dùng legacy choices format `{text, isCorrect}` thay vì `{content: {text}, is_correct}` → mapper đã handle backward compat

---

## PLAN CÒN LẠI

### TIER 1 — Fix bug chính (ĐANG LÀM, gần xong)

**Đã hoàn thành:**
- [x] L0: Plumb TemplateMode enum qua các tầng
- [x] L1: Schema-only context builder + sanitize tags
- [x] L2: Universal prompts cho 2 sub-mode (styleOnly + sameForm)
- [x] L4: Module similarity verifier (CPU-only)
- [x] L4-hook: Tích hợp verifier vào AiRepositoryImpl
- [x] Fix _handleRegenerateSingle
- [x] L5: UI chip TemplateMode + disable cho non-MCQ
- [x] L5-badge: Badge "tương tự câu mẫu" trên question card
- [x] L3: Mở rộng validation per-call (dedup, count fix, empty text)

**Còn lại:**
- [ ] Task #9: Chạy `flutter analyze` toàn project, fix mọi error/warning
- [ ] Smoke test thực tế với file `tn.xlsx` có > 5 câu MCQ (xác nhận câu sinh ra không trùng template)
- [ ] Smoke test chip "Cùng dạng" (chọn sameForm → generate → xem câu có giữ cấu trúc không)
- [ ] Commit Tier 1 (tất cả file đã edit)

**Lệnh verify:**
```bash
flutter analyze --no-congratulate 2>&1 | grep -E "error|Error"
# Phải ra 0 errors
```

---

### TIER 2 — Nên có (PR tiếp theo)

#### T2-1: Diversity sampling cho > 50 câu mẫu
**Vấn đề:** Nếu template có 50+ câu, gửi hết vào context sẽ vượt token limit. Cần sample đại diện.
**Approach:**
- Cluster câu theo type + difficulty
- Sample đều từ mỗi cluster (tối đa 20 câu)
**File:** `lib/presentation/providers/local_temp_file_notifier.dart` → `_buildSchemaOnlyContext()`

#### T2-2: Fallback tags chain
**Vấn đề:** Nếu file Excel không có tags, schema-only context vô nghĩa.
**Approach:**
- tags rỗng → dùng filename (strip extension, split camelCase/underscore)
- filename cũng rỗng → bắt buộc focus hint field (disable Generate button với tooltip)
**File:** `lib/presentation/providers/local_temp_file_notifier.dart` + screen

#### T2-3: Pre-detect câu có biến số → ép styleOnly
**Vấn đề:** Giáo viên chọn sameForm nhưng template có câu lý thuyết (không có số liệu) → sameForm vô nghĩa.
**Approach:**
- Detect regex: `\d+\s*(cm|m|km|kg|°|%|đồng|VND)` trong text
- Nếu < 50% câu có biến số → warn + auto-downgrade sameForm→styleOnly
**File:** `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

#### T2-4: Giữ lại Phase 3 bug fixes (context.md cũ)
File `.claude/context.md` cũ có danh sách C-1..C-4, L-1..L-6, U-1..U-6 cần fix cho Rubric feature.
Xem git history hoặc backup để restore nếu cần: các bug đó vẫn còn trong codebase chưa fix.

**Các bug quan trọng nhất:**
- C-2: `Navigator.pop(sheetCtx)` sai context trong rubric_builder_component.dart ~line 360
- C-3: Score override không validate >= 0 trong interactive_rubric_grader.dart ~line 428
- C-4: Param name mismatch `assignmentId` vs `distributionId` trong student_assignment_detail_screen.dart ~line 629
- L-5: SnackBar không hiện khi chỉ 1 essay thiếu rubric (điều kiện `errors.length > 1` sai, phải `errors.isNotEmpty`)

---

### TIER 3 — Tương lai (sau khi Tier 1+2 stable)

#### T3-1: Embedding similarity thay Levenshtein
**Vấn đề:** Levenshtein + Jaccard bigram không bắt được paraphrase sâu (đổi từ đồng nghĩa, đổi cấu trúc câu).
**Approach:** Dùng `multilingual-e5-small` qua Supabase Edge Function RPC. Cosine similarity trên embeddings.
**Constraint:** Cần server-side model, thêm latency ~200-500ms per batch.

#### T3-2: Inline answer parser cho .docx/.pdf
**Vấn đề:** Hiện chỉ Excel `.xlsx` có `parsedQuestions`. Word/PDF dùng raw extracted text → không có schema-only mode.
**Approach:** Thêm parser detect "Câu 1:", "A.", "B.", "C.", "D." pattern trong Word/PDF → build `parsedQuestions`.

#### T3-3: Mixed file role tagging
**Approach:** Cho phép user tag từng file là "template" hay "knowledge source" (2 role khác nhau trong Mode 3). Hiện tại detect tự động qua `parsedQuestions != null`.

---

## LINE NUMBERS QUICK REFERENCE (2026-04-29)

> Agent dùng section này để navigate trực tiếp — KHÔNG cần grep/search.

### `lib/presentation/providers/local_temp_file_notifier.dart`
| Method | Line |
|---|---|
| `getKnowledgeContextForIds()` | 96 |
| `_buildSchemaOnlyContext()` | 165 |
| `_sanitizeTagsForSchema()` | 197 |
| `getTemplateQuestionsForIds()` | 248 |

### `lib/core/services/ai_service.dart`
| Method | Line |
|---|---|
| `getGenerateQuestionsPrompt()` — branch styleOnly/sameForm switch | 278 |
| `_buildStyleOnlyPrompt()` — definition | 429 |
| `_buildSameFormPrompt()` — definition | 482 |

### `lib/data/repositories/ai_repository_impl.dart`
| Method | Line |
|---|---|
| `generateQuestions()` — log + call `_applyTemplateVerification` | 66 |
| `_mapAiQuestionToStandardFormat()` | 268 |
| `_applyTemplateVerification()` — definition | 711 |

### `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`
| Method | Line |
|---|---|
| `_handleGenerate()` | 385 |
| `_handleRegenerateSingle()` | 1052 |
| `_buildTemplateModeChips()` — call site trong Mode 3 UI | 1383 |
| `_buildTemplateModeChips()` — definition | 2959 |
| `_buildModeChip()` — helper widget | ~3000 |

### State fields trong `TeacherAiGenerateQuestionScreen`
```dart
TemplateMode? _effectiveTemplateMode    // null = chưa detect
List<Map>? _templateQuestionsForVerify  // câu mẫu gốc cho verifier
bool _templateAllMcq                    // chip "Cùng dạng" chỉ enable khi true
```

---

## KỸ THUẬT CẦN CHÚ Ý CHO PHIÊN SAU

### 1. API hoàn toàn user-configured
Model AI là do người dùng tự cài trong Settings. KHÔNG hardcode model. KHÔNG assume Groq hay Gemini.
Hỗ trợ: Groq / Gemini / OpenAI / Anthropic / Ollama.
Service entry: `AiService.callActiveAi(prompt)` — tự detect provider.

### 2. _similarityWarning format
Khi verifier set badge, field `_similarityWarning` trong question Map là:
```dart
{'score': double, 'matchedTemplateIdx': int}
// Không phải String!
```
UI badge phải cast as `Map<String, dynamic>`.

### 3. Thứ tự validation trong _mapAiQuestionToStandardFormat
ĐÚNG thứ tự: Dedup + count fix → correct count validate → answer.correct_choices sync
SAI thứ tự sẽ gây mất đáp án đúng sau khi trim.

### 4. choices format legacy vs new
Model yếu (8B) thường trả legacy format: `{id, text, isCorrect}`
Mapper đã handle: fallback sang legacy nếu `choice['content']` null.
Format mới: `{id, content: {text}, is_correct}`.

### 5. _tryParseJson handles
- Markdown code fence: ` ```json...``` `
- Direct JSON decode
- Heuristic: tìm first `[` or `{`, last `]` or `}`, extract và parse
- Preamble text trước JSON array được tự động strip bởi heuristic

### 6. Similarity badge field name
```dart
q['_similarityWarning']  // Map có score + matchedTemplateIdx
```
Set bởi `_applyTemplateVerification()` trong `ai_repository_impl.dart`.

### 7. Groq max_tokens formula
```dart
// lib/core/services/ai_service.dart
static int _groqMaxTokensFromPrompt(String prompt) {
  // qty × 220 + 400 overhead, clamp [800, 6000]  ← cap tăng lên 6000
}
```

---

## LOGS KEY ĐỂ DEBUG

Sau khi generate Mode 3 với Excel template, tìm các log này:
```
📄 [Context] getKnowledgeContextForIds: mode=styleOnly, ids=1
📄 [Context] tn.xlsx: parsedQ=2 → schema-only          ← phải "schema-only"
📄 [Context] tn.xlsx output (XXX chars): [Schema bài mẫu...
🧠 [Prompt] Template mode → branch=styleOnly qty=10 type=null
🧠 [Prompt] Built styleOnly prompt: XXXX chars. Preview: CẤM TUYỆT ĐỐI...
🔧 [AI REPO] generateQuestions: qty=10 useTemplate=true resolvedMode=styleOnly templateQCount=N
✅ [AI REPO] Generated N questions
```

Nếu thấy `No questions found. Raw response (500 chars):` → xem nội dung để debug parse failure.

---

## GHI CHÚ QUAN TRỌNG TỪ MEMORY

1. Toàn bộ tính năng tự luận (rubric, essay workspace, Phase 3+6) defer vô thời hạn — KHÔNG implement.
2. AI Config có 2 loại riêng biệt: analytics (Phase 7) dùng `ApiKeyService.getAnalyticsProvider/Model()`, KHÔNG nhầm với question generation config.
3. File local chưa chắc đã push — phải xác nhận user trước mọi thao tác git có thể overwrite.

---

## MODE 3 — TỔNG HỢP CASE & GAPS (2026-05-02)

### Các chiều biến thiên

| Chiều | Giá trị |
|---|---|
| File type | Excel (có sheets mẫu), Excel (không có sheets mẫu), Word/PDF (có cấu trúc câu hỏi), Word/PDF (raw text) |
| FileRole | Mẫu (template), Kiến thức (KT) |
| TemplateMode | styleOnly (Tạo mới), sameForm (Cùng dạng) |
| Số file | 1 Mẫu, 1 KT, 1 Mẫu + 1 KT, nhiều Mẫu, nhiều KT |

---

### Bảng case chính

| File type | Role | styleOnly | sameForm | Ghi chú |
|---|---|---|---|---|
| Excel (sheets mẫu) | Mẫu | ✅ schema-only (type + diff + tags) | ✅ text + options shuffle | Happy path |
| Excel (sheets mẫu) | KT | ⚠️ BUG | ⚠️ BUG | `extractedText` = tab-separated garbage |
| Excel (không sheets mẫu) | auto-KT | ⚠️ BUG | N/A | `parsedQuestions=null`, vẫn gửi tab-sep garbage |
| Word/PDF (có Q structure, T3-2) | Mẫu | ✅ schema-only | ✅ text + options shuffle | Hoạt động nếu T3-2 đã parse được |
| Word/PDF (có Q structure) | KT | ✅ raw text readable | N/A | Tốt — AI đọc text thường |
| Word/PDF (raw text) | auto-KT | ✅ raw text readable | N/A | Tốt |
| Excel Mẫu + Word KT | mixed | ✅ schema + raw text | partial | Happy path multi-file |
| Excel Mẫu + Excel KT | mixed | ⚠️ schema OK + KT garbage | partial | BUG: KT garbage |
| Nhiều Mẫu | multi-Mẫu | ⚠️ schemas concat | ⚠️ schemas concat | Có thể confuse AI |

---

### 6 Gap cụ thể + câu hỏi quyết định

#### GAP-1 — Excel-as-KT gửi tab-separated garbage lên AI
**Symptom:** Khi user toggle Excel có `parsedQuestions` sang KT role (hoặc Excel không có sheets mẫu), `getKnowledgeContextForIds` vào nhánh `else if (f.extractedText?.isNotEmpty == true)` và gửi:
```
Câu hỏi	A. Lựa chọn 1	B. Lựa chọn 2	C. Lựa chọn 3	D. Lựa chọn 4	A	2	flutter, cơ bản
```
AI không thể đọc context này như knowledge source.

**Câu hỏi quyết định:**
- Option A (UI layer): Lock role toggle — Excel có `parsedQuestions` bắt buộc là Mẫu, không cho toggle sang KT. Simple, nhưng mất flexibility.
- Option B (Data layer): `extractFromXlsx` cải tiến — reformat tab-separated thành readable paragraphs (bỏ header row, join cell bằng ": " hoặc newline). Phức tạp hơn, nhưng cho phép Excel non-template làm KT.
- **Đề xuất (refined by advisor):** Lock chỉ Excel có `parsedQuestions`. Word/PDF có `parsedQuestions` vẫn cho toggle (text extracted readable). Condition:
  ```dart
  final isXlsx = file.mimeType.contains('spreadsheetml') || file.filename.toLowerCase().endsWith('.xlsx');
  final canToggle = !(isXlsx && file.parsedQuestions != null);
  ```
  B cho Excel không có `parsedQuestions` (reformat text thay vì tab-sep).

#### GAP-2 — Nhiều Mẫu: schemas nối tiếp nhau
**Symptom:** User chọn 2 file Excel Mẫu → `getKnowledgeContextForIds` ghép 2 schema block. AI thấy context:
```
=== file1.xlsx ===
[Schema bài mẫu — 10 câu...] Câu 1: MCQ 4 lựa chọn độ khó 2/5 — Tags: ...
---
=== file2.xlsx ===
[Schema bài mẫu — 8 câu...] Câu 1: MCQ 4 lựa chọn độ khó 3/5 — Tags: ...
```
AI không biết phải ưu tiên schema nào, có thể blend 2 style lại.

**Câu hỏi quyết định:**
- Option A: Giới hạn 1 Mẫu — nếu user chọn 2+ Mẫu, warning + chỉ dùng file Mẫu đầu tiên.
- Option B: Merge schemas — dùng schema file Mẫu đầu tiên làm primary, file còn lại làm KT (downgrade role automatically).
- Option C: Cho phép, kèm note trong schema header rằng đây là 2 mẫu.
- **Đề xuất:** A — giới hạn 1 Mẫu (đơn giản nhất, ít ambiguity). UI: khi user toggle file thứ 2 sang Mẫu, auto-toggle file Mẫu cũ về KT và show snackbar "Chỉ dùng 1 file mẫu. Đã đổi [filename] sang Kiến thức."

#### GAP-3 — Stale `_useAsStyleTemplate` khi regenerate
**Symptom:** User generate lần 1 (file A là Mẫu → `_useAsStyleTemplate=true`), sau đó toggle file A sang KT, bấm "Tạo lại" → `_handleRegenerateSingle` dùng `_effectiveTemplateMode` cũ (đã cached từ generate lần 1), gửi schema-only context nhưng file A bây giờ là KT.

**Câu hỏi quyết định:**
- Option A: Re-detect tại regenerate time — `_handleRegenerateSingle` gọi lại detect logic từ state hiện tại của `localTempFilesProvider`.
- Option B: Invalidate cache khi file role thay đổi — watch `localTempFilesProvider` và reset `_effectiveTemplateMode=null` khi any file role changes.
- **Đề xuất (advisor: chọn A):** A đơn giản hơn, không có risk rebuild loop Riverpod:
  ```dart
  // _handleRegenerateSingle:
  final currentFiles = ref.read(localTempFilesProvider);
  final hasTemplateNow = currentFiles.any(
    (f) => selectedIds.contains(f.id) && f.effectiveRole == FileRole.template && f.parsedQuestions != null,
  );
  final modeNow = hasTemplateNow ? (_effectiveTemplateMode ?? TemplateMode.styleOnly) : null;
  // re-fetch _templateQuestionsForVerify từ currentFiles để khớp
  ```

#### GAP-4 — Không cảnh báo khi qty >> template size
**Symptom:** Template có 3 câu MCQ, user yêu cầu sinh 20 câu → `sameForm` → AI bị ép tạo 20 biến thể từ 3 câu gốc → kết quả lặp lại hoặc hallucinate.

**Câu hỏi quyết định:**
- Option A: Warn only — snackbar "Template có 3 câu, bạn đang yêu cầu 20. Câu sinh ra có thể lặp cấu trúc."
- Option B: Hard cap — qty tối đa = template_size × 3. Disabled slider nếu vượt.
- Option C: Auto-suggest qty = template_size (điền sẵn vào field).
- **Đề xuất:** A (warn) + C (auto-suggest default) cho `sameForm`. Với `styleOnly`, không cần cap (AI có thể tự đặt bài mới hoàn toàn).
- **Ngưỡng warn:** `qty > templateSize * 3` → warn. `qty > templateSize * 10` → block với message.

#### GAP-5 — Truncation priority: KT bị cắt trước Mẫu hay sau?
**Symptom:** Context quá dài → `smartTruncate` cắt từ cuối. Nếu KT append trước Mẫu trong `parts.join`, schema Mẫu bị cắt → AI không có schema để follow.

**Câu hỏi quyết định:**
- **Đề xuất:** Mẫu schema LUÔN được ưu tiên → Sắp xếp `parts` trong `getKnowledgeContextForIds`: schema-only/sameForm blocks TRƯỚC, KT raw text SAU. `smartTruncate` cắt từ cuối → chỉ KT bị cắt.
- **Implement:** Sort `parts` by role: template blocks first, then KT blocks.

#### GAP-6 — sameForm với template nhỏ (< 5 câu)
**Symptom:** Template có 2 câu toán → user chọn sameForm → AI nhận 2 câu mẫu với text + options → AI có quá ít context, kết quả rất gần bản gốc hoặc lặp lại.

**Câu hỏi quyết định:**
- Option A: Disable sameForm nếu template < 5 câu (join với GAP-4 warn).
- Option B: Allow nhưng warn + giới hạn qty = templateSize × 2.
- **Đề xuất:** A — trong chip "Cùng dạng", nếu `templateQuestions.length < 5`, disabled + tooltip "Cần ít nhất 5 câu mẫu để dùng chế độ này. File hiện tại có N câu."

---

### Thứ tự fix đề xuất

| Priority | Gap | Effort | Lý do |
|---|---|---|---|
| P0 | GAP-1 (Excel-as-KT garbage) | Low (UI lock) | Gây AI nhận context vô nghĩa |
| P0 | GAP-5 (truncation priority) | Low (reorder parts) | Mẫu schema bị cắt = toàn bộ anti-copy mất tác dụng |
| P1 | GAP-3 (stale regenerate) | Low (re-detect tại call site) | Silent wrong behavior |
| P1 | GAP-4 (qty >> template size) | Low (warn + suggest) | UX confuse |
| P2 | GAP-6 (sameForm tiny template) | Low (disable chip) | Kết quả tệ nhưng không crash |
| P2 | GAP-2 (multiple Mẫu) | Medium (UI enforce 1 Mẫu) | Edge case, ít gặp |
| P2 | GAP-7 (extraction silent failure) | Low (disable Generate) | AI generate "trên không" với empty context |

---

### Files cần edit cho các Gap trên

```
GAP-1: context_sources_section.dart → _buildRoleToggle
        canToggle = !(isXlsx && file.parsedQuestions != null)
        Word/PDF vẫn cho toggle dù có parsedQuestions

GAP-2: context_sources_section.dart → updateFileRole callback
        Nếu new role = Mẫu và đã có Mẫu khác → ??warn hay auto-toggle?? (cần confirm user)

GAP-3: teacher_ai_generate_question_screen.dart → _handleRegenerateSingle()
        Re-detect hasTemplate từ currentFiles tại call time, không dùng _effectiveTemplateMode cache

GAP-4: teacher_ai_generate_question_screen.dart → _handleGenerate()
        Warn khi qty > templateSize × 3 (ngưỡng cần confirm user)

GAP-5: local_temp_file_notifier.dart → getKnowledgeContextForIds()
        Sort parts: template schema blocks trước, KT raw text sau

GAP-6: context_sources_section.dart → _buildSubModeStrip
        Disable sameForm chip nếu templateQs.length < 5

GAP-7: teacher_ai_generate_question_screen.dart hoặc context_sources_section.dart
        Disable Generate button nếu tất cả selected files đều có extractedText.isEmpty && parsedQuestions == null
```

---

### 2 Quyết định cần confirm với user trước khi code

1. **GAP-2 (nhiều Mẫu):** Auto-toggle file Mẫu cũ sang KT khi chọn file Mẫu mới (aggressive, UX đôi khi không expect), hay chỉ warn snackbar và để user tự toggle?

2. **GAP-4 (ngưỡng warn):** `qty > templateSize × 3` có hợp lý không? Ví dụ template 3 câu → warn khi qty > 9. Hay dùng ngưỡng khác?

---

## PROMPT BUGS — Mode 3 (2026-05-02)

> Phân tích từ code `lib/core/services/ai_service.dart` (`_buildStyleOnlyPrompt`, `_buildSameFormPrompt`, `getGenerateQuestionsPrompt`).
> Bugs được chia: P0 (phá chức năng), P1 (thường gặp), P2 (thỉnh thoảng).

---

### P0-1 — `typeRule` tính xong nhưng KHÔNG inject vào template prompts

**File:** `ai_service.dart` — `getGenerateQuestionsPrompt()` line ~257, `_buildStyleOnlyPrompt()` line ~429.

**Bug:** Biến `typeRule` được build từ `_buildTypeRule(questionType)` nhưng **không được truyền vào** `_buildStyleOnlyPrompt()` hay `_buildSameFormPrompt()`. Cả 2 hàm không nhận param `typeRule`.

```dart
// getGenerateQuestionsPrompt:
final typeRule = _buildTypeRule(questionType);  // ← computed
// ...
prompt = _buildStyleOnlyPrompt(
  topic: ..., quantity: ..., difficultyLine: ..., topicLine: ...,
  documentContext: ..., formatExample: ...,
  // ← typeRule KHÔNG được truyền vào
);
```

**Hậu quả:** Nếu user chọn `questionType=true_false` nhưng schema có MCQ, AI sinh ra MCQ vì schema dạy nó vậy, không có rule nào ép `type=true_false`.

**Fix:** Thêm param `String typeRule` vào cả hai hàm builder, inject vào QUY TẮC section:
```dart
// Trong _buildStyleOnlyPrompt, QUY TẮC:
// 2b. $typeRule (nếu typeRule != 'auto' → ưu tiên type này, bỏ qua type trong schema)
```

---

### P0-2 — `difficultyLine` override xung đột với difficulty của schema

**File:** `ai_service.dart` — `_buildStyleOnlyPrompt()` line ~447.

**Bug:** Prompt có 2 instruction mâu thuẫn:
- Rule trong QUY TẮC: *"Giữ ĐÚNG: loại câu (type), số lựa chọn, **độ khó tương ứng từng câu trong schema**"*
- `$difficultyLine`: *"Độ khó: Khó (4/5)."*

Nếu schema có mix (câu 1: diff 2, câu 2: diff 4) nhưng user đặt difficulty=3, AI không biết phải làm gì: theo schema hay theo override? Model yếu thường theo instruction cuối → tất cả câu ra cùng 1 mức độ khó, bỏ qua schema.

**Fix:** Trong template mode, `difficultyLine` nên là soft hint chứ không phải override:
```
Độ khó: cố gắng theo từng câu trong schema (nếu schema không chỉ rõ, dùng $difficultyLabel).
```
Hoặc: chỉ inject `difficultyLine` khi difficulty được user chỉ định **và** tất cả câu trong schema có cùng 1 mức độ khó.

---

### P0-3 — `_buildSameFormPrompt` có 3 ví dụ toán thuần túy — mislead cho template không phải toán

**File:** `ai_service.dart` — `_buildSameFormPrompt()` line ~512.

**Bug:** 3 chain-of-thought examples đều là bài toán (cộng, hình học, đại số). Nếu template là văn học, lịch sử, hoặc lập trình:
- Model học từ ví dụ → áp cấu trúc toán học vào template không phải toán
- "PHÂN TÍCH STRUCTURE: tách câu mẫu thành... biến thay đổi được = số/tên/đơn vị" — instruction này không có nghĩa với câu lý thuyết

**Fix:** Thêm ít nhất 1 ví dụ không phải toán. Ví dụ câu lập trình:
```
Mẫu: "Lệnh nào in ra màn hình trong Python? A. echo  B. print  C. write  D. output"
Phân tích: khung "Lệnh nào làm X trong ngôn ngữ Y?", biến Y=Python, hành động X=in ra.
Đổi: Y=Java, X=khai báo biến. Tính: int x = ...; Distractors: val x (Kotlin), var x: int (Swift)...
```

---

### P0-4 — `formatExample` MCQ-only conflict với mixed-type schema trong styleOnly

**File:** `ai_service.dart` — `_buildStyleOnlyPrompt()` cuối prompt ~line 460.

**Bug:** `$formatExample` dùng `_buildFormatExample(questionType)`. Khi `questionType=null` (auto), hàm trả về **MCQ 2-câu example**. Nếu schema có mix true_false + MCQ, model học từ example → sinh toàn MCQ. Thêm nữa, trong `_buildStyleOnlyPrompt` đã có 1 embedded MCQ example (Flutter widget), rồi lại inject `$formatExample` (cũng MCQ) → **2 MCQ examples** cho dù user không yêu cầu MCQ.

**Fix:** Trong template mode, `formatExample` nên compact hơn và khớp với types trong schema. Hoặc: không inject `formatExample` cố định mà inject minimal format reminder:
```
// Thay $formatExample bằng:
FORMAT NHẮC NHỞ: output là JSON array, mỗi object có "type", "override_text", và fields theo type (choices/expected_answer/blanks). KHÔNG có field "explanation".
```

---

### P1-1 — `topicLine` sai ngữ pháp khi không có focus hint

**File:** `ai_service.dart` — `getGenerateQuestionsPrompt()` line ~271.

**Bug:**
```dart
final topicLine = hasFocusHint
    ? 'BẮT BUỘC tập trung vào "$topic" (yêu cầu giáo viên)'
    : 'mở rộng cùng chủ đề/lĩnh vực gợi ý qua tags trong schema';
```

Khi `hasFocusHint=false`, prompt có:
```
Chủ đề: mở rộng cùng chủ đề/lĩnh vực gợi ý qua tags trong schema.
```

"Chủ đề: mở rộng cùng..." — mệnh đề sau dấu `:` là instruction, không phải tên chủ đề. Model yếu đọc "Chủ đề:" → expect topic name → nhận instruction → confuse.

**Fix:**
```dart
final topicLine = hasFocusHint
    ? 'Chủ đề BẮT BUỘC: "$topic" (yêu cầu giáo viên)'
    : 'Chủ đề: suy ra từ tags trong schema, mở rộng trong cùng lĩnh vực';
```

---

### P1-2 — Rule anti-copy (không sao chép tài liệu) ở cuối danh sách, vị trí yếu nhất

**File:** `ai_service.dart` — non-template mode, `getGenerateQuestionsPrompt()` line ~334.

**Bug:** Rule 8 là "TUYỆT ĐỐI KHÔNG sao chép..." nhưng là rule cuối trong danh sách, sau 7 rule khác. Model yếu (8B) thường bỏ qua rule cuối khi list dài. Rule này quan trọng nhất cho Mode 3 KT nhưng ở vị trí priority thấp nhất.

**Fix:** Đổi thành rule 1 hoặc đặt ở primacy (trước danh sách). Rule diversify (rule 5, 7) quan trọng hơn rule anti-copy? Không — với KT mode, anti-copy là cốt lõi.

---

### P1-3 — Rule 5 "Đa dạng hóa" conflict với KT mode (phải bám tài liệu)

**File:** `ai_service.dart` — non-template mode, line ~335.

**Bug:** Rule 5 nói "kết hợp câu cơ bản, câu cần suy luận 2-3 bước, câu áp dụng thực tế, câu có dữ liệu thực". Nhưng Rule 1 nói "Lấy kiến thức từ NỘI DUNG TÀI LIỆU". Nếu tài liệu chỉ có lý thuyết, rule 5 khiến AI tự sáng tạo "câu có dữ liệu thực" không có trong tài liệu → vi phạm rule 1.

**Fix:** Trong KT mode, rule 5 phải được conditional:
```
5. ĐA DẠNG HÓA câu hỏi từ CÁC PHẦN KHÁC NHAU của tài liệu: câu ghi nhớ, câu hiểu ý, câu so sánh, câu áp dụng (nếu tài liệu có). Không tạo câu về thông tin KHÔNG CÓ trong tài liệu.
```

---

### P1-4 — max_tokens cap quá thấp → JSON bị cắt ngang giữa chừng

**File:** `ai_service.dart` — `_groqMaxTokensFromPrompt()` line ~982.

**Bug:** Formula hiện tại: `400 + qty * 220`, cap max 4000. Với qty=20 → 4800 → bị cap về 4000 → với MCQ đầy đủ (~250 tokens/câu) chỉ đủ khoảng 16 câu → JSON bị cắt → parse fail → fallback "(cần chỉnh sửa)". Cả hai builder đã có "Trả về đúng JSON ARRAY $quantity object" ở recency nhưng model không thể tuân thủ vì bị cắt.

**Lưu ý:** Prompt có rule count constraint ở cuối (đúng) — vấn đề là token budget không đủ, không phải thiếu rule.

**Fix:** Tăng max cap và điều chỉnh formula:
```dart
static int _groqMaxTokensFromPrompt(String prompt) {
  final m = RegExp(r'tạo\s+(\d+)\s+câu\s+hỏi', caseSensitive: false).firstMatch(prompt);
  final qty = int.tryParse(m?.group(1) ?? '') ?? 10;
  // MCQ đầy đủ (override_text + 4 choices + tags): ~250 tokens. Cap 6000 để đủ cho qty=20.
  final estimated = 500 + (qty * 260);
  return estimated.clamp(800, 6000);  // Tăng max cap từ 4000 → 6000
}
```

---

### P1-5 — Gemini temperature không set — mặc định 1.0, quá cao cho template mode

**File:** `ai_service.dart` — `_callGeminiApiOnce()` line ~771.

**Bug:**
```dart
'generationConfig': {
  'responseMimeType': 'application/json',
  // KHÔNG có 'temperature' → Gemini default = 1.0
}
```

Groq call có `'temperature': 0.1`. Gemini default 1.0 → output không nhất quán, dễ sáng tạo quá mức cho Mode 3 template → sinh câu quá giống template (random seed cao = drift nhiều hơn).

**Fix:** Thêm temperature vào generationConfig:
```dart
'generationConfig': {
  'responseMimeType': 'application/json',
  'temperature': 0.2,  // Thấp → consistent với Groq behavior
},
```

---

### P2-1 — `_buildSameFormPrompt` thiếu RÀNG BUỘC FORMAT section

**File:** `ai_service.dart` — `_buildSameFormPrompt()`.

**Bug:** `_buildStyleOnlyPrompt` có section `RÀNG BUỘC FORMAT:` explicit (choices count, override_text, tags...) nhưng `_buildSameFormPrompt` chỉ có `$formatExample` và 1 dòng nhắc lại ở cuối. Nếu AI sinh MCQ thiếu `override_text`, không có rule nào nói rõ là sai.

**Fix:** Thêm `RÀNG BUỘC FORMAT:` section tương tự styleOnly vào cuối sameForm prompt.

---

### P2-2 — Không có type distribution hint khi schema có mixed types

**File:** `ai_service.dart` — `_buildStyleOnlyPrompt()`.

**Bug:** Schema có 5 MCQ + 3 TF + 2 short_answer → styleOnly prompt chỉ nói "Giữ ĐÚNG: loại câu tương ứng từng câu". Nhưng khi AI sinh $quantity=10 câu mới, không có instruction nào về phân phối type (5 MCQ, 3 TF, 2 SA). AI thường overfit MCQ.

**Fix:** Trong `_buildSchemaOnlyContext()` (LocalTempFilesNotifier), thêm 1 dòng summary phân phối type:
```
[Phân phối: 5 MCQ, 3 TF, 2 SA — giữ tỉ lệ này khi tạo câu mới]
```
Và trong `_buildStyleOnlyPrompt`, thêm rule: "Giữ tỉ lệ phân phối type như trong schema".

---

### P2-3 — Embedded Flutter example trong styleOnly luôn là MCQ — mislead cho non-MCQ schema

**File:** `ai_service.dart` — `_buildStyleOnlyPrompt()` line ~457.

**Bug:**
```
--- VÍ DỤ NGƯỠNG (schema 1 câu MCQ độ khó 3, tags: "flutter, cơ bản") ---
[{"type":"multiple_choice","override_text":"Widget nào dùng...",...}]
```

Example này hardcoded là MCQ về Flutter. Nếu schema là true_false về lịch sử, ví dụ này:
1. Dạy model output MCQ (sai type)
2. Dạy model nghĩ topic là Flutter (sai domain)

**Fix:** Bỏ embedded example, chỉ giữ `$formatExample` (đã được chọn theo questionType).

---

### Tổng hợp fix theo file

```
ai_service.dart — _buildStyleOnlyPrompt():
  P0-1: thêm param typeRule, inject vào QUY TẮC
  P0-2: đổi difficultyLine thành soft hint trong template mode
  P0-4: bỏ formatExample cố định, thay bằng minimal format reminder
  P1-1: sửa topicLine grammar
  P1-4: thêm output count constraint
  P2-3: bỏ hardcoded Flutter MCQ example

ai_service.dart — _buildSameFormPrompt():
  P0-1: thêm typeRule injection
  P0-3: thêm 1 ví dụ non-math
  P2-1: thêm RÀNG BUỘC FORMAT section
  P1-4: thêm output count constraint

ai_service.dart — getGenerateQuestionsPrompt() [non-template branch]:
  P1-2: anti-copy lên rule 1 hoặc primacy
  P1-3: conditional diversify rule cho KT mode

ai_service.dart — _callGeminiApiOnce():
  P1-5: thêm temperature: 0.2 trong generationConfig

local_temp_file_notifier.dart — _buildSchemaOnlyContext():
  P2-2: thêm type distribution summary line

ai_service.dart — getGenerateQuestionsPrompt():
  P0-1: typeRule variable phải được pass vào builder functions
```

---

## FIXES ĐÃ THỰC HIỆN (2026-05-02) — Mode 3 bugs báo cáo

### Root causes đã xác nhận

1. **"câu hỏi 1" / "câu hỏi 2" output** — 2 nguồn song song:
   - AI output `{"override_text": "câu hỏi 1"}` → do schema label "Câu N:" trigger pattern match
   - Parser fallback tạo "Câu hỏi N (cần chỉnh sửa)" khi AI trả về empty content

2. **"câu hỏi về lịch sử" / "câu hỏi về toán học"** — schema-only context có tags như "lịch sử", "toán học" → AI dùng tag name làm question text

3. **Tạo lại 1 câu không theo form mẫu** — GAP-3: stale `_useAsStyleTemplate` + không re-detect template state

### Thay đổi code đã apply

#### `local_temp_file_notifier.dart` — `_buildSchemaOnlyContext()`
- **Schema label "Câu N:" → "[Slot N]"** — phá pattern matching: model không còn kết hợp nhãn với output "câu N"
- **GAP-5 fix**: sort template parts trước KT parts — `smartTruncate` chỉ cắt KT text, schema mẫu luôn giữ nguyên

#### `ai_repository_impl.dart` — `_mapAiQuestionToStandardFormat()` + `_parseAiResponse()`
- **Parser fallback → null** (line 459): content.text rỗng → return null (không tạo "Câu hỏi N cần chỉnh sửa")
- **Return type**: `Map<String, dynamic>?` — nullable, caller skip null results
- **Non-Map entries** (line 231): skip thay vì tạo placeholder map
- **No padding**: không còn pad questions với `_generateFallbackQuestions` khi count < expected; chỉ fallback khi `questions.isEmpty` hoàn toàn

#### `ai_service.dart` — `_buildStyleOnlyPrompt()`
- **P0-1 fix**: thêm param `typeRule`, inject vào prompt sau difficultyLine
- **P2-3 fix**: bỏ hardcoded Flutter MCQ example ("Widget nào dùng để hiển thị...")
- **Anti-placeholder (positive example)**: "override_text = câu hỏi thực sự (VD đúng: 'Thủ đô Pháp là thành phố nào?' — VD sai: 'câu hỏi địa lý' hay 'câu hỏi 1')"
- **KIỂM TRA rule**: xác nhận isCorrect=true là đúng kiến thức trước khi xuất
- Bỏ "CẤM TUYỆT ĐỐI" phrasing (có thể backfire trên model yếu) → thay bằng positive framing

#### `ai_service.dart` — `_buildFormatExample()`
- MCQ default: thay "Câu hỏi trắc nghiệm 1?" → real questions ("Nguyên tố hóa học 'O' là gì?")
- true_false: thay "Câu hỏi đúng/sai ở đây?" → real statements
- essay/short_answer: thay placeholder text → real questions

#### `ai_service.dart` — `_groqMaxTokensFromPrompt()`
- **P1-4 fix**: token cap 4000 → 6000 (tránh truncate JSON giữa chừng ở qty=20)

#### `ai_service.dart` — `_callGeminiApiOnce()`
- **P1-5 fix**: thêm `'temperature': 0.2` trong generationConfig (tránh Gemini default 1.0)

#### `teacher_ai_generate_question_screen.dart` — `_handleRegenerateSingle()`
- **GAP-3 fix**: xóa stale `_useAsStyleTemplate` cache, re-detect live từ `localTempFilesProvider` state tại thời điểm regen
- Dùng `aiSettings.templateMode` (live từ provider) thay vì `_effectiveTemplateMode` (cached)
- Biến local `regenUseAsStyleTemplate` + `regenTemplateMode` thay vì state fields

### Còn lại (chưa fix)

| ID | Mô tả | Priority | Effort |
|---|---|---|---|
| GAP-1 | Excel-as-KT garbage (lock toggle) | P0 | Low |
| GAP-2 | Multiple Mẫu conflict | P2 | Medium |
| GAP-4 | qty >> templateSize warn | P1 | Low |
| GAP-6 | sameForm chip disable nếu < 5 câu | P2 | Low |
| P0-2 | difficultyLine soft hint trong template mode | P1 | Low |
| P0-3 | sameForm non-math example | P1 | Low |
| P0-4 | formatExample conflict với mixed-type schema | P1 | Low |
| P1-1 | topicLine grammar khi no focus hint | P2 | Trivial |
| P1-2 | anti-copy lên primacy trong KT mode | P1 | Low |
| P1-3 | conditional diversify rule cho KT mode | P1 | Low |
| P2-1 | sameForm thiếu RÀNG BUỘC FORMAT | P2 | Low |
| P2-2 | Type distribution hint trong schema header | P2 | Low |

### Test scenario cần verify sau deploy

1. **"câu hỏi 1" bug**: Generate Mode 3 với Excel template → output không còn "câu hỏi N" hay "câu hỏi về [tag]"
2. **Tạo lại 1 câu**: Click tạo lại → câu ra có content thực, đúng loại (typeRule), đúng chủ đề
3. **Token truncation**: qty=20 → không còn JSON bị cắt ngang
4. **GAP-3**: Toggle file role sau generate → click Tạo lại → dùng role mới, không phải role cũ
5. **GAP-5**: File Excel Mẫu + Word KT → context xuất template schema trước, KT text sau

---

## PENDING — Submit Atomic RPC + pg_cron Auto-Finalize (2026-05-07)

> Note để hôm khác bắt tay. Cả 2 task đều CHƯA triển khai. Đã có rollback client-side (`_rollbackSubmit` trong `assignment_datasource.dart`) + auto-submit watchdog client-side (workspace screen) đỡ tạm.

### Bối cảnh đã làm xong (KHÔNG đụng lại)
- BUG-1: `getDistributionDetail` filter variant theo `session_id` (fallback latest) — fixed.
- BUG-2: `submitAssignment` lookup submission theo `session_id` — fixed (mỗi attempt 1 row).
- BUG-3: bỏ dead-path hardcode `attempt:1` trong `getOrCreateSubmission` — fixed.
- Past-due redo block: migration_22 + helper `canRedoNow`/`whyCannotRedo` + UI `_SubmittedFooter` disable nút "Làm lại" — fixed.
- Past-due workspace: `WorkspaceState.allowLate` + `isPastDueClosed` getter + watchdog 5s + banner đỏ + disable nút "Nộp bài" — fixed.
- Rollback client-side: `submitAssignment` wrapper try-catch gọi `_rollbackSubmit(sessionId)` cleanup partial state — fixed.

### Mục 1 — RPC `submit_assignment_atomic` (CHƯA LÀM)

**Vấn đề:** rollback client-side còn khe hở (mạng đứt giữa rollback). Cần atomic transaction server-side.

**2 phương án — user cần chọn khi resume:**

| Phương án | Mô tả | Ưu | Nhược |
|---|---|---|---|
| **(A) Lai** ⭐ recommended | Client vẫn grade MCQ (giữ logic Dart `_gradeObjectiveQuestion`). RPC chỉ DB-write atomic | Rủi ro thấp, không đụng grading logic | Vẫn cần payload format ổn định |
| (B) Pure server | Port toàn bộ grading sang PL/pgSQL | Chuẩn enterprise | Phải port + test format mới `selected_choice_ids` vs cũ `selected_choices` + 3 cấp fallback `correct_choices` |

**Phạm vi đụng (phương án A):**
- New: `db/migration_23_submit_assignment_atomic.sql` — RPC `submit_assignment_atomic(p_session_id uuid, p_payload jsonb, p_ai_enabled bool)`
- Edit: `lib/data/datasources/assignment_datasource.dart` `_doSubmitAssignment` thay 6 bước inline bằng 1 RPC call
- Có thể bỏ hoặc thu hẹp `_rollbackSubmit` (RPC tự rollback)
- Test: `test/integration/submission_flow_test.dart` đã có — verify không regression

**Payload format đề xuất (A):**
```json
{
  "session_id": "uuid",
  "answers": [
    {
      "assignment_question_id": "uuid",
      "answer": {"selected_choice_ids": [0]},
      "final_score": 1.0,
      "needs_ai_grading": false,
      "needs_ai_feedback": true
    }
  ],
  "total_mcq_score": 7.5,
  "submit_status": "ai_processing"
}
```

### Mục 2 — pg_cron auto-finalize quá hạn (CHƯA LÀM)

**Vấn đề:** student không mở app sau due_at + `!allow_late` → `work_sessions` cứ `in_progress` mãi → GV bị chặn chấm/publish.

**Pre-condition:** Extension `pg_cron` **CHƯA enable** trên project Supabase này (verified 2026-05-07: `SELECT extname FROM pg_extension WHERE extname='pg_cron'` → empty).

**User cần quyết khi resume:**
1. Enable pg_cron: Claude chạy `CREATE EXTENSION pg_cron` qua MCP, HOẶC user tự bật từ Supabase Dashboard → Database → Extensions?
2. Cron behavior: chỉ flip `in_progress → submitted` (đơn giản, an toàn) HOẶC auto-grade MCQ luôn (giống flow submit thường)?

**Logic đề xuất:**
```sql
-- Mỗi 5 phút
SELECT cron.schedule(
  'auto_finalize_overdue_sessions',
  '*/5 * * * *',
  $$ SELECT public.auto_finalize_overdue_sessions(); $$
);
```

**RPC `auto_finalize_overdue_sessions()` SECURITY DEFINER (cần vì cron không có `auth.uid()`):**
```sql
-- Pseudocode
FOR r IN
  SELECT ws.id, ws.student_id, ws.assignment_distribution_id, ws.started_at
  FROM work_sessions ws
  JOIN assignment_distributions ad ON ad.id = ws.assignment_distribution_id
  WHERE ws.status = 'in_progress'
    AND ad.due_at IS NOT NULL
    AND ad.due_at < now()
    AND COALESCE(ad.allow_late, true) = false
LOOP
  -- KHÔNG gọi finalize_work_session (auth check) — inline logic.
  UPDATE work_sessions SET
    status = 'submitted',
    submitted_at = LEAST(now(), ad.due_at),
    time_spent_seconds = ...,
    updated_at = now()
  WHERE id = r.id;
END LOOP;
```

**Cảnh báo:** Auto-flip `submitted` không có `submission_answers` cho câu chưa trả lời → submission có `total_score=0`. Nếu chọn nhánh "auto-grade luôn", phải simulate flow submit (bao gồm bước insert empty submission_answers cho câu blank, INSERT submissions, INSERT ai_queue analysis).

**Phạm vi đụng:**
- New: `db/migration_24_pg_cron_auto_finalize.sql`
  - `CREATE EXTENSION IF NOT EXISTS pg_cron;`
  - RPC `auto_finalize_overdue_sessions()`
  - `cron.schedule(...)`
- Optional: `db/migration_24_undo.sql` để `cron.unschedule()` rollback

### 3 câu hỏi cần user trả lời khi resume
1. **Mục 1**: chọn (A) lai hay (B) pure server?
2. **Mục 2.a**: Claude tự `CREATE EXTENSION pg_cron`, hay user tự bật từ dashboard?
3. **Mục 2.b**: cron chỉ flip status, hay auto-grade MCQ luôn?

Đủ 3 câu trả lời là có thể bắt đầu thực thi không cần discuss thêm.

---

## PENDING — "Học sinh cần chú ý" / AI Recommendations cho Giáo viên (2026-05-07)

> Plan tách riêng cho phần `InterventionBadge` + `TeacherRecommendationsScreen` + pipeline sinh recommendation.
> CHƯA bắt đầu code. Cần user xác nhận scope trước khi thực thi.

### Bối cảnh đã verify (qua đọc code, chưa chạy DB)

**Files involved:**
- `lib/presentation/views/recommendation/widgets/intervention_badge.dart` — pill đỏ "X học sinh cần chú ý" trên teacher home
- `lib/presentation/views/recommendation/teacher/teacher_recommendations_screen.dart` — screen full list (UI scaffold, text mất dấu)
- `lib/presentation/views/recommendation/widgets/recommendation_card.dart` — card chung cho cả teacher + student (text mất dấu cho type badges)
- `lib/presentation/providers/recommendation_providers.dart` — `interventionCountProvider`, `teacherRecommendationNotifierProvider`, `top3RecommendationsProvider`
- `lib/data/datasources/recommendation_datasource.dart` — query bảng `ai_recommendations`
- `supabase/functions/process-ai-queue/index.ts` `handleAnalysis()` line 343-434 — generator hiện tại
- Bảng `ai_recommendations` (Supabase): `student_id`, `teacher_id`, `class_id`, `type`, `priority` (1-5), `title`, `description`, `resources` (jsonb), `dismissed`, `created_at`

**Luồng hiện tại:**
```
HS nộp bài → ai_queue (analysis) → Edge fn handleAnalysis()
  → query student_skill_mastery WHERE mastery_level < 0.6 LIMIT 5
  → INSERT ai_recommendations với CHỈ student_id (KHÔNG có teacher_id)
  → priority = round((1 - mastery) * 5) ⇒ 1=khẩn cấp, 5=thấp

Phía HS: top3RecommendationsProvider lấy 3 record student_id=me ⇒ HOẠT ĐỘNG
Phía GV: interventionCountProvider count WHERE teacher_id=me AND priority≤1 ⇒ luôn 0 (vì edge fn không bao giờ insert teacher_id)
```

### 4 Vấn đề chính cần fix

| ID | Vấn đề | Severity |
|---|---|---|
| REC-1 | Edge function không sinh `teacher_id` row → badge GV luôn ẩn (count=0) trên app thật. Chỉ thấy data từ seed `db/seed_05_recommendations_test_data.sql` | P0 — feature dead |
| REC-2 | UI `teacher_recommendations_screen.dart` toàn bộ text mất dấu ("Goi y hoc tap", "Khan cap", "Tat ca", "An goi y", "Loi tai du lieu", "Thu lai", "Khong co goi y nao", "Hom nay", "Hom qua"…). Cũng có ở `recommendation_card.dart` (`_buildTypeBadge` 9 nhãn) và `intervention_badge.dart` đã đúng dấu | P1 — UX |
| REC-3 | UI không JOIN `profiles` để hiển thị tên học sinh → GV không biết recommendation thuộc HS nào. Card chỉ ghi "Ôn tập: OBJ-1234 / mastery 30%" | P1 — UX |
| REC-4 | `_selectedClassId` declared nhưng không có dropdown filter lớp. Không có CTA hành động (giao bài bổ sung, xem chi tiết HS). Không group theo HS | P2 — feature gap |

### Câu hỏi cần user trả lời trước khi code

1. **Scope generator:**
   - (a) Edge fn hiện tại insert thêm `teacher_id` cho mỗi row HS yếu (1 HS yếu 5 LO → 5 row, mỗi row teacher_id của lớp HS đó), HOẶC
   - (b) Tạo edge fn riêng `aggregate-teacher-interventions` chạy daily/cron, gom HS yếu cùng 1 lớp thành 1 row teacher_id duy nhất với resources liệt kê HS, HOẶC
   - (c) Tạo SQL view `v_teacher_interventions` aggregate trực tiếp từ `student_skill_mastery` + `class_members`, datasource query view này thay vì query `ai_recommendations` cho phía GV.
   - **Đề xuất:** (c) — không trùng lặp data, luôn live theo mastery hiện tại, không cần thêm cron, dismiss vẫn dùng bảng cũ (record-level). Giảm nhất phụ thuộc edge function.

2. **Hiển thị tên HS trong card:**
   - Thêm field `student_name` vào response (datasource JOIN profiles).
   - Card teacher: thêm header "🎓 [Tên HS] · [Lớp]" trên title.
   - Confirm OK?

3. **Filter lớp:**
   - Thêm dropdown ở đầu `teacher_recommendations_screen` (load từ `teacherDashboardClassesProvider`), filter theo `class_id`. Confirm OK?

4. **Group theo HS:**
   - Card grouping: 1 HS = 1 expandable card, các LO yếu là sub-list. Hay vẫn để mỗi LO là 1 card riêng?
   - **Đề xuất:** Group — đỡ noise khi 1 HS yếu 5 LO.

5. **Push notification thật:**
   - Có cần thêm hay vẫn chỉ là badge in-app?
   - **Đề xuất:** Skip Phase này, defer sang Tier 3.

### Plan thực thi (đề xuất 3 Tier)

#### TIER 1 — UI fix nhanh (Low effort, high visibility)

Mục tiêu: text có dấu, hiển thị tên HS, filter lớp, không đụng backend.

**Thay đổi:**

```
lib/presentation/views/recommendation/teacher/teacher_recommendations_screen.dart
  - "Goi y hoc tap" → "Gợi ý học tập"
  - "Tat ca" → "Tất cả", "Khan cap" → "Khẩn cấp"
  - "Can chu y" → "Cần chú ý", "Goi y khac" → "Gợi ý khác"
  - "Khong co goi y nao" → "Không có gợi ý nào"
  - "Cac goi y se xuat hien khi co hoc sinh\ncan ho tro them." → "Các gợi ý sẽ xuất hiện khi có học sinh\ncần hỗ trợ thêm."
  - "Loi tai du lieu" → "Lỗi tải dữ liệu"
  - "Thu lai" → "Thử lại"
  - Thêm DropdownButton<String?> cho _selectedClassId, watch teacherDashboardClassesProvider
  - Group urgent recommendations theo student_id: Map<String, List<Recommendation>> grouped

lib/presentation/views/recommendation/widgets/recommendation_card.dart
  - _buildTypeBadge labels:
      "So sanh" → "So sánh"
      "Ky nang yeu" → "Kỹ năng yếu"
      "Can thiep" → "Can thiệp"
      "Nop muon" → "Nộp muộn"
      "Canh bao tham gia" → "Cảnh báo tham gia"
      "Rui ro" → "Rủi ro"
      "Goi y bai tap" → "Gợi ý bài tập"
      "Meo hoc tap" → "Mẹo học tập"
      "Co hoi cai thien" → "Cơ hội cải thiện"
  - "An goi y" tooltip → "Ẩn gợi ý"
  - "Khan cap" → "Khẩn cấp", "Cao" giữ, "Thap" → "Thấp"
  - "On tap" → "Ôn tập", "Tai lieu" → "Tài liệu"
  - _formatDate: "Hom nay" → "Hôm nay", "Hom qua" → "Hôm qua", "X ngay truoc" → "X ngày trước"
  - Thêm prop optional `studentName` + `className` → render header phía trên title nếu có
  - Đã xóa "Đã xóa gợi ý" snackbar text nếu cần đồng bộ

lib/data/datasources/recommendation_datasource.dart
  - getTeacherRecommendations(): select bổ sung student profile:
      .select('*, student:profiles!student_id(id, full_name, avatar_url), class:classes!class_id(id, name)')
  - _mapRowToRecommendation: parse thêm studentName, className từ row
  - (Cần kiểm tra schema FK qua Supabase MCP trước khi thay select string)

lib/domain/entities/recommendation/recommendation.dart
  - Thêm field optional: String? studentName, String? className (Freezed)
  - dart run build_runner build -d
```

**Verify:**
- `flutter analyze` 0 error
- Mở teacher recommendations screen → text đầy đủ dấu
- Card hiện tên HS (sau khi T2 enable data)

#### TIER 2 — Backend pipeline (Medium effort, fix REC-1)

Mục tiêu: GV thực sự thấy data sinh tự động, không cần seed.

**Phương án đề xuất: SQL view aggregate**

```
db/migration_25_teacher_interventions_view.sql
  CREATE OR REPLACE VIEW v_teacher_interventions AS
  SELECT
    gen_random_uuid()::text AS virtual_id,
    cm_t.user_id              AS teacher_id,
    ssm.student_id            AS student_id,
    cls.id                    AS class_id,
    cls.name                  AS class_name,
    p.full_name               AS student_name,
    p.avatar_url              AS student_avatar,
    'intervention'            AS type,
    GREATEST(1, LEAST(5, ROUND((1 - AVG(ssm.mastery_level)) * 5))) AS priority,
    'Cần can thiệp: ' || p.full_name AS title,
    'HS yếu ' || COUNT(*) || ' kỹ năng (mastery TB ' ||
      ROUND(AVG(ssm.mastery_level) * 100) || '%)' AS description,
    jsonb_build_object(
      'objective_ids', array_agg(ssm.objective_id),
      'mastery_avg', AVG(ssm.mastery_level),
      'weak_count', COUNT(*)
    )                         AS resources,
    false                     AS dismissed,
    NOW()                     AS created_at
  FROM student_skill_mastery ssm
  JOIN class_members cm_s ON cm_s.user_id = ssm.student_id AND cm_s.role = 'student'
  JOIN classes cls         ON cls.id = cm_s.class_id
  JOIN class_members cm_t  ON cm_t.class_id = cls.id AND cm_t.role = 'teacher'
  JOIN profiles p          ON p.id = ssm.student_id
  WHERE ssm.mastery_level < 0.6
  GROUP BY cm_t.user_id, ssm.student_id, cls.id, cls.name, p.full_name, p.avatar_url
  HAVING COUNT(*) >= 1;

  -- RLS view: chỉ teacher đó đọc được row của mình
  CREATE POLICY "teacher_view_own_interventions" ON v_teacher_interventions
    FOR SELECT USING (teacher_id = (select auth.uid()));
```

**Lưu ý:**
- View không tự sinh ID stable (mỗi query 1 UUID khác) → KHÔNG dismiss được. Cần workflow dismiss riêng:
  - Option: bảng `teacher_intervention_dismissals(teacher_id, student_id, dismissed_at)`. Datasource LEFT JOIN để filter.
  - Option khác: bỏ chức năng dismiss cho teacher view (vì data tự refresh khi mastery thay đổi).
  - **Đề xuất:** dismiss = "snooze 7 ngày" → bảng `teacher_intervention_snoozes(teacher_id, student_id, until_at)`. View filter ra.

**Files đụng:**
```
db/migration_25_teacher_interventions_view.sql        (NEW)
db/migration_25_teacher_intervention_snoozes.sql      (NEW, optional)
lib/data/datasources/recommendation_datasource.dart   (getTeacherRecommendations đổi sang query view)
lib/presentation/providers/recommendation_providers.dart (interventionCountProvider count từ view)
docs/note sql.txt                                     (sync schema)
memory-bank/README_SUPABASE.md                        (note view + table mới)
```

**Verify:**
- Apply migration qua Supabase MCP
- Test với account GV K17A1 → badge hiện số HS yếu thật
- Dismiss → row biến mất 7 ngày
- Mastery tăng > 60% → row biến mất ngay (live)

#### TIER 3 — Tương lai (Defer)

- Push notification realtime (FCM hoặc Supabase Realtime subscribe `student_skill_mastery` → trigger snackbar/notification)
- CTA "Giao bài bổ sung" trong card → push sang `teacher_create_assignment` với `objective_ids` từ resources prefilled
- Drilldown card → mở screen chi tiết HS với radar chart kỹ năng yếu
- "Liên hệ phụ huynh" button (cần feature parent contact hiện chưa có)

### Files quick reference

```
UI:
  lib/presentation/views/recommendation/widgets/intervention_badge.dart            (đã đúng dấu, không đụng)
  lib/presentation/views/recommendation/widgets/recommendation_card.dart           (T1 — sửa text + thêm studentName/className)
  lib/presentation/views/recommendation/teacher/teacher_recommendations_screen.dart (T1 — sửa text + dropdown lớp + group)
  lib/presentation/views/recommendation/student/student_recommendations_tab.dart   (T1 — kiểm tra text)

Data:
  lib/data/datasources/recommendation_datasource.dart                              (T1 — JOIN profiles. T2 — query view)
  lib/domain/entities/recommendation/recommendation.dart                           (T1 — thêm studentName, className. build_runner)
  lib/presentation/providers/recommendation_providers.dart                         (T2 — interventionCount đổi nguồn)

Backend:
  supabase/functions/process-ai-queue/index.ts                                     (KHÔNG đụng — vẫn sinh student_id rows cho phía HS)
  db/migration_25_teacher_interventions_view.sql                                   (T2 — NEW)
  db/migration_25_teacher_intervention_snoozes.sql                                 (T2 — NEW, optional dismiss)

Docs:
  docs/note sql.txt                                                                (T2 — sync)
  memory-bank/README_SUPABASE.md                                                   (T2 — sync)
  memory-bank/activeContext.md, progress.md                                        (post-fix update)
```

### 5 câu hỏi cần user trả lời khi resume

1. **Scope:** chọn (a) edge fn insert teacher_id, (b) cron aggregate, hay (c) SQL view? Đề xuất (c).
2. **Group cards theo HS** (1 HS = 1 card với sub-list LO yếu) hay giữ 1 card / 1 LO?
3. **Dismiss workflow** cho teacher view: snooze 7 ngày, dismiss vĩnh viễn, hay bỏ dismiss?
4. **Tier order:** làm T1 (UI) trước rồi T2 (backend), hay T2 trước (vì không có data thật thì test T1 không ý nghĩa)?
5. **CTA "Giao bài bổ sung"**: include trong T1 hay defer T3?

Đủ 5 câu trả lời là có thể bắt đầu thực thi không cần discuss thêm.


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
✅ Context output: "Câu 1: MCQ 4 lựa chọn độ khó 2/5 — Tags: flutter, cơ bản"
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
  // qty × 220 + 400 overhead, clamp [800, 4000]
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

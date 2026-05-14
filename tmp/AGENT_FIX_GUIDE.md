# AGENT FIX GUIDE — Mode 3 + LaTeX + Web Crash

> **Tạo bởi:** Session 2026-05-11 (Claude Opus 4.7 + marionette + dart MCP)
> **Tester:** Auto qua Flutter web (Chrome localhost:55750)
> **Account:** `ha@gmail.com` (teacher "Thái Anh Huy")
> **Trạng thái:** 3 bug P0 CRITICAL phát hiện qua live test — TẤT CẢ items đánh dấu "RESOLVED" trong `AGENT_TEST_GUIDE.md` đều **chưa fix triệt để** hoặc đã regression.

---

## 1. Tóm tắt nhanh

| ID | Severity | Title | File | Lý do user thấy |
|----|----------|-------|------|-----------------|
| **F-001** | P0 BLOCKER | `String.fromEnvironment` crash Flutter web | `lib/core/services/ai_service.dart:111` | `AiService.initialize()` throw `DartError` → provider crash, AI vẫn gọi được nhờ retry, nhưng log đầy lỗi |
| **F-002** | P0 BLOCKER | JSON parser không decode được LaTeX escape | `lib/data/repositories/ai_repository_impl.dart:671` (`_tryParseJson`) | **Đây là root cause của TẤT CẢ phàn nàn user.** AI gen ra LaTeX OK (`$x^2 - 7x + 12 = 0$`, `$A = F \cdot s$`) nhưng `jsonDecode` throw vì `\c`, `\s`, `\d` không phải JSON escape → null → fallback `"Câu hỏi N (cần chỉnh sửa)"` x10 |
| **F-002b** | P0 | Regex sanitize bỏ sót `\frac`, `\theta`, `\to`, `\nabla` (LaTeX command bắt đầu bằng `\f`, `\t`, `\n`, `\r`, `\b`) | `_sanitizeLatexInJson` regex v1 | Regex v1 whitelist `["\\/bfnrtu]` để `\f` `\t` `\n` `\r` `\b` qua → `jsonDecode` ăn `\f` thành form-feed → mất chữ `f` → render literal đỏ `rac{-b...}`. Regex v2 cần catch `\` theo sau 2+ chữ cái (LaTeX command). |
| **F-003** | P1 | Default model là Groq llama, không phải Gemini 2.0 Flash | `lib/core/services/api_key_service.dart` | Schema response Groq có thể khác Gemini → V-001 fix không cover trường hợp này |

---

## 2. Evidence — Log raw từ live test

Test path: Mode 3 (tab Tài liệu) → file mẫu `mau_cau_hoi_multipleChoice_word_1778326787066.docx` (5 câu MCQ, role 📋 Mẫu auto) → chip `Cùng dạng` → button `Sinh từ tài liệu` (qty=10).

### 2.1 Log SUCCESS path (chip behavior + branch đúng)

```
💡 [Mode3] useAsStyleTemplate=true, docChars=812, topic="Câu hỏi từ tài liệu"
💡 🔧 [AI REPO] generateQuestions: qty=10 type=null useTemplate=true resolvedMode=sameForm templateQCount=5
💡 🧠 [Prompt] Template mode → branch=sameForm qty=10 type=null
💡 🧠 [Prompt] Built sameForm prompt: 6761 chars. Preview:
   Bạn là giáo viên VN có 10+ năm kinh nghiệm soạn đề. Câu hỏi PHẢI:
   - Dùng tiếng Việt sư phạm, văn phong rõ ràng, đúng cấp học (lớp 9-12).
   - BÁM CHẶT MÔN HỌC trong tài liệu mẫu — KHÔNG tự suy sang môn khác...
```

→ **Chip + branch + prompt build CHẠY ĐÚNG.** User phàn nàn "tùm lum" là vì OUTPUT, không phải chip logic.

### 2.2 Log CRASH path (Bug F-001 — Web only)

```
DartError: Unsupported operation: String.fromEnvironment can only be used as a const constructor
dart-sdk/lib/_internal/js_dev_runtime/patch/core_patch.dart 436:5   fromEnvironment
package:ai_mls/core/services/ai_service.dart 111:28                  <fn>
package:ai_mls/core/services/ai_service.dart 95:23                   initialize
package:ai_mls/data/datasources/ai_datasource.dart 8:15              new
```

Code tại `ai_service.dart:111`:
```dart
final envFile = String.fromEnvironment(
  'ENV_FILE',
  defaultValue: '.env.dev',
);
```

→ DDC (Flutter web debug) enforce `String.fromEnvironment` chỉ được dùng trong **const context**. Code này dùng làm local variable → runtime throw. Trên mobile (AOT) thì pass nhờ tree-shake.

### 2.3 Log CORE BUG (Bug F-002 — Cross-platform)

```
🔑 [API Key Service] Using Groq API key from profile metadata
🤖 [AI Service] Calling Groq API... model=llama-3.3-70b-versatile

⚠️ [AI REPO] No questions found. Raw response (500 chars):
[
  {"type":"multiple_choice","override_text":"Nghiệm phương trình $x^2 - 7x + 12 = 0$ là:","choices":[{"id":0,"text":"$x = 3$ hoặc $x = 4$","isCorrect":true},{"id":1,"text":"$x = -3$ hoặc $x = -4$","isCorrect":false},...]}
  {"type":"multiple_choice","override_text":"Công thức tính công cơ học là:","choices":[{"id":0,"text":"$A = F \cdot s$","isCorrect":...
```

**Quan sát quan trọng:**
- AI **đã gen LaTeX đúng**: `$x^2 - 7x + 12 = 0$`, `$x = 3$ hoặc $x = 4$`, `$A = F \cdot s$`
- Schema response: `[{type, override_text, choices: [{id, text, isCorrect}], tags}]` — đây là array of objects, valid Dart structure
- Nhưng log nói **"No questions found"** → vào fallback path → trả 10 câu `_generateFallbackQuestions`:

```
✅ [AI REPO] Generated 10 questions
📝 [Result] ══ Generated 10 câu ══
  Q1[multipleChoice|diff=null] Câu hỏi 1 (cần chỉnh sửa)
       → ans=A | opts: A.Lựa chọn A (cần chỉnh sửa) | B.Lựa chọn B | C.Lựa chọn C | D.Lựa chọn D
       → tags:
  ... (lặp Q2-Q10 y hệt)
```

### 2.4 Root cause F-002 — chi tiết

`_tryParseJson` ở `ai_repository_impl.dart:671`:

```dart
dynamic _tryParseJson(String jsonString) {
  String s = jsonString.trim();
  ...
  // 2) Try direct decode first
  try {
    return jsonDecode(s);   // ← FAIL ở đây với LaTeX
  } catch (_) { /* continue */ }

  // 3) Heuristic extract substring
  ...
  try {
    return jsonDecode(candidate);   // ← FAIL lần 2 cùng lý do
  } catch (_) {
    return null;   // ← Trả null → fallback
  }
}
```

**Vì sao `jsonDecode` fail:**

AI gen JSON string chứa LaTeX command như `"text":"$A = F \cdot s$"`.

Trong JSON spec, `\` phải được escape thành `\\`. Các escape hợp lệ chỉ là: `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`, `\uXXXX`.

LaTeX commands `\cdot`, `\sqrt`, `\sum`, `\int`, `\alpha`, `\beta`, `\geq`, `\leq`, `\pm`, `\div`, `\times`, `\theta`, `\pi`, `\Delta`... đều có `\<chữ>` không phải escape JSON hợp lệ → `FormatException` ngay.

`\frac` đặc biệt evil — `\f` LÀ valid (form feed) nên `jsonDecode` không throw ở char `f`, nhưng phần sau `rac{1}{2}` sẽ break tiếp tại `\{` nếu có.

---

## 3. FIX PROPOSALS

### F-001 Fix — `String.fromEnvironment` crash

**File**: `lib/core/services/ai_service.dart:111-118`

**Vấn đề**: Dùng làm runtime variable.

**Fix option A (đơn giản nhất) — wrap trong const**:

```dart
// Đổi từ:
final envFile = String.fromEnvironment(
  'ENV_FILE',
  defaultValue: '.env.dev',
);

// Sang:
const envFile = String.fromEnvironment(
  'ENV_FILE',
  defaultValue: '.env.dev',
);
```

Note: `const` chỉ work khi compile-time constant, không thể `apiKey ?? Env.aiApiKey` parameterize. Nhưng ở case này chỉ cần `--dart-define=ENV_FILE=...` nên `const` work fine.

**Fix option B — bỏ luôn log debug này** (nó chỉ là debug log không quan trọng):

```dart
// Xóa hoàn toàn block từ line 110-118 nếu không cần debug ENV_FILE.
```

**Recommended**: Option A — sửa 1 keyword `final` → `const`.

---

### F-002 Fix — JSON parser cho LaTeX (CRITICAL)

**File**: `lib/data/repositories/ai_repository_impl.dart:670-728`

**Fix steps**:

1. Thêm helper `_sanitizeLatexInJson(String)` — escape backslash thành `\\` cho các LaTeX command phổ biến trước khi `jsonDecode`.

2. Trong `_tryParseJson`, thêm bước retry sau khi 2 lần decode fail:

```dart
// Sau line 691 (sau "// continue" của first decode)

// 2b) Retry with LaTeX sanitization
try {
  final sanitized = _sanitizeLatexInJson(s);
  return jsonDecode(sanitized);
} catch (_) {
  // continue
}
```

3. Implement helper (đặt cuối class):

```dart
/// Escape LaTeX backslashes (`\frac`, `\cdot`, ...) for valid JSON.
/// AI generators thường trả LaTeX trong JSON string KHÔNG escape `\`.
/// Strategy: tìm `\` không theo sau JSON escape hợp lệ → escape thành `\\`.
String _sanitizeLatexInJson(String input) {
  // JSON valid escapes: \" \\ \/ \b \f \n \r \t \uXXXX
  // Nếu thấy \ theo sau ký tự khác → coi là LaTeX, escape thành \\
  final invalidEscape = RegExp(r'\\(?!["\\/bfnrtu])');
  return input.replaceAllMapped(invalidEscape, (_) => r'\\');
}
```

**Test verification**: Sau fix, gen lại với Mode 3 sameForm + file template MCQ → kiểm log:
```
📝 [Result] ══ Generated 10 câu ══
  Q1[multipleChoice|diff=2] Nghiệm phương trình $x^2 - 7x + 12 = 0$ là:
       → ans=A | opts: A.$x = 3$ hoặc $x = 4$ | B.$x = -3$ hoặc $x = -4$ | ...
```

KHÔNG còn `Q1[...] Câu hỏi 1 (cần chỉnh sửa)`.

**Cảnh báo bổ sung**: Schema AI trả `{type: "multiple_choice", override_text, choices: [{id, text, isCorrect}]}` cần `_mapAiQuestionToStandardFormat` (line 249) xử lý. Đọc function này để verify nó accept schema `override_text` + `choices[].isCorrect`. Nếu không, có thể parse được nhưng vẫn fail map → cần fix thêm.

---

### F-003 Fix — Default model dropdown

**File**: `lib/core/services/api_key_service.dart` (function lấy model từ profile)

**Vấn đề**: Đang dùng Groq llama-3.3-70b-versatile thay vì Gemini 2.0 Flash (theo spec S2.3).

**Fix**: Kiểm tra logic priority chọn provider:

1. Nếu user có config Groq API key → dùng Groq
2. Nếu KHÔNG có → fallback Gemini với default model `gemini-2.0-flash`

Profile của user test `ha@gmail.com` đang có Groq API key → đó là lý do dùng Groq. Đây có thể là **expected behavior** nếu user chủ động cấu hình Groq.

**Nhưng**: Schema Groq trả về `override_text` + `choices[].isCorrect` — schema này có hợp với parser `_mapAiQuestionToStandardFormat` không? Cần grep & verify.

**Action item**: Đọc `_mapAiQuestionToStandardFormat` (`lib/data/repositories/ai_repository_impl.dart:~249-400`) → kiểm tra có handle:
- `override_text` (Groq schema) vs `text` / `content` (Gemini schema)?
- `choices: [{id, text, isCorrect}]` (Groq) vs `options: [{label, content, correct}]` (Gemini)?

Nếu schemas khác → cần thêm branch xử lý trong `_mapAiQuestionToStandardFormat`.

---

## 4. Test sau khi fix

### 4.1 Pre-conditions
- Code đã sửa F-001 + F-002 (F-003 nếu schema khác)
- Build runner: `dart run build_runner build --delete-conflicting-outputs` (nếu đụng Freezed)
- Hot restart Flutter app (không hot reload — vì sửa AI service init)

### 4.2 Verification script (paste vào session sau)

```
1. Connect marionette với VM service URI mới (lấy từ get_app_logs)
2. mcp__marionette__take_screenshots — verify đang ở login screen
3. Login với ha@gmail.com / 12345678
4. Bottom nav: Bài tập → "Tạo bài mới" → "Thêm câu hỏi" (FAB) → tab "Tài liệu"
5. Verify chip "Tạo mới" active, file mẫu auto-load
6. Tap chip_same_form → verify chip xanh
7. Tap btn_generate
8. Đợi 15s
9. mcp__dart__get_app_logs maxLines=200
10. Tìm trong log:
    ✅ KHÔNG có "String.fromEnvironment can only be used as const"
    ✅ KHÔNG có "No questions found. Raw response"
    ✅ Có "Q1[multipleChoice|diff=N] <nội dung Toán/Lý/Hóa thật>"
    ✅ "opts:" có LaTeX `$...$` thật, không phải "Lựa chọn A (cần chỉnh sửa)"
11. mcp__marionette__take_screenshots — verify card hiện công thức đẹp (MathText render fraction)
```

### 4.3 Regression tests cần chạy

| TC | Skill area |
|----|-----------|
| TC-01 Mode 1 prompt | Verify Gemini path không gãy F-002 |
| TC-02 Mode 2 Excel | Verify parse local Excel không gọi AI |
| TC-05 Mode 3 styleOnly | Verify chip "Tạo mới" cho output đúng |
| TC-06 Mode 3 sameForm | Same — đã test trong session này |
| TC-10 Auto-downgrade | Verify nếu file không có số liệu thì downgrade |
| S1.5.1 LaTeX render | Verify MathText render `$\frac{1}{2}$` đẹp |
| S5.4.3 Export Word OMML | Verify export ra Word file có phân số thật |

---

## 5. Notes cho session fix

### 5.1 Ưu tiên fix order

```
F-001 (web crash) → F-002 (JSON parser) → re-test cả 10 câu hiển thị nội dung thật → F-003 (chỉ nếu schema map fail)
```

### 5.2 KHÔNG cần làm trong fix session này

- Đừng đụng chip logic (`chip_same_form`, `chip_style_only`) — đã verify chạy đúng
- Đừng đụng prompt builder (`getGenerateQuestionsPrompt`) — đã build prompt 6761 chars đúng
- Đừng thêm Force toggle lại (V-002 đã bỏ đúng)
- Đừng đụng `useAsStyleTemplate` detection logic — đã `=true` đúng cho file MCQ

### 5.3 Memory bank update

Sau khi fix xong, update:
- `memory-bank/activeContext.md` — ghi 3 bugs fix kèm commit hash
- `tmp/AGENT_TEST_GUIDE.md` issue tracker — thêm F-001/F-002/F-003 với status RESOLVED + commit hash

### 5.4 Skill `flutter-web-debug` đã verify hoạt động

Skill mới tạo (`.claude/skills/flutter-web-debug/SKILL.md`) đã hoạt động end-to-end với Flutter web qua `mcp__marionette__connect` + VM service URI từ DTD logs. Workflow này có thể tái sử dụng cho session sau.

---

## 6. Phụ lục — Tóm tắt mapping user complaint → bug

| User báo | Hiện tượng kỹ thuật | Bug ID | Fix |
|----------|---------------------|--------|-----|
| "Chip chạy tùm lum" | Chip logic đúng nhưng output toàn placeholder làm user thấy chip vô tác dụng | F-002 | Fix JSON parser → output thật → chip có ý nghĩa |
| "Mode chạy không đúng ý tưởng" | branch=sameForm log đúng, nhưng câu output là fallback placeholder | F-002 | Same |
| "LaTeX AI chưa thêm được" | AI THẬT SỰ gen LaTeX (`$x^2 - 7x + 12 = 0$`) nhưng parser nuốt mất | F-002 | Same — sau fix sẽ thấy LaTeX trong card |

→ **1 fix F-002 giải quyết cả 3 phàn nàn.** F-001 cần fix để web không spam crash log nhưng không phải nguyên nhân user-facing bug.

---

## 7. Quick fix patch (sẵn để apply)

### Patch 1 — `lib/core/services/ai_service.dart`

```diff
@@ -108,11 +108,11 @@
     }

     // Debug: Check ENV_FILE environment variable
-    final envFile = String.fromEnvironment(
+    const envFile = String.fromEnvironment(
       'ENV_FILE',
       defaultValue: '.env.dev',
     );
```

### Patch 2 — `lib/data/repositories/ai_repository_impl.dart`

Trong `_tryParseJson`, thêm sau block "// 2) Try direct decode first":

```diff
@@ -686,6 +686,14 @@
     // 2) Try direct decode first
     try {
       return jsonDecode(s);
     } catch (_) {
       // continue
     }

+    // 2b) Retry with LaTeX-aware sanitization.
+    // AI thường trả LaTeX (\\frac, \\cdot, \\sqrt...) trong JSON string không escape backslash.
+    try {
+      final sanitized = _sanitizeLatexInJson(s);
+      return jsonDecode(sanitized);
+    } catch (_) {
+      // continue
+    }
+
     // 3) Heuristic: extract first JSON object/array substring from noisy text
```

Và thêm helper cuối class (trước `}` đóng class):

```dart
/// Escape backslash trong JSON string không phải escape JSON hợp lệ.
/// AI generators (Groq llama, Gemini) thường trả LaTeX `\frac`, `\cdot`
/// trong JSON string KHÔNG escape — `jsonDecode` sẽ throw.
String _sanitizeLatexInJson(String input) {
  return input.replaceAllMapped(
    RegExp(r'\\(?!["\\/bfnrtu])'),
    (_) => r'\\',
  );
}
```

### Verify lệnh sau patch

```powershell
flutter analyze
flutter test test/unit/data/repositories/  # nếu có test cho parser
# Hot restart app, login lại, test Mode 3 sameForm
```

---

**END OF FIX GUIDE.**

---

# 🔧 ADDENDUM — F-002b Fix (2026-05-11)

## Vấn đề phát sinh sau Patch 2 ban đầu

Sau khi apply regex v1: `\\(?!["\\/bfnrtu])`, test phát hiện:
- ✅ `\Delta`, `\pm`, `\sqrt`, `\cdot` render OK
- ❌ `\frac` → render **literal đỏ** `$x = rac{-b...}$` (mất chữ `f`)

**Root cause**: `\f` LÀ JSON escape hợp lệ (form-feed `0x0C`). Regex v1 để nó qua. `jsonDecode` xử lý `\f` thành form-feed char → còn lại `rac{...}`. MathText không parse được LaTeX nửa vời → fallback render literal đỏ.

Cùng pattern với: `\to`, `\theta`, `\tau`, `\times`, `\nabla`, `\neq`, `\rho`, `\rightarrow`, `\beta`, `\binom`, `\boxed`...

## Patch 2b — Regex v2

```dart
String _sanitizeLatexInJson(String input) {
  return input.replaceAllMapped(
    // Match 1: \\ followed by 2+ letters (LaTeX command like \frac, \beta, \theta)
    // Match 2: \\ followed by char NOT in JSON whitelist (\, \; \!)
    RegExp(r'\\(?=[a-zA-Z]{2,}|[^"\\/bfnrtu])'),
    (_) => r'\\',
  );
}
```

**Logic**:
- Alternative 1 `[a-zA-Z]{2,}`: catch LaTeX command (luôn 2+ chữ) → escape tất cả `\frac`, `\theta`, `\to`, `\Delta`, `\pm`, v.v.
- Alternative 2 `[^"\\/bfnrtu]`: catch ký tự LaTeX 1-char không phải JSON escape (`\,`, `\;`, `\!`, `\#`...)
- Giữ nguyên `\"`, `\\`, `\/`, `\u<hex>`, và single `\b/f/n/r/t` không theo sau letter (control chars hợp lệ)

## Verify sau Patch 2b

Test với prompt "Phương trình bậc hai... công thức nghiệm + Viet + Delta":

**Log raw từ AI (Groq)**:
```
Q3: A.$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$ | ...
Q5: A.$x_1 + x_2 = \frac{-b}{a}$ và $x_1 \cdot x_2 = \frac{c}{a}$ | ...
```

**Sau sanitize + decode** (log `_logGeneratedQuestions`):
```
Q3: A.$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$ ...
   (đã escape double, decode lại thành single \frac ✓)
```

**UI render**:
- Q3 tất cả 4 đáp án: **phân số THẬT** (tử/mẫu/gạch ngang) ✓
- Q5 Viet với `\cdot`: dấu nhân thật ✓
- Q6, Q8 Delta `\Delta = b^2 - 4ac`: ký tự Δ + mũ 2 đẹp ✓
- KHÔNG còn text đỏ literal ✓

## Lesson learned

**JSON valid escape ≠ "không phải LaTeX"**. Khi sanitize, phải hiểu: nếu AI gen `\f` trong literal text, KHÔNG bao giờ ý là form-feed character — luôn là start của LaTeX command. Tương tự `\t`, `\n`, `\r`, `\b`. Whitelist phải dựa trên **ngữ cảnh** (1 letter alone = JSON escape OK, 2+ letters = LaTeX command escape).

Edge case còn tồn đọng (low priority):
- Single-letter LaTeX như `\,`, `\;`, `\!` — đã handle qua Match 2.
- `\u<4 hex>` legitimate JSON unicode — preserved vì `u` trong whitelist.
- Multi-line text với real `\n` newline — preserved (single `n` không match Match 1, `n` trong whitelist Match 2).

**END OF ADDENDUM.**

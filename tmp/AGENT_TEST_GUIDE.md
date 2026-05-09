# Agent Test Guide — AI Question Generation (Mode 1/2/3)

> **Mục đích**: Hướng dẫn agent dùng MCP tools (marionette + dart) để test tự động  
> tính năng tạo câu hỏi bằng AI, đọc log nội dung câu hỏi/đáp án, debug chính xác.

---

## 0. Chuẩn bị file mẫu (người dùng thêm thủ công)

Đặt các file sau vào `/mnt/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD/tmp/`:

| Tên file | Mô tả | Dùng cho |
|---|---|---|
| `mau_excel_mcq.xlsx` | Excel MCQ 5 câu, loại mixed (có số liệu) | TC-05, TC-06, TC-07 |
| `mau_excel_2mcq.xlsx` | Excel MCQ đúng 2 câu TN | TC-09a (GAP-6 threshold) |
| `mau_excel_1mcq.xlsx` | Excel MCQ chỉ 1 câu TN | TC-09b (chip Cùng dạng disabled) |
| `mau_excel_nonum.xlsx` | Excel MCQ không có số/đơn vị | TC-10 (auto-downgrade) |
| `mau_word_mcq.docx` | Word template có "Câu N:" format | TC-03, TC-08 |
| `kienthuc.docx` | Word kiến thức thuần (bài giảng) | TC-04, TC-07 |

> **Cách tạo nhanh từ ứng dụng**: Settings → Tải File Mẫu → chọn format → tải về.  
> Sau đó sao chép/đổi tên vào thư mục tmp/ theo bảng trên.

---

## 1. Setup — Khởi động & kết nối

### Bước 1.1 — Khởi động Flutter app

```
flutter run --debug
```

Ghi lại VM service URI từ output (dạng `ws://127.0.0.1:XXXX/ws`).

### Bước 1.2 — Kết nối Marionette

```json
mcp__marionette__connect({ "uri": "ws://127.0.0.1:XXXX/ws" })
```

### Bước 1.3 — Xác nhận kết nối

```json
mcp__marionette__take_screenshots({})
```

Kết quả: ảnh màn hình app hiện tại.

### Bước 1.4 — Đọc log tool

```json
mcp__dart__get_app_logs({})
```

Log format: `[timestamp] LEVEL [tag] message`

---

## 2. Navigate đến màn hình AI Generate

### Bước 2.1 — Tìm nút vào màn hình

```json
mcp__marionette__get_interactive_elements({})
```

Tìm element có text `"Tạo câu hỏi bằng AI"` hoặc navigate qua assignment flow.

### Bước 2.2 — Xác nhận màn hình đúng

```json
mcp__marionette__take_screenshots({})
```

Màn hình đúng có: title `"Tạo câu hỏi bằng AI"`, 3 tab `"Nhập Prompt"` / `"Trích xuất"` / `"Tài liệu"`.

---

## 3. Luồng đọc log sau mỗi test

Sau mỗi hành động, đọc log ngay:

```json
mcp__dart__get_app_logs({})
```

### Bảng log prefix quan trọng

| Prefix | Ý nghĩa |
|---|---|
| `🔵 [Generate]` | Bắt đầu generate, log params đầu vào |
| `[Generate] processingMode=...` | Mode được dùng, danh sách file IDs |
| `[Mode3]` | Log nội bộ Mode 3 (RAG) |
| `[Mode3] rawText →` | Số ký tự text lấy từ file |
| `[Mode3] hasExcelTemplate=...` | Phát hiện file mẫu loại gì |
| `[Mode3] T2-3 numeric ratio=...` | Tỉ lệ câu có số liệu (quyết định sameForm/styleOnly) |
| `[Mode3] Auto-downgrade` | Tự động hạ sameForm → styleOnly |
| `[Mode3] smartTruncate:` | Context bị cắt ngắn hay không |
| `📄 [Context]` | Xây context gửi cho AI |
| `📄 [Context] Total context:` | Tổng số ký tự context |
| `🧠 [Prompt] Template mode →` | Branch prompt được dùng (styleOnly/sameForm) |
| `🧠 [Prompt] Built ... prompt:` | Preview 400 ký tự đầu prompt |
| `🤖 [AI Service] Calling Gemini` | AI call bắt đầu |
| `✅ [AI Service] Gemini API response` | AI trả lời |
| `❌ [AI Service]` | Lỗi API |
| `📝 [Result] ══ Generated N câu ══` | **Bắt đầu log chi tiết câu hỏi** |
| `  Q1[type\|diff=N]` | Câu hỏi: type, độ khó, nội dung |
| `       → ans=X \| opts:` | Đáp án đúng và các lựa chọn |
| `       → tags:` | Tags của câu |
| `  Q1[...] ⚠sim=N% (tpl#M)` | Câu tương tự mẫu N% với câu mẫu số M |
| `📝 [Result] ══ End ══` | Kết thúc log chi tiết |
| `[LocalTempFile] Template parsed:` | File parse xong, có N câu |
| `[LocalTempFile] Text extracted:` | File extract text xong |

---

## 4. Test Cases

---

### TC-01 — Mode 1: Nhập Prompt cơ bản

**Mục tiêu**: AI tạo câu từ topic thuần, không file.

**Bước:**

1. Tap tab `"Nhập Prompt"` (key: `tab_promptOnly`)
2. Nhập topic: `"Lịch sử Việt Nam thế kỷ 20"`
3. Đặt số lượng: `5`
4. Tap button `"Tạo câu hỏi"` (key: `btn_generate`)
5. Đọc log

**Log cần thấy:**
```
🔵 [Generate] _handleGenerate called
🔵 [Generate] topic="Lịch sử Việt Nam thế kỷ 20", _isQtyMismatch=false...
[Generate] processingMode=promptOnly, selectedFileIds(0)=[]
🤖 [AI Service] Calling Gemini API...
✅ [AI Service] Gemini API response received
📝 [Result] ══ Generated 5 câu ══
  Q1[multipleChoice|diff=3] ...
       → ans=A | opts: A.xxx | B.xxx | C.xxx | D.xxx
📝 [Result] ══ End ══
```

**Pass nếu**: `Generated 5 câu`, có đủ nội dung câu hỏi và đáp án, KHÔNG có `❌ [AI Service]`.

**Fail nếu**: `EXIT: topic empty`, form validation failed, hoặc AI error.

---

### TC-02 — Mode 2: Trích xuất từ Excel

**Mục tiêu**: Excel Mẫu → câu hỏi được parse trực tiếp, KHÔNG gọi AI.  
**File cần**: `mau_excel_mcq.xlsx`

**Bước:**

1. Tap tab `"Trích xuất"` (key: `tab_extraction`)
2. Tap `"+ Thêm tài liệu"` (key: `btn_add_file`) → chọn `mau_excel_mcq.xlsx`
3. Đọc log để xác nhận parse:
   ```
   [LocalTempFile] Template parsed: 5 câu hỏi + 0 chars text từ mau_excel_mcq.xlsx
   ```
4. Tick file card (key: `file_card_<id>`)
5. Tap `"Trích xuất câu hỏi"` (key: `btn_generate`)
6. Đọc log

**Log cần thấy:**
```
[Generate] processingMode=extraction, selectedFileIds(1)=[...]
📝 [Result] ══ Generated 5 câu ══
  Q1[multipleChoice|diff=N] ...
```

**Snackbar**: `"Đã tải 5 câu hỏi từ file Excel"`

**KHÔNG thấy**: `🤖 [AI Service] Calling Gemini` — đây là dấu hiệu pass vì không gọi AI.

---

### TC-03 — Mode 2: Trích xuất từ Word

**Mục tiêu**: Word doc → AI đọc text → sinh câu.  
**File cần**: `mau_word_mcq.docx`

**Bước:**

1. Tap tab `"Trích xuất"` (key: `tab_extraction`)
2. Thêm file `mau_word_mcq.docx`
3. Log: `[LocalTempFile] Text extracted: N chars từ mau_word_mcq.docx`
4. Tick file, tap `"Trích xuất câu hỏi"`
5. Đọc log

**Log cần thấy:**
```
[Generate] useAsStyleTemplate=true/false, docChars=N/M
🤖 [AI Service] Calling Gemini API...
📝 [Result] ══ Generated N câu ══
```

**Pass nếu**: câu hỏi được tạo, có nội dung liên quan đến Word doc.

---

### TC-04 — Mode 3: RAG chỉ file Kiến thức

**Mục tiêu**: Word kiến thức → AI tạo câu từ nội dung tài liệu (không có mẫu).  
**File cần**: `kienthuc.docx`

**Bước:**

1. Tap tab `"Tài liệu"` (key: `tab_ragGeneration`)
2. Thêm `kienthuc.docx`
3. Log: `[LocalTempFile] Text extracted: N chars`
4. Xác nhận role badge hiển thị `📚 KT` (file chỉ có text, không toggleable)
5. Tick file, tap `"Sinh từ tài liệu"` (key: `btn_generate`)
6. Đọc log

**Log cần thấy:**
```
[Mode3] selectedIds(1)=[...]
[Mode3] file=kienthuc.docx | extractedChars=N | parsedQty=0 | selected=true
[Mode3] rawText → N chars
[Mode3] hasExcelTemplate=false, hasDocxTemplate=false → useAsStyleTemplate=false
[Mode3] smartTruncate: total=N, used=N, wasTruncated=false
🤖 [AI Service] Calling Gemini API...
📝 [Result] ══ Generated N câu ══
```

**Snackbar**: `"Phát hiện tài liệu lý thuyết — AI sẽ tạo câu dựa trên kiến thức trong tài liệu."`

**Pass nếu**: `useAsStyleTemplate=false`, câu hỏi có nội dung khớp tài liệu.

---

### TC-05 — Mode 3: Excel Mẫu + styleOnly (Tạo mới)

**Mục tiêu**: Excel Mẫu → AI học phong cách → tạo câu MỚI.  
**File cần**: `mau_excel_mcq.xlsx`

**Bước:**

1. Tap tab `"Tài liệu"` (key: `tab_ragGeneration`)
2. Thêm `mau_excel_mcq.xlsx`
3. Log: `[LocalTempFile] Template parsed: 5 câu hỏi`
4. Role badge tự động = `📋 Mẫu` (vì có parsedQuestions)
5. Tick file → sub-mode strip hiện ra
6. Xác nhận chip `"Tạo mới"` (key: `chip_style_only`) đang selected
7. Tap `"Sinh từ tài liệu"` (key: `btn_generate`)
8. Đọc log

**Log cần thấy:**
```
[Mode3] hasExcelTemplate=true, hasDocxTemplate=false → useAsStyleTemplate=true
🧠 [Prompt] Template mode → branch=styleOnly qty=N type=...
🧠 [Prompt] Built styleOnly prompt: N chars. Preview:...
📄 [Context] mau_excel_mcq.xlsx: parsedQ=5 → schema [role=template]
📄 [Context] Total context: N chars (1 template, 0 KT parts)
📝 [Result] ══ Generated N câu ══
  Q1[multipleChoice|diff=N] ...
       → ans=A | opts: ...
```

**Snackbar**: `"Phát hiện tài liệu bài mẫu — AI sẽ tạo câu cùng dạng, nội dung mới."`

**Kiểm tra câu**: Câu hỏi phải là MCQ (giống mẫu), nhưng nội dung khác hoàn toàn mẫu.  
**Fail nếu**: `useAsStyleTemplate=false` hoặc câu hỏi trùng với mẫu.

---

### TC-06 — Mode 3: Excel Mẫu + sameForm (Cùng dạng)

**Mục tiêu**: Excel Mẫu → AI tạo câu CÙNG CẤU TRÚC (đổi số/tình huống).  
**File cần**: `mau_excel_mcq.xlsx` (phải có MCQ với số liệu để không bị downgrade)

**Bước:**

1. Làm tương tự TC-05 bước 1-5
2. Tap chip `"Cùng dạng"` (key: `chip_same_form`) — phải enabled
3. Tap `"Sinh từ tài liệu"`
4. Đọc log

**Log cần thấy:**
```
[Mode3] T2-3 numeric ratio=0.XX (N/M) → numericDowngrade=false
[Mode3] hasExcelTemplate=true → useAsStyleTemplate=true
🧠 [Prompt] Template mode → branch=sameForm qty=N
```

**Kiểm tra câu**: Cấu trúc câu tương tự mẫu (cùng loại MCQ, số lựa chọn), NỘI DUNG KHÁC.  
**Kiểm tra badge**: Nếu câu quá giống mẫu, thấy `⚠sim=XX% (tpl#N)` trong log và badge vàng trên UI.

**Fail nếu**: `numericDowngrade=true` khi không mong muốn, hoặc `branch=styleOnly` thay vì `sameForm`.

---

### TC-07 — Mode 3: Mixed — Excel Mẫu + Word Kiến thức

**Mục tiêu**: Kết hợp 1 file mẫu (học phong cách) + 1 file kiến thức (nguồn nội dung).  
**File cần**: `mau_excel_mcq.xlsx` + `kienthuc.docx`

**Bước:**

1. Tab `"Tài liệu"`, thêm cả 2 file
2. `mau_excel_mcq.xlsx` → role `📋 Mẫu` (auto)
3. `kienthuc.docx` → role `📚 KT` (auto, vì không có parsedQ)
4. Tick cả 2 file
5. Chip `"Tạo mới"` (styleOnly)
6. Tap generate
7. Đọc log

**Log cần thấy:**
```
[Mode3] hasExcelTemplate=true, hasDocxTemplate=false → useAsStyleTemplate=true
📄 [Context] mau_excel_mcq.xlsx: parsedQ=5 → schema [role=template]
📄 [Context] kienthuc.docx: → raw text (N chars) [role=knowledgeSource]
📄 [Context] Total context: N chars (1 template, 1 KT parts)
🧠 [Prompt] Template mode → branch=styleOnly
```

**Pass nếu**: `Total context` bao gồm cả 2 phần, câu hỏi có nội dung từ `kienthuc.docx`.

---

### TC-08 — GAP-2: Auto-downgrade Mẫu cũ khi set Mẫu mới

**Mục tiêu**: Khi đặt file mới làm Mẫu, file Mẫu cũ tự chuyển sang Kiến thức.  
**File cần**: `mau_excel_mcq.xlsx` + `mau_word_mcq.docx`

**Bước:**

1. Tab `"Tài liệu"`, thêm cả 2 file
2. Ban đầu: `mau_excel_mcq.xlsx` = `📋 Mẫu` (auto), `mau_word_mcq.docx` = `📚 KT`
3. Screenshot để xác nhận trạng thái ban đầu:
   ```json
   mcp__marionette__take_screenshots({})
   ```
4. Tap role badge của `mau_word_mcq.docx` để đổi sang `📋 Mẫu`
   (key: `role_toggle_<id_of_word_file>`)
5. Screenshot lại

**Expected:**
- Snackbar: `'"mau_excel_mcq.xlsx" đã chuyển sang 📚 Kiến thức'`
- `mau_excel_mcq.xlsx` badge = `📚 KT`
- `mau_word_mcq.docx` badge = `📋 Mẫu`

**Pass nếu**: Chỉ 1 file là Mẫu tại mọi thời điểm.

---

### TC-09a — GAP-6: Chip "Cùng dạng" enabled khi đủ 2 MCQ

**Mục tiêu**: File có ≥2 câu TN → chip "Cùng dạng" enabled.  
**File cần**: `mau_excel_2mcq.xlsx`

**Bước:**

1. Tab `"Tài liệu"`, thêm `mau_excel_2mcq.xlsx`
2. Tick file (role = `📋 Mẫu` auto)
3. Screenshot sub-mode strip

**Expected**: Chip `"Cùng dạng"` (key: `chip_same_form`) KHÔNG bị xám, bấm được.

---

### TC-09b — GAP-6: Chip "Cùng dạng" disabled khi chỉ 1 MCQ

**Mục tiêu**: File có <2 câu TN → chip "Cùng dạng" disabled.  
**File cần**: `mau_excel_1mcq.xlsx`

**Bước:**

1. Thêm `mau_excel_1mcq.xlsx`, tick
2. Screenshot sub-mode strip

**Expected**: Chip `"Cùng dạng"` bị xám, tooltip `"Cần ít nhất 2 câu Trắc nghiệm"`.  
Log khi tick: `allMcq=false` (trong `[Context]`).

---

### TC-10 — sameForm auto-downgrade khi không có số liệu

**Mục tiêu**: MCQ không có số/đơn vị → sameForm tự downgrade về styleOnly.  
**File cần**: `mau_excel_nonum.xlsx`

**Bước:**

1. Tab `"Tài liệu"`, thêm `mau_excel_nonum.xlsx`
2. Tick, role = Mẫu, chọn chip `"Cùng dạng"`
3. Tap generate
4. Đọc log

**Log cần thấy:**
```
[Mode3] T2-3 numeric ratio=0.00 (0/N) → numericDowngrade=true
[Mode3] Auto-downgrade sameForm → styleOnly: allMcq=true numericDowngrade=true
```

**Snackbar**: `"Template ít câu có số liệu — chuyển sang chế độ 'Tạo mới'..."`

**Pass nếu**: `branch=styleOnly` trong `[Prompt]` log dù user đã chọn Cùng dạng.

---

### TC-11 — Similarity badge hiển thị đúng vị trí

**Mục tiêu**: Badge `⚠ Tương tự mẫu #N (XX%)` hiển thị dưới card, không che content.

**Bước:**

1. Chạy TC-06 (sameForm) để có câu tương tự
2. Đọc log tìm `⚠sim=` trong kết quả:
   ```
   Q3[multipleChoice|diff=2] Tính vận tốc của vật…
        → ans=B | opts: ...
        ⚠sim=72% (tpl#1)
   ```
3. Screenshot màn hình
4. Scroll để thấy câu có badge

**Pass nếu**: Badge xuất hiện BÊN DƯỚI card question (không chồng lên các lựa chọn).  
**Fail nếu**: Badge chồng lên lựa chọn D hoặc bị che khuất.

---

### TC-12 — Regenerate single question

**Mục tiêu**: Tạo lại 1 câu không ảnh hưởng câu khác.

**Bước:**

1. Sau khi có kết quả từ TC-05 hoặc TC-06
2. Tìm icon regenerate trên câu Q2 (biểu tượng refresh)
3. Tap icon đó
4. Đọc log

**Log cần thấy (regenerate):**
```
[Generate] processingMode=ragGeneration (hoặc mode hiện tại)
📝 [Result] ══ Generated 1 câu ══
  Q1[...] nội dung câu mới
📝 [Result] ══ End ══
```

**Pass nếu**: Chỉ câu Q2 thay đổi, Q1/Q3... không đổi.

---

### TC-13 — Lưu vào Question Bank

**Mục tiêu**: Câu hỏi được save vào Supabase thành công.

**Bước:**

1. Sau khi có kết quả từ bất kỳ TC nào
2. Tap `"Lưu vào Bank"`
3. Đọc log

**Log cần thấy:**
```
✅ [AI Service] ... (save flow)
```

**Snackbar**: thông báo thành công.

---

## 5. Debugging khi test thất bại

### 5.1 — Không có câu hỏi nào được tạo

Đọc log tìm:
- `🟡 [Generate] EXIT:` → form validation thất bại → xem lý do
- `❌ [AI Service]` → lỗi API → xem error message
- `[Mode3] EMPTY reason:` → file không có nội dung

### 5.2 — File không parse được

```
[LocalTempFile] Extraction failed for X: error
```

Kiểm tra:
- File đúng format chưa? (xlsx/docx/pdf)
- File có bị corrupt không?
- `parsedQty=0` + `extractedChars=0` → file rỗng hoặc format sai

### 5.3 — Chip "Cùng dạng" bị disabled khi không mong muốn

Log tìm `allMcq=false` → xem từng file trong log:
```
[Mode3] file=X.xlsx | parsedQty=N | selected=true
```
Nếu `parsedQty=0` cho file Excel → parse thất bại → check file format.

### 5.4 — sameForm bị auto-downgrade không mong muốn

Log tìm:
```
[Mode3] T2-3 numeric ratio=0.XX → numericDowngrade=true
```
Nếu ratio < 0.5 → file Excel template không có đủ câu có số liệu.  
→ Dùng file mẫu có số liệu (đơn vị vật lý, hóa học, toán...).

### 5.5 — Context gửi cho AI quá dài / bị cắt

```
[Mode3] smartTruncate: total=50000, used=30000, wasTruncated=true
```
→ File quá dài → bình thường, AI vẫn dùng phần đã cắt.

### 5.6 — Badge tương tự hiện sai vị trí

Đọc log tìm `⚠sim=`:
```
Q3[...] ... ⚠sim=85% (tpl#2)
```
Screenshot → kiểm tra badge dưới card hay chồng vào lựa chọn.

---

## 6. Tham khảo ValueKey

| Widget | Key | Dùng cho |
|---|---|---|
| Tab "Nhập Prompt" | `tab_promptOnly` | Tap để chọn Mode 1 |
| Tab "Trích xuất" | `tab_extraction` | Tap để chọn Mode 2 |
| Tab "Tài liệu" | `tab_ragGeneration` | Tap để chọn Mode 3 |
| Button generate chính | `btn_generate` | Tap để tạo câu hỏi |
| Button "Tạo lại" | `btn_regenerate_all` | Tap để tạo lại toàn bộ |
| Button thêm file | `btn_add_file` | Tap để mở file picker |
| File card (tap = tick) | `file_card_<id>` | Tick/untick file |
| Role badge toggle | `role_toggle_<id>` | Đổi 📋/📚 role |
| Chip "Tạo mới" | `chip_style_only` | Chọn styleOnly |
| Chip "Cùng dạng" | `chip_same_form` | Chọn sameForm |

> **Lưu ý**: `<id>` là UUID ngẫu nhiên sinh khi upload file.  
> Dùng `mcp__marionette__get_interactive_elements({})` để tìm `<id>` cụ thể.

---

## 7. Tham khảo cấu trúc câu hỏi trong log

```
Q1[multipleChoice|diff=3] Chiến dịch Điện Biên Phủ kết thúc thắng lợi vào ngày nào?
     → ans=A | opts: A.7/5/1954 | B.2/9/1945 | C.30/4/1975 | D.21/7/1954
     → tags: lịch sử,điện biên phủ,1954
```

| Field | Ý nghĩa |
|---|---|
| `[multipleChoice]` | Loại câu: `multipleChoice`, `trueFalse`, `shortAnswer`, `math` |
| `diff=3` | Độ khó 1-5 |
| Dòng nội dung | Tối đa 90 ký tự đầu câu hỏi |
| `ans=A` | Đáp án đúng |
| `opts: A.xxx \| B.xxx` | Nội dung các lựa chọn |
| `tags: xxx,yyy` | Tags phân loại |
| `⚠sim=72% (tpl#1)` | Cảnh báo tương tự: 72% giống câu mẫu số 1 |

---

## 8. Thứ tự chạy test khuyến nghị

```
TC-01 → TC-02 → TC-04 → TC-05 → TC-06 → TC-07 → TC-08 → TC-09a → TC-09b → TC-10 → TC-11 → TC-12 → TC-03 → TC-13
```

Chạy TC-01 trước để verify API key hoạt động. Nếu TC-01 lỗi, các TC khác cũng sẽ lỗi (trừ TC-02 không dùng AI).

---

## 9. Checklist hoàn thành

- [ ] TC-01 PASS: Mode 1 tạo N câu, có đủ nội dung
- [ ] TC-02 PASS: Mode 2 Excel — 5 câu load không gọi AI
- [ ] TC-03 PASS: Mode 2 Word — AI generate từ text
- [ ] TC-04 PASS: Mode 3 KT only — `useAsStyleTemplate=false`
- [ ] TC-05 PASS: Mode 3 styleOnly — `branch=styleOnly`, câu mới
- [ ] TC-06 PASS: Mode 3 sameForm — `branch=sameForm`, có/không similarity badge
- [ ] TC-07 PASS: Mode 3 Mixed — context có cả 2 phần
- [ ] TC-08 PASS: GAP-2 — auto-downgrade Mẫu cũ
- [ ] TC-09a PASS: GAP-6 — chip enabled với 2 MCQ
- [ ] TC-09b PASS: GAP-6 — chip disabled với 1 MCQ
- [ ] TC-10 PASS: auto-downgrade khi không có số liệu
- [ ] TC-11 PASS: badge dưới card, không che content
- [ ] TC-12 PASS: regenerate single — chỉ 1 câu thay đổi
- [ ] TC-13 PASS: save to bank thành công

---

# ═══════════════════════════════════════════════════════════════
# SESSION 2026-05-09 — Mode 3 Bug Fix + Phase A + G1 + A5
# ═══════════════════════════════════════════════════════════════

> Section bổ sung — bao gồm tất cả thay đổi của phiên 4-agent team (4 commit:
> `ba521a8`, `b41cdcb`, `da9f8ce`, `c421fdb`). Static verify đã PASS toàn bộ;
> **functional test trên thiết bị CHƯA THỰC HIỆN** — đây là việc của phiên sau.

## Cách dùng section này
1. Đi tuần tự từng test theo thứ tự (S1 → S2 → S3 → S4 → S5 → S6)
2. Đánh dấu trạng thái:
   - `[ ]` chưa test
   - `[x]` PASS
   - `[F]` FAIL — ghi `commit_hash: lý do` bên cạnh
   - `[B]` Blocked — ghi nguyên nhân
   - `[N]` N/A
3. Test fail → tạo todo trong session đó để fix
4. Khi commit mới ảnh hưởng đến area nào → re-run test area đó

---

## Setup chuẩn bị test (BẮT BUỘC làm trước)

### Pre-requisites
- Flutter SDK + Android device/emulator có Google Play Services (cho Gemini API)
- Account giáo viên test, đã cấu hình API key Gemini trong Settings → API Keys
- File Excel mẫu (theo template `WordTemplateGenerator.generate(WordDocType.questions)`)
- 4 file Word `.docx` chuẩn bị trước (xem dưới)

### Tạo 4 file Word test mẫu

**Word A — ASCII math thuần (1 câu mẫu)**
1. Mở Word
2. Gõ thẳng: `Câu 1: Tính 15 + 27 = ?`
3. Save as `test_A_ascii.docx`

**Word B — LaTeX inline plain text (1 câu mẫu)**
1. Mở Word
2. Gõ thẳng (KHÔNG dùng equation editor): `Câu 1: Tính $\frac{1}{2} + \frac{1}{4} = ?$`
3. Save as `test_B_latex.docx`

**Word C — Equation Editor (Insert → Equation) (1 câu mẫu)**
1. Mở Word
2. Gõ: `Câu 1: Tính `
3. Insert → Equation (hoặc Alt+=) → gõ phân số `1/2 + 1/4 = ?`
4. Save as `test_C_omml.docx`

**Word D — Hỗn hợp (3 câu mẫu MCQ)**
1. Tạo 3 câu MCQ chuẩn:
   ```
   Câu 1: Phương trình 3x − 9 = 0 có nghiệm là?
   A. x = −9
   B. x = 9
   C. x = 3
   D. x = −3
   Đáp án: C
   ```
   (Lặp 3 câu khác nhau)
2. Save as `test_D_mcq.docx`

---

## S1. Mode 3 Template Detection + LaTeX Render (commit `ba521a8`)

### S1.1 Force template toggle
- **Vị trí**: Mode 3 hint card → SwitchListTile "Coi tài liệu là MẪU"
- [ ] **S1.1.1** Toggle xuất hiện đúng vị trí, đúng style DesignTokens
- [ ] **S1.1.2** Toggle OFF mặc định khi mở screen lần đầu
- [ ] **S1.1.3** Bật toggle → state persist trong screen session

### S1.2 Detection auto path C (math expression)
- [ ] **S1.2.1** Upload `test_A_ascii.docx`, click Generate (Mode 3) → log có `[Mode3] hasDocxTemplate=true`
- [ ] **S1.2.2** Banner trạng thái hiện "✓ Đã phát hiện 1 câu mẫu — chế độ Cùng Dạng sẵn sàng"

### S1.3 Force toggle override
- [ ] **S1.3.1** Upload tài liệu KHÔNG có math (vd file văn xuôi) → bật Force → Generate → log `[Mode3] Force template mode ON — bypass detection`
- [ ] **S1.3.2** Banner hiện "⚡ Đã ép coi là tài liệu mẫu" với màu warning

### S1.4 Chip sub-mode UX (file `context_sources_section.dart`)
- [ ] **S1.4.1** Mode 3 không có file → chip "Tạo mới / Cùng dạng" hiện disabled với opacity 0.55
- [ ] **S1.4.2** Long-press chip disabled → tooltip "Cần tài liệu mẫu… hoặc bật 'Coi tài liệu là MẪU'"
- [ ] **S1.4.3** Khi `_useAsStyleTemplate=true` HOẶC `_forceTemplateMode=true` → chip enabled, click chuyển được giữa styleOnly/sameForm
- [ ] **S1.4.4** Chip không xuất hiện 2 chỗ cùng lúc (đã guard `!hasTemplateSelected`)

### S1.5 LaTeX render trong preview card (MathText widget)
- **Pre**: gen 5 câu math có công thức (vd dùng Word B)
- [ ] **S1.5.1** AI gen ra `$\frac{1}{2}$` → preview card render thành phân số đẹp (KHÔNG hiển thị literal)
- [ ] **S1.5.2** Option text có `$x^2$` → render thành x mũ 2
- [ ] **S1.5.3** Câu essay có `$\sqrt{x+1}$` trong expected_answer → render đẹp
- [ ] **S1.5.4** Plain text không có `$` → render bình thường, không artifacts
- [ ] **S1.5.5** LaTeX malformed (vd `$\fra{1}{2}$`) → fallback hiện literal màu đỏ, không crash

### S1.6 Edit dialog Tab + Toolbar
- **Pre**: gen xong, click icon edit (cây bút) trên 1 câu
- [ ] **S1.6.1** Dialog mở có 2 tab: "Sửa" và "Xem trước"
- [ ] **S1.6.2** Tab "Sửa" hiện toolbar 11 nút: `f(x)`, `√`, `x²`, `x_n`, `½`, `Σ`, `∫`, `≤`, `≥`, `±`, `[___N]` (nút cuối chỉ với fill_blank)
- [ ] **S1.6.3** Click `f(x)` khi không có selection → insert `$  $` cursor giữa
- [ ] **S1.6.4** Highlight selection rồi click `f(x)` → wrap thành `$selected$`
- [ ] **S1.6.5** Click `½` → insert `\frac{}{}` cursor ở `{}` đầu
- [ ] **S1.6.6** Click `√` → insert `\sqrt{}` cursor giữa
- [ ] **S1.6.7** Switch sang tab "Xem trước" → render LaTeX live
- [ ] **S1.6.8** Sửa text trong Tab "Sửa" → tab "Xem trước" cập nhật reactive (qua `Listenable.merge`)
- [ ] **S1.6.9** Mỗi choice MCQ/math có nút "fx" mini bên phải → wrap selection trong `$...$`
- [ ] **S1.6.10** Save → câu hỏi trong card cập nhật đúng
- [ ] **S1.6.11** Câu fill_blank: nút `[___N]` auto-increment N theo số blank hiện có

### S1.7 templateCount cascade (backend)
- [ ] **S1.7.1** Upload 1 câu mẫu, gen 10 câu → log AI prompt có "Bạn có 1 câu mẫu nhưng cần tạo 10 câu — hãy biến tấu MỖI mẫu thành nhiều biến thể KHÁC NHAU…"
- [ ] **S1.7.2** Upload 5 câu mẫu, gen 10 câu → log KHÔNG có instruction trên (templateCount=5, không thỏa `< quantity/2`)

---

## S2. Phase A — VN Persona + Multi-step + Gemini 2.0 + Cache (commit `b41cdcb`)

### S2.1 VN sư phạm persona
- **Pre**: gen câu hỏi bất kỳ (Mode 1, 2, 3)
- [ ] **S2.1.1** Câu hỏi gen ra dùng tiếng Việt sư phạm rõ ràng (không Hán Việt khó hiểu)
- [ ] **S2.1.2** Distractor (đáp án sai) hợp lý — kiểu lỗi học sinh thường mắc, không vô nghĩa
- [ ] **S2.1.3** Nội dung gắn với chương trình SGK VN (lịch sử, địa lý, văn học VN nếu liên quan)

### S2.2 Multi-step math reasoning (Mode 3 sameForm)
- **Pre**: upload file Word có câu math mẫu, bật sameForm
- [ ] **S2.2.1** Câu gen ra có đáp án đúng (verify thủ công 5/5 câu math)
- [ ] **S2.2.2** Distractor là lỗi sai cụ thể (cộng thiếu, quên đơn vị, đảo dấu) — không bịa số ngẫu nhiên
- [ ] **S2.2.3** Phù hợp cấp học (lớp 9 không tích phân, lớp 12 không quá đơn giản)

### S2.3 Default model Gemini 2.0 Flash
- [ ] **S2.3.1** Vào Settings → API Keys → confirm default model dropdown hiện `gemini-2.0-flash`
- [ ] **S2.3.2** User chưa cấu hình → AI gọi dùng `gemini-2.0-flash` (xem log network/console)
- [ ] **S2.3.3** Long context (>20K char document) không bị truncate quá sớm

### S2.4 Document parse cache
- **Pre**: kBuild debug, mở DevTools console
- [ ] **S2.4.1** Upload file Word lần đầu → parse mất ~3-5s
- [ ] **S2.4.2** Remove file rồi upload lại CÙNG file → parse tức thì (<100ms — cache hit)
- [ ] **S2.4.3** Upload file Word khác → parse lại bình thường (cache miss)
- [ ] **S2.4.4** Upload >20 file khác nhau → cache evict file cũ nhất (LRU 20 entries)

---

## S3. G1 — OMML → LaTeX Word Equation Parser (commit `da9f8ce`)

### S3.1 Unit test (đã pass — re-verify nếu có sửa)
- [x] **S3.1.1** 8/8 unit test pass — `flutter test test/unit/core/omml_to_latex_test.dart`

### S3.2 Functional với file Word C (Equation Editor)
- **Pre**: file `test_C_omml.docx` đã tạo với equation editor `1/2 + 1/4 = ?`
- [ ] **S3.2.1** Upload file C, Mode 3, Generate → log AI prompt có nội dung `$\frac{1}{2} + \frac{1}{4} = ?$` (LaTeX, không phải `1 2 1 4`)
- [ ] **S3.2.2** Câu gen ra cùng dạng phân số (10 câu khác phân số khác nhau)
- [ ] **S3.2.3** Render preview card hiện phân số đẹp qua MathText

### S3.3 Mix functional
- **Pre**: file Word có cả equation editor + LaTeX inline + ASCII
- [ ] **S3.3.1** Mỗi loại được convert đúng, không nhiễu lẫn nhau
- [ ] **S3.3.2** Plain text Việt giữ nguyên, không bị strip ký tự đặc biệt

### S3.4 Edge cases
- [ ] **S3.4.1** Word có equation rỗng `<m:oMath></m:oMath>` → không output `$$` rỗng
- [ ] **S3.4.2** Word có matrix (`m:m`) → fallback strip về text plain (không crash)
- [ ] **S3.4.3** Word có equation lồng sâu (frac trong frac) → convert đúng `\frac{\frac{1}{2}}{3}`

---

## S4. A5 — Self-Critique Toggle (commit `c421fdb`)

### S4.1 Toggle UI
- **Pre**: mở screen tạo câu hỏi → AI Settings drawer
- [ ] **S4.1.1** Section "Nâng cao" hiện cuối drawer
- [ ] **S4.1.2** SwitchListTile "Chế độ chính xác cao" với icon `verified_outlined`
- [ ] **S4.1.3** OFF mặc định, persist khi chuyển screen rồi quay lại
- [ ] **S4.1.4** Subtitle giải thích "AI tự kiểm tra mỗi câu — chậm hơn ~10s, tốn 2x token AI"

### S4.2 Toggle OFF (default — zero impact)
- [ ] **S4.2.1** Gen 5 câu với toggle OFF → KHÔNG có AI call thứ 2 (xem log/network)
- [ ] **S4.2.2** Latency tương đương gen trước khi có A5
- [ ] **S4.2.3** Card preview KHÔNG có badge cảnh báo cam (mọi câu)

### S4.3 Toggle ON — happy path
- [ ] **S4.3.1** Bật toggle, gen 5 câu math → có thêm 1 AI call (log `[Critique] N=5, fails=X`)
- [ ] **S4.3.2** Latency tăng ~5-10s sau khi gen xong (do critique pass)
- [ ] **S4.3.3** Câu pass: KHÔNG có badge
- [ ] **S4.3.4** Câu fail: badge cam dưới card với icon warning + lý do cụ thể

### S4.4 Toggle ON — graceful fallback
- [ ] **S4.4.1** AI lần 2 trả về JSON malformed → toàn bộ câu mark pass=true (không block)
- [ ] **S4.4.2** AI lần 2 trả về thiếu entry (5 câu nhưng chỉ 3 review) → entry thiếu mark pass=true
- [ ] **S4.4.3** AI lần 2 timeout/error → flow vẫn complete, không có badge

### S4.5 Critique quality
- [ ] **S4.5.1** Cố tạo prompt yêu cầu câu sai (vd "tính 2+2 nhưng đáp án 5") → critique phát hiện và mark fail
- [ ] **S4.5.2** Câu phức tạp đúng → critique mark pass

---

## S5. G3 — Export câu hỏi → Word (TBD — commit chưa có)

> Sẽ điền checklist sau khi G3 commit. Stub để session sau biết section này tồn tại.

### S5.1 LaTeX → OMML conversion
- [ ] S5.1.x …

### S5.2 Generate Word file từ list questions
- [ ] S5.2.x …

### S5.3 UI nút "Xuất ra Word"
- [ ] S5.3.x …

### S5.4 Mở Word file output
- [ ] S5.4.1 Word render được tất cả câu, math hiện đúng dạng phân số / mũ / căn (không phải literal LaTeX)
- [ ] S5.4.2 Format paragraph đẹp, có separator giữa các câu
- [ ] S5.4.3 Đáp án (cho MCQ) hiện rõ ràng

---

## S6. Regression sanity (chạy sau mỗi commit lớn)

- [ ] **R1** Login flow vẫn work (admin/teacher/student)
- [ ] **R2** Tạo class + add student vẫn work
- [ ] **R3** Distribute assignment + student submit vẫn work
- [ ] **R4** Grade submission (teacher hub) vẫn work
- [ ] **R5** No new flutter analyze warnings
- [ ] **R6** Build APK debug success <60s
- [ ] **R7** Cold start app <3s

---

## Issue tracker — FAIL/Blocked items

> Khi 1 test fail → ghi vào đây, link với commit hash.

| Date | Test ID | Commit | Description | Status |
|------|---------|--------|-------------|--------|
| | | | | |

---

## Ghi chú quan trọng cho phiên sau

1. **G3 chưa làm** — cần dispatch agent team Export câu hỏi → Word (LaTeX → OMML reverse + integrate vào WordTemplateGenerator + nút UI)
2. **B RAG pgvector** — defer, làm khi DB > 100 câu approved
3. **Mode 3 fix bundle** include nhiều thứ pre-existing không liên quan AI (supabase migrations 008-018, redo eligibility, assignment bank widgets, hub stats) — cần regression test khi vào các flow khác
4. **571 MB `.claude/worktrees/`** đã ignore — không xóa local vì có agent state có thể recovery, nhưng KHÔNG commit
5. **Memory bank đã update** trong commit `ba521a8` — đọc `memory-bank/activeContext.md` đầu phiên sau

## Log lịch sử test

| Date | Tester | Phase | Result | Notes |
|------|--------|-------|--------|-------|
| 2026-05-09 | Agent QA (static) | S1+S2+S3+S4 (commits ba521a8, b41cdcb, da9f8ce, c421fdb) | static PASS toàn bộ | Build apk + flutter analyze pass; CHƯA test trên thiết bị |

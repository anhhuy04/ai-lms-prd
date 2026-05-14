# 📋 Manual Test TODO — Phiên 2026-05-15

> **Ai thực hiện**: User (Anh Huy) — Claude/marionette không làm được do giới hạn UI dialog & file native.
> **Ưu tiên**: P1 = quan trọng nhất, P2 = nice-to-have.
> **Cập nhật**: sau khi xong test nào tick `[x]` trong file này, sau đó update kết quả tương ứng vào `tmp/AGENT_TEST_GUIDE.md`.

---

## 🔥 P1 — Test bắt buộc (5-15 phút)

### ① TC-13 — Lưu vào Question Bank
**Mục tiêu**: verify save 10 câu AI gen vào Supabase qua dialog confirm.

1. Mở app web `localhost:8080`, đăng nhập `ha@gmail.com / 12345678`
2. Vào màn **Tạo câu hỏi bằng AI** (Thêm câu hỏi từ assignment screen)
3. Tab **Tài liệu**, tick file `mau_excel_mcq.xlsx`, chip "Tạo mới"
4. Click **Sinh từ tài liệu** → đợi ~10s có 10 câu render
5. Click **Lưu vào Bank** (góc dưới trái)
6. Dialog confirm xuất hiện — click **Xác nhận**
7. Expected: snackbar "Đã lưu N câu vào ngân hàng câu hỏi"
8. **Verify**: vào màn `Ngân hàng câu hỏi` → thấy 10 câu vừa save
9. Tick `[ ] TC-13 PASS` vào `tmp/AGENT_TEST_GUIDE.md` line 589

---

### ② TC-12 — Regenerate 1 câu
**Mục tiêu**: verify "Tạo lại 1 câu" không ảnh hưởng câu khác.

1. Sau TC-13 (đã có 10 câu trên màn)
2. Tìm icon **refresh xanh** (🔄) ở góc phải-trên của Câu 5 bất kỳ
3. Click icon đó → đợi ~5s
4. Expected:
   - Chỉ Câu 5 thay đổi nội dung (text khác)
   - Câu 1-4, 6-10 GIỮ NGUYÊN
5. **Verify log** trong console flutter run:
   - `[Generate] processingMode=ragGeneration` (không phải gen toàn bộ)
   - `📝 [Result] ══ Generated 1 câu ══`
6. Tick `[ ] TC-12 PASS` vào AGENT_TEST_GUIDE.md line 588

---

### ③ S5.4 — Verify file Word export render đẹp
**Mục tiêu**: confirm LaTeX `$x^2$`, `\frac{1}{2}` render math thật trong Word, không phải literal.

1. Sau TC-12/13 (đã có 10 câu)
2. Click icon **download xanh** (⬇️) bên trái action bar → `btn_export_word`
3. File `de_ai_<timestamp>.docx` tải về Downloads
4. **Mở bằng Microsoft Word** (KHÔNG dùng Google Docs / LibreOffice — render OMML khác)
5. Kiểm tra:
   - [ ] **S5.4.1** Không có lỗi corrupt khi mở
   - [ ] **S5.4.2** Title "ĐỀ KIỂM TRA — Câu hỏi từ tài liệu" bold center
   - [ ] **S5.4.3** Phân số `\frac{1}{2}` hiện THẬT (tử trên, mẫu dưới, gạch ngang) — KHÔNG phải literal text `$\frac{1}{2}$`
   - [ ] **S5.4.4** Mũ `x^2` render đẹp (số 2 nhỏ phía trên-phải)
   - [ ] **S5.4.5** Căn `\sqrt{x}` có dấu căn bao quanh x
   - [ ] **S5.4.6** Dấu tiếng Việt (ê ô ă đ) giữ nguyên
   - [ ] **S5.4.7** "Đáp án: X" italic dưới mỗi câu MCQ
   - [ ] **S5.4.8** Mỗi câu cách 1 paragraph trống
6. Tick các sub-test trong AGENT_TEST_GUIDE.md line 805-814

---

## 🟡 P2 — Test phụ (cần tạo file Word riêng, 15-30 phút)

### ④ S3.2-3.4 — OMML Equation Editor parser (Word C)

**Tại sao**: Verify parser đọc đúng phương trình tạo bằng Word Equation Editor (Insert → Equation), không phải LaTeX text.

#### Bước 1 — Tạo file `test_C_omml.docx`
1. Mở **Microsoft Word**
2. Gõ: `Câu 1: Tính `
3. **Insert → Equation** (hoặc nhấn `Alt + =`)
4. Trong equation editor: gõ `1/2 + 1/4 = ?`
5. Word tự render phân số thật (KHÔNG phải `1/2` text)
6. Save as `test_C_omml.docx` vào `tmp/`

#### Bước 2 — Upload + verify
1. App → tab **Tài liệu** → Thêm tài liệu → chọn `test_C_omml.docx`
2. Tick file, click **Sinh từ tài liệu**
3. **Verify log** trong console:
   - [ ] **S3.2.1** Log `[LocalTempFile] Text extracted: N chars` với N>0
   - [ ] **S3.2.2** Trong prompt AI có `$\frac{1}{2}+\frac{1}{4}$` (LaTeX, KHÔNG phải `1 2 1 4`)
4. 10 câu gen ra → mỗi câu có phân số render đẹp (qua MathText widget)

#### Bước 3 — Mix functional (S3.3)
1. Tạo `test_D_mcq.docx` với 3 câu MCQ format chuẩn (`Câu N: ...`, `A. ...`, `Đáp án: C`)
2. Upload + gen → verify parse 3 câu mẫu OK

---

### ⑤ S4.3.2-4 — Test live Toggle Self-Critique ON (tốn 2x token!)

**Cảnh báo**: Test này tốn gấp đôi token AI vì mỗi câu được AI kiểm tra lại.

1. Cài đặt AI (icon 3 chấm góc phải-trên) → cuộn xuống mục **Nâng cao**
2. Bật toggle **Chế độ chính xác cao** (ON)
3. Quay lại màn AI generate, gen 5 câu math (Mode 3 + mau_excel_mcq.xlsx)
4. **Verify**:
   - [ ] **S4.3.1** Console log `[Critique] N=5, fails=$X`
   - [ ] **S4.3.2** Latency tăng ~5-10s sau khi gen (do critique chạy)
   - [ ] **S4.3.3** Câu pass: KHÔNG badge cam
   - [ ] **S4.3.4** Câu fail (nếu có): badge cam dưới card với icon warning + reason
5. Tắt toggle lại để các test sau không bị tốn token

---

## 🚀 P3 — Push GitHub (10 phút)

### Vấn đề
- Commit cũ `ba521a8` có chứa **Supabase PAT** → GitHub Push Protection chặn
- Cần rotate PAT cũ + bypass hoặc remove

### Cách giải quyết (chọn 1)

**Cách A — Rotate PAT (an toàn nhất)**
1. Vào Supabase Dashboard → Account → Access Tokens
2. Revoke token cũ trong file `.mcp.json` (`sbp_...`)
3. Tạo PAT mới
4. Update `.mcp.json` (local, không commit)
5. Push: GitHub sẽ chấp nhận vì token cũ đã invalid

**Cách B — Bypass Protection (nhanh, không an toàn)**
1. Vào URL GitHub push reject báo (ví dụ: `https://github.com/.../security/secret-scanning/unblock-secret/...`)
2. Chọn "I'll fix this later" → confirm bypass
3. `git push origin main`
4. **Rotate PAT ngay sau khi push** (rất quan trọng!)

### Push lệnh
```bash
cd D:\code\Flutter_Android\Flutter_Android\AI_LMS_PRD
git push origin main
```

10 commit sẽ lên: `63a02df → 3c5dbaf → 4772208 → d850610 → c7cf614 → ab032a2 → 1cb5996 → 8256b67 → 21428de → 77871da`

---

## 📊 Checklist tổng

- [ ] **P1.1** TC-13 Save Bank verified
- [ ] **P1.2** TC-12 Regenerate single verified
- [ ] **P1.3** S5.4 Word output mở Microsoft Word verified (8 sub-tests)
- [ ] **P2.1** S3.2-3.4 OMML Word C file created + tested
- [ ] **P2.2** S4.3.2-4 Self-critique toggle ON live tested
- [ ] **P3** Push GitHub xong (rotate Supabase PAT trước)

Sau mỗi mục xong → tick + update kết quả vào `AGENT_TEST_GUIDE.md`.

---

## 🆘 Nếu gặp lỗi

| Triệu chứng | Nguyên nhân | Cách fix |
|---|---|---|
| Dialog không hiện khi Lưu Bank | Network error | Check log console + retry |
| Icon refresh câu không click được | Đang gen | Đợi gen xong rồi thử |
| File Word mở bị corrupt | OMML invalid | Báo lại, đã fix F-009 nhưng có thể edge case |
| Phân số trong Word literal `$\frac{1}{2}$` | LaTeX→OMML conversion fail | Báo lại để check `latex_to_omml.dart` |
| GitHub push reject | Secret trong commit cũ | Cách A hoặc B ở mục P3 |

---

**END OF MANUAL TEST TODO** — 6 mục, ước tính tổng 1-1.5 giờ. Báo cáo lại khi xong từng mục.

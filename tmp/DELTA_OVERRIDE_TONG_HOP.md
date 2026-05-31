# 📋 DELTA OVERRIDE — TỔNG HỢP TOÀN BỘ (đọc file này là đủ)

> **Ngày:** 2026-05-30
> **Nguồn dữ liệu:** Source code thật + Supabase MCP (project `vazhgunhcjdwlkbslroc`).
> **Đã chốt:** Phạm vi = *Chặn rác mới + Backfill an toàn*. Triển khai = *Lập plan, chờ duyệt*.
> **File liên quan:** plan gốc của anh `tmp/delta_override_plan_v3.md` · plan thực thi `tasks/todo.md`.

---

# PHẦN 1 — VẤN ĐỀ LÀ GÌ (1 đoạn)

Mô hình đúng ("Sách thư viện vs. Giấy ghi chú"):
- **S1 Link gốc:** chọn câu từ Bank, không sửa → `question_id = UUID`, `custom_content = NULL`.
- **S2 Delta Override:** chọn từ Bank, sửa vài chữ → `question_id = UUID`, `custom_content = {override_text?, choices?}` (CHỈ phần khác biệt).
- **S3 Inline:** gõ tay mới → `question_id = NULL`, `custom_content = {type, override_text, choices, ...}` (toàn bộ).

**Bệnh:** Khi giáo viên chọn câu từ Bank, hệ thống **nhồi nguyên cục JSON đầy đủ** (type, tags, difficulty, explanation, choices, hints...) vào `custom_content` dù vẫn giữ `question_id`. → Vi phạm "nguồn chân lý duy nhất", phình dữ liệu, làm nhiễu analytics Phase 7 (1 câu hỏi mang nhiều phiên bản nội dung).

---

# PHẦN 2 — BẰNG CHỨNG TỪ DATABASE THẬT (292 dòng `assignment_questions`)

| Loại | Số dòng | Đánh giá |
|------|--------:|----------|
| ✅ S1 link gốc (qid + NULL) | 41 | đúng |
| ✅ S2 delta (qid + diff, không `type`) | 0 | — |
| ✅ S3 inline (qid NULL + content) | 139 | đúng |
| ❌ **GARBAGE (qid + full payload có `type`)** | **112** | **38% — đây là rác** |

**Chi tiết 112 dòng rác:**
- 110 trắc nghiệm (multiple_choice) + 2 tự luận (essay).
- Keys thừa trong `custom_content`: `type(112), hints(112), tags(111), learningObjectives(111), explanation(111), choices(110), difficulty(103)`.
- Field chấm điểm (`expected_answer / ai_grading_keywords / blanks / pairs / objective_ids / images`) trong dòng bank-linked = **0** → nghĩa là strip các key thừa **AN TOÀN**, không mất dữ liệu chấm điểm.

**⚠️ RỦI RO BACKFILL (số thật):**
- **107 / 112** dòng rác ĐÃ có `submission_answers` (học sinh đã làm/đã chấm).
- **19 assignments** bị ảnh hưởng.
- → Backfill BẮT BUỘC bảo toàn nội dung học sinh đã thấy (text + choices không đổi).

**⚠️ TẦNG RÁC THỨ 2 (plan v3 không phát hiện):**
- `questions.content` của Bank cũng bẩn: **40 câu** lưu shape `{override_text}` thay vì `{text}` chuẩn.
- → Backfill kiểu "nếu custom_content == questions.content thì set NULL" của plan v3 sẽ match **0 dòng** (2 bên khác shape) → **vô dụng**, phải viết lại theo từng field.
- → Lần này **KHÔNG sửa tầng 2** (theo lựa chọn "backfill an toàn"), chỉ ghi nhận để lần sau.

---

# PHẦN 3 — NGUYÊN NHÂN GỐC (3 tầng, đã xác minh code)

### 🔴 V1 — Write Client (Flutter)
`teacher_create_assignment_screen.dart:765-937` → hàm `_mapQuestionsToAssignmentQuestions()`
- Build **full** `custom_content` cho MỌI câu (cả bank-linked lẫn inline), rồi gán `question_id: q['questionId']` (dòng 928).
- **Không có** hàm `_diffAgainstBank`. → bank-linked luôn nhận full payload.
- ✅ Confirmed.

### 🔴 V2 — Write Server (2 RPC)
**a) `create_assignment_with_questions(p_teacher_id, p_payload)`**
- CÓ logic delta nhưng **so sai shape**:
  ```sql
  IF v_custom_content IS NULL OR v_custom_content = v_base_content THEN
    v_custom_content := NULL;   -- KHÔNG BAO GIỜ chạy
  END IF;
  ```
  `v_custom_content` = `{type, override_text, choices...}` còn `v_base_content` (`questions.content`) = `{text}` → khác shape → không bao giờ bằng → rác luôn được lưu. Không whitelist key.

**b) `publish_assignment(p_assignment, p_questions, p_distributions)`** ← **đường ghi chính khi publish**
- **KHÔNG có logic delta gì cả** — insert thẳng `q->'custom_content'` từ client:
  ```sql
  SELECT v_assignment_id, (q->>'question_id')::uuid, q->'custom_content', ...
  ```
- → Đây là nguồn rác lớn nhất. **plan v3 BỎ SÓT RPC này.**
- ⚠️ Có guard `v_has_sessions`: nếu assignment đã có học sinh làm → KHÔNG xoá/ghi lại câu hỏi. → fix write chỉ áp cho bài MỚI; 19 bài cũ phải dựa vào backfill.

### 🟢 V3 — Read Path (KHÔNG vỡ — trái với audit)
`assignment_datasource.dart:836-1004` → `getDistributionDetail()`
- Apply delta ĐÚNG: bank làm nền + override `override_text`/`choices` (Case 1 bank-linked); full custom_content cho inline (Case 2).
- Verbose (~170 dòng) nhưng chạy đúng → **chỉ là cleanup tùy chọn, KHÔNG phải bug.**
- Lưu ý: Case 1 chỉ đọc override text+choices, không đọc expected_answer/keywords từ custom_content — nhưng vì bank-linked không có các field đó (Phần 2) nên hiện không mất gì.

---

# PHẦN 4 — SAI LỆCH GIỮA PLAN V3 CỦA ANH VỚI THỰC TẾ

| # | `delta_override_plan_v3.md` nói | Thực tế đã verify | Verdict |
|---|--------------------------------|-------------------|---------|
| C1 | Tạo `db/migrations/016_delta_override_guard.sql` | Hệ thống dùng `supabase/migrations/` (timestamped); mới nhất `024_question_bank_summary_rpc`. Thư mục `db/` là **legacy KHÔNG được apply**. Số 016 cũng đã dùng | ❌ **Sai chỗ + sai số** → phải `supabase/migrations/<ts>_025_...` |
| C2 | TODO 2: gỡ read merge "đang vỡ ~dòng 842-1004" | Read path chạy đúng | ❌ Chỉ là cleanup, hạ ưu tiên / bỏ |
| C3 | Whitelist `[override_text, choices, points, rubric]` | Bank-linked rows có 0 field chấm điểm → whitelist này an toàn | ✅ OK hiện tại (ghi chú: mở rộng nếu sau cho override essay) |
| C4 | CHECK `NOT (custom_content ? 'type')` NOT VALID | Đúng invariant | ⚠️ Phải add **SAU** khi sửa write + backfill, không thì chặn insert hiện tại |
| C5 | Chỉ sửa `create_assignment_with_questions` | Còn `publish_assignment` (đường ghi chính, hiện không delta) | ⚠️ **Bỏ sót** — phải sửa CẢ HAI |
| C6 | Backfill "nếu custom == bank thì NULL" | Match 0 dòng (khác shape); bank content cũng bẩn | ❌ Logic sai, viết lại theo field |

**Constraint hiện có trên `assignment_questions`:** `points_check(points>0)`, FK assignment (CASCADE), FK question (SET NULL), pkey(id), unique(assignment_id, order_idx). **KHÔNG có** check nào trên (question_id, custom_content).

---

# PHẦN 5 — PLAN FIX ĐỀ XUẤT (1 PR atomic, 5 bước)

> Thứ tự bắt buộc trong file SQL: **helper → fix RPC → backfill → constraint** (add constraint trước backfill sẽ fail vì 112 dòng còn `type`).

### TODO 1 — [Dart] Diff client
File: `teacher_create_assignment_screen.dart`
- Cache bank gốc khi pick: `_bankCache[q.id] = q` trong `_openQuestionBankPicker` (line ~464).
- Viết `_diffAgainstBank(q, fullCustomContent) → Map?`:
  - `override_text` khác bank → giữ; giống → bỏ.
  - `choices` khác bank (so text+isCorrect, đúng thứ tự) → **snapshot TRỌN BỘ mảng** (không diff từng phần — tránh Array Annihilation); giống → bỏ.
  - KHÔNG copy type/tags/difficulty/explanation/images/hints/learningObjectives cho bank-linked.
  - Không có override nào → trả `null`.
  - Bank không có trong cache (sửa bài cũ) → fallback giữ nguyên (an toàn).
- `_mapQuestionsToAssignmentQuestions`: bank-linked → dùng diff (NULL/S2); inline → giữ full (S3).

### TODO 2 — [SQL] Sửa 2 RPC + helper
File mới: `supabase/migrations/<timestamp>_025_delta_override_guard.sql`
- `fn_strip_bank_delta(p_custom jsonb, p_question_id uuid) → jsonb`: whitelist giữ `override_text, choices`; strip key thừa; nếu override_text trùng bank text → bỏ; nếu rỗng `{}` → NULL.
- Sửa `create_assignment_with_questions`: thay block so-sai-shape bằng `fn_strip_bank_delta` khi `question_id NOT NULL`.
- Sửa `publish_assignment`: thêm `fn_strip_bank_delta` vào nhánh INSERT (chỉ khi `question_id NOT NULL`). Giữ nguyên guard `v_has_sessions`.

### TODO 3 — [SQL] Backfill an toàn (cùng migration 025)
```sql
UPDATE assignment_questions aq
SET custom_content = fn_strip_bank_delta(aq.custom_content, aq.question_id)
WHERE aq.question_id IS NOT NULL AND aq.custom_content ? 'type';
```
- Resolved-view (bank nền + override) bất biến → 107 dòng có submission an toàn.
- KHÔNG đụng `submission_answers` (điểm nằm bảng khác, không phụ thuộc custom_content).

### TODO 4 — [SQL] CHECK constraint (cuối migration 025)
```sql
ALTER TABLE assignment_questions
  ADD CONSTRAINT aq_no_full_schema_in_delta
  CHECK (question_id IS NULL OR custom_content IS NULL OR NOT (custom_content ? 'type'))
  NOT VALID;
ALTER TABLE assignment_questions VALIDATE CONSTRAINT aq_no_full_schema_in_delta; -- vì backfill đã sạch 100%
```

### TODO 5 — Verify
- `flutter analyze` = 0 error.
- MCP re-check bucket → kỳ vọng 0 dòng GARBAGE; constraint VALID.
- So resolved text/choices 5 dòng mẫu trước/sau backfill phải GIỐNG HỆT.
- Smoke test tạo + publish 1 bài pick-bank.
- Cập nhật `memory-bank/activeContext.md`.

### Rollback
Migration bọc `BEGIN; ... COMMIT;`. Backfill idempotent (chạy lại vô hại). RPC cũ có trong git history. Gỡ constraint: `DROP CONSTRAINT aq_no_full_schema_in_delta;`.

---

# PHẦN 6 — KHÔNG LÀM LẦN NÀY (đã chốt)
- ❌ Tầng rác 2 (`questions.content` shape `{override_text}` — 40 câu) → lần sau.
- ❌ DTO refactor read path (read đang đúng).
- ❌ Mở whitelist cho essay override (chưa có nhu cầu thật).

---

# PHẦN 7 — 2 ĐIỂM CẦN ANH XÁC NHẬN TRƯỚC KHI CODE
1. **Whitelist bank-linked = `[override_text, choices]`** (points/rubric ở cột riêng) — đồng ý?
2. **VALIDATE constraint ngay trong migration 025** (em nghiêng phương án này vì backfill làm sạch 100%) hay để NOT VALID rồi validate ở migration sau?

> Duyệt (toàn bộ / chỉnh điểm nào) → em code theo thứ tự helper → RPC → backfill → constraint → verify.

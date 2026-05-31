# Delta Override — Báo cáo XÁC MINH (code + DB thật)

> 2026-05-30. Nguồn: source code + Supabase MCP (project `vazhgunhcjdwlkbslroc`).
> Tổng: 292 `assignment_questions`, 274 `questions`.

## 1. DỮ LIỆU THẬT — phân loại 292 dòng assignment_questions

| Bucket | Số dòng | Đánh giá |
|--------|--------:|----------|
| S1 link gốc (qid + custom_content NULL) | 41 | ✅ chuẩn |
| S2 delta override (qid + diff, không có `type`) | 0 | — |
| S3 inline (qid NULL + custom_content) | 139 | ✅ chuẩn (ghost/inline) |
| **GARBAGE: bank-linked + FULL payload (có `type`)** | **112** | ❌ rác (38% tổng) |

Trong 112 garbage: 110 multiple_choice + 2 essay.
Keys trong garbage custom_content: `override_text(112), hints(112), type(112), tags(111), learningObjectives(111), explanation(111), choices(110), difficulty(103)`.
**Field chấm điểm bank-linked: `expected_answer=0, ai_grading_keywords=0, blanks=0, pairs=0, objective_ids=0, images=0`** → bank-linked rows KHÔNG mang field chấm điểm essay/fill. (Chỉ S3 inline mới mang.)

## 2. ⚠️ TẦNG RÁC THỨ 2 (mới phát hiện — plan v3 KHÔNG đề cập)

`questions.content` của bank cũng bị **nhiễm shape sai**:
- 112 questions có `content = {override_text, explanation}` (shape custom_content) thay vì `{text, ...}` chuẩn.
- 156 questions có `content = {text}` chuẩn.
- 0 questions có key `type` trong content.

→ Nghĩa là: **khi câu hỏi được tạo, content gốc đã lưu sai key `override_text` thay vì `text`** (do write path build content từ custom_content, hoặc do `create_assignment_with_questions` insert `v_q->'content'` đã sai shape từ client). Hệ quả:
- Read path `getDistributionDetail` Case 1 đọc `qContent['text']` → **null** cho 112 câu này → may mắn được cứu vì custom_content cũng có `override_text` đè lên. Nhưng nếu cleanup custom_content về NULL mà KHÔNG sửa bank content → **mất text câu hỏi**.
- `custom_content == questions.content`? → **0 dòng** khớp exactly (custom_content nhiều key hơn). Nên backfill kiểu "nếu bằng nhau thì NULL" của plan v3 sẽ match 0 dòng → **vô dụng**.

## 3. 🔴 RỦI RO BACKFILL (số thật)
- **107 / 112** dòng garbage ĐÃ có `submission_answers` (học sinh đã làm/đã chấm).
- **19 assignments** bị ảnh hưởng.
→ Backfill phải bảo toàn nội dung học sinh đã thấy. KHÔNG được đổi text/choices. Chỉ được strip key thừa khi resolved-view không đổi.

## 4. NGUYÊN NHÂN GỐC (confirmed qua code + định nghĩa RPC thật)

### V1 Write client — `teacher_create_assignment_screen.dart:765-937`
`_mapQuestionsToAssignmentQuestions` build **full** custom_content cho MỌI câu + gán `question_id` (dòng 928). Không diff. → bank-linked nhận full payload. **Không có `_diffAgainstBank`.** CONFIRMED.

### V2 Write server — RPC `create_assignment_with_questions(p_teacher_id, p_payload)` + `publish_assignment(p_assignment, p_questions, p_distributions)`
- `create_assignment_with_questions`: có logic delta `IF v_custom_content = v_base_content THEN NULL` nhưng so `{type,override_text,...}` vs `{text}`/`{override_text}` → **không bao giờ bằng** → rác lưu luôn. Không whitelist.
- `publish_assignment`: **KHÔNG có cả logic delta** — insert thẳng `q->'custom_content'` từ client (SELECT ... q->'custom_content'). Đây là đường ghi chính (publish). CONFIRMED — đường này là nguồn rác lớn nhất.
- ⚠️ `publish_assignment` có guard `v_has_sessions`: nếu assignment đã có work_sessions → **KHÔNG xoá/ghi lại** assignment_questions. → fix write CHỈ áp cho assignment mới/chưa ai làm. 19 assignments cũ phải dựa vào backfill, không tự sửa qua publish.

### V3 Read path — `assignment_datasource.dart:836-1004`
KHÔNG vỡ. Apply delta đúng (bank nền + override text/choices cho Case1; full custom_content cho Case2 inline). Plan v3 TODO2 coi là "bug phải gỡ" → **SAI**, chỉ là cleanup tùy chọn.
- ⚠️ Case 1 chỉ đọc override `override_text`+`choices`, KHÔNG đọc `expected_answer/keywords/blanks` từ custom_content → nhưng vì bank-linked không có các field đó (mục 1) nên hiện không mất gì.

## 5. XUNG ĐỘT VỚI PLAN V3 (tmp/delta_override_plan_v3.md)

| # | Plan v3 | Thực tế | Verdict |
|---|---------|---------|---------|
| C1 | tạo `db/migrations/016_...` | dùng `supabase/migrations/` timestamped; mới nhất `024_question_bank_summary_rpc` (20260521). `db/` legacy KHÔNG apply. 016 đã dùng | ❌ SAI chỗ+số. Phải `supabase/migrations/<ts>_025_...` |
| C2 | TODO2 gỡ read merge "đang vỡ" | read path đúng | ❌ chỉ cleanup, hạ ưu tiên |
| C3 | whitelist `[override_text,choices,points,rubric]` | bank-linked không có field chấm điểm → whitelist này AN TOÀN cho bank-linked. Nhưng nếu tương lai cho override essay thì thiếu | ⚠️ OK cho hiện tại, ghi chú mở rộng |
| C4 | CHECK `NOT (custom_content ? 'type')` NOT VALID | đúng invariant | ⚠️ phải add SAU khi sửa write, nếu không chặn insert |
| C5 | sửa `create_assignment_with_questions` | còn phải sửa **`publish_assignment`** (đường ghi chính, hiện KHÔNG delta) | ⚠️ plan v3 bỏ sót publish_assignment |
| C6 | backfill "nếu custom==bank thì NULL" | 0 dòng match (shape khác). Bank content cũng bẩn (tầng 2) | ❌ logic backfill sai, cần viết lại theo field |

## 6. CONSTRAINT hiện có (assignment_questions)
`points_check(points>0)`, FK assignment(CASCADE), FK question(SET NULL), pkey(id), unique(assignment_id, order_idx). KHÔNG có check trên (question_id, custom_content).

## 7. CÂU HỎI CẦN USER CHỐT
1. Phạm vi sửa: chỉ **chặn rác MỚI** (sửa write V1+V2 + constraint), hay **cả backfill 112 dòng cũ** (rủi ro cao, 107 đã có bài nộp)?
2. Tầng rác 2 (`questions.content` shape `{override_text}` cho 112 câu): có sửa luôn về `{text}` không? (cần để read path & analytics đúng lâu dài)
3. Whitelist bank-linked: chốt `[override_text, choices]` (+ points/rubric ở cột riêng) — đồng ý? Tương lai essay override thì mở thêm.
4. Có chấp nhận **không backfill**, chỉ để read path tiếp tục che (vì nó đang hiển thị đúng) và chỉ chặn rác mới? → an toàn nhất, 0 rủi ro dữ liệu cũ.

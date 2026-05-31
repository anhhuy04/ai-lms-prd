# PLAN CUỐI — Delta Override (HƯỚNG C: Snapshot-first) — chờ duyệt để code

> Đã chốt Hướng C. Mọi giả định đã verify bằng code + DB thật + test RLS đúng quyền học sinh.
> Nguyên tắc tối thượng: **resolved-view (cái học sinh thấy) BẤT BIẾN** cho 107 dòng đã có bài nộp.

---

## SỰ THẬT NỀN (đã verify)
- 41 bank-linked + custom NULL = câu GLOBAL (học sinh đọc được bank). ✅ đúng sẵn.
- 112 bank-linked + full payload = câu PRIVATE (is_global=false). Học sinh KHÔNG đọc được bank (test RLS = 0). → full payload là thứ DUY NHẤT giúp học sinh thấy đề. Bản chất: câu inline bị `create_assignment_with_questions` tự tạo bản bank private rồi link.
- 139 inline + question_id NULL = S3 sạch (đường publish). Trigger chạy OK (151 submission_answers).
- 0 dòng global + full payload.
- Trigger `fn_update_skill_mastery` + `fn_update_question_stats`: đều `IF question_id IS NULL THEN RETURN NEW` → NULL an toàn, không crash.
- FK: submission_answers/autosave → assignment_questions.**id** (không phải question_id). question_id FK = ON DELETE SET NULL.
- Client KHÔNG có field isGlobal → ENFORCE Ở SERVER.

## QUYẾT ĐỊNH KIẾN TRÚC (Hướng C)
| Loại câu | question_id | custom_content |
|----------|-------------|----------------|
| Inline (gõ tay) | **NULL** | full (S3) |
| Bank GLOBAL, không sửa | giữ UUID | NULL (S1) |
| Bank GLOBAL, có sửa | giữ UUID | diff `{override_text?, choices?}` (S2) |
| Bank PRIVATE (mọi trường hợp) | **NULL** | full snapshot (về S3 — vì học sinh không đọc được bank) |

→ Invariant: **question_id NOT NULL ⟹ custom_content là diff (không có key `type`)**.

---

## TODO 1 — [SERVER] Helper + 2 RPC  (file: `supabase/migrations/<ts>_025_delta_override_enforcement.sql`)
Bọc `BEGIN; ... COMMIT;`.

1.1. `fn_normalize_aq_content(p_question_id uuid, p_custom jsonb) RETURNS jsonb`
   - Trả jsonb `{"question_id": <uuid|null>, "custom_content": <jsonb|null>}`.
   - p_question_id NULL → trả {NULL, p_custom} (inline giữ nguyên).
   - bank = SELECT is_global, content FROM questions WHERE id=p_question_id. Không tồn tại → {NULL, p_custom}.
   - **is_global = false (private)** → {NULL, p_custom} (snapshot S3, cắt link).
   - **is_global = true (global)**:
     - whitelist: `v := p_custom` chỉ giữ `override_text`, `choices` (bỏ tất cả key khác).
     - nếu `v->>'override_text' = COALESCE(bank.content->>'text', bank.content->>'override_text')` → bỏ `override_text`.
     - nếu `choices` khớp bank (so text+is_correct theo thứ tự) → bỏ `choices`.
     - nếu `v = '{}'` → custom = NULL.
     - trả {p_question_id, v}.

1.2. `create_assignment_with_questions`: thay block "2.2 tính custom_content" (so shape sai) bằng gọi `fn_normalize_aq_content(v_question_id, v_question->'custom_content')` → lấy ra question_id + custom_content chuẩn rồi INSERT. **LƯU Ý:** với câu inline (client không gửi id), RPC hiện tạo bank question private + link → theo Hướng C phải để **question_id = NULL** (đừng tạo bản bank private). Sửa nhánh "tạo câu mới" để KHÔNG insert vào questions; chỉ insert assignment_questions với question_id NULL + full custom_content. (Khớp hành vi publish_assignment, hết nguồn sinh 112 rác.)

1.3. `publish_assignment`: nhánh INSERT assignment_questions (chỉ khi NOT v_has_sessions) → đưa từng phần tử qua `fn_normalize_aq_content(q->>'question_id', q->'custom_content')`. Giữ nguyên guard `v_has_sessions`.

**Verify:** MCP gọi RPC với payload full bank-global → DB lưu diff/NULL; bank-private → question_id NULL + full.

## TODO 2 — [BACKFILL] 112 dòng (cùng migration, sau khi tạo helper)
```sql
-- 2a. Câu PRIVATE bank-linked → cắt link (về S3 inline). resolved-view bất biến (read path đã đọc full custom_content).
UPDATE public.assignment_questions aq
SET question_id = NULL
WHERE aq.question_id IS NOT NULL
  AND aq.custom_content ? 'type'
  AND aq.question_id IN (SELECT id FROM public.questions WHERE is_global IS NOT TRUE);

-- 2b. (Phòng tương lai) Câu GLOBAL bank-linked + full payload → collapse về diff. Hiện 0 dòng nhưng để an toàn:
UPDATE public.assignment_questions aq
SET custom_content = (fn_normalize_aq_content(aq.question_id, aq.custom_content)->'custom_content')
WHERE aq.question_id IS NOT NULL
  AND aq.custom_content ? 'type'
  AND aq.question_id IN (SELECT id FROM public.questions WHERE is_global IS TRUE);
```
- KHÔNG đụng submission_answers (FK qua .id). Trigger an toàn (guard NULL).
- Log COUNT trước/sau trong khối DO.

## TODO 3 — [CONSTRAINT] khoá cửa (cuối migration, sau backfill)
```sql
ALTER TABLE public.assignment_questions
  ADD CONSTRAINT aq_bank_linked_must_be_delta
  CHECK (question_id IS NULL OR custom_content IS NULL OR NOT (custom_content ? 'type'))
  NOT VALID;
ALTER TABLE public.assignment_questions VALIDATE CONSTRAINT aq_bank_linked_must_be_delta;
```
Sau backfill: 41 (custom NULL) pass, 112 (question_id NULL) pass, 139 inline (question_id NULL) pass → VALIDATE OK.

## TODO 4 — [CLIENT] (tối thiểu — server đã enforce)
- `_mapQuestionsToAssignmentQuestions`: KHÔNG cần đổi logic (server normalize). Chỉ thêm comment ghi rõ "server fn_normalize_aq_content là nơi enforce data contract" để Tech Lead khỏi nghi.
- (Bỏ ý tưởng `_diffAgainstBank` ở client vì entity không có isGlobal → client không quyết định đúng được. Defense ở server là đủ và chính xác hơn.)

## TODO 5 — VERIFY
- MCP: chạy lại bucket phân loại → 0 dòng "GARBAGE (qid + type)".
- MCP: constraint VALID; thử INSERT 1 dòng (qid NOT NULL + custom có 'type') → phải bị REJECT.
- MCP: so resolved text/choices 5 dòng mẫu trước/sau backfill → GIỐNG HỆT.
- `flutter analyze` = 0 error (client gần như không đổi).
- Smoke: tạo + publish 1 bài (1 câu inline + 1 câu global từ bank) → DB đúng contract.
- Cập nhật `memory-bank/activeContext.md`.

## ROLLBACK
Migration trong transaction. Backfill idempotent. RPC cũ trong git history. Gỡ: `DROP CONSTRAINT aq_bank_linked_must_be_delta;` + restore RPC.

## KHÔNG LÀM
- Hướng A (thêm RLS cho học sinh đọc bank private) — đã loại, để tương lai nếu cần link analytics.
- Sửa tầng rác 2 (questions.content shape) — không cần vì câu private giờ cắt link, read path không đọc bank nữa.

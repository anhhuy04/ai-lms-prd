# 🧪 TEST GUIDE — Delta Override + Analytics (MCP-driven E2E trên giao diện)

> **Mục tiêu:** Kiểm chứng 11 migration (025–035) + fix grading bank-type hoạt động ĐÚNG khi thao tác thật trên UI, **lái UI bằng MCP** và **verify DB bằng Supabase MCP**.
> **Tài khoản test:** `ha@gmail.com` (GIÁO VIÊN, id `d810df06-78c5-441c-8eaf-90e6e505adad`).
> **App:** http://localhost:8080 (web-server mode). Cần học sinh cho Test 6/9.
> **Người chạy:** AI agent dùng MCP (UI driver + Supabase) — tự lái, tự verify.
> **Cập nhật:** 2026-05-31 (sau khi apply 033/034/035 + fix #1 grading + revert #6).

---

## 0. KHẾ ƯỚC ĐANG TEST (phải nhớ)

Bảng `assignment_questions`, constraint `aq_bank_linked_must_be_delta`:
> `question_id NOT NULL` ⟹ `custom_content` KHÔNG chứa key `type`.

| Kịch bản | question_id | custom_content | Khi nào |
|----------|-------------|----------------|---------|
| **S1** | UUID (bank GLOBAL) | `NULL` | chọn câu bank global, không sửa |
| **S2** | UUID (bank GLOBAL) | `{override_text?, choices?}` (KHÔNG có `type`) | chọn bank global + sửa |
| **S3** | `NULL` | full payload (`type`, `override_text`, `choices`, `objective_ids`...) | gõ tay inline / bank PRIVATE |

**Quy tắc vàng:** Câu bank PRIVATE (is_global=false) LUÔN bị cắt link → S3. Câu gõ tay → S3.
**Suy `type` khi đọc/chấm:** câu bank-linked (question_id≠NULL) lấy `type` từ **bank `questions.type`**; câu inline lấy từ `custom_content.type`. (← fix #1, áp cho cả grading lẫn render.)

---

## 0bis. ⚠️ THAY ĐỔI SO VỚI BẢN GUIDE CŨ (đọc kỹ trước khi test)

| Mục | Trạng thái mới |
|-----|----------------|
| **Test 7** (AI generate → "Lưu & thêm vào Đề thi") | ❌ **VÔ HIỆU** — `StagingAreaWidget` đã orphaned (không còn caller). Màn AI generate chỉ có nút **"Lưu vào Ngân hàng"** (→ `createQuestion`, KHÔNG gọi `save_questions_to_assignment`). Không test được qua UI. RPC `save_questions_to_assignment` (migration 028/033) hiện là code chết. **BỎ QUA Test 7.** |
| **Test 9 (MỚI)** | ✅ Kiểm fix #1: câu **bank GLOBAL non-MC** (tự luận/điền khuyết) phải chấm đúng + vào `ai_queue`, KHÔNG bị auto-0 như trắc nghiệm. |
| **avg_score** | `question_stats.avg_score` giờ là **điểm THÔ** (migration 032/034), KHÔNG còn chuẩn hoá 0–1. |
| **Migration count** | 025–035 = **11 migration**; **9 function** lõi (thêm `update_assignment_question_content`). |
| **Hotfix sửa câu** | đường `_saveHotfix` (bài đã publish) giờ đi RPC `update_assignment_question_content` (chuẩn hoá qua `fn_normalize_aq_content`). |

---

## 1. BASELINE (đã chụp — chụp lại nếu muốn mốc mới)

> Chạy query này TRƯỚC khi thao tác, ghi `baseline_at` làm mốc `created_at >` cho các test sau.

```sql
-- [MCP supabase.execute_sql] BASELINE
SELECT
  (SELECT count(*) FROM public.assignment_questions) AS aq_total,
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NOT NULL) AS bank_linked,
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NULL) AS inline_rows,
  (SELECT count(*) FROM public.assignment_questions
     WHERE question_id IS NULL
       AND jsonb_array_length(COALESCE(custom_content->'objective_ids','[]'::jsonb))>0) AS inline_with_objectives,
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NOT NULL AND custom_content ? 'type') AS garbage_rows,
  (SELECT count(*) FROM public.assignments WHERE teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad') AS ha_assignments,
  (SELECT count(*) FROM public.questions WHERE author_id='d810df06-78c5-441c-8eaf-90e6e505adad' AND is_global IS NOT TRUE) AS ha_private_bank,
  (SELECT count(*) FROM public.question_stats) AS qstats_rows,
  (SELECT count(*) FROM public.student_skill_mastery) AS skill_mastery_rows,
  now() AS baseline_at;
```

**Baseline đã chụp 2026-05-31 (≈ 2026-05-30 17:22 UTC):**
`aq_total=292 · bank_linked=41 · inline_rows=251 · inline_with_objectives=0 · garbage_rows=0 · ha_assignments=19 · ha_private_bank=70 · qstats_rows=26 · skill_mastery_rows=353`

→ Kỳ vọng sau test: `garbage_rows VẪN = 0`, `inline_with_objectives TĂNG` (sau Test 1), `aq_total` tăng theo số câu thêm.
→ **Mốc so sánh dùng trong query:** `created_at > '2026-05-31 00:00:00+00'` (đổi theo ngày bạn chạy).

---

## 2. TOOLCHAIN MCP — lái UI + verify (THAY cho log instrumentation cũ)

### 2.1. Verify DB — `mcp__supabase__execute_sql` (read-only cho test)
- Chạy SELECT ở mỗi test để đối chiếu kỳ vọng. **KHÔNG INSERT/UPDATE/DELETE.**
- Token đã cấu hình sẵn trong `.mcp.json` (server `supabase`).

### 2.2. Lái UI — chọn driver theo thứ tự ưu tiên
Quy trình mỗi test: **(a)** agent lái UI bằng MCP → **(b)** chờ commit → **(c)** chạy query verify → **(d)** đối chiếu kỳ vọng.

**Ưu tiên A — `marionette` (Flutter widget, đáng tin nhất NẾU app debug expose VM service):**
1. Lấy VM service ws URI (terminal `flutter run` in ra, vd `ws://127.0.0.1:8181/ws`), hoặc `mcp__dart__list_running_apps` / `mcp__mcp-flutter-debug__get_active_ports`.
2. `mcp__marionette__connect` với URI đó.
3. `mcp__marionette__get_interactive_elements` → khám phá nút/field (match theo `ValueKey` hoặc text).
4. `mcp__marionette__tap` / `enter_text` / `scroll_to` để thao tác; `take_screenshots` để xem state; `get_logs` để debug.
> Nếu marionette KHÔNG connect (app thiếu package `marionette`) → dùng B.

**Ưu tiên B — `claude-in-chrome` (app chạy web tại localhost:8080):**
1. `ToolSearch "select:mcp__claude-in-chrome__tabs_context_mcp"` rồi gọi để lấy tab context.
2. `mcp__claude-in-chrome__navigate` tới `http://localhost:8080` (hoặc dùng tab có sẵn nếu user yêu cầu).
3. `mcp__claude-in-chrome__find` / `read_page` / `get_page_text` để định vị element; `computer` (click/type) hoặc `form_input` để thao tác.
4. `mcp__claude-in-chrome__read_console_messages` (pattern lọc) để đọc log nếu cần.
> Lưu ý: Flutter web render canvas → text có thể không phải DOM thường; ưu tiên semantics labels. Bật accessibility nếu cần.

**Ưu tiên C — debug/log only (khi không click được):** `mcp__dart__get_app_logs`, `mcp__dart__get_runtime_errors` (cần `connect_dart_tooling_daemon`). Skill dự án: **`flutter-web-debug`** (auto-connect VM/Chrome) — gọi khi cần.

### 2.3. Nguyên tắc cho agent
- Sau mỗi thao tác ghi DB (lưu/publish/sync), **đợi UI báo thành công** rồi mới query (tránh đọc trước commit).
- Nếu UI lỗi (snackbar đỏ / runtime error) → chụp screenshot + đọc log, ghi vào kết quả test (FAIL).
- Không bịa: nếu không tìm thấy nút (vd nút "Đồng bộ" Test 8), ghi "không reachable" thay vì giả định.

---

## 3. KỊCH BẢN TEST (thực hiện THEO THỨ TỰ)

> Mỗi test: lái UI → chờ "xong" → chạy query verify → đối chiếu. Thay `'2026-05-31 00:00:00+00'` bằng mốc của bạn.

### ✅ TEST 1 — Câu INLINE gõ tay + gắn Learning Objective (luồng chính)

**Thao tác UI:**
1. Đăng nhập `ha@gmail.com`.
2. Tạo bài tập mới → tiêu đề "DOTEST Inline Objective".
3. Thêm **1 câu gõ tay** loại Trắc nghiệm: đề + 4 đáp án (đánh dấu 1 đúng).
4. Bấm **"Chọn mục tiêu học tập"** → chọn ≥1 objective (hoặc "+ Tạo mới" rồi chọn).
5. Lưu câu hỏi → **Lưu nháp** bài tập.

**Verify (Supabase MCP):**
```sql
SELECT aq.id, aq.question_id,
       aq.custom_content->>'type' AS type,
       aq.custom_content->'objective_ids' AS objective_ids,
       (aq.custom_content ? 'type') AS has_type_key,
       a.title, a.created_at
FROM public.assignment_questions aq
JOIN public.assignments a ON a.id = aq.assignment_id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad'
  AND a.created_at > '2026-05-31 00:00:00+00'
ORDER BY a.created_at DESC, aq.order_idx;
```
**Kỳ vọng:** `question_id=NULL` (S3) · `objective_ids` mảng UUID **không rỗng** · `type` có giá trị · KHÔNG dòng `question_id NOT NULL AND has_type_key=true`.

```sql
-- TEST 1b: constraint toàn cục vẫn sạch
SELECT count(*) AS garbage_must_be_0
FROM public.assignment_questions WHERE question_id IS NOT NULL AND custom_content ? 'type';
```
**Kỳ vọng:** `0`.

---

### ✅ TEST 2 — Câu từ NGÂN HÀNG (data contract S1/S2/S3)

**Thao tác UI:**
1. Trong bài tập, bấm **"Chọn từ Ngân hàng câu hỏi"**.
2. Chọn 1 câu GLOBAL → thêm, **KHÔNG sửa** (test S1).
3. (Tùy chọn) Chọn thêm 1 câu GLOBAL rồi **sửa đề** (test S2).
4. (Tùy chọn) Chọn 1 câu PRIVATE (kho riêng) → để test cắt link S3.
5. Lưu nháp.

**Verify:**
```sql
SELECT aq.id, aq.question_id, q.is_global,
       CASE
         WHEN aq.question_id IS NULL THEN 'S3 inline (private→cắt link hoặc gõ tay)'
         WHEN aq.custom_content IS NULL THEN 'S1 link gốc'
         WHEN NOT (aq.custom_content ? 'type') THEN 'S2 delta override'
         ELSE 'GARBAGE (SAI!)'
       END AS bucket,
       aq.custom_content
FROM public.assignment_questions aq
LEFT JOIN public.questions q ON q.id = aq.question_id
JOIN public.assignments a ON a.id = aq.assignment_id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad'
  AND a.created_at > '2026-05-31 00:00:00+00'
ORDER BY a.created_at DESC, aq.order_idx;
```
**Kỳ vọng:** GLOBAL không sửa → `S1` · GLOBAL có sửa → `S2` · PRIVATE → `S3 inline` (question_id NULL) · **TUYỆT ĐỐI không** `GARBAGE`.

---

### ✅ TEST 3 — PUBLISH bài tập

**Thao tác UI:** Bấm **"Xuất bản"** (chọn lớp/đối tượng nếu hỏi) → báo "publish xong".

**Verify:**
```sql
SELECT a.id, a.title, a.is_published, a.published_at,
       count(aq.*) AS n_questions,
       count(*) FILTER (WHERE aq.question_id IS NOT NULL AND aq.custom_content ? 'type') AS garbage_in_this_assignment
FROM public.assignments a
JOIN public.assignment_questions aq ON aq.assignment_id = a.id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad'
  AND a.created_at > '2026-05-31 00:00:00+00'
GROUP BY a.id, a.title, a.is_published, a.published_at;
```
**Kỳ vọng:** `is_published=true`, `garbage_in_this_assignment=0`, publish KHÔNG ném lỗi.

---

### ✅ TEST 4 — SỬA bài (replace_assignment_questions, migration 026)

> Lưu ý: UI cho sửa **danh sách câu** chỉ ở bài **nháp** (`!is_published`). Bài đã publish → đường **hotfix** (sửa nội dung 1 câu, xem Test 4b).

**4a — sửa bài NHÁP:** mở lại bài nháp → đổi/thêm câu → Lưu. Verify: chạy lại query TEST 2 → không sinh GARBAGE; câu inline giữ objective_ids.

**4b — hotfix bài ĐÃ PUBLISH (update_assignment_question_content, migration 035):** mở bài đã publish → sửa đề/đáp án 1 câu (dialog hotfix) → Lưu.
```sql
-- sau hotfix: vẫn đúng contract, không sinh garbage
SELECT aq.id, aq.question_id, (aq.custom_content ? 'type') AS has_type_key, aq.custom_content
FROM public.assignment_questions aq JOIN public.assignments a ON a.id=aq.assignment_id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad' AND a.created_at > '2026-05-31 00:00:00+00'
ORDER BY a.created_at DESC, aq.order_idx;
```
**Kỳ vọng:** câu bank-linked sau hotfix `has_type_key=false`; câu inline giữ nguyên; UI không lỗi.

---

### ✅ TEST 5 — NHÂN BẢN bài tập (deep_clone, migration 027)

**Thao tác UI:** Danh sách bài tập → **Nhân bản** bài có câu inline → mở bản sao → câu inline **hiển thị đầy đủ đề + đáp án**.

**Verify:**
```sql
SELECT a.title, aq.question_id,
       (aq.custom_content IS NOT NULL) AS has_content,
       aq.custom_content->>'override_text' AS text_preview
FROM public.assignments a
JOIN public.assignment_questions aq ON aq.assignment_id=a.id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad'
  AND a.title LIKE '%(Bản sao)%'
  AND a.created_at > '2026-05-31 00:00:00+00'
ORDER BY a.created_at DESC, aq.order_idx;
```
**Kỳ vọng:** câu inline (question_id NULL) có `has_content=true` + `text_preview` không null.

---

### ✅ TEST 6 — ANALYTICS (skill_mastery + question_stats, migration 032)

> Cần học sinh LÀM BÀI + GV chấm.

**Thao tác UI (2 vai):** Học sinh làm bài (gồm câu inline có objective) → nộp. GV chấm (đặc biệt câu tự luận chấm sau).

**Verify:**
```sql
-- 6a: skill_mastery nhận câu inline có objective
SELECT sm.student_id, sm.objective_id, sm.attempts, sm.correct, sm.mastery_level, sm.last_updated
FROM public.student_skill_mastery sm
WHERE sm.last_updated > '2026-05-31 00:00:00+00'
ORDER BY sm.last_updated DESC;

-- 6b: question_stats nhận câu bank-linked (raw avg_score, KHÔNG chuẩn hoá 0–1)
SELECT qs.question_id, qs.total_attempts, qs.correct_count, qs.avg_score, qs.last_attempted
FROM public.question_stats qs
WHERE qs.last_attempted > '2026-05-31 00:00:00+00'
ORDER BY qs.last_attempted DESC;
```
**Kỳ vọng:** có dòng mới sau baseline. `avg_score` là điểm THÔ (vd 1.5/2.0), KHÔNG phải 0–1. Chấm lại (regrade) KHÔNG double-count `total_attempts`.

---

### ❌ TEST 7 — (VÔ HIỆU) AI GENERATE → "Lưu & thêm vào Đề thi"

> **BỎ QUA.** `StagingAreaWidget` orphaned → không có nút "Lưu & thêm vào Đề thi" trong UI sống. RPC `save_questions_to_assignment` là code chết. Nếu sau này wire lại flow này (gắn lại `showStagingArea` + cho `QuestionDTO` mang `objective_ids`) thì mới test được. Hiện tại đánh dấu **N/A**.

---

### ⚠️ TEST 8 — SMART SYNC "Đồng bộ về Ngân hàng" (sync_assignment_to_bank, migration 029)

> **Kiểm reachability trước:** mở bài nháp có câu inline → tìm banner "câu hỏi chưa lưu vào ngân hàng" + nút **"Đồng bộ"**. Nếu KHÔNG thấy banner/nút → ghi "không reachable", bỏ qua phần UI (logic DB đã verify ở tầng RPC).

**Thao tác UI (nếu reachable):** bấm **"Đồng bộ"** → báo "sync xong" (UI hiện "Đã tạo X mới, liên kết Y trùng").

**Verify:**
```sql
SELECT aq.id, aq.question_id,
       (aq.custom_content ? 'synced_to_bank_id') AS marked_synced,
       aq.custom_content->>'synced_to_bank_id' AS bank_id,
       (aq.custom_content ? 'type') AS still_has_type
FROM public.assignment_questions aq
JOIN public.assignments a ON a.id = aq.assignment_id
WHERE a.teacher_id='d810df06-78c5-441c-8eaf-90e6e505adad'
  AND a.created_at > '2026-05-31 00:00:00+00'
  AND aq.question_id IS NULL
ORDER BY a.created_at DESC;
```
**Kỳ vọng:** `question_id=NULL` (soft-link) · `marked_synced=true`, `bank_id` UUID · `still_has_type=true` (qid NULL nên không vi phạm constraint) · UI KHÔNG crash.

```sql
-- 8b: bank private TĂNG sau sync (baseline ha_private_bank=70)
SELECT count(*) AS ha_private_bank_now
FROM public.questions WHERE author_id='d810df06-78c5-441c-8eaf-90e6e505adad' AND is_global IS NOT TRUE;
```
**Kỳ vọng:** > 70.

---

### ✅ TEST 9 (MỚI) — CHẤM ĐÚNG câu BANK non-MC (fix #1)

> Mục tiêu: câu **bank GLOBAL dạng tự luận/điền khuyết** (question_id≠NULL, custom_content KHÔNG có `type`) phải được suy `type` từ bank → chấm đúng + vào `ai_queue`, KHÔNG bị auto-0 như trắc nghiệm.
> Hiện DB có **0** câu bank non-MC → cần GV chủ động thêm 1 câu như vậy.

**Thao tác UI:**
1. GV: tạo/chọn 1 câu **GLOBAL bank dạng tự luận (essay)** vào 1 bài tập → publish → phân phối cho 1 lớp có học sinh.
2. Học sinh: làm bài, trả lời câu essay đó (gõ text) → nộp.

**Verify:**
```sql
-- 9a: submission_answer của câu bank essay KHÔNG bị auto chấm 0 như MCQ; phải chờ AI/GV
-- (submission_answers KHÔNG có cột status; trạng thái nằm ở work_sessions)
SELECT sa.id, sa.assignment_question_id, sa.final_score,
       aq.question_id, q.type AS bank_type
FROM public.submission_answers sa
JOIN public.assignment_questions aq ON aq.id = sa.assignment_question_id
JOIN public.questions q ON q.id = aq.question_id
WHERE q.type IN ('essay','short_answer','math','problem_solving','fill_blank')
  AND sa.created_at > '2026-05-31 00:00:00+00'
ORDER BY sa.created_at DESC;

-- 9b: câu essay/short_answer được đẩy vào ai_queue (không bị bỏ qua như MCQ)
SELECT aq2.question_id, q.type, qz.request_type, qz.status, qz.created_at
FROM public.ai_queue qz
JOIN public.submission_answers sa ON sa.id = qz.submission_answer_id
JOIN public.assignment_questions aq2 ON aq2.id = sa.assignment_question_id
JOIN public.questions q ON q.id = aq2.question_id
WHERE qz.created_at > '2026-05-31 00:00:00+00'
ORDER BY qz.created_at DESC;
```
**Kỳ vọng:**
- 9a: câu bank essay/short_answer có `final_score = NULL` (chờ AI/GV chấm), KHÔNG bị áp đặt =0 ngay lúc nộp như trắc nghiệm. (Trước fix #1: bị coi multiple_choice → chấm 0 âm thầm.)
- 9b: có dòng `request_type='score'` cho câu essay/short_answer/math (→ chứng minh `needsAIGrading=true`, fix #1 hoạt động). Trước fix: câu này bị coi `multiple_choice` → KHÔNG vào ai_queue.

---

## 4. QUERY "SỨC KHỎE TỔNG THỂ" (chạy bất cứ lúc nào)

```sql
-- [MCP supabase.execute_sql] HEALTH CHECK (bao trùm 025–035)
SELECT
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NOT NULL AND custom_content ? 'type') AS garbage_MUST_0,           -- 025 constraint
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NULL AND custom_content IS NULL) AS empty_MUST_0,                   -- 027 deep_clone
  (SELECT count(*) FROM public.assignment_questions aq JOIN public.questions q ON q.id=aq.question_id
     WHERE aq.custom_content IS NULL AND q.is_global IS NOT TRUE) AS rls_landmine_MUST_0,                                                     -- 028 save_questions
  (SELECT count(*) FROM public.assignment_questions WHERE question_id IS NULL AND custom_content IS NOT NULL
     AND NOT (custom_content ? 'override_text') AND (custom_content ? 'text')) AS legacy_text_key_MUST_0,                                     -- 031 normalize
  (SELECT convalidated FROM pg_constraint WHERE conname='aq_bank_linked_must_be_delta') AS constraint_valid_MUST_true,                       -- 025
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public'
     AND proname IN ('fn_normalize_aq_content','create_assignment_with_questions','publish_assignment',
                     'replace_assignment_questions','deep_clone_assignment','save_questions_to_assignment',
                     'sync_assignment_to_bank','detect_ghost_questions','update_assignment_question_content')) AS funcs_MUST_9,               -- 025/026/027/028/029/035
  (SELECT count(*) FROM pg_trigger WHERE tgrelid='public.submission_answers'::regclass AND NOT tgisinternal) AS sa_triggers_MUST_4,          -- 032
  (SELECT count(*) FROM public.question_stats WHERE avg_score > 1) AS qstats_raw_rows,                                                       -- 034 (raw > 1 chứng tỏ đã backfill)
  (SELECT count(*) FROM public.assignment_questions) AS aq_total;
```
**Kỳ vọng mọi lúc:** `garbage=0, empty=0, rls_landmine=0, legacy_text_key=0, constraint_valid=true, funcs=9, sa_triggers=4`. `qstats_raw_rows` > 0 (sau migration 034).

**Nếu FAIL → dump dòng nghi vấn:**
```sql
SELECT id, question_id, jsonb_pretty(custom_content)
FROM public.assignment_questions WHERE id = '<aq_id>';
```

---

## 5. BẢNG TỔNG KẾT PASS/FAIL (AI điền sau khi test)

| Test | Migration | Nội dung | Kỳ vọng chính | Kết quả |
|------|-----------|----------|---------------|---------|
| 1 | 025 | Inline + objective | objective_ids không rỗng, qid NULL, garbage=0 | ☐ |
| 2 | 025/030 | Bank S1/S2/S3 | đúng bucket, không GARBAGE | ☐ |
| 3 | 030 | Publish | is_published=true, garbage=0, không lỗi | ☐ |
| 4a | 026 | Sửa bài nháp | không sinh garbage | ☐ |
| 4b | 035 | Hotfix bài đã publish | has_type_key=false, không lỗi | ☐ |
| 5 | 027 | Nhân bản | câu inline không rỗng | ☐ |
| 6 | 032 | Analytics | mastery/stats có dòng mới, avg_score thô | ☐ |
| 7 | 028 | AI→thêm vào đề | ❌ **N/A** (StagingAreaWidget orphaned) | ⊘ |
| 8 | 029 | Smart Sync | soft-link, bank private +1 (nếu banner reachable) | ☐ |
| 9 | (fix #1) | Chấm câu bank non-MC | essay vào ai_queue, KHÔNG auto-0 | ☐ |
| HEALTH | 025–035 | Toàn cục | garbage=0, funcs=9, triggers=4, constraint valid, qstats raw | ☐ |

> **Coverage:** 025✓(T1,2,3) · 026✓(T4a) · 027✓(T5) · 028⊘(code chết) · 029✓(T8) · 030✓(T2,3) · 031✓(HEALTH) · 032✓(T6) · 035✓(T4b) · fix#1✓(T9).

---

## 6. GHI CHÚ QUAN TRỌNG
- `ha@gmail.com` = GIÁO VIÊN → test write path. Test 6 & 9 cần thêm tài khoản **học sinh**.
- Câu bank GLOBAL học sinh đọc được (render lấy type/content từ bank); câu bank PRIVATE bị cắt link thành inline snapshot (S3) → đúng Hướng C.
- Mọi đường ghi `assignment_questions` đi qua RPC (`create_assignment_with_questions`, `publish_assignment`, `replace_assignment_questions`, `deep_clone_assignment`, `update_assignment_question_content`) → tự chuẩn hoá qua `fn_normalize_aq_content`. Không có đường client ghi thẳng.
- **Bug pre-existing CHƯA fix (không chặn test, ghi nhận):** (a) câu bank-linked trong **form sửa của GV** có thể hiện sai loại/trống text (display-only, DB vẫn đúng); (b) nhánh has-sessions của `replace_assignment_questions` không match câu cũ theo id — hiện KHÔNG reachable (replace chỉ chạy ở bài nháp, chưa có session). Xem memory `project-bank-type-grading-bug`.
- Đây là guide MCP-driven: KHÔNG cần thêm log `[DOTEST]` như bản cũ. Nếu UI khó click (Flutter web canvas), fallback đọc log qua `mcp__dart__get_app_logs` / runtime errors.

# Phase 7 — Câu hỏi chưa rõ / Cần xác nhận trước khi plan

> **Status: ✅ TẤT CẢ 21 CÂU HỎI ĐÃ ĐƯỢC GIẢI ĐÁP** (discuss-phase 2026-04-08)
> Xem quyết định chi tiết trong `07-CONTEXT.md` section `<session_decisions>` (D-07 đến D-24)
>
> **Ký hiệu:** `[BLOCKER]` = phải trả lời trước khi code | `[CLARIFY]` = ảnh hưởng đến thiết kế | `[RISK]` = rủi ro tiềm ẩn phát hiện từ code

---

## Wave 1 — DB Triggers (7-01, 7-02, 7-11a)

### Q1 [BLOCKER] Custom questions không có `question_id` → trigger 7-01/7-02 skip hoàn toàn?

**Quan sát từ schema:**
```
submission_answers.assignment_question_id
  → assignment_questions.question_id  ← CÓ THỂ NULL (custom questions)
    → question_objectives.question_id
      → student_skill_mastery
```
`assignment_questions.question_id` là NULL với custom questions (tạo inline, không từ question bank).
Nếu trigger chỉ follow chain này, toàn bộ custom questions không cập nhật `skill_mastery` và `question_stats`.

**Câu hỏi:** Trong thực tế, bài tập của giáo viên trong app dùng linked questions (question bank) hay custom questions nhiều hơn? Nếu chủ yếu là custom → analytics Phase 4 sẽ luôn rỗng dù trigger đã deploy.

---

### Q2 [BLOCKER] `question_stats` PRIMARY KEY là `questions.id` — custom questions không track được

**Schema:** `question_stats.question_id REFERENCES public.questions(id)`

Custom questions chỉ có `assignment_question_id`, không có `questions.id`. Vậy 7-02 (Question Stats trigger) chỉ hoạt động với câu hỏi từ question bank, custom questions bị bỏ qua hoàn toàn.

**Câu hỏi:** Có chấp nhận giới hạn này (phase 7 chỉ track question bank questions) hay cần thiết kế lại `question_stats` để accept `assignment_question_id` thay vì `question_id`?

---

### Q3 [RISK] Unanswered questions được insert với `final_score = 0` — trigger sẽ đếm sai

**Code tìm thấy** (`submitAssignment()` step 2.5): câu bỏ trống được INSERT vào `submission_answers` với `final_score = 0`.

Nếu trigger D-01 chạy với condition `WHERE final_score IS NOT NULL` → câu bỏ trống (`final_score = 0`) vẫn đáp ứng vì `0 IS NOT NULL`.

**Hậu quả:** Học sinh bỏ trống câu → trigger vẫn đếm `attempts++` và `is_correct = false` → làm giảm `mastery_level` không công bằng.

**Câu hỏi:** Trigger có nên dùng `WHERE final_score IS NOT NULL AND answer != '{"selected_choice_ids":[]}'::jsonb` để bỏ qua câu trống? Hay accept việc bỏ trống = sai?

---

### Q4 [RISK] Trigger 7-01 chỉ fire trên INSERT — grade override là UPDATE, không được cập nhật

**Context nói:** "Trigger đảm bảo mọi code path (submit, re-grade, override)".
**Thực tế:** Schema trigger thường là `AFTER INSERT ON submission_answers`.

Nhưng grade override (`grade_overrides` table) không INSERT vào `submission_answers` — nó INSERT vào `grade_overrides` rồi UPDATE `submission_answers.final_score`. Trigger INSERT sẽ không fire khi override.

**Câu hỏi:** Trigger skill_mastery có cần thêm `AFTER UPDATE OF final_score ON submission_answers`? Hay cần trigger riêng trên `grade_overrides` INSERT? Cần quyết định rõ để tránh skill_mastery không cập nhật khi giáo viên chỉnh điểm.

---

### Q5 [CLARIFY] `work_sessions.status = 'submitted'` có còn tồn tại sau 7-11b không?

**Hiện tại:** submitAssignment() luôn set `status = 'submitted'`.
**Sau 7-11b:** Khi AI TẮT → set `status = 'graded'` ngay. Khi AI BẬT → set `status = 'ai_processing'`.

`submitted` trở nên vô nghĩa cho MCQ (vì MCQ auto-grade xong ngay). Nhưng `submitted` vẫn cần cho essay (khi Phase 3 re-enable).

**Câu hỏi:** Có giữ `submitted` như trạng thái trung gian không? Hay trong Phase 7 flow, MCQ sẽ không bao giờ ở `submitted` nữa (nhảy thẳng `in_progress → ai_processing/graded`)?

---

## Wave 2 — Core Flutter (7-03, 7-04, 7-10a, 7-11b)

### Q6 [BLOCKER] `submission_analytics.metrics.time_per_question` không thể tính từ data hiện tại

**Quan sát:** `autosave_answers` chỉ có `updated_at` (thời điểm save cuối). Không có timestamp khi học sinh bắt đầu/kết thúc từng câu. `work_sessions.time_spent_seconds` là TỔNG thời gian, không phải per-question.

**Hậu quả:** `time_per_question` trong metrics không thể tính chính xác — chỉ có thể ước tính (total / số câu) hoặc bỏ qua field này.

**Câu hỏi:** 7-03 có nên bỏ `time_per_question` (không có data) và chỉ lưu `accuracy_by_tag` + `difficulty_vs_score`? Hay tính rough estimate = `time_spent_seconds / question_count`?

---

### Q7 [BLOCKER] `accuracy_by_tag` cần tag của câu hỏi — tag ở đâu?

**Schema:** `questions` table không có `tags` column. `learning_objectives` có `subject_code` và `code` nhưng không có tags tự do.

`accuracy_by_tag` trong metrics cần nhóm câu hỏi theo tag để tính accuracy. Nhưng không rõ "tag" ở đây là `learning_objectives.subject_code`, custom tags, hay `learning_objectives.code`.

**Câu hỏi:** `accuracy_by_tag` trong `submission_analytics` grouping theo cái gì? `learning_objectives.subject_code`? `learning_objectives.code`? Hay bỏ qua field này trong Phase 7?

---

### Q8 [BLOCKER] Push notification trong 7-04 — hạ tầng chưa tồn tại

**Tìm thấy trong code:** Tất cả notification UI đều là `// TODO: Implement notifications`. Không có FCM/firebase_messaging trong `pubspec.yaml`. Không có device_token storage.

**Hậu quả:** 7-04 nếu implement push notification sẽ cần: (1) thêm firebase_messaging dependency, (2) xin quyền notification, (3) lưu device token, (4) Edge Function hoặc Supabase pgnet để gửi push. Đây là feature lớn, không phải 1 task nhỏ.

**Câu hỏi:** 7-04 có thực sự cần push notification? Hay chỉ cần:
- Verify grade override được lưu đúng vào DB
- Hiển thị thông báo in-app (snackbar/badge) khi học sinh vào app

Nếu muốn push thật, cần tách thành task riêng với scope rõ ràng hơn.

---

### Q9 [RISK] `SubmissionStatus` enum — unknown values fall back to `draft` silently

**Tìm thấy trong code** (`submission.g.dart:15`):
```dart
$enumDecodeNullable(_$SubmissionStatusEnumMap, json['status']) ?? SubmissionStatus.draft
```

Khi DB trả về `ai_processing` hoặc `pending_review` (sau 7-11a deploy) nhưng Flutter chưa có enum values này (7-11b chưa release), submission sẽ hiển thị `draft` thay vì báo lỗi.

**Hậu quả thực tế:** Học sinh nộp bài xong, status hiện "bản nháp" thay vì "đang xử lý". Giáo viên thấy bài như chưa nộp.

**Câu hỏi:** 7-11a (DB migration) và 7-11b (Flutter enum) có cần deploy CÙNG LÚC không? Nếu deploy DB trước mà Flutter chưa update → silent wrong data. Có nên giữ nguyên logic hiện tại (`ai_processing` → `graded` ngay) cho đến khi 7-11b release?

---

### Q10 [CLARIFY] `submitAssignment()` đọc `assignment_distributions` nhưng chưa lấy `settings`

**Code hiện tại:**
```dart
final distributionFuture = _client
    .from('assignment_distributions')
    .select('due_at, allow_late, late_policy')  // ← không có 'settings'
    .eq('id', distributionId)
    .maybeSingle();
```

7-11b cần đọc `settings['ai_feedback_enabled']` nhưng query không fetch `settings`.

**Câu hỏi:** Đây chỉ cần thêm `settings` vào `.select()` — không phải vấn đề lớn. Nhưng cần nhớ khi plan 7-11b. Confirm: chỉ cần sửa query string thêm `, settings` là đủ?

---

## Wave 3 — AI Infrastructure + UAT (7-05, 7-06, 7-07, 7-10b)

### Q11 [CLARIFY] AI Recommendations (7-07) — CÓ 2 luồng recommendation khác nhau

**Tìm thấy trong code** (`recommendation_datasource.dart`):
- Line 23: `.eq('teacher_id', teacherId)` → recommendations cho **giáo viên** (intervention alerts)
- Line 56: `.eq('student_id', studentId)` → recommendations cho **học sinh** (học tập tab)

**Schema `ai_recommendations`:**
```sql
teacher_id  uuid  -- GV nhận đề xuất (intervention cho cả lớp)
student_id  uuid  -- HS nhận đề xuất (học tập cá nhân)
```

**Câu hỏi:** 7-07 cần INSERT 2 loại records:
- Type "individual" với `student_id` → hiện trong tab "Học tập" của học sinh
- Type "class" với `teacher_id` → hiện trong teacher dashboard (intervention)

Hay chỉ INSERT 1 loại? Cần xác định để 7-07 INSERT đúng fields, nếu không Phase 5 và Phase 4 analytics đều không thấy data.

---

### Q12 [BLOCKER] 7-07 Recommendations trigger — chain dài từ submit đến generate

**Flow hiện tại:**
```
submit → INSERT submission_answers → trigger 7-01 UPDATE skill_mastery
                                   → trigger 7-02 UPDATE question_stats
       → Flutter INSERT submission_analytics (7-03)
       
       →→ ? Ai trigger recommendations generation?
```

Context nói "trigger sau khi student_skill_mastery UPDATE". Nhưng `skill_mastery` được update bởi PostgreSQL trigger. Để trigger recommendations từ DB trigger → cần DB trigger gọi Edge Function hoặc dùng Supabase Realtime.

Gọi Edge Function từ PostgreSQL trigger = `pg_net` extension (có sẵn trong Supabase). Nhưng đây là additional complexity.

**Câu hỏi:** 7-07 recommendations generate theo cách nào?
- **Option A:** Rule-based Flutter call: sau khi submit, Flutter tự tính + INSERT recommendations
- **Option B:** Edge Function gọi từ Supabase cron (batch, không realtime)
- **Option C:** pg_net trong DB trigger gọi Edge Function sau skill_mastery update (realtime nhưng phức tạp)

Quyết định này ảnh hưởng scope 7-07 rất nhiều.

---

### Q13 [CLARIFY] `get_class_average_skill_mastery` RPC — chưa tồn tại trong DB

**Tìm thấy:**
- `analytics_providers.dart:160`: `// TODO(REC-03): Implement RPC call to get_class_average_skill_mastery`
- Không tìm thấy function này trong bất kỳ file migration nào.

**Câu hỏi:** `get_class_average_skill_mastery` cần được tạo trong 7-09 (Phase 5 VERIFICATION closure). Confirm đây là RPC mới hoàn toàn cần viết SQL + deploy, không phải RPC đã có đâu đó?

---

### Q14 [CLARIFY] 7-10a Filter by Status — bug ở đâu chính xác?

Context nói "code bug, không phải data-dependent". Nhưng không mô tả bug cụ thể.

**Cần xác định:**
- Filter "Chỉ đợi chấm" dùng `work_sessions.status = 'submitted'`?
- Filter "Nộp muộn" dùng `submissions.is_late = true`?
- Bug có phải là query filter sai column, hay UI filter chip không apply đúng state?

**Câu hỏi:** Khi plan 7-10a, cần investigate trước: đọc `submission_datasource.dart` filter logic + `submission_list_item.dart` để xác định root cause trước khi fix.

---

## Wave 4 — AI Features (7-08, 7-09)

### Q15 [BLOCKER] Edge Function 7-05 "skeleton" — có thực sự gọi Claude API không?

Context nói "skeleton với `DRY_RUN=true` — log payload nhưng không gọi API".

Nhưng 7-08 (AI Feedback cho MCQ) cần Edge Function xử lý `feedback` request_type. Nếu 7-05 là DRY_RUN thì 7-08 cũng chỉ là DRY_RUN — không có AI feedback thật.

**Câu hỏi:** Mục tiêu Phase 7 cho 7-08: (a) deploy thật với Claude API key và có feedback thực? hay (b) chỉ build infrastructure + dry-run?

Nếu (a) thì cần Claude API key trong Supabase secrets — đây là prerequisite cần chuẩn bị.

---

### Q16 [CLARIFY] 7-08 AI Feedback — kết quả lưu ở đâu và đọc từ đâu trong Flutter?

**Schema có:** `submission_answers.ai_feedback` (jsonb) và `ai_evaluations` table riêng.

Context không nói rõ sau khi Edge Function chạy xong:
1. Kết quả lưu vào `submission_answers.ai_feedback` hay `ai_evaluations`?
2. Flutter đọc feedback từ đâu để hiển thị cho học sinh?
3. Có provider nào hiện tại đọc `ai_feedback` từ `submission_answers` không?

**Câu hỏi:** Xác định write path (Edge Function → lưu vào table nào) và read path (Flutter UI hiển thị feedback từ đâu) trước khi plan 7-08.

---

### Q17 [CLARIFY] Sau khi Edge Function chạy xong — ai update `work_sessions.status`?

**Flow 7-11:**
```
submit → work_sessions.status = 'ai_processing'
→ Edge Function chạy
→ Edge Function xong → status = 'graded' (hoặc 'pending_review' nếu ai_require_review = true)
```

Nhưng Edge Function là server-side Deno code. Nó cần quyền UPDATE `work_sessions` table. Cần Supabase service role key trong Edge Function.

**Câu hỏi:** Edge Function có được cấp service role key không? Hay chỉ dùng anon key (không có quyền UPDATE `work_sessions` qua RLS)?

---

## Wave 5 — UI Polish (7-12)

### Q18 [RISK] 7-12 — "Chờ duyệt AI" filter trong Teacher Submission List

**Context nói:** "Tab hoặc filter mới trong Teacher Submission List: 'Chờ duyệt AI'".

Submission List hiện tại có filter chips. Thêm filter `pending_review` vào đây ảnh hưởng đến UI hiện tại.

**Câu hỏi:** `pending_review` filter là chip thêm vào filter bar hiện có (như "Chờ chấm", "Đã chấm")? Hay tab riêng? Cần xem UI hiện tại của Submission List trước khi quyết định.

---

## Câu hỏi tổng quát Phase 7

### Q19 [CLARIFY] Khi nào `work_sessions.attempt` > 1? Trigger 7-01 xử lý re-attempts thế nào?

Schema có `work_sessions.attempt` nhưng UI hiện tại có cho phép học sinh làm lại không? Nếu có, trigger INSERT vào `submission_answers` lần 2 → `skill_mastery.attempts` tăng tiếp (đúng). Nhưng `question_stats.total_attempts` cũng tăng — đây là intended behavior?

---

### Q20 [CLARIFY] `ai_queue` hiện chỉ có `submission_answer_id` — 7-08 `feedback` request cần thêm data gì vào `payload`?

**Schema:** `ai_queue.payload` jsonb — hiện tại mẫu có `question_text`, `answer_text`, `rubric`, `max_points`.

Cho MCQ feedback, AI cần: câu hỏi, các lựa chọn, đáp án đúng, câu trả lời HS. Nhưng `ai_queue` chỉ link tới `submission_answer_id` — Edge Function cần JOIN nhiều bảng để lấy đủ context.

**Câu hỏi:** `payload` có nên được pre-populated khi INSERT vào `ai_queue` (Flutter side)? Hay để Edge Function tự JOIN khi xử lý? Pre-populated = ít JOIN nhưng data có thể stale. Tự JOIN = luôn fresh nhưng phức tạp hơn trong Edge Function.

---

### Q21 [RISK] Khi Edge Function update `work_sessions.status` → Flutter UI có tự refresh không?

**Flow:**
```
Flutter submit → status = 'ai_processing' → UI hiện "Đang xử lý..."
Edge Function chạy xong → UPDATE work_sessions.status = 'graded'
→ Flutter UI có biết không?
```

**Tìm thấy:** `supabase_datasource.dart` có Realtime subscription infrastructure (`subscribe()`/`unsubscribe()`). Nhưng hiện tại KHÔNG có subscription nào trên `work_sessions`.

**Hậu quả nếu không handle:** Học sinh nộp bài, thấy "Đang xử lý..." mãi mãi dù AI đã xong. Phải thoát app và vào lại mới thấy điểm.

**Câu hỏi:** 7-12 hoặc 7-11b có cần thêm Realtime subscription cho `work_sessions` table không? Hay chỉ cần pull-to-refresh / timer poll là đủ trong Phase 7?

---

*Tổng: 21 câu hỏi | 6 BLOCKER | 9 CLARIFY | 6 RISK*
*Tạo: 2026-04-08*

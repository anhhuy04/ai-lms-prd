# Phase 7: AI Analytics Pipeline — Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Đảm bảo pipeline dữ liệu từ "học sinh nộp bài" → "analytics có data thực" hoạt động end-to-end.
Build AI queue infrastructure cho tương lai (essay khi re-enable).

**Scope (13 plans, 5 waves):**

```
Wave 1 — DB Foundation (pure SQL, parallel, không cần Flutter changes)
  7-01:  Trigger skill_mastery write pipeline
  7-02:  Trigger question_stats write pipeline
  7-11a: DB Migration — work_sessions.status + distributions.settings JSONB

Wave 2 — Core Flutter (sau Wave 1 deploy, parallel trong wave)
  7-03:  Submission Analytics INSERT (non-blocking trong submitAssignment)
  7-04:  Grade Override + Push Notification
  7-10a: Filter by Status bug fix (độc lập, nhóm vào wave này)
  7-11b: Flutter — SubmissionStatus enum + submit flow AI status + distribute UI toggle

Wave 3 — AI Infrastructure + Data Verification (sau Wave 2, parallel)
  7-05:  AI Queue Edge Function skeleton (Deno)
  7-06:  Phase 4 UAT Closure (skill_mastery có data từ 7-01)
  7-07:  AI Recommendations Pipeline (cần 7-01 + 7-03 data)
  7-10b: Phase 2 UAT Closure — Grade Audit + Override MCQ (cần 7-04 data)

Wave 4 — AI Features + UAT (sau Wave 3, parallel)
  7-08:  AI Feedback cho MCQ (cần 7-05 Edge Function)
  7-09:  Phase 5 UAT + VERIFICATION Closure (cần 7-07 data)

Wave 5 — UI Polish (sau Wave 4)
  7-12:  SubmissionStatus UI Update (cần 7-11b enum + 7-08 statuses working)
```

**Rationale:**
- **Wave 1 trước**: DB triggers + schema deploy ngay → data bắt đầu populate tự động từ lần submit đầu tiên. Zero Flutter breaking changes (chỉ mở rộng CHECK constraint và JSONB).
- **7-11 split**: Schema migration (7-11a) PHẢI deploy trước Flutter code (7-11b) để tránh Flutter set status mới khi DB chưa accept.
- **Wave 3 sau Wave 2**: Edge Function cần biết logic status transitions (7-11b). UAT phases cần có real data từ triggers (7-01 Wave 1).
- **7-12 cuối**: UI badge chỉ có nghĩa khi data thực sự có các status mới (sau 7-08 + 7-11b hoạt động).

**Out of Scope (deferred):**
- Essay AI scoring qua rubric (Phase 3 deferred)
- `ai_evaluations.criteria_scores` UI display
- AI grading screen cho câu tự luận
- RLHF fine-tuning pipeline (future)

</domain>

<decisions>
## Implementation Decisions

### D-01: Skill Mastery Update — PostgreSQL Trigger (không phải Flutter)

**CHỐT: Supabase PostgreSQL trigger trên `submission_answers` INSERT**

- Sau khi INSERT vào `submission_answers` với `final_score != null`:
  1. Lookup `assignment_questions.question_id` → `question_objectives` → `learning_objectives`
  2. Tính `is_correct = (final_score == points)` cho MCQ
  3. UPSERT `student_skill_mastery`: `attempts++`, `correct++` (nếu đúng), `mastery_level = correct/attempts`
- Rationale: Trigger đảm bảo cập nhật ngay cả khi nhiều flow khác nhau (submit, re-grade, override)
- Không dùng Flutter call vì dễ bị miss khi có nhiều code path

### D-02: Question Stats — PostgreSQL Trigger

**CHỐT: Trigger tương tự trên `submission_answers` INSERT**

- UPSERT `question_stats`: `total_attempts++`, `correct_count++` (nếu đúng), `avg_score` recalculate
- Cùng trigger function với D-01 hoặc trigger riêng

### D-03: Submission Analytics — Flutter Call sau Submit

**CHỐT: Gọi từ Flutter trong `submitAssignment()` sau bước 4 (INSERT submissions)**

- Không dùng trigger vì cần `work_sessions.time_spent_seconds` (cross-table join phức tạp)
- Format metrics: `{ "time_per_question": {...}, "accuracy_by_tag": {...} }`
- Nếu fail, log lỗi và tiếp tục — không block submit flow

### D-04: Grade Override Verification + Push Notification

**CHỐT: Verify wiring + thêm push notification**

- `GradeOverrideDataSource.createGradeOverride()` đã đủ
- Kiểm tra `grading_action_buttons.dart` và `teacher_submission_detail_screen.dart` có gọi không
- Nếu teacher override → `grade_overrides` INSERT → trigger recalculate `student_skill_mastery`
- **Mới (từ Phase 6 D-04):** Sau khi INSERT grade_override → push notification đến học sinh: "Giáo viên đã chỉnh điểm câu X: cũ → mới"
- Notification áp dụng cho MỌI loại câu (MCQ + essay), không phân biệt

### D-05: AI Queue Edge Function — Supabase Deno Function

**CHỐT: Supabase Edge Function `process-ai-queue` (Deno TypeScript)**

- Trigger: HTTP POST (có thể gọi từ Supabase cron hoặc Flutter sau submit)
- Xử lý cả 3 request_type:
  - `score`: chấm điểm essay → **DEFER** (chỉ khi Phase 3 re-enable)
  - `feedback`: AI giải thích đáp án MCQ sai/đúng → **INCLUDE** (7-08)
  - `analysis`: AI phân tích patterns → **INCLUDE** (bổ sung cho 7-01 trigger)
- Retry: `attempts` column, max 3 lần (5s → 30s → mark failed)
- **Bây giờ:** skeleton xử lý `feedback` + `analysis`. `score` là stub logging.
- **Khi essay re-enable:** bật `score` processing thật

### D-06: Question Type Filtering cho Skill Mastery

**CHỐT: Chỉ update skill_mastery cho MCQ (multiple_choice, true_false) trong Phase 7**

- Essay/short_answer: `final_score` chưa có (AI chưa chạy) → skip khi null
- MCQ: `final_score` đã có sau submit → update ngay
- Trigger tự nhiên handle việc này: `WHERE final_score IS NOT NULL`

</decisions>

<session_decisions>
## Decisions từ discuss-phase 2026-04-08 (giải quyết 07-QUESTIONS.md)

### Nhóm 1 — DB Triggers & Analytics Scope

**D-07: Custom questions không được track — giới hạn chấp nhận**
- Phase 7 chỉ track questions từ question bank (`assignment_questions.question_id IS NOT NULL`)
- Custom questions (question_id = NULL) skip trigger skill_mastery + question_stats
- Rationale: Custom questions không có learning_objectives → analytics không có ý nghĩa
- Ghi rõ giới hạn trong UI hoặc docs

**D-08: Câu bỏ trống = thất bại (tính vào mastery)**
- `final_score = 0` với `selected_choice_ids = []` → vẫn tính `attempts++`
- Rationale: Tránh survivorship bias — bỏ trống là không biết, phải phản ánh vào Radar Chart
- Trigger condition: `WHERE final_score IS NOT NULL` (0 vẫn là NOT NULL)

**D-09: Trigger AFTER UPDATE cho grade override**
- Thêm trigger `AFTER UPDATE OF final_score ON submission_answers`
- Khi GV override điểm → recalculate mastery_level từ đầu (not incremental)
- Cần: `correct = COUNT WHERE final_score = points`, `attempts = COUNT WHERE final_score IS NOT NULL`

**D-10: submission_analytics metrics — telemetry approach**
- `time_per_question`: Client-side telemetry — workspace gửi `time_log: {"aq_id": seconds}` khi submit
  - Backend validate: `SUM(time_log values) <= time_spent_seconds + tolerance`
  - Nếu valid → lưu vào metrics. Nếu invalid → log warning, lưu null
  - ⚠️ **Scope addition**: Cần sửa workspace screen thêm per-question stopwatch
- `accuracy_by_tag`: Dùng `questions.tags[]` (text array đã có), KHÔNG dùng `learning_objectives.subject_code`
  - JOIN: submission_answers → assignment_questions → questions → tags
  - Tính accuracy per tag → `{"toán": 0.8, "hình học": 0.6}`

**D-11: submitAssignment() settings parsing — null-safe mandatory**
- Thêm `settings` vào `.select()` của distributionFuture query
- Parse bắt buộc null-safe với defaults:
  ```dart
  final aiEnabled = (settings?['ai_feedback_enabled'] as bool?) ?? false;
  final requireReview = (settings?['ai_require_review'] as bool?) ?? true;
  ```
- Hệ lụy 1: work_sessions.status = AI bật → `ai_processing`, AI tắt → `graded` (ngay sau MCQ grade)
- Hệ lụy 2: Khi `aiEnabled = true` → INSERT `feedback` vào ai_queue cho TẤT CẢ câu MCQ

---

### Nhóm 2 — Status Flow & Notifications

**D-12: Giữ 'submitted' ngắn gọn trước khi phân luồng**
- submitAssignment() vẫn set `submitted` như hiện tại
- Ngay sau đó trong cùng transaction/call: update sang `graded` hoặc `ai_processing`
- Đơn giản code hơn, không cần conditional logic cho initial status

**D-13: in_app_notifications table — notification infrastructure (không FCM)**
- Tạo bảng `in_app_notifications` trong DB migration
  ```sql
  CREATE TABLE in_app_notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    type text NOT NULL,          -- 'grade_override', 'ai_graded', ...
    title text NOT NULL,
    body text,
    payload jsonb,
    read_at timestamptz,
    created_at timestamptz DEFAULT now()
  );
  ```
- PostgreSQL trigger trên `grade_overrides` INSERT → INSERT notification cho student
- Flutter Realtime subscription lắng nghe bảng này
- Benefit: Khi thêm FCM sau, chỉ cần Edge Function đọc bảng này, không sửa core code

**D-14: Recommendations — Dual-Channel Pipeline**
- 1 lần phân tích → 2 records INSERT:
  - `student_id` record: mastery < 0.6 → gợi ý tài nguyên học cho học sinh
  - `teacher_id + class_id` record: cả lớp có học sinh yếu → cảnh báo can thiệp cho GV
- Rule-based logic trong Edge Function (async, qua ai_queue)
- Threshold: `mastery_level < 0.6` → generate recommendation

**D-15: Recommendations trigger chain — Edge Function via ai_queue**
- Sau khi DB trigger cập nhật skill_mastery → Flutter INSERT `analysis` request vào ai_queue
- Edge Function xử lý `analysis` → kiểm tra mastery thresholds → INSERT ai_recommendations
- Không dùng Flutter call trực tiếp, không dùng cron — trigger theo submission

**D-16: SubmissionStatus.unknown — graceful degradation**
- Thêm `SubmissionStatus.unknown` vào enum
- JSON parsing: bất kỳ string nào không nhận ra → `unknown`
- UI: `unknown` → badge xám "Đang xử lý hệ thống..." + icon sync
- Cho phép 7-11a deploy trước 7-11b mà không crash

**D-17: Realtime subscription trên work_sessions khi ai_processing**
- Sau khi submit với AI bật, Flutter lắng nghe `work_sessions` row qua Realtime
- Khi status chuyển → `graded`/`pending_review`: refresh UI, hiện điểm/badge
- Dùng infrastructure có sẵn trong `supabase_datasource.dart:subscribe()`

---

### Nhóm 3 — AI Infrastructure

**D-18: Edge Function dùng Analytics AI config động từ profiles.metadata**
- App có **2 config AI riêng biệt** — phải dùng đúng loại:
  - **Analytics AI** (`profiles.metadata.analytics.provider` + `analytics.model`) → **DÙNG CHO PHASE 7**
  - Question generation AI (`profiles.metadata.ai.provider` + `ai.model`) → KHÔNG liên quan
- API key lưu trong `profiles.metadata.api_keys.{provider}` (Gemini/Groq/Ollama — không có Anthropic)
- Flutter: `ApiKeyService.getAnalyticsProvider()` + `ApiKeyService.getAnalyticsModel()`
- Edge Function Deno flow:
  1. Lấy `submission_answer_id` từ ai_queue
  2. JOIN → teacher_id (submission_answers → work_sessions → assignment_distributions → assignments)
  3. Đọc `profiles.metadata` của teacher (service role key):
     - `metadata.analytics.provider` → provider
     - `metadata.analytics.model` → model
     - `metadata.api_keys.{provider}` → api_key
  4. Gọi AI API tương ứng (Gemini/Groq/Ollama)
- Reference files:
  - `lib/core/services/api_key_service.dart:580` — `getAnalyticsProvider()`, `getAnalyticsModel()`
  - `lib/core/services/profile_metadata_service.dart:363` — storage keys `analytics.provider`, `analytics.model`
  - `lib/presentation/views/settings/api_key_setup_screen.dart` — UI cấu hình (section "Phân tích dữ liệu")

**D-19: Feedback write path → submission_answers.ai_feedback**
- Edge Function UPDATE `submission_answers.ai_feedback` sau khi AI trả kết quả
- Column `ai_feedback jsonb` đã có trong schema
- Flutter entity `SubmissionAnswer.aiFeedback` đã có → zero Flutter change để đọc

**D-20: Service role key cho Edge Function**
- Lưu `SUPABASE_SERVICE_ROLE_KEY` vào Supabase secrets
- Edge Function dùng để bypass RLS khi UPDATE work_sessions + đọc profiles.metadata
- Cách chuẩn của Supabase cho server-side operations

**D-21: Edge Function tự JOIN context (không pre-populate payload)**
- ai_queue chỉ có `submission_answer_id`
- Edge Function JOIN: submission_answers → assignment_questions → questions + choices → lấy question_text, choices, student_answer, correct_answer
- Data luôn fresh, không stale payload
- Phức tạp hơn nhưng đúng hơn

---

### Nhóm 4 — Minor Clarifications

**D-22: get_class_average_skill_mastery — tạo trong 7-09**
- SQL function với `SECURITY DEFINER` để bypass RLS
- Input: `p_class_id uuid` → Output: `avg mastery per objective`
- Unblock `analytics_providers.dart:160` TODO

**D-23: Filter by Status bug — fix trong 7-10a**
- Investigate root cause trước khi fix (datasource query hay UI state)
- Target: "Chỉ đợi chấm" và "Nộp muộn" filter hoạt động đúng

**D-24: pending_review UI = badge + filter chip**
- Badge vàng "Chờ duyệt" trên từng submission item
- Filter chip thêm vào bar hiện tại để lọc nhanh
- Cả 2 trong cùng task 7-12

</session_decisions>

<critical_gaps>
## Gaps hiện tại (trước Phase 7)

| Bảng | Tình trạng | Hậu quả |
|------|------------|---------|
| `student_skill_mastery` | Chỉ READ, không bao giờ WRITE | Phase 4 analytics rỗng |
| `question_stats` | Không có code nào đọc/ghi | Bảng không có data |
| `submission_analytics` | Không có code nào tạo record | Phase 5 recommendations thiếu context |
| `ai_queue` worker | Không có Edge Function | Records tồn tại nhưng không được xử lý |
| Grade override UI | Datasource có, UI chưa xác minh | Override có thể không được lưu |

</critical_gaps>

<specifics>
## Specific Ideas

- **Trigger-first approach:** D-01 và D-02 dùng trigger để đảm bảo mọi code path đều cập nhật analytics. Flutter call chỉ dùng khi cần data cross-table phức tạp.
- **Graceful degradation:** Tất cả analytics writes đều non-blocking — nếu fail, submission vẫn thành công.
- **MCQ-first verification:** Test với MCQ ngay sau Phase 7 implement. Essay data pipeline tự hoạt động khi Phase 3 re-enable.
- **Edge Function skeleton pattern:** Deploy function với flag `DRY_RUN=true` — log payload nhưng không gọi API. Dễ bật thật sau.

</specifics>

<canonical_refs>
## Canonical References

### Database Schema
- `db/schema_03_submissions_ai_analytics.sql` — ai_queue, ai_evaluations, grade_overrides, student_skill_mastery, question_stats, submission_analytics
- `db/schema_02_questions_assignments.sql` — assignment_questions, question_objectives

### Existing Code (cần hiểu trước khi implement)
- `lib/data/datasources/assignment_datasource.dart:1073` — `submitAssignment()` — flow submit + ai_queue insert
- `lib/data/datasources/analytics_datasource.dart:241` — READ `student_skill_mastery` — sẽ có data sau Phase 7
- `lib/data/datasources/grade_override_datasource.dart` — Complete datasource, verify UI wiring
- `lib/presentation/views/assignment/teacher/widgets/submission/grading_action_buttons.dart` — UI có thể gọi grade override
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` — Teacher grading UI

### Phase contexts
- `.planning/phases/06-ai-grading/06-CONTEXT.md` — AI queue workflow, ai_evaluations schema, retry logic
- `.planning/phases/04-learning-analytics/` — Analytics screen context
- `.planning/phases/05-personalized-recommendations/` — Recommendations context

</canonical_refs>

<code_context>
## Existing Code Insights

### submitAssignment() — đã làm được gì
- ✅ Auto-grade MCQ, insert `submission_answers` với `final_score`
- ✅ INSERT `ai_queue` cho essay/short_answer (nhưng chưa có worker)
- ❌ Không UPDATE `student_skill_mastery`
- ❌ Không UPDATE `question_stats`
- ❌ Không INSERT `submission_analytics`

### SubmissionAnswer entity
- Đã có: `aiScore`, `aiConfidence`, `aiFeedback`, `finalScore`, `gradedBy`, `gradedAt`
- `finalScore` được ghi cho MCQ, null cho essay

### GradeOverrideDataSource
- `createGradeOverride()` — đầy đủ, cần verify UI có gọi không
- `getOverrideHistory()` — đầy đủ

### AnalyticsDatasource
- READ `student_skill_mastery` với JOIN `learning_objectives` — code đã sẵn sàng
- Sẽ có data ngay sau khi trigger D-01 hoạt động

</code_context>

<phase4_uat_debt>
## Phase 4 UAT Debt — Cần hoàn thành trong Phase 7

Phase 4 UAT còn `status: partial` — 7 tests bị skip. Phase 7 phải close hết các tests này.

### Nhóm A: Blocked bởi thiếu data (sẽ unblock sau 7-01)

| Test | Nội dung | Unblocked bởi |
|------|----------|---------------|
| Test 1 | Radar Chart hiển thị skill mastery | 7-01: skill_mastery write pipeline |
| Test 4 | Strength/Weakness Card từ skill data | 7-01: skill_mastery write pipeline |

→ Sau khi 7-01 xong, submit MCQ → có data → re-test Test 1 + 4

### Nhóm B: Navigation/UI fixes — code đã sửa nhưng CHƯA RE-TEST với app

| Test | Nội dung | Fix đã làm (chưa verify) |
|------|----------|--------------------------|
| Test 1b Path C | Lớp học → Tiến độ học tập → Analytics với classId | `app_router.dart` + `student_analytics_screen.dart` |
| Test 8 | Teacher - Class Overview Card | Phụ thuộc navigation test 7 (đã fix) |
| Test 9 | Teacher - Top/Bottom Performers Lists | Phụ thuộc navigation test 7 (đã fix) |
| Test 11 | Teacher navigation từ Dashboard + Class Detail | Navigation fix trong `class_settings_drawer.dart` |
| Test 12 | Shimmer loading trên TeacherAnalyticsScreen | Cần re-test sau nav fix |

→ Nhóm B cần **re-test trong app** — code đã sửa, chưa verify chạy đúng

### 7-06: Phase 4 UAT Closure

Thêm vào scope Phase 7:
- **7-06: Re-test Phase 4 UAT** — sau khi 7-01 done + có data, run lại 7 tests còn lại
- Nếu phát hiện bug trong nhóm B → fix và re-verify

</phase4_uat_debt>

<phase5_uat_debt>
## Phase 5 UAT Debt + Gaps — Cần hoàn thành trong Phase 7

### Gap: ai_recommendations không bao giờ được INSERT

Phase 5 chỉ **READ** từ `ai_recommendations` table. Không có code nào tạo recommendations.
- UAT passed nhờ seed data tay — production sẽ luôn rỗng
- Cần: sau khi `skill_mastery` + `submission_analytics` có data → generate recommendations

**7-07: AI Recommendations Generation Pipeline**
- Input: `student_skill_mastery` (skill gaps) + `submission_analytics` (patterns)
- Logic: Học sinh có mastery < 0.6 → INSERT `ai_recommendations` cho teacher (intervention)
- Logic: Học sinh có accuracy thấp theo tag → INSERT `ai_recommendations` cho student (learning resource)
- Trigger: Sau khi `student_skill_mastery` UPDATE (cuối flow submit)
- Dùng Claude API qua Edge Function hoặc simple rule-based trigger nếu chưa muốn gọi AI

### Phase 5 Tests còn debt

| Test | Nội dung | Blocked bởi |
|------|----------|-------------|
| Test 7 | PeerComparisonBadge — `get_student_peer_comparison` RPC | Thiếu real submission data (7-01 sẽ fix) |
| Test 8 | Student "Học tập" tab không hiện | Plan 05-04 chưa implement |

**7-09: Phase 5 UAT + VERIFICATION Closure**
- 7-09a: Sau 7-01 có real data → re-test Test 7 PeerComparisonBadge (`get_student_peer_comparison` RPC cần real data)
- 7-09b: Plans 05-04/05-05 đã implement (VERIFICATION xác nhận "Học tập" section tồn tại) → chỉ re-test với data thực
- 7-09c: Fix 3 Phase 5 VERIFICATION gaps:
  - Standalone route: thêm `StudentRecommendationsTab` vào STUDENT STANDALONE ROUTES trong `app_router.dart`
  - Dismiss bug: dời `ref.invalidate(top3RecommendationsProvider)` vào trong `if (success)` block tại `recommendation_providers.dart:241`
  - REC-03 class avg: implement `get_class_average_skill_mastery` RPC trong DB migration + update `classAverageSkillMasteryProvider` (phụ thuộc 7-01 data)

</phase5_uat_debt>

<phase2_uat_debt>
## Phase 2 UAT Debt — Cần hoàn thành trong Phase 7

Phase 2 UAT có 4 tests bị skip còn debt.

| Test | Nội dung | Action trong Phase 7 |
|------|----------|----------------------|
| Test 2 | Filter by Status "Chỉ đợi chấm" / "Nộp muộn" | **7-10a** — code bug, không phải data-dependent |
| Test 7 | Grade Audit Trail — lịch sử override | **7-10b** — re-test sau khi 7-04 có override data |
| Test 8 | Override MCQ score (phần không cần AI) | **7-10c** — re-test "Sửa điểm" cho MCQ sau 7-04 |
| Test 5 | AI Confidence Indicator | **DEFER** — cần essay AI data |

**7-10: Phase 2 UAT Closure**
- 7-10a: Điều tra + fix Filter by Status — xác định data source đúng cho filter chip
- 7-10b: Re-test Grade Audit Trail (lịch sử override hiển thị đúng) sau 7-04
- 7-10c: Re-test Override score cho MCQ sau 7-04

</phase2_uat_debt>

<ai_grading_db>
## 7-11a: DB Migration — AI Grading Status Foundation (Wave 1)

> **Chạy đầu tiên, trước mọi Flutter code.** Pure SQL — không cần build_runner.

### 1. Mở rộng CHECK constraint `work_sessions.status`

```sql
ALTER TABLE public.work_sessions
  DROP CONSTRAINT work_sessions_status_check;

ALTER TABLE public.work_sessions
  ADD CONSTRAINT work_sessions_status_check
  CHECK (status IN ('in_progress', 'submitted', 'ai_processing', 'pending_review', 'graded'));
```

**Zero breaking changes:** Chỉ thêm giá trị mới. Code hiện tại dùng `submitted`/`graded` vẫn chạy bình thường.

### 2. Thêm 2 fields vào `assignment_distributions.settings` JSONB

Không cần migration SQL — JSONB tự mở rộng. Chỉ cần cập nhật logic đọc trong Flutter (7-11b):

```json
{
  "shuffle_questions": false,
  "shuffle_choices": false,
  "show_score_immediately": true,
  "student_review_mode": "full_review",
  "ai_feedback_enabled": false,
  "ai_require_review": true
}
```

| Field | Default | Ý nghĩa |
|-------|---------|---------|
| `ai_feedback_enabled` | `false` | Toggle chính AI phân tích |
| `ai_require_review` | `true` | Sub-setting: chờ teacher duyệt trước khi công bố |

### File cần tạo

`db/migrations/007_work_sessions_ai_status.sql` — chứa ALTER TABLE trên.

</ai_grading_db>

<ai_grading_toggle>
## 7-11b: Flutter — AI Grading Toggle & Auto-grade Workflow (Wave 2)

### Tình huống người dùng

**AI TẮT (mặc định):**
- Học sinh nộp bài → MCQ tự động chấm → `work_sessions.status = 'graded'` → điểm hiển thị ngay
- Không có AI phân tích, không có feedback AI
- Giáo viên vẫn có thể bật AI retroactively qua nút "Chạy AI" trong submission list

**AI BẬT + Không cần duyệt:**
- Học sinh nộp bài → MCQ tự động chấm → `status = 'ai_processing'` → AI chạy ngầm → phân tích + viết feedback → `status = 'graded'` → điểm hiển thị

**AI BẬT + Chờ giáo viên duyệt:**
- Học sinh nộp bài → MCQ tự động chấm → `status = 'ai_processing'` → AI chạy ngầm → `status = 'pending_review'` → giáo viên vào xem AI analysis + approve/edit → `status = 'graded'`

---

### Schema Changes

#### 1. Bảng `work_sessions` — Mở rộng CHECK constraint của `status`

> **Lý do KHÔNG dùng `submissions.grading_status`:**
> `submission_datasource.dart` đọc status **100% từ `work_sessions.status`** (submissions không có status column).
> Thêm column mới vào submissions tạo 2 nguồn sự thật → code hiện tại không đọc, phải sync thủ công.
> Mở rộng `work_sessions.status` = zero breaking changes, tất cả code tự động nhận giá trị mới.

```sql
-- Migration: mở rộng CHECK constraint
ALTER TABLE public.work_sessions
  DROP CONSTRAINT work_sessions_status_check;

ALTER TABLE public.work_sessions
  ADD CONSTRAINT work_sessions_status_check
  CHECK (status IN ('in_progress', 'submitted', 'ai_processing', 'pending_review', 'graded'));
```

| Status | Ý nghĩa |
|--------|---------|
| `in_progress` | Học sinh đang làm bài |
| `submitted` | Vừa nộp xong — chờ xử lý |
| `ai_processing` | AI đang chạy ngầm |
| `pending_review` | AI xong, chờ teacher duyệt |
| `graded` | Điểm đã công bố — học sinh thấy được |

#### 2. `assignment_distributions.settings` JSONB — Thêm 2 fields

Field `ai_feedback_enabled` đã có trong schema comment nhưng chưa implement. Thêm `ai_require_review`:

```json
{
  "shuffle_questions": false,
  "shuffle_choices": false,
  "show_score_immediately": true,
  "student_review_mode": "full_review",
  "ai_feedback_enabled": false,
  "ai_require_review": true
}
```

- `ai_feedback_enabled`: toggle chính — bật/tắt AI phân tích
- `ai_require_review`: sub-setting (chỉ active khi `ai_feedback_enabled = true`) — bật = chờ teacher duyệt, tắt = auto-publish sau AI

---

### UI Components

#### A. Distribution Settings Screen (Teacher khi phát bài)

Thêm vào màn hình cấu hình phát bài (`distribute_assignment` flow):

```
┌─────────────────────────────────────────┐
│  AI Phân tích bài làm          [○ Tắt] │  ← SwitchListTile (ai_feedback_enabled)
│                                          │
│  ▼ (khi bật, expand animation)          │
│  ┌───────────────────────────────────┐  │
│  │ Chờ giáo viên duyệt trước khi    │  │
│  │ công bố điểm          [● Bật]    │  │  ← SwitchListTile con (ai_require_review)
│  │                                   │  │
│  │ Khi tắt: AI phân tích xong →     │  │
│  │ tự động công bố điểm             │  │  ← Helper text thay đổi theo toggle
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

- Dùng `AnimatedCrossFade` hoặc `AnimatedSize` để expand/collapse sub-section
- Sub-section có indent + màu background nhạt hơn để thể hiện phân cấp

#### B. Teacher Submission List — Thêm status badge + nút "Chạy AI"

> **Lưu ý:** Status đọc từ `work_sessions.status` (qua JOIN) — KHÔNG dùng `submissions.grading_status`.
> `SubmissionStatus` enum sẽ được mở rộng thêm `aiProcessing`, `pendingReview`.

- Badge trạng thái theo `work_sessions.status`:
  - `submitted` → xám: "Chờ chấm"
  - `ai_processing` → xanh nhấp nháy: "AI đang xử lý..."
  - `pending_review` → vàng: "Chờ duyệt"
  - `graded` → xanh lá: "Đã công bố"
- Nút "Chạy AI" (icon: auto_awesome) hiện khi `status = 'submitted'` + `ai_feedback_enabled = true` trong distribution settings → trigger retroactive AI grading

#### C. Student Side — Trạng thái bài nộp

- Khi `work_sessions.status = 'submitted'`: "Đã nộp, chờ chấm"
- Khi `work_sessions.status = 'ai_processing'`: "Đang chấm tự động..."
- Khi `work_sessions.status = 'pending_review'`: "Đang chờ giáo viên xét duyệt"
- Khi `work_sessions.status = 'graded'`: hiện điểm

#### D. Teacher Review Queue (khi `work_sessions.status = 'pending_review'`)

- Tab hoặc filter mới trong Teacher Submission List: "Chờ duyệt AI"
- Xem AI feedback, analysis → nút "Duyệt & Công bố" hoặc "Sửa điểm → Công bố"

---

### Submit Flow Changes

Trong `assignment_datasource.dart → submitAssignment()`:

**Bước 4 (UPDATE work_sessions.status) — thêm logic AI status:**
```dart
// Đọc settings từ distribution
final aiEnabled = settings['ai_feedback_enabled'] as bool? ?? false;

// Tính status ban đầu sau khi nộp
final String newStatus = aiEnabled ? 'ai_processing' : 'graded';
// AI tắt → MCQ đã auto-grade → 'graded' luôn
// AI bật → chờ xử lý → 'ai_processing'

// UPDATE work_sessions.status (KHÔNG thêm column vào submissions)
await _client.from('work_sessions').update({
  'status': newStatus,
}).eq('id', sessionId);
```

**Bước 5 (INSERT ai_queue) — chỉ khi aiEnabled:**
- Hiện tại chỉ queue essay/short_answer → vẫn giữ
- Thêm: queue `feedback` request cho TẤT CẢ câu khi `ai_feedback_enabled = true`

---

### Retroactive AI Trigger

Button "Chạy AI" trong Teacher Submission List:
```dart
// Gọi Edge Function trực tiếp với submission_id
await supabase.functions.invoke('process-ai-queue', body: {
  'submission_id': submissionId,
  'retroactive': true,
});
// Cập nhật UI: work_sessions.status → 'ai_processing'
```

---

### Files cần modify

| File | Action |
|------|--------|
| `db/` | Migration mở rộng CHECK constraint `work_sessions.status` |
| `lib/domain/entities/submission.dart` | Thêm enum values `aiProcessing`, `pendingReview` vào `SubmissionStatus` |
| `lib/data/datasources/assignment_datasource.dart:submitAssignment()` | UPDATE `work_sessions.status` sau submit dựa trên `ai_feedback_enabled` |
| `lib/presentation/providers/distribute_assignment_notifier.dart` | Đọc + lưu `ai_feedback_enabled` + `ai_require_review` |
| `lib/presentation/views/assignment/distribute/` | UI toggle + sub-setting |
| Teacher Submission List (`submission_list_item.dart`) | Status badge theo mới `aiProcessing`/`pendingReview` + nút "Chạy AI" |
| Student submission status screen | Hiện trạng thái `aiProcessing`/`pendingReview`/`graded` |

</ai_grading_toggle>

---

## 7-12: SubmissionStatus UI Update

> **Thực hiện SAU 7-08 + 7-11** — cần các status mới thực sự tồn tại trong DB trước khi update UI.

### Mục tiêu

Mở rộng `SubmissionStatus` enum + update tất cả UI screens hiển thị trạng thái bài nộp.

### Schema change (đã làm ở 7-11)

```sql
ALTER TABLE public.work_sessions
  DROP CONSTRAINT work_sessions_status_check;
ALTER TABLE public.work_sessions
  ADD CONSTRAINT work_sessions_status_check
  CHECK (status IN ('in_progress', 'submitted', 'ai_processing', 'pending_review', 'graded'));
```

### Flutter changes

**1. `lib/domain/entities/submission.dart` — mở rộng enum:**
```dart
enum SubmissionStatus {
  draft,
  submitted,
  aiProcessing,      // ← MỚI: AI đang xử lý
  pendingReview,     // ← MỚI: Chờ giáo viên duyệt
  graded,
}
```

**2. Files cần update badge/text:**

| File | Thay đổi |
|------|---------|
| `lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart` | Thêm badge `aiProcessing` (xanh nhấp nháy) + `pendingReview` (vàng) + nút "Chạy AI" khi `submitted` + AI enabled |
| `lib/presentation/views/assignment/teacher/widgets/ass_hub/recent_activity_item.dart` | Thêm text/icon cho 2 status mới |
| `lib/presentation/views/assignment/teacher/widgets/grading_hub/class_bottom_sheet.dart` | Thêm filter/tab "Chờ duyệt AI" khi có `pendingReview` |
| Student submission status screen (xác định file khi plan) | Text: `aiProcessing` → "Đang chấm tự động...", `pendingReview` → "Đang chờ giáo viên xét duyệt" |

**3. Cần chạy `build_runner`** sau khi sửa enum (Freezed regenerate).

<deferred>
## Deferred Ideas

- **RLHF Pipeline:** Thu thập grade overrides để fine-tune model — future
- **Real-time analytics:** Push notification khi skill_mastery thay đổi — future
- **Student feedback on AI grades:** Học sinh phản hồi về điểm AI — future
- **AI grading cho essay:** Phase 3 re-enable + Edge Function DRY_RUN=false
- **Rubric criteria scores display:** `ai_evaluations.criteria_scores` → `ReadOnlyRubricViewer(selectedLevels:)`

</deferred>

---

*Phase: 07-ai-analytics-pipeline*
*Context gathered: 2026-04-08*

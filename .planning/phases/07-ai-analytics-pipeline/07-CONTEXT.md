# Phase 7: AI Analytics Pipeline — Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Đảm bảo pipeline dữ liệu từ "học sinh nộp bài" → "analytics có data thực" hoạt động end-to-end.
Build AI queue infrastructure cho tương lai (essay khi re-enable).

**Scope:**
- 7-01: Skill Mastery Write Pipeline
- 7-02: Question Stats Write Pipeline
- 7-03: Submission Analytics Generation
- 7-04: Grade Override End-to-End Verification + Push Notification
- 7-05: AI Queue Edge Function (infrastructure skeleton — score/feedback/analysis)
- 7-06: Phase 4 UAT Closure (7 tests còn skip)
- 7-07: AI Recommendations Generation Pipeline (INSERT vào `ai_recommendations`)
- 7-08: AI Feedback cho MCQ (`feedback` request_type — giải thích đáp án sai/đúng)
- 7-09: Phase 5 UAT + VERIFICATION Closure
- 7-10: Phase 2 UAT Closure
- 7-11: AI Grading Toggle & Auto-grade Workflow

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

<ai_grading_toggle>
## 7-11: AI Grading Toggle & Auto-grade Workflow

### Tình huống người dùng

**AI TẮT (mặc định):**
- Học sinh nộp bài → MCQ tự động chấm → `grading_status = 'published'` → điểm hiển thị ngay
- Không có AI phân tích, không có feedback AI
- Giáo viên vẫn có thể bật AI retroactively qua nút "Chạy AI" trong submission list

**AI BẬT + Không cần duyệt:**
- Học sinh nộp bài → MCQ tự động chấm → `grading_status = 'ai_processing'` → AI chạy ngầm → phân tích + viết feedback → `grading_status = 'published'` → điểm hiển thị

**AI BẬT + Chờ giáo viên duyệt:**
- Học sinh nộp bài → MCQ tự động chấm → `grading_status = 'ai_processing'` → AI chạy ngầm → `grading_status = 'pending_review'` → giáo viên vào xem AI analysis + approve/edit → `grading_status = 'published'`

---

### Schema Changes

#### 1. Bảng `submissions` — Thêm `grading_status`

```sql
ALTER TABLE public.submissions
  ADD COLUMN grading_status text NOT NULL DEFAULT 'pending'
  CHECK (grading_status IN ('pending', 'ai_processing', 'pending_review', 'published'));
```

| Status | Ý nghĩa |
|--------|---------|
| `pending` | Mới nộp, AI tắt — chờ teacher grade hoặc đã auto-grade MCQ |
| `ai_processing` | AI đang chạy ngầm |
| `pending_review` | AI xong, chờ teacher duyệt |
| `published` | Điểm đã công bố — học sinh thấy được |

> `work_sessions.status` giữ nguyên ('in_progress' → 'submitted' → 'graded') — track session, không track grading.

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

- Badge trạng thái theo `grading_status`:
  - `pending` → xám: "Chờ chấm"
  - `ai_processing` → xanh nhấp nháy: "AI đang xử lý..."
  - `pending_review` → vàng: "Chờ duyệt"
  - `published` → xanh lá: "Đã công bố"
- Nút "Chạy AI" (icon: auto_awesome) hiện khi `grading_status = 'pending'` + `ai_feedback_enabled = true` trong distribution settings → trigger retroactive AI grading

#### C. Student Side — Trạng thái bài nộp

- Khi `grading_status = 'pending'`: "Đã nộp, chờ chấm"
- Khi `grading_status = 'ai_processing'`: "Đang chấm tự động..."
- Khi `grading_status = 'pending_review'`: "Đang chờ giáo viên xét duyệt"
- Khi `grading_status = 'published'`: hiện điểm

#### D. Teacher Review Queue (khi `grading_status = 'pending_review'`)

- Tab hoặc filter mới trong Teacher Submission List: "Chờ duyệt AI"
- Xem AI feedback, analysis → nút "Duyệt & Công bố" hoặc "Sửa điểm → Công bố"

---

### Submit Flow Changes

Trong `assignment_datasource.dart → submitAssignment()`:

**Bước 4 (INSERT submissions) — thêm logic grading_status:**
```dart
// Đọc settings từ distribution
final aiEnabled = settings['ai_feedback_enabled'] as bool? ?? false;

// Tính grading_status ban đầu
String gradingStatus;
if (!aiEnabled) {
  gradingStatus = 'published'; // AI tắt → công bố ngay (MCQ đã auto-grade)
} else {
  gradingStatus = 'ai_processing'; // AI bật → chờ xử lý
}

// INSERT submissions với grading_status
await _client.from('submissions').insert({
  ...existingFields,
  'grading_status': gradingStatus,
});
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
// Cập nhật UI: grading_status → 'ai_processing'
```

---

### Files cần modify

| File | Action |
|------|--------|
| `db/schema_03_submissions_ai_analytics.sql` | Thêm `grading_status` column + migration |
| `lib/domain/entities/submission.dart` | Thêm `gradingStatus` field |
| `lib/data/datasources/assignment_datasource.dart:submitAssignment()` | Logic grading_status khi submit |
| `lib/presentation/providers/distribute_assignment_notifier.dart` | Đọc + lưu `ai_feedback_enabled` + `ai_require_review` |
| `lib/presentation/views/assignment/distribute/` | UI toggle + sub-setting |
| Teacher Submission List | Status badge + nút "Chạy AI" |
| Student submission status screen | Hiện trạng thái theo grading_status |

</ai_grading_toggle>

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

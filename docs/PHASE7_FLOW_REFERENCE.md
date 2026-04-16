# Phase 7: AI Analytics Pipeline — Flow Reference

> **Metadata**
> - Created: 2026-04-11
> - Version: 1.0
> - Author: Technical Writing (AI LMS PRD)
> - Scope: End-to-end reference cho Phase 7 (AI Analytics Pipeline) — từ student submit đến AI feedback hiển thị
> - Status: Source-of-truth document. Không viết tắt, không tóm lược.

Tài liệu này là **nguồn truth duy nhất** cho Phase 7. Một developer chỉ cần đọc file này là có thể:
1. Trace toàn bộ luồng từ "học sinh nộp bài" đến "AI feedback hiển thị".
2. Biết chính xác file / dòng nào cần sửa khi có bug ở bất kỳ layer nào.
3. Hiểu badge logic mà không cần đọc code.

---

## Quick-Reference Index

| # | Section | Nội dung chính |
|---|---------|----------------|
| 1 | [Route Map](#1-route-map) | Tất cả routes Phase 7 + navigation flows |
| 2 | [Submit Flow (End-to-End)](#2-submit-flow-end-to-end) | 3 layer: UI → Data → Triggers |
| 3 | [DB Triggers & Migrations](#3-db-triggers--migrations) | 4 triggers + schema + RPC |
| 4 | [Edge Function: process-ai-queue](#4-edge-function-process-ai-queue) | Outer loop + 3 handlers + ai_feedback schema |
| 5 | [Provider & State Layer](#5-provider--state-layer) | workspace_provider + teacher_submission_providers |
| 6 | [UI Badge Logic](#6-ui-badge-logic) | Teacher list + Student class detail + History |
| 7 | [Teacher Submission Detail Screen](#7-teacher-submission-detail-screen) | Auto-publish + AI feedback box |
| 8 | [AI Feedback JSON Schema](#8-ai-feedback-json-schema) | 5-field contract + render rules |
| 9 | [API Key Lookup Chain](#9-api-key-lookup-chain) | Student submit → teacher key resolution |
| 10 | [Known Issues & Deferred Work](#10-known-issues--deferred-work) | Bug table + deferred TODOs |
| ★ | [Status Transitions Quick Lookup](#status-transitions-quick-lookup) | Bảng tóm tắt ở cuối file |

---

## 1. Route Map

Các routes liên quan Phase 7 với path, params, role, và navigation method.

| Route name | Path | Role | Nav method | Params |
|------------|------|------|-----------|--------|
| `studentSubmissionHistory` | `/student/submissions/history` | student | `pushNamed` | — |
| `studentAssignmentWorkspace` | `/student/assignment/:id/workspace` | student | `pushNamed` | `distributionId` |
| `teacherSubmissionList` | `/teacher/submissions/:distributionId` | teacher | `pushNamed` | `distributionId` |
| `teacherGradeSubmission` | `/teacher/submission/:submissionId/grade` | teacher | `pushNamed` | `submissionId` |
| `teacherAssignmentDetail` | `/teacher/class/:classId/assignment/:distributionId` | teacher | `pushNamed` | `classId`, `distributionId` |
| `apiKeySetup` | `/settings/api-keys` | both | `pushNamed` | — |
| `studentAnalytics` | `/student/analytics` | student | tab in shell | — |
| `teacherAnalytics` | `/teacher/class/:classId/analytics` | teacher | `pushNamed` | `classId` |

**Source files:**
- `lib/core/routes/route_constants.dart` — route names, paths, RBAC
- `lib/core/routes/app_router.dart` — GoRouter config
- `lib/core/routes/route_guards.dart` — redirect callbacks

### Navigation Flows

**Student submit flow:**
```
StudentClassDetail (bottom sheet list)
  → StudentAssignmentDetail
    → StudentAssignmentWorkspace       (pushNamed, distributionId)
      → [submit] → context.pop()       (quay về detail, status updated)
```

**Student history flow:**
```
StudentAssignmentList
  → StudentSubmissionHistory           (pushNamed — lịch sử nộp bài)
```

**Teacher grading flow:**
```
TeacherAssignmentDetail
  → TeacherSubmissionList(distributionId)     (pushNamed)
    → TeacherGradeSubmission(submissionId)    (pushNamed — chấm 1 submission cụ thể)
```

**Settings flow (cả 2 roles):**
```
(any screen) → apiKeySetup              (pushNamed — cấu hình AI API key)
```

> ⚠️ Route ordering: `specific` routes PHẢI khai báo trước `parameterized` routes.
> Ví dụ đúng: `/student/class/search` declared BEFORE `/student/class/:classId`.

---

## 2. Submit Flow (End-to-End)

Luồng đầy đủ 3 layer theo thứ tự thực thi khi học sinh nhấn "Nộp bài".

### Layer 1 — Flutter UI (`workspace_provider.dart`)

```
User tap "Nộp bài"
  → WorkspaceNotifier.submit()
  → Guard: _isUpdating = true                 (concurrency guard — tránh double-submit)
  → repo.submitAssignment(distributionId, studentId, timeLog)
  → Set local state: WorkspaceSubmissionStatus.submitted
     (không phân biệt graded / ai_processing — UI chỉ biết "đã submit")
  → return true nếu success
```

> ⚠️ **Known gap (C1-UI):** Không có realtime listener. Nếu backend chuyển `ai_processing → graded` trong nền, UI badge "AI đang xử lý" sẽ kẹt cho đến khi user thoát/vào lại screen.

### Layer 2 — Data Layer (`assignment_datasource.dart`, L~1300-1570)

Thứ tự thực thi trong `submitAssignment()`:

#### Step 1 — Fetch context

```
- Fetch work_session row (by session_id)
- Fetch distribution settings JSON:
    settings['ai_feedback_enabled'] as bool? ?? false   → aiEnabled
    settings['ai_require_review']  as bool? ?? true     → requireReview
```

#### Step 2 — Parse questionInfoMap từ `autosave_answers`

```
hasEssay = any question type ∈ {essay, short_answer, fill_blank}
hasMcq   = any question type ∈ {multiple_choice, true_false}
```

#### Step 2a — Grade MCQ + INSERT `submission_answers` (answered questions)

Per answered question:

| Question type | Action |
|---------------|--------|
| MCQ (`multiple_choice`, `true_false`) | `_gradeAnswer()` → `final_score`; INSERT `{session_id, aq_id, answer, final_score}` |
| Essay (`essay`, `short_answer`, `fill_blank`) | INSERT `{session_id, aq_id, answer}` — **KHÔNG set `final_score`** (sẽ do GV hoặc AI chấm sau) |

Đồng thời queue `ai_queue`:

| Condition | Queue item |
|-----------|-----------|
| `needsAIGrading` (essay) | INSERT `ai_queue {request_type='score', status='pending'}` → **deferred stub** (chưa implement) |
| `!needsAIGrading` + `aiEnabled` (MCQ với AI bật) | INSERT `ai_queue {request_type='feedback', status='pending'}` |

#### Step 2b — INSERT empty `submission_answers` (câu bỏ trống)

| Type | Insert |
|------|--------|
| MCQ bỏ trống | `final_score = 0`, `answer = {selected_choice_ids: []}` |
| Essay bỏ trống | `final_score = 0`, `answer = {text: ''}` — ⚠️ **Known issue (L1-DB):** nên là `NULL` cho essay, không phải 0 |

> ⚠️ **L1-DB consequence:** Vì essay bỏ trống có `final_score = 0`, trigger `trg_sa_01_skill_mastery` sẽ ghi nhận "wrong attempt" cho mastery của objective đó — **trước khi GV kịp chấm tay**. Mastery sẽ sai lệch tạm thời. Fix tại `assignment_datasource.dart:1466-1471`.

#### Step 3 — Upsert `submissions` record (CQRS read model)

```
submissions {
  total_score = sum of MCQ final_scores,
  ai_graded   = false,
  submitted_at = now()
}
```

#### Step 4 — UPDATE `work_sessions.status` (Smart Submit Logic)

| `hasEssay` | `aiEnabled` | `work_sessions.status` | Mục đích |
|------------|-------------|------------------------|----------|
| `true`     | any         | `submitted`            | Có essay → chờ GV chấm tay (AI không chạy cho essay ở phase này) |
| `false`    | `true`      | `ai_processing`        | MCQ đã scored, AI feedback đang chạy ngầm |
| `false`    | `false`     | `graded`               | MCQ xong hoàn toàn, không cần AI → release điểm ngay |

> ⚠️ **L5-DB:** `pending_review` là dead code. Essay + AI vẫn set `submitted`, không đi qua `ai_processing` → trạng thái `pending_review` hiện chỉ tồn tại trong enum CHECK constraint nhưng không có code path nào set nó ở submit time. Fix tại `assignment_datasource.dart:1522-1528` — đổi `hasEssay + aiEnabled → 'ai_processing'` nếu muốn AI chấm essay.

#### Step 5 — DELETE `autosave_answers` (cleanup)

Xóa toàn bộ autosave của session này sau khi đã flush vào `submission_answers`.

#### Step 6 — Non-blocking AI trigger (chỉ khi `aiEnabled`)

```
INSERT ai_queue {
  request_type = 'analysis',
  payload      = { session_id: <sessionId> },
  status       = 'pending'
}

unawaited(_triggerAiQueue(sessionId))
  → HTTP POST đến Edge Function /functions/v1/process-ai-queue
  → Body: { session_id: <sessionId> }
  → Fire & forget (không await, không block UI response)
```

#### Step 7 — Non-blocking `_insertSubmissionAnalytics()`

```
- Tính time_per_question từ timeLog param
- Tính accuracy_by_tag từ questions.tags + final_scores
- INSERT submission_analytics row
- Nếu fail → log + continue (không ném lỗi lên UI)
```

### Smart Submit Status Matrix

| `hasEssay` | `aiEnabled` | `work_sessions.status` | Student thấy | Teacher thấy |
|------------|-------------|------------------------|--------------|--------------|
| `true`  | any     | `submitted`       | "Chờ giáo viên chấm" (cam) | "Chờ chấm" (xám) |
| `false` | `true`  | `ai_processing`   | "Đang chấm tự động..." (xanh dương) | "AI đang xử lý..." (xanh dương) |
| `false` | `false` | `graded`          | "Đã chấm" + điểm (xanh lá) | "Đã công bố" + điểm (xanh lá) |

### Layer 3 — Postgres Triggers (tự động sau INSERT `submission_answers`)

Sau mỗi INSERT vào `submission_answers` ở Step 2a/2b, hai triggers chạy tự động:

1. **`trg_sa_01_skill_mastery`** → UPSERT `student_skill_mastery` (xem Section 3 cho guards)
2. **`trg_sa_02_question_stats`** → UPSERT `question_stats`

---

## 3. DB Triggers & Migrations

### Trigger 1: `trg_sa_01_skill_mastery`

| Attribute | Value |
|-----------|-------|
| Bảng | `submission_answers` |
| Event | `AFTER INSERT` |
| File | `db/migrations/007_skill_mastery_trigger.sql` |
| Guards | `final_score IS NOT NULL` (D-06: skip essay chưa chấm) + `question_id IS NOT NULL` (D-07: skip custom questions) |

**Logic:**
```
JOIN question_objectives → learning_objectives
UPSERT student_skill_mastery:
  attempts++
  correct++   IF final_score = points   (strict equality)
  mastery     = correct / attempts
```

> ⚠️ **Known issue:** Partial credit (`final_score < points` nhưng > 0) được tính là **"wrong"**. Không có threshold như "≥70% thì coi là correct" — strict equality only.

### Trigger 2: `trg_sa_02_question_stats`

| Attribute | Value |
|-----------|-------|
| Bảng | `submission_answers` |
| Event | `AFTER INSERT` |
| File | `db/migrations/007_question_stats_trigger.sql` |

**Logic:**
```
UPSERT question_stats:
  total_attempts++
  correct_count++           IF final_score = points
  avg_score = recalc from sum/count
```

> ⚠️ **Known issue (L2-DB):** KHÔNG có `AFTER UPDATE` trigger. Khi GV override điểm qua `grade_overrides`, `question_stats` sẽ **drift mãi mãi** — không được recompute. Fix: thêm AFTER UPDATE OF `final_score` trigger, mirror logic của `trg_sa_update_recalc_mastery`.

### Trigger 3: `trg_sa_update_recalc_mastery`

| Attribute | Value |
|-----------|-------|
| Bảng | `submission_answers` |
| Event | `AFTER UPDATE OF final_score` |
| File | `db/migrations/007_grade_override_recalc_trigger.sql` |

**Logic (D-09 — Full recount):**
```
-- KHÔNG incremental, tính lại từ đầu để tránh drift
correct  = COUNT(*) WHERE final_score = points
attempts = COUNT(*) WHERE final_score IS NOT NULL
mastery  = correct / attempts
```

### Trigger 4: `trg_grade_override_notify`

| Attribute | Value |
|-----------|-------|
| Bảng | `grade_overrides` |
| Event | `AFTER INSERT` |
| File | `db/migrations/007_grade_override_notification_trigger.sql` |

**Logic:**
```
INSERT in_app_notifications {
  user_id: <student_id>,
  type:    'grade_override',
  title:   'Điểm đã được cập nhật',
  body:    'Giáo viên đã chỉnh điểm câu X'
}
```

> ⚠️ **Known issue (C2-SQL):** File thiếu `DROP TRIGGER IF EXISTS` ở dòng 48 trước khi `CREATE TRIGGER`. Re-deploy sẽ fail với "trigger already exists". Fix: thêm `DROP TRIGGER IF EXISTS trg_grade_override_notify ON grade_overrides;` phía trên `CREATE TRIGGER`.

### Schema: `work_sessions.status` CHECK constraint

| Attribute | Value |
|-----------|-------|
| File | `db/migrations/007_work_sessions_ai_status.sql` |
| Valid values | `in_progress` \| `submitted` \| `graded` \| `ai_processing` \| `pending_review` |

### Schema: `in_app_notifications`

| Attribute | Value |
|-----------|-------|
| File | `db/migrations/007_in_app_notifications.sql` |
| Columns | `id, user_id, type, title, body, payload (jsonb), read_at, created_at` |
| RLS SELECT | Chỉ owner (`user_id = auth.uid()`) |
| RLS UPDATE | Chỉ owner (mark as read) |
| RLS INSERT | **KHÔNG cho client** — chỉ qua `SECURITY DEFINER` triggers |

### RPC: `get_class_average_skill_mastery(p_class_id uuid)`

| Attribute | Value |
|-----------|-------|
| File | `db/migrations/007_class_avg_skill_mastery_rpc.sql` |
| Returns | `objective_id, objective_code, objective_description, subject_code, avg_mastery, total_students, students_below_threshold` |
| Dart consumer | `analytics_datasource.dart` |

> ⚠️ Hiện tại Dart consumer **chỉ đọc `objective_id` + `avg_mastery`** — 5 fields còn lại bị discard. Khi implement class analytics UI, nhớ tận dụng `total_students` và `students_below_threshold` để hiển thị "X/Y học sinh chưa đạt".

---

## 4. Edge Function: process-ai-queue

| Attribute | Value |
|-----------|-------|
| File | `supabase/functions/process-ai-queue/index.ts` |
| Deploy | `supabase functions deploy process-ai-queue` |
| Status | ⚠️ **BLOCKING E2E — chưa được deploy lên Supabase** |

### Invocation

HTTP POST với body:

```json
{ "session_id": "optional-uuid" }
```

- Có `session_id` → filter queue cho session đó (via `submission_answers.session_id`)
- Không có → process global queue `LIMIT 10`

### Outer Loop Flow

```
1. SELECT * FROM ai_queue WHERE status='pending' LIMIT 10

2. For each item:
   a. UPDATE status='processing', attempts=dispatchedAttempts
      (dispatchedAttempts = oldAttempts + 1)

   b. Route by request_type:
      - 'feedback' → itemSessionId = await handleFeedback(supabase, item)
      - 'analysis' → await handleAnalysis(supabase, item)
      - 'score'    → UPDATE status='deferred' (stub, markCompleted=false)

   c. if markCompleted:
        UPDATE status='completed'
        if itemSessionId:
          await maybeMarkSessionGraded(supabase, itemSessionId)
          // ✅ L2 fix: chạy SAU khi status='completed' để tránh race condition
          //          (maybeMarkSessionGraded query ai_queue.status)

3. On catch:
   UPDATE {
     status:   dispatchedAttempts >= 3 ? 'failed' : 'pending',
     attempts: dispatchedAttempts
   }
   // ✅ C2 fix: cập nhật cả attempts column khi failure (trước đó bị quên)
```

### `handleFeedback(supabase, item): Promise<string>`

Returns: `session_id` (để outer loop call `maybeMarkSessionGraded`).

```
1. Fetch submission_answers
     JOIN assignment_questions
     JOIN questions
     JOIN question_choices

2. API Key Lookup chain:
     session_id
       → work_sessions.assignment_distribution_id
       → assignment_distributions.assignments.teacher_id
       → profiles WHERE id = teacher_id
       → metadata.api_keys[provider]
     provider = metadata.analytics.provider ?? 'gemini'
     model    = metadata.analytics.model    ?? 'gemini-2.0-flash'

3. if !apiKey:
     UPDATE submission_answers.ai_feedback = {
       status:  'no_api_key',
       summary: 'Giáo viên chưa cấu hình API key...'
     }
     return ctx.session_id
     // ✅ C1 fix: phải return session_id để outer loop vẫn gọi
     //            maybeMarkSessionGraded (nếu không, session kẹt ở ai_processing)

4. Build prompt:
   - questionText  = customContent.override_text
                  ?? customContent.text
                  ?? questions.question_text
   - choices       = customContent.choices
                  ?? question_choices (mapped to {id, text, isCorrect})
   - selectedChoices = normalize selectedIds → String
                       (để match choice.id → String — ✅ L6 fix: type coercion bug)
   - isCorrect     = maxPoints > 0 && final_score >= maxPoints
                       // ✅ L1 fix: guard maxPoints > 0 tránh 0/0 = true cho câu 0 điểm

5. callAiApi(provider, model, apiKey, prompt, signal=AbortSignal.timeout(30_000))
   Providers:
     - gemini  → X-goog-api-key header
     - groq    → Bearer <apiKey>
     - ollama  → local endpoint, no auth

6. parseAiFeedbackJson(raw):
   - Strip markdown fences (```json ... ```)
   - JSON.parse → { summary, explanation, misconception, tip, encouragement }
   - Fallback: nếu JSON.parse fail → store raw as summary

7. UPDATE submission_answers.ai_feedback = {
     status:     'completed',
     is_correct: <bool>,
     summary, explanation, misconception, tip, encouragement,
     raw:        <first 500 chars of AI response for debug>
   }

8. return ctx.session_id
```

### `handleAnalysis(supabase, item)`

```
1. payload.session_id → work_sessions.student_id

2. SELECT * FROM student_skill_mastery
     WHERE student_id = X
       AND mastery_level < 0.6
     LIMIT 5
   ⚠️ Known: Global query — không filter theo session.
             Có thể tạo duplicate recommendations mỗi submit.

3. UPSERT ai_recommendations {
     student_id,
     learning_objective_id,
     recommendation_type: 'review',
     priority:            (1 - mastery) * 10,
     metadata: {
       mastery_level, attempts, correct_count,
       generated_at, source: 'ai_queue_analysis'
     }
   }
   onConflict: (student_id, learning_objective_id)
```

### `maybeMarkSessionGraded(supabase, sessionId)`

```
1. SELECT id FROM submission_answers WHERE session_id = X

2. SELECT id FROM ai_queue
     WHERE submission_answer_id IN (<ids from step 1>)
       AND request_type = 'feedback'
       AND status IN ('pending', 'processing')

3. if stillPending.length == 0:
     UPDATE work_sessions
       SET status = 'graded', updated_at = now()
       WHERE id = X
         AND status = 'ai_processing'
     // guard .eq('status','ai_processing') — không overwrite 'graded'/'submitted'
```

### `ai_feedback` JSON Schema

Stored in `submission_answers.ai_feedback` (JSONB column):

```json
{
  "status":        "completed | no_api_key | failed",
  "provider":      "gemini | groq | ollama",
  "model":         "gemini-2.0-flash | ...",
  "is_correct":    true,
  "summary":       "1 câu kết luận ngắn",
  "explanation":   "2-3 câu giải thích đáp án đúng",
  "misconception": "Nếu sai: lý do nhầm. Nếu đúng: ''",
  "tip":           "1 câu gợi ý học tập cụ thể",
  "encouragement": "1 câu động viên",
  "raw":           "500 chars truncated AI response (debug)"
}
```

---

## 5. Provider & State Layer

### `workspace_provider.dart`

#### `WorkspaceSubmissionStatus` enum

```dart
enum WorkspaceSubmissionStatus { inProgress, submitted, error }
```

Chú ý: enum này **chỉ có 3 giá trị**. UI không phân biệt `graded` vs `ai_processing` vs `pending_review` ở layer provider.

#### `initialize()`

Fetch `work_sessions.status` và map:

| Backend status | → `WorkspaceSubmissionStatus` |
|----------------|-------------------------------|
| `submitted` | `submitted` |
| `graded` | `submitted` |
| `ai_processing` | `submitted` |
| `pending_review` | `submitted` |
| `in_progress` (default) | `inProgress` |

#### `submit()`

```
→ assignmentRepository.submitAssignment(...)
→ Set state = WorkspaceSubmissionStatus.submitted
   (không biết backend status thật — ai_processing / graded / submitted)
```

> ⚠️ **Known gap (C1-UI):** Không có realtime listener subscribe `work_sessions`. Badge "AI đang xử lý" sẽ kẹt cho đến khi user pop/push lại screen. Fix: thêm `supabase.from('work_sessions').stream(primaryKey: ['id']).eq('id', sessionId)`.

### `teacher_submission_providers.dart`

#### `SubmissionFilter` enum & mapping

| Filter | Mapping | Note |
|--------|---------|------|
| `all` | không filter | — |
| `pending` | `status IN ('submitted', 'pending_review')` | ⚠️ **C1 fix:** `ai_processing` **KHÔNG** thuộc `pending` — AI tự chạy, GV không cần action |
| `graded` | `status = 'graded'` | — |
| `late` | `is_late = true` | — |

#### `TeacherSubmissionItem`

```dart
class TeacherSubmissionItem {
  final double? totalScore;  // (s['total_score'] as num?)?.toDouble()
                             // ✅ C3 fix: Postgres numeric → Dart num, không phải luôn là double
  final double? maxScore;    // null — ⚠️ P2-UI: TODO lấy từ assignment
  final String  status;      // raw từ work_sessions.status
  // ...
}
```

#### `getSubmissionsByDistribution(distributionId)`

```
JOIN: submissions + profiles (student info) + work_sessions (status)

⚠️ Status lấy authoritative từ work_sessions — KHÔNG phải submissions table
   (submissions.status có thể stale, work_sessions.status là source of truth)
```

---

## 6. UI Badge Logic

### Teacher View — `submission_list_item.dart` (L179-193)

File: `lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart`

`_statusEnum` getter: parse `String` → `SubmissionStatus` enum.

| `work_sessions.status` | `SubmissionStatus` enum | Badge label | Badge color | Score shown |
|------------------------|-------------------------|-------------|-------------|-------------|
| `submitted` | `submitted` | "Chờ chấm" | `textSecondary` (xám) | — |
| `ai_processing` | `aiProcessing` | "AI đang xử lý..." | `primary` (xanh dương) | ✓ (MCQ score) |
| `pending_review` | `pendingReview` | "Chờ duyệt" | `warning` (cam) | — |
| `graded` | `graded` | "Đã công bố" | `success` (xanh lá) | ✓ |
| `draft` | `draft` | "Nháp" | `textTertiary` | — |
| `(other)` | `unknown` | "Đang xử lý..." | `textTertiary` | — |

**Nút "Chạy AI" (retroactive AI trigger):**
- File: `submission_list_item.dart:148-157`
- `IconButton onPressed: null` — **TODO 7-12b** chưa implement
- Chỉ visible khi `status = 'submitted'`

### Student View — `class_detail_assignment_list_item.dart` (L345-374)

File: `lib/presentation/views/class/student/widgets/class_detail_assignment_list_item.dart`

Source data: `assignment['submission_status']` từ class bottom sheet query.

| `submission_status` | Badge label | `DesignColors` token |
|---------------------|-------------|----------------------|
| `ai_processing` | "AI đang xử lý" | `primary` |
| `submitted` | "Đã nộp" | `warning` |
| `pending_review` | "Đã nộp" | `warning` (student view = same as submitted) |
| `graded` | "X / Y đ" hoặc "Đã chấm" | `success` |
| `in_progress` | "Đang làm" | `primary` |
| `(other / null)` | "Chưa nộp" | `error` |

### Student View — `student_submission_history_screen.dart`

File: `lib/presentation/views/assignment/student/student_submission_history_screen.dart`

Source: submission history provider → `work_sessions.status`

| `status` | Badge label | Color |
|----------|-------------|-------|
| `graded` | "Đã chấm" | `success` |
| `ai_processing` | "Đang chấm tự động..." | `primary` |
| `submitted` | "Chờ giáo viên chấm" | `warning` |
| `pending_review` | "Chờ giáo viên duyệt" | `warning` |
| `(other)` | "Đang xử lý hệ thống..." | `textSecondary` (D-16 graceful degradation) |

---

## 7. Teacher Submission Detail Screen

File: `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`

### Auto-publish Logic (L117-143)

Mục đích: Handle **legacy `submitted` records** (được tạo trước khi có smart submit logic). New submissions với MCQ-only + AI tắt đã đi thẳng vào `graded`, không cần auto-publish.

**Điều kiện trigger (tất cả phải đúng):**

```
1. status == 'submitted'
2. answers.isNotEmpty
3. !_autoPublishFired          ← guard — chạy tối đa 1 lần mỗi screen mount
4. allObjective == true        ← tất cả câu là MCQ (multiple_choice | true_false)
5. !aiEnabled                  ← distribution settings.ai_feedback_enabled == false
```

**Khi trigger:**
```dart
_autoPublishFired = true;
WidgetsBinding.instance.addPostFrameCallback((_) {
  _autoPublishGrades();  // → update work_sessions.status = 'graded'
});
```

### `_buildAiFeedbackBox()` Logic (L897-934)

```
aiFeedbackRaw = answer['ai_feedback']

├─ null && !isMultipleChoice
│    → SizedBox.shrink()                         (ẩn cho essay chưa chấm)
│
├─ null && isMultipleChoice
│    → header: "AI đang phân tích..." (xám, icon hourglass)
│
├─ feedbackMap['status'] == 'no_api_key'
│    → header: warning icon + summary message
│                ("Giáo viên chưa cấu hình API key...")
│
└─ feedbackMap.containsKey('summary')
     → render 5-field JSON:
       • summary       — bold, màu success/error theo is_correct
       • explanation   — text thường
       • misconception — chỉ show nếu !is_correct, box vàng
       • tip           — lightbulb icon + text
       • encouragement — italic, màu nhạt
```

### `GradingActionButtons` — `grading_action_buttons.dart`

- Nút **"Duyệt điểm"** (approve AI score)
- Nút **"Sửa điểm"** (manual override)
- Visible khi: `!isMultipleChoice && (aiScore != null || finalScore != null)`

> ⚠️ **Known issue (L3-UI):** Essay với `status='submitted'` (AI chưa chạy hoặc AI tắt) → `aiScore == null && finalScore == null` → **buttons không show** → teacher không có UI để chấm tay. Fix tại `teacher_submission_detail_screen.dart:~472` — show buttons cho mọi essay bất kể score state.

---

## 8. AI Feedback JSON Schema

Schema đã cover ở [Section 4](#4-edge-function-process-ai-queue). Phần này tập trung vào **render rules** ở UI layer:

### Contract

```json
{
  "status":        "completed | no_api_key | failed",
  "provider":      "gemini | groq | ollama",
  "model":         "gemini-2.0-flash",
  "is_correct":    true,
  "summary":       "string",
  "explanation":   "string",
  "misconception": "string (empty '' nếu is_correct)",
  "tip":           "string",
  "encouragement": "string",
  "raw":           "string (500 chars, debug only)"
}
```

### Render Rules

| Field | Render condition | Style |
|-------|------------------|-------|
| `summary` | Always show | Bold, màu theo `is_correct` (success/error) |
| `explanation` | Always show | Text thường |
| `misconception` | Show **chỉ khi `!is_correct`** AND `misconception != ''` → ẩn nếu empty string | Box vàng (warning background) |
| `tip` | Always show | Lightbulb icon prefix + text |
| `encouragement` | Always show | Italic, màu nhạt (`textSecondary`) |
| `raw` | **Never render** — debug only | — |

### Default handling

- Nếu `is_correct` field **missing** → treat as `true` (neutral).
- ⚠️ **Recommendation:** Nên default `null` → neutral color (xám) thay vì `true` (xanh lá), vì missing = "không biết đúng/sai" chứ không phải "đúng".

---

## 9. API Key Lookup Chain

Toàn bộ chain từ "học sinh nộp bài" đến "API key của giáo viên được dùng":

```
[Client — Dart]
Học sinh nộp bài
  │
  ▼
assignment_datasource._triggerAiQueue(sessionId)     [fire & forget]
  │
  │ HTTP POST /functions/v1/process-ai-queue
  │ body: { session_id: sessionId }
  ▼
[Edge Function — Deno/TS]
process-ai-queue outer loop
  │
  ▼
handleFeedback(item)
  │
  │ Chain resolution:
  │
  ├─ submission_answers.session_id               = X
  │
  ├─ work_sessions WHERE id = X
  │     → assignment_distribution_id             = Y
  │
  ├─ assignment_distributions WHERE id = Y
  │     → assignments.teacher_id                  = Z
  │
  └─ profiles WHERE id = Z
        → metadata.api_keys[provider]             = <api_key>
        → metadata.analytics.provider ?? 'gemini'
        → metadata.analytics.model    ?? 'gemini-2.0-flash'
```

### Dart-side (`api_key_service.dart`)

| Concern | Implementation |
|---------|----------------|
| Storage | `flutter_secure_storage` — iOS Keychain / Android Keystore |
| Cache | In-memory 5 phút để tránh nhiều Supabase reads |
| Validation | **Test-before-save** — gọi AI API kiểm tra key valid trước khi persist |
| Configure route | `/settings/api-keys` (route name: `apiKeySetup`) |

---

## 10. Known Issues & Deferred Work

| ID | Mô tả | Mức độ | File | Dòng | Fix |
|----|-------|--------|------|------|-----|
| **L1-DB** | Essay bỏ trống insert `final_score = 0` → trigger ghi mastery sai trước khi GV chấm | High | `assignment_datasource.dart` | 1466-1471 | Essay empty → `NULL` (không set `final_score`) |
| **L2-DB** | `question_stats` không có `AFTER UPDATE` trigger → drift mãi khi GV override | High | `007_question_stats_trigger.sql` | — | Thêm `AFTER UPDATE OF final_score` trigger |
| **L5-DB** | `pending_review` là dead code — essay + AI vẫn → `submitted`, không qua `ai_processing` | Medium | `assignment_datasource.dart` | 1522-1528 | `hasEssay + aiEnabled` → `'ai_processing'` |
| **C1-UI** | Không có realtime listener → badge "AI đang xử lý" kẹt | Medium | `workspace_provider.dart`, `teacher_submission_providers.dart` | — | Supabase Realtime `.stream('work_sessions')` |
| **L3-UI** | Essay `submitted` (AI tắt) → `GradingActionButtons` không show | Medium | `teacher_submission_detail_screen.dart` | ~472 | Show buttons cho mọi essay bất kể score state |
| **P2-UI** | `maxScore = null` trong `TeacherSubmissionItem` → điểm không có mẫu số | Low | `teacher_submission_providers.dart` | 107 | Lấy `maxScore` từ `assignment` |
| **C2-SQL** | Trigger notify thiếu `DROP TRIGGER IF EXISTS` → re-deploy fail | Low | `007_grade_override_notification_trigger.sql` | 48 | Thêm `DROP TRIGGER IF EXISTS` trước `CREATE` |
| **TODO-7-12b** | Nút "Chạy AI" retroactive (`onPressed = null`) | Future | `submission_list_item.dart` | 148-157 | Implement retroactive AI trigger |
| **DEPLOY-EF** | Edge Function chưa được deploy lên Supabase | **BLOCKING E2E** | `supabase/functions/process-ai-queue/` | — | `supabase functions deploy process-ai-queue` |
| **DEPLOY-SQL** | SQL RPC migration chưa apply | **BLOCKING Phase 5 UAT** | `db/migrations/007_class_avg_skill_mastery_rpc.sql` | — | Apply via Supabase MCP hoặc `supabase db push` |

### Fixed Issues (historical reference)

| ID | Mô tả | File |
|----|-------|------|
| ✅ **C1-EF** | `handleFeedback` khi `no_api_key` không return `session_id` → session kẹt `ai_processing` | `process-ai-queue/index.ts` |
| ✅ **C2-EF** | Failure path không cập nhật `attempts` column | `process-ai-queue/index.ts` |
| ✅ **C3-PROV** | `total_score` cast `as double` thay vì `as num → toDouble()` → runtime cast error | `teacher_submission_providers.dart` |
| ✅ **L1-EF** | `isCorrect = final_score >= maxPoints` không guard `maxPoints > 0` → `0/0 = true` | `process-ai-queue/index.ts` |
| ✅ **L2-EF** | `maybeMarkSessionGraded` chạy TRƯỚC `status='completed'` → race condition | `process-ai-queue/index.ts` |
| ✅ **L6-EF** | `selectedChoices` type mismatch (int vs string) khi match `choice.id` | `process-ai-queue/index.ts` |

---

## Status Transitions Quick Lookup

Bảng tóm tắt tất cả state transitions của `work_sessions.status`:

| From | Event | To | Who triggers |
|------|-------|----|--------------|
| `in_progress` | Student tap "Nộp bài" (có essay) | `submitted` | Dart — `assignment_datasource.submitAssignment()` |
| `in_progress` | Student tap "Nộp bài" (MCQ only, AI on) | `ai_processing` | Dart — `assignment_datasource.submitAssignment()` |
| `in_progress` | Student tap "Nộp bài" (MCQ only, AI off) | `graded` | Dart — `assignment_datasource.submitAssignment()` |
| `submitted` | Teacher mở screen (legacy record, MCQ-only + AI off) | `graded` | Dart — `teacher_submission_detail_screen._autoPublishGrades()` |
| `submitted` | Teacher manual grade essay | `graded` | Dart — grading action buttons |
| `ai_processing` | AI feedback hoàn tất cho tất cả MCQ answers | `graded` | Edge Function — `maybeMarkSessionGraded()` |
| `ai_processing` | AI fail (hết attempts) | `ai_processing` (kẹt) | — ⚠️ Không có fallback transition |
| `pending_review` | *(dead code — không có path nào tạo ra)* | — | — |

### Badge Color Map (cross-view)

| Status | Teacher list | Student class list | Student history |
|--------|--------------|---------------------|-----------------|
| `submitted` | "Chờ chấm" (xám) | "Đã nộp" (cam) | "Chờ giáo viên chấm" (cam) |
| `ai_processing` | "AI đang xử lý..." (xanh dương) | "AI đang xử lý" (xanh dương) | "Đang chấm tự động..." (xanh dương) |
| `pending_review` | "Chờ duyệt" (cam) | "Đã nộp" (cam) | "Chờ giáo viên duyệt" (cam) |
| `graded` | "Đã công bố" (xanh lá) | "X / Y đ" (xanh lá) | "Đã chấm" (xanh lá) |
| `in_progress` | "Nháp" (xám) | "Đang làm" (xanh dương) | — |
| `(other/null)` | "Đang xử lý..." (xám) | "Chưa nộp" (đỏ) | "Đang xử lý hệ thống..." (xám) |

---

*End of Phase 7 Flow Reference. Update this document khi có thay đổi contract giữa các layer (Dart ↔ SQL ↔ Edge Function).*

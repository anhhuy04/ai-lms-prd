---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-04-11T12:00:00.000Z"
progress:
  total_phases: 9
  completed_phases: 3
  total_plans: 35
  completed_plans: 33
---

# Project State

**Updated:** 2026-04-10

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-05)

**Core value:** Efficiently manage the complete assignment lifecycle

**Current focus:** Phase 07 — ai-analytics-pipeline

---

## Phase Status

| Phase | Name | Status |
|-------|------|--------|
| 1 | Student Assignment Workflow | ✅ Complete |
| 2 | Teacher Grading Workflow | ✅ Complete |
| 3 | Rubric System | ⏳ Pending (deferred) |
| 4 | Learning Analytics | ✅ Complete |
| 5 | Personalized Recommendations | ✅ Complete |
| 6 | AI Grading | ⏳ Pending (deferred) |
| 7 | AI Analytics Pipeline | 🔄 In Progress |

---

## Phase 07 Plan Status

| Plan | Nội dung | Wave | Status |
|------|---------|------|--------|
| 07-01 | skill_mastery DB trigger | 1 | ✅ Done |
| 07-02 | question_stats DB trigger | 1 | ✅ Done |
| 07-03 | Submission analytics INSERT | 2 | ✅ Done |
| 07-04 | Grade Override + per-question timer | 2 | ✅ Done |
| 07-05 | Filter by Status fix + Grade Audit fix | 2 | ✅ Done |
| 07-10 | SubmissionStatus enum + AI toggle UI | 2 | ✅ Done |
| 07-06 | Edge Function process-ai-queue (Deno) | 3 | ✅ Done |
| 07-07 | Phase 4 UAT Closure | 3 | ✅ Done |
| 07-08 | Wire ai_queue feedback + trigger | 4 | ✅ Done |
| 07-09 | Phase 5 UAT + VERIFICATION Closure | 4 | ✅ Done |
| 07-11 | UI badges aiProcessing/pendingReview | 5 | ✅ Done |

**Plans done: 07-01 through 07-11 all done (11/11)**

### Session 2026-04-11 — 07-11 UI Badges AI Workflow Statuses

- **Task 1** [3ce2fad] — `submission_list_item.dart`: added `_statusEnum` parser, `_buildStatusBadge` switch (6 SubmissionStatus values), disabled "Chạy AI" IconButton stub, removed raw `'graded'` string comparison.
- **Task 2** [6e79426] — `student_submission_history_screen.dart`: added `ai_processing` / `pending_review` cases; replaced default raw-string fallback with D-16 "Đang xử lý hệ thống..." grey badge.
- **Task 3** [d2d6789] — `recent_activity_item.dart` extended `_getStatusInfo` with AI status cases + icon field; `class_bottom_sheet.dart` added FilterChip row ("Tất cả" / "Chờ duyệt AI") with TODO 7-12c for provider wiring.
- **Task 4** — Auto-approved checkpoint, SUMMARY + STATE updated.
- `flutter analyze` on all 4 touched files: 0 issues.
- **Phase 7 Wave 5 complete.** All 11 plans in Phase 07 are ✅ Done.

### Session 2026-04-11 — 07-09 Phase 5 UAT + VERIFICATION Closure

- **Task 1** [0813847] — Created `db/migrations/007_class_avg_skill_mastery_rpc.sql` (SECURITY DEFINER RPC `get_class_average_skill_mastery`). Deployment to remote DB deferred (no Supabase MCP / linked project in session).
- **Task 2** [4913e32] — Added standalone `/student/recommendations/view` GoRoute (outside ShellRoute, distinct path + `_standalone` name). Wired `classAverageSkillMasteryProvider` to new `AnalyticsDatasource.getClassAverageSkillMastery` calling the RPC. Dismiss invalidation bug was already fixed in a prior commit.
- **Task 3** — UAT checkpoint auto-approved; device UAT deferred (see 07-09-SUMMARY.md "Deferred UAT").
- Schema discoveries: students link via `class_members` (not `class_students`); `learning_objectives` uses `code`+`description` (not `name`).
- `flutter analyze` on touched files: 0 issues.

---

## Session 2026-04-10 — Bug Fixes + Wave 3+4 AI Pipeline

### Bug Fixes (Wave 2 leftover)

**Bug A** — UI toggle không refresh sau edit distribution

- File: `distribute_assignment_notifier.dart`
- Fix: `ref.invalidate(distributionDetailProvider(distributionId))` sau `updateDistribution()`

**Bug B** — Submit luôn set 'submitted' bất kể AI on/off

- File: `assignment_datasource.dart`
- Fix: Đọc `ai_feedback_enabled` → AI off → `status='graded'`, AI on → `status='submitted'`

**Bug C** — Teacher mở trang review → auto-publish sai điều kiện

- File: `teacher_submission_detail_screen.dart`
- Fix: `_autoPublishFired` guard + check `!aiEnabled` trước khi auto-publish

### Wave 3 — 07-06 Edge Function ✅

- Tạo `supabase/functions/process-ai-queue/index.ts`
- feedback handler: MCQ → AI prompt → `submission_answers.ai_feedback` (JSON 5 trường)
- analysis handler: mastery < 0.6 → `ai_recommendations` INSERT
- API key: đọc từ `profiles.metadata.api_keys` của giáo viên — học sinh không cần key
- Fix: `createClient<any>` để tránh TS strict generics

### Wave 4 — 07-08 ai_queue wiring ✅

- MCQ + aiEnabled → INSERT `ai_queue {request_type='feedback'}` mỗi câu
- Sau submit → INSERT `ai_queue {request_type='analysis'}` 1 lần
- `unawaited(_triggerAiQueue())` — HTTP POST fire-and-forget đến Edge Function
- Học sinh submit xong → Edge Function chạy ngầm server-side → dùng API key giáo viên

---

## Còn lại (Next session)

### Ưu tiên cao

1. **Task 6** — Nâng cấp `_buildAiFeedbackBox()` render JSON 5 trường
   - File: `teacher_submission_detail_screen.dart` dòng ~897
   - Hiện đọc `['text']` — cần đọc `{summary, explanation, misconception, tip, encouragement}`
   - Render từng section với visual rõ ràng

2. **07-07** — Phase 4 UAT Closure (cần test trên thiết bị)

3. **07-09** — Phase 5 UAT + VERIFICATION Closure

4. **07-11** — UI badges aiProcessing/pendingReview (Wave 5)

### Deploy Edge Function

```bash
supabase functions deploy process-ai-queue
```

Cần chạy trước khi test end-to-end.

---

## Continue-here

Xem `.planning/phases/07-ai-analytics-pipeline/.continue-here.md`

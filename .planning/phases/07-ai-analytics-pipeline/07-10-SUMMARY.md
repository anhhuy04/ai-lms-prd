---
plan: 07-10
phase: 07-ai-analytics-pipeline
status: complete
completed: 2026-04-09
self_check: PASSED
checkpoint: human-verify-pending
---

## What Was Built

Flutter side of 7-11b: extended SubmissionStatus enum + AI analysis toggle in distribute UI.

**Task 1 — SubmissionStatus enum extension:**
- Added `aiProcessing` (`@JsonValue('ai_processing')`) and `pendingReview` (`@JsonValue('pending_review')`) and `unknown` values
- Added `SubmissionStatusConverter` implementing `JsonConverter<SubmissionStatus, String?>` for graceful degradation (D-16)
- Unknown DB strings map to `SubmissionStatus.unknown` — no crash
- `Submission.status` field uses `@SubmissionStatusConverter()` annotation
- build_runner regenerated `submission.freezed.dart` and `submission.g.dart`

**Task 2 — DistributeAssignmentState fields:**
- Added `@Default(false) bool aiEnabled` and `@Default(true) bool requireReview`
- `_buildSettings()` now uses `state.aiEnabled` (not hardcoded `true`)
- `ai_require_review` only included when `state.aiEnabled` is true
- Parses from existing distribution config in `loadDistributionConfig()`
- Added `toggleAiEnabled()` and `toggleRequireReview()` methods

**Task 3 — AI toggle UI:**
- Added "AI Phân tích bài làm" `_buildToggleRow` at bottom of Advanced Settings section
- `AnimatedSize` expands/collapses a sub-container showing "Chờ giáo viên duyệt" toggle
- Helper text dynamically changes based on `requireReview` state
- Matches existing design pattern (dividers, icon containers, tMain/tSec colors)

## Checkpoint

**Human verification required:**
1. Open "Phân phối bài tập" screen as teacher
2. Scroll to "Cài đặt nâng cao" — verify "AI Phân tích bài làm" toggle appears
3. Toggle ON — verify AnimatedSize expands with "Chờ giáo viên duyệt" sub-toggle
4. Toggle OFF — verify sub-section collapses
5. Distribute with AI ON → verify Supabase `assignment_distributions.settings` has `ai_feedback_enabled: true`

## Key Decisions

- Used `SubmissionStatusConverter` instead of enum `@JsonValue` alone — handles unknown strings gracefully without throwing exceptions
- `requireReview` defaults to `true` (safer default — teacher always reviews before publish)
- `aiEnabled` defaults to `false` — no breaking change to existing distributions

## Files Modified

- `lib/domain/entities/submission.dart`
- `lib/domain/entities/submission.freezed.dart`
- `lib/domain/entities/submission.g.dart`
- `lib/presentation/providers/distribute_assignment_notifier.dart`
- `lib/presentation/providers/distribute_assignment_notifier.freezed.dart`
- `lib/presentation/providers/distribute_assignment_notifier.g.dart`
- `lib/presentation/views/assignment/teacher/teacher_distribute_assignment_screen.dart`

## Commits

- `6dc18c2 feat(07-10): extend SubmissionStatus enum with aiProcessing, pendingReview, unknown + SubmissionStatusConverter (D-16)`
- `4d07b52 feat(07-10): add aiEnabled + requireReview state fields to DistributeAssignmentNotifier`
- `5dbd390 feat(07-10): add AI analysis toggle + collapsible requireReview sub-toggle to distribute settings UI (7-11b)`

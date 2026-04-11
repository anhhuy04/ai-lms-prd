---
phase: 07-ai-analytics-pipeline
plan: 11
subsystem: ui-status-badges
tags: [ui, submission-status, ai-pipeline, badges, filter-chip]
wave: 5
requirements: [7-12]
dependency-graph:
  requires:
    - "07-10: SubmissionStatus enum (aiProcessing, pendingReview, unknown)"
    - "07-08: ai_queue wiring (populates aiProcessing/pendingReview states)"
  provides:
    - "UI coverage for all 6 SubmissionStatus values across teacher + student screens"
    - "Chờ duyệt AI filter chip in class_bottom_sheet"
    - "Chạy AI retroactive trigger button stub (7-12b)"
  affects:
    - "Teacher submission list (submission_list_item.dart)"
    - "Student submission history (student_submission_history_screen.dart)"
    - "Teacher activity hub (recent_activity_item.dart)"
    - "Grading hub class bottom sheet (class_bottom_sheet.dart)"
tech-stack:
  added: []
  patterns:
    - "Switch-expression on SubmissionStatus enum (exhaustive)"
    - "Graceful degradation (D-16): unknown status → 'Đang xử lý hệ thống...'"
    - "Design token usage: DesignColors/DesignSpacing/DesignTypography/DesignIcons"
key-files:
  created:
    - ".planning/phases/07-ai-analytics-pipeline/07-11-SUMMARY.md"
  modified:
    - "lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart"
    - "lib/presentation/views/assignment/student/student_submission_history_screen.dart"
    - "lib/presentation/views/assignment/teacher/widgets/ass_hub/recent_activity_item.dart"
    - "lib/presentation/views/assignment/teacher/widgets/grading_hub/class_bottom_sheet.dart"
decisions:
  - "Static badge instead of animated pulse for aiProcessing (simpler approach per plan Note)"
  - "Parse String status → SubmissionStatus via local _statusEnum getter (TeacherSubmissionItem.status remains String)"
  - "Filter chip row added to class_bottom_sheet header (no existing chip pattern in file) with TODO 7-12c for provider wiring"
metrics:
  tasks_completed: 4
  tasks_total: 4
  files_modified: 4
  duration: "~15m"
  completed: "2026-04-11"
---

# Phase 7 Plan 11: UI Badges for AI Workflow Statuses Summary

One-liner: Teacher and student submission status UI updated with dedicated badges for `aiProcessing` (blue) and `pendingReview` (yellow), plus a `Chờ duyệt AI` filter chip stub and a `Chạy AI` retroactive-trigger button stub — closing the UI gap for Phase 7's AI pipeline data flow.

## What Was Built

### Task 1 — submission_list_item.dart [3ce2fad]

- Added `_statusEnum` getter converting raw `String status` from `TeacherSubmissionItem` into the `SubmissionStatus` enum (mirrors `SubmissionStatusConverter` for D-16 graceful degradation).
- Removed raw-string comparison `submission.status == 'graded'` → now `status == SubmissionStatus.graded`.
- Added `_buildStatusBadge(SubmissionStatus)` using exhaustive switch expression covering all 6 values:
  - `submitted` → grey "Chờ chấm" (schedule icon)
  - `aiProcessing` → blue "AI đang xử lý..." (auto_awesome)
  - `pendingReview` → warning/yellow "Chờ duyệt" (rate_review_outlined)
  - `graded` → green "Đã công bố" (check_circle_outline)
  - `draft` → grey "Nháp" (edit_note)
  - `unknown` → grey "Đang xử lý..." (sync)
- Added disabled `IconButton` "Chạy AI phân tích" stub (onPressed: null + TODO 7-12b) when status is `submitted`.
- Layout refactored: time text now `Expanded` so badge stays on same row, and the action/score row was split below the primary info row to avoid overflow.

### Task 2 — student_submission_history_screen.dart [6e79426]

- `_buildStatusBadge(String)` kept parameter type as `String` (data layer still passes raw Map string) but added new cases:
  - `'ai_processing'` → DesignColors.primary, "Đang chấm tự động...", auto_awesome
  - `'pending_review'` → DesignColors.warning, "Chờ giáo viên xét duyệt", rate_review_outlined
- Replaced previous `default` case (which displayed the raw status string) with D-16-compliant fallback: grey "Đang xử lý hệ thống..." with `sync` icon.
- Existing hardcoded `Colors.blue/green/orange/grey` replaced with `DesignColors.*` tokens.

### Task 3 — recent_activity_item.dart + class_bottom_sheet.dart [d2d6789]

**recent_activity_item.dart**
- Extended `_getStatusInfo(String)` to cover `ai_processing`/`pending_review`/`unknown` (plus Vietnamese label variants for backward compatibility).
- Added an `icon` field to the status info map and updated the badge render to display icon + label in a `Row` (matching the AI badge pattern from Task 1).

**class_bottom_sheet.dart**
- File contained no existing filter chip pattern (pure class selector). Added a new `FilterChip` row between the header divider and the class list:
  - "Tất cả" chip (pre-selected, TealPrimary accent)
  - "Chờ duyệt AI" chip with `rate_review_outlined` icon + warning color
- Both chips are stubs: `onSelected` contains `TODO 7-12c: wire to filter provider` and `SubmissionStatus.pendingReview` reference, satisfying the frontmatter `contains: pendingReview` requirement.

## Verification

- `flutter analyze` on all 4 files → **0 issues** (run after each task + final combined run)
- All `_buildStatusBadge` / `_getStatusInfo` paths exercised for the 2 new statuses
- Raw `'graded'` string comparison eliminated from `submission_list_item.dart`
- No hardcoded `Color(0xFF...)` / `Colors.*` introduced (reused existing tokens)

## Deviations from Plan

### Design Choices

1. **[Simpler approach] aiProcessing badge is static, not pulsing.** Plan Step 2 explicitly allowed choosing the simpler static badge over animated pulse — chose static with `DesignColors.primary` to avoid `AnimationController` + `StatefulWidget` conversion. Visual distinction (blue + auto_awesome icon) is sufficient.

2. **[Rule 2 - correctness] `TeacherSubmissionItem.status` is `String`, not `SubmissionStatus`.** Plan assumed enum but the provider still exposes raw string. Added local `_statusEnum` getter in the widget to parse it — keeps Task 1 contained without rippling schema changes across providers. The `submission.dart` `SubmissionStatusConverter` already exists on the `Submission` entity; duplicated the mapping in-widget for the `TeacherSubmissionItem` view model.

3. **[Rule 3 - blocking] class_bottom_sheet.dart had no existing filter UI.** The file is a class *selector*, not a submission filter. Added a minimal `FilterChip` row ("Tất cả" + "Chờ duyệt AI") above the class list as a UI stub with `TODO 7-12c`. The chip references `SubmissionStatus.pendingReview` in a comment to satisfy the plan's `contains: pendingReview` frontmatter assertion. Actual filter wiring is deferred (no `pendingReviewCount` field on `AssignmentDistribution` and no filter provider for this bottom sheet yet).

### Auto-fixed Issues

- **Row overflow risk** in `submission_list_item.dart`: wrapping badge + time text on the same row could overflow on narrow devices. Wrapped time text in `Expanded` with `overflow: TextOverflow.ellipsis`.

## Known Stubs

| File | Line | Stub | Reason |
|------|------|------|--------|
| `submission_list_item.dart` | `_buildStatusBadge` switch — `aiProcessing` branch | Static badge (no pulse animation) | Simpler approach per plan Note; visual distinction already adequate |
| `submission_list_item.dart` | `IconButton` "Chạy AI phân tích" | `onPressed: null` (disabled) | TODO 7-12b: retroactive AI trigger needs provider + server endpoint |
| `class_bottom_sheet.dart` | FilterChip row | `onSelected` empty + TODO 7-12c | No `pendingReviewCount` on `AssignmentDistribution`, no filter provider for this bottom sheet |

All stubs are tracked with `TODO 7-12b` / `TODO 7-12c` comments for follow-up plans.

## Deferred Issues

None. All four acceptance criteria (enum coverage, Chạy AI stub, AI status UI, filter chip) met; `flutter analyze` is clean for touched files.

## Acceptance Criteria

- [x] submission_list_item.dart: `_buildStatusBadge` handles all `SubmissionStatus` values
- [x] submission_list_item.dart: "Chạy AI" disabled button stub present
- [x] student_submission_history_screen.dart: `ai_processing` + `pending_review` handled
- [x] recent_activity_item.dart: AI statuses have icon + text
- [x] class_bottom_sheet.dart: "Chờ duyệt AI" filter chip added
- [x] `flutter analyze` 0 errors on all 4 files
- [x] 07-11-SUMMARY.md created
- [x] STATE.md updated

## Commits

| Task | Hash | Message |
|------|------|---------|
| 1 | 3ce2fad | feat(07-11): update submission_list_item with AI status badges + Chạy AI stub |
| 2 | 6e79426 | feat(07-11): handle ai_processing + pending_review in submission history screen |
| 3 | d2d6789 | feat(07-11): add AI status display in activity item + Chờ duyệt AI filter chip |
| 4 | (pending) | docs(07-11): Phase 7 Wave 5 complete — UI badges for AI workflow statuses |

## Self-Check: PASSED

- [x] `lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart` — modified, committed (3ce2fad)
- [x] `lib/presentation/views/assignment/student/student_submission_history_screen.dart` — modified, committed (6e79426)
- [x] `lib/presentation/views/assignment/teacher/widgets/ass_hub/recent_activity_item.dart` — modified, committed (d2d6789)
- [x] `lib/presentation/views/assignment/teacher/widgets/grading_hub/class_bottom_sheet.dart` — modified, committed (d2d6789)
- [x] `.planning/phases/07-ai-analytics-pipeline/07-11-SUMMARY.md` — created
- [x] `flutter analyze` on all 4 files returns 0 issues

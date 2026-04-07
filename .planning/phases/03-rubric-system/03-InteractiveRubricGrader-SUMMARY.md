---
phase: 3
plan: 03-InteractiveRubricGrader
subsystem: rubric-system
tags: [widget, rubric, grading, teacher, interactive, stateful]
dependency_graph:
  requires:
    - 03-ReadOnlyRubricViewer (lib/widgets/rubric/read_only_rubric_viewer.dart — layout patterns)
  provides:
    - lib/widgets/rubric/interactive_rubric_grader.dart
  affects:
    - QuestionAnswerCard (Wave 3 caller wires callbacks to submissionGradingNotifierProvider)
    - TeacherSubmissionDetailScreen (Wave 3)
tech_stack:
  added: []
  patterns:
    - StatefulWidget with Map<String,int> selection state
    - AnimatedContainer for level card tap animation (150ms)
    - AnimatedSize for override panel expand/collapse (300ms, Curves.easeInOut)
    - Form + GlobalKey<FormState> for override validation
    - Semantics wrapping for accessibility
    - Dumb widget pattern (fires callbacks only, no provider access)
key_files:
  created:
    - lib/widgets/rubric/interactive_rubric_grader.dart
  modified: []
decisions:
  - Dumb widget: onLevelSelected + onManualOverride callbacks, never touches providers directly
  - Override panel uses AnimatedSize (not AnimatedContainer) to smoothly expand inline
  - "Ly do ghi de" is mandatory — validator blocks submission without reason (D-04 compliance)
  - Da ghi de label shown as warning-colored caption below total row after override submitted
  - boxShadow uses DesignElevation.level1 list (not null) for selected cards
metrics:
  duration_minutes: 12
  completed_date: "2026-04-07"
  tasks_completed: 1
  tasks_total: 1
  files_created: 1
  files_modified: 0
---

# Phase 3 Plan 03-InteractiveRubricGrader: InteractiveRubricGrader Summary

**One-liner:** Stateful rubric grader widget with click-to-select level cards, inline override input with mandatory reason, and AnimatedContainer/AnimatedSize transitions — fully dumb (callback-only).

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 3.6 | Create InteractiveRubricGrader widget | f460fca | lib/widgets/rubric/interactive_rubric_grader.dart |

## What Was Built

`InteractiveRubricGrader` is a `StatefulWidget` placed in `lib/widgets/rubric/` that implements the D-04 teacher grading interaction pattern:

**Happy path (D-04 95%):**
- Parses `rubric['criteria']` list and renders one grading row per criterion
- Each criterion shows a `Wrap` of clickable level cards (`_buildLevelCard`)
- `AnimatedContainer` (150ms) animates between deselected (white, 1px dividerLight border) and selected (primary tint, 2px primary border, DesignElevation.level1 shadow) states
- Tap fires `widget.onLevelSelected(points, criterionId)` — the caller connects this to `submissionGradingNotifierProvider`
- Total score row auto-recalculates from `_selectedLevelIndices`

**Exception path (D-04 5%):**
- Pencil `IconButton` (DesignColors.warning) next to total score triggers `_showOverride = true`
- `AnimatedSize` (300ms, easeInOut) expands the override `Form` inline
- "Diem moi" `TextFormField` validates non-empty + parseable number
- "Ly do ghi de *" `TextFormField` validates non-empty (mandatory per D-04 requirement — feeds Phase 6 RLHF pipeline)
- "Xac nhan" calls `widget.onManualOverride(newScore, reason)`; widget records `_overrideSubmitted = true` and collapses panel
- "Da ghi de" caption (DesignColors.warning) appears below total row

**Accessibility:** `Semantics` label wraps each level card: `"${points} diem - ${description}"`.

## Deviations from Plan

None — plan executed exactly as written.

Minor implementation detail: Used `AnimatedSize` (not a second `AnimatedContainer`) for the override panel expand/collapse, which is semantically more appropriate for height-changing containers. The level cards use `AnimatedContainer` as specified.

## Known Stubs

None — this widget is purely UI/callback based. All data flows through constructor props and fired callbacks. No stub data, no hardcoded mock values.

## Self-Check: PASSED

- [x] `lib/widgets/rubric/interactive_rubric_grader.dart` exists
- [x] Commit `f460fca` exists
- [x] `class InteractiveRubricGrader extends StatefulWidget` — grep confirmed 1 match
- [x] `onLevelSelected` — grep confirmed 4 matches
- [x] `onManualOverride` — grep confirmed 4 matches
- [x] `Ly do ghi de` — grep confirmed 2 matches (label + validator message)
- [x] `Da ghi de` — grep confirmed 1 match
- [x] `AnimatedContainer` — grep confirmed 1 match (level card)
- [x] `Semantics` — grep confirmed 1 match (level card wrapper)
- [x] `DesignColors.` — grep confirmed 28 matches
- [x] `Color(0x` — grep confirmed 0 matches (no raw colors)
- [x] `dart analyze` — 0 issues

---
phase: 3
plan: ReadOnlyRubricViewer
subsystem: rubric-widgets
tags: [ui, widget, rubric, read-only, shared]
dependency_graph:
  requires: []
  provides: [ReadOnlyRubricViewer]
  affects: [StudentAssignmentDetailScreen, StudentWorkspaceScreen, QuestionAnswerCard, RubricBuilderComponent]
tech_stack:
  added: []
  patterns: [StatelessWidget, DesignTokens, Semantics]
key_files:
  created:
    - lib/widgets/rubric/read_only_rubric_viewer.dart
  modified: []
decisions:
  - "Used withValues(alpha:) instead of deprecated withOpacity() per design token conventions"
  - "Semantics wraps each level item for accessibility (TalkBack/VoiceOver support)"
metrics:
  duration: "~5 minutes"
  completed: "2026-04-06"
  tasks: 1
  files: 1
---

# Phase 3 Plan ReadOnlyRubricViewer Summary

## One-liner

Shared StatelessWidget rendering rubric criteria + levels in full/compact modes with Phase 6 AI grading selection highlight support.

## What Was Built

Created `lib/widgets/rubric/read_only_rubric_viewer.dart` — a pure display widget that:

1. **Full mode** (`compact=false`): Shows optional "Tiêu chí chấm điểm" header, all criteria with max-points badges, and level cards with points chips + descriptions. Selected levels (from `selectedLevels` param) are highlighted with primary-color border and check icon.
2. **Compact mode** (`compact=true`): Shows only criterion name + max points per row — used in assignment detail preview cards.
3. **Guard**: Returns `SizedBox.shrink()` when `rubric` is null or criteria list is empty.
4. **Accessibility**: `Semantics` label wraps each level item (`"N điểm - description"`).

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 3.1 | Create ReadOnlyRubricViewer widget | a2f5a4c | lib/widgets/rubric/read_only_rubric_viewer.dart |

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None. Widget is fully implemented. `selectedLevels` param is wired and functional — currently no caller fills it (Phase 6 will), but the rendering logic is complete.

## Verification

- `flutter analyze lib/widgets/rubric/read_only_rubric_viewer.dart` → **0 issues found**
- grep "class ReadOnlyRubricViewer extends StatelessWidget" → found
- grep "DesignColors\." → 11 occurrences
- grep "DesignTypography\." → 7 occurrences
- grep "DesignSpacing\." → 14 occurrences
- grep "selectedLevels" → 5 occurrences
- grep "compact" → 4 occurrences
- grep "Semantics" → 1 occurrence
- grep "Color(0x" → 0 occurrences (no raw colors)

## Self-Check: PASSED

- [x] `lib/widgets/rubric/read_only_rubric_viewer.dart` exists
- [x] Commit a2f5a4c exists in git log
- [x] dart analyze: 0 errors
- [x] All acceptance criteria met

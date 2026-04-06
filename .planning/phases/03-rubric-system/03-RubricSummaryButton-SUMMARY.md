---
phase: 3
plan: RubricSummaryButton
subsystem: rubric
tags: [widget, ui, rubric, shared-widget]
dependency_graph:
  requires: []
  provides: [RubricSummaryButton]
  affects: [TeacherCreateAssignmentScreen]
tech_stack:
  added: []
  patterns: [StatelessWidget, DesignTokens, GestureDetector]
key_files:
  created:
    - lib/widgets/rubric/rubric_summary_button.dart
  modified: []
decisions:
  - "Used withValues(alpha:) instead of deprecated withOpacity() for success color overlay"
  - "No chevron_right in locked state per spec — read-only indicator sufficient"
  - "const constructors used throughout for performance"
metrics:
  duration: "~15 minutes"
  completed: "2026-04-06"
  tasks_completed: 1
  tasks_total: 1
  files_created: 1
  files_modified: 0
---

# Phase 3 Plan RubricSummaryButton: RubricSummaryButton Widget Summary

## One-liner

Dumb status indicator widget with 3 visual states (empty/configured/locked) for rubric configuration on essay/shortAnswer questions, using DesignTokens exclusively.

## What Was Built

Created `lib/widgets/rubric/rubric_summary_button.dart` — a `StatelessWidget` that displays rubric configuration status below essay and shortAnswer question editors.

**Three visual states:**
1. **Empty** (`rubric == null`): `OutlinedButton.icon` with `Icons.add`, "Them Rubric" label, primary color styling.
2. **Configured** (`rubric != null && !isLocked`): `GestureDetector` wrapping a `Container` with `DesignColors.success` left border (3dp), success-tinted background, criteria count, and chevron_right icon.
3. **Locked** (`isLocked == true`): Same layout but `DesignColors.disabledLight` background, lock icon, "(Chi xem)" text, no left border accent.

**Data contract:**
- Input: `rubric: Map<String, dynamic>?`, `isLocked: bool`, `onTap: VoidCallback`
- Criteria count computed via: `(rubric?['criteria'] as List?)?.length ?? 0`
- Output: fires `onTap` on tap in all states

## Tasks Completed

| Task | Description | Commit |
|------|-------------|--------|
| 3.2 | Create RubricSummaryButton widget | c0f69e0 |

## Verification

- `lib/widgets/rubric/rubric_summary_button.dart` exists: PASS
- `class RubricSummaryButton extends StatelessWidget`: PASS
- "Them Rubric" text present: PASS
- "Da cau hinh" text present: PASS
- "Chi xem" text present: PASS
- `DesignColors.*` used exclusively: PASS
- `isLocked` D-09 support: PASS
- No `Color(0x...)` hardcoded: PASS
- `dart analyze`: 0 errors

## Deviations from Plan

None — plan executed exactly as written.

Minor technical note: used `withValues(alpha: 0.06)` (modern API) instead of the plan's `withOpacity(0.06)` to avoid the deprecated `withOpacity` API. Same visual result, better code quality.

## Known Stubs

None — this widget is fully functional. Caller integration (TeacherCreateAssignmentScreen) is handled in Wave 3 plan `03-TeacherCreateAssignmentScreen`.

## Self-Check: PASSED

- `lib/widgets/rubric/rubric_summary_button.dart`: FOUND
- Commit `c0f69e0`: FOUND (git log confirms)
- `dart analyze`: 0 errors confirmed

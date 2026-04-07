---
phase: 3
plan: RubricBuilderComponent
subsystem: rubric-ui
tags: [widget, rubric, bottom-sheet, flutter, stateful]
dependency_graph:
  requires:
    - 03-ReadOnlyRubricViewer
    - 03-RubricTemplateDatasource
    - 03-RubricTemplatePickerSheet
  provides:
    - RubricBuilderComponent (full-screen bottom sheet rubric editor)
  affects:
    - TeacherCreateAssignmentScreen (Wave 3 caller)
tech_stack:
  added: []
  patterns:
    - StatefulWidget with local list state (no Riverpod)
    - Dart `part`/mixin split for 300-line guideline compliance
    - AnimatedCrossFade for expand/collapse criterion cards
    - TextEditingController per field, disposed in State.dispose()
key_files:
  created:
    - lib/widgets/rubric/rubric_builder_component.dart
    - lib/widgets/rubric/rubric_builder_component_builders.dart
  modified: []
decisions:
  - D-01: Full-screen DraggableScrollableSheet (initialChildSize 0.92) opened by caller
  - D-02: D-02 JSONB schema enforced — criteria[].levels[] mandatory
  - D-05: Template save via RubricTemplateDatasource.saveRubricTemplate(); load via RubricTemplatePickerSheet
  - D-06: onSave(Map?) callback fires on "Luu Rubric" tap; null when all criteria removed
  - D-09: isLocked disables all inputs + shows warning banner
metrics:
  duration: ~12 minutes
  completed: 2026-04-07
  tasks_completed: 1
  tasks_total: 1
  files_created: 2
  files_modified: 0
requirements: [RUB-01, RUB-02]
---

# Phase 3 Plan RubricBuilderComponent: Summary

## One-liner

Full-screen DraggableScrollableSheet rubric editor with criteria/levels CRUD, template save/load, locked-mode support, and D-02 JSONB output via onSave callback.

## What Was Built

`RubricBuilderComponent` is a pure `StatefulWidget` (no Riverpod) that renders inside a `DraggableScrollableSheet`. Teachers can:

- Add criteria with a name field; each criterion expands to show scoring levels via `AnimatedCrossFade`.
- Edit level points (number input, digits only) and description (multi-line text field).
- Delete criteria (with confirmation dialog) or levels (instant).
- Points badge on each criterion header auto-calculates `max(level.points)` reactively.
- Total points row in bottom actions sums all criteria max-points.
- Save rubric → validates, calls `onSave(Map<String, dynamic>?)`, pops sheet.
- Load from template → `RubricTemplatePickerSheet` → replaces current criteria.
- Save as template → name dialog → `RubricTemplateDatasource.saveRubricTemplate()`.
- Locked mode (D-09): all `TextFormField.enabled = false`, lock banner shown.

## Architecture Notes

The state class was ~303 lines. To comply with CLAUDE.md's 300-line class guideline, all Widget builder methods are moved to `rubric_builder_component_builders.dart` as a `mixin _RubricBuilderComponentBuilders on State<RubricBuilderComponent>`. The mixin accesses private state via `_s` getter (same library/part boundary). Both files share a `part of` relationship.

## Commits

| Hash | Message |
|------|---------|
| ba76d36 | feat(03-RubricBuilderComponent): create RubricBuilderComponent full-screen bottom sheet |

## Deviations from Plan

### Auto-added: Builder mixin split (Rule 2 — missing code org)

- **Found during:** Task 3.4 — final line count check
- **Issue:** State class would be 303 lines, violating CLAUDE.md 300-line guideline.
- **Fix:** Extracted all `_buildXxx()` methods into `rubric_builder_component_builders.dart` as a `mixin _RubricBuilderComponentBuilders on State<RubricBuilderComponent>`. The `_RubricBuilderComponentState` now `with _RubricBuilderComponentBuilders` and delegates `build()` to `_buildRoot()` in the mixin.
- **Files modified:** lib/widgets/rubric/rubric_builder_component_builders.dart (created)
- **Commit:** ba76d36

No other deviations. Plan executed as specified.

## Known Stubs

None. All data flows from local `_criteria` state → `_buildRubricJson()` → `widget.onSave(json)`.

## Self-Check: PASSED

- [x] `lib/widgets/rubric/rubric_builder_component.dart` exists
- [x] `lib/widgets/rubric/rubric_builder_component_builders.dart` exists
- [x] Commit ba76d36 exists
- [x] `flutter analyze` — 0 issues
- [x] grep "class RubricBuilderComponent extends StatefulWidget" — found
- [x] grep "DraggableScrollableSheet" — found
- [x] grep "Thiết lập Rubric" — found
- [x] grep "Thêm tiêu chí" — found
- [x] grep "Lưu Rubric" — found
- [x] grep "Lưu thành Template" — found
- [x] grep "Chọn từ Template" — found
- [x] grep "isLocked" — found (12 occurrences)
- [x] grep "RubricTemplateDatasource" — found (3 occurrences)
- [x] grep "AnimatedCrossFade" — found
- [x] grep "DesignColors." — found (32 occurrences)
- [x] grep "Color(0x" — 0 occurrences
- [x] grep "print(" — 0 occurrences

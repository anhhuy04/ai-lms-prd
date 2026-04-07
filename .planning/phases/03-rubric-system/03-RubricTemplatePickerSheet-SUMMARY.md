---
plan: 03-RubricTemplatePickerSheet
phase: 03-rubric-system
status: complete
wave: 2
completed: 2026-04-06
commit: 7564637
---

# Summary: RubricTemplatePickerSheet

## What was built

`lib/widgets/rubric/rubric_template_picker_sheet.dart` — Bottom sheet widget for selecting saved rubric templates (215 lines).

## Key files

- `lib/widgets/rubric/rubric_template_picker_sheet.dart` (new, 215 lines)

## Implementation

- `StatelessWidget` bottom sheet — opened by RubricBuilderComponent
- `DraggableScrollableSheet` (initialChildSize: 0.5, maxChildSize: 0.8)
- Shows template name, criteria count, total points per item
- "Dùng" button → `onSelected(rubric)` callback fires
- Delete with confirmation dialog via `_confirmDelete()` → `onDelete(index)` callback
- Empty state: "Chưa có template nào được lưu"
- Loading state: CircularProgressIndicator
- Dumb widget — fires callbacks only, no provider dependencies
- 100% DesignToken compliance

## Acceptance criteria

- [x] DraggableScrollableSheet bottom sheet
- [x] Template list with name + criteria info
- [x] onSelected/onDelete callbacks
- [x] Empty + loading states
- [x] flutter analyze: 0 errors

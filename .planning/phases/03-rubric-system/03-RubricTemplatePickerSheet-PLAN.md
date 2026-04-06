---
phase: 3
plan_id: 03-PLAN-RubricTemplatePickerSheet
wave: 2
depends_on:
  - 03-PLAN-RubricTemplateDatasource
files_modified:
  - lib/widgets/rubric/rubric_template_picker_sheet.dart
autonomous: true
requirements: [RUB-01]
---

# RubricTemplatePickerSheet -- Phase 3 Plan

## 1. Muc dich & Pham vi

Bottom sheet list for selecting a saved rubric template. Supports template selection and deletion. Shown from inside RubricBuilderComponent when teacher taps "Chon tu Template".

**Layer:** Shared widget (lib/widgets/rubric/)
**Type:** New file

## 2. File Path

- **Target:** `lib/widgets/rubric/rubric_template_picker_sheet.dart`
- **Read first:**
  - `lib/core/constants/design_tokens.dart`

## 3. UI Spec (from 03-UI-SPEC.md)

### Props

```dart
class RubricTemplatePickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> templates;  // [{name, rubric}]
  final ValueChanged<Map<String, dynamic>> onSelected;
  final ValueChanged<int> onDelete;  // index
}
```

### Layout

```
DraggableScrollableSheet (initialChildSize: 0.5, maxChildSize: 0.8)
  Container (background: DesignColors.white, topRadius: DesignRadius.lg)
    Column
      _buildSheetHandle()  // centered 40x4 bar, DesignColors.dividerMedium
      Padding (horizontal: DesignSpacing.lg, top: DesignSpacing.md)
        Text "Chon Template" (DesignTypography.headlineMedium)
      SizedBox(height: DesignSpacing.md)
      if templates.isEmpty: _buildEmptyState()
      else: Expanded ListView.separated with _buildTemplateItem(index)
```

### _buildTemplateItem(index)

```
ListTile
  contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.xs)
  leading: Container (40x40, bg DesignColors.tealPrimary.withOpacity(0.12), DesignRadius.sm)
    Icon(Icons.description, color: DesignColors.tealPrimary, size: DesignIcons.mdSize)
  title: Text template['name'] (DesignTypography.titleMedium)
  subtitle: Text "{criteriaCount} tieu chi - {totalPoints} diem" (DesignTypography.caption)
  trailing: IconButton(Icons.delete_outline, color: DesignColors.error, size: DesignIcons.smSize)
  onTap: onSelected(template)
```

### Empty state

Center with Icon(Icons.folder_open, size DesignIcons.xlSize, color: DesignColors.textTertiary), "Chua co template nao", "Luu rubric hien tai thanh template de tai su dung sau."

## 4. Flow & Logic

- Receives pre-loaded templates list (caller fetches from RubricTemplateDatasource).
- Tap item: call `onSelected` with the template map, caller pops sheet.
- Tap delete icon: show confirmation dialog ("Xoa template '{name}'? Hanh dong nay khong the hoan tac."), on confirm call `onDelete(index)`.
- Criteria count: `(template['rubric']['criteria'] as List?)?.length ?? 0`.
- Total points: `criteria.fold(0, (sum, c) => sum + c['max_points'])`.

## 5. Data Contract

- **Input:** `templates: List<Map<String, dynamic>>` each `{"name": "...", "rubric": {"criteria": [...]}}`
- **Output:** `onSelected(Map<String, dynamic>)` with selected template, `onDelete(int)` with index
- **Provider dependencies:** None

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

class RubricTemplatePickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> templates;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final ValueChanged<int> onDelete;

  const RubricTemplatePickerSheet({ ... });

  @override
  Widget build(BuildContext context) { ... }
  Widget _buildSheetHandle() { ... }
  Widget _buildTemplateItem(BuildContext context, int index) { ... }
  Widget _buildEmptyState() { ... }
}
```

## 7. Integration Points

- **Who calls this:** `RubricBuilderComponent` (Wave 2) via `showModalBottomSheet`
- **What this calls:** Nothing -- fires callbacks

## 8. Tasks

<wave>2</wave>

<task id="3.5">
  <title>Create RubricTemplatePickerSheet</title>
  <read_first>
    - lib/core/constants/design_tokens.dart
  </read_first>
  <action>
    1. Create `lib/widgets/rubric/rubric_template_picker_sheet.dart`.
    2. Class `RubricTemplatePickerSheet extends StatelessWidget`.
    3. Constructor: `required this.templates`, `required this.onSelected`, `required this.onDelete`.
    4. `build()`: Return `DraggableScrollableSheet(initialChildSize: 0.5, maxChildSize: 0.8, builder: (context, scrollController) => Container(decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(DesignRadius.lg), topRight: Radius.circular(DesignRadius.lg))), child: Column(children: [_buildSheetHandle(), Padding(padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg).copyWith(top: DesignSpacing.md), child: Align(alignment: Alignment.centerLeft, child: Text('Chon Template', style: DesignTypography.headlineMedium))), SizedBox(height: DesignSpacing.md), templates.isEmpty ? Expanded(child: _buildEmptyState()) : Expanded(child: ListView.separated(controller: scrollController, itemCount: templates.length, separatorBuilder: (_, __) => Divider(color: DesignColors.dividerLight, height: 1), itemBuilder: (ctx, i) => _buildTemplateItem(ctx, i)))])))`.
    5. `_buildSheetHandle()`: Center(child: Container(margin: EdgeInsets.only(top: DesignSpacing.sm), width: 40, height: 4, decoration: BoxDecoration(color: DesignColors.dividerMedium, borderRadius: BorderRadius.circular(2)))).
    6. `_buildTemplateItem(BuildContext context, int index)`:
       - Extract `template = templates[index]`, `rubric = template['rubric'] as Map<String, dynamic>? ?? {}`, `criteria = rubric['criteria'] as List? ?? []`, `criteriaCount = criteria.length`, `totalPoints = criteria.fold<int>(0, (sum, c) => sum + ((c as Map)['max_points'] as int? ?? 0))`.
       - Return `ListTile(contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.xs), leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: DesignColors.tealPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(DesignRadius.sm)), child: Icon(Icons.description, color: DesignColors.tealPrimary, size: DesignIcons.mdSize)), title: Text(template['name'] ?? '', style: DesignTypography.titleMedium), subtitle: Text('$criteriaCount tieu chi - $totalPoints diem', style: DesignTypography.caption), trailing: IconButton(icon: Icon(Icons.delete_outline, color: DesignColors.error, size: DesignIcons.smSize), onPressed: () => _confirmDelete(context, index)), onTap: () => onSelected(template))`.
    7. `_confirmDelete(BuildContext context, int index)`: showDialog with title "Xoa template", content "Xoa template '${templates[index]['name']}'? Hanh dong nay khong the hoan tac.", actions: TextButton "Huy" + TextButton "Xoa template" (color: DesignColors.error). On confirm: `onDelete(index)`.
    8. `_buildEmptyState()`: Center(child: Padding(padding: EdgeInsets.all(DesignSpacing.xxxl), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_open, size: DesignIcons.xlSize, color: DesignColors.textTertiary), SizedBox(height: DesignSpacing.md), Text('Chua co template nao', style: DesignTypography.titleMedium.copyWith(color: DesignColors.textSecondary)), SizedBox(height: DesignSpacing.sm), Text('Luu rubric hien tai thanh template de tai su dung sau.', style: DesignTypography.bodyMedium.copyWith(fontSize: 12), textAlign: TextAlign.center)]))).
    9. Only DesignTokens for styling.
  </action>
  <acceptance_criteria>
    - `lib/widgets/rubric/rubric_template_picker_sheet.dart` exists
    - grep "class RubricTemplatePickerSheet extends StatelessWidget" lib/widgets/rubric/rubric_template_picker_sheet.dart
    - grep "Chon Template" lib/widgets/rubric/rubric_template_picker_sheet.dart
    - grep "Chua co template nao" lib/widgets/rubric/rubric_template_picker_sheet.dart (empty state)
    - grep "Xoa template" lib/widgets/rubric/rubric_template_picker_sheet.dart (delete confirmation)
    - grep "DesignColors\." lib/widgets/rubric/rubric_template_picker_sheet.dart
    - NOT grep "Color(0x" lib/widgets/rubric/rubric_template_picker_sheet.dart
    - flutter analyze lib/widgets/rubric/rubric_template_picker_sheet.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Template list renders with name, criteria count, total points.
- Empty state shown when no templates saved.
- Tap item fires onSelected with template data.
- Delete with confirmation dialog fires onDelete.
- All styling via DesignTokens.

---
phase: 3
plan_id: 03-PLAN-RubricBuilderComponent
wave: 2
depends_on:
  - 03-PLAN-ReadOnlyRubricViewer
  - 03-PLAN-RubricTemplateDatasource
files_modified:
  - lib/widgets/rubric/rubric_builder_component.dart
autonomous: true
requirements: [RUB-01, RUB-02]
---

# RubricBuilderComponent -- Phase 3 Plan

## 1. Muc dich & Pham vi

Full-screen bottom sheet content for building rubrics. Teachers add/edit/delete criteria, each with multiple scoring levels (points + descriptions). Supports locked mode (D-09), template save/load (D-05), and points auto-calculation (D-06). This is the primary RUB-01 and RUB-02 implementation.

**Layer:** Shared widget (lib/widgets/rubric/)
**Type:** New file

## 2. File Path

- **Target:** `lib/widgets/rubric/rubric_builder_component.dart`
- **Read first:**
  - `lib/core/constants/design_tokens.dart` (all tokens)
  - `lib/widgets/rubric/read_only_rubric_viewer.dart` (sibling widget, understand shared patterns)
  - `lib/data/datasources/rubric_template_datasource.dart` (template CRUD API)
  - `lib/core/services/profile_metadata_service.dart` (understand metadata API for templates)

## 3. UI Spec (from 03-UI-SPEC.md)

### Props

```dart
class RubricBuilderComponent extends StatefulWidget {
  final Map<String, dynamic>? initialRubric;
  final bool isLocked;       // D-09 -- entire form read-only
  final ValueChanged<Map<String, dynamic>?> onSave;
}
```

### Layout hierarchy

```
DraggableScrollableSheet (initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95)
  Container (background: DesignColors.moonLight)
    Column
      _buildHeader()
        Row
          Text "Thiet lap Rubric" (DesignTypography.headlineMedium)
          Spacer
          IconButton close (Icons.close, DesignIcons.mdSize)
        if isLocked: Container (DesignColors.warning bg at 12% opacity)
          Row: Icon(Icons.lock, DesignColors.warning) + Text "Rubric da khoa vi co hoc sinh dang lam bai" (DesignTypography.caption)
      Divider (DesignColors.dividerLight)
      Expanded
        ListView.separated
          for each criterion: _buildCriterionCard(index)
          _buildAddCriterionButton()
      _buildBottomActions()
```

### _buildCriterionCard(index)

```
Container (background: DesignColors.white, borderRadius: DesignRadius.md, elevation: DesignElevation.level1)
  padding: DesignSpacing.lg
  Column
    Row (criterion header)
      Expanded: TextFormField "Ten tieu chi" (DesignTypography.titleMedium)
        hintText: "VD: Lap luan"
      Container (points badge) -- bg DesignColors.primary.withOpacity(0.12), DesignRadius.full
        Text "{max_points} diem" (DesignTypography.caption, color: DesignColors.primary)
      SizedBox(width: DesignSpacing.sm)
      IconButton expand/collapse (Icons.expand_more / expand_less, DesignIcons.smSize)
      if !isLocked: IconButton delete (Icons.delete_outline, DesignIcons.smSize, color: DesignColors.error)
    if expanded:
      SizedBox(height: DesignSpacing.md)
      for each level: _buildLevelRow(criterionIndex, levelIndex)
      if !isLocked: _buildAddLevelButton()
```

### _buildLevelRow(criterionIndex, levelIndex)

```
Container (background: DesignColors.moonLight, borderRadius: DesignRadius.sm)
  padding: DesignSpacing.md
  Row
    SizedBox(width: 60)
      TextFormField points (keyboardType: number, decoration: "Diem", style: DesignTypography.bodyMedium fontWeight w600)
    SizedBox(width: DesignSpacing.sm)
    Expanded: TextFormField description (decoration: "Mo ta muc diem", DesignTypography.bodyMedium, maxLines: 2)
    if !isLocked: IconButton remove (Icons.close, DesignIcons.xsSize, color: DesignColors.textTertiary)
```

### _buildBottomActions()

```
Container
  padding: DesignSpacing.lg
  decoration: BoxDecoration(border: Border(top: DesignColors.dividerLight))
  Column
    Row (template actions)
      Expanded: OutlinedButton "Chon tu Template" (Icons.folder_open)
      SizedBox(width: DesignSpacing.sm)
      Expanded: OutlinedButton "Luu thanh Template" (Icons.save_outlined)
    SizedBox(height: DesignSpacing.md)
    Row (total points display)
      Text "Tong diem:" (DesignTypography.bodyMedium)
      Text "{totalPoints} diem" (DesignTypography.titleMedium, color: DesignColors.primary)
    SizedBox(height: DesignSpacing.md)
    SizedBox(width: double.infinity)
      ElevatedButton "Luu Rubric"
        backgroundColor: DesignColors.primary
        height: 48dp (DesignComponents.buttonHeightLarge)
        borderRadius: DesignRadius.sm
        style: DesignTypography.titleMedium, color: DesignColors.white
```

### Empty state (no criteria yet)

Center with text "Chua co tieu chi nao" (DesignTypography.titleMedium, color: DesignColors.textSecondary) + "Nhan '+ Them tieu chi' de bat dau xay dung rubric cho cau hoi nay." (DesignTypography.bodyMedium, fontSize: 12).

### New criterion default

Pre-populate 2 levels: Level 1: points=5, description="" / Level 2: points=0, description="".

### Animation

Bottom sheet opens with 300ms Curves.easeInOut. Criterion expand/collapse: AnimatedCrossFade with 150ms.

## 4. Flow & Logic

1. On init, parse `initialRubric` into local state: `List<_CriterionState>` where each has `id`, `name`, `maxPoints`, `List<_LevelState>`, `isExpanded`.
2. If `initialRubric` is null, show empty state.
3. Add criterion: append new `_CriterionState` with UUID-like id (`'crit-${DateTime.now().millisecondsSinceEpoch}'`), empty name, 2 default levels (5 pts and 0 pts), `isExpanded: true`.
4. Delete criterion: show confirmation dialog (WarningDialog per UI-SPEC: "Xoa tieu chi '{name}'? Toan bo muc diem trong tieu chi nay se bi xoa."). On confirm, remove from list.
5. Add level: append to criterion's levels with points=0, description="".
6. Delete level: remove at index (no confirmation per UI-SPEC for levels).
7. Points auto-calc: `totalPoints = criteria.fold(0, (sum, c) => sum + c.maxPoints)` where `c.maxPoints = max(c.levels.map(l => l.points))`.
8. "Luu Rubric" button: build JSONB per D-02 schema, call `onSave(rubricJson)`, pop sheet.
9. "Luu thanh Template": prompt for template name via simple dialog with TextFormField + "Luu" button. Validate non-empty. Call `RubricTemplateDatasource.saveRubricTemplate(name, currentRubricJson)`.
10. "Chon tu Template": call `RubricTemplateDatasource.getSavedRubrics()`, open `RubricTemplatePickerSheet` bottom sheet. On selection, replace current criteria state with template's rubric.
11. Locked mode (D-09): all TextFormFields have `enabled: false`, no add/delete buttons rendered, warning banner at top.
12. Validation on save: each criterion must have non-empty name, at least 2 levels, each level must have description. Show error borders per UI-SPEC.

## 5. Data Contract

- **Input:** `initialRubric: Map<String, dynamic>?` (D-02 schema), `isLocked: bool`, `onSave: ValueChanged<Map<String, dynamic>?>`
- **Output:** Calls `onSave` with rubric JSONB matching D-02:
  ```json
  { "criteria": [{ "id": "crit-1", "name": "...", "max_points": 5, "levels": [{ "points": 5, "description": "..." }] }] }
  ```
- **Provider dependencies:** None (StatefulWidget with local state)
- **Supabase calls:** Via `RubricTemplateDatasource` for template save/load

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/data/datasources/rubric_template_datasource.dart';
import 'package:ai_mls/widgets/rubric/rubric_template_picker_sheet.dart';
import 'package:flutter/material.dart';

class RubricBuilderComponent extends StatefulWidget {
  final Map<String, dynamic>? initialRubric;
  final bool isLocked;
  final ValueChanged<Map<String, dynamic>?> onSave;

  const RubricBuilderComponent({ ... });

  @override
  State<RubricBuilderComponent> createState() => _RubricBuilderComponentState();
}

class _RubricBuilderComponentState extends State<RubricBuilderComponent> {
  late List<_CriterionState> _criteria;
  final Map<int, bool> _expandedMap = {};

  @override
  void initState() { super.initState(); _parseCriteria(); }

  void _parseCriteria() { ... }
  Map<String, dynamic> _buildRubricJson() { ... }
  int get _totalPoints => ...;

  void _addCriterion() { ... }
  void _deleteCriterion(int index) { ... }
  void _addLevel(int criterionIndex) { ... }
  void _deleteLevel(int criterionIndex, int levelIndex) { ... }
  void _saveRubric() { ... }
  Future<void> _saveAsTemplate() async { ... }
  Future<void> _openTemplatePicker() async { ... }
  bool _validate() { ... }

  @override
  Widget build(BuildContext context) { ... }
  Widget _buildHeader() { ... }
  Widget _buildCriterionCard(int index) { ... }
  Widget _buildLevelRow(int criterionIndex, int levelIndex) { ... }
  Widget _buildAddCriterionButton() { ... }
  Widget _buildAddLevelButton(int criterionIndex) { ... }
  Widget _buildBottomActions() { ... }
  Widget _buildEmptyState() { ... }
}

class _CriterionState { String id; String name; List<_LevelState> levels; }
class _LevelState { int points; String description; }
```

## 7. Integration Points

- **Who calls this:** `TeacherCreateAssignmentScreen` (Wave 3) via `showModalBottomSheet(builder: (_) => RubricBuilderComponent(...))`
- **What this calls:**
  - `RubricTemplateDatasource.getSavedRubrics()` / `.saveRubricTemplate()` / `.deleteRubricTemplate()`
  - `RubricTemplatePickerSheet` (Wave 2) for template selection

## 8. Tasks

<wave>2</wave>

<task id="3.4">
  <title>Create RubricBuilderComponent full-screen bottom sheet</title>
  <read_first>
    - lib/core/constants/design_tokens.dart (all token values)
    - lib/data/datasources/rubric_template_datasource.dart (template CRUD API from Wave 1)
    - lib/widgets/rubric/read_only_rubric_viewer.dart (sibling widget patterns)
  </read_first>
  <action>
    1. Create `lib/widgets/rubric/rubric_builder_component.dart`.
    2. Define private classes `_CriterionState` with fields: `String id`, `String name`, `List<_LevelState> levels`, `TextEditingController nameController`. Define `_LevelState` with fields: `int points`, `String description`, `TextEditingController pointsController`, `TextEditingController descriptionController`.
    3. Class `RubricBuilderComponent extends StatefulWidget` with props: `initialRubric: Map<String, dynamic>?`, `isLocked: bool = false`, `onSave: ValueChanged<Map<String, dynamic>?>`.
    4. State class `_RubricBuilderComponentState`:
       - `late List<_CriterionState> _criteria;`
       - `final Set<int> _expandedIndices = {};`
       - `final Map<String, String?> _errors = {};` (for validation)
       - `initState()`: call `_parseCriteria()` which reads `widget.initialRubric` and populates `_criteria`. If null or empty criteria, set `_criteria = []`.
       - `dispose()`: dispose all TextEditingControllers in _criteria and their levels.
    5. `_parseCriteria()`: iterate `widget.initialRubric?['criteria']` as List, for each create `_CriterionState` with `id = criterion['id']`, `name = criterion['name']`, levels from `criterion['levels']` list. Create controllers with initial values.
    6. `int get _totalPoints`: `_criteria.fold<int>(0, (sum, c) => sum + (c.levels.isEmpty ? 0 : c.levels.map((l) => l.points).reduce(max)))`. Import `dart:math` for `max`.
    7. `Map<String, dynamic> _buildRubricJson()`: Returns D-02 compliant JSON. For each criterion: `{"id": c.id, "name": c.name, "max_points": max of level points, "levels": [{"points": l.points, "description": l.description}]}`.
    8. `_addCriterion()`: `setState` appending `_CriterionState(id: 'crit-${DateTime.now().millisecondsSinceEpoch}', name: '', levels: [_LevelState(points: 5, description: '', ...), _LevelState(points: 0, description: '', ...)])`. Add index to `_expandedIndices`.
    9. `_deleteCriterion(int index)`: Show confirmation dialog: title "Xoa tieu chi", content "Xoa tieu chi '${_criteria[index].name}'? Toan bo muc diem trong tieu chi nay se bi xoa.", actions: TextButton "Huy" + TextButton "Xoa tieu chi" (color: DesignColors.error). On confirm: dispose controllers, `setState(() => _criteria.removeAt(index))`.
    10. `_addLevel(int criterionIndex)`: `setState` appending `_LevelState(points: 0, description: '', ...)` to `_criteria[criterionIndex].levels`.
    11. `_deleteLevel(int ci, int li)`: dispose controllers, `setState(() => _criteria[ci].levels.removeAt(li))`. No confirmation.
    12. `bool _validate()`: For each criterion: name must be non-empty, must have >= 2 levels, each level must have description non-empty. Set `_errors` map entries for fields that fail. Return true if all pass.
    13. `_saveRubric()`: If `!_validate()` return. Build JSON via `_buildRubricJson()`. If criteria is empty, call `widget.onSave(null)` else `widget.onSave(json)`. `Navigator.pop(context)`.
    14. `_saveAsTemplate()`: Show dialog with TextFormField for template name. Validate non-empty (error text: "Vui long nhap ten template."). On confirm: call `await RubricTemplateDatasource.saveRubricTemplate(name, _buildRubricJson())`. Show SnackBar "Da luu template".
    15. `_openTemplatePicker()`: `final templates = await RubricTemplateDatasource.getSavedRubrics()`. Show `showModalBottomSheet` with `RubricTemplatePickerSheet(templates: templates, onSelected: (t) { _loadTemplate(t); Navigator.pop(context); }, onDelete: (i) async { await RubricTemplateDatasource.deleteRubricTemplate(i); ... })`.
    16. `_loadTemplate(Map<String, dynamic> template)`: Dispose current controllers. Parse `template['rubric']` same as `_parseCriteria()`. `setState`.

    17. `build()` method: Return `DraggableScrollableSheet(initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95, builder: (context, scrollController) => Container(decoration: BoxDecoration(color: DesignColors.moonLight, borderRadius: BorderRadius.only(topLeft: Radius.circular(DesignRadius.lg), topRight: Radius.circular(DesignRadius.lg))), child: Column(children: [_buildHeader(), Divider(color: DesignColors.dividerLight, height: 1), Expanded(child: _criteria.isEmpty ? _buildEmptyState() : ListView.separated(..., controller: scrollController)), if (!widget.isLocked) _buildBottomActions()])))`.

    18. `_buildHeader()`: Padding(padding: EdgeInsets.fromLTRB(DesignSpacing.lg, DesignSpacing.xxxl, DesignSpacing.lg, DesignSpacing.md)). Row: Text('Thiet lap Rubric', style: DesignTypography.headlineMedium), Spacer, IconButton(Icons.close, size: DesignIcons.mdSize, onPressed: () => Navigator.pop(context)). Below row, if widget.isLocked: Container with DesignColors.warning.withValues(alpha: 0.12) bg, Row with Icon(Icons.lock) + Text "Rubric da khoa vi co hoc sinh dang lam bai" in DesignTypography.caption.

    19. `_buildCriterionCard(int index)`: Container(margin: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.sm), padding: EdgeInsets.all(DesignSpacing.lg), decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.circular(DesignRadius.md), boxShadow: DesignElevation.level1)). Column: criterion header Row (TextFormField for name, points badge, expand/collapse, delete), AnimatedCrossFade for expand/collapse with firstChild=SizedBox.shrink() secondChild=Column of level rows + add level button. Duration: Duration(milliseconds: 150).

    20. `_buildLevelRow(int ci, int li)`: Container(margin: EdgeInsets.only(bottom: DesignSpacing.sm), padding: EdgeInsets.all(DesignSpacing.md), decoration: BoxDecoration(color: DesignColors.moonLight, borderRadius: BorderRadius.circular(DesignRadius.sm))). Row: SizedBox(width: 60, child: TextFormField for points number input), SizedBox(width: DesignSpacing.sm), Expanded TextFormField for description (maxLines: 2), if !isLocked: IconButton close.

    21. `_buildAddCriterionButton()`: Padding(padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg)). OutlinedButton.icon with Icons.add + "Them tieu chi". Style: foregroundColor DesignColors.primary, side: BorderSide(color: DesignColors.primary), minimumSize: Size(double.infinity, 40).

    22. `_buildBottomActions()`: Container with top border Divider, padding DesignSpacing.lg. Column: Row of 2 Expanded OutlinedButtons ("Chon tu Template" + "Luu thanh Template"), SizedBox, Row showing total points, SizedBox, full-width ElevatedButton "Luu Rubric" (bg: DesignColors.primary, height 48, text white).

    23. `_buildEmptyState()`: Center Column with Icon(Icons.article_outlined, size: 48, color: DesignColors.textTertiary), Text "Chua co tieu chi nao", Text "Nhan '+ Them tieu chi' de bat dau xay dung rubric cho cau hoi nay.", and _buildAddCriterionButton().

    24. All TextFormFields have `enabled: !widget.isLocked`. Validation errors show red border (DesignColors.error) and error text in DesignTypography.caption color DesignColors.error.

    25. Use ONLY DesignTokens. No raw Color(), EdgeInsets, font sizes except explicit overrides.
  </action>
  <acceptance_criteria>
    - `lib/widgets/rubric/rubric_builder_component.dart` exists
    - grep "class RubricBuilderComponent extends StatefulWidget" lib/widgets/rubric/rubric_builder_component.dart
    - grep "DraggableScrollableSheet" lib/widgets/rubric/rubric_builder_component.dart
    - grep "Thiet lap Rubric" lib/widgets/rubric/rubric_builder_component.dart
    - grep "Them tieu chi" lib/widgets/rubric/rubric_builder_component.dart
    - grep "Luu Rubric" lib/widgets/rubric/rubric_builder_component.dart
    - grep "Luu thanh Template" lib/widgets/rubric/rubric_builder_component.dart
    - grep "Chon tu Template" lib/widgets/rubric/rubric_builder_component.dart
    - grep "isLocked" lib/widgets/rubric/rubric_builder_component.dart (D-09 support)
    - grep "RubricTemplateDatasource" lib/widgets/rubric/rubric_builder_component.dart (template integration)
    - grep "AnimatedCrossFade" lib/widgets/rubric/rubric_builder_component.dart (expand/collapse animation)
    - grep "DesignColors\." lib/widgets/rubric/rubric_builder_component.dart
    - NOT grep "Color(0x" lib/widgets/rubric/rubric_builder_component.dart
    - NOT grep "print(" lib/widgets/rubric/rubric_builder_component.dart
    - flutter analyze lib/widgets/rubric/rubric_builder_component.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Teacher can add criteria with name, multiple levels with points + descriptions.
- Teacher can delete criteria (with confirmation) and levels (without confirmation).
- Points auto-calculated as max of level points per criterion.
- Template save prompts for name, stores via ProfileMetadataService.
- Template load opens picker sheet, replaces criteria on selection.
- Locked mode (D-09) disables all inputs, shows warning banner.
- Validation prevents saving with empty criterion names, <2 levels, or empty level descriptions.
- Empty state shown when no criteria added yet.

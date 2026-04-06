---
phase: 3
plan_id: 03-PLAN-ReadOnlyRubricViewer
wave: 1
depends_on: []
files_modified:
  - lib/widgets/rubric/read_only_rubric_viewer.dart
autonomous: true
requirements: [RUB-04]
---

# ReadOnlyRubricViewer -- Phase 3 Plan

## 1. Muc dich & Pham vi

Dumb StatelessWidget that renders a rubric's criteria and levels in read-only mode. This is the most reused widget in Phase 3 -- appears in Student Assignment Detail, Student Workspace bottom sheet, Teacher Grading review, and (Phase 6) AI feedback display.

**Layer:** Shared widget (lib/widgets/rubric/)
**Type:** New file

## 2. File Path

- **Target:** `lib/widgets/rubric/read_only_rubric_viewer.dart`
- **Read first:**
  - `lib/core/constants/design_tokens.dart` (DesignColors, DesignSpacing, DesignTypography, DesignRadius, DesignIcons)
  - `lib/widgets/rubric/` (directory does not exist yet -- create it)

## 3. UI Spec (from 03-UI-SPEC.md)

### Props

```dart
class ReadOnlyRubricViewer extends StatelessWidget {
  final Map<String, dynamic>? rubric;           // required -- the rubric JSONB
  final Map<String, int>? selectedLevels;       // optional -- criterion_id to level_index (Phase 6 fills)
  final bool showHeader;                        // default: true -- shows "Tieu chi cham diem" title
  final bool compact;                           // default: false -- when true, hides level descriptions
}
```

### Layout (full mode, compact=false)

```
Container (padding: DesignSpacing.lg)
  Column
    if showHeader:
      Row
        Icon(Icons.grading, DesignIcons.smSize, color: DesignColors.tealPrimary)
        SizedBox(width: DesignSpacing.sm)
        Text "Tieu chi cham diem" (DesignTypography.titleMedium)
      SizedBox(height: DesignSpacing.md)
    for each criterion:
      _buildCriterionSection(criterion, selectedLevelIndex)
      if not last: Divider(color: DesignColors.dividerLight, height: DesignSpacing.lg)
```

### _buildCriterionSection(criterion, selectedLevelIndex)

```
Column (crossAxisAlignment: start)
  Row
    Expanded: Text criterion['name'] (DesignTypography.titleMedium, fontSize: 14sp override)
    Container (points badge)
      background: DesignColors.primary.withOpacity(0.12)
      borderRadius: DesignRadius.full
      padding: horizontal DesignSpacing.sm, vertical DesignSpacing.xs
      Text "Toi da {max_points}d" (DesignTypography.caption, color: DesignColors.primary)
  SizedBox(height: DesignSpacing.sm)
  for each level in criterion['levels']:
    _buildLevelItem(level, isSelected: levelIndex == selectedLevelIndex)
```

### _buildLevelItem(level, isSelected)

```
Container
  margin: EdgeInsets.only(bottom: DesignSpacing.xs)
  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm)
  decoration: BoxDecoration
    color: isSelected ? DesignColors.primary.withOpacity(0.08) : DesignColors.white
    border: Border.all(color: isSelected ? DesignColors.primary : DesignColors.dividerLight)
    borderRadius: DesignRadius.sm
  Row
    Container (points chip)
      width: 36dp
      alignment: center
      padding: vertical DesignSpacing.xs
      decoration: BoxDecoration(color: DesignColors.moonMedium, borderRadius: DesignRadius.xs)
      Text "{points}d" (DesignTypography.caption, fontWeight: semiBold w600)
    SizedBox(width: DesignSpacing.sm)
    Expanded: Text level['description'] (DesignTypography.bodyMedium, fontSize: 12sp override)
    if isSelected: Icon(Icons.check_circle, color: DesignColors.primary, size: DesignIcons.smSize)
```

### Layout (compact=true, for assignment detail preview card)

```
Column
  for each criterion:
    Padding (bottom: DesignSpacing.xs)
      Row
        Icon(Icons.check_circle_outline, DesignIcons.xsSize, color: DesignColors.tealPrimary)
        SizedBox(width: DesignSpacing.sm)
        Expanded: Text criterion['name'] (DesignTypography.bodyMedium)
        Text "{max_points}d" (DesignTypography.bodyMedium, fontWeight: semiBold w600, color: DesignColors.primary)
```

## 4. Flow & Logic

- If `rubric` is null or `rubric['criteria']` is null/empty, return `SizedBox.shrink()` (component simply not shown per UI-SPEC empty state rule).
- Parse `rubric['criteria']` as `List<dynamic>`, iterate each as `Map<String, dynamic>`.
- For each criterion, read `criterion['id']`, `criterion['name']`, `criterion['max_points']`, `criterion['levels']`.
- If `selectedLevels` is provided and contains `criterion['id']`, highlight that level index.
- `compact` mode only shows criterion name + max_points, no level descriptions.

## 5. Data Contract

- **Input:** `rubric: Map<String, dynamic>?` matching D-02 schema:
  ```json
  { "criteria": [{ "id": "crit-1", "name": "...", "max_points": 5, "levels": [{ "points": 5, "description": "..." }] }] }
  ```
- **Input:** `selectedLevels: Map<String, int>?` -- maps criterion `id` to selected level index
- **Output:** Pure display, no callbacks
- **Provider dependencies:** None (dumb widget)
- **Supabase calls:** None

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

class ReadOnlyRubricViewer extends StatelessWidget {
  final Map<String, dynamic>? rubric;
  final Map<String, int>? selectedLevels;
  final bool showHeader;
  final bool compact;

  const ReadOnlyRubricViewer({
    super.key,
    required this.rubric,
    this.selectedLevels,
    this.showHeader = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) { ... }

  Widget _buildCriterionSection(Map<String, dynamic> criterion, int? selectedLevelIndex) { ... }

  Widget _buildLevelItem(Map<String, dynamic> level, {required bool isSelected}) { ... }

  Widget _buildCompactCriterion(Map<String, dynamic> criterion) { ... }
}
```

## 7. Integration Points

- **Who calls this:**
  - `StudentAssignmentDetailScreen` (Wave 4) -- compact + full mode with expand toggle
  - `StudentWorkspaceScreen` (Wave 4) -- inside bottom sheet from "Xem Tieu chi" button
  - `QuestionAnswerCard` (Wave 3) -- replaces existing `_buildRubric()` method
  - `RubricBuilderComponent` (Wave 2) -- locked mode can reuse this for preview
- **What this calls:** Nothing (pure rendering)

## 8. Tasks

<wave>1</wave>

<task id="3.1">
  <title>Create ReadOnlyRubricViewer widget</title>
  <read_first>
    - lib/core/constants/design_tokens.dart (token values for DesignColors, DesignSpacing, DesignTypography, DesignRadius, DesignIcons)
    - lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart (existing _buildRubric to understand current pattern and replace)
  </read_first>
  <action>
    1. Create directory `lib/widgets/rubric/` if it does not exist.
    2. Create `lib/widgets/rubric/read_only_rubric_viewer.dart` with class `ReadOnlyRubricViewer extends StatelessWidget`.
    3. Constructor params: `required this.rubric` (Map<String, dynamic>?), `this.selectedLevels` (Map<String, int>?), `this.showHeader = true`, `this.compact = false`.
    4. `build()` method:
       - If `rubric == null` or `(rubric!['criteria'] as List?)?.isEmpty ?? true`, return `const SizedBox.shrink()`.
       - Parse `criteria = rubric!['criteria'] as List<dynamic>`.
       - If `compact`, return Column of `_buildCompactCriterion(criterion)` for each.
       - Otherwise, return Container with `padding: const EdgeInsets.all(DesignSpacing.lg)` containing Column:
         - If `showHeader`: Row with `Icon(Icons.grading, size: DesignIcons.smSize, color: DesignColors.tealPrimary)`, `SizedBox(width: DesignSpacing.sm)`, `Text('Tieu chi cham diem', style: DesignTypography.titleMedium)`, then `SizedBox(height: DesignSpacing.md)`.
         - For each criterion (with index), call `_buildCriterionSection(criterion as Map<String, dynamic>, selectedLevelIndex)`.
         - Between criteria (not after last): `Divider(color: DesignColors.dividerLight, height: DesignSpacing.lg)`.
    5. `_buildCriterionSection(Map<String, dynamic> criterion, int? selectedLevelIndex)`:
       - Column with crossAxisAlignment: CrossAxisAlignment.start.
       - Row: Expanded Text `criterion['name']` with `DesignTypography.titleMedium.copyWith(fontSize: 14)`, Container points badge with `DesignColors.primary.withValues(alpha: 0.12)` background, `DesignRadius.full` borderRadius, padding horizontal `DesignSpacing.sm` vertical `DesignSpacing.xs`, Text `'Toi da ${criterion['max_points']}d'` with `DesignTypography.caption.copyWith(color: DesignColors.primary)`.
       - SizedBox(height: DesignSpacing.sm).
       - For each level in `criterion['levels'] as List<dynamic>`: `_buildLevelItem(level as Map<String, dynamic>, isSelected: levelIdx == selectedLevelIndex)`.
    6. `_buildLevelItem(Map<String, dynamic> level, {required bool isSelected})`:
       - Container with margin bottom `DesignSpacing.xs`, padding symmetric horizontal `DesignSpacing.md` vertical `DesignSpacing.sm`.
       - BoxDecoration: color `isSelected ? DesignColors.primary.withValues(alpha: 0.08) : DesignColors.white`, border `Border.all(color: isSelected ? DesignColors.primary : DesignColors.dividerLight)`, borderRadius `DesignRadius.sm`.
       - Row: Container(width: 36, alignment: Alignment.center, padding vertical `DesignSpacing.xs`, decoration BoxDecoration(color: DesignColors.moonMedium, borderRadius: DesignRadius.xs), child: Text '${level['points']}d' with `DesignTypography.caption.copyWith(fontWeight: FontWeight.w600)`).
       - SizedBox(width: DesignSpacing.sm).
       - Expanded Text `level['description']` with `DesignTypography.bodyMedium.copyWith(fontSize: 12)`.
       - If isSelected: `Icon(Icons.check_circle, color: DesignColors.primary, size: DesignIcons.smSize)`.
    7. `_buildCompactCriterion(Map<String, dynamic> criterion)`:
       - Padding bottom `DesignSpacing.xs`, Row: Icon(Icons.check_circle_outline, size: DesignIcons.xsSize, color: DesignColors.tealPrimary), SizedBox(width: DesignSpacing.sm), Expanded Text criterion['name'] with DesignTypography.bodyMedium, Text '${criterion['max_points']}d' with DesignTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: DesignColors.primary).
    8. Add Semantics labels: each level item gets `Semantics(label: '${level['points']} diem - ${level['description']}')`.
    9. Use ONLY design tokens. No raw Color(), no raw EdgeInsets numbers, no raw font sizes except the explicit overrides (14, 12) specified in UI-SPEC.
  </action>
  <acceptance_criteria>
    - `lib/widgets/rubric/read_only_rubric_viewer.dart` exists
    - grep "class ReadOnlyRubricViewer extends StatelessWidget" lib/widgets/rubric/read_only_rubric_viewer.dart
    - grep "DesignColors\." lib/widgets/rubric/read_only_rubric_viewer.dart (uses design tokens)
    - grep "DesignTypography\." lib/widgets/rubric/read_only_rubric_viewer.dart
    - grep "DesignSpacing\." lib/widgets/rubric/read_only_rubric_viewer.dart
    - grep "selectedLevels" lib/widgets/rubric/read_only_rubric_viewer.dart (Phase 6 ready)
    - grep "compact" lib/widgets/rubric/read_only_rubric_viewer.dart (compact mode exists)
    - grep "Semantics" lib/widgets/rubric/read_only_rubric_viewer.dart (accessibility)
    - NOT grep "Color(0x" lib/widgets/rubric/read_only_rubric_viewer.dart (no raw colors)
    - flutter analyze lib/widgets/rubric/read_only_rubric_viewer.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- ReadOnlyRubricViewer renders rubric criteria with levels in full mode (showHeader + level descriptions + points chips).
- ReadOnlyRubricViewer renders compact mode showing only criterion names + max_points.
- `selectedLevels` param highlights the correct level when provided.
- Returns SizedBox.shrink() when rubric is null or criteria list empty.
- All styling uses DesignTokens exclusively.
- Accessibility: Semantics labels on level items.

## 10. must_haves

```yaml
must_haves:
  truths:
    - "Teacher can see rubric criteria and levels in grading view"
    - "Student can preview rubric criteria before starting assignment"
    - "Student can view rubric criteria during workspace via bottom sheet"
    - "Rubric viewer highlights teacher-selected levels (Phase 6: AI-selected)"
    - "Rubric viewer shows compact summary in assignment detail"
  artifacts:
    - path: "lib/widgets/rubric/read_only_rubric_viewer.dart"
      provides: "Reusable read-only rubric display component"
      min_lines: 80
    - path: "lib/widgets/rubric/rubric_builder_component.dart"
      provides: "Full-screen rubric editor for teachers"
      min_lines: 200
    - path: "lib/widgets/rubric/rubric_summary_button.dart"
      provides: "Status indicator button in question editor"
      min_lines: 40
    - path: "lib/widgets/rubric/interactive_rubric_grader.dart"
      provides: "Clickable level cards for teacher grading"
      min_lines: 150
    - path: "lib/widgets/rubric/rubric_template_picker_sheet.dart"
      provides: "Template selection bottom sheet"
      min_lines: 60
  key_links:
    - from: "lib/widgets/rubric/rubric_builder_component.dart"
      to: "teacher_create_assignment_screen.dart"
      via: "showModalBottomSheet onSave callback updates question rubric"
      pattern: "RubricBuilderComponent.*onSave"
    - from: "lib/widgets/rubric/interactive_rubric_grader.dart"
      to: "teacher_submission_providers.dart"
      via: "onLevelSelected/onManualOverride calls overrideScore()"
      pattern: "overrideScore"
    - from: "lib/widgets/rubric/read_only_rubric_viewer.dart"
      to: "student_assignment_workspace_screen.dart"
      via: "showModalBottomSheet wraps ReadOnlyRubricViewer"
      pattern: "ReadOnlyRubricViewer"
    - from: "lib/widgets/rubric/rubric_template_picker_sheet.dart"
      to: "lib/core/services/profile_metadata_service.dart"
      via: "ProfileMetadataService.get/set for saved_rubrics"
      pattern: "ProfileMetadataService"
```

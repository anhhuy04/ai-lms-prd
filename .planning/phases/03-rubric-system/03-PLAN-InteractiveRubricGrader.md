---
phase: 3
plan_id: 03-PLAN-InteractiveRubricGrader
wave: 2
depends_on:
  - 03-PLAN-ReadOnlyRubricViewer
files_modified:
  - lib/widgets/rubric/interactive_rubric_grader.dart
autonomous: true
requirements: [RUB-02]
---

# InteractiveRubricGrader -- Phase 3 Plan

## 1. Muc dich & Pham vi

Interactive widget for teacher grading using rubric criteria. Teachers click level cards to score per criterion (D-04 happy path) or override with a custom score + mandatory reason (D-04 exception path). Used in teacher submission detail screen for essay/shortAnswer questions that have rubrics attached.

**Layer:** Shared widget (lib/widgets/rubric/)
**Type:** New file

## 2. File Path

- **Target:** `lib/widgets/rubric/interactive_rubric_grader.dart`
- **Read first:**
  - `lib/core/constants/design_tokens.dart`
  - `lib/widgets/rubric/read_only_rubric_viewer.dart` (similar layout patterns for criteria/levels)
  - `lib/presentation/providers/teacher_submission_providers.dart` lines 300-305 (overrideScore signature)
  - `lib/data/datasources/grade_override_datasource.dart` (existing override data layer)

## 3. UI Spec (from 03-UI-SPEC.md)

### Props

```dart
class InteractiveRubricGrader extends StatefulWidget {
  final Map<String, dynamic> rubric;
  final double? currentScore;
  final String submissionAnswerId;
  final Function(double points, String criterionId) onLevelSelected;
  final Function(double score, String reason) onManualOverride;
}
```

### Layout

```
Container (padding: DesignSpacing.lg)
  Column
    Row
      Icon(Icons.grading, DesignIcons.smSize, color: DesignColors.primary)
      SizedBox(width: DesignSpacing.sm)
      Text "Cham diem theo Rubric" (DesignTypography.titleMedium)
    SizedBox(height: DesignSpacing.md)
    for each criterion: _buildCriterionGradingRow(criterion)
      if not last: SizedBox(height: DesignSpacing.lg)
    Divider(color: DesignColors.dividerLight, height: DesignSpacing.lg)
    _buildTotalScoreRow()
```

### _buildCriterionGradingRow(criterion)

```
Column (crossAxisAlignment: start)
  Row
    Expanded: Text criterion['name'] (DesignTypography.titleMedium, fontSize: 14sp override)
    Text "{selectedPoints}/{max_points} diem" (DesignTypography.bodyMedium, fontWeight: w600)
      color: hasSelection ? DesignColors.primary : DesignColors.textTertiary
  SizedBox(height: DesignSpacing.sm)
  Wrap (spacing: DesignSpacing.sm, runSpacing: DesignSpacing.sm)
    for each level: _buildLevelCard(criterion, level, isSelected)
```

### _buildLevelCard(criterion, level, isSelected)

```
GestureDetector(onTap: -> selectLevel)
  AnimatedContainer
    duration: 150ms
    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm)
    constraints: BoxConstraints(minWidth: 80, maxWidth: 200)
    decoration: BoxDecoration
      color: isSelected ? DesignColors.primary.withOpacity(0.1) : DesignColors.white
      border: Border.all(color: isSelected ? DesignColors.primary : DesignColors.dividerLight, width: isSelected ? 2 : 1)
      borderRadius: DesignRadius.sm
      boxShadow: isSelected ? [DesignElevation.level1] : []
    Column (crossAxisAlignment: start)
      Row
        Text "{points}d" (DesignTypography.caption, fontWeight: w600, color: isSelected ? DesignColors.primary : DesignColors.textPrimary)
        if isSelected: Icon(Icons.check_circle, size: DesignIcons.xsSize, color: DesignColors.primary)
      SizedBox(height: DesignSpacing.xs)
      Text description (DesignTypography.caption, maxLines: 2, overflow: ellipsis)
```

### _buildTotalScoreRow()

```
Row
  Expanded: Text "Tong diem:" (DesignTypography.titleMedium)
  Text "{totalSelected}/{totalMax} diem" (DesignTypography.headlineMedium, color: DesignColors.primary)
  SizedBox(width: DesignSpacing.sm)
  IconButton (Icons.edit, size: DesignIcons.smSize, color: DesignColors.warning, tooltip: "Ghi de diem")
```

### Override input (inline expand below total score)

```
AnimatedContainer (expand)
  duration: 300ms
  padding: DesignSpacing.md
  decoration: BoxDecoration(color: DesignColors.warning.withOpacity(0.06), borderRadius: DesignRadius.sm)
  Column
    TextFormField "Diem moi" (keyboardType: number, border color: DesignColors.warning)
    SizedBox(height: DesignSpacing.sm)
    TextFormField "Ly do ghi de *" (required, maxLines: 2, border color: DesignColors.warning)
    SizedBox(height: DesignSpacing.sm)
    Row: TextButton "Huy" + ElevatedButton "Xac nhan" (bg: DesignColors.warning, height: 34)
```

## 4. Flow & Logic

1. Parse `rubric['criteria']` into local state: `Map<String, int> _selectedLevelIndices` keyed by criterion `id`.
2. Tap level card: update `_selectedLevelIndices[criterionId] = levelIndex`. Calculate score for that criterion = `level['points']`. Call `onLevelSelected(levelPoints, criterionId)`.
3. Total score: sum of selected level points across all criteria. Show "--" for criteria with no selection.
4. Override flow (D-04 exception path): tap pencil icon next to total score -> expand override input section (`_showOverride = true`). "Diem moi" TextFormField (number). "Ly do ghi de" TextFormField (required -- validated non-empty, error: "Vui long nhap ly do ghi de diem."). "Xac nhan" calls `onManualOverride(newScore, reason)`. "Huy" collapses override section.
5. After override submitted: show "Da ghi de" label in DesignColors.warning below score.

## 5. Data Contract

- **Input:** `rubric: Map<String, dynamic>` (D-02 schema), `currentScore: double?`, `submissionAnswerId: String`
- **Output:** `onLevelSelected(double, String)` and `onManualOverride(double, String)`
- **Provider dependencies:** None (callbacks handled by caller)

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

class InteractiveRubricGrader extends StatefulWidget { ... }

class _InteractiveRubricGraderState extends State<InteractiveRubricGrader> {
  final Map<String, int> _selectedLevelIndices = {};
  bool _showOverride = false;
  bool _overrideSubmitted = false;
  final _overrideScoreController = TextEditingController();
  final _overrideReasonController = TextEditingController();
  final _overrideFormKey = GlobalKey<FormState>();

  double get _totalSelected { ... }
  double get _totalMax { ... }

  void _selectLevel(String criterionId, int levelIndex, double points) { ... }
  void _submitOverride() { ... }

  @override
  Widget build(BuildContext context) { ... }
  Widget _buildCriterionGradingRow(Map<String, dynamic> criterion) { ... }
  Widget _buildLevelCard(Map<String, dynamic> criterion, Map<String, dynamic> level, int levelIndex, bool isSelected) { ... }
  Widget _buildTotalScoreRow() { ... }
  Widget _buildOverrideInput() { ... }
}
```

## 7. Integration Points

- **Who calls this:** `QuestionAnswerCard` or `TeacherSubmissionDetailScreen` (Wave 3) -- rendered inside question grading area when rubric != null
- **What this calls:** Nothing directly -- fires `onLevelSelected` and `onManualOverride` callbacks which the caller connects to `submissionGradingNotifierProvider.overrideScore()`

## 8. Tasks

<wave>2</wave>

<task id="3.6">
  <title>Create InteractiveRubricGrader widget</title>
  <read_first>
    - lib/core/constants/design_tokens.dart
    - lib/widgets/rubric/read_only_rubric_viewer.dart (similar criterion/level rendering patterns)
    - lib/presentation/providers/teacher_submission_providers.dart:300 (overrideScore signature to match callbacks)
  </read_first>
  <action>
    1. Create `lib/widgets/rubric/interactive_rubric_grader.dart`.
    2. Class `InteractiveRubricGrader extends StatefulWidget` with props: `rubric: Map<String, dynamic>` (required), `currentScore: double?`, `submissionAnswerId: String` (required), `onLevelSelected: Function(double points, String criterionId)` (required), `onManualOverride: Function(double score, String reason)` (required).
    3. State class `_InteractiveRubricGraderState`:
       - `final Map<String, int> _selectedLevelIndices = {};` -- criterion_id -> level_index
       - `bool _showOverride = false;`
       - `bool _overrideSubmitted = false;`
       - `final _overrideScoreController = TextEditingController();`
       - `final _overrideReasonController = TextEditingController();`
       - `final _overrideFormKey = GlobalKey<FormState>();`
       - Parse criteria from `widget.rubric['criteria'] as List<dynamic>`.
    4. Getters:
       - `List<dynamic> get _criteria => widget.rubric['criteria'] as List<dynamic>? ?? [];`
       - `double get _totalMax => _criteria.fold<double>(0, (sum, c) => sum + ((c as Map)['max_points'] as num? ?? 0).toDouble());`
       - `double get _totalSelected`: iterate _criteria, for each with `_selectedLevelIndices[c['id']]` != null, add that level's points. For unselected criteria, add 0.
       - `bool get _allSelected => _criteria.every((c) => _selectedLevelIndices.containsKey((c as Map)['id']));`
    5. `_selectLevel(String criterionId, int levelIndex, double points)`:
       - `setState(() => _selectedLevelIndices[criterionId] = levelIndex);`
       - `widget.onLevelSelected(points, criterionId);`
    6. `_submitOverride()`:
       - If `!_overrideFormKey.currentState!.validate()` return.
       - `final newScore = double.tryParse(_overrideScoreController.text) ?? 0;`
       - `final reason = _overrideReasonController.text.trim();`
       - `widget.onManualOverride(newScore, reason);`
       - `setState(() { _overrideSubmitted = true; _showOverride = false; });`
    7. `build()`: Container(padding: EdgeInsets.all(DesignSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header row, SizedBox, ...criteria rows with spacers, Divider, _buildTotalScoreRow(), if (_showOverride) _buildOverrideInput()])).
    8. Header row: Row(children: [Icon(Icons.grading, size: DesignIcons.smSize, color: DesignColors.primary), SizedBox(width: DesignSpacing.sm), Text('Cham diem theo Rubric', style: DesignTypography.titleMedium)]).
    9. `_buildCriterionGradingRow(Map<String, dynamic> criterion)`:
       - `final criterionId = criterion['id'] as String;`
       - `final selectedIdx = _selectedLevelIndices[criterionId];`
       - `final levels = criterion['levels'] as List<dynamic>? ?? [];`
       - `final selectedPoints = selectedIdx != null ? (levels[selectedIdx] as Map)['points'] : null;`
       - Column: Row(Expanded Text name with `DesignTypography.titleMedium.copyWith(fontSize: 14)`, Text score: selectedPoints != null ? '${selectedPoints}/${criterion['max_points']} diem' in `DesignTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: DesignColors.primary)` : '--/${criterion['max_points']} diem' in textTertiary).
       - SizedBox(height: DesignSpacing.sm).
       - Wrap(spacing: DesignSpacing.sm, runSpacing: DesignSpacing.sm, children: levels enumerated -> _buildLevelCard).
    10. `_buildLevelCard(Map<String, dynamic> criterion, Map<String, dynamic> level, int levelIndex, bool isSelected)`:
        - `final points = (level['points'] as num?)?.toDouble() ?? 0;`
        - GestureDetector(onTap: () => _selectLevel(criterion['id'], levelIndex, points)).
        - AnimatedContainer(duration: Duration(milliseconds: 150), padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm), constraints: BoxConstraints(minWidth: 80, maxWidth: 200)).
        - BoxDecoration: color isSelected ? DesignColors.primary.withValues(alpha: 0.1) : DesignColors.white, border Border.all(color: isSelected ? DesignColors.primary : DesignColors.dividerLight, width: isSelected ? 2 : 1), borderRadius BorderRadius.circular(DesignRadius.sm), boxShadow isSelected ? DesignElevation.level1 : null.
        - Column(crossAxisAlignment: start): Row(children: [Text '${level['points']}d' with caption.copyWith(fontWeight: w600, color: isSelected ? DesignColors.primary : DesignColors.textPrimary), if isSelected: Padding(left: DesignSpacing.xs, child: Icon(Icons.check_circle, size: DesignIcons.xsSize, color: DesignColors.primary))]), SizedBox(height: DesignSpacing.xs), Text description with caption, maxLines: 2, overflow: ellipsis, color: isSelected ? textPrimary : textSecondary.
        - Wrap with `Semantics(label: '${level['points']} diem - ${level['description']}')`.
    11. `_buildTotalScoreRow()`:
        - Row: Expanded Text 'Tong diem:' with titleMedium, Text '${ _allSelected ? _totalSelected.toInt() : "--"}/${ _totalMax.toInt()} diem' with headlineMedium color primary, SizedBox(width: DesignSpacing.sm), IconButton(icon: Icon(Icons.edit, size: DesignIcons.smSize, color: DesignColors.warning), tooltip: 'Ghi de diem', onPressed: () => setState(() => _showOverride = !_showOverride)).
        - If `_overrideSubmitted`: below Row, Text 'Da ghi de' in DesignTypography.caption.copyWith(color: DesignColors.warning).
    12. `_buildOverrideInput()`:
        - AnimatedSize with duration 300ms curve Curves.easeInOut.
        - Form(key: _overrideFormKey, child: Container(margin: EdgeInsets.only(top: DesignSpacing.md), padding: EdgeInsets.all(DesignSpacing.md), decoration: BoxDecoration(color: DesignColors.warning.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(DesignRadius.sm)))).
        - Column: TextFormField 'Diem moi' (controller: _overrideScoreController, keyboardType: TextInputType.number, decoration with border color DesignColors.warning), SizedBox(height: DesignSpacing.sm), TextFormField 'Ly do ghi de *' (controller: _overrideReasonController, maxLines: 2, validator: (v) => v == null || v.trim().isEmpty ? 'Vui long nhap ly do ghi de diem.' : null, decoration with border color DesignColors.warning), SizedBox(height: DesignSpacing.sm), Row(mainAxisAlignment: end): TextButton 'Huy' (color: textSecondary, onPressed: setState showOverride=false) + SizedBox(width: DesignSpacing.sm) + ElevatedButton 'Xac nhan' (bg: DesignColors.warning, minimumSize: Size(0, 34), onPressed: _submitOverride).
    13. Dispose controllers in `dispose()`.
    14. Only DesignTokens for styling.
  </action>
  <acceptance_criteria>
    - `lib/widgets/rubric/interactive_rubric_grader.dart` exists
    - grep "class InteractiveRubricGrader extends StatefulWidget" lib/widgets/rubric/interactive_rubric_grader.dart
    - grep "Cham diem theo Rubric" lib/widgets/rubric/interactive_rubric_grader.dart
    - grep "onLevelSelected" lib/widgets/rubric/interactive_rubric_grader.dart
    - grep "onManualOverride" lib/widgets/rubric/interactive_rubric_grader.dart
    - grep "Ly do ghi de" lib/widgets/rubric/interactive_rubric_grader.dart (D-04 mandatory reason)
    - grep "Da ghi de" lib/widgets/rubric/interactive_rubric_grader.dart (override submitted state)
    - grep "AnimatedContainer" lib/widgets/rubric/interactive_rubric_grader.dart (level card animation)
    - grep "Semantics" lib/widgets/rubric/interactive_rubric_grader.dart (accessibility)
    - grep "DesignColors\." lib/widgets/rubric/interactive_rubric_grader.dart
    - NOT grep "Color(0x" lib/widgets/rubric/interactive_rubric_grader.dart
    - flutter analyze lib/widgets/rubric/interactive_rubric_grader.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Teacher can tap level cards to select score per criterion.
- Selected level visually highlighted with primary color border, tint, check icon.
- Total score auto-calculated from selections.
- Override input expands inline with mandatory reason field.
- Override submitted shows "Da ghi de" indicator.
- Callbacks fire correctly for level selection and manual override.

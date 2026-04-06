---
phase: 3
plan_id: 03-PLAN-RubricSummaryButton
wave: 1
depends_on: []
files_modified:
  - lib/widgets/rubric/rubric_summary_button.dart
autonomous: true
requirements: [RUB-03]
---

# RubricSummaryButton -- Phase 3 Plan

## 1. Muc dich & Pham vi

Small status indicator widget placed inside the question editor for essay/shortAnswer questions. Shows rubric status: empty ("Them Rubric"), configured ("Rubric: Da cau hinh 3 tieu chi"), or locked ("Rubric: 3 tieu chi (Chi xem)"). Tapping opens the RubricBuilderComponent or ReadOnlyRubricViewer.

**Layer:** Shared widget (lib/widgets/rubric/)
**Type:** New file

## 2. File Path

- **Target:** `lib/widgets/rubric/rubric_summary_button.dart`
- **Read first:**
  - `lib/core/constants/design_tokens.dart` (DesignColors, DesignSpacing, DesignTypography, DesignRadius, DesignIcons)

## 3. UI Spec (from 03-UI-SPEC.md)

### Props

```dart
class RubricSummaryButton extends StatelessWidget {
  final Map<String, dynamic>? rubric;
  final bool isLocked;
  final VoidCallback onTap;
}
```

### States

| State | Visual |
|-------|--------|
| Empty (rubric == null) | OutlinedButton: icon `Icons.add`, label "Them Rubric", borderColor `DesignColors.primary`, textColor `DesignColors.primary` |
| Configured (rubric != null, !isLocked) | Container with `DesignColors.success` left border (3dp), bg `DesignColors.success.withOpacity(0.06)`. Icon `Icons.check_circle` (success). Text "Rubric: Da cau hinh {N} tieu chi (Nhan de sua)". Chevron right. |
| Locked (isLocked) | Same layout but: icon `Icons.lock` (textTertiary), text "Rubric: {N} tieu chi (Chi xem)", bg `DesignColors.disabledLight`, no left border accent. |

### Layout (configured state)

```
GestureDetector(onTap: onTap)
  Container
    margin: EdgeInsets.only(top: DesignSpacing.sm)
    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm)
    decoration: BoxDecoration
      color: DesignColors.success.withOpacity(0.06)
      borderRadius: DesignRadius.sm
      border: Border(left: BorderSide(color: DesignColors.success, width: 3))
    Row
      Icon(Icons.check_circle, size: DesignIcons.smSize, color: DesignColors.success)
      SizedBox(width: DesignSpacing.sm)
      Expanded
        Text "Rubric: Da cau hinh {N} tieu chi" (DesignTypography.bodyMedium)
        Text "(Nhan de sua)" (DesignTypography.caption, color: DesignColors.textSecondary)
      Icon(Icons.chevron_right, size: DesignIcons.smSize, color: DesignColors.textTertiary)
```

## 4. Flow & Logic

- Count criteria: `(rubric?['criteria'] as List?)?.length ?? 0`.
- 3 visual states based on `rubric` and `isLocked`.
- Empty state: OutlinedButton with "+ Them Rubric" label. Per D-07, this appears for both essay AND shortAnswer question types (caller determines visibility).
- Configured state: success-colored container with criteria count.
- Locked state (D-09): muted container, lock icon, "(Chi xem)" text.
- `onTap` is always called regardless of state -- the caller decides whether to open builder or viewer.

## 5. Data Contract

- **Input:** `rubric: Map<String, dynamic>?`, `isLocked: bool`, `onTap: VoidCallback`
- **Output:** Calls `onTap` when tapped
- **Provider dependencies:** None (dumb widget)

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

class RubricSummaryButton extends StatelessWidget {
  final Map<String, dynamic>? rubric;
  final bool isLocked;
  final VoidCallback onTap;

  const RubricSummaryButton({
    super.key,
    required this.rubric,
    this.isLocked = false,
    required this.onTap,
  });

  int get _criteriaCount => (rubric?['criteria'] as List?)?.length ?? 0;

  @override
  Widget build(BuildContext context) { ... }
  Widget _buildEmpty() { ... }
  Widget _buildConfigured() { ... }
  Widget _buildLocked() { ... }
}
```

## 7. Integration Points

- **Who calls this:** `TeacherCreateAssignmentScreen` question editor section (Wave 3) -- rendered below essay/shortAnswer question content.
- **What this calls:** Nothing -- fires `onTap` callback.

## 8. Tasks

<wave>1</wave>

<task id="3.2">
  <title>Create RubricSummaryButton widget</title>
  <read_first>
    - lib/core/constants/design_tokens.dart (token values)
  </read_first>
  <action>
    1. Create `lib/widgets/rubric/rubric_summary_button.dart` with class `RubricSummaryButton extends StatelessWidget`.
    2. Constructor: `required this.rubric` (Map<String, dynamic>?), `this.isLocked = false`, `required this.onTap`.
    3. Getter `int get _criteriaCount => (rubric?['criteria'] as List?)?.length ?? 0;`.
    4. `build()`: If `rubric == null`, return `_buildEmpty()`. If `isLocked`, return `_buildLocked()`. Otherwise `_buildConfigured()`.
    5. `_buildEmpty()`:
       - Return `Padding(padding: EdgeInsets.only(top: DesignSpacing.sm), child: OutlinedButton.icon(onPressed: onTap, icon: Icon(Icons.add, size: DesignIcons.smSize), label: Text('Them Rubric'), style: OutlinedButton.styleFrom(foregroundColor: DesignColors.primary, side: BorderSide(color: DesignColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)), minimumSize: Size(0, 40))))`.
    6. `_buildConfigured()`:
       - GestureDetector(onTap: onTap) wrapping Container.
       - Container margin: `EdgeInsets.only(top: DesignSpacing.sm)`, padding: `EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm)`.
       - BoxDecoration: `color: DesignColors.success.withValues(alpha: 0.06)`, `borderRadius: BorderRadius.circular(DesignRadius.sm)`, `border: Border(left: BorderSide(color: DesignColors.success, width: 3))`.
       - Row children: Icon(Icons.check_circle, size: DesignIcons.smSize, color: DesignColors.success), SizedBox(width: DesignSpacing.sm), Expanded Column(crossAxisAlignment: start, children: [Text('Rubric: Da cau hinh $_criteriaCount tieu chi', style: DesignTypography.bodyMedium), Text('(Nhan de sua)', style: DesignTypography.caption.copyWith(color: DesignColors.textSecondary))]), Icon(Icons.chevron_right, size: DesignIcons.smSize, color: DesignColors.textTertiary).
    7. `_buildLocked()`:
       - Same GestureDetector + Container layout as configured but:
       - BoxDecoration: `color: DesignColors.disabledLight`, `borderRadius: BorderRadius.circular(DesignRadius.sm)`, no left border accent.
       - Row: Icon(Icons.lock, size: DesignIcons.smSize, color: DesignColors.textTertiary), text "Rubric: $_criteriaCount tieu chi (Chi xem)" in DesignTypography.bodyMedium.copyWith(color: DesignColors.textTertiary).
       - No chevron_right (read-only indicator sufficient).
    8. All styling via DesignTokens exclusively.
  </action>
  <acceptance_criteria>
    - `lib/widgets/rubric/rubric_summary_button.dart` exists
    - grep "class RubricSummaryButton extends StatelessWidget" lib/widgets/rubric/rubric_summary_button.dart
    - grep "Them Rubric" lib/widgets/rubric/rubric_summary_button.dart (empty state text)
    - grep "Da cau hinh" lib/widgets/rubric/rubric_summary_button.dart (configured state text)
    - grep "Chi xem" lib/widgets/rubric/rubric_summary_button.dart (locked state text)
    - grep "DesignColors\." lib/widgets/rubric/rubric_summary_button.dart
    - grep "isLocked" lib/widgets/rubric/rubric_summary_button.dart (D-09 support)
    - NOT grep "Color(0x" lib/widgets/rubric/rubric_summary_button.dart
    - flutter analyze lib/widgets/rubric/rubric_summary_button.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- 3 visual states render correctly: empty, configured, locked.
- Criteria count computed from rubric JSONB.
- onTap fires for all states.
- Uses DesignTokens exclusively.

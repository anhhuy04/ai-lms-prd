---
phase: 3
plan_id: 03-PLAN-StudentAssignmentDetailScreen
wave: 4
depends_on:
  - 03-PLAN-ReadOnlyRubricViewer
files_modified:
  - lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
autonomous: true
requirements: [RUB-04]
---

# StudentAssignmentDetailScreen -- Phase 3 Plan

## 1. Muc dich & Pham vi

Add rubric preview section to the student assignment detail screen. Students see rubric criteria before starting their work (D-03 "Giai doan 1"). Each essay/shortAnswer question with a rubric gets an expandable rubric preview card using ReadOnlyRubricViewer in both compact and full modes.

**Layer:** Presentation (existing screen modification)
**Type:** Modify existing file

## 2. File Path

- **Target:** `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart`
- **Read first:**
  - `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart` (FULL FILE -- understand _InProgressView structure, questions data shape, existing layout)
  - `lib/widgets/rubric/read_only_rubric_viewer.dart` (ReadOnlyRubricViewer API with compact + showHeader props)
  - `lib/presentation/providers/student_assignment_providers.dart` (verify question data includes rubric column)

## 3. UI Spec (from 03-UI-SPEC.md)

### Rubric preview per question

```
for each question where rubric != null && (type == essay || type == shortAnswer):
  Card
    elevation: DesignElevation.level1
    borderRadius: DesignRadius.md
    margin: EdgeInsets.only(bottom: DesignSpacing.md)
    child: Column
      Padding (all: DesignSpacing.lg)
        Row
          Icon(Icons.rule, DesignIcons.smSize, color: DesignColors.tealPrimary)
          SizedBox(width: DesignSpacing.sm)
          Expanded
            Text "Tieu chi cham diem - Cau {questionNumber}" (DesignTypography.titleMedium, fontSize: 14sp override)
          _buildExpandToggle()  // Icons.expand_more/less
      if expanded:
        Divider(color: DesignColors.dividerLight)
        Padding (horizontal: DesignSpacing.lg, bottom: DesignSpacing.lg)
          ReadOnlyRubricViewer(rubric: question.rubric, showHeader: false)
      else:
        Padding (horizontal: DesignSpacing.lg, bottom: DesignSpacing.md)
          ReadOnlyRubricViewer(rubric: question.rubric, compact: true, showHeader: false)
```

Default state: Collapsed (compact mode). Tap expand icon to see full levels.

## 4. Flow & Logic

1. Find the `_InProgressView` (or equivalent view shown before student starts the assignment).
2. Access the questions list from the assignment detail data. Each question should have a `rubric` field.
3. Filter for questions where `rubric != null` AND type is `essay` or `short_answer`.
4. For each matching question, render the rubric preview card with expand/collapse toggle.
5. Track expanded state locally: `Set<int> _expandedRubricIndices = {}`.
6. This is purely read-only display -- no interactions beyond expand/collapse.

## 5. Data Contract

- **Input:** Assignment detail data with questions list, each question having `rubric` field
- **Data verification:** Check `studentAssignmentDetailProvider` or equivalent provider to ensure rubric column is included in the query. If SELECT does not include rubric, add it.

## 6. Cau truc Code

Since the detail screen likely uses StatefulWidget or ConsumerStatefulWidget:
```dart
// Add to state:
final Set<int> _expandedRubricIndices = {};

// New method:
Widget _buildRubricPreviewSection(List<dynamic> questions) { ... }
Widget _buildRubricCard(Map<String, dynamic> question, int questionNumber) { ... }
```

## 7. Integration Points

- **Who calls this:** Student navigates to assignment detail -- existing route
- **What this calls:** `ReadOnlyRubricViewer` (Wave 1) in both compact and full modes

## 8. Tasks

<wave>4</wave>

<task id="3.10">
  <title>Add rubric preview cards to StudentAssignmentDetailScreen</title>
  <read_first>
    - lib/presentation/views/assignment/student/student_assignment_detail_screen.dart (FULL FILE -- understand _InProgressView or equivalent, questions data shape, how questions are accessed from detail data)
    - lib/widgets/rubric/read_only_rubric_viewer.dart (compact and showHeader props)
    - lib/presentation/providers/student_assignment_providers.dart (check if rubric is in query SELECT)
  </read_first>
  <action>
    1. Add import: `import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';`
    2. Determine how questions are accessed in the detail view. Likely from `detail['questions']` or similar. Verify that each question map includes `rubric` key. If the provider query does not select `rubric`, update the select clause to include it (in the datasource or provider file).
    3. The screen may be StatelessWidget or StatefulWidget. If StatelessWidget (with _InProgressView as separate widget), the expand/collapse state needs a StatefulWidget wrapper. Options:
       - If `_InProgressView` is already a StatefulWidget: add `_expandedRubricIndices` set to state.
       - If StatelessWidget: convert the rubric section to a separate small `_RubricPreviewCard` StatefulWidget that manages its own expanded state.
    4. Create method/widget `_buildRubricPreviewSection(List<dynamic> questions)`:
       - Filter questions: `questions.where((q) { final type = q['type'] ?? q['question_type']; return (type == 'essay' || type == 'short_answer') && q['rubric'] != null; }).toList()`.
       - If filtered list empty, return SizedBox.shrink().
       - Return Column with header "Tieu chi cham diem" and list of rubric cards.
    5. Create `_RubricPreviewCard` as a StatefulWidget with props `rubric: Map<String, dynamic>`, `questionNumber: int`:
       - State has `bool _expanded = false;`.
       - Build: `Card(elevation: /* DesignElevation.level1 value */, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)), margin: EdgeInsets.only(bottom: DesignSpacing.md), child: Column(children: [Padding(padding: EdgeInsets.all(DesignSpacing.lg), child: Row(children: [Icon(Icons.rule, size: DesignIcons.smSize, color: DesignColors.tealPrimary), SizedBox(width: DesignSpacing.sm), Expanded(child: Text('Tieu chi cham diem - Cau $questionNumber', style: DesignTypography.titleMedium.copyWith(fontSize: 14))), IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: DesignIcons.smSize), onPressed: () => setState(() => _expanded = !_expanded))])), if (_expanded) ...[Divider(color: DesignColors.dividerLight, height: 1), Padding(padding: EdgeInsets.fromLTRB(DesignSpacing.lg, 0, DesignSpacing.lg, DesignSpacing.lg), child: ReadOnlyRubricViewer(rubric: widget.rubric, showHeader: false))] else Padding(padding: EdgeInsets.fromLTRB(DesignSpacing.lg, 0, DesignSpacing.lg, DesignSpacing.md), child: ReadOnlyRubricViewer(rubric: widget.rubric, compact: true, showHeader: false))]))`.
    6. Place `_buildRubricPreviewSection(questions)` in the `_InProgressView` build method, after the assignment info section and before the "Bat dau lam bai" button.
    7. ALSO check `_SubmittedView` (review screen foundation per D-03 "Giai doan 3"): If there is a submitted view showing grading results, add `ReadOnlyRubricViewer` with `selectedLevels: null` (Phase 6 placeholder) for essay/shortAnswer questions. This is the foundation -- selectedLevels will be populated when Phase 6 adds AI criteria_scores.
  </action>
  <acceptance_criteria>
    - grep "ReadOnlyRubricViewer" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
    - grep "Tieu chi cham diem" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
    - grep "_RubricPreviewCard\|_expanded\|expand_less\|expand_more" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart (expand/collapse mechanism)
    - grep "Icons.rule" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
    - grep "DesignColors.tealPrimary" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
    - grep "compact: true" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart (compact mode for collapsed state)
    - flutter analyze lib/presentation/views/assignment/student/student_assignment_detail_screen.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Essay/shortAnswer questions with rubric show expandable preview card.
- Collapsed state shows compact mode (criterion names + max_points).
- Expanded state shows full mode (levels with descriptions).
- Questions without rubric or non-essay types show nothing.
- Review screen foundation ready for Phase 6 selectedLevels.

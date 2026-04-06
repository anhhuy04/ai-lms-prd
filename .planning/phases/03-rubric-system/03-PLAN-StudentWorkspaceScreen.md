---
phase: 3
plan_id: 03-PLAN-StudentWorkspaceScreen
wave: 4
depends_on:
  - 03-PLAN-ReadOnlyRubricViewer
files_modified:
  - lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
  - lib/presentation/providers/workspace_provider.dart
autonomous: true
requirements: [RUB-04]
---

# StudentWorkspaceScreen -- Phase 3 Plan

## 1. Muc dich & Pham vi

Add "Xem Tieu chi" button to the student workspace for essay and shortAnswer questions that have a rubric attached. Tapping opens a bottom sheet with ReadOnlyRubricViewer. Per D-03, opening/closing the sheet must NOT trigger autosave or interrupt typing state.

**Layer:** Presentation (existing screen modification)
**Type:** Modify 2 existing files

## 2. File Path

- **Target 1:** `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`
- **Target 2:** `lib/presentation/providers/workspace_provider.dart`
- **Read first:**
  - `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` lines 456-780 (_buildEssay, _buildShortAnswer methods)
  - `lib/presentation/providers/workspace_provider.dart` lines 396-430 (QuestionState class)
  - `lib/widgets/rubric/read_only_rubric_viewer.dart` (ReadOnlyRubricViewer API)
  - `lib/presentation/views/assignment/student/widgets/essay_answer_field.dart` (understand essay field widget)

## 3. UI Spec (from 03-UI-SPEC.md)

### "Xem Tieu chi" button placement

```
if question.rubric != null:
  Align(alignment: Alignment.centerRight)
    TextButton.icon
      icon: Icon(Icons.info_outline, size: DesignIcons.xsSize, color: DesignColors.tealPrimary)
      label: Text "Xem Tieu chi" (DesignTypography.caption, color: DesignColors.tealPrimary)
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs)
        minimumSize: Size(0, 32)
      )
      onPressed: -> showModalBottomSheet(
        isScrollControlled: true
        shape: RoundedRectangleBorder(topLeft/topRight: DesignRadius.lg)
        builder: DraggableScrollableSheet(initialChildSize: 0.6, maxChildSize: 0.85)
          Column
            _buildSheetHandle()  // 40dp wide, 4dp tall, centered
            ReadOnlyRubricViewer(rubric: question.rubric)
      )
```

## 4. Flow & Logic

1. `QuestionState` needs a `rubric` field. Check if it exists. If not, add `Map<String, dynamic>? rubric` to `QuestionState` and ensure the workspace data loading query includes `assignment_questions.rubric`.
2. In `_buildEssay(QuestionState question, dynamic answer)`: before returning the `EssayAnswerField`, check if `question.rubric != null`. If so, add the "Xem Tieu chi" button ABOVE the text field.
3. `_buildShortAnswer` currently delegates to `_buildEssay` (line 778), so the button will appear for both types automatically.
4. CRITICAL (D-03): The bottom sheet is a pure read-only overlay. It does not modify any workspace state. No setState, no provider mutation. The `showModalBottomSheet` call does not trigger autosave because it does not change the answer text controllers.

## 5. Data Contract

- **Input:** `QuestionState.rubric` (Map<String, dynamic>? from assignment_questions.rubric column)
- **Provider change:** Add `rubric` field to `QuestionState` if missing
- **Supabase change:** Ensure workspace data fetch includes `rubric` column from `assignment_questions`

## 6. Cau truc Code

### QuestionState changes (workspace_provider.dart)
```dart
class QuestionState {
  // ... existing fields
  final Map<String, dynamic>? rubric;  // ADD THIS

  const QuestionState({
    // ... existing params
    this.rubric,  // ADD THIS
  });
}
```

### Workspace screen changes
```dart
Widget _buildRubricButton(QuestionState question) {
  if (question.rubric == null) return const SizedBox.shrink();
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon( ... ),
  );
}
```

## 7. Integration Points

- **Who calls this:** Student navigates to workspace -- existing route
- **What this calls:** `ReadOnlyRubricViewer` (Wave 1) via bottom sheet
- **Data dependency:** `QuestionState.rubric` must be populated from assignment_questions query

## 8. Tasks

<wave>4</wave>

<task id="3.9">
  <title>Add rubric field to QuestionState and "Xem Tieu chi" button to workspace</title>
  <read_first>
    - lib/presentation/providers/workspace_provider.dart lines 396-430 (QuestionState class and its constructor)
    - lib/presentation/providers/workspace_provider.dart (search for where QuestionState is constructed from query data -- find the mapping logic)
    - lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart lines 456-470 (_buildQuestionWidget and _buildEssay)
    - lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart lines 673-680 (_buildEssay method body)
    - lib/widgets/rubric/read_only_rubric_viewer.dart (ReadOnlyRubricViewer constructor params)
  </read_first>
  <action>
    **Part A: workspace_provider.dart -- add rubric to QuestionState**

    1. In `QuestionState` class, add field: `final Map<String, dynamic>? rubric;`
    2. In `QuestionState` constructor, add parameter: `this.rubric,`
    3. Find where `QuestionState` objects are created from query data (search for `QuestionState(` constructor calls). Add `rubric: questionData['rubric'] as Map<String, dynamic>?,` to each construction site.
    4. Ensure the Supabase query that fetches assignment questions includes the `rubric` column. Search for the SELECT query in the workspace provider or datasource. If rubric is not in the select list, add it. If using `select('*')`, rubric is already included.

    **Part B: student_assignment_workspace_screen.dart -- add button**

    5. Add import: `import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';`
    6. Add method `Widget _buildRubricButton(QuestionState question)`:
       ```dart
       Widget _buildRubricButton(QuestionState question) {
         if (question.rubric == null) return const SizedBox.shrink();
         return Align(
           alignment: Alignment.centerRight,
           child: TextButton.icon(
             icon: Icon(Icons.info_outline, size: DesignIcons.xsSize, color: DesignColors.tealPrimary),
             label: Text('Xem Tieu chi', style: DesignTypography.caption.copyWith(color: DesignColors.tealPrimary)),
             style: TextButton.styleFrom(
               padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
               minimumSize: const Size(0, 32),
             ),
             onPressed: () => _showRubricSheet(question.rubric!),
           ),
         );
       }
       ```
    7. Add method `void _showRubricSheet(Map<String, dynamic> rubric)`:
       ```dart
       void _showRubricSheet(Map<String, dynamic> rubric) {
         showModalBottomSheet(
           context: context,
           isScrollControlled: true,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.only(
               topLeft: Radius.circular(DesignRadius.lg),
               topRight: Radius.circular(DesignRadius.lg),
             ),
           ),
           builder: (_) => DraggableScrollableSheet(
             initialChildSize: 0.6,
             maxChildSize: 0.85,
             expand: false,
             builder: (context, scrollController) => Column(
               children: [
                 Center(
                   child: Container(
                     margin: EdgeInsets.only(top: DesignSpacing.sm, bottom: DesignSpacing.sm),
                     width: 40, height: 4,
                     decoration: BoxDecoration(
                       color: DesignColors.dividerMedium,
                       borderRadius: BorderRadius.circular(2),
                     ),
                   ),
                 ),
                 Expanded(
                   child: SingleChildScrollView(
                     controller: scrollController,
                     child: ReadOnlyRubricViewer(rubric: rubric),
                   ),
                 ),
               ],
             ),
           ),
         );
       }
       ```
    8. In `_buildEssay(QuestionState question, dynamic answer)` method: BEFORE the `return EssayAnswerField(...)` statement, wrap in a Column that includes `_buildRubricButton(question)` followed by the EssayAnswerField. Since _buildShortAnswer delegates to _buildEssay, both types get the button.
       Specifically, change:
       ```dart
       // FROM:
       return EssayAnswerField(...);
       // TO:
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           _buildRubricButton(question),
           EssayAnswerField(...),
         ],
       );
       ```
    9. CRITICAL: Do NOT add any setState or provider mutations inside _showRubricSheet. The sheet is purely read-only. Autosave must not be interrupted.
  </action>
  <acceptance_criteria>
    - grep "rubric" lib/presentation/providers/workspace_provider.dart (rubric field in QuestionState)
    - grep "Xem Tieu chi" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - grep "ReadOnlyRubricViewer" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - grep "_showRubricSheet" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - grep "_buildRubricButton" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - grep "DraggableScrollableSheet" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - grep "DesignColors.tealPrimary" lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
    - flutter analyze lib/presentation/providers/workspace_provider.dart returns 0 errors
    - flutter analyze lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Essay and shortAnswer questions with rubric show "Xem Tieu chi" button.
- Button opens bottom sheet with full ReadOnlyRubricViewer.
- Bottom sheet open/close does NOT trigger autosave or interrupt typing (D-03).
- Questions without rubric show no button (SizedBox.shrink).
- QuestionState.rubric field populated from Supabase query data.

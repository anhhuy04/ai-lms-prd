---
phase: 3
plan_id: 03-PLAN-QuestionAnswerCard
wave: 3
depends_on:
  - 03-PLAN-InteractiveRubricGrader
  - 03-PLAN-ReadOnlyRubricViewer
files_modified:
  - lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
autonomous: true
requirements: [RUB-02, RUB-04]
---

# QuestionAnswerCard -- Phase 3 Plan

## 1. Muc dich & Pham vi

Modify the existing QuestionAnswerCard to replace the partial `_buildRubric()` method (which uses wrong key `max_score` instead of `max_points`) with the new `ReadOnlyRubricViewer` for display and add `InteractiveRubricGrader` for teacher grading interaction.

**Layer:** Presentation (existing widget modification)
**Type:** Modify existing file

## 2. File Path

- **Target:** `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart`
- **Read first:**
  - `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` (current 101-line file -- FULL READ)
  - `lib/widgets/rubric/read_only_rubric_viewer.dart` (replacement for _buildRubric)
  - `lib/widgets/rubric/interactive_rubric_grader.dart` (new grading widget)
  - `lib/presentation/providers/teacher_submission_providers.dart` lines 300-305 (overrideScore API)

## 3. UI Spec

### Current state (to replace)

Lines 80-100: `_buildRubric(dynamic rubric)` shows `criterion['name']` + `criterion['score']/${criterion['max_score']}` -- uses WRONG keys (`max_score` instead of `max_points` per D-02).

### New behavior

1. When `showRubric` is true and `answer['rubric']` is not null:
   - If the widget is in a grading context (new prop `isGrading: bool`): render `InteractiveRubricGrader` with callbacks
   - If read-only context: render `ReadOnlyRubricViewer`
2. Remove the old `_buildRubric()` method entirely.

### New props to add

```dart
final bool isGrading;                    // default: false
final String? submissionAnswerId;        // needed for InteractiveRubricGrader
final Function(double, String)? onLevelSelected;     // grading callback
final Function(double, String)? onManualOverride;     // override callback
```

## 4. Flow & Logic

- The `rubric` data comes from `answer['rubric']` or `answer['assignment_question']?['rubric']` -- check which key the parent screen passes. Research shows it's `answer['rubric']` at line 53.
- For grading mode: `InteractiveRubricGrader` receives rubric, current score from `answer['final_score']`, submissionAnswerId, and the two callbacks.
- For read-only mode: `ReadOnlyRubricViewer` receives rubric, no selectedLevels (Phase 6 will add).

## 5. Data Contract

- **Input:** Existing `answer` map + new optional props for grading callbacks
- **Output:** Fires `onLevelSelected`/`onManualOverride` callbacks in grading mode

## 6. Cau truc Code

```dart
class QuestionAnswerCard extends StatelessWidget {
  // Existing props...
  final bool isGrading;
  final String? submissionAnswerId;
  final Function(double, String)? onLevelSelected;
  final Function(double, String)? onManualOverride;

  // Remove: Widget _buildRubric(dynamic rubric) { ... }
  // Add: Widget _buildRubricSection() { ... }
}
```

## 7. Integration Points

- **Who calls this:** `TeacherSubmissionDetailScreen` -- passes grading callbacks when in grading mode
- **What this calls:** `ReadOnlyRubricViewer` (Wave 1), `InteractiveRubricGrader` (Wave 2)

## 8. Tasks

<wave>3</wave>

<task id="3.8">
  <title>Replace _buildRubric with ReadOnlyRubricViewer and add InteractiveRubricGrader</title>
  <read_first>
    - lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart (full 101-line file)
    - lib/widgets/rubric/read_only_rubric_viewer.dart (ReadOnlyRubricViewer API)
    - lib/widgets/rubric/interactive_rubric_grader.dart (InteractiveRubricGrader API)
    - lib/presentation/providers/teacher_submission_providers.dart:300 (overrideScore to confirm callback signature)
  </read_first>
  <action>
    1. Add imports:
       - `import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';`
       - `import 'package:ai_mls/widgets/rubric/interactive_rubric_grader.dart';`
    2. Add new constructor parameters after existing ones:
       - `this.isGrading = false`
       - `this.submissionAnswerId`
       - `this.onLevelSelected`
       - `this.onManualOverride`
    3. Add corresponding fields:
       - `final bool isGrading;`
       - `final String? submissionAnswerId;`
       - `final Function(double points, String criterionId)? onLevelSelected;`
       - `final Function(double score, String reason)? onManualOverride;`
    4. Delete the entire `_buildRubric(dynamic rubric)` method (lines 80-100).
    5. Replace the rubric section in `build()` (lines 50-54) where it currently calls `_buildRubric(answer['rubric'])`:
       ```dart
       if (showRubric) ...[
         Text('Rubric', style: DesignTypography.bodySmall.copyWith(color: DesignColors.textSecondary)),
         const SizedBox(height: DesignSpacing.xs),
         _buildRubricSection(),
       ],
       ```
    6. Add new method `Widget _buildRubricSection()`:
       ```dart
       Widget _buildRubricSection() {
         final rubricData = answer['rubric'] as Map<String, dynamic>?;
         if (rubricData == null) {
           return Text('Khong co rubric', style: DesignTypography.bodyMedium.copyWith(color: DesignColors.textTertiary));
         }
         if (isGrading && submissionAnswerId != null && onLevelSelected != null && onManualOverride != null) {
           return InteractiveRubricGrader(
             rubric: rubricData,
             currentScore: (answer['final_score'] as num?)?.toDouble(),
             submissionAnswerId: submissionAnswerId!,
             onLevelSelected: onLevelSelected!,
             onManualOverride: onManualOverride!,
           );
         }
         return ReadOnlyRubricViewer(rubric: rubricData);
       }
       ```
    7. Verify existing callers of QuestionAnswerCard still compile (new params have defaults).
  </action>
  <acceptance_criteria>
    - grep "ReadOnlyRubricViewer" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
    - grep "InteractiveRubricGrader" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
    - grep "isGrading" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
    - grep "onLevelSelected" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
    - grep "onManualOverride" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart
    - NOT grep "max_score" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart (old wrong key removed)
    - NOT grep "_buildRubric\b" lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart (old method removed -- note: _buildRubricSection is the new method)
    - flutter analyze lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Old `_buildRubric()` with wrong `max_score` key is removed.
- Read-only mode shows `ReadOnlyRubricViewer` (correct D-02 keys: `max_points`, `levels`).
- Grading mode shows `InteractiveRubricGrader` with clickable level cards.
- Existing callers (non-grading) continue to work with default `isGrading: false`.

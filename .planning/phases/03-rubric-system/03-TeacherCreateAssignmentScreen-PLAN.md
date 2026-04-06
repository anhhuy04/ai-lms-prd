---
phase: 3
plan_id: 03-PLAN-TeacherCreateAssignmentScreen
wave: 3
depends_on:
  - 03-PLAN-RubricBuilderComponent
  - 03-PLAN-RubricSummaryButton
files_modified:
  - lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
autonomous: true
requirements: [RUB-03]
---

# TeacherCreateAssignmentScreen -- Phase 3 Plan

## 1. Muc dich & Pham vi

Modify the existing teacher assignment creation screen to integrate rubric functionality: add RubricSummaryButton to essay/shortAnswer question editors, open RubricBuilderComponent on tap, implement points auto-sync (D-06), publish validation hard block (D-08), and rubric edit lock check (D-09).

**Layer:** Presentation (existing screen modification)
**Type:** Modify existing file

## 2. File Path

- **Target:** `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`
- **Read first:**
  - `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` (FULL FILE -- understand current structure, _questions map, _mapQuestionsToAssignmentQuestions, question type rendering, publish flow)
  - `lib/widgets/rubric/rubric_summary_button.dart` (Wave 1 widget)
  - `lib/widgets/rubric/rubric_builder_component.dart` (Wave 2 widget)
  - `lib/domain/entities/assignment_question.dart` (AssignmentQuestion.rubric field)
  - `lib/domain/usecases/assignment_usecases.dart` lines 60-135 (save/publish use case rubric passthrough)

## 3. UI Spec (from 03-UI-SPEC.md, 03-CONTEXT.md)

### RubricSummaryButton placement

For each question where type is `essay` or `shortAnswer` (per D-07), render `RubricSummaryButton` below the question content/answer section inside the question editor card.

### Publish validation error UI (D-08)

When teacher taps "Phat hanh" and any essay/shortAnswer question has `rubric == null`:
- Scroll to first offending question
- Highlight question card with `Border.all(color: DesignColors.error, width: 2)`
- Show error row below: Icon(Icons.error_outline) + "Cau hoi tu luan phai co Rubric truoc khi phat hanh."
- If multiple errors: SnackBar "Co {N} cau hoi tu luan chua co Rubric."

## 4. Flow & Logic

### Rubric section in question editor
1. In the question editor build method, after the question content section and before the points/score section, check if `questionType == QuestionType.essay || questionType == QuestionType.shortAnswer`.
2. If yes, render `RubricSummaryButton(rubric: _questions[index]['rubric'], isLocked: _isRubricLocked, onTap: () => _openRubricBuilder(index))`.
3. `_openRubricBuilder(int questionIndex)`:
   - First check D-09 lock condition: query if assignment has active distributions or work_sessions > 0.
   - `showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => RubricBuilderComponent(initialRubric: _questions[questionIndex]['rubric'], isLocked: _isRubricLocked, onSave: (newRubric) { setState(() { _questions[questionIndex]['rubric'] = newRubric; }); Navigator.pop(context); }))`.

### Points auto-sync (D-06)
- When rubric is set (not null) for essay/shortAnswer: disable the points TextFormField for that question (set `enabled: false`).
- Auto-calculate points: `criteria.fold<double>(0, (sum, c) => sum + (c['max_points'] as num).toDouble())`.
- Update `_questions[questionIndex]['points']` with calculated value.
- When rubric is removed (set to null via builder saving empty): re-enable points field, keep last calculated value as starting point.

### Publish validation (D-08)
- In the existing publish flow method, BEFORE calling the publish RPC:
- Iterate all questions. For each with type essay/shortAnswer: check if `rubric == null`.
- If any fail: do NOT call RPC. Set `_publishValidationErrors` map. Scroll to first error. Show SnackBar if multiple errors.
- `_publishValidationErrors` is a `Set<int>` of question indices with errors.
- In question card builder: if index is in `_publishValidationErrors`, wrap card with error border + error message row.
- Draft save (D-08): NO validation -- rubric can be null, empty criteria, all allowed.

### D-09 lock check
- `bool _isRubricLocked = false;`
- On screen init (if editing existing assignment with `_assignmentId != null`): query Supabase to check if any `assignment_distributions` with `status = 'active'` or `COUNT(work_sessions) > 0` for this assignment.
- If true, set `_isRubricLocked = true`. RubricSummaryButton shows locked state, RubricBuilderComponent opens in locked mode.

## 5. Data Contract

- **Existing data flow:** `_questions` list of maps → `_mapQuestionsToAssignmentQuestions()` → rubric passthrough already exists at line 758.
- **New state:** `Set<int> _publishValidationErrors = {}`, `bool _isRubricLocked = false`.
- **Supabase call for D-09:** `supabase.from('assignment_distributions').select('id').eq('assignment_id', assignmentId).eq('status', 'active').limit(1)` and `supabase.from('work_sessions').select('id').eq('assignment_id', assignmentId).limit(1)`.

## 6. Cau truc Code

New methods to add:
```dart
Widget _buildRubricSection(int questionIndex) { ... }
Future<void> _openRubricBuilder(int questionIndex) async { ... }
void _updateRubricPoints(int questionIndex, Map<String, dynamic>? rubric) { ... }
bool _validatePublishRubrics() { ... }
Future<void> _checkRubricLock() async { ... }
```

## 7. Integration Points

- **Who calls this:** Existing navigation -- teacher navigates to create/edit assignment.
- **What this calls:**
  - `RubricSummaryButton` (Wave 1) -- widget
  - `RubricBuilderComponent` (Wave 2) -- widget via showModalBottomSheet
  - `SupabaseService.client` -- for D-09 lock check query
  - Existing `_mapQuestionsToAssignmentQuestions()` -- rubric already in flow

## 8. Tasks

<wave>3</wave>

<task id="3.7">
  <title>Integrate rubric into TeacherCreateAssignmentScreen</title>
  <read_first>
    - lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (FULL FILE -- understand _questions structure, question rendering, publish flow, points handling)
    - lib/widgets/rubric/rubric_summary_button.dart (RubricSummaryButton widget API)
    - lib/widgets/rubric/rubric_builder_component.dart (RubricBuilderComponent widget API)
    - lib/domain/entities/assignment_question.dart (AssignmentQuestion entity with rubric field)
    - lib/core/services/supabase_service.dart (SupabaseService.client pattern)
  </read_first>
  <action>
    1. Add imports at top: `import 'package:ai_mls/widgets/rubric/rubric_summary_button.dart';` and `import 'package:ai_mls/widgets/rubric/rubric_builder_component.dart';`.
    2. Add state variables:
       - `Set<int> _publishValidationErrors = {};`
       - `bool _isRubricLocked = false;`
    3. In `initState()` or equivalent init method: if editing existing assignment (`_assignmentId != null`), call `_checkRubricLock()`.
    4. Add method `Future<void> _checkRubricLock() async`:
       - `if (_assignmentId == null) return;`
       - `try { final distResult = await SupabaseService.client.from('assignment_distributions').select('id').eq('assignment_id', _assignmentId!).eq('status', 'active').limit(1); final wsResult = await SupabaseService.client.from('work_sessions').select('id').eq('assignment_id', _assignmentId!).limit(1); setState(() { _isRubricLocked = (distResult as List).isNotEmpty || (wsResult as List).isNotEmpty; }); } catch (e) { AppLogger.error('Error checking rubric lock: $e', error: e); }`
    5. Add method `Widget _buildRubricSection(int questionIndex)`:
       - `final q = _questions[questionIndex];`
       - `final type = q['type'];` -- check how question type is stored in _questions map (may be QuestionType enum or string).
       - `if (type != QuestionType.essay && type != QuestionType.shortAnswer) return const SizedBox.shrink();` (or string comparison if stored as string).
       - `final rubric = q['rubric'] as Map<String, dynamic>?;`
       - Return `RubricSummaryButton(rubric: rubric, isLocked: _isRubricLocked, onTap: () => _openRubricBuilder(questionIndex))`.
    6. Add method `Future<void> _openRubricBuilder(int questionIndex) async`:
       - `await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DesignRadius.lg))), builder: (_) => RubricBuilderComponent(initialRubric: _questions[questionIndex]['rubric'] as Map<String, dynamic>?, isLocked: _isRubricLocked, onSave: (newRubric) { _updateRubricPoints(questionIndex, newRubric); Navigator.pop(context); }));`
    7. Add method `void _updateRubricPoints(int questionIndex, Map<String, dynamic>? rubric)`:
       - `setState(() { _questions[questionIndex]['rubric'] = rubric; });`
       - D-06 points auto-sync: `if (rubric != null) { final criteria = rubric['criteria'] as List<dynamic>? ?? []; final totalPoints = criteria.fold<double>(0, (sum, c) => sum + ((c as Map<String, dynamic>)['max_points'] as num? ?? 0).toDouble()); setState(() { _questions[questionIndex]['points'] = totalPoints; }); }`
       - Clear publish validation error for this question: `_publishValidationErrors.remove(questionIndex);`
    8. Insert `_buildRubricSection(questionIndex)` call into the question editor card builder -- find where essay/shortAnswer questions render their content section, add the rubric section call after the question content and before the points/scoring section.
    9. D-06 points field disable: in the points TextFormField for essay/shortAnswer questions, add `enabled: _questions[questionIndex]['rubric'] == null` condition. When disabled, show the auto-calculated value as read-only text.
    10. Publish validation (D-08): find the publish/distribute method. BEFORE calling the RPC or use case:
        - `final errors = <int>{};`
        - `for (int i = 0; i < _questions.length; i++) { final type = _questions[i]['type']; if ((type == QuestionType.essay || type == QuestionType.shortAnswer) && _questions[i]['rubric'] == null) { errors.add(i); } }`
        - `if (errors.isNotEmpty) { setState(() => _publishValidationErrors = errors); /* scroll to first error question */ if (errors.length > 1) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: DesignColors.error, content: Text('Co ${errors.length} cau hoi tu luan chua co Rubric. Vui long them Rubric truoc khi phat hanh.', style: DesignTypography.bodyMedium.copyWith(color: DesignColors.white)), duration: Duration(seconds: 4))); return; }`
    11. In question card builder: if `_publishValidationErrors.contains(questionIndex)`, wrap the card content with `Container(decoration: BoxDecoration(border: Border.all(color: DesignColors.error, width: 2), borderRadius: BorderRadius.circular(DesignRadius.md)))` and add error message row below: `Padding(padding: EdgeInsets.only(top: DesignSpacing.xs, left: DesignSpacing.lg, right: DesignSpacing.lg), child: Row(children: [Icon(Icons.error_outline, size: DesignIcons.xsSize, color: DesignColors.error), SizedBox(width: DesignSpacing.xs), Expanded(child: Text('Cau hoi tu luan phai co Rubric truoc khi phat hanh.', style: DesignTypography.caption.copyWith(color: DesignColors.error)))]))`.
    12. Draft save: NO changes needed -- existing flow already passes rubric as-is (line 758), null is allowed for drafts per D-08.
  </action>
  <acceptance_criteria>
    - grep "RubricSummaryButton" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
    - grep "RubricBuilderComponent" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
    - grep "_isRubricLocked" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (D-09)
    - grep "_publishValidationErrors" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (D-08)
    - grep "Cau hoi tu luan phai co Rubric" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (publish error text)
    - grep "_updateRubricPoints" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (D-06 auto-sync)
    - grep "work_sessions" lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart (D-09 lock query)
    - flutter analyze lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- Essay/shortAnswer questions show RubricSummaryButton in editor.
- Tapping button opens RubricBuilderComponent bottom sheet.
- Saving rubric updates question's rubric field and auto-syncs points (D-06).
- Points field disabled when rubric is configured for essay/shortAnswer.
- Publish blocked with visual errors when essay/shortAnswer has no rubric (D-08).
- Draft save allows null rubric (D-08).
- Rubric locked for assignments with active distributions or work sessions (D-09).

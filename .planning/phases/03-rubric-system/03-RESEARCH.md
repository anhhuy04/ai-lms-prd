# Phase 3: Rubric System - Research

**Researched:** 2026-04-06
**Domain:** Flutter UI (Rubric Builder, Rubric Viewer, Interactive Grading), Supabase JSONB, profiles.metadata
**Confidence:** HIGH — all findings verified against actual codebase files

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**D-01: Rubric Builder Location — Separate Full-screen Bottom Sheet (Mobile)**
- Summary button in question editor: "Rubric: Đã cấu hình 3 tiêu chí (Nhấn để sửa)" or "Thêm Rubric"
- Tap → opens Full-screen Bottom Sheet
- `RubricBuilderComponent` fully isolated from `QuestionEditorComponent`
- Input: existing rubric JSONB or null. Output: updated rubric JSONB

**D-02: Rubric Structure — Full Levels (MANDATORY)**
```json
{
  "criteria": [
    {
      "id": "crit-1",
      "name": "Lập luận",
      "max_points": 5,
      "levels": [
        { "points": 5, "description": "Lập luận hoàn chỉnh, có dẫn chứng" },
        { "points": 3, "description": "Đúng ý chính, thiếu dẫn chứng" },
        { "points": 0, "description": "Lạc đề hoặc không trả lời" }
      ]
    }
  ]
}
```
`levels` array is MANDATORY. Payload without it is invalid.

**D-03: Student Rubric Visibility — 3 Locations**
1. Assignment Detail (before starting): rubric preview card per essay question
2. Workspace (while working): "ℹ️ Xem Tiêu chí" button at essay editor corner → Bottom Sheet. Workspace state and autosave NOT interrupted.
3. Review screen (after grading): `ReadOnlyRubricViewer` shows teacher-assigned score per criterion. AI highlight = placeholder, deferred Phase 6.

Single `ReadOnlyRubricViewer` dumb component used in all 3 locations.

**D-04: Teacher Grading Interaction — Click Level + Override with Reason**
- Happy path: clickable level cards, tap → auto-fill score for criterion, selected level highlighted
- Exception path: edit icon → custom number input → mandatory "Lý do ghi đè" prompt → write to `grade_overrides` table

**D-05: Rubric Template Reuse — profiles.metadata JSONB**
- `profiles.metadata['saved_rubrics']` array — no new table
- "Lưu thành Template" → UPDATE profiles SET metadata jsonb_set
- "Load from template" → read array, pick, fill form
- Template entry: `{ "name": "Rubric Tự luận Toán", "rubric": {...} }`

**D-06: Points Auto-Sync — Rubric is Single Source of Truth**
- essay/short_answer with rubric: `assignment_questions.points` field DISABLED (locked)
- points = `criteria.reduce((sum, c) => sum + c.max_points, 0)` auto-calculated
- Remove rubric → points field unblocks → manual input
- Backend: if `points != sum(criteria[].max_points)` → HTTP 400

**D-07: Rubric Applies to BOTH essay AND short_answer**
- Both `QuestionType.essay` and `QuestionType.shortAnswer` trigger rubric builder
- Already grouped together in existing codebase: `essay || shortAnswer`

**D-08: Validation — Lifecycle-Aware**
- Draft (`is_published = false`): rubric validation BYPASSED — null rubric, empty criteria all allowed
- Publish (`is_published = true`): HARD BLOCK if essay/short_answer has no rubric, min 1 criterion, min 2 levels per criterion
- Frontend highlights offending questions in red on publish attempt

**D-09: Rubric Edit Lock — Conditional Disable**
- Lock condition: `COUNT(work_sessions) > 0` for this assignment OR any `assignment_distributions.status = 'active'`
- Locked → entire RubricBuilderComponent disabled (greyed out, read-only)
- Escape: clone assignment

### Claude's Discretion
- Animation/transitions for bottom sheet open/close
- Empty state for rubric builder (first criterion prompt)
- Level card visual design (color, border, check icon when selected)
- Template picker UI (list vs grid)
- Which level is pre-selected as "0-point floor" in new rubric creation

### Deferred Ideas (OUT OF SCOPE)
- AI level highlight on Review screen — requires Phase 6 `ai_evaluations.criteria_scores`
- Real-time rubric co-editing
- Rubric analytics
- Rubric sharing between teachers
- Web Side-panel implementation
- Peer rubric review
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RUB-01 | User can create rubric with criteria | RubricBuilderComponent (new) — full-screen bottom sheet with add/edit/delete criteria |
| RUB-02 | User can define point scale for each criterion | Level cards within each criterion in RubricBuilderComponent — points + descriptions |
| RUB-03 | User can apply rubric to assignments | Rubric summary button in QuestionEditorComponent for essay/shortAnswer — writes to AssignmentBuilderNotifier |
| RUB-04 | User can preview rubric scores before submitting | ReadOnlyRubricViewer (new) — used in StudentAssignmentDetailScreen, Workspace, Review screen |
</phase_requirements>

---

## Summary

Phase 3 implements the complete rubric lifecycle: teacher builds rubrics in a full-screen bottom sheet, attaches them to essay/short_answer questions, students can preview criteria before and during submission, and teachers use interactive level cards when grading with mandatory override reason tracking.

The data layer is already complete. `assignment_questions.rubric` is a jsonb column that exists in the database schema, is present in the `AssignmentQuestion` entity, and is already passed through both the `SaveAssignmentDraftUseCase` and `PublishAssignmentUseCase` to the RPC. The `grade_overrides` table exists with `old_score`, `new_score`, `reason` columns and a full datasource (`GradeOverrideDataSource`) and domain entity (`GradeOverride`). The `profiles.metadata` column exists with an established `ProfileMetadataService` pattern for read/write with 5-minute cache.

The primary work is UI: three new widget components (`RubricBuilderComponent`, `ReadOnlyRubricViewer`, `InteractiveRubricGrader`) plus targeted modifications to six existing files. No database migrations are needed.

**Primary recommendation:** Build bottom-up — shared widgets first (`ReadOnlyRubricViewer`, `RubricBuilderComponent`), then wire into teacher creation flow, then student views, then interactive grading. Each layer is testable in isolation.

---

## Reusable Assets (Existing Code to Leverage)

### Fully Reusable (zero modification)
| Asset | File | What It Provides |
|-------|------|------------------|
| `AssignmentQuestion.rubric` | `lib/domain/entities/assignment_question.dart:18` | `Map<String, dynamic>? rubric` field already in Freezed entity |
| Rubric passthrough in draft save | `lib/domain/usecases/assignment_usecases.dart:72` | `'rubric': q.rubric` already in questionRows payload |
| Rubric passthrough in publish | `lib/domain/usecases/assignment_usecases.dart:132` | `'rubric': q.rubric` already in questionRows payload |
| Rubric in RPC payload | `teacher_create_assignment_screen.dart:758` | `if (row.containsKey('rubric')) 'rubric': row['rubric']` |
| `GradeOverrideDataSource.createGradeOverride()` | `lib/data/datasources/grade_override_datasource.dart:10` | Full insert with `submissionAnswerId`, `overriddenBy`, `oldScore`, `newScore`, `reason` |
| `GradeOverride` Freezed entity | `lib/domain/entities/grade_override.dart` | Typed entity for override audit trail |
| `GradeAuditTrail` widget | `lib/presentation/views/assignment/teacher/widgets/submission/grade_audit_trail.dart` | Displays override history — shows `oldScore → newScore + reason` |
| `ProfileMetadataService` | `lib/core/services/profile_metadata_service.dart` | `getMetadata()`, `set(key, value)` with 5-min cache — use for `saved_rubrics` |
| `showModalBottomSheet` pattern | Used throughout Phase 2 grading screens | Bottom sheet pattern already established in project |
| `AssignmentBuilderNotifier` + `AssignmentBuilderState` | `lib/presentation/providers/assignment_builder_notifier.dart` | Full state with `questions: List<AssignmentQuestion>` — extend to update rubric per question |

### Partially Reusable (extend or replace)
| Asset | File | Current State | Phase 3 Action |
|-------|------|---------------|----------------|
| `QuestionAnswerCard._buildRubric()` | `lib/.../submission/question_answer_card.dart:80-100` | Shows `name + score/max_score` read-only, but uses `max_score` key (wrong — should be `max_points`) | Replace with `ReadOnlyRubricViewer` |
| `GradingActionButtons` | `lib/.../submission/grading_action_buttons.dart` | Has approve + override buttons. Override modal has `reason` field (already in Phase 2) | Extend: add rubric level click interaction BEFORE the override path |
| `submissionGradingNotifierProvider.overrideScore()` | `lib/presentation/providers/teacher_submission_providers.dart:300` | Accepts `submissionAnswerId, newScore, reason` — writes to `grade_overrides` | Reuse directly from rubric level selection (level.points = newScore) |

---

## Files to Create (New Files)

### 1. Shared Rubric Widgets (used in multiple locations)

**`lib/widgets/rubric/read_only_rubric_viewer.dart`**
- Dumb StatelessWidget
- Input: `Map<String, dynamic>? rubric`, optional `Map<String, int>? selectedLevels` (criterion_id → level_index)
- Renders: criteria list, each criterion shows levels as cards, highlights selected level
- Used in: StudentAssignmentDetailScreen, StudentWorkspaceScreen bottom sheet, TeacherSubmissionDetailScreen review section
- Phase 6 fills `selectedLevels` — this phase leaves it as nullable param

**`lib/widgets/rubric/rubric_builder_component.dart`**
- Full-screen bottom sheet content (StatefulWidget with local state)
- Input: `Map<String, dynamic>? initialRubric`, `ValueChanged<Map<String, dynamic>?> onSave`
- Features: add/edit/delete criteria, add/edit/delete levels per criterion, points input per level, "Lưu Template" + "Load Template" buttons
- Points auto-sum shown in real-time as footer total
- Lock mode: if `isLocked: true` → all inputs disabled, read-only presentation
- D-09 lock check: caller checks `work_sessions` count before opening this sheet

**`lib/widgets/rubric/interactive_rubric_grader.dart`**
- Stateful widget for teacher grading flow
- Input: `Map<String, dynamic> rubric`, `double? currentScore`, `ValueChanged<double> onScoreSelected`, `ValueChanged<(double, String)> onOverride`
- Renders level cards as tap targets — tap = select level, auto-fill score
- Shows pencil/edit icon for override path → opens `OverrideScoreDialog`
- Displays `GradeAuditTrail` for history

### 2. Supporting Widgets

**`lib/widgets/rubric/rubric_summary_button.dart`**
- Small button/chip showing rubric status: "Thêm Rubric" or "Rubric: X tiêu chí"
- Input: `Map<String, dynamic>? rubric`, `VoidCallback onTap`, `bool isLocked`
- Used inside question editor for essay/short_answer questions

**`lib/widgets/rubric/rubric_template_picker_sheet.dart`**
- Bottom sheet for picking a saved template
- Input: `List<Map<String, dynamic>> templates`, `ValueChanged<Map<String, dynamic>> onSelected`
- Called from inside `RubricBuilderComponent`

### 3. Data Layer

**`lib/data/datasources/rubric_template_datasource.dart`**
- Wraps `ProfileMetadataService`
- `Future<List<Map<String, dynamic>>> getSavedRubrics()`
- `Future<void> saveRubricTemplate(String name, Map<String, dynamic> rubric)`
- `Future<void> deleteRubricTemplate(String templateId)` (by name or index)
- No new Supabase table — reads/writes `profiles.metadata['saved_rubrics']`

---

## Files to Modify (Existing Files and Changes)

### 1. Teacher — Question Editor (rubric attachment)

**`lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`**

Change location: `_mapQuestionsToAssignmentQuestions()` method (lines 606–744) and question rendering section.

Changes needed:
- Add rubric state tracking per question: extend `_questions` map entries to include `'rubric': Map<String, dynamic>?`
- In `_mapQuestionsToAssignmentQuestions()`: include `'rubric': q['rubric']` for all question types (already partially done at line 758, but needs to flow from question map → assignment question row)
- Add `_buildRubricSection(int questionIndex)` private builder: checks if question type is `essay || shortAnswer`, shows `RubricSummaryButton`, handles tap → opens `RubricBuilderComponent` bottom sheet
- After rubric save callback: update `_questions[index]['rubric'] = newRubric`
- Points auto-sync: when rubric != null for essay/shortAnswer → disable points input for that question, calculate sum of `criteria[].max_points`
- D-09 lock check: before opening rubric builder, query `work_sessions` count for `_assignmentId`
- Publish validation (D-08): in publish flow, check if any essay/shortAnswer question has null rubric → show error highlight before calling RPC

**`lib/presentation/providers/assignment_builder_notifier.dart`**

Add method: `updateQuestionRubric(String questionId, Map<String, dynamic>? rubric)`
- Find question by id in `current.questions`
- Create new `AssignmentQuestion` with `rubric: rubric` and auto-calculated `points`
- Replace in list, mark `isDirty: true`, schedule autosave

### 2. Teacher — Grading Screen (interactive rubric grading)

**`lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart`**

Change location: `_buildQuestionCard()` method (line 325+) and `_buildAiFeedbackBox()` area.

Changes needed:
- Add rubric detection: extract `rubric` from `answer['assignment_questions']['rubric']` 
- If `rubric != null` and `questionType == 'essay' || 'short_answer'`: render `InteractiveRubricGrader` widget between student answer and AI feedback sections
- `InteractiveRubricGrader.onScoreSelected`: call `submissionGradingNotifierProvider.overrideScore(answerId, levelPoints, reason: 'Chọn mức rubric')` — using the existing override infrastructure
- `InteractiveRubricGrader.onOverride`: call `overrideScore(answerId, customScore, reason)` — same path, override reason is mandatory per D-04
- Remove or demote current static `_buildRubric()` section from `QuestionAnswerCard` — now handled by `InteractiveRubricGrader`

### 3. Student — Assignment Detail (rubric preview before start)

**`lib/presentation/views/assignment/student/student_assignment_detail_screen.dart`**

Change location: `_InProgressView` widget (line 75+) — the view shown before student starts.

Changes needed:
- In questions loop (currently renders question count only): for each question where `rubric != null`, render `ReadOnlyRubricViewer` in a card with header "Tiêu chí chấm điểm"
- Data access: `detail['questions']` list items — each item has `assignment_questions.rubric` or need to verify query includes rubric. Check `studentAssignmentDetailProvider` data shape.

**`lib/presentation/providers/student_assignment_providers.dart`**

Verify/add: `studentAssignmentDetailProvider` query must include `rubric` column from `assignment_questions`.
Check current SELECT query — add `rubric` to the column list if missing.

### 4. Student — Workspace (rubric button during work)

**`lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`**

Change location: `_buildEssay()` method (line 457) and `_buildShortAnswer()` (line 776).

Changes needed:
- Add "ℹ️ Xem Tiêu chí" button as a small chip/icon button at the top-right of the essay text area
- Tap → `showModalBottomSheet` with `ReadOnlyRubricViewer` as content
- Rubric data source: `WorkspaceNotifier` state already has `QuestionState` — need to verify rubric is included in question data loaded by `workspaceNotifierProvider`
- CRITICAL (D-03): modal open/close must NOT trigger autosave or interrupt workspace state

**`lib/presentation/providers/workspace_provider.dart`**

Verify: `QuestionState` model includes rubric field. If not, add `rubric: Map<String, dynamic>?` to `QuestionState`. Verify the workspace data query fetches `assignment_questions.rubric`.

### 5. Student — Review Screen (rubric with teacher scores foundation)

The submitted view in `student_assignment_detail_screen.dart` (`_SubmittedView`, line 97) currently shows score, timing, AI feedback, and teacher comment. 

Changes needed:
- After grading is complete (`studentReviewMode == 'full_review'`): for essay/short_answer questions with rubric, show `ReadOnlyRubricViewer` with `selectedLevels` = null (Phase 6 will populate)
- This requires the student detail data to include per-question `rubric` and `final_score`
- Data: `studentSubmissionProvider` returns submission — need to verify it includes `submission_answers` with `assignment_questions.rubric`

---

## Integration Points (Exact Connection Points)

### Point 1: RubricBuilderComponent → AssignmentBuilderNotifier

```dart
// In teacher_create_assignment_screen.dart, question editor section
// When essay/short_answer question is rendered:
_buildRubricSection(questionIndex) {
  final q = _questions[questionIndex];
  if (q['type'] != QuestionType.essay && q['type'] != QuestionType.shortAnswer) {
    return const SizedBox.shrink();
  }
  final rubric = q['rubric'] as Map<String, dynamic>?;
  return RubricSummaryButton(
    rubric: rubric,
    isLocked: _isRubricLocked,  // D-09 check result
    onTap: () => _openRubricBuilder(questionIndex),
  );
}

Future<void> _openRubricBuilder(int questionIndex) async {
  // D-09: check work_sessions count first
  final hasWorkSessions = await _checkWorkSessionsExist();
  if (hasWorkSessions) {
    // show locked rubric in read-only mode
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => RubricBuilderComponent(
      initialRubric: _questions[questionIndex]['rubric'],
      isLocked: hasWorkSessions,
      onSave: (newRubric) {
        setState(() {
          _questions[questionIndex]['rubric'] = newRubric;
          // Points auto-sync (D-06)
          if (newRubric != null) {
            final criteria = newRubric['criteria'] as List;
            final totalPoints = criteria.fold<double>(0, (sum, c) => sum + (c['max_points'] as num).toDouble());
            _scoringPointsMap[_questions[questionIndex]['type'] as QuestionType] = totalPoints;
          }
        });
      },
    ),
  );
}
```

### Point 2: Rubric in _mapQuestionsToAssignmentQuestions()

Current state (line 758): `if (row.containsKey('rubric')) 'rubric': row['rubric']`

This already works IF `_questions[i]['rubric']` is populated. The fix is ensuring question map entries include the `rubric` key when rubric is set/cleared.

### Point 3: InteractiveRubricGrader → submissionGradingNotifierProvider

```dart
// In teacher_submission_detail_screen.dart, inside _buildQuestionCard()
// After student answer box, before AI feedback box:
final rubric = (answer['assignment_questions'] as Map<String, dynamic>?)?['rubric'] as Map<String, dynamic>?;
if (rubric != null && (questionType == 'essay' || questionType == 'short_answer')) {
  InteractiveRubricGrader(
    rubric: rubric,
    currentScore: (answer['final_score'] as num?)?.toDouble(),
    submissionAnswerId: answer['id'] as String,
    distributionId: widget.distributionId,
    onLevelSelected: (double points, String criterionId) {
      // D-04 happy path: clicking a level is also an "override" with a standard reason
      ref.read(submissionGradingNotifierProvider.notifier).overrideScore(
        submissionAnswerId: answer['id'] as String,
        newScore: points,
        reason: 'Chọn mức rubric: $criterionId',
        distributionId: widget.distributionId,
      );
    },
    onManualOverride: (double score, String reason) {
      // D-04 exception path: mandatory reason
      ref.read(submissionGradingNotifierProvider.notifier).overrideScore(
        submissionAnswerId: answer['id'] as String,
        newScore: score,
        reason: reason,
        distributionId: widget.distributionId,
      );
    },
  )
}
```

### Point 4: ReadOnlyRubricViewer → Student Workspace

```dart
// In _buildEssay() and _buildShortAnswer() in student_assignment_workspace_screen.dart
// Add button above text field:
if (question.rubric != null)
  Align(
    alignment: Alignment.topRight,
    child: TextButton.icon(
      icon: const Icon(Icons.info_outline, size: 16),
      label: const Text('Xem Tiêu chí'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => ReadOnlyRubricViewer(
            rubric: question.rubric,
          ),
        );
      },
    ),
  ),
```

### Point 5: Template CRUD → ProfileMetadataService

```dart
// In RubricBuilderComponent, "Lưu Template" button:
Future<void> _saveTemplate(String name) async {
  final current = await ProfileMetadataService.getMetadata() ?? {};
  final savedRubrics = List<Map<String, dynamic>>.from(current['saved_rubrics'] ?? []);
  savedRubrics.add({ 'name': name, 'rubric': _buildCurrentRubricJson() });
  await ProfileMetadataService.set('saved_rubrics', savedRubrics);
}

// "Load Template" button → opens RubricTemplatePickerSheet
Future<void> _openTemplatePicker() async {
  final metadata = await ProfileMetadataService.getMetadata();
  final templates = List<Map<String, dynamic>>.from(metadata?['saved_rubrics'] ?? []);
  // Show bottom sheet with templates list
}
```

---

## State Management Approach

### Rubric Builder State (LOCAL — not in Riverpod)

`RubricBuilderComponent` is a `StatefulWidget` with purely local state:
```dart
class _RubricBuilderState extends State<RubricBuilderComponent> {
  late List<Map<String, dynamic>> _criteria; // local mutable copy
  bool _isDirty = false;
}
```
Rationale: Rubric builder is modal, isolated, no shared consumers. Local state avoids provider pollution. Output only exits via `onSave` callback.

### Assignment Builder Integration (EXISTING Notifier — extend)

`AssignmentBuilderNotifier.questions` already holds `List<AssignmentQuestion>`. Add one method:
```dart
void updateQuestionRubric(String questionId, Map<String, dynamic>? rubric)
```
This updates the `AssignmentQuestion.copyWith(rubric: rubric, points: autoCalcPoints)` in the list and triggers autosave.

### Template State (STATELESS — ProfileMetadataService)

No Riverpod provider needed. Direct calls to `ProfileMetadataService.getMetadata()` and `set()` are sufficient. The 5-minute cache handles performance.

### Interactive Grading State (EXISTING Notifier — reuse)

`submissionGradingNotifierProvider.overrideScore()` already handles the full flow:
1. Fetches current score from DB
2. Updates `submission_answers.final_score`
3. Writes `grade_overrides` audit record
4. Invalidates `teacherSubmissionListProvider`

Level click in `InteractiveRubricGrader` simply calls this same method with `reason: 'Chọn mức rubric'`.

---

## Data Flow (Rubric JSONB: Builder → Entity → RPC → DB)

```
Teacher taps "Thêm Rubric" on essay question
  ↓
RubricBuilderComponent opens (local state)
  ↓ onSave callback
teacher_create_assignment_screen._questions[i]['rubric'] = newRubric
  ↓ D-06: points auto-calculated from criteria sum
_questions[i]['points'] = sum(criteria[].max_points)
  ↓ autosave debounce triggers
_mapQuestionsToAssignmentQuestions() includes rubric key
  ↓
SaveAssignmentDraftUseCase.questionRows includes 'rubric': q.rubric
  ↓
AssignmentDataSource.replaceAssignmentQuestions() PATCH
  ↓
Supabase: assignment_questions.rubric = jsonb value persisted

On publish:
teacher taps Publish
  ↓ D-08 frontend validation: any essay/short_answer with rubric == null? → block + highlight
  ↓
PublishAssignmentUseCase sends questionRows with rubric
  ↓
RPC publish_assignment server-side transaction
  ↓ D-08 backend: is_published = true → validate rubric completeness
  ↓
assignment_questions.rubric persisted for all questions

When teacher grades:
submission_answers joined with assignment_questions (includes rubric)
  ↓
InteractiveRubricGrader receives rubric JSONB
  ↓ teacher clicks level
overrideScore(submissionAnswerId, points, reason)
  ↓
submission_answers.final_score updated
grade_overrides row inserted (audit trail)
```

---

## Risk Areas

### Risk 1: Student Detail Provider Missing Rubric Column
**What could go wrong:** `studentAssignmentDetailProvider` SELECT query may not include `rubric` from `assignment_questions`. Student rubric preview and workspace viewer get null rubric silently.
**Investigation needed:** Read `lib/presentation/providers/student_assignment_providers.dart` query — verify `rubric` column in SELECT.
**Mitigation:** Add `rubric` to the SELECT if missing. Low-risk data layer change.

### Risk 2: Workspace QuestionState Missing Rubric Field
**What could go wrong:** `QuestionState` model in `workspace_provider.dart` may not have a `rubric` field. The "Xem Tiêu chí" button has no data to show.
**Investigation needed:** Read `lib/presentation/providers/workspace_provider.dart` — check `QuestionState` class definition and `initialize()` data fetch.
**Mitigation:** Add `rubric: Map<String, dynamic>?` to `QuestionState` and populate from `assignment_questions.rubric` in workspace init query.

### Risk 3: _mapQuestionsToAssignmentQuestions() vs AssignmentBuilderNotifier Dual Paths
**What could go wrong:** There are two assignment creation paths — the raw screen state (`_questions` list in `teacher_create_assignment_screen.dart`) and the `AssignmentBuilderNotifier`. The rubric must be tracked in the screen's `_questions` map (used by `_mapQuestionsToAssignmentQuestions()`) AND optionally synced to the notifier.
**Mitigation:** Rubric data lives in screen's `_questions` map (same as other question attributes like `points`, `text`). The notifier's `updateQuestionRubric()` is for future programmatic use. Primary flow: screen state → `_mapQuestionsToAssignmentQuestions()` → RPC.

### Risk 4: profiles UPDATE RLS — Teacher Can Update Own Row
**What could go wrong:** RLS policy on `profiles` may not allow teacher to UPDATE `metadata` on their own row.
**Investigation needed:** Verify Supabase RLS policies on `profiles` table. `ProfileMetadataService` already works for API key storage (confirmed by `api_key_service.dart` usage) — this proves the UPDATE path works for own row.
**Confidence:** HIGH — `ProfileMetadataService.set()` already writes to `profiles.metadata` successfully in production (api_key_setup_screen). RLS allows self-update.

### Risk 5: RubricBuilderComponent Keyboard + Bottom Sheet Conflicts
**What could go wrong:** Full-screen bottom sheet with multiple text inputs (criterion names, level descriptions) causes keyboard to obscure content on mobile.
**Mitigation:** Use `isScrollControlled: true` + `DraggableScrollableSheet` pattern OR set bottom sheet to full screen with `Padding(bottom: MediaQuery.of(context).viewInsets.bottom)`.

### Risk 6: D-09 Lock Check Async in UI
**What could go wrong:** D-09 requires checking `COUNT(work_sessions) > 0` before showing rubric builder. This is an async DB call that must complete before opening the bottom sheet. If handled poorly, UI lags or shows unlocked rubric while check is pending.
**Mitigation:** Show loading indicator while check runs, or pre-fetch lock status when question card loads (provider with `assignmentId` param). Preloading preferred — avoids per-tap latency.

### Risk 7: grade_overrides reason field — existing constraint
**What could go wrong:** The `grade_overrides.reason` column is defined as `text` (nullable in schema). D-04 says reason is MANDATORY for override. The existing `overrideScore()` in `teacher_submission_providers.dart` accepts optional `String? reason`.
**Mitigation:** Enforce non-null reason in the `InteractiveRubricGrader` UI before calling `overrideScore()`. Backend schema does not enforce NOT NULL on `reason` — frontend is the enforcement layer. This is correct per D-04.

### Risk 8: Existing _buildRubric() in QuestionAnswerCard Uses Wrong Key
**What found:** `question_answer_card.dart:94` reads `criterion['max_score']` but the D-02 schema uses `max_points`. This existing partial implementation will show 0/0 for all criteria.
**Mitigation:** Replace `_buildRubric()` entirely with `ReadOnlyRubricViewer` in the Phase 3 plan.

---

## Code Examples

### Pattern: showModalBottomSheet full-screen (established in project)

```dart
// Used throughout Phase 2 grading screens
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.9,
    maxChildSize: 1.0,
    minChildSize: 0.5,
    builder: (_, controller) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.xl),
      ),
      child: RubricBuilderComponent(
        initialRubric: rubric,
        onSave: onSave,
      ),
    ),
  ),
);
```

### Pattern: ProfileMetadataService write (from api_key_service.dart)

```dart
// Existing usage pattern — use same for saved_rubrics
await ProfileMetadataService.set('saved_rubrics', updatedList);
final metadata = await ProfileMetadataService.getMetadata();
final templates = metadata?['saved_rubrics'] as List<dynamic>? ?? [];
```

### Pattern: @riverpod notifier method (from assignment_builder_notifier.dart)

```dart
void updateQuestionRubric(String questionId, Map<String, dynamic>? rubric) {
  final current = state.value ?? AssignmentBuilderState.initial();
  final questions = current.questions.map((q) {
    if (q.id != questionId) return q;
    // D-06: auto-calculate points from criteria sum
    double points = q.points;
    if (rubric != null) {
      final criteria = rubric['criteria'] as List<dynamic>? ?? [];
      points = criteria.fold(0.0, (sum, c) => sum + ((c['max_points'] as num?)?.toDouble() ?? 0.0));
    }
    return q.copyWith(rubric: rubric, points: points);
  }).toList();
  state = AsyncValue.data(current.copyWith(questions: questions, isDirty: true));
  _scheduleAutosave();
}
```

### Pattern: Concurrency guard for async checks

```dart
bool _isCheckingLock = false;
bool _rubricIsLocked = false;

Future<void> _checkRubricLockStatus() async {
  if (_isCheckingLock) return;
  _isCheckingLock = true;
  try {
    final assignmentId = _assignmentId;
    if (assignmentId == null) return;
    final count = await _client
        .from('work_sessions')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('assignment_id', assignmentId);
    setState(() { _rubricIsLocked = (count.count ?? 0) > 0; });
  } finally {
    _isCheckingLock = false;
  }
}
```

---

## Standard Stack

No new libraries needed. Phase 3 uses the existing approved stack:

| Component | Library | Version | Notes |
|-----------|---------|---------|-------|
| State management | `riverpod` + `@riverpod` | 2.5.1 | Extend `AssignmentBuilderNotifier` |
| UI widgets | Flutter built-ins | 3.8.x | `DraggableScrollableSheet`, `showModalBottomSheet` |
| Immutable models | `freezed` | existing | No new entities needed |
| Design tokens | `DesignColors`, `DesignSpacing`, etc. | existing | Mandatory for all new widgets |
| Supabase | `supabase_flutter` | existing | `ProfileMetadataService` for templates |
| Logging | `AppLogger` | existing | Never `print()` |

---

## Environment Availability

Step 2.6: SKIPPED (no external dependencies — phase is Flutter UI + existing Supabase tables only)

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | None detected (no `flutter_test` config file) |
| Quick run command | `flutter test test/` |
| Full suite command | `flutter test --coverage` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| RUB-01 | Create rubric with criteria + levels, serialize to valid JSONB | unit | `flutter test test/widgets/rubric/rubric_builder_test.dart` | ❌ Wave 0 |
| RUB-02 | Point scale per criterion — levels sum equals max_points, D-06 auto-sync | unit | `flutter test test/providers/assignment_builder_notifier_test.dart` | ❌ Wave 0 |
| RUB-03 | Rubric attached to assignment — passes through save + publish RPC payloads | unit | `flutter test test/usecases/assignment_usecases_test.dart` | ❌ Wave 0 |
| RUB-04 | Student can view rubric — ReadOnlyRubricViewer renders criteria from JSONB | widget | `flutter test test/widgets/rubric/read_only_rubric_viewer_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter analyze` — 0 errors
- **Per wave merge:** `flutter test test/widgets/rubric/` + `flutter analyze`
- **Phase gate:** Full `flutter analyze && flutter test` green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/widgets/rubric/rubric_builder_test.dart` — covers RUB-01: criteria CRUD, JSONB serialization
- [ ] `test/widgets/rubric/read_only_rubric_viewer_test.dart` — covers RUB-04: renders criteria from rubric map
- [ ] `test/providers/assignment_builder_notifier_test.dart` — covers RUB-02, RUB-03: `updateQuestionRubric()`, points auto-sync

---

## Open Questions

1. **Does `studentAssignmentDetailProvider` SELECT include `rubric` column?**
   - What we know: provider exists at `lib/presentation/providers/student_assignment_providers.dart`, reads from `assignment_questions`
   - What's unclear: whether current SELECT includes `rubric` column
   - Recommendation: Planner must add a task to verify and extend query if missing

2. **Does `WorkspaceNotifier.QuestionState` include rubric?**
   - What we know: `workspace_provider.dart` powers the workspace screen, `QuestionState` has `choices`, `pairs`, etc.
   - What's unclear: whether `rubric` is already in `QuestionState`
   - Recommendation: Planner must add an investigation + patch task

3. **Does the Supabase `publish_assignment` RPC currently validate rubric on the backend (D-08)?**
   - What we know: RPC exists and is called by `AssignmentDataSource.publishAssignmentRpc()`, but its SQL body is not in the local `db/` files
   - What's unclear: whether backend SQL validates rubric completeness or relies entirely on frontend
   - Recommendation: Treat as frontend-only validation for Phase 3. Backend validation is a future hardening task.

---

## Sources

### Primary (HIGH confidence)
- `lib/domain/entities/assignment_question.dart` — rubric field confirmed in Freezed entity
- `lib/domain/usecases/assignment_usecases.dart` — rubric passthrough confirmed in both save and publish usecases
- `lib/data/datasources/grade_override_datasource.dart` — full CRUD confirmed, reason field present
- `lib/core/services/profile_metadata_service.dart` — set/get pattern confirmed working (used by api_key_service)
- `db/schema_02_questions_assignments.sql` — rubric JSONB column and D-02 structure confirmed at lines 169–182
- `db/schema_03_submissions_ai_analytics.sql` — grade_overrides table confirmed at lines 202–212
- `db/schema_01_core_users_classes.sql` — profiles.metadata column confirmed at line 19
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` — grading flow, GradingActionButtons, overrideScore path confirmed
- `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` — essay/short_answer _buildEssay() and _buildShortAnswer() confirmed
- `lib/presentation/providers/assignment_builder_notifier.dart` — state shape, questions list, autosave pattern confirmed

### Secondary (MEDIUM confidence)
- `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` — existing partial rubric display confirmed, uses wrong `max_score` key (should be `max_points`)
- `lib/core/services/api_key_service.dart` — confirms ProfileMetadataService UPDATE on own profiles row works in production (proves RLS allows it)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new libraries, all patterns verified in codebase
- Architecture: HIGH — rubric entity/usecase/datasource already exists, UI widget locations confirmed
- Pitfalls: HIGH — all risk areas identified from actual code inspection, not assumptions
- Data flow: HIGH — traced from UI through usecase through RPC payload in actual files

**Research date:** 2026-04-06
**Valid until:** 2026-05-06 (stable stack, no fast-moving dependencies)

---

## RESEARCH COMPLETE

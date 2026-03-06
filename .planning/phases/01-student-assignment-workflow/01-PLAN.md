---
phase: 01-student-assignment-workflow
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/core/routes/route_constants.dart
  - lib/core/routes/app_router.dart
  - lib/presentation/providers/student_assignment_providers.dart
  - lib/presentation/views/assignment/student/student_assignment_list_screen.dart
  - lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
  - lib/domain/entities/submission.dart
  - lib/domain/entities/submission.freezed.dart
autonomous: true
requirements:
  - STU-01
  - STU-02
---

<objective>
Create student assignment list and detail views with routing
</objective>

<context>
@.planning/phases/01-student-assignment-workflow/01-CONTEXT.md
@.planning/REQUIREMENTS.md

# Key Interfaces from Codebase

From lib/domain/entities/assignment.dart:
```dart
class Assignment {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  AssignmentStatus status;
  int? totalPoints;
  List<Question> questions;
}
```

From lib/widgets/list_item/assignment/class_detail_assignment_list_item.dart:
- Reusable AssignmentCard pattern
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create Submission entity</name>
  <files>lib/domain/entities/submission.dart, lib/domain/entities/submission.freezed.dart</files>
  <action>
Create Submission entity with Freezed:
- id, assignmentId, studentId, status (draft/submitted/graded)
- submittedAt, gradedAt, score, feedback
- Map<questionId, Answer> answers
- List<String> uploadedFileUrls

Run build_runner after creation.
  </action>
  <verify>
<automated>flutter analyze lib/domain/entities/submission.dart</automated>
  </verify>
  <done>Submission entity created with JSON serialization</done>
</task>

<task type="auto">
  <name>Task 2: Create student assignment routes and providers</name>
  <files>lib/core/routes/route_constants.dart, lib/core/routes/app_router.dart, lib/presentation/providers/student_assignment_providers.dart</files>
  <action>
Add student assignment routes:
- /student/assignments (list)
- /student/assignment/:id (detail)

Create providers:
- studentAssignmentListProvider (fetches assignments for current student)
- studentAssignmentDetailProvider(id)
- submissionProvider(assignmentId) - gets or creates draft

Use existing ref.watch patterns from class_providers.dart
  </action>
  <verify>
<automated>flutter analyze</automated>
  </verify>
  <done>Routes and providers created, compile passes</done>
</task>

<task type="auto">
  <name>Task 3: Create student assignment list screen</name>
  <files>lib/presentation/views/assignment/student/student_assignment_list_screen.dart</files>
  <action>
Create StudentAssignmentListScreen:
- Reuse existing AssignmentCard pattern from class_detail_assignment_list_item.dart
- Show: title, subject, due date, status badge, completion %
- Sort by due date (nearest first)
- Filter chips: All / Pending / Submitted / Graded
- Use ShimmerListTileLoading for loading state
- Pull-to-refresh functionality
  </action>
  <verify>
<automated>flutter analyze lib/presentation/views/assignment/student/</automated>
  </verify>
  <done>Assignment list displays with filters, loading states</done>
</task>

<task type="auto">
  <name>Task 4: Create student assignment detail screen</name>
  <files>lib/presentation/views/assignment/student/student_assignment_detail_screen.dart</files>
  <action>
Create StudentAssignmentDetailScreen:
- Header: assignment title, due date, time remaining
- Scrollable question list showing: number, content, type icon, points
- Essay questions: expandable with text field preview
- "Start Working" button to enter workspace
- Use DesignTokens (DesignColors, DesignSpacing, DesignTypography)
  </action>
  <verify>
<automated>flutter analyze lib/presentation/views/assignment/student/</automated>
  </verify>
  <done>Assignment detail shows all questions and info</done>
</task>

</tasks>

<verification>
- flutter analyze passes
- Routes navigate correctly
- List and detail screens render with mock data
</verification>

<success_criteria>
- Student can view list of assigned assignments (STU-01)
- Student can view assignment details with questions (STU-02)
</success_criteria>

<output>
After completion, create .planning/phases/01-student-assignment-workflow/01-01-SUMMARY.md
</output>

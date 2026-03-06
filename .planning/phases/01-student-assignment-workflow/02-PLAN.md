---
phase: 01-student-assignment-workflow
plan: 02
type: execute
wave: 2
depends_on: [01]
files_modified:
  - lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
  - lib/presentation/providers/workspace_provider.dart
  - lib/data/repositories/submission_repository_impl.dart
  - lib/domain/repositories/submission_repository.dart
  - lib/data/datasources/submission_datasource.dart
autonomous: true
requirements:
  - STU-03
  - STU-04
  - STU-05
  - STU-06
---

<objective>
Create workspace for completing assignments with auto-save, file upload, and submission
</objective>

<context>
@.planning/phases/01-student-assignment-workflow/01-CONTEXT.md

# Key Context
- Auto-save: use existing `easy_debounce` package (2 second debounce)
- File upload: Supabase Storage API
- Question types: Multiple choice, True/False, Essay, Fill-in-blank
- Submission: Confirmation dialog, disable during submit
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create submission repository and datasource</name>
  <files>lib/domain/repositories/submission_repository.dart, lib/data/repositories/submission_repository_impl.dart, lib/data/datasources/submission_datasource.dart</files>
  <action>
Create submission repository pattern:
- getSubmission(assignmentId, studentId)
- saveDraft(submission) - partial save
- submitAssignment(submissionId) - final submit
- uploadFile(file, submissionId)
- getSubmissionHistory(studentId)

Follow existing repository pattern from assignment_repository_impl.dart
  </action>
  <verify>
<automated>flutter analyze</automated>
  </verify>
  <done>Repository layer handles all submission operations</done>
</task>

<task type="auto">
  <name>Task 2: Create workspace provider with auto-save</name>
  <files>lib/presentation/providers/workspace_provider.dart</files>
  <action>
Create WorkspaceNotifierProvider:
- State: Map<questionId, Answer> answers, submissionStatus, savingStatus
- Methods: updateAnswer, saveDraft, submit, uploadFile
- Auto-save: Use easy_debounce - 2 second delay after answer change
- File upload: Supabase Storage, progress tracking
- Optimistic UI: immediate local update, async save
- Use concurrency guard pattern from CLAUDE.md
  </action>
<verify>
<automated>flutter analyze lib/presentation/providers/</automated>
  </verify>
  <done>Workspace provider handles all state and auto-save</done>
</task>

<task type="auto">
  <name>Task 3: Create assignment workspace screen</name>
<files>lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart</files>
<action>
Create StudentAssignmentWorkspaceScreen:
- Progress indicator: "Question X of Y answered"
- Question types:
  - Multiple choice: Radio buttons with options
  - True/False: Toggle buttons
  - Essay: Multi-line text field
  - Fill-in-blank: Text fields per blank
- Auto-save indicator: "Saving..." -> "Saved" -> hidden
- File upload section with progress
- Submit button with confirmation dialog
- Disable submit during upload/submission
  </action>
<verify>
<automated>flutter analyze lib/presentation/views/assignment/student/</automated>
  </done>
  <done>Workspace displays all question types with answers</done>
</task>

<task type="auto">
  <name>Task 4: Create submission confirmation and history</name>
  <files>lib/presentation/views/assignment/student/student_submission_confirm_screen.dart, lib/presentation/views/assignment/student/student_submission_history_screen.dart</files>
  <action>
Create:
1. SubmissionConfirmScreen - success state with timestamp, confirmation number
2. SubmissionHistoryScreen - list of past submissions with scores

History shows: assignment name, submitted date, score (if graded)
  </action>
  <verify>
<automated>flutter analyze lib/presentation/views/assignment/student/</automated>
  </verify>
  <done>Submission confirmation and history screens work</done>
</task>

</tasks>

<verification>
- flutter analyze passes
- Auto-save triggers after 2 second debounce
- File upload shows progress
- Submission creates confirmation
</verification>

<success_criteria>
- Student can complete assignment in workspace (STU-03)
- Auto-save works without data loss (STU-04)
- File upload functional (STU-05)
- Submission confirmation displayed (STU-06)
- Student can view submission history and scores (STU-07)
</success_criteria>

<output>
After completion, create .planning/phases/01-student-assignment-workflow/01-02-SUMMARY.md
</output>

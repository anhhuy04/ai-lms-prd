---
phase: 01-student-assignment-workflow
plan: 03
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/presentation/providers/student_assignment_providers.dart
  - lib/data/repositories/assignment_repository_impl.dart
  - lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
autonomous: true
gap_closure: true
requirements:
  - STU-01
  - STU-02

must_haves:
  truths:
    - "Học sinh có thể xem chi tiết bài tập với danh sách câu hỏi"
    - "Học sinh có thể vào workspace làm bài"
  artifacts:
    - path: "lib/presentation/views/assignment/student/student_assignment_detail_screen.dart"
      provides: "Assignment detail UI with questions list"
    - path: "lib/presentation/providers/student_assignment_providers.dart"
      provides: "Data fetching for assignment detail"
    - path: "lib/data/repositories/assignment_repository_impl.dart"
      provides: "getDistributionDetail implementation"
  key_links:
    - from: "assignment_list_screen.dart"
      to: "student_assignment_detail_screen.dart"
      via: "context.pushNamed with distributionId"
      pattern: "pushNamed.*studentAssignmentDetail"
    - from: "student_assignment_detail_screen.dart"
      to: "studentAssignmentDetailProvider"
      via: "ref.watch"
      pattern: "studentAssignmentDetailProvider"
---

<objective>
Fix navigation and data issues preventing students from viewing assignment details and entering workspace.

Gap 1: "học sinh chưa xem được chi tiết bài tập"
Gap 2: "chưa vào được vì bước 2 chưa xong"
</objective>

<context>
@.planning/phases/01-student-assignment-workflow/01-UAT.md
@lib/core/routes/app_router.dart
@lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
@lib/presentation/providers/student_assignment_providers.dart

Routes already exist:
- studentAssignmentDetail at /student/assignment/:assignmentId (line 344)
- studentAssignmentWorkspace at /student/assignment/workspace/:distributionId (line 357)

Navigation from list uses: context.pushNamed(AppRoute.studentAssignmentDetail, pathParameters: {'assignmentId': distributionId})
</context>

<tasks>

<task type="auto">
  <name>Task 1: Debug assignment detail provider</name>
  <files>lib/presentation/providers/student_assignment_providers.dart, lib/data/repositories/assignment_repository_impl.dart</files>
  <action>
    1. Check studentAssignmentDetailProvider implementation - verify it returns proper data structure
    2. Verify getDistributionDetail() in assignment_repository_impl.dart returns questions array
    3. Add logging to identify where it fails
    4. Ensure provider returns {title, description, dueDate, questions: [], points} structure

    Common issues to check:
    - Null check on questions array
    - Empty array handling in UI
    - Wrong data type returned
  </action>
  <verify>
    <automated>grep -n "getDistributionDetail" lib/data/repositories/assignment_repository_impl.dart | head -20</automated>
  </verify>
  <done>Provider returns valid assignment detail with questions array</done>
</task>

<task type="auto">
  <name>Task 2: Verify detail screen renders questions</name>
  <files>lib/presentation/views/assignment/student/student_assignment_detail_screen.dart</files>
  <action>
    1. Check _buildBody method renders questions list
    2. Verify it handles empty questions array gracefully
    3. Check if "Bat dau lam bai" button exists and navigates to workspace
    4. Ensure screen shows all required fields: title, description, points, dueDate, questions

    The screen should display:
    - Assignment title and description
    - Points and due date
    - List of questions with type and points
    - "Bat dau lam bai" button
  </action>
  <verify>
    <automated>grep -n "Bat dau\|workspace\|questions" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart</automated>
  </verify>
  <done>Screen displays all assignment details including questions list</done>
</task>

<task type="auto">
  <name>Task 3: Fix workspace navigation from detail screen</name>
  <files>lib/presentation/views/assignment/student/student_assignment_detail_screen.dart</files>
  <action>
    1. Find "Bat dau lam bai" button in detail screen
    2. Verify it uses correct route: AppRoute.studentAssignmentWorkspace
    3. Pass distributionId (not assignmentId) as path parameter
    4. Test navigation flow: List -> Detail -> Workspace

    Route pattern: /student/assignment/workspace/:distributionId
  </action>
  <verify>
    <automated>grep -n "studentAssignmentWorkspace\|pushNamed" lib/presentation/views/assignment/student/student_assignment_detail_screen.dart</automated>
  </verify>
  <done>Button navigates correctly to workspace with distributionId</done>
</task>

</tasks>

<verification>
After fixes:
1. Student taps assignment in list
2. Detail screen loads showing title, description, questions, due date
3. Tap "Bat dau lam bai" navigates to workspace
4. No errors in console, data displays correctly
</verification>

<success_criteria>
- Test 2 passes: Student can view assignment detail with questions
- Test 3 passes: Student can enter workspace from detail screen
</success_criteria>

<output>
After completion, create .planning/phases/01-student-assignment-workflow/01-03-SUMMARY.md
</output>

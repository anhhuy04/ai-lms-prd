---
status: complete
phase: 04-learning-analytics
source:
  - .planning/phases/04-learning-analytics/04-01-SUMMARY.md
  - .planning/phases/04-learning-analytics/04-02-SUMMARY.md
  - .planning/phases/04-learning-analytics/04-03-SUMMARY.md
started: 2026-03-19T00:00:00Z
updated: 2026-03-21T12:00:00Z
note: |
  Tests 1, 1b, 4 skipped (need student_skill_mastery data).
  Testing from test 2 onwards.
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 2
name: Student Analytics - Grade Trend Line Chart (RE-TEST)
expected: |
  Filter chips (Tuần/Tháng/Học kỳ/Tùy chỉnh) should be redesigned into a bottom sheet.
  Should add class filter/sort option.
awaiting: [testing complete]

## Tests

### 1. Student Analytics Screen - Radar Chart
expected: Navigate to the Student Analytics screen. The page should display a radar/spider chart showing skill mastery across different skills (up to 8 skills). Each skill axis should have labeled tick marks. The filled area should be color-coded. The chart should have a title "Kỹ năng của bạn" or similar.
result: skipped
reason: "Chưa có dữ liệu submissions để test (cần có bài nộp và điểm số trong CSDL)."

### 1b. Student Analytics - Dual-Lens Architecture (context: classId filter)
expected: |
  THREE navigation paths lead to the SAME StudentAnalyticsScreen but load DIFFERENT data:
  - Path A (Global Lens): Bottom Nav → Điểm số → Analytics card → classId=null → all submissions across ALL classes
  - Path B (Macro Lens): Lớp học → chọn lớp → ⋮ menu → "Phân tích học tập" → classId=<classId> → filter submissions to that class only
  - Path C (Macro Lens): Lớp học → chọn lớp → Card "Tiến độ học tập" → "Xem chi tiết" → classId=<classId> → same as Path B
result: skipped
reason: "Requires populated database with submissions per class to verify filter works correctly. Code changes applied but not yet verified."
FIX_APPLIED:
  - StudentAnalyticsScreen: added classId optional parameter
  - StudentAnalyticsNotifier: added classId param, passes to datasource
  - AnalyticsDatasource: getBasicMetrics, getSkillMastery, getGradeTrends all accept classId → filter via assignment_distributions.class_id
  - StudentClassDetailScreen: passes classId via extra={'classId': widget.classId}
  - StudentClassSettingsDrawer: added onViewAnalytics callback
  - AppRouter: studentAnalytics route reads classId from state.extra

### 2. Student Analytics Screen - Grade Trend Line Chart
expected: Below or near the radar chart, a line chart should display grade trends over time (week/month/semester). The line should show data points with labels. Y-axis should show scores, X-axis should show time periods. The chart should have a title like "Xu hướng điểm" or similar.
result: pass

### 3. Student Analytics Screen - Metric Cards
expected: The screen should display metric cards showing basic engagement metrics (e.g., total submissions, average score, completion rate). Each card should use DesignColors tokens and show a label, value, and optional trend indicator.
result: pass

### 4. Student Analytics Screen - Strength/Weakness Card
expected: A card should display the student's top strengths (highest-scoring skills) and areas needing improvement (lowest-scoring skills). Labels should be in Vietnamese. The card should use the StrengthWeaknessCard widget.
result: skipped
reason: "Needs student_skill_mastery data (same dependency as Test 1 - Radar chart)."

### 5. Student Analytics Screen - Time Range Selector
expected: A row of filter chips (Week / Month / Semester / All) should be visible above the charts. Tapping a chip should filter the displayed data. The selected chip should be visually highlighted (different color).
result: pass

### 6. Student Analytics Screen - Empty States
expected: When a student has no submissions, the appropriate empty state widget should appear (ZeroSubmissions, PendingGrading, or similar) instead of crashing or showing blank space. The empty state should be friendly and informative in Vietnamese.
result: skipped
reason: "Chưa có dữ liệu submissions để test empty states."

### 7. Teacher Analytics Screen - Grade Distribution Heatmap
expected: |
  Navigate to the Teacher Analytics screen. A bar chart should display grade distribution
  across score ranges (0-4, 4-6, 6-8, 8-10 on a /10 scale). Each bar should be color-coded
  by range (green for 8-10, yellow for 6-8, orange for 4-6, red for 0-4). The chart should
  show student count per range and use assignment titles on the Y-axis. Maximum 5 rows visible,
  scrollable inside a card container.
result: pass

### 8. Teacher Analytics Screen - Class Overview Card
expected: A card should display class-level summary metrics: average score, total students, total submissions, and submission rate. The card should use gradient styling. All values should be numeric with labels in Vietnamese.
result: pass

### 9. Teacher Analytics Screen - Top/Bottom Performers Lists
expected: Two ranked lists should display: one for top performers (highest-scoring students) and one for bottom performers (students needing intervention). Each row should show rank, student name, and score badge. Tapping a student should navigate to their detail. Located on the Teacher Analytics screen, below the class overview card or heatmap.
result: pass

### 10. Student Analytics - Navigation Integration
expected: A student can navigate to the analytics screen from the student dashboard or student class detail. The screen should load and display the student's own analytics data. Back navigation should work correctly.
result: skipped
reason: "Phụ thuộc dual-lens fix (test 1b) - đợi data có submissions."

### 11. Teacher Analytics - Navigation Integration
expected: A teacher can navigate to the analytics screen from the teacher dashboard or class detail. The screen should load and display the selected class's analytics. Back navigation should work correctly.
result: pass

### 12. Analytics Screen - Loading States
expected: When analytics data is being fetched, the screen should show a shimmer loading state (not a spinner or blank screen). Loading should be smooth and use the project's shimmer loading patterns.
result: pass

## Summary

total: 12
passed: 8
issues: 0
pending: 0
skipped: 5

## Gaps

- truth: "Grade distribution heatmap has proper padding from card border, assignment titles show max 2 lines with ellipsis when truncated, column colors match 4-bucket scheme"
  status: passed
  reason: "pass"
  severity: major
  test: 7
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Teacher class overview card shows all metrics in /10 scale (avg, highest, lowest score) plus submission rate"
  status: passed
  reason: "pass"
  severity: major
  test: 8
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Top/bottom performers lists show scores in /10 scale, no student appears in both lists, tapping a student navigates to their detail"
  status: passed
  reason: "pass"
  severity: major
  test: 9
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Teacher analytics data is filtered by classId - students from different classes don't appear in the same analytics screen"
  status: passed
  reason: "pass"
  severity: blocker
  test: 11
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Teacher analytics shows loading shimmer state while fetching data"
  status: passed
  reason: "pass"
  severity: major
  test: 12
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Line chart shows grade trends in /10 scale, with horizontal swipe for overflow"
  status: passed
  reason: "pass"
  severity: major
  test: 2
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Metric cards show average score in /10 scale (e.g., 7.5 not 75%) with trend indicator"
  status: passed
  reason: "User reported: pass"
  severity: major
  test: 3
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Time filter controls metric cards AND charts, accessible via bottom sheet with custom date range"
  status: passed
  reason: "pass"
  severity: major
  test: 5
  artifacts: []
  missing: []
  debug_session: ""

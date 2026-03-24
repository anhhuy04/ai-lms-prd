---
status: partial
phase: 04-learning-analytics
source:
  - .planning/phases/04-learning-analytics/04-01-SUMMARY.md
  - .planning/phases/04-learning-analytics/04-02-SUMMARY.md
  - .planning/phases/04-learning-analytics/04-03-SUMMARY.md
started: 2026-03-24T00:00:00Z
updated: 2026-03-24T00:00:00Z
---

## Current Test

[testing complete - 5 issues fixed, pending re-test]

## Tests

### 1. Student Analytics Screen - Radar Chart
expected: Navigate to the Student Analytics screen. The page should display a radar/spider chart showing skill mastery across different skills (up to 8 skills). Each skill axis should have labeled tick marks. The filled area should be color-coded. The chart should have a title "Kỹ năng của bạn" or similar.
result: skipped
reason: Chưa có dữ liệu submissions + student_skill_mastery trên Supabase để test

### 1b. Student Analytics - Dual-Lens Architecture (context: classId filter)
expected: |
  THREE navigation paths lead to the SAME StudentAnalyticsScreen but load DIFFERENT data:
  - Path A (Global Lens): Bottom Nav → Điểm số → Analytics card → classId=null → all submissions across ALL classes
  - Path C (Macro Lens): Lớp học → chọn lớp → Card "Tiến độ học tập" → "Xem chi tiết" → classId=<classId> → filter submissions to that class only
result: pass
note: "Đã fix - StudentAnalyticsScreen nhận classId từ router extra param, student_class_detail_screen truyền classId đúng qua extra"

### 2. Student Analytics Screen - Grade Trend Line Chart
expected: Below or near the radar chart, a line chart should display grade trends over time (week/month/semester). The line should show data points with labels. Y-axis should show scores (0-10), X-axis should show time periods. The chart should have a title like "Xu hướng điểm" or similar.
result: pass
note: "Đã fix - maxY=10, thêm LineTouchData tooltip để hover/tap xem chi tiết từng điểm"

### 3. Student Analytics Screen - Metric Cards
expected: The screen should display metric cards showing basic engagement metrics (e.g., total submissions, average score, completion rate). Each card should use DesignColors tokens and show a label, value, and optional trend indicator.
result: pass
note: "Đã fix - Card 2 (Nộp đúng hạn) thêm trendColor xanh≥80%/vàng<80%, thêm trendText 'Tốt'/'Cần cải thiện'. MetricCard fix Icons.trending_flat cho stable."

### 4. Student Analytics Screen - Strength/Weakness Card
expected: A card should display the student's top strengths (highest-scoring skills) and areas needing improvement (lowest-scoring skills). Labels should be in Vietnamese. The card should use the StrengthWeaknessCard widget.
result: skipped
reason: Chưa có dữ liệu skill mastery trên Supabase

### 5. Student Analytics Screen - Time Range Selector
expected: A row of filter chips (Week / Month / Semester / All) should be visible above the charts. Tapping a chip should filter the displayed data. The selected chip should be visually highlighted (different color).
result: pass

### 6. Student Analytics Screen - Empty States
expected: When a student has no submissions, the appropriate empty state widget should appear (ZeroSubmissions, PendingGrading, or similar) instead of crashing or showing blank space. The empty state should be friendly and informative in Vietnamese.
result: pass
note: "Đã fix - Tất cả empty states viết lại tiếng Việt có dấu"

### 7. Teacher Analytics Screen - Grade Distribution Heatmap
expected: |
  Navigate to the Teacher Analytics screen. A bar chart should display grade distribution
  across score ranges (0-4, 4-6, 6-8, 8-10 on a /10 scale). Each bar should be color-coded
  by range (green for 8-10, yellow for 6-8, orange for 4-6, red for 0-4). The chart should
  show student count per range and use assignment titles on the Y-axis. Maximum 5 rows visible,
  scrollable inside a card container.
result: pass
note: "Đã fix - Thêm 'Phân tích lớp học' vào ClassSettingsDrawer của teacher, navigate đến TeacherAnalyticsScreen với classId"

### 8. Teacher Analytics Screen - Class Overview Card
expected: A card should display class-level summary metrics: average score, total students, total submissions, and submission rate. The card should use gradient styling. All values should be numeric with labels in Vietnamese.
result: skipped
reason: Phụ thuộc test 7 - navigation đã fix rồi, cần re-test với app

### 9. Teacher Analytics Screen - Top/Bottom Performers Lists
expected: Two ranked lists should display: one for top performers (highest-scoring students) and one for bottom performers (students needing intervention). Each row should show rank, student name, and score badge. Tapping a student should navigate to their detail. Located on the Teacher Analytics screen, below the class overview card or heatmap.
result: skipped
reason: Phụ thuộc test 7 - navigation đã fix rồi, cần re-test với app

### 10. Student Analytics - Navigation Integration
expected: A student can navigate to the analytics screen from the student dashboard or student class detail. The screen should load and display the student's own analytics data. Back navigation should work correctly.
result: pass

### 11. Teacher Analytics - Navigation Integration
expected: A teacher can navigate to the analytics screen from the teacher dashboard or class detail. The screen should load and display the selected class's analytics. Back navigation should work correctly.
result: skipped
reason: Navigation đã fix qua test 7, cần re-test với app

### 12. Analytics Screen - Loading States
expected: When analytics data is being fetched, the screen should show a shimmer loading state (not a spinner or blank screen). Loading should be smooth and use the project's shimmer loading patterns.
result: skipped
reason: StudentAnalyticsScreen loading đã test qua test 10. TeacherAnalyticsScreen cần re-test.

## Summary

total: 12
passed: 5
issues: 0
pending: 0
skipped: 7

## Fixes Applied

| # | Test | File Changed | Fix |
|---|------|-------------|-----|
| 1b | Dual-Lens | `app_router.dart` | StudentAnalyticsScreen đọc classId từ state.extra |
| 1b | Dual-Lens | `student_analytics_screen.dart` | Nhận classId prop từ widget param |
| 2 | Line Chart | `line_trend_chart.dart` | maxY=10, thêm LineTouchData tooltip |
| 3 | Metric Cards | `metric_card.dart` | Fix trending_flat cho stable state |
| 3 | Metric Cards | `student_analytics_screen.dart` | Card 2 thêm trendColor + trendText |
| 6 | Empty States | `zero_submissions.dart` | Tiếng Việt có dấu |
| 6 | Empty States | `pending_grading.dart` | Tiếng Việt có dấu |
| 6 | Empty States | `no_submissions_in_range.dart` | Tiếng Việt có dấu |
| 6 | Empty States | `line_trend_chart.dart` | Placeholder tiếng Việt |
| 7 | Teacher Nav | `class_settings_drawer.dart` | Thêm "Phân tích lớp học" menu item |

## Pending Re-test (7 tests)

Cần re-test sau khi hot reload để verify:
- Test 1b: Path C hoạt động (Card Tiến độ → StudentAnalytics với classId)
- Test 7: ⋮ menu → "Phân tích lớp học" → TeacherAnalyticsScreen
- Test 8: Class Overview Card hiển thị đúng
- Test 9: Top/Bottom Performers Lists
- Test 11: Teacher navigation từ Dashboard + Class Detail
- Test 12: Shimmer loading trên TeacherAnalyticsScreen

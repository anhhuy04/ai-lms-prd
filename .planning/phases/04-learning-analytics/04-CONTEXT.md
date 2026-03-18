# Phase 4: Learning Analytics - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Provide actionable insights on student learning progress. Students can view personal performance analytics, class analytics (for teachers), grade trends over time, and identify strengths/weaknesses.

**Scope:**
- ANL-01: Personal performance analytics (student)
- ANL-02: Class performance analytics (teacher)
- ANL-03: Grade trends over time
- ANL-04: Strengths and weaknesses identification

**Out of Scope:** Recommendations (Phase 5), AI Grading (Phase 6)

</domain>

<decisions>
## Implementation Decisions

### Tab Location
- **Extend Scores Tab** — Mở rộng Scores tab hiện có thành Analytics Dashboard đầy đủ
- Giữ nguyên 5 tabs (Home, Classes, Assignments, Scores/Analytics, Profile)

### Visualization Style
- **Hybrid approach** — Tích hợp cả 3:
  - **Charts**: Line chart cho trends theo thời gian, bar chart cho subject breakdown
  - **Metric Cards**: Hiển thị key metrics (total score, average, completion rate)
  - **Data Tables**: Chi tiết từng assignment với expandable rows

### Time Range Selection
- **Week/Month/Semester** — Preset filters
- **Custom Date Range** — User tự chọn ngày bắt đầu và kết thúc
- Default: All-time

### Strengths/Weaknesses
- **Auto-calculated** — Tự động phân tích và hiển thị subjects/topics mạnh và yếu dựa trên score patterns
- Color coding: xanh cho strengths, đỏ cho weaknesses

### Teacher Analytics
- Tích hợp vào teacher dashboard (có thể qua Assignment Hub hoặc tab mới)
- Aggregate data: class average, distribution, top/bottom performers

</decisions>

<canonical_refs>
## Canonical References

### Requirements
- `.planning/REQUIREMENTS.md` — ANL-01 to ANL-04

### Existing Code
- `lib/presentation/views/dashboard/student_dashboard_screen.dart` — Student dashboard structure
- `lib/presentation/views/dashboard/teacher_dashboard_screen.dart` — Teacher dashboard structure
- `lib/presentation/views/grading/scores_screen.dart` — Current Scores screen to extend
- `lib/widgets/cards/statistics_card.dart` — Reusable statistics card component
- `lib/domain/entities/assignment_statistics.dart` — Statistics entity

### Design System
- `memory-bank/DESIGN_SYSTEM_GUIDE.md` — Design tokens and patterns

</canonical_refs

#code_context
## Existing Code Insights

### Reusable Assets
- `StatisticsCard` widget: Có thể reuse cho analytics metrics
- `AssignmentStatistics` entity: Base cho analytics data
- `ScoresScreen`: Để extend thành Analytics Dashboard

### Established Patterns
- Bottom tab navigation cho dashboard
- Card-based layout cho metrics
- Design tokens đã có sẵn

### Integration Points
- StudentDashboardScreen: Thay ScoresScreen bằng AnalyticsScreen mới
- AssignmentRepository: Cần thêm methods cho analytics queries

</code_context>

<specifics>
## Specific Ideas

- "Tích hợp cả 3 visualization styles một cách thông minh" — không chỉ dùng 1 loại
- Week/Month/Semester presets + custom date range
- Auto-calculate strengths/weaknesses dựa trên score patterns

</specifics>

<deferred>
## Deferred Ideas

- Teacher analytics tab — Có thể extend từ Assignment Hub hoặc tab riêng (Phase 4 tập trung Student Analytics trước)
- Recommendations (Phase 5)
- AI-powered insights (Phase 6)

</deferred>

---

*Phase: 04-learning-analytics*
*Context gathered: 2026-03-18*

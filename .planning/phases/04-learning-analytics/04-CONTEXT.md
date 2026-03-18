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
  - **Charts**: Radar chart cho skill mastery, line chart cho trends, bar chart cho subject comparison
  - **Metric Cards**: Hiển thị key metrics
  - **Data Tables**: Chi tiết từng assignment với expandable rows

### Time Range Selection
- **Week/Month/Semester** — Preset filters
- **Custom Date Range** — User tự chọn ngày bắt đầu và kết thúc
- Default: All-time

### Strengths/Weaknesses
- **Auto-calculated** — Tự động phân tích và hiển thị subjects/topics mạnh và yếu dựa trên score patterns
- Color coding: xanh cho strengths, đỏ cho weaknesses

### Data Sources
- **Hybrid approach**: Realtime queries từ existing tables + cached analytics
- Tables: `submissions`, `work_sessions`, `student_skill_mastery`, `learning_objectives`, `submission_analytics`

### Metrics Display (4 Groups)

**1. Basic & Engagement Metrics:**
- Score trends: Hiệu suất các bài tập gần nhất với xu hướng điểm đi lên/đi xuống
- On-time rate: Tỷ lệ nộp bài đúng hạn (từ `is_late` flag)
- Time spent: Tổng thời gian làm bài (từ `time_spent_seconds`)

**2. Skill Map (Radar Chart) - Core Feature:**
- Lấy từ `student_skill_mastery` + `learning_objectives`
- Radar chart hiển thị mastery_level (0.0 - 1.0) cho từng skill
- Ví dụ: Đại số: 0.9, Hình học: 0.4

**3. Deep Strength/Weakness Analysis:**
- Lấy từ `submission_analytics` (JSONB `metrics` column)
- Accuracy by tag: Tỷ lệ đúng theo từng tag/dạng bài
- Difficulty vs score: Học sinh làm tốt ở câu khó (level 4,5) hay chỉ câu dễ?
- Time per question: Phát hiện các câu mất nhiều thời gian
- Nhận diện lỗi lặp lại / quan niệm sai

**4. Context & Trajectory:**
- Class comparison: So sánh ẩn danh với trung bình lớp (dùng Edge Function hoặc Postgres View để bypass RLS)
- Trajectory predictions: Dự đoán hiệu suất sắp tới (từ `ai_recommendations` hoặc AI queue evaluations)

### Empty States (Contextual)

**1. ZERO SUBMISSIONS:**
- Condition: `submissions` count = 0
- UI: Welcome message + CTA "Take Diagnostic Test to map your skills"

**2. PENDING GRADING:**
- Condition: Latest submission có `ai_graded = false` hoặc `total_score IS NULL`
- UI: Skeleton loader / "AI is analyzing..." animation, ẩn score charts

**3. NO SKILL / PARTIAL ANALYTICS:**
- Condition: Có submissions nhưng `student_skill_mastery` có skill với `attempts = 0`, hoặc `submission_analytics` metrics missing
- UI: Radar/Bar charts hiển thị nhưng gray out các điểm missing
- AI Recommendation Card: "Not enough data for [Skill]. Complete [Suggested Assignment]"

**4. NORMAL STATE:**
- Condition: Tất cả tables có data
- UI: Full Hybrid Dashboard bình thường

### UI/UX Principles (Junior-to-Pro Bridge)
- **Điểm số là phụ**: UI làm nổi bật Strengths trước để tăng tự tin
- **CTAs thông minh**: Thay vì chỉ hiển thị "Yếu Hình học", hiển thị ngay "Gợi ý tài nguyên ôn tập Hình học không gian"
- **Không layout shift**: Empty State components match height của actual Charts
- **Lazy loading**: Load Basic & Radar trước, Deep Analysis lazy load sau

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
- `lib/widgets/cards/statistics_card.dart` — Reusable statistics component
- `lib/domain/entities/assignment_statistics.dart` — Statistics entity
- `lib/data/datasources/submission_datasource.dart` — Submission queries

### Database Tables (for reference)
- `submissions`: `total_score`, `is_late`, `submitted_at`, `ai_graded`
- `work_sessions`: `time_spent_seconds`
- `student_skill_mastery`: `mastery_level`, `attempts`
- `learning_objectives`: Skill definitions
- `submission_analytics`: JSONB `metrics` column
- `ai_recommendations`: AI predictions

### Design System
- `memory-bank/DESIGN_SYSTEM_GUIDE.md` — Design tokens and patterns

</canonical_refs

#code_context
## Existing Code Insights

### Reusable Assets
- `StatisticsCard` widget: Có thể reuse cho analytics metrics
- `AssignmentStatistics` entity: Base cho analytics data
- `ScoresScreen`: Để extend thành Analytics Dashboard
- Submission datasource: Có methods cơ bản, cần thêm analytics queries

### Established Patterns
- Bottom tab navigation cho dashboard
- Card-based layout cho metrics
- Design tokens đã có sẵn
- Skeleton loaders cho loading states

### Integration Points
- StudentDashboardScreen: Thay ScoresScreen bằng AnalyticsScreen mới
- AssignmentRepository: Cần thêm methods cho analytics queries
- Có thể cần Edge Function hoặc Postgres View cho class comparison (RLS bypass)

</code_context>

<specifics>
## Specific Ideas

**Metrics Display:**
- 4 groups: Basic & Engagement, Skill Map (Radar), Deep S/W Analysis, Context & Trajectory
- Radar chart là "trái tim" của hệ thống
- Score trends hiển thị direction (đi lên/đi xuống)
- Difficulty vs score để biết học sinh làm được câu khó không

**Empty States:**
- 4 states: Zero Submissions, Pending Grading, No Skill/Partial, Normal
- Contextual messages thay vì generic "No Data"
- CTA buttons cụ thể: "Take Diagnostic Test", "Complete Assignment"
- Match heights để tránh layout shift

**Junior-to-Pro UX:**
- Điểm số là con số phụ
- Nổi bật Strengths trước
- Hiển thị CTAs cho Weaknesses: "Gợi ý tài nguyên ôn tập [Topic]"

</specifics>

<deferred>
## Deferred Ideas

- Teacher analytics tab — Có thể extend từ Assignment Hub hoặc tab riêng (Phase 4 tập trung Student Analytics trước)
- Recommendations (Phase 5) - liên quan nhưng là phase riêng
- AI-powered insights (Phase 6) - AI Grading phase

</deferred>

---

*Phase: 04-learning-analytics*
*Context gathered: 2026-03-18*

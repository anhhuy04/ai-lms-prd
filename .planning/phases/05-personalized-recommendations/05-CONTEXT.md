# Phase 5: Personalized Recommendations - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Guide students and teachers with intelligent suggestions based on learning analytics data.

**Scope (REC-01 to REC-03):**
- REC-01: Teacher intervention suggestions for struggling students
- REC-02: Student learning resource suggestions (curated links + practice)
- REC-03: Anonymous peer comparison data (no leaderboard)

**Out of Scope:**
- AI-generated personalized study paths (Phase 6)
- Plagiarism detection, parent portal, advanced scheduling

</domain>

<decisions>
## Implementation Decisions

### Screen Location (REC-01: Teacher)

- **Both Dashboard + Tab** — ATC Dashboard (badge/tray "Students Needing Attention") + Dedicated "Gợi ý" tab
- Teacher thấy badge/tray ngay khi vào trang chấm bài + full tab riêng khi cần chi tiết

### Screen Location (REC-02: Student)

- **Both Analytics + Tab** — "Phòng khám + Hộp thuốc đầu giường" model:
  - Analytics Screen: Gợi ý xuất hiện ngay dưới strengths/weaknesses (context-aware, "bác sĩ kê đơn")
  - Tab/Dashboard riêng: Quick-access "Hộp thuốc" — 3 actions khẩn cấp nhất, không cognitive overload
- **Priority ranking**: Tab chỉ hiển thị 3 gợi ý khẩn cấp nhất. Analytics hiển thị đầy đủ.

### Recommendation Engine

- **Hybrid: Rule-based + AI-ready**
  - Phase 5: Rule-based là nền tảng (fast, reliable, zero API cost)
  - Phase 6: AI enhancement khi AI Grading ready
- **Single sink**: Tất cả recommendations (rule-based hoặc AI) INSERT vào bảng `ai_recommendations`
- Dumb UI: Frontend chỉ `SELECT * FROM ai_recommendations WHERE dismissed = false` — không cần biết nguồn tạo

**Workload Distribution:**
- **Rule-based (Quantitative):** Tỷ lệ nộp đúng hạn, total_time_minutes, trend_direction → hàm `AVG()`, `COUNT()` trực tiếp trên DB
- **AI (Qualitative / Pedagogy):** Gom nhóm misconceptions, phân tích rubric, study plan → qua `ai_queue` (Phase 6)

### Trigger & Timing

- **Hybrid: On-event (DB Trigger) + Background Cron**
  - **"Dây chuyền kiểm định" (On-event):** DB Trigger kích hoạt khi submission chuyển trạng thái sang graded. INSERT cảnh báo vào `ai_recommendations` ngay lập tức. Đảm bảo freshness.
  - **"Đội tuần tra đêm" (Background Cron):** Supabase pg_cron chạy định kỳ (2:00 AM). Quét `student_skill_mastery` + `submission_analytics`. Phát hiện patterns dài hạn: "mastery_level giảm dần 3 bài kiểm tra liên tiếp". Tạo macro-level recommendations.

### Resource Types (REC-02: Student)

- **Both Curated Links + Practice Assignments**

**Data Architecture (JSONB `resources` column in `ai_recommendations`):**
```json
{
  "videos": ["https://youtube.com/..."],
  "documents": ["https://docs.google.com/..."],
  "exercises": ["uuid-assignment-1", "uuid-assignment-2"]
}
```

- **Curated links**: Frontend đọc mảng `videos` + `documents`, hiển thị Card có icon YouTube/PDF
- **Practice assignments**: Frontend đọc mảng `exercises` (UUIDs), JOIN với bảng `assignments`, hiển thị nút "Làm bài ôn tập ngay". Nhảy thẳng vào workspace hiện có.
- **Closed-loop**: Practice assignments → work_sessions → skill mastery update → radar chart refresh → new recommendations

### Peer Comparison (REC-03)

- **Both inline + detailed view**

**Lớp 1 — Quick-glance (Gương chiếu hậu):**
- Badge nhỏ: "🔥 Top 15% của lớp" (anonymous)
- Line chart với 2 vệt: nét liền = student's score, nét đứt = class average
- Hiển thị trên Analytics screen, không chiếm nhiều diện tích

**Lớp 2 — Deep Analysis (Bản đồ chi tiết):**
- Dual Radar Chart: Lớp xanh = student's mastery_level, Lớp xám mờ = class average
- Khi tap vào badge → bật Bottom Sheet với Dual Radar Chart
- Skill-by-skill comparison: phát hiện "điểm tổng cao nhưng Lượng giác đang lõm so với mặt bằng"

**CRITICAL — RLS Security:**
- **Tuyệt đối KHÔNG gửi raw scores của students khác về client**
- Dùng **Supabase RPC (SECURITY DEFINER)** để tính percentile và class average ngay trong PostgreSQL
- Frontend chỉ nhận 2 con số vô danh: class_average (VD: 7.5) và percentile (VD: 15%)
- Junior anti-pattern: `SELECT total_score FROM submissions` → vi phạm RLS, expose điểm học sinh khác

### Claude's Discretion

- Badge design và color scheme cụ thể
- Số lượng recommendations hiển thị mặc định (3 cho Tab, full cho Analytics)
- Empty state messages cho từng trường hợp
- Animation/transitions giữa Dashboard badge và Tab screen

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` — REC-01, REC-02, REC-03

### Prior Phase Contexts
- `.planning/phases/04-learning-analytics/04-CONTEXT.md` — Analytics foundation (strengths/weaknesses, skillMasteries, gradeTrends, classComparison entities)
- `.planning/phases/06-ai-grading/06-CONTEXT.md` — ai_recommendations table design, CO-STAR framework for AI prompts
- `.planning/phases/02-teacher-grading-workflow/02-CONTEXT.md` — ATC Dashboard pattern, Teacher grading workflow

### Database Architecture
- `ai_recommendations` table — Single sink cho tất cả recommendations (rule-based + AI)
- `student_skill_mastery` table — master_level (0.0-1.0) dùng cho threshold: < 0.5 → gợi ôn tập
- `submission_analytics` table — JSONB metrics cho trend detection
- `ai_queue` table — Phase 6 AI processing pipeline
- `assignments` table — Nguồn cho practice exercise UUIDs

### Existing Code
- `lib/presentation/providers/analytics_providers.dart` — StudentAnalyticsNotifier, classComparison, strengths/weaknesses (reuse for recommendations)
- `lib/domain/entities/analytics/student_analytics.dart` — StudentAnalytics, ClassComparison entities (reuse)
- `lib/domain/entities/analytics/class_analytics.dart` — ClassAnalytics entity
- `lib/data/datasources/analytics_datasource.dart` — Analytics queries (extend for recommendations)
- `lib/presentation/views/dashboard/student_dashboard_screen.dart` — Student dashboard (extend với recommendations section)
- `lib/presentation/views/dashboard/teacher_dashboard_screen.dart` — Teacher dashboard (extend với intervention badge)

### Design System
- `memory-bank/DESIGN_SYSTEM_GUIDE.md` — Design tokens

### Database
- `.planning/sql-flow-decisions.md` — Submission flow, SSOT patterns, CQRS

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `StudentAnalyticsNotifier`: Đã có sẵn, strengths/weaknesses tự động tính từ skillMasteries
- `ClassComparison`: Đã có percentile, rank, classAverage — dùng trực tiếp cho REC-03
- `StatisticsCard`: Reuse cho recommendation cards
- `ShimmerLoading`: Loading states cho recommendation lists
- Radar chart (fl_chart): Đã dùng trong Phase 4, reuse cho dual radar comparison

### Established Patterns
- Riverpod với @riverpod annotation
- Supabase RPC calls cho server-side computation
- DB Triggers cho event-driven updates
- pg_cron cho background jobs
- Design tokens (DesignColors, DesignSpacing, DesignTypography)
- Shimmer loaders cho loading states

### Integration Points
- **Providers**: Tạo `recommendation_providers.dart` (mới) — kế thừa từ analytics_providers
- **Datasource**: Mở rộng `analytics_datasource.dart` hoặc tạo `recommendation_datasource.dart` (mới)
- **Entities**: Tạo `Recommendation` entity (mới) — đọc từ `ai_recommendations` table
- **Routes**: TeacherRecommendationsScreen + StudentRecommendationsScreen
- **Existing entities reuse**: StudentAnalytics, ClassComparison từ Phase 4

### New Components Needed
- RecommendationCard widget (cho cả teacher + student variants)
- InterventionBadge widget (ATC dashboard badge)
- PeerComparisonBadge widget (Top X% anonymous badge)
- DualRadarChart widget (student vs class average)

</code_context>

<specifics>
## Specific Ideas

**Two-Layer UI Pattern ("Clinic + Pillbox"):**
- Lớp Analytics: "Phòng khám" — bác sĩ (AI) phân tích sâu, kê đơn ngay tại chỗ
- Lớp Tab: "Hộp thuốc" — 3 actions khẩn cấp nhất, cognitive overload prevention

**Rule-based Thresholds:**
- `mastery_level < 0.5` → trigger learning resource recommendation
- Score giảm 2 bài liên tiếp → trigger intervention suggestion
- `on_time_rate` giảm → trigger deadline habit recommendation

**No Leaderboard Policy:**
- TUYỆT ĐỐI không làm bảng xếp hạng công khai tên
- Chỉ anonymous percentile, class average, trend direction
- RPC SECURITY DEFINER bắt buộc cho peer comparison

**Closed Learning Loop:**
- Practice assignment → submit → AI/teacher grade → skill mastery update → radar refresh → new recommendations

</specifics>

<deferred>
## Deferred Ideas

### Reviewed Todos (not folded)
- None — no pending todos matched Phase 5 scope

### Ideas mentioned during discussion
- AI-generated personalized study paths — deferred to Phase 6 (quá đắt, dễ hallucination, cần Phase 6 complete)
- Misconception grouping (qualitative) — deferred to Phase 6 AI (yêu cầu AI phân tích sâu)
- Push notifications cho new recommendations — future enhancement
- Real-time recommendation status updates — future enhancement

</deferred>

---

*Phase: 05-personalized-recommendations*
*Context gathered: 2026-03-25*

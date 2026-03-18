# Phase 4: Learning Analytics - Research

**Researched:** 2026-03-18
**Domain:** Data visualization, analytics dashboards, Flutter charts
**Confidence:** HIGH

## Summary

Phase 4 focuses on implementing a Learning Analytics dashboard that extends the existing Scores Tab into a full Analytics Dashboard. Key findings:

1. **fl_chart** (v1.2.0) is the recommended library for all chart types including Radar charts - it supports Line, Bar, Pie, Scatter, and Radar charts natively
2. The existing database schema has core tables defined but analytics tables (`student_skill_mastery`, `submission_analytics`, `ai_recommendations`) need verification/creation
3. Hybrid visualization approach (Radar + Line + Bar + Cards + Tables) is the standard pattern for analytics dashboards
4. Empty state UX is critical - 4 distinct states must be handled with matching heights to prevent layout shift
5. Lazy loading with priority ordering (Basic Metrics/Radar first, Deep Analysis later) is essential for performance

**Primary recommendation:** Use fl_chart v1.2.0+ for all visualizations. Extend ScoresScreen to AnalyticsDashboard using existing StatisticsCard patterns. Implement 4-group metrics display with proper empty state handling.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Extend Scores Tab → Analytics Dashboard
- Hybrid visualizations: Radar (Skill Map) + Line + Bar + Cards + Tables
- 4 metric groups: Basic & Engagement, Skill Map, Deep S/W Analysis, Context & Trajectory
- 4 empty states: Zero Submissions, Pending Grading, No Skill/Partial, Normal
- UI/UX: Điểm số là phụ, nổi bật Strengths trước, CTAs cho Weaknesses

### Claude's Discretion
- Chart library selection (recommend fl_chart)
- Exact implementation of deep analysis metrics
- Teacher analytics integration point

### Deferred Ideas (OUT OF SCOPE)
- Teacher analytics tab — Focus on Student Analytics first (Phase 4)
- Recommendations (Phase 5)
- AI-powered insights (Phase 6)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ANL-01 | Personal performance analytics (student) | fl_chart supports line charts for trends, cards for metrics |
| ANL-02 | Class performance analytics (teacher) | Requires edge function/view for RLS-bypassed class comparison |
| ANL-03 | Grade trends over time | fl_chart line charts with time-based x-axis |
| ANL-04 | Strengths and weaknesses identification | Radar chart + deep analysis from submission_analytics |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `fl_chart` | 1.2.0+ | Charts (Radar, Line, Bar, Pie) | Only Flutter library with native Radar support, active maintenance |
| `riverpod` | 2.5.1 | State management | Project mandatory |
| `shimmer` | 3.0.0 | Loading states | Project mandatory |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `fl_chart` | 1.2.0+ | RadarChart | Skill mastery visualization |
| `fl_chart` | 1.2.0+ | LineChart | Grade trends over time |
| `fl_chart` | 1.2.0+ | BarChart | Subject comparison, difficulty analysis |
| `fl_chart` | 1.2.0+ | PieChart | Engagement distribution |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `fl_chart` | `charts_flutter` (Google) | fl_chart has better mobile support, active development, native Radar chart |
| `fl_chart` | `syncfusion_fusion_charts` | Commercial license, overkill for this use case |
| `fl_chart` | `bee_chart` | Less mature, fewer chart types |

**Installation:**
```bash
flutter pub add fl_chart
```

**Version verification:**
- fl_chart: 1.2.0 (published 2026-03-14 per pub.dev)

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── presentation/
│   ├── views/
│   │   └── analytics/                    # NEW: Analytics screens
│   │       ├── student_analytics_screen.dart
│   │       ├── teacher_analytics_screen.dart
│   │       └── widgets/
│   │           ├── charts/
│   │           │   ├── radar_skill_chart.dart
│   │           │   ├── line_trend_chart.dart
│   │           │   └── bar_comparison_chart.dart
│   │           ├── cards/
│   │           │   ├── metric_card.dart
│   │           │   └── strength_weakness_card.dart
│   │           └── empty_states/
│   │               ├── zero_submissions.dart
│   │               ├── pending_grading.dart
│   │               └── partial_analytics.dart
│   └── providers/
│       └── analytics_providers.dart      # NEW: Analytics data providers
├── domain/
│   └── entities/
│       └── analytics/                    # NEW: Analytics entities
│           ├── student_analytics.dart
│           ├── skill_mastery.dart
│           └── grade_trend.dart
└── data/
    └── datasources/
        └── analytics_datasource.dart     # NEW: Analytics queries
```

### Pattern 1: Hybrid Analytics Dashboard
**What:** Combine charts, metric cards, and data tables in a unified view
**When to use:** When displaying complex analytics with multiple data dimensions
**Example:**
```dart
// Source: fl_chart documentation + design best practices
class StudentAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Basic & Engagement Metrics (Cards)
          _buildMetricCards(),

          // 2. Skill Map (Radar Chart) - Core Feature
          _buildRadarChart(),

          // 3. Deep Analysis (Bars/Tables)
          _buildDeepAnalysis(),

          // 4. Context & Trajectory
          _buildTrajectorySection(),
        ],
      ),
    );
  }
}
```

### Pattern 2: Contextual Empty States
**What:** Show different empty states based on data availability with matching heights
**When to use:** Analytics screens with varying data completeness
**Example:**
```dart
// Match chart height to prevent layout shift
Widget _buildRadarChartSection(AnalyticsState state) {
  if (state.submissionCount == 0) {
    return SizedBox(
      height: 300.h, // Match actual chart height
      child: ZeroSubmissionsEmptyState(),
    );
  }
  if (state.hasPendingGrading) {
    return SizedBox(
      height: 300.h,
      child: PendingGradingEmptyState(),
    );
  }
  return RadarSkillChart(data: state.skillData);
}
```

### Pattern 3: Lazy Loading with Priority
**What:** Load basic metrics first, deep analysis later
**When to use:** Heavy analytics dashboards
**Example:**
```dart
// Basic & Radar load immediately
final basicMetrics = await Future.wait([
  ref.read(submissionRepoProvider).getBasicMetrics(),
  ref.read(skillRepoProvider).getSkillMastery(),
]);

// Deep analysis lazy loads
ref.read(deepAnalysisProvider); // Separate provider, loads in background
```

### Anti-Patterns to Avoid
- **Layout shift:** Empty states MUST match actual chart heights
- **Blocking load:** Never show blank screen while loading - use shimmer placeholders
- **Score-first UI:** Always highlight Strengths before weaknesses per UX requirements

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Radar charts | Custom canvas drawing | `fl_chart RadarChart` | Native support, touch interactions, animations |
| Line trends | Custom path painting | `fl_chart LineChart` | Built-in touch handling, tooltips, animations |
| Bar comparisons | Custom bar widgets | `fl_chart BarChart` | Grouped/stacked bars, animations |
| Loading shimmer | Generic spinners | `shimmer` package | Project standard for all loading states |

**Key insight:** Analytics visualization requires complex touch handling, animations, and responsive sizing. Custom implementations quickly become buggy and hard to maintain.

## Common Pitfalls

### Pitfall 1: Radar Chart Overflow on Mobile
**What goes wrong:** Radar chart becomes too small or overflows on narrow screens
**Why it happens:** Default chart size too large for mobile viewports
**How to avoid:** Use `flutter_screenutil` for responsive sizing:
```dart
RadarChart(
  radarSize: 200.r, // Responsive
  radarBorderData: BorderSide(color: DesignColors.border),
  getTitle: (index, angle) {
    return RadarChartTitle(text: skills[index], angle: 0);
  },
)
```
**Warning signs:** Charts clipped, horizontal scroll needed, text too small

### Pitfall 2: Layout Shift on Empty States
**What goes wrong:** Screen jumps when transitioning from empty state to data
**Why it happens:** Empty state containers have different heights than actual charts
**How to avoid:** Use fixed-height containers matching chart dimensions
**Warning signs:** Screen height changes after data loads, jarring scroll position

### Pitfall 3: N+1 Queries for Analytics
**What goes wrong:** Each skill/topic triggers separate database query
**Why it happens:** Fetching analytics data without proper batch queries
**How to avoid:** Use single query with JOINs or create analytics view:
```sql
-- Single query for all skill masteries
SELECT
  lo.name as skill_name,
  ssm.mastery_level,
  ssm.attempts
FROM student_skill_mastery ssm
JOIN learning_objectives lo ON lo.id = ssm.objective_id
WHERE ssm.student_id = auth.uid();
```
**Warning signs:** Multiple network calls in timeline, slow dashboard load

### Pitfall 4: Missing RLS for Class Comparison
**What goes wrong:** Cannot compare student to class average due to RLS blocking cross-student data
**Why it happens:** Student can only see their own submissions
**How to avoid:** Create Postgres View or Edge Function:
```sql
-- View for class statistics (bypasses RLS on aggregation)
CREATE VIEW class_average_stats AS
SELECT
  ad.class_id,
  AVG(s.total_score) as avg_score,
  COUNT(s.id) as submission_count
FROM submissions s
JOIN assignment_distributions ad ON ad.id = s.assignment_distribution_id
GROUP BY ad.class_id;
```
**Warning signs:** Class comparison shows no data, "permission denied" errors

## Code Examples

### Radar Chart (Skill Mastery)
```dart
// Source: fl_chart documentation
RadarChart(
  RadarChartData(
    radarSpots: skillData.map((skill) =>
      RadarSpot(skill.masteryLevel * 10, skill.masteryLevel)
    ).toList(),
    radarBorderData: BorderSide(color: DesignColors.primary),
    gridBorderData: BorderSide(color: DesignColors.border),
    titleTextStyle: DesignTypography.caption,
    tickCount: 5,
    ticks: [0, 0.25, 0.5, 0.75, 1.0].map((v) =>
      RadarTick(v * 10, '', showTick: false)
    ).toList(),
    titlePositions: skillData.asMap().entries.map((e) =>
      RadarTitlePosition(angle: _getAngle(e.key, skillData.length), text: e.value.skillName)
    ).toList(),
  ),
)
```

### Line Chart (Grade Trends)
```dart
// Source: fl_chart documentation
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: trendData.map((d) =>
          FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.score)
        ).toList(),
        isCurved: true,
        color: DesignColors.primary,
        barWidth: 3,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: DesignColors.primary.withOpacity(0.1),
        ),
      ),
    ],
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) =>
            Text('${value.toInt()}', style: DesignTypography.caption),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) =>
            Text(_formatDate(value), style: DesignTypography.caption),
        ),
      ),
    ),
  ),
)
```

### Metric Card Pattern (Reuse existing)
```dart
// Source: lib/widgets/cards/statistics_card.dart (existing pattern)
StatisticsCard(
  label: 'On-time Rate',
  value: onTimeRate,
  backgroundColor: DesignColors.successLight,
  textColor: DesignColors.successDark,
  borderColor: DesignColors.success,
)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Google Charts | fl_chart | 2020s | Native Flutter rendering, better performance |
| Static charts | Interactive + animations | fl_chart 0.65+ | Touch tooltips, smooth transitions |
| Score-first UI | Strengths-first UX | This phase | Better student motivation, per UX research |

**Deprecated/outdated:**
- `charts_flutter` (Google): No longer actively maintained for Flutter 3.x
- Hard-coded chart sizes: Use responsive sizing with flutter_screenutil

## Open Questions

1. **Analytics tables existence**
   - What we know: Schema document mentions `student_skill_mastery`, `submission_analytics`, `ai_recommendations`
   - What's unclear: Whether these tables actually exist in Supabase
   - Recommendation: Use Supabase MCP to verify table existence before planning queries

2. **Class comparison RLS approach**
   - What we know: Need to bypass RLS for anonymous class averages
   - What's unclear: Edge Function vs Postgres View tradeoffs
   - Recommendation: Use Postgres View for simplicity - no function code to maintain

3. **Pending Grading detection**
   - What we know: Need to check `ai_graded` flag or `total_score IS NULL`
   - What's unclear: Exact query pattern for recent pending submissions
   - Recommendation: Query submissions ordered by submitted_at DESC, check first record

## Validation Architecture

> Section included as workflow.nyquist_validation is not explicitly set to false in .planning/config.json

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | None — existing test infrastructure |
| Quick run command | `flutter test` |
| Full suite command | `flutter test --reporter expanded` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ANL-01 | Personal performance analytics display | Widget | `flutter test test/analytics/` | ❌ Need to create |
| ANL-02 | Class performance analytics display | Widget | `flutter test test/analytics/` | ❌ Need to create |
| ANL-03 | Grade trends chart renders | Widget | `flutter test test/analytics/` | ❌ Need to create |
| ANL-04 | Strengths/weaknesses calculated | Unit | `flutter test test/analytics/` | ❌ Need to create |

### Sampling Rate
- **Per task commit:** `flutter test test/analytics/ --name="<test_name>" -x`
- **Per wave merge:** Full suite via `flutter test`
- **Phase gate:** All analytics tests green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/analytics/student_analytics_test.dart` — covers ANL-01
- [ ] `test/analytics/teacher_analytics_test.dart` — covers ANL-02
- [ ] `test/analytics/strengths_weakness_test.dart` — covers ANL-04
- [ ] `test/analytics/chart_rendering_test.dart` — covers ANL-03
- None — existing test infrastructure applies, need to create analytics-specific tests

## Sources

### Primary (HIGH confidence)
- [fl_chart pub.dev](https://pub.dev/packages/fl_chart) - Latest version, chart types supported
- [fl_chart GitHub](https://github.com/imaNNeo/fl_chart) - Examples, API documentation
- `lib/widgets/cards/statistics_card.dart` - Existing project pattern
- `lib/domain/entities/assignment_statistics.dart` - Existing analytics entity pattern

### Secondary (MEDIUM confidence)
- [fl_chart RadarChart examples](https://github.com/imaNNeo/fl_chart/tree/master/example/lib/screens/scatter_chart) - Chart configuration patterns
- `docs/guides/development/database-schema-summary.md` - Database schema reference

### Tertiary (LOW confidence)
- Web search: "flutter analytics dashboard best practices" - General patterns, needs verification against project standards

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - fl_chart verified via pub.dev, versions confirmed
- Architecture: HIGH - Follows existing project patterns (StatisticsCard, Riverpod providers)
- Pitfalls: MEDIUM - Patterns identified from mobile chart implementations, some assumptions about table existence

**Research date:** 2026-03-18
**Valid until:** 2026-04-18 (30 days - stable domain)

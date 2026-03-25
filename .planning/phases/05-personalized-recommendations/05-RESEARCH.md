# Phase 5: Personalized Recommendations - Research

**Researched:** 2026-03-25
**Domain:** Recommendation engine, Supabase DB triggers/cron, Flutter UI patterns, peer comparison security
**Confidence:** MEDIUM-HIGH

## Summary

Phase 5 builds an intelligent recommendation layer on top of the existing Learning Analytics foundation (Phase 4). The core architecture is a **hybrid rule-based engine** with `ai_recommendations` as the single sink, triggered by **DB triggers (on-event)** and **pg_cron (2AM nightly)**. The "Dumb UI" pattern means frontend only `SELECT`s from `ai_recommendations` and renders -- no recommendation logic in Flutter code. The dual-layer UI ("Clinic + Pillbox") places full recommendations on Analytics screens and top-3 urgent actions on dedicated Tab/Dashboard widgets.

Key findings:
1. The `ai_recommendations` table schema already exists in `db/schema_03_submissions_ai_analytics.sql` with JSONB `resources` column and `priority` (1-5) field.
2. The `student_skill_mastery` table exists with `mastery_level` (0.0-1.0) and `attempts` columns -- the threshold `mastery_level < 0.5` is already queryable.
3. **Peer comparison MUST use Supabase RPC (SECURITY DEFINER)** -- the existing `getClassComparison` in `analytics_datasource.dart` fetches raw scores, which violates the "no raw scores to client" constraint. This needs an RPC rewrite.
4. DB Triggers for on-event recommendations and pg_cron for nightly patrol are Supabase PostgreSQL features that require migration files.
5. All existing Flutter code patterns (Riverpod, Freezed, fl_chart, design tokens) are fully applicable.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **Hybrid engine**: Rule-based (Phase 5) + AI-ready (Phase 6), single sink = `ai_recommendations` table
- **Dumb UI**: Frontend only `SELECT * FROM ai_recommendations WHERE dismissed = false` -- no source awareness
- **Trigger**: DB Trigger (on-event on submission graded) + pg_cron (2:00 AM night patrol)
- **Resource types**: Curated links (videos, documents) + Practice assignments (exercise UUIDs in JSONB)
- **Peer comparison**: Supabase RPC (SECURITY DEFINER) only -- NO raw scores to client
- **Teacher REC-01**: Both Dashboard badge ("Students Needing Attention") + Dedicated "Goi y" tab
- **Student REC-02**: Both Analytics screen (full "Clinic") + Tab (top-3 "Pillbox")
- **REC-03 Peer Comparison**: Anonymous percentile badge + inline chart (student vs class avg line) + tap for Dual Radar Chart bottom sheet
- **Rule thresholds**: `mastery_level < 0.5` triggers resource recommendation; score declining 2 consecutive triggers intervention

### Claude's Discretion (Research & Recommend)
- Badge design and color scheme
- Number of recommendations displayed by default (3 for Tab, full for Analytics)
- Empty state messages per case
- Animation/transitions between Dashboard badge and Tab screen

### Deferred Ideas (OUT OF SCOPE)
- AI-generated personalized study paths (Phase 6)
- Misconception grouping / qualitative analysis (Phase 6 AI)
- Push notifications for new recommendations
- Real-time recommendation status updates
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| REC-01 | User can receive intervention suggestions (teacher) | DB Trigger on submission graded + pg_cron nightly scan for declining patterns. Teacher `SELECT` from `ai_recommendations` with type='individual'. Dashboard badge + dedicated tab. |
| REC-02 | User can receive learning resource suggestions (student) | `mastery_level < 0.5` threshold from `student_skill_mastery`. JSONB resources column supports videos/documents/exercises UUIDs. Analytics screen full list + Tab top-3. |
| REC-03 | User can view peer comparison data | Supabase RPC (SECURITY DEFINER) computes class_average and percentile server-side. Frontend receives only anonymous values. Dual Radar Chart via fl_chart. Anonymous badge "Top X%". |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `riverpod` + `riverpod_annotation` | ^2.5.1 | State management | Already in use across all phases |
| `@riverpod` generator | ^2.3.0 | Code generation for providers | Already in use |
| `freezed_annotation` + `json_annotation` | latest | Immutable models | Already in use for all entities |
| `fl_chart` | ^0.69.0 | Radar chart, line chart | Already used in Phase 4 analytics |
| `flutter_secure_storage` | ^9.0.0 | Secure token storage | Already in use |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `shimmer` | ^3.0.0 | Loading states | Recommendation list loading |
| `supabase_flutter` | ^2.5.0 | Database client | Already in use |
| `sentry_flutter` | ^8.0.0 | Error reporting | Critical recommendation flows |

### Supabase Backend Components
| Component | Purpose | Notes |
|----------|---------|-------|
| `ai_recommendations` table | Single sink for all recommendations | Schema: id, teacher_id, class_id, student_id, type, priority (1-5), title, description, resources (JSONB), dismissed, created_at |
| `student_skill_mastery` table | Source for rule-based thresholds | Fields: student_id, objective_id, mastery_level (0.0-1.0), attempts |
| `submission_analytics` table | Metrics for trend detection | JSONB `metrics` column |
| DB Trigger | On-event recommendation generation | Fires on submission graded |
| pg_cron | Nightly patrol (2AM) | Scans for long-term declining patterns |
| RPC `security definer` | Peer comparison computation | Computes percentile/class_average server-side |

**Installation:** No new pub packages required. All needed packages are already in `pubspec.yaml`.

---

## Architecture Patterns

### Recommended Project Structure

```
lib/
  domain/
    entities/
      recommendation.dart              # Freezed entity: Recommendation
  data/
    datasources/
      recommendation_datasource.dart   # SELECT from ai_recommendations + RPC calls
    repositories/
      recommendation_repository.dart    # Interface + Implementation
  presentation/
    providers/
      recommendation_providers.dart    # Riverpod providers/notifiers
    views/
      recommendation/
        teacher/
          teacher_recommendations_screen.dart
          teacher_recommendations_tab.dart
          widgets/
            intervention_badge.dart
            intervention_card.dart
        student/
          student_recommendations_tab.dart  # "Pillbox" - top 3
          widgets/
            recommendation_card.dart
            peer_comparison_badge.dart
            peer_comparison_chart.dart
            dual_radar_chart.dart
```

### Pattern 1: Dumb UI -- Single Sink SELECT

**What:** Frontend issues a single `SELECT` from `ai_recommendations` and renders results without knowing the source (rule-based or AI).

**Why:** Decouples generation logic from rendering. Phase 6 AI enhancement changes only the INSERT side.

**Implementation:**
```dart
// RecommendationDatasource
Future<List<Recommendation>> getRecommendations({
  String? userId,
  bool forTeacher = false,
  int? limit,
}) async {
  var q = _client
      .from('ai_recommendations')
      .select()
      .eq('dismissed', false);

  if (forTeacher) {
    q = q.eq('teacher_id', userId);
  } else {
    q = q.eq('student_id', userId);
  }

  if (limit != null) {
    q = q.limit(limit);
  }

  q = q.order('priority', ascending: true)
       .order('created_at', ascending: false);

  final result = await q;
  return result.map((row) => Recommendation.fromJson(row)).toList();
}
```

### Pattern 2: DB Trigger (On-Event Recommendation)

**What:** PostgreSQL trigger fires when a submission transitions to `graded` status, immediately INSERTing a recommendation.

**Why:** Guarantees freshness -- student/teacher sees recommendation the moment grading completes.

**Migration approach:**
```sql
-- Trigger function
CREATE OR REPLACE FUNCTION fn_recommend_on_graded_submission()
RETURNS TRIGGER AS $$
DECLARE
  v_student_id UUID;
  v_class_id UUID;
  v_teacher_id UUID;
  v_mastery_level NUMERIC;
BEGIN
  -- Only fire when transitioning TO graded (total_score is set)
  IF NEW.total_score IS NOT NULL AND TG_OP = 'UPDATE' THEN
    SELECT student_id INTO v_student_id FROM submissions WHERE id = NEW.id;

    -- Get class and teacher via assignment_distributions
    SELECT ad.class_id, ad.assignments
      INTO v_class_id, v_assignment_id
      FROM assignment_distributions ad
      WHERE ad.id = NEW.assignment_distribution_id;

    -- Check mastery_level for this student's weak skills
    SELECT ssm.mastery_level INTO v_mastery_level
    FROM student_skill_mastery ssm
    JOIN submission_answers sa ON sa.objective_id = ssm.objective_id
    WHERE sa.submission_id = NEW.id
    ORDER BY ssm.mastery_level ASC
    LIMIT 1;

    -- Rule: mastery_level < 0.5 → trigger resource recommendation
    IF v_mastery_level < 0.5 THEN
      INSERT INTO ai_recommendations (
        teacher_id, class_id, student_id, type, priority,
        title, description, resources, created_at
      ) VALUES (
        v_teacher_id, v_class_id, v_student_id, 'individual', 2,
        'Học sinh cần ôn tập kỹ năng',
        'Mức thành thạo thấp được phát hiện sau bài kiểm tra gần nhất.',
        '{"exercises": [], "videos": [], "documents": []}',
        now()
      );
    END IF;

    -- Rule: score declining 2+ consecutive → intervention suggestion
    -- (implemented in pg_cron for multi-submission pattern detection)
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recommend_on_graded
AFTER UPDATE OF total_score ON submissions
FOR EACH ROW
EXECUTE FUNCTION fn_recommend_on_graded_submission();
```

### Pattern 3: pg_cron Nightly Patrol

**What:** Supabase pg_cron runs at 2:00 AM daily, scanning `student_skill_mastery` for long-term declining patterns.

**Why:** Catches patterns that span multiple submissions (e.g., mastery declining for 3 consecutive assignments).

```sql
-- pg_cron scheduled function
CREATE OR REPLACE FUNCTION fn_cron_nightly_recommendation_scan()
RETURNS void AS $$
DECLARE
  v_rec RECORD;
BEGIN
  -- Scan for students with declining mastery (3 consecutive decreases)
  FOR v_rec IN
    WITH ranked AS (
      SELECT
        ssm.student_id,
        ssm.objective_id,
        lo.description AS skill_name,
        ssm.mastery_level,
        ROW_NUMBER() OVER (
          PARTITION BY ssm.student_id, ssm.objective_id
          ORDER BY ssm.last_updated DESC
        ) AS rn
      FROM student_skill_mastery ssm
      JOIN learning_objectives lo ON lo.id = ssm.objective_id
      WHERE ssm.last_updated > now() - interval '30 days'
    ),
    declining AS (
      SELECT
        r1.student_id,
        r1.objective_id,
        r1.skill_name,
        r1.mastery_level AS current_level,
        r2.mastery_level AS prev_level,
        r3.mastery_level AS prev_prev_level
      FROM ranked r1
      JOIN ranked r2 ON r1.student_id = r2.student_id
        AND r1.objective_id = r2.objective_id AND r2.rn = 2
      JOIN ranked r3 ON r1.student_id = r3.student_id
        AND r1.objective_id = r3.objective_id AND r3.rn = 3
      WHERE r1.rn = 1
        AND r1.mastery_level < r2.mastery_level
        AND r2.mastery_level < r3.mastery_level
        AND r3.mastery_level < 0.7
    )
    INSERT INTO ai_recommendations (
      teacher_id, class_id, student_id, type, priority,
      title, description, resources
    )
    SELECT
      c.teacher_id,
      cm.class_id,
      d.student_id,
      'individual',
      CASE
        WHEN d.current_level < 0.3 THEN 1  -- Critical
        WHEN d.current_level < 0.5 THEN 2  -- High
        ELSE 3
      END,
      'Xu hướng sa sut: ' || d.skill_name,
      'Muc do thanh thao giam dan trong 3 bai kiem tra gan nhat.',
      '{"exercises": [], "videos": [], "documents": []}'
    FROM declining d
    JOIN class_members cm ON cm.student_id = d.student_id AND cm.status = 'approved'
    JOIN classes c ON c.id = cm.class_id
    ON CONFLICT DO NOTHING;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule: run at 2 AM daily
SELECT cron.schedule(
  'nightly-recommendation-scan',
  '0 2 * * *',
  'SELECT fn_cron_nightly_recommendation_scan()'
);
```

### Pattern 4: RPC SECURITY DEFINER for Peer Comparison

**What:** All peer comparison math happens server-side via Supabase RPC. Client receives only anonymous aggregates (percentile, class_average).

**Why:** The existing `getClassComparison` in `analytics_datasource.dart` fetches raw submission scores to the client, which violates REC-03 security constraints. This must be replaced with an RPC.

```sql
-- RPC: compute peer comparison for a student in a class
CREATE OR REPLACE FUNCTION get_student_peer_comparison(
  p_student_id UUID,
  p_class_id UUID
) RETURNS JSONB
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
  v_student_avg NUMERIC;
  v_class_avg NUMERIC;
  v_percentile NUMERIC;
  v_rank INTEGER;
  v_total INTEGER;
BEGIN
  -- Get this student's average score (only their submissions for this class)
  SELECT COALESCE(AVG(s.total_score), 0)
  INTO v_student_avg
  FROM submissions s
  JOIN assignment_distributions ad ON ad.id = s.assignment_distribution_id
  WHERE s.student_id = p_student_id
    AND ad.class_id = p_class_id
    AND s.total_score IS NOT NULL;

  -- Compute class-wide averages per student, then derive class average + percentile
  WITH student_avgs AS (
    SELECT
      s.student_id,
      AVG(s.total_score) AS avg_score
    FROM submissions s
    JOIN assignment_distributions ad ON ad.id = s.assignment_distribution_id
    JOIN class_members cm ON cm.student_id = s.student_id AND cm.class_id = p_class_id
    WHERE ad.class_id = p_class_id
      AND s.total_score IS NOT NULL
    GROUP BY s.student_id
  ),
  ranked AS (
    SELECT
      avg_score,
      ROW_NUMBER() OVER (ORDER BY avg_score DESC) AS rn,
      COUNT(*) OVER () AS total
    FROM student_avgs
  )
  SELECT
    (SELECT AVG(avg_score) FROM student_avgs),
    (SELECT ROUND(
      COUNT(*) FILTER (WHERE avg_score < v_student_avg) * 100.0 / NULLIF(MAX(r.total), 0), 1
    ) FROM ranked r),
    (SELECT COALESCE(MIN(rn), 1) FROM ranked r WHERE r.avg_score <= v_student_avg),
    (SELECT MAX(total) FROM ranked)
  INTO v_class_avg, v_percentile, v_rank, v_total
  FROM ranked LIMIT 1;

  RETURN jsonb_build_object(
    'class_average', ROUND(v_class_avg::numeric, 2),
    'percentile', ROUND(v_percentile::numeric, 1),
    'rank', v_rank,
    'total_students', v_total
  );
END;
$$ LANGUAGE plpgsql;
```

### Pattern 5: Dual Radar Chart (Peer Comparison)

**What:** Overlapping radar charts showing student's mastery vs class average for skill-by-skill comparison.

**Why:** Enables "skill-by-skill" detection -- e.g., student has high total score but weak in Trigonometry.

**Implementation (extends existing `RadarSkillChart`):**
```dart
// DualRadarChart widget - student vs class average
class DualRadarChart extends StatelessWidget {
  final List<SkillMastery> studentSkills;      // Green overlay
  final List<double> classAverageSkills;       // Gray overlay
  final double height;

  const DualRadarChart({
    super.key,
    required this.studentSkills,
    required this.classAverageSkills,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final displaySkills = studentSkills.take(8).toList();

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            // Student (foreground - teal)
            RadarDataSet(
              fillColor: DesignColors.primary.withValues(alpha: 0.25),
              borderColor: DesignColors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: displaySkills.map((s) =>
                RadarEntry(value: s.masteryLevel * 100)
              ).toList(),
            ),
            // Class average (background - gray)
            RadarDataSet(
              fillColor: Colors.grey.withValues(alpha: 0.1),
              borderColor: Colors.grey.shade400,
              borderWidth: 1,
              borderDash: [5, 5],
              entryRadius: 2,
              dataEntries: classAverageSkills.isNotEmpty
                ? displaySkills.asMap().entries.map((e) =>
                    RadarEntry(
                      value: (classAverageSkills[e.key] * 100)
                        .clamp(0.0, 100.0)
                    )
                  ).toList()
                : displaySkills.map((_) =>
                    const RadarEntry(value: 0)
                  ).toList(),
            ),
          ],
          // ... standard chart config
        ),
      ),
    );
  }
}
```

### Pattern 6: Two-Layer UI ("Clinic + Pillbox")

**Student REC-02 Layer 1 -- Analytics Screen ("Phong kham"):**
```dart
// Inside StudentAnalyticsScreen, after strength/weakness section:
class _RecommendationClinicSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(studentRecommendationsProvider);

    return recsAsync.when(
      data: (recs) => recs.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Goi y hoc tap', style: DesignTypography.titleMedium),
              SizedBox(height: DesignSpacing.md),
              ...recs.map((r) => RecommendationCard(
                recommendation: r,
                onDismiss: () => ref.read(
                  studentRecommendationsProvider.notifier
                ).dismiss(r.id),
                onAction: (resource) => _navigateToResource(context, resource),
              )),
            ],
          ),
      loading: () => ShimmerCardLoading(), // Custom shimmer for cards
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

**Student REC-02 Layer 2 -- Tab ("Hop thuoc dau giuong"):**
```dart
// StudentRecommendationsTab - Top 3 urgent
class StudentRecommendationsTab extends ConsumerWidget {
  const StudentRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LIMIT 3 -- only the 3 most urgent
    final recsAsync = ref.watch(top3RecommendationsProvider);

    return recsAsync.when(
      data: (recs) => recs.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: EdgeInsets.all(DesignSpacing.lg),
            itemCount: recs.length,
            itemBuilder: (context, index) => RecommendationCard(
              recommendation: recs[index],
              compact: true, // Smaller variant for pillbox
            ),
          ),
      loading: () => ShimmerListTileLoading(),
      error: (_, __) => _buildErrorState(),
    );
  }
}
```

**Teacher REC-01 Layer 1 -- ATC Dashboard Badge:**
```dart
// InterventionBadge widget - appears on TeacherGradingHub
class InterventionBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(interventionCountProvider);

    return countAsync.when(
      data: (count) => count == 0
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () => context.goNamed(AppRoute.teacherRecommendationsTab),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DesignColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(color: DesignColors.error),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber, color: DesignColors.error, size: 16),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    '$count hoc sinh can chu y',
                    style: DesignTypography.labelMedium.copyWith(
                      color: DesignColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

### Anti-Patterns to Avoid

- **Fetching raw scores for peer comparison in Flutter**: `SELECT total_score FROM submissions` in client code exposes individual student scores. MUST use RPC `security definer`.
- **Implementing recommendation logic in Flutter providers**: Rule-based logic belongs in DB triggers and cron jobs, not Dart code. Frontend is "dumb."
- **Showing student names in peer comparison**: Only percentiles and class averages may be displayed.
- **Replacing the existing fl_chart radar chart**: Extend `RadarSkillChart` rather than creating a new one.
- **Hardcoding recommendation counts**: Use the `priority` field (1-5) from the table, sort by priority, then limit.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Recommendation rendering | Custom logic per recommendation type | Single `RecommendationCard` that reads type/priority from entity | Uniform UX, maintainable |
| Peer comparison math | Client-side percentile calculation | Supabase RPC `security definer` | RLS bypass, no raw scores to client |
| Recommendation generation (quantitative) | Flutter-side threshold checks | PostgreSQL triggers + pg_cron | Works without app open, scalable |
| Loading states | `CircularProgressIndicator` everywhere | `ShimmerCardLoading` for card lists, `ShimmerListTileLoading` for list items | Matches existing pattern from Phase 4 |
| Radar chart reuse | New chart widget from scratch | Extend existing `RadarSkillChart` | Already has correct styling, fl_chart setup |

**Key insight:** The "Dumb UI" constraint means ~80% of the Flutter work is display logic. The recommendation engine complexity lives in PostgreSQL (triggers, cron, RPC), not in Dart.

---

## Common Pitfalls

### Pitfall 1: RLS Blocking RPC
**What goes wrong:** The `get_student_peer_comparison` RPC is created with `SECURITY DEFINER` but the underlying query joins `class_members` which has RLS. The `SECURITY DEFINER` bypasses RLS of the calling table but not the joined tables unless `search_path` is set.
**How to avoid:** Always `SET search_path = public` in SECURITY DEFINER functions and test with a non-owner authenticated user.
**Verification:**
```sql
-- Test as authenticated student (not service_role):
SELECT get_student_peer_comparison('student-uuid', 'class-uuid');
-- Must return JSONB without errors
```

### Pitfall 2: Duplicate Recommendations
**What goes wrong:** DB trigger fires on EVERY submission graded update, potentially creating duplicate recommendations for the same issue.
**How to avoid:** Use `ON CONFLICT DO NOTHING` in the trigger's INSERT, or check if a similar recommendation (same student_id, type, title pattern) was created within the last 24 hours before inserting.
**Verification:**
```sql
-- Check for duplicates after trigger fires
SELECT student_id, title, created_at FROM ai_recommendations
WHERE created_at > now() - interval '1 hour'
ORDER BY created_at DESC;
```

### Pitfall 3: JSONB `resources` Parsing Without Null Guard
**What goes wrong:** The `resources` JSONB column may be NULL for rule-based recommendations that haven't populated resources yet.
**How to avoid:** Always use Freezed with `@Default` for JSONB fields, or add null checks in the widget:
```dart
final resources = recommendation.resources;
final exercises = resources?['exercises'] as List<dynamic>? ?? [];
```

### Pitfall 4: Conflicting RLS on `ai_recommendations`
**What goes wrong:** The table has `teacher_id` as a reference column, but student recommendations (REC-02) need `student_id`. Current RLS policy (`auth.uid() = teacher_id`) blocks students from reading their own recommendations.
**How to fix:** The existing migration shows `teacher_id` policy only. Need to add a student-facing policy: `student_id = (select auth.uid())` for SELECT, OR restructure to use a single policy that checks `teacher_id = auth.uid() OR student_id = auth.uid()`.
**Verification:**
```sql
-- Test as student:
SELECT * FROM ai_recommendations WHERE student_id = auth.uid() AND dismissed = false;
-- Must return student's own recommendations
```

### Pitfall 5: pg_cron Not Enabled
**What goes wrong:** Supabase free tier has pg_cron as an extension that must be enabled per project.
**How to avoid:** Document as a required Supabase configuration step. Check with `SELECT cron.schedule(...)` -- if it errors, pg_cron needs to be enabled via Supabase dashboard or:
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

---

## Code Examples

### Recommendation Entity (Freezed)

```dart
// lib/domain/entities/recommendation.dart
@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String id,
    String? teacherId,
    String? classId,
    String? studentId,
    @Default('individual') String type,     // 'individual' | 'small_group' | 'class'
    @Default(3) int priority,               // 1-5 (1 = most urgent)
    required String title,
    String? description,
    Map<String, dynamic>? resources,        // JSONB: {exercises[], videos[], documents[]}
    @Default(false) bool dismissed,
    DateTime? createdAt,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}

// Helper extensions
extension RecommendationHelpers on Recommendation {
  List<String> get exercises =>
    (resources?['exercises'] as List<dynamic>?)?.cast<String>() ?? [];

  List<String> get videos =>
    (resources?['videos'] as List<dynamic>?)?.cast<String>() ?? [];

  List<String> get documents =>
    (resources?['documents'] as List<dynamic>?)?.cast<String>() ?? [];

  bool get isUrgent => priority <= 2;
}
```

### Dismissing a Recommendation

```dart
// In RecommendationDatasource
Future<void> dismissRecommendation(String recommendationId) async {
  await _client
      .from('ai_recommendations')
      .update({'dismissed': true})
      .eq('id', recommendationId);
}
```

### Peer Comparison Badge Widget

```dart
class PeerComparisonBadge extends StatelessWidget {
  final double percentile;   // e.g., 15.0
  final double classAverage;  // e.g., 7.5

  const PeerComparisonBadge({
    super.key,
    required this.percentile,
    required this.classAverage,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = percentile <= 25;
    final label = isTop
        ? 'Thu top ${percentile.toStringAsFixed(0)}%'
        : 'Thu ${percentile.toStringAsFixed(0)}% cua lop';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isTop
            ? DesignColors.success.withValues(alpha: 0.1)
            : DesignColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: isTop ? DesignColors.success : DesignColors.warning,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTop ? Icons.trending_up : Icons.trending_flat,
            size: DesignIcons.xsSize,
            color: isTop ? DesignColors.success : DesignColors.warning,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(label, style: DesignTypography.labelSmall),
        ],
      ),
    );
  }
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Analytics-only display (Phase 4) | Recommendations on top of analytics | Phase 5 | Students/teachers get actionable next steps |
| Raw scores fetched to client for peer comparison | RPC server-side computation | Phase 5 | RLS compliance, no data leakage |
| Recommendations generated in Flutter code | PostgreSQL triggers + pg_cron | Phase 5 | Works without app open, zero API cost |
| Single recommendation surface | Dual-layer ("Clinic + Pillbox") | Phase 5 | Prevents cognitive overload, surfaces urgency |

**Deprecated/outdated:**
- Phase 4 `getClassComparison` in `analytics_datasource.dart` fetches raw scores to Flutter -- must be replaced with RPC call during Phase 5 implementation.

---

## Open Questions

1. **Curated resource curation**
   - What we know: JSONB `resources` column schema supports `videos`, `documents`, `exercises` arrays. Exercises are UUIDs from `assignments` table.
   - What's unclear: Who curates the initial video/document links? Is there a resource library table, or do teachers paste URLs?
   - Recommendation: Add a `curated_resources` table or use the `resources` JSONB column with teacher-managed URLs. Document the curation workflow in the plan.

2. **pg_cron availability on Supabase free tier**
   - What we know: pg_cron requires Supabase Pro plan or dedicated instance. Free tier may not have it.
   - What's unclear: What Supabase plan is this project using?
   - Recommendation: Verify with `SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'`. If unavailable, fall back to a Flutter-side periodic refresh (e.g., on app open) for the "night patrol" logic.

3. **Assignment UUIDs for practice exercises**
   - What we know: Practice exercises are UUIDs from the `assignments` table. Need to JOIN with `assignments` to get title and navigation info.
   - What's unclear: Should old assignments be reusable as practice exercises, or is there a "practice assignment" flag?
   - Recommendation: Query assignments by the teacher's class IDs, filter by available/active status. No new table needed -- reuse existing `assignments` table.

4. **Rec-01: Which class for the teacher recommendation?**
   - What we know: Teachers have multiple classes. Recommendations need `class_id` to scope the context.
   - What's unclear: Should REC-01 show recommendations across ALL classes (teacher's full roster), or filter by a specific class context?
   - Recommendation: Show across all classes, with class name as a filter chip on the TeacherRecommendationsScreen. This matches the ATC Dashboard pattern from Phase 2.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| PostgreSQL (Supabase) | DB triggers, pg_cron, RPC | Yes (Supabase) | -- | Flutter-side periodic refresh if pg_cron unavailable |
| `pg_cron` extension | Nightly patrol | Unknown | -- | Flutter-side on-app-open scan |
| `fl_chart` | Radar charts, line charts | Yes | ^0.69.0 | -- |
| `riverpod` | State management | Yes | ^2.5.1 | -- |
| `freezed` | Immutable models | Yes | latest | -- |
| Supabase MCP | Schema verification, migrations | Yes | -- | Manual SQL execution |

**Missing dependencies with no fallback:**
- pg_cron (if Supabase free tier): Night patrol recommendations will be delayed until student opens app. Impact: REC-01/REC-02 macro-level recommendations less timely. Recommendation: Flag for verification with Supabase plan check.

**Missing dependencies with fallback:**
- None identified -- all Flutter dependencies are already in pubspec.yaml.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (built-in) |
| Config file | none -- standard Flutter test |
| Quick run command | `flutter test test/recommendation/` |
| Full suite command | `flutter test` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REC-01 | Teacher receives intervention suggestions | Unit | `flutter test test/recommendation/teacher_test.dart` | TBD |
| REC-02 | Student receives learning resource suggestions | Unit | `flutter test test/recommendation/student_test.dart` | TBD |
| REC-03 | Peer comparison shows percentile + class average | Unit | `flutter test test/recommendation/peer_comparison_test.dart` | TBD |
| REC-01 | Intervention count badge on ATC Dashboard | Widget | `flutter test test/widgets/intervention_badge_test.dart` | TBD |
| REC-02 | Top-3 recommendations on student Tab | Widget | `flutter test test/widgets/student_recommendations_tab_test.dart` | TBD |
| REC-03 | Dual radar chart renders correctly | Widget | `flutter test test/widgets/dual_radar_chart_test.dart` | TBD |

### Wave 0 Gaps
- [ ] `test/recommendation/` directory -- unit tests for recommendation providers
- [ ] `test/widgets/intervention_badge_test.dart` -- badge widget test
- [ ] `test/widgets/student_recommendations_tab_test.dart` -- tab widget test
- [ ] `test/widgets/dual_radar_chart_test.dart` -- dual radar chart widget test
- [ ] `test/widgets/peer_comparison_badge_test.dart` -- peer badge widget test
- [ ] `test/datasources/recommendation_datasource_test.dart` -- datasource tests (mock Supabase)
- Framework install: Already installed via `flutter_test` in pubspec.yaml

*(If no gaps: existing test infrastructure covers all phase requirements)* -- Wave 0 gaps identified above. Phase 5 introduces new UI widgets and data flows not covered by existing tests.

---

## Sources

### Primary (HIGH confidence)
- `db/schema_03_submissions_ai_analytics.sql` (lines 262-283) -- `ai_recommendations` table schema verified
- `db/schema_03_submissions_ai_analytics.sql` (lines 217-226) -- `student_skill_mastery` table schema verified
- `lib/data/datasources/analytics_datasource.dart` -- existing query patterns, ClassComparison entity
- `lib/domain/entities/analytics/student_analytics.dart` -- ClassComparison freezed model
- `lib/presentation/providers/analytics_providers.dart` -- existing Riverpod patterns
- `lib/presentation/views/grading/widgets/analytics/charts/radar_skill_chart.dart` -- fl_chart RadarChart usage
- `pubspec.yaml` line 84 -- fl_chart version ^0.69.0 verified

### Secondary (MEDIUM confidence)
- `.planning/phases/05-personalized-recommendations/05-CONTEXT.md` -- Phase decisions, locked architecture
- `.planning/phases/06-ai-grading/06-CONTEXT.md` -- ai_recommendations design, CO-STAR framework reference
- `memory-bank/DESIGN_SYSTEM_GUIDE.md` -- design tokens reference
- `memory-bank/systemPatterns.md` -- Clean Architecture, RLS conventions, fl_chart patterns
- `docs/guides/development/sql-flow-decisions.md` -- SQL flow reference for recommendations

### Tertiary (LOW confidence)
- pg_cron availability on Supabase free tier -- needs verification with actual Supabase instance
- Curated resources curation workflow -- not yet defined in any document

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all packages already in pubspec.yaml, patterns from existing Phase 4 code
- Architecture: HIGH -- Dumb UI, DB triggers, RPC patterns well-established from Phase 2/4 context
- Pitfalls: MEDIUM -- RLS blocking RPC and pg_cron availability need verification on actual Supabase instance
- DB migration patterns: MEDIUM -- trigger/RPC/cron patterns are standard PostgreSQL but need testing on Supabase

**Research date:** 2026-03-25
**Valid until:** 2026-04-25 (30 days -- Supabase features and fl_chart are stable)

---

## Research Blockers

None -- all required information was available from CONTEXT.md, existing code, and schema files.

**Unresolved:**
- pg_cron availability on Supabase plan (needs actual Supabase instance check)
- Curated resources curation workflow (needs clarification from user/product)

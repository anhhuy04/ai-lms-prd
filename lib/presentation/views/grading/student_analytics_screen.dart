import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../domain/entities/analytics/student_analytics.dart';
import '../../providers/analytics_providers.dart';
import 'widgets/analytics/charts/radar_skill_chart.dart';
import 'widgets/analytics/charts/line_trend_chart.dart';
import 'widgets/analytics/cards/metric_card.dart';
import 'widgets/analytics/cards/strength_weakness_card.dart';
import 'widgets/analytics/empty_states/zero_submissions.dart';
import 'widgets/analytics/empty_states/pending_grading.dart';
import 'widgets/analytics/empty_states/no_skill_data.dart';
import 'widgets/analytics/time_range_selector.dart';

class StudentAnalyticsScreen extends ConsumerStatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  ConsumerState<StudentAnalyticsScreen> createState() =>
      _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState
    extends ConsumerState<StudentAnalyticsScreen> {
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.all;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(studentAnalyticsNotifierProvider);
    final emptyState = ref.watch(analyticsEmptyStateProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Cannot load data', style: DesignTypography.titleMedium),
              SizedBox(height: DesignSpacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(studentAnalyticsNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (analytics) => _buildContent(analytics, emptyState),
      ),
    );
  }

  Widget _buildContent(StudentAnalytics analytics, AnalyticsEmptyState emptyState) {
    // Show empty states based on condition
    if (emptyState == AnalyticsEmptyState.zeroSubmissions) {
      return ZeroSubmissionsState(
        onTakeDiagnostic: () {
          // Navigate to diagnostic test
        },
      );
    }

    if (emptyState == AnalyticsEmptyState.pendingGrading) {
      return const PendingGradingState();
    }

    if (emptyState == AnalyticsEmptyState.noSkillData) {
      return NoSkillDataState(
        onCompleteAssignment: () {
          // Navigate to assignments
        },
      );
    }

    // Normal state - show full dashboard
    return RefreshIndicator(
      onRefresh: () => ref.read(studentAnalyticsNotifierProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time range selector
            TimeRangeSelector(
              selected: _selectedRange,
              onChanged: (range) => setState(() => _selectedRange = range),
            ),
            SizedBox(height: DesignSpacing.lg),

            // Group 1: Basic & Engagement Metrics
            _buildBasicMetrics(analytics.basicMetrics),
            SizedBox(height: DesignSpacing.lg),

            // Group 2: Skill Map (Radar) - Core Feature
            _buildSectionTitle('Skill Map'),
            SizedBox(height: DesignSpacing.sm),
            RadarSkillChart(skills: analytics.skillMasteries),
            SizedBox(height: DesignSpacing.lg),

            // Group 3: Strengths & Weaknesses
            _buildSectionTitle('Performance Analysis'),
            SizedBox(height: DesignSpacing.sm),
            StrengthWeaknessCard(
              strengths: analytics.strengthsWeaknesses.strengths,
              weaknesses: analytics.strengthsWeaknesses.weaknesses,
              onWeaknessTap: (skillName) {
                // Navigate to suggested resources
              },
            ),
            SizedBox(height: DesignSpacing.lg),

            // Group 4: Grade Trends
            _buildSectionTitle('Grade Trends'),
            SizedBox(height: DesignSpacing.sm),
            LineTrendChart(trends: analytics.gradeTrends),
            SizedBox(height: DesignSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicMetrics(BasicEngagementMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Overview'),
        SizedBox(height: DesignSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DesignSpacing.sm,
          crossAxisSpacing: DesignSpacing.sm,
          childAspectRatio: 1.5,
          children: [
            MetricCard(
              label: 'Average Score',
              value: '${metrics.avgScore.toStringAsFixed(1)}%',
              icon: Icons.score,
              trendColor: metrics.trendDirection == TrendDirection.up
                  ? DesignColors.success
                  : metrics.trendDirection == TrendDirection.down
                      ? DesignColors.error
                      : null,
              trendText: _getTrendText(metrics.trendDirection),
            ),
            MetricCard(
              label: 'On-time Rate',
              value: '${(metrics.onTimeRate * 100).toStringAsFixed(0)}%',
              icon: Icons.schedule,
              trendColor: metrics.onTimeRate >= 0.8
                  ? DesignColors.success
                  : DesignColors.warning,
            ),
            MetricCard(
              label: 'Time Spent',
              value: _formatTime(metrics.totalTimeMinutes),
              icon: Icons.timer,
            ),
            MetricCard(
              label: 'Submissions',
              value: '${metrics.submissionCount}',
              icon: Icons.assignment_turned_in,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String? _getTrendText(TrendDirection? direction) {
    if (direction == null) return null;
    switch (direction) {
      case TrendDirection.up:
        return 'Improving';
      case TrendDirection.down:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }
}

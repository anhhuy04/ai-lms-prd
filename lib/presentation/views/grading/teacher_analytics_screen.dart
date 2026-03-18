import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'widgets/analytics/teacher/charts/grade_distribution_chart.dart';
import 'widgets/analytics/teacher/cards/class_overview_card.dart';
import 'widgets/analytics/teacher/lists/top_performers_list.dart';
import 'widgets/analytics/teacher/lists/bottom_performers_list.dart';

class TeacherAnalyticsScreen extends ConsumerStatefulWidget {
  final String classId;

  const TeacherAnalyticsScreen({
    super.key,
    required this.classId,
  });

  @override
  ConsumerState<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState
    extends ConsumerState<TeacherAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(classAnalyticsProvider(widget.classId));

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Class Analytics'),
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
                onPressed: () =>
                    ref.invalidate(classAnalyticsProvider(widget.classId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (analytics) => _buildContent(analytics),
      ),
    );
  }

  Widget _buildContent(ClassAnalytics analytics) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(classAnalyticsProvider(widget.classId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Overview Card
            ClassOverviewCard(
              classAverage: analytics.classAverage,
              totalStudents: _calculateUniqueStudents(analytics),
              totalSubmissions: _calculateTotalSubmissions(analytics),
              highestScore: analytics.topPerformers.isNotEmpty
                  ? analytics.topPerformers.first.score
                  : null,
              lowestScore: analytics.bottomPerformers.isNotEmpty
                  ? analytics.bottomPerformers.last.score
                  : null,
            ),
            SizedBox(height: DesignSpacing.lg),

            // Grade Distribution Chart
            _buildSectionTitle('Grade Distribution'),
            SizedBox(height: DesignSpacing.sm),
            GradeDistributionChart(distribution: analytics.distribution),
            SizedBox(height: DesignSpacing.lg),

            // Top Performers
            _buildSectionTitle('Top Performers'),
            SizedBox(height: DesignSpacing.sm),
            TopPerformersList(
              performers: analytics.topPerformers,
              onTap: (studentId) {
                // Navigate to student detail
              },
            ),
            SizedBox(height: DesignSpacing.lg),

            // Bottom Performers (needs attention)
            _buildSectionTitle('Needs Attention'),
            SizedBox(height: DesignSpacing.sm),
            BottomPerformersList(
              performers: analytics.bottomPerformers,
              onTap: (studentId) {
                // Navigate to student detail or send intervention
              },
            ),
            SizedBox(height: DesignSpacing.xxl),
          ],
        ),
      ),
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

  int _calculateUniqueStudents(ClassAnalytics analytics) {
    final ids = <String>{};
    for (final p in analytics.topPerformers) {
      ids.add(p.studentId);
    }
    for (final p in analytics.bottomPerformers) {
      ids.add(p.studentId);
    }
    return ids.isEmpty ? analytics.totalStudents : ids.length;
  }

  int _calculateTotalSubmissions(ClassAnalytics analytics) {
    int total = 0;
    for (final d in analytics.distribution) {
      total += d.count;
    }
    return total > 0 ? total : analytics.totalSubmissions;
  }
}

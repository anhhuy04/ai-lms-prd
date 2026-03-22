import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/score_display_utils.dart';
import 'package:ai_mls/domain/entities/analytics/student_analytics.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/charts/radar_skill_chart.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/charts/line_trend_chart.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/cards/metric_card.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/cards/strength_weakness_card.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/time_range_selector.dart'
    show
        AnalyticsTimeRange,
        AnalyticsTimeRangeAll,
        AnalyticsTimeRangeWeek,
        AnalyticsTimeRangeMonth,
        AnalyticsTimeRangeCustom,
        showAnalyticsFilterBottomSheet,
        AnalyticsFilterChip;

/// Screen for a teacher to view a specific student's analytics.
/// Accessed from top/bottom performers list in TeacherAnalyticsScreen.
class TeacherStudentAnalyticsScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String? classId;

  const TeacherStudentAnalyticsScreen({
    super.key,
    required this.studentId,
    this.classId,
  });

  @override
  ConsumerState<TeacherStudentAnalyticsScreen> createState() =>
      _TeacherStudentAnalyticsScreenState();
}

class _TeacherStudentAnalyticsScreenState
    extends ConsumerState<TeacherStudentAnalyticsScreen> {
  AnalyticsTimeRange _selectedRange = const AnalyticsTimeRangeAll();
  String? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      teacherStudentAnalyticsNotifierProvider(
        studentId: widget.studentId,
        classId: widget.classId,
        timeRange: _selectedRange,
      ),
    );

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Phân tích học sinh'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const ShimmerDashboardLoading(),
        error: (e, st) {
          AppLogger.error(
            '[TeacherStudentAnalytics] Error loading analytics',
            error: e,
            stackTrace: st,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Không thể tải dữ liệu',
                  style: DesignTypography.titleMedium,
                ),
                SizedBox(height: DesignSpacing.sm),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    teacherStudentAnalyticsNotifierProvider(
                      studentId: widget.studentId,
                      classId: widget.classId,
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
        data: (analytics) => _buildContent(analytics),
      ),
    );
  }

  Widget _buildContent(StudentAnalytics analytics) {
    final hasSkillData = analytics.skillMasteries.isNotEmpty &&
        analytics.skillMasteries.any((s) => s.attempts > 0);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(
            teacherStudentAnalyticsNotifierProvider(
              studentId: widget.studentId,
              classId: widget.classId,
              timeRange: _selectedRange,
            ).notifier,
          )
          .refresh(
            studentId: widget.studentId,
            classId: widget.classId,
            timeRange: _selectedRange,
          ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter row (time range + class filter via bottom sheet)
            _buildFilterRow(),
            SizedBox(height: DesignSpacing.lg),

            // Group 1: Basic & Engagement Metrics
            _buildBasicMetrics(analytics.basicMetrics),
            SizedBox(height: DesignSpacing.lg),

            // Group 2: Skill Map (Radar)
            _buildSectionTitle('Kỹ năng'),
            SizedBox(height: DesignSpacing.sm),
            if (hasSkillData)
              RadarSkillChart(skills: analytics.skillMasteries)
            else
              _buildSkillMapPlaceholder(),
            SizedBox(height: DesignSpacing.lg),

            // Group 3: Strengths & Weaknesses
            _buildSectionTitle('Phân tích điểm mạnh/yếu'),
            SizedBox(height: DesignSpacing.sm),
            if (hasSkillData)
              StrengthWeaknessCard(
                strengths: analytics.strengthsWeaknesses.strengths,
                weaknesses: analytics.strengthsWeaknesses.weaknesses,
                onWeaknessTap: (_) {},
              )
            else
              _buildStrengthWeaknessPlaceholder(),
            SizedBox(height: DesignSpacing.lg),

            // Group 4: Grade Trends
            _buildSectionTitle('Xu hướng điểm số'),
            SizedBox(height: DesignSpacing.sm),
            if (analytics.gradeTrends.isNotEmpty)
              LineTrendChart(trends: analytics.gradeTrends)
            else
              _buildLineChartPlaceholder(),
            SizedBox(height: DesignSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillMapPlaceholder() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Chưa có dữ liệu kỹ năng',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthWeaknessPlaceholder() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Center(
        child: Text(
          'Chưa có dữ liệu phân tích điểm mạnh/yếu',
          style: DesignTypography.bodyMedium.copyWith(
            color: DesignColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLineChartPlaceholder() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: DesignColors.textSecondary),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Chưa có dữ liệu xu hướng điểm',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicMetrics(BasicEngagementMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tổng quan'),
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
              label: 'Điểm trung bình',
              value: '${ScoreDisplayUtils.toRawString(metrics.avgScore)}/10',
              icon: Icons.score,
              trendColor: metrics.trendDirection == TrendDirection.up
                  ? DesignColors.success
                  : metrics.trendDirection == TrendDirection.down
                      ? DesignColors.error
                      : DesignColors.textSecondary,
              trendText: _getTrendText(metrics.trendDirection),
            ),
            MetricCard(
              label: 'Nộp đúng hạn',
              value: '${(metrics.onTimeRate * 100).toStringAsFixed(0)}%',
              icon: Icons.schedule,
              trendColor: metrics.onTimeRate >= 0.8
                  ? DesignColors.success
                  : DesignColors.warning,
            ),
            MetricCard(
              label: 'Thời gian học',
              value: _formatTime(metrics.totalTimeMinutes),
              icon: Icons.timer,
            ),
            MetricCard(
              label: 'Bài đã nộp',
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
      style: DesignTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
    );
  }

  String? _getTrendText(TrendDirection? direction) {
    if (direction == null) return null;
    switch (direction) {
      case TrendDirection.up:
        return 'Tăng ↑';
      case TrendDirection.down:
        return 'Giảm ↓';
      case TrendDirection.stable:
        return 'Ổn định →';
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  String get _filterDescription {
    final parts = <String>[];
    if (_selectedRange is AnalyticsTimeRangeWeek) {
      parts.add('Tuần này');
    } else if (_selectedRange is AnalyticsTimeRangeMonth) {
      parts.add('Tháng này');
    } else if (_selectedRange is AnalyticsTimeRangeCustom) {
      parts.add('Tùy chỉnh');
    } else {
      parts.add('Tất cả thời gian');
    }
    if (_selectedClassId != null) {
      parts.add('Lớp đã chọn');
    } else {
      parts.add('Tất cả lớp');
    }
    return parts.join(' · ');
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await showAnalyticsFilterBottomSheet(
      context: context,
      ref: ref,
      initialTimeRange: _selectedRange,
      initialClassId: _selectedClassId,
    );
    if (result != null) {
      setState(() {
        _selectedRange = result.timeRange;
        _selectedClassId = result.classId;
      });
    }
  }

  Widget _buildFilterRow() {
    final hasActiveFilter = _selectedRange is! AnalyticsTimeRangeAll ||
        _selectedClassId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsFilterChip(
          onTap: _showFilterBottomSheet,
          hasActiveFilter: hasActiveFilter,
        ),
        SizedBox(height: DesignSpacing.xs),
        Text(
          _filterDescription,
          style: DesignTypography.bodySmall,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/score_display_utils.dart';
import 'package:ai_mls/domain/entities/analytics/student_analytics.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart' as shimmers;
import 'widgets/analytics/charts/radar_skill_chart.dart';
import 'widgets/analytics/charts/line_trend_chart.dart';
import 'widgets/analytics/cards/metric_card.dart';
import 'widgets/analytics/cards/strength_weakness_card.dart';
import 'widgets/analytics/empty_states/zero_submissions.dart';
import 'widgets/analytics/empty_states/pending_grading.dart';
import 'widgets/analytics/empty_states/no_submissions_in_range.dart';
import 'widgets/analytics/time_range_selector.dart'
    show
        AnalyticsTimeRange,
        AnalyticsTimeRangeAll,
        AnalyticsTimeRangeWeek,
        AnalyticsTimeRangeMonth,
        AnalyticsTimeRangeCustom,
        showAnalyticsFilterBottomSheet,
        AnalyticsFilterChip;

class StudentAnalyticsScreen extends ConsumerStatefulWidget {
  final String? classId;

  const StudentAnalyticsScreen({super.key, this.classId});

  @override
  ConsumerState<StudentAnalyticsScreen> createState() =>
      _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState
    extends ConsumerState<StudentAnalyticsScreen> {
  AnalyticsTimeRange _selectedRange = const AnalyticsTimeRangeAll();
  String? _selectedClassId;
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
  }

  /// Computed filter state description text.
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

    if (_selectedClassName != null) {
      parts.add(_selectedClassName!);
    } else {
      parts.add('Tất cả lớp');
    }

    return parts.join(' · ');
  }

  bool get _hasActiveFilter {
    if (_selectedRange is! AnalyticsTimeRangeAll) return true;
    if (_selectedClassId != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      studentAnalyticsNotifierProvider(
        classId: _selectedClassId,
        timeRange: _selectedRange,
      ),
    );
    final emptyState = ref.watch(
      analyticsEmptyStateProvider(
        classId: _selectedClassId,
        timeRange: _selectedRange,
      ),
    );

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Phân tích học tập'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const shimmers.ShimmerStudentAnalyticsLoading(),
        error: (e, st) {
          AppLogger.error(
            '[StudentAnalyticsScreen] Error loading analytics',
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
                    studentAnalyticsNotifierProvider(
                      classId: _selectedClassId,
                      timeRange: _selectedRange,
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
        data: (analytics) => _buildContent(analytics, emptyState),
      ),
    );
  }

  Widget _buildContent(
    StudentAnalytics analytics,
    AnalyticsEmptyState emptyState,
  ) {
    // Show zeroSubmissions empty state when student has no submissions at all
    if (emptyState == AnalyticsEmptyState.zeroSubmissions) {
      return ZeroSubmissionsState(
        onTakeDiagnostic: () {
          context.pushNamed(AppRoute.studentAssignmentList);
        },
      );
    }

    if (emptyState == AnalyticsEmptyState.pendingGrading) {
      return const PendingGradingState();
    }

    if (emptyState == AnalyticsEmptyState.noDataInRange) {
      return NoSubmissionsInRangeState(
        onClearFilter: () {
          setState(() {
            _selectedRange = const AnalyticsTimeRangeAll();
            _selectedClassId = null;
            _selectedClassName = null;
          });
        },
      );
    }

    // noSkillData: show dashboard with basic metrics + placeholder for radar/line
    final hasSkillData =
        analytics.skillMasteries.isNotEmpty &&
        analytics.skillMasteries.any((s) => s.attempts > 0);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(
            studentAnalyticsNotifierProvider(
              classId: _selectedClassId,
              timeRange: _selectedRange,
            ).notifier,
          )
          .refresh(classId: _selectedClassId, timeRange: _selectedRange),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chip + current filter description
            _buildFilterRow(),
            SizedBox(height: DesignSpacing.lg),

            // Group 1: Basic & Engagement Metrics
            _buildBasicMetrics(analytics.basicMetrics),
            SizedBox(height: DesignSpacing.lg),

            // Group 2: Skill Map (Radar) - Core Feature
            _buildSectionTitle('Kỹ năng của bạn'),
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
                onWeaknessTap: (skillName) {
                  context.pushNamed(AppRoute.studentAssignmentList);
                },
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

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsFilterChip(
          hasActiveFilter: _hasActiveFilter,
          onTap: _showFilterBottomSheet,
        ),
        if (_hasActiveFilter) ...[
          SizedBox(height: DesignSpacing.xs),
          Padding(
            padding: EdgeInsets.only(left: DesignSpacing.xs),
            child: Text(
              _filterDescription,
              style: DesignTypography.caption.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await showAnalyticsFilterBottomSheet(
      context: context,
      ref: ref,
      initialTimeRange: _selectedRange,
      initialClassId: _selectedClassId,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedRange = result.timeRange;
        _selectedClassId = result.classId;
        _selectedClassName = result.className;
      });
    }
  }

  Widget _buildSkillMapPlaceholder() {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.studentAssignmentList),
      child: SizedBox(
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
              SizedBox(height: DesignSpacing.xs),
              Text(
                'Hoàn thành nhiều bài tập hơn để xem biểu đồ kỹ năng',
                style: DesignTypography.caption.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
          'Hoàn thành nhiều bài tập hơn để xem phân tích điểm mạnh/yếu',
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
              trendText: metrics.onTimeRate >= 0.8
                  ? 'Tốt'
                  : 'Cần cải thiện',
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
}

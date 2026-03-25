import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/score_display_utils.dart';
import 'package:ai_mls/domain/entities/analytics/student_analytics.dart';
import 'package:ai_mls/domain/entities/analytics/skill_mastery.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/dual_radar_chart.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/peer_comparison_badge.dart';
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

            // Group 4: Peer Comparison (REC-03)
            _buildSectionTitle('So sanh voi lop'),
            SizedBox(height: DesignSpacing.sm),
            _buildPeerComparisonSection(),
            SizedBox(height: DesignSpacing.lg),

            // Group 5: Grade Trends
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

  // REC-03: Peer Comparison Section
  Widget _buildPeerComparisonSection() {
    final classId = _selectedClassId;
    if (classId == null) {
      return _buildPeerComparisonPlaceholder('Chon lop de xem so sanh');
    }

    final peerAsync = ref.watch(peerComparisonProvider(classId));
    final skillMasteries = ref.watch(skillMasteryProvider).value ?? [];

    return peerAsync.when(
      data: (peer) {
        if (peer.totalStudents == 0) {
          return _buildPeerComparisonPlaceholder('Chua co du lieu lop');
        }

        return Container(
          padding: EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            boxShadow: [DesignElevation.level1],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'So sanh voi lop',
                          style: DesignTypography.titleMedium,
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        PeerComparisonBadge(
                          percentile: peer.percentile,
                          classAverage: peer.classAverage,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showPeerComparisonBottomSheet(
                      classId,
                      peer,
                      skillMasteries,
                    ),
                    icon: const Icon(Icons.radar),
                    label: const Text('Xem chi tiet'),
                  ),
                ],
              ),
              SizedBox(height: DesignSpacing.md),
              _buildPeerTrendMiniChart(peer),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => _buildPeerComparisonPlaceholder('Loi tai du lieu'),
    );
  }

  Widget _buildPeerComparisonPlaceholder(String message) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [DesignElevation.level1],
      ),
      child: Center(
        child: Text(
          message,
          style: DesignTypography.bodyMedium.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPeerTrendMiniChart(PeerComparison peer) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Diem cua ban',
                style: DesignTypography.labelSmall.copyWith(color: Colors.grey),
              ),
              SizedBox(height: DesignSpacing.xs),
              Text(
                '-',
                style: DesignTypography.titleMedium.copyWith(
                  color: DesignColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.shade200,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trung binh lop',
                style: DesignTypography.labelSmall.copyWith(color: Colors.grey),
              ),
              SizedBox(height: DesignSpacing.xs),
              Text(
                peer.classAverage > 0
                    ? peer.classAverage.toStringAsFixed(1)
                    : '-',
                style: DesignTypography.titleMedium.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPeerComparisonBottomSheet(
    String classId,
    PeerComparison peer,
    List<SkillMastery> studentSkills,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (sheetContext, scrollController) => Consumer(
          builder: (sheetContext, sheetRef, _) {
            final classAvgAsync = ref.watch(classAverageSkillMasteryProvider(classId));
            final classAvgMap = classAvgAsync.value ?? {};

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: DesignSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'So sanh ky nang',
                                style: DesignTypography.titleLarge,
                              ),
                              Text(
                                'So sanh muc do thanh thao cua ban voi trung binh lop',
                                style: DesignTypography.bodySmall.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PeerComparisonBadge(
                          percentile: peer.percentile,
                          classAverage: peer.classAverage,
                        ),
                      ],
                    ),
                  ),

                  // Dual Radar Chart
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                            child: DualRadarChart(
                              studentSkills: studentSkills,
                              classAverageSkills: classAvgMap,
                              height: 300,
                            ),
                          ),

                          // Legend
                          Padding(
                            padding: EdgeInsets.all(DesignSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(DesignColors.primary, 'Ky nang cua ban'),
                                SizedBox(width: DesignSpacing.lg),
                                _buildLegendItem(Colors.grey.shade400, 'Trung binh lop'),
                              ],
                            ),
                          ),

                          // Stats row
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                            child: Row(
                              children: [
                                _buildStatCard(
                                  'Thu ${peer.percentile.toStringAsFixed(0)}%',
                                  'trong lop',
                                  peer.totalStudents,
                                ),
                                SizedBox(width: DesignSpacing.sm),
                                _buildStatCard(
                                  peer.classAverage.toStringAsFixed(1),
                                  'Trung binh lop',
                                  null,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: DesignSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: DesignSpacing.xs),
        Text(label, style: DesignTypography.labelSmall),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, int? suffix) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.moonLight,
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: DesignTypography.titleLarge.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (suffix != null) ...[
                  SizedBox(width: DesignSpacing.xs),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '/$suffix',
                      style: DesignTypography.labelSmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              label,
              style: DesignTypography.labelSmall.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

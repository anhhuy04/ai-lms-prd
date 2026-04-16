
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/analytics/grade_trend.dart';
import 'package:ai_mls/domain/entities/analytics/student_analytics.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/charts/line_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScoresScreen extends ConsumerWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(studentAnalyticsNotifierProvider());
    final emptyState = ref.watch(analyticsEmptyStateProvider());

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Điểm số'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, ref, e.toString()),
        data: (analytics) => _buildContent(context, analytics, emptyState),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: DesignColors.error,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Không thể tải dữ liệu',
            style: DesignTypography.titleMedium,
          ),
          SizedBox(height: DesignSpacing.sm),
          ElevatedButton(
            onPressed: () => ref.invalidate(studentAnalyticsNotifierProvider),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StudentAnalytics analytics,
    AnalyticsEmptyState emptyState,
  ) {
    // Show empty state if no submissions
    if (emptyState == AnalyticsEmptyState.zeroSubmissions) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Summary Card - Main feature
          _buildAnalyticsSummaryCard(context, analytics),
          SizedBox(height: DesignSpacing.lg),

          // Quick Stats Grid
          _buildQuickStats(analytics.basicMetrics),
          SizedBox(height: DesignSpacing.lg),

          // Strengths Preview
          if (analytics.strengthsWeaknesses.strengths.isNotEmpty)
            _buildStrengthsPreview(analytics.strengthsWeaknesses.strengths),
          SizedBox(height: DesignSpacing.lg),

          // Xu hướng điểm số
          _buildScoreTrendSection(analytics.gradeTrends),
          SizedBox(height: DesignSpacing.lg),

          // So sánh với lớp
          if (analytics.classComparison.totalStudents > 0)
            _buildClassComparisonSection(analytics.classComparison, analytics.basicMetrics.avgScore),
          SizedBox(height: DesignSpacing.md),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.xl),
              decoration: BoxDecoration(
                color: DesignColors.primaryLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: DesignColors.primary,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Chưa có dữ liệu điểm số',
              style: DesignTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Hoàn thành bài tập để xem thống kê học tập của bạn',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummaryCard(
    BuildContext context,
    StudentAnalytics analytics,
  ) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.studentAnalytics),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignColors.primary,
              DesignColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [
            BoxShadow(
              color: DesignColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.analytics_outlined,
                size: 120,
                color: DesignColors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng quan học tập',
                        style: DesignTypography.titleMedium.copyWith(
                          color: DesignColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSpacing.sm,
                          vertical: DesignSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: DesignColors.white,
                            ),
                            SizedBox(width: DesignSpacing.xs),
                            Text(
                              'Xem chi tiết',
                              style: DesignTypography.caption.copyWith(
                                color: DesignColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Row(
                    children: [
                      // Score circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignColors.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                analytics.basicMetrics.avgScore.toStringAsFixed(1),
                                style: DesignTypography.headlineMedium.copyWith(
                                  color: DesignColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Điểm TB',
                                style: DesignTypography.caption.copyWith(
                                  color: DesignColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: DesignSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryRow(
                              Icons.trending_up,
                              'Xu hướng',
                              _getTrendText(analytics.basicMetrics.trendDirection),
                              analytics.basicMetrics.trendDirection,
                            ),
                            SizedBox(height: DesignSpacing.sm),
                            _buildSummaryRow(
                              Icons.check_circle_outline,
                              'Nộp đúng hạn',
                              '${(analytics.basicMetrics.onTimeRate * 100).toStringAsFixed(0)}%',
                              null,
                            ),
                            SizedBox(height: DesignSpacing.sm),
                            _buildSummaryRow(
                              Icons.assignment_turned_in,
                              'Tổng bài',
                              '${analytics.basicMetrics.submissionCount}',
                              null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, TrendDirection? trend) {
    Color? valueColor;
    if (trend == TrendDirection.up) {
      valueColor = DesignColors.success;
    } else if (trend == TrendDirection.down) {
      valueColor = DesignColors.error;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: DesignColors.white.withValues(alpha: 0.8),
        ),
        SizedBox(width: DesignSpacing.sm),
        Text(
          label,
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.white.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: DesignTypography.bodyMedium.copyWith(
            color: valueColor ?? DesignColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getTrendText(TrendDirection? trend) {
    switch (trend) {
      case TrendDirection.up:
        return 'Tăng ↑';
      case TrendDirection.down:
        return 'Giảm ↓';
      case TrendDirection.stable:
        return 'Ổn định →';
      default:
        return 'Chưa rõ';
    }
  }

  Widget _buildQuickStats(BasicEngagementMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê nhanh',
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                label: 'Thời gian học',
                value: _formatTime(metrics.totalTimeMinutes),
                color: DesignColors.info,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment,
                label: 'Bài đã làm',
                value: '${metrics.submissionCount}',
                color: DesignColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsPreview(List<dynamic> strengths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Điểm mạnh',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem tất cả',
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        Wrap(
          spacing: DesignSpacing.sm,
          runSpacing: DesignSpacing.sm,
          children: strengths.take(3).map<Widget>((skill) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DesignColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: DesignColors.success,
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    skill.skillName,
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Xu hướng điểm số ───────────────────────────────────────────────────────

  Widget _buildScoreTrendSection(List<GradeTrend> trends) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 18,
                    color: DesignColors.primary,
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    'Xu hướng điểm số',
                    style: DesignTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (trends.isNotEmpty)
                Text(
                  '${trends.length} bài gần nhất',
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          if (trends.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.lg),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu điểm số',
                  style: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            LineTrendChart(trends: trends, height: 180),
            SizedBox(height: DesignSpacing.sm),
            // Mini summary dưới chart: min / max / gần nhất
            _buildTrendSummaryRow(trends),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendSummaryRow(List<GradeTrend> trends) {
    final scores = trends.map((t) => t.score).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final latestScore = trends.last.score;

    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            'Thấp nhất',
            minScore.toStringAsFixed(1),
            DesignColors.error,
            Icons.arrow_downward,
          ),
        ),
        Expanded(
          child: _buildMiniStat(
            'Cao nhất',
            maxScore.toStringAsFixed(1),
            DesignColors.success,
            Icons.arrow_upward,
          ),
        ),
        Expanded(
          child: _buildMiniStat(
            'Gần nhất',
            latestScore.toStringAsFixed(1),
            DesignColors.primary,
            Icons.radio_button_checked,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(height: 2),
        Text(
          value,
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: DesignTypography.caption.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── So sánh với lớp ────────────────────────────────────────────────────────

  Widget _buildClassComparisonSection(
    ClassComparison comparison,
    double myAvgScore,
  ) {
    final percentile = (comparison.percentile * 100).clamp(0.0, 100.0);
    final isAboveAverage = myAvgScore >= comparison.classAverage;
    final diff = (myAvgScore - comparison.classAverage).abs();
    final topPercent = (100 - percentile).clamp(0.0, 100.0);

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: DesignColors.primary,
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                'So sánh với lớp',
                style: DesignTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),

          // Percentile bar
          Row(
            children: [
              Text(
                'Xếp hạng phần trăm',
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Top ${topPercent.toStringAsFixed(0)}%',
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: topPercent <= 25
                      ? DesignColors.success
                      : topPercent <= 50
                          ? DesignColors.primary
                          : DesignColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignRadius.full),
            child: LinearProgressIndicator(
              value: comparison.percentile.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: DesignColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                topPercent <= 25
                    ? DesignColors.success
                    : topPercent <= 50
                        ? DesignColors.primary
                        : DesignColors.warning,
              ),
            ),
          ),
          SizedBox(height: DesignSpacing.md),

          // 3 metric row: rank / my score vs class avg / total students
          Row(
            children: [
              Expanded(
                child: _buildComparisonTile(
                  icon: Icons.leaderboard,
                  label: 'Xếp hạng',
                  value: '#${comparison.rank}',
                  sub: '/ ${comparison.totalStudents} học sinh',
                  color: DesignColors.primary,
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: _buildComparisonTile(
                  icon: isAboveAverage
                      ? Icons.trending_up
                      : Icons.trending_down,
                  label: 'So với lớp',
                  value: '${isAboveAverage ? '+' : '-'}${diff.toStringAsFixed(1)}',
                  sub: 'TB lớp: ${comparison.classAverage.toStringAsFixed(1)}',
                  color: isAboveAverage
                      ? DesignColors.success
                      : DesignColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTile({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: DesignSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            value,
            style: DesignTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            sub,
            style: DesignTypography.caption.copyWith(
              color: DesignColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}p';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}p';
  }
}

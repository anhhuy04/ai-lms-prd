import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/assignment_statistics.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/submission_filter_chips.dart';
import 'package:ai_mls/widgets/cards/statistics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Teacher Grading Hub Screen - ATC (Air Traffic Control) Dashboard
///
/// Central screen for managing assignment grading workflow.
/// Shows overview stats and quick access to pending grading tasks.
class TeacherGradingHubScreen extends ConsumerStatefulWidget {
  const TeacherGradingHubScreen({super.key});

  @override
  ConsumerState<TeacherGradingHubScreen> createState() =>
      _TeacherGradingHubScreenState();
}

class _TeacherGradingHubScreenState
    extends ConsumerState<TeacherGradingHubScreen> {
  SubmissionFilter _currentFilter = SubmissionFilter.all;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hubState = ref.watch(teacherAssignmentHubNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? DesignColors.moonDark : DesignColors.moonLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: DesignIcons.smSize,
            color: isDark
                ? DesignColors.textTertiary
                : DesignColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Chấm điểm',
          style: TextStyle(
            fontSize: DesignTypography.titleLargeSize,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignColors.white : DesignColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1A2632) : DesignColors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: hubState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          AppLogger.error(
            '[TeacherGradingHub] Error loading data',
            error: e,
            stackTrace: st,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: DesignColors.error),
                SizedBox(height: DesignSpacing.md),
                Text(
                  'Không thể tải dữ liệu',
                  style: DesignTypography.titleMedium,
                ),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
        data: (hubData) => _buildContent(hubData, isDark),
      ),
    );
  }

  Widget _buildContent(
    TeacherAssignmentHubState hubData,
    bool isDark,
  ) {
    final stats = hubData.statistics;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ATC Dashboard Stats Row
            _buildStatsRow(stats, isDark),
            SizedBox(height: DesignSpacing.xl),

            // Filter chips
            SubmissionFilterChips(
              currentFilter: _currentFilter,
              onFilterChanged: (filter) {
                setState(() => _currentFilter = filter);
              },
            ),
            SizedBox(height: DesignSpacing.lg),

            // Distributions with pending grading
            _buildDistributionsSection(hubData, isDark),

            SizedBox(height: DesignSpacing.xl),

            // Quick actions
            _buildQuickActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AssignmentStatistics stats, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: StatisticsCard(
            label: 'Chưa chấm',
            value: stats.ungraded,
            backgroundColor: DesignColors.warning.withValues(alpha: 0.1),
            textColor: DesignColors.warning,
            borderColor: DesignColors.warning.withValues(alpha: 0.3),
            icon: Icons.pending_actions,
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: StatisticsCard(
            label: 'Đã chấm',
            value: stats.graded,
            backgroundColor: DesignColors.success.withValues(alpha: 0.1),
            textColor: DesignColors.success,
            borderColor: DesignColors.success.withValues(alpha: 0.3),
            icon: Icons.check_circle_outline,
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: StatisticsCard(
            label: 'Tổng bài tập',
            value: stats.totalAssignments,
            backgroundColor: DesignColors.primary.withValues(alpha: 0.1),
            textColor: DesignColors.primary,
            borderColor: DesignColors.primary.withValues(alpha: 0.3),
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionsSection(
    TeacherAssignmentHubState hubData,
    bool isDark,
  ) {
    if (hubData.distributions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Chưa có bài tập nào được giao',
        subtitle: 'Giao bài tập cho lớp để bắt đầu chấm điểm.',
        isDark: isDark,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách bài nộp',
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hubData.distributions.length,
          separatorBuilder: (_, __) => SizedBox(height: DesignSpacing.md),
          itemBuilder: (context, index) {
            final dist = hubData.distributions[index];
            return _DistributionGradingCard(
              distribution: dist,
              isDark: isDark,
              onTap: () {
                // Find the assignment title from hubData.assignments
                final assignment = hubData.assignments
                    .where((a) => a.id == dist.assignmentId)
                    .firstOrNull;
                context.pushNamed(
                  AppRoute.teacherSubmissionList,
                  pathParameters: {'distributionId': dist.id},
                  extra: {
                    'assignmentTitle': assignment?.title ?? '',
                    'className': dist.className,
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.visibility_outlined,
                label: 'Xem tất cả bài nộp',
                color: DesignColors.primary,
                onTap: () {
                  // Navigate to grading overview - select first distribution if available
                },
                isDark: isDark,
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics_outlined,
                label: 'Xem phân tích',
                color: DesignColors.tealPrimary,
                onTap: () {
                  context.pushNamed(AppRoute.teacherAnalyticsOverview);
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : DesignColors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: DesignColors.textSecondary,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            title,
            style: DesignTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            subtitle,
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DistributionGradingCard extends StatelessWidget {
  final dynamic distribution;
  final bool isDark;
  final VoidCallback onTap;

  const _DistributionGradingCard({
    required this.distribution,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : DesignColors.dividerLight,
          ),
          boxShadow: [DesignElevation.level1],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Icon(
                Icons.assignment_turned_in_outlined,
                color: DesignColors.primary,
                size: DesignIcons.mdSize,
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distribution.className ?? 'Lớp học',
                    style: DesignTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DesignColors.white
                          : DesignColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.xs),
                  Text(
                    _getDueDateText(distribution.dueAt),
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? DesignColors.textTertiary
                  : DesignColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getDueDateText(DateTime? dueDate) {
    if (dueDate == null) return 'Không có hạn nộp';
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    if (diff.isNegative) {
      return 'Đã hết hạn';
    } else if (diff.inDays == 0) {
      return 'Hạn hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hạn ngày mai';
    } else {
      return 'Hạn còn ${diff.inDays} ngày';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: DesignIcons.lgSize,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              label,
              style: DesignTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

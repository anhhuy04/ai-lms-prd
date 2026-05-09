import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/responsive_utils.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/providers/student_dashboard_notifier.dart';
import 'package:ai_mls/presentation/providers/student_dashboard_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/peer_comparison_badge.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/recommendation_card.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/responsive/responsive_card.dart';
import 'package:ai_mls/widgets/responsive/responsive_row.dart';
import 'package:ai_mls/widgets/responsive/responsive_text.dart';
import 'package:ai_mls/widgets/text/smart_marquee_text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget này chỉ chứa phần nội dung có thể cuộn của trang chủ sinh viên.
class StudentHomeContentScreen extends ConsumerWidget {
  const StudentHomeContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(studentDashboardNotifierProvider);
    final config = ResponsiveUtils.getLayoutConfig(context);

    return dashboardState.when(
      loading: () => const ShimmerDashboardLoading(),
      error: (error, _) =>
          Center(child: ResponsiveText('Lỗi: ${error.toString()}')),
      data: (_) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(studentDashboardNotifierProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              config.screenPadding,
              config.sectionSpacing,
              config.screenPadding,
              config.sectionSpacing + 80,
            ),
            children: [
              _buildHeader(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildProgressCard(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildPeerComparisonBadge(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildRecommendationsSection(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildStatsRow(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildSectionHeader(
                context,
                'Sắp đến hạn',
                actionLabel: 'Xem tất cả',
                onAction: () =>
                    context.pushNamed(AppRoute.studentAssignmentList),
              ),
              SizedBox(height: config.itemSpacing),
              _buildDueList(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildSectionHeader(context, 'Điểm số mới nhất'),
              SizedBox(height: config.itemSpacing),
              _buildScoresList(context, ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.value;
    final config = ResponsiveUtils.getLayoutConfig(context);

    return ResponsiveRow(
      children: [
        CircleAvatar(
          radius: DesignComponents.avatarMedium / 2,
          backgroundColor: DesignColors.primary.withValues(alpha: 0.1),
          child: ResponsiveText(
            (profile?.fullName?.isNotEmpty ?? false)
                ? profile!.fullName![0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: DesignColors.primary,
              fontWeight: FontWeight.bold,
            ),
            fontSize: 22,
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText(
                'Chào buổi sáng,',
                style: TextStyle(color: DesignColors.textSecondary),
                fontSize: DesignTypography.bodySmallSize,
              ),
              SizedBox(height: DesignSpacing.xs),
              SmartMarqueeText(
                text: profile?.fullName ?? 'Học sinh',
                style: DesignTypography.titleLarge,
              ),
            ],
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Container(
          width: DesignComponents.avatarMedium,
          height: DesignComponents.avatarMedium,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: DesignColors.dividerLight),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
            color: DesignColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, WidgetRef ref) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final progressAsync = ref.watch(studentDashboardProgressProvider);

    final progress = progressAsync.valueOrNull?.progress ?? 0.0;
    final remaining = progressAsync.valueOrNull?.remainingCount ?? 0;
    final safeProgress =
        (progress.isFinite ? progress : 0.0).clamp(0.0, 1.0);

    final motivationText = progressAsync.isLoading
        ? '...'
        : safeProgress >= 1.0
            ? 'Xuất sắc! 🎉'
            : safeProgress >= 0.7
                ? 'Rất tốt! 🚀'
                : safeProgress >= 0.4
                    ? 'Tiếp tục nào! 💪'
                    : 'Hãy cố gắng! 📚';

    final percentText = progressAsync.isLoading
        ? '...'
        : '${(safeProgress * 100).round()}%';

    final footerText = progressAsync.isLoading
        ? 'Đang tải...'
        : safeProgress >= 1.0
            ? 'Đã hoàn thành tất cả bài tập! 🎉'
            : remaining > 0
                ? 'Còn $remaining bài tập để hoàn thành mục tiêu'
                : 'Không có bài tập nào';

    return ResponsiveCard(
      padding: EdgeInsets.all(config.cardPadding + 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), DesignColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Tiến độ tổng quan',
            style: const TextStyle(color: Colors.white70),
            fontSize: DesignTypography.bodySmallSize,
          ),
          SizedBox(height: DesignSpacing.sm),
          ResponsiveRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                motivationText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ResponsiveText(
                percentText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                fontSize: DesignTypography.displayLargeSize,
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: safeProgress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: ResponsiveText(
              footerText,
              style: const TextStyle(color: Colors.white),
              fontSize: DesignTypography.bodySmallSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerComparisonBadge(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(studentClassesForAnalyticsProvider);

    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) return const SizedBox.shrink();

        final firstClass = classes.first;
        final peerAsync = ref.watch(peerComparisonProvider(firstClass.id));

        return peerAsync.when(
          data: (peer) {
            if (peer.totalStudents == 0) return const SizedBox.shrink();
            return PeerComparisonBadge(
              percentile: peer.percentile,
              classAverage: peer.classAverage,
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, WidgetRef ref) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final recsAsync = ref.watch(top3RecommendationsProvider);

    return recsAsync.when(
      data: (recs) {
        if (recs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Học tập',
              actionLabel: 'Xem tất cả',
              onAction: () =>
                  context.pushNamed(AppRoute.studentRecommendationsTab),
            ),
            SizedBox(height: config.itemSpacing),
            ...recs.take(3).map(
              (rec) => Padding(
                padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                child: RecommendationCard(
                  recommendation: rec,
                  compact: true,
                  onDismiss: null,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatsRow(BuildContext context, WidgetRef ref) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final submitted = statsAsync.valueOrNull?.submitted ?? 0;
    final pending = statsAsync.valueOrNull?.pendingGrading ?? 0;

    return ResponsiveRow(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.check_circle_outline,
            'Đã nộp',
            '$submitted',
            DesignColors.success,
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.hourglass_top_outlined,
            'Chờ chấm',
            '$pending',
            DesignColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveCard(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: DesignColors.dividerLight),
            ),
            child: Icon(icon, color: color, size: DesignIcons.smSize),
          ),
          SizedBox(height: config.itemSpacing),
          ResponsiveText(
            title,
            style: TextStyle(color: DesignColors.textSecondary),
            fontSize: DesignTypography.bodySmallSize,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: DesignComponents.avatarSmall,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ResponsiveText(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                fontSize: DesignTypography.displaySmallSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return ResponsiveRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          fontSize: DesignTypography.headlineMediumSize,
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: ResponsiveText(
              actionLabel,
              style: const TextStyle(
                color: DesignColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDueList(BuildContext context, WidgetRef ref) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final cardHeight = ResponsiveUtils.responsiveValue(
      context,
      mobile: 150.0,
      tablet: 180.0,
      desktop: 200.0,
    );
    final dueAsync = ref.watch(studentDueAssignmentsProvider);

    return dueAsync.when(
      loading: () => ShimmerHorizontalCardsLoading(height: cardHeight),
      error: (_, __) => SizedBox(
        height: cardHeight,
        child: Center(
          child: ResponsiveText(
            'Không thể tải dữ liệu',
            style: TextStyle(color: DesignColors.textSecondary),
          ),
        ),
      ),
      data: (assignments) {
        if (assignments.isEmpty) {
          return SizedBox(
            height: cardHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: DesignColors.success,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    'Không có bài tập nào sắp hết hạn',
                    style: TextStyle(color: DesignColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: assignments.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: config.itemSpacing),
            itemBuilder: (context, index) {
              final a = assignments[index];
              final title = a['title'] as String? ?? 'Bài tập';
              final dueAtStr = a['distribution_due_at'] as String?;
              final dueAt =
                  dueAtStr != null ? DateTime.tryParse(dueAtStr) : null;
              final status =
                  a['submission_status'] as String? ?? 'not_submitted';
              final distributionId = a['distribution_id'] as String?;
              return _buildDueCard(
                  context, title, status, dueAt, index, distributionId);
            },
          ),
        );
      },
    );
  }

  Widget _buildDueCard(
    BuildContext context,
    String title,
    String status,
    DateTime? dueAt,
    int index,
    String? distributionId,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);

    const cardColors = [
      Color(0xFFE3F2FD),
      Color(0xFFFFF3E0),
      Color(0xFFE8F5E9),
      Color(0xFFF3E5F5),
      Color(0xFFE0F2F1),
    ];
    final color = cardColors[index % cardColors.length];

    String timeText;
    if (dueAt == null) {
      timeText = 'Không có hạn';
    } else {
      final diff = dueAt.difference(DateTime.now());
      if (diff.isNegative) {
        timeText = 'Đã quá hạn';
      } else if (diff.inHours < 1) {
        timeText = 'Còn ${diff.inMinutes} phút';
      } else if (diff.inHours < 24) {
        timeText = 'Còn ${diff.inHours} giờ';
      } else if (diff.inDays == 1) {
        timeText = 'Ngày mai';
      } else {
        timeText = 'Còn ${diff.inDays} ngày';
      }
    }

    String statusLabel;
    switch (status) {
      case 'submitted':
        statusLabel = 'Đã nộp';
        break;
      case 'in_progress':
        statusLabel = 'Đang làm';
        break;
      default:
        statusLabel = 'Chưa làm';
    }

    return InkWell(
      onTap: () {
        if (distributionId != null) {
          context.pushNamed(
            AppRoute.studentAssignmentDetail,
            pathParameters: {'distributionId': distributionId},
          );
        }
      },
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      child: ResponsiveCard(
        padding: EdgeInsets.all(config.cardPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: SizedBox(
          width: ResponsiveUtils.responsiveValue(
            context,
            mobile: 240.0,
            tablet: 280.0,
            desktop: 320.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: DesignColors.textSecondary,
                    size: DesignIcons.smSize,
                  ),
                ],
              ),
              const Spacer(),
              ResponsiveText(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                fontSize: DesignTypography.bodyLargeSize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ResponsiveText(
                statusLabel,
                style: TextStyle(color: DesignColors.textPrimary),
                fontSize: DesignTypography.bodySmallSize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: config.itemSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: config.itemSpacing,
                  vertical: DesignSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ResponsiveText(
                  timeText,
                  style: const TextStyle(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  fontSize: DesignTypography.labelSmallSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoresList(BuildContext context, WidgetRef ref) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final scoresAsync = ref.watch(studentRecentScoresProvider);

    return scoresAsync.when(
      loading: () => const ShimmerListTileLoading(itemCount: 3),
      error: (_, __) => const SizedBox.shrink(),
      data: (scores) {
        if (scores.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(config.cardPadding),
              child: ResponsiveText(
                'Chưa có điểm nào',
                style: TextStyle(color: DesignColors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < scores.length; i++) ...[
              if (i > 0) SizedBox(height: config.itemSpacing),
              _buildScoreTile(context, scores[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildScoreTile(
    BuildContext context,
    Map<String, dynamic> score,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);

    // Nested: work_sessions → assignment_distributions → assignments
    final distData =
        score['assignment_distributions'] as Map<String, dynamic>?;
    final assignmentData =
        distData?['assignments'] as Map<String, dynamic>?;
    final title = assignmentData?['title'] as String? ?? 'Bài tập';
    final totalPoints = (assignmentData?['total_points'] as num?)?.toInt();

    final totalScore = score['total_score'] as num?;
    final scoreText =
        totalScore != null ? totalScore.toStringAsFixed(1) : '-';
    final pointsText =
        totalPoints != null ? '/$totalPoints' : '/10';

    final distributionId = distData?['id'] as String?;

    return InkWell(
      onTap: () {
        if (distributionId != null) {
          context.pushNamed(
            AppRoute.studentAssignmentDetail,
            pathParameters: {'distributionId': distributionId},
          );
        }
      },
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: ResponsiveCard(
        padding: EdgeInsets.symmetric(
          horizontal: config.itemSpacing,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: DesignColors.dividerLight),
        ),
        child: ResponsiveRow(
          children: [
            CircleAvatar(
              backgroundColor: DesignColors.warning.withValues(alpha: 0.1),
              child: const Icon(
                Icons.assignment_outlined,
                color: DesignColors.warning,
              ),
            ),
            SizedBox(width: config.itemSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    fontSize: DesignTypography.bodyLargeSize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText(
                    'Đã chấm',
                    style: TextStyle(color: Colors.grey[600]),
                    fontSize: DesignTypography.bodySmallSize,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ResponsiveText(
                  scoreText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: DesignColors.success,
                  ),
                  fontSize: DesignTypography.headlineMediumSize,
                ),
                ResponsiveText(
                  pointsText,
                  style: TextStyle(color: DesignColors.textSecondary),
                  fontSize: DesignTypography.labelSmallSize,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

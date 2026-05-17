import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment_statistics.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ass_hub/assignment_management_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Teacher Assignment Hub Screen - Tổng quan bài tập cho giáo viên
class TeacherAssignmentHubScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentHubScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentHubScreen> createState() =>
      _TeacherAssignmentHubScreenState();
}

class _TeacherAssignmentHubScreenState
    extends ConsumerState<TeacherAssignmentHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(teacherAssignmentHubNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: stateAsync.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => _buildLoading(context),
        error: (error, stack) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TeacherAssignmentHubState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = state.statistics;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Gradient overview card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg, DesignSpacing.lg, DesignSpacing.lg, 0,
              ),
              child: _buildOverviewCard(context, isDark, stats),
            ),
          ),

          // Thống kê nhanh (info only, no tap)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg, DesignSpacing.xl, DesignSpacing.lg, 0,
              ),
              child: _buildStatusSection(context, isDark, stats),
            ),
          ),

          // Quản lý bài tập (3 compact cards, tappable)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg, DesignSpacing.xl, DesignSpacing.lg, 0,
              ),
              child: _buildManagementSection(context, ref, isDark, stats),
            ),
          ),

          // Thao tác nhanh (icon grid)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg, DesignSpacing.xl, DesignSpacing.lg, DesignSpacing.xl,
              ),
              child: _buildActionsGrid(context, ref, isDark),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }


  // ── Gradient Overview Card ─────────────────────────────────────────────────

  Widget _buildOverviewCard(
    BuildContext context,
    bool isDark,
    AssignmentStatistics stats,
  ) {
    final total = stats.totalAssignments;
    // % đã publish = bài đã hoàn chỉnh / tổng số bài
    final publishedCount = total - stats.creatingCount;
    final publishedPercent = total > 0
        ? (publishedCount / total * 100).toInt()
        : 0;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.teacherAssignmentBank),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
          ),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng quan bài tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white70, size: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circle – main number
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tổng bài',
                        style: TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Side stats — chỉ dùng dữ liệu có thật từ assignments + distributions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OverviewStatRow(
                        icon: Icons.assignment_turned_in_outlined,
                        label: 'Tổng bài nộp',
                        value: stats.totalSubmissions.toString(),
                      ),
                      const SizedBox(height: 10),
                      _OverviewStatRow(
                        icon: Icons.share_outlined,
                        label: 'Đã giao lớp',
                        value: stats.distributingCount.toString(),
                      ),
                      const SizedBox(height: 10),
                      _OverviewStatRow(
                        icon: Icons.published_with_changes,
                        label: 'Đã xuất bản',
                        value: '$publishedPercent%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Thống kê nhanh (grid card) ────────────────────────────────────────────

  Widget _buildStatusSection(
    BuildContext context,
    bool isDark,
    AssignmentStatistics stats,
  ) {
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.08);
    final cardColor = isDark ? const Color(0xFF1E2A35) : Colors.white;
    const inProgressColor = Color(0xFFEA580C);

    Widget twoColRow(
      int c1, String l1, IconData i1, Color col1,
      int c2, String l2, IconData i2, Color col2,
    ) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatGridItem(
                count: c1, label: l1, icon: i1, color: col1, isDark: isDark,
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            Expanded(
              child: _StatGridItem(
                count: c2, label: l2, icon: i2, color: col2, isDark: isDark,
              ),
            ),
          ],
        ),
      );
    }

    // Top row: "Còn hạn nộp" full-width — "N bài / M lớp"
    final inProgressLabel = stats.inProgressClasses > 0
        ? '${stats.inProgress} bài / ${stats.inProgressClasses} lớp'
        : '${stats.inProgress} bài';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thống kê nhanh', style: DesignTypography.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: dividerColor, width: 1),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            child: Column(
              children: [
                // Hàng đầu: Còn hạn nộp — full width
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: inProgressColor.withValues(
                            alpha: isDark ? 0.18 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.hourglass_bottom,
                          color: inProgressColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inProgressLabel,
                            style: TextStyle(
                              color: inProgressColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Còn hạn nộp',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF617589),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                twoColRow(
                  stats.waitingToAssign, 'Chờ giao',
                  Icons.schedule, const Color(0xFF9333EA),
                  stats.totalSubmissions, 'Tổng bài nộp',
                  Icons.assignment_turned_in, const Color(0xFF2563EB),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                twoColRow(
                  stats.lateSubmissions, 'Nộp muộn',
                  Icons.warning_amber_rounded, const Color(0xFFDC2626),
                  stats.distsWithLate, 'Lớp có muộn',
                  Icons.class_, const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Quản lý bài tập ────────────────────────────────────────────────────────

  Widget _buildManagementSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AssignmentStatistics stats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quản lý bài tập', style: DesignTypography.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AssignmentManagementCard(
                label: 'Đang tạo',
                count: stats.creatingCount,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : const Color(0xFFF1F5F9),
                iconColor: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
                textColor: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF1E293B),
                icon: Icons.edit_document,
                onTap: () async {
                  await context.pushNamed(AppRoute.teacherDraftAssignments);
                  if (!mounted) return;
                  await ref
                      .read(teacherAssignmentHubNotifierProvider.notifier)
                      .refresh();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AssignmentManagementCard(
                label: 'Đã tạo',
                count: stats.totalAssignments - stats.creatingCount,
                backgroundColor: isDark
                    ? const Color(0xFF14532D).withValues(alpha: 0.4)
                    : const Color(0xFFD1FAE5),
                iconColor: isDark
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFF059669),
                textColor: isDark
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFF065F46),
                icon: Icons.assignment_outlined,
                onTap: () async {
                  await context.pushNamed(AppRoute.teacherPublishedAssignments);
                  if (!mounted) return;
                  await ref
                      .read(teacherAssignmentHubNotifierProvider.notifier)
                      .refresh();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Thao tác nhanh (icon grid) ─────────────────────────────────────────────

  Widget _buildActionsGrid(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thao tác nhanh', style: DesignTypography.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: DesignSpacing.md,
          mainAxisSpacing: DesignSpacing.md,
          childAspectRatio: 1.05,
          children: [
            _ActionCard(
              icon: Icons.add_circle_rounded,
              label: 'Tạo bài mới',
              color: DesignColors.primary,
              isDark: isDark,
              onTap: () async {
                await context.pushNamed(AppRoute.teacherCreateAssignment);
                if (!mounted) return;
                await ref
                    .read(teacherAssignmentHubNotifierProvider.notifier)
                    .refresh();
              },
            ),
            _ActionCard(
              icon: Icons.fact_check_rounded,
              label: 'Chấm bài',
              color: const Color(0xFFEA580C),
              isDark: isDark,
              onTap: () => context.pushNamed(AppRoute.teacherGrading),
            ),
            _ActionCard(
              icon: Icons.send_rounded,
              label: 'Giao bài',
              color: const Color(0xFF059669),
              isDark: isDark,
              onTap: () async {
                await context.pushNamed(AppRoute.teacherAssignmentSelection);
                if (!mounted) return;
                await ref
                    .read(teacherAssignmentHubNotifierProvider.notifier)
                    .refresh();
              },
            ),
            _ActionCard(
              icon: Icons.insights_rounded,
              label: 'Báo cáo',
              color: const Color(0xFF0EA5E9),
              isDark: isDark,
              onTap: () => context.pushNamed(AppRoute.teacherAnalyticsOverview),
            ),
          ],
        ),
      ],
    );
  }

  // ── Loading & Error ────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Container(
                          height: 70,
                          margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignRadius.lg),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Container(
                          height: 90,
                          margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignRadius.lg),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.xxxxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: DesignIcons.xxlSize,
                    color: DesignColors.error,
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Text('Có lỗi xảy ra', style: DesignTypography.titleLarge),
                  SizedBox(height: DesignSpacing.sm),
                  Text(
                    error.toString(),
                    style: DesignTypography.bodyMedium.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSpacing.xl),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(teacherAssignmentHubNotifierProvider.notifier)
                          .refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.xl,
                        vertical: DesignSpacing.md,
                      ),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _OverviewStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewStatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Item trong grid thống kê nhanh — icon + count + label.
class _StatGridItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatGridItem({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF617589),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card hành động dạng ô vuông — nền trung tính, icon màu nhỏ.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E2A35) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final radius = BorderRadius.circular(DesignRadius.lg);

    return Material(
      color: cardBg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF374151),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

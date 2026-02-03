import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ass_hub/activity_overview_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ass_hub/assignment_management_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ass_hub/assignment_statistics_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ass_hub/recent_activity_item.dart';
import 'package:ai_mls/widgets/buttons/quick_action_button.dart';
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
    // Auto-refresh khi screen được mount
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
    final statistics = state.statistics;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Header Section - Title and Notification
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? const Color(0xFF1A2632) : Colors.white,
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assignment Hub',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                ],
              ),
            ),
          ),

          // Thao tác nhanh Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                    child: Text(
                      'Thao tác nhanh',
                      style: DesignTypography.titleLarge,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                    child: Row(
                      children: [
                        QuickActionButton(
                          label: 'Tạo bài mới',
                          icon: Icons.add_circle,
                          isPrimary: true,
                          onTap: () async {
                            await context.pushNamed(
                              AppRoute.teacherCreateAssignment,
                            );
                            if (!mounted) return;
                            await ref
                                .read(
                                  teacherAssignmentHubNotifierProvider.notifier,
                                )
                                .refresh();
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Tạo bằng AI',
                          icon: Icons.auto_awesome,
                          isGradient: true,
                          onTap: () {
                            // TODO: Navigate to AI assignment creator
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Giao bài',
                          icon: Icons.send,
                          onTap: () {
                            // TODO: Navigate to assignment distribution
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Tìm bài',
                          icon: Icons.search,
                          onTap: () {
                            // Navigate to assignment list (có thể thêm search sau)
                            context.goNamed(AppRoute.teacherAssignmentList);
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Báo cáo',
                          icon: Icons.insights,
                          onTap: () {
                            // TODO: Navigate to reports
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Thư mục',
                          icon: Icons.folder_open,
                          onTap: () {
                            // TODO: Navigate to folders
                          },
                        ),
                        SizedBox(width: DesignSpacing.md),
                        QuickActionButton(
                          label: 'Cài đặt',
                          icon: Icons.settings,
                          onTap: () {
                            // Navigate to settings screen
                            context.goNamed(AppRoute.settings);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistics Cards Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AssignmentStatisticsCard(
                      label: 'Tổng số bài tập',
                      value: statistics.totalAssignments,
                      backgroundColor: isDark
                          ? const Color(0xFF1E3A5F).withValues(alpha: 0.2)
                          : const Color(0xFFDBEAFE),
                      textColor: isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF1E40AF),
                      borderColor: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: AssignmentStatisticsCard(
                      label: 'Số bài chưa chấm',
                      value: statistics.ungradedAssignments,
                      backgroundColor: isDark
                          ? const Color(0xFF7F1D1D).withValues(alpha: 0.2)
                          : const Color(0xFFFCE7F3),
                      textColor: isDark
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFBE185D),
                      borderColor: isDark
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFFFBCFE8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quản lý bài tập Section
                Padding(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý bài tập',
                        style: DesignTypography.titleLarge,
                      ),
                      SizedBox(height: DesignSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AssignmentManagementCard(
                              label: 'Đang tạo',
                              count: statistics.creatingCount,
                              backgroundColor: isDark
                                  ? const Color(
                                      0xFF1E293B,
                                    ).withValues(alpha: 0.5)
                                  : const Color(0xFFF1F5F9),
                              iconColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                              textColor: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF1E293B),
                              icon: Icons.edit_document,
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoute.teacherDraftAssignments,
                                );
                                if (!mounted) return;
                                await ref
                                    .read(
                                      teacherAssignmentHubNotifierProvider
                                          .notifier,
                                    )
                                    .refresh();
                              },
                            ),
                          ),
                          SizedBox(width: DesignSpacing.md),
                          Expanded(
                            child: AssignmentManagementCard(
                              label: 'Đã tạo',
                              count:
                                  statistics.totalAssignments -
                                  statistics.creatingCount,
                              backgroundColor: isDark
                                  ? const Color(
                                      0xFF14532D,
                                    ).withValues(alpha: 0.4)
                                  : const Color(0xFFD1FAE5),
                              iconColor: isDark
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFF059669),
                              textColor: isDark
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFF065F46),
                              icon: Icons.assignment_outlined,
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoute.teacherPublishedAssignments,
                                );
                                if (!mounted) return;
                                await ref
                                    .read(
                                      teacherAssignmentHubNotifierProvider
                                          .notifier,
                                    )
                                    .refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AssignmentManagementCard(
                              label: 'Phân phối bài tập',
                              count: statistics.distributingCount,
                              backgroundColor: isDark
                                  ? const Color(
                                      0xFF312E81,
                                    ).withValues(alpha: 0.4)
                                  : const Color(0xFFE0E7FF),
                              iconColor: isDark
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFF6366F1),
                              textColor: isDark
                                  ? const Color(0xFFE9D5FF)
                                  : const Color(0xFF312E81),
                              icon: Icons.share,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tổng quan hoạt động Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng quan hoạt động',
                            style: DesignTypography.titleLarge,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignSpacing.sm,
                              vertical: DesignSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: DesignColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                DesignRadius.full,
                              ),
                            ),
                            child: Text(
                              'Học kỳ I',
                              style: DesignTypography.caption.copyWith(
                                color: DesignColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSpacing.md),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: DesignSpacing.md,
                        mainAxisSpacing: DesignSpacing.md,
                        childAspectRatio: 1.5,
                        children: [
                          ActivityOverviewCard(
                            label: 'Chờ giao',
                            count: statistics.waitingToAssign,
                            backgroundColor: isDark
                                ? const Color(0xFF581C87).withValues(alpha: 0.4)
                                : const Color(0xFFF3E8FF),
                            iconColor: isDark
                                ? const Color(0xFFC084FC)
                                : const Color(0xFF9333EA),
                            textColor: isDark
                                ? const Color(0xFFE9D5FF)
                                : const Color(0xFF581C87),
                            icon: Icons.schedule,
                          ),
                          ActivityOverviewCard(
                            label: 'Đã giao',
                            count: statistics.assigned,
                            backgroundColor: isDark
                                ? const Color(0xFF1E3A5F).withValues(alpha: 0.4)
                                : const Color(0xFFDBEAFE),
                            iconColor: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF3B82F6),
                            textColor: isDark
                                ? const Color(0xFFDBEAFE)
                                : const Color(0xFF1E40AF),
                            icon: Icons.send,
                          ),
                          ActivityOverviewCard(
                            label: 'Đang làm',
                            count: statistics.inProgress,
                            backgroundColor: isDark
                                ? const Color(0xFF7C2D12).withValues(alpha: 0.4)
                                : const Color(0xFFFED7AA),
                            iconColor: isDark
                                ? const Color(0xFFFDBA74)
                                : const Color(0xFFEA580C),
                            textColor: isDark
                                ? const Color(0xFFFED7AA)
                                : const Color(0xFF7C2D12),
                            icon: Icons.trending_up,
                          ),
                          ActivityOverviewCard(
                            label: 'Chưa chấm',
                            count: statistics.ungraded,
                            backgroundColor: isDark
                                ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                                : const Color(0xFFFEE2E2),
                            iconColor: isDark
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFFDC2626),
                            textColor: isDark
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFF7F1D1D),
                            icon: Icons.assignment_late,
                          ),
                          ActivityOverviewCard(
                            label: 'Đã chấm',
                            count: statistics.graded,
                            backgroundColor: isDark
                                ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                                : const Color(0xFFD1FAE5),
                            iconColor: isDark
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFF059669),
                            textColor: isDark
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFF064E3B),
                            icon: Icons.check_circle,
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: DesignSpacing.lg),

                // Hoạt động gần đây Section
                Container(
                  margin: EdgeInsets.only(top: DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2632) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(DesignRadius.lg * 2),
                      topRight: Radius.circular(DesignRadius.lg * 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          DesignSpacing.lg,
                          DesignSpacing.xl,
                          DesignSpacing.lg,
                          DesignSpacing.md,
                        ),
                        child: Text(
                          'Hoạt động gần đây',
                          style: DesignTypography.titleLarge,
                        ),
                      ),
                      if (state.recentActivities.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(DesignSpacing.xxxxxl),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: DesignIcons.xxlSize,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                                SizedBox(height: DesignSpacing.md),
                                Text(
                                  'Chưa có hoạt động gần đây',
                                  style: DesignTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...state.recentActivities.map((assignment) {
                          // Get class name - simplified display
                          // TODO: Enrich with actual class name from classes table when needed
                          final className = assignment.classId != null
                              ? 'Lớp học' // Placeholder - will be enriched with actual class name
                              : 'Chưa phân lớp';

                          // Determine status based on assignment state
                          final status = _getAssignmentStatus(assignment);

                          // TODO: Get actual submission counts from submissions table when available
                          // For now, use placeholder values
                          const submittedCount = 0;
                          const totalCount = 0;

                          return RecentActivityItem(
                            assignment: assignment,
                            className: className,
                            submittedCount: submittedCount,
                            totalCount: totalCount,
                            status: status,
                            onTap: () {
                              // Navigate to assignment detail screen
                              // TODO: Add route for assignment detail when implemented
                              // context.goNamed(AppRoute.teacherAssignmentDetail,
                              //   pathParameters: {'assignmentId': assignment.id});
                            },
                          );
                        }),
                      SizedBox(height: DesignSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: const Text(
              'Assignment Hub',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: DesignSpacing.md),
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        SliverToBoxAdapter(
          child: Container(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: const Text(
              'Assignment Hub',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
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

  /// Determine assignment status based on assignment state
  String _getAssignmentStatus(Assignment assignment) {
    if (!assignment.isPublished) {
      return 'Đang tạo';
    }

    if (assignment.dueAt != null) {
      final now = DateTime.now();
      if (assignment.dueAt!.isBefore(now)) {
        return 'Quá hạn';
      }
    }

    // TODO: Check actual submission/grading status when submissions table is available
    return 'Đã giao';
  }
}

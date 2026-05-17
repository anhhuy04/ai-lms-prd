import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/providers/teacher_dashboard_notifier.dart';
import 'package:ai_mls/presentation/providers/teacher_dashboard_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/widgets/teacher_home_wide_layout.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/intervention_badge.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherHomeContentScreen extends ConsumerWidget {
  const TeacherHomeContentScreen({super.key});

  static String _classBadge(String name) {
    final trimmed = name.replaceFirst(RegExp(r'^Lớp\s+'), '');
    final first = trimmed.split(' ').first;
    return first.length > 4 ? first.substring(0, 4) : first;
  }

  static int _pendingForClass(
    List<AssignmentDistribution> dists,
    String classId,
  ) {
    int total = 0;
    for (final d in dists) {
      if (d.classId == classId) {
        final p = (d.submittedCount ?? 0) - (d.gradedCount ?? 0);
        if (p > 0) total += p;
      }
    }
    return total;
  }

  static int _totalAssignmentsForClass(
    List<AssignmentDistribution> dists,
    String classId,
  ) {
    // Đếm distributions — mỗi lần giao (cả lớp / nhóm / cá nhân) tính riêng
    return dists.where((d) => d.classId == classId).length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherDashboardClassesProvider);

    // Shimmer toàn màn hình chỉ khi chưa có dữ liệu lần đầu
    // TeacherHomeContentScreen đã nằm trong body của TeacherDashboardScreen
    // nên không cần bọc thêm Scaffold
    if (classesAsync.isLoading && !classesAsync.hasValue) {
      return const ShimmerTeacherHomeLoading();
    }

    // ── Responsive: wide screen dùng layout mới theo mẫu HTML ──
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= DesignBreakpoints.tabletSmall;

    if (isWide) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(teacherDashboardNotifierProvider.notifier).refresh(),
          child: const TeacherHomeWideLayout(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(teacherDashboardNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DesignSpacing.md),
              _buildQuickStats(context, ref),
              SizedBox(height: DesignSpacing.lg),
              _buildPriorityCard(context, ref),
              SizedBox(height: DesignSpacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                child: const Row(
                  children: [Expanded(child: InterventionBadge())],
                ),
              ),
              SizedBox(height: DesignSpacing.xxl),
              _buildSectionHeader(
                context,
                'Lớp học của tôi',
                'Xem tất cả',
                onAction: () => context.goNamed(AppRoute.teacherClassList),
              ),
              SizedBox(height: DesignSpacing.md),
              _buildClassList(context, ref),
              SizedBox(height: DesignSpacing.xxl),
              _buildSectionHeader(context, 'Bài tập sắp hết hạn', 'Xem lịch'),
              SizedBox(height: DesignSpacing.md),
              _buildUpcomingAssignments(context, ref),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final classesAsync = ref.watch(teacherDashboardClassesProvider);
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final pendingAsync = ref.watch(teacherPendingCountProvider);
    final uniqueAsync = ref.watch(teacherUniqueStudentCountProvider);

    // Hub loading → pending/unique đều return 0 ngay, không qua trạng thái loading
    if (hubAsync.isLoading || pendingAsync.isLoading || uniqueAsync.isLoading) {
      return const ShimmerQuickStatsChips();
    }

    final classes = classesAsync.valueOrNull ?? [];
    final classCount = classes.length;
    final totalFromClasses = classes.fold<int>(
      0,
      (sum, c) => sum + (c.studentCount ?? 0),
    );
    final pendingLabel =
        'Chờ chấm: ${pendingAsync.valueOrNull?.toString() ?? '_'}';
    final uniqueLabel =
        'tổng/hs thực: $totalFromClasses/${uniqueAsync.valueOrNull?.toString() ?? '_'}';

    Widget chip({
      required IconData icon,
      required Color color,
      required String label,
    }) {
      return Chip(
        avatar: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: DesignColors.dividerLight),
        ),
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => switch (i) {
          0 => chip(
            icon: Icons.assignment_late_outlined,
            color: colorScheme.primary,
            label: pendingLabel,
          ),
          1 => chip(
            icon: Icons.groups_outlined,
            color: colorScheme.secondary,
            label: uniqueLabel,
          ),
          _ => chip(
            icon: Icons.school_outlined,
            color: colorScheme.tertiary,
            label: 'Số lớp: $classCount',
          ),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildPriorityCard(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final pendingAsync = ref.watch(teacherPendingCountProvider);
    final pendingValue = pendingAsync.valueOrNull?.toString() ?? '_';
    // Hub loading → pendingAsync trả 0 ngay, cần check hub trực tiếp
    final isPendingLoading = hubAsync.isLoading || pendingAsync.isLoading;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [BoxShadow(color: DesignColors.shadowLight, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ƯU TIÊN',
                      style: TextStyle(
                        color: DesignColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bài tập cần chấm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (isPendingLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: ShimmerTextLine(width: 200, height: 16),
                  )
                else
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: DesignColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                      ),
                      children: [
                        const TextSpan(text: 'Bạn có '),
                        TextSpan(
                          text: pendingValue,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' bài nộp đang chờ duyệt.'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('Chấm ngay'),
                  // goNamed để switch tab trong ShellRoute (không push stack)
                  onPressed: () => context.pushNamed(
                    AppRoute.teacherGrading,
                    extra: {'initialFilter': GradingHubFilter.pending},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 5,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 120,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA45_xZRsDy6Jm2gT5nx3zmyuQzfpAULGoBH6EJrZwU9cHELNFm6-PrGgDHtDwiH_p_tvS1utjvKkEbTl8Md2Y1DkXwXmS4LnHuNK4Dmd320ix9yse19hA-jdpj3un6wbsVWMaOrjz5i6bzv0jDLTK_7RykfJqEmNWO0oMHM1rT_ZlRycefHkybScXcKD9Eqzj3iGuNq2mRdGLLGk9DzH9r-r2JMLk0Klg0r-IQ6I3mRC4ek65KqP-_MQAWdwLaeSTYhwsI_oCO2w',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionText, {
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildClassList(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherDashboardClassesProvider);
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final isHubLoading = hubAsync.isLoading;
    final dists = hubAsync.valueOrNull?.distributions ?? const [];

    return classesAsync.when(
      loading: () => const ShimmerAssignmentListLoading(itemCount: 3),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Không thể tải danh sách lớp',
            style: TextStyle(color: DesignColors.textSecondary),
          ),
        ),
      ),
      data: (all) {
        if (all.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chưa có lớp học nào',
                style: TextStyle(color: DesignColors.textSecondary),
              ),
            ),
          );
        }
        // Chỉ hiển thị 5 lớp mới nhất
        final display = all.take(5).toList();
        return Column(
          children: [
            for (int i = 0; i < display.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _buildClassTile(context, display[i], dists, i, isHubLoading),
            ],
          ],
        );
      },
    );
  }

  Widget _buildClassTile(
    BuildContext context,
    Class cls,
    List<AssignmentDistribution> dists,
    int index,
    bool isHubLoading,
  ) {
    const gradients = [
      LinearGradient(colors: [Colors.orange, Colors.pink]),
      LinearGradient(colors: [Colors.blue, Colors.cyan]),
      LinearGradient(colors: [Colors.green, Colors.teal]),
      LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
      LinearGradient(colors: [Colors.red, Colors.orangeAccent]),
    ];
    final gradient = gradients[index % gradients.length];
    final badge = _classBadge(cls.name);

    final studentCount = cls.studentCount ?? 0;
    final totalAssignments = _totalAssignmentsForClass(dists, cls.id);
    final pendingCount = _pendingForClass(dists, cls.id);

    // Dòng phụ: môn học • năm học
    final infoLine = [
      if (cls.subject?.isNotEmpty == true) cls.subject!,
      if (cls.academicYear?.isNotEmpty == true) cls.academicYear!,
    ].join(' • ');

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoute.teacherClassDetail,
        pathParameters: {'classId': cls.id},
        extra: {'className': cls.name, 'semesterInfo': infoLine},
      ),
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: DesignColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: DesignColors.shadowLight,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (infoLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      infoLine,
                      style: TextStyle(
                        color: DesignColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '$studentCount học sinh',
                    style: TextStyle(
                      color: DesignColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (isHubLoading)
                        const ShimmerInlineChips()
                      else ...[
                        if (totalAssignments > 0)
                          _chip(
                            '$totalAssignments bài tập',
                            DesignColors.primary,
                          ),
                        if (pendingCount > 0)
                          _chip('$pendingCount chờ chấm', DesignColors.warning)
                        else
                          _chip('Không có bài chờ', DesignColors.success),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: DesignColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildUpcomingAssignments(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final upcomingAsync = ref.watch(teacherUpcomingDistributionsProvider);
    // Hub loading → upcomingAsync trả [] ngay; check hub để hiện shimmer đúng lúc
    if (hubAsync.isLoading || upcomingAsync.isLoading) {
      return const ShimmerAssignmentListLoading(itemCount: 3);
    }
    return upcomingAsync.when(
      loading: () => const ShimmerAssignmentListLoading(itemCount: 3),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Không thể tải dữ liệu',
            style: TextStyle(color: DesignColors.textSecondary),
          ),
        ),
      ),
      data: (distributions) {
        if (distributions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Không có bài tập nào sắp hết hạn',
                style: TextStyle(color: DesignColors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < distributions.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _buildAssignmentTile(context, distributions[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAssignmentTile(
    BuildContext context,
    AssignmentDistribution dist,
  ) {
    final dueAt = dist.dueAt;
    final now = DateTime.now();
    final diff = dueAt?.difference(now);

    Color timeColor;
    String timeText;
    if (diff == null) {
      timeColor = DesignColors.textSecondary;
      timeText = 'Không có hạn';
    } else if (diff.inHours < 24) {
      timeColor = DesignColors.error;
      timeText = 'Còn ${diff.inHours}h';
    } else if (diff.inDays <= 3) {
      timeColor = DesignColors.warning;
      timeText = 'Còn ${diff.inDays} ngày';
    } else {
      timeColor = DesignColors.primary;
      timeText = 'Còn ${diff.inDays} ngày';
    }

    String dayOfWeek = '';
    String dayNum = '';
    if (dueAt != null) {
      const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      dayOfWeek = weekdays[dueAt.weekday % 7];
      dayNum = '${dueAt.day}';
    }

    final title = dist.assignmentTitle ?? 'Bài tập';
    final className = dist.className ?? 'Lớp học';
    final submitted = dist.submittedCount ?? 0;
    final total = dist.recipientCount ?? 0;
    final submissionStatus = total > 0
        ? '$submitted/$total đã nộp'
        : 'Chưa có bài nộp';

    return InkWell(
      onTap: () {
        // dist.id non-null theo entity; chỉ classId là nullable.
        if (dist.classId != null) {
          context.pushNamed(
            AppRoute.teacherAssignmentDetail,
            pathParameters: {
              'classId': dist.classId!,
              'distributionId': dist.id,
            },
            extra: {
              'assignmentTitle': dist.assignmentTitle,
              'className': dist.className,
            },
          );
        }
      },
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: DesignColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: timeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                border: Border.all(color: timeColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayOfWeek,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(
                          timeText,
                          style: TextStyle(
                            color: timeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: timeColor.withValues(alpha: 0.1),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          className,
                          style: TextStyle(
                            color: DesignColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: DesignColors.moonLight,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: TextStyle(color: DesignColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        submissionStatus,
                        style: TextStyle(
                          color: DesignColors.textSecondary,
                          fontSize: 12,
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
}

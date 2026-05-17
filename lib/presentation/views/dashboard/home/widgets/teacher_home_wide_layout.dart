import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/providers/teacher_dashboard_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/intervention_badge.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Layout 2 cột cho màn hình rộng (>= 600dp landscape / desktop).
/// Left: priority banner + class list.
/// Right: alert badge + stats widget.
class TeacherHomeWideLayout extends ConsumerWidget {
  const TeacherHomeWideLayout({super.key});

  // ── helpers ──────────────────────────────────────────────────────────────
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
    return dists.where((d) => d.classId == classId).length;
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left column ─────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriorityBanner(),
                const SizedBox(height: DesignSpacing.xl),
                _ClassListSection(),
                const SizedBox(height: DesignSpacing.xl),
                _UpcomingAssignmentsSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Right column ────────────────────────────────────────────────────
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              0,
              DesignSpacing.xl,
              DesignSpacing.xl,
              DesignSpacing.xl,
            ),
            child: Column(
              children: [
                // Urgent alert
                const InterventionBadge(),
                const SizedBox(height: DesignSpacing.lg),
                // Stats widget
                _StatsWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Priority Banner ─────────────────────────────────────────────────────────
class _PriorityBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final pendingAsync = ref.watch(teacherPendingCountProvider);
    final isPendingLoading = hubAsync.isLoading || pendingAsync.isLoading;
    final pendingValue = pendingAsync.valueOrNull?.toString() ?? '_';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [BoxShadow(color: DesignColors.shadowLight, blurRadius: 10)],
      ),
      child: Row(
        children: [
          // ── Text + action ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.xl),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (isPendingLoading)
                    const ShimmerTextLine(width: 200, height: 16)
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
                  const SizedBox(height: DesignSpacing.xl),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Chấm ngay'),
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
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Illustration ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(DesignRadius.lg),
              bottomRight: Radius.circular(DesignRadius.lg),
            ),
            child: Container(
              width: 160,
              height: 180,
              color: const Color(0xFFE0F2F1),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuA45_xZRsDy6Jm2gT5nx3zmyuQzfpAULGoBH6EJrZwU9cHELNFm6-PrGgDHtDwiH_p_tvS1utjvKkEbTl8Md2Y1DkXwXmS4LnHuNK4Dmd320ix9yse19hA-jdpj3un6wbsVWMaOrjz5i6bzv0jDLTK_7RykfJqEmNWO0oMHM1rT_ZlRycefHkybScXcKD9Eqzj3iGuNq2mRdGLLGk9DzH9r-r2JMLk0Klg0r-IQ6I3mRC4ek65KqP-_MQAWdwLaeSTYhwsI_oCO2w',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Color(0xFF0EA5A4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Class List Section ───────────────────────────────────────────────────────
class _ClassListSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherDashboardClassesProvider);
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final isHubLoading = hubAsync.isLoading;
    final dists = hubAsync.valueOrNull?.distributions ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lớp học của tôi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.goNamed(AppRoute.teacherClassList),
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSpacing.md),

        // Class grid
        classesAsync.when(
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
            final display = all.take(6).toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: 2 cột nếu đủ rộng
                final cols = constraints.maxWidth > 540 ? 2 : 1;
                return _buildClassGrid(
                  context,
                  display,
                  dists,
                  isHubLoading,
                  cols,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildClassGrid(
    BuildContext context,
    List<Class> items,
    List<AssignmentDistribution> dists,
    bool isHubLoading,
    int cols,
  ) {
    if (cols == 1) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ClassCard(
              cls: items[i],
              dists: dists,
              index: i,
              isHubLoading: isHubLoading,
            ),
          ],
        ],
      );
    }
    // 2-column grid
    final rows = (items.length / 2).ceil();
    return Column(
      children: [
        for (int r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ClassCard(
                  cls: items[r * 2],
                  dists: dists,
                  index: r * 2,
                  isHubLoading: isHubLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: r * 2 + 1 < items.length
                    ? _ClassCard(
                        cls: items[r * 2 + 1],
                        dists: dists,
                        index: r * 2 + 1,
                        isHubLoading: isHubLoading,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Class cls;
  final List<AssignmentDistribution> dists;
  final int index;
  final bool isHubLoading;

  const _ClassCard({
    required this.cls,
    required this.dists,
    required this.index,
    required this.isHubLoading,
  });

  static const _gradients = [
    LinearGradient(colors: [Colors.orange, Colors.pink]),
    LinearGradient(colors: [Colors.blue, Colors.cyan]),
    LinearGradient(colors: [Colors.green, Colors.teal]),
    LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
    LinearGradient(colors: [Colors.red, Colors.orangeAccent]),
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    final badge = TeacherHomeWideLayout._classBadge(cls.name);
    final studentCount = cls.studentCount ?? 0;
    final totalAssignments = TeacherHomeWideLayout._totalAssignmentsForClass(
      dists,
      cls.id,
    );
    final pendingCount = TeacherHomeWideLayout._pendingForClass(dists, cls.id);
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
        padding: const EdgeInsets.all(DesignSpacing.lg),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (infoLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      infoLine,
                      style: TextStyle(
                        color: DesignColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '$studentCount học sinh',
                    style: TextStyle(
                      color: DesignColors.textSecondary,
                      fontSize: 13,
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
}

// ── Stats Widget ─────────────────────────────────────────────────────────────
class _StatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherDashboardClassesProvider);
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final pendingAsync = ref.watch(teacherPendingCountProvider);
    final uniqueAsync = ref.watch(teacherUniqueStudentCountProvider);

    final classes = classesAsync.valueOrNull ?? [];
    final classCount = classes.length;
    final totalFromClasses = classes.fold<int>(
      0,
      (sum, c) => sum + (c.studentCount ?? 0),
    );
    final pending = pendingAsync.valueOrNull ?? 0;
    final unique = uniqueAsync.valueOrNull ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [BoxShadow(color: DesignColors.shadowLight, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG QUAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: DesignColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSpacing.md),
          _statItem(
            icon: Icons.assignment_late_outlined,
            color: DesignColors.primary,
            label: 'Chờ chấm',
            value: (hubAsync.isLoading || pendingAsync.isLoading)
                ? '...'
                : '$pending',
          ),
          const SizedBox(height: DesignSpacing.sm),
          _statItem(
            icon: Icons.groups_outlined,
            color: Colors.purple,
            label: 'Tổng/hs thực',
            value: (hubAsync.isLoading || uniqueAsync.isLoading)
                ? '...'
                : '$totalFromClasses/$unique',
          ),
          const SizedBox(height: DesignSpacing.sm),
          _statItem(
            icon: Icons.school_outlined,
            color: Colors.orange,
            label: 'Số lớp',
            value: classesAsync.isLoading ? '...' : '$classCount',
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DesignColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Assignments Section ────────────────────────────────────────────
class _UpcomingAssignmentsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(teacherAssignmentHubNotifierProvider);
    final upcomingAsync = ref.watch(teacherUpcomingDistributionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài tập sắp hết hạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: null,
              child: Text(
                'Xem lịch',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSpacing.md),

        // List
        if (hubAsync.isLoading || upcomingAsync.isLoading)
          const ShimmerAssignmentListLoading(itemCount: 3)
        else
          upcomingAsync.when(
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
                    _UpcomingAssignmentTile(dist: distributions[i]),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }
}

class _UpcomingAssignmentTile extends StatelessWidget {
  final AssignmentDistribution dist;
  const _UpcomingAssignmentTile({required this.dist});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(DesignSpacing.md),
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
            // Date badge
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
                          style: const TextStyle(
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

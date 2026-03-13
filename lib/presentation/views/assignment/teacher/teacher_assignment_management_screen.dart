import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Assignment Management Screen - Quản lý bài tập
/// Hiển thị danh sách bài tập với các action buttons để điều hướng
class TeacherAssignmentManagementScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentManagementScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentManagementScreen> createState() =>
      _TeacherAssignmentManagementScreenState();
}

class _TeacherAssignmentManagementScreenState
    extends ConsumerState<TeacherAssignmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(teacherAssignmentHubNotifierProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản lý bài tập',
          style: TextStyle(
            color: DesignColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignColors.primary,
          unselectedLabelColor: DesignColors.textTertiary,
          indicatorColor: DesignColors.primary,
          tabs: const [
            Tab(text: 'Đang tạo'),
            Tab(text: 'Đã tạo'),
            Tab(text: 'Đã giao'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: hubState.when(
        data: (state) => TabBarView(
          controller: _tabController,
          children: [
            _buildAssignmentList(
              state.assignments.where((a) => !a.isPublished).toList(),
              state.distributions,
              emptyMessage: 'Chưa có bài tập nào đang tạo',
            ),
            _buildAssignmentList(
              state.assignments.where((a) => a.isPublished).toList(),
              state.distributions,
              emptyMessage: 'Chưa có bài tập đã xuất bản',
            ),
            _buildDistributionList(state.distributions),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: DesignColors.error,
              ),
              const SizedBox(height: DesignSpacing.md),
              Text('Lỗi: $error'),
              const SizedBox(height: DesignSpacing.md),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(teacherAssignmentHubNotifierProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build list of assignments (draft/published)
  Widget _buildAssignmentList(
    List<Assignment> assignments,
    List<AssignmentDistribution> distributions, {
    required String emptyMessage,
  }) {
    if (assignments.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSpacing.md),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final relatedDistributions = distributions
            .where((d) => d.assignmentId == assignment.id)
            .toList();

        return _AssignmentCard(
          assignment: assignment,
          distributions: relatedDistributions,
        );
      },
    );
  }

  /// Build list of distributions (đã giao cho các lớp)
  Widget _buildDistributionList(List<AssignmentDistribution> distributions) {
    if (distributions.isEmpty) {
      return _buildEmptyState('Chưa có bài tập nào được giao cho lớp');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSpacing.md),
      itemCount: distributions.length,
      itemBuilder: (context, index) {
        final distribution = distributions[index];
        return _DistributionCard(distribution: distribution);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: DesignColors.textTertiary,
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            message,
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card hiển thị thông tin assignment với các action buttons
class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final List<AssignmentDistribution> distributions;

  const _AssignmentCard({
    required this.assignment,
    required this.distributions,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = !assignment.isPublished;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: DesignTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDraft
                        ? DesignColors.warning.withValues(alpha: 0.1)
                        : DesignColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    isDraft ? 'Bản nháp' : 'Đã xuất bản',
                    style: DesignTypography.labelSmall.copyWith(
                      color: isDraft
                          ? DesignColors.warning
                          : DesignColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.sm),

            // Description
            if (assignment.description != null &&
                assignment.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignSpacing.sm),
                child: Text(
                  assignment.description!,
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Info row
            Row(
              children: [
                if (assignment.dueAt != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: DesignColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hạn: ${_formatDate(assignment.dueAt!)}',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textTertiary,
                    ),
                  ),
                ],
                const Spacer(),
                if (assignment.totalPoints != null)
                  Text(
                    '${assignment.totalPoints!.toStringAsFixed(0)} điểm',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDraft = !assignment.isPublished;

    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: [
        // Xem chi tiết
        _ActionButton(
          icon: Icons.visibility,
          label: 'Xem',
          color: DesignColors.primary,
          onTap: () {
            context.pushNamed(
              AppRoute.teacherCreateAssignment,
              extra: {'assignmentId': assignment.id},
            );
          },
        ),

        // Giao bài (nếu đã publish)
        if (isDraft)
          _ActionButton(
            icon: Icons.send,
            label: 'Giao',
            color: DesignColors.tealPrimary,
            onTap: () {
              context.pushNamed(
                AppRoute.teacherAssignmentSelection,
                extra: {'assignmentId': assignment.id},
              );
            },
          ),

        // Danh sách nộp (nếu đã giao cho lớp)
        if (distributions.isNotEmpty)
          _ActionButton(
            icon: Icons.assignment,
            label: 'Danh sách nộp',
            color: DesignColors.info,
            onTap: () {
              // Đi đến trang danh sách nộp của distribution đầu tiên
              context.pushNamed(
                AppRoute.teacherSubmissionList,
                pathParameters: {'distributionId': distributions.first.id},
              );
            },
          ),

        // Chấm bài (nếu đã giao)
        if (distributions.isNotEmpty)
          _ActionButton(
            icon: Icons.grade,
            label: 'Chấm bài',
            color: DesignColors.success,
            onTap: () {
              // Đi đến trang danh sách nộp (grading)
              context.pushNamed(
                AppRoute.teacherSubmissionList,
                pathParameters: {'distributionId': distributions.first.id},
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Card hiển thị thông tin distribution (đã giao cho lớp)
class _DistributionCard extends StatelessWidget {
  final AssignmentDistribution distribution;

  const _DistributionCard({required this.distribution});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSpacing.sm),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: DesignColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distribution.className ?? 'Lớp học',
                        style: DesignTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (distribution.groupName != null)
                        Text(
                          distribution.groupName!,
                          style: DesignTypography.bodySmall.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    'Đã giao',
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),

            // Stats
            Row(
              children: [
                _StatItem(
                  icon: Icons.people,
                  label: 'HS',
                  value: '${distribution.recipientCount ?? 0}',
                ),
                const SizedBox(width: DesignSpacing.lg),
                _StatItem(
                  icon: Icons.assignment_turned_in,
                  label: 'Nộp',
                  value: '${distribution.submittedCount ?? 0}',
                ),
                const SizedBox(width: DesignSpacing.lg),
                _StatItem(
                  icon: Icons.grade,
                  label: 'Chấm',
                  value: '${distribution.gradedCount ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),

            // Action buttons
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
              children: [
                _ActionButton(
                  icon: Icons.assignment,
                  label: 'Danh sách nộp',
                  color: DesignColors.info,
                  onTap: () {
                    context.pushNamed(
                      AppRoute.teacherSubmissionList,
                      pathParameters: {'distributionId': distribution.id},
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.grade,
                  label: 'Chấm bài',
                  color: DesignColors.success,
                  onTap: () {
                    context.pushNamed(
                      AppRoute.teacherSubmissionList,
                      pathParameters: {'distributionId': distribution.id},
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: DesignTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: DesignColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: DesignTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Class Selection Screen - Chọn lớp để xem bài nộp
/// Hiển thị danh sách các lớp đã giao bài tập với stats
class TeacherClassSubmissionListScreen extends ConsumerWidget {
  final String assignmentId;
  final String assignmentTitle;

  const TeacherClassSubmissionListScreen({
    super.key,
    required this.assignmentId,
    this.assignmentTitle = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubState = ref.watch(teacherAssignmentHubNotifierProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          assignmentTitle.isNotEmpty ? assignmentTitle : 'Chọn lớp',
          style: const TextStyle(
            color: DesignColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: hubState.when(
        data: (state) {
          // Lọc distributions của assignment này
          final distributions = state.distributions
              .where((d) => d.assignmentId == assignmentId)
              .toList();

          if (distributions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(DesignSpacing.md),
            itemCount: distributions.length,
            itemBuilder: (context, index) {
              final distribution = distributions[index];
              return _ClassSubmissionCard(
                distribution: distribution,
                onTap: () {
                  context.pushNamed(
                    AppRoute.teacherSubmissionList,
                    pathParameters: {'distributionId': distribution.id},
                    extra: {
                      'assignmentTitle': assignmentTitle,
                      'className': distribution.className,
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error, ref),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: DesignColors.textTertiary,
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Chưa giao bài tập cho lớp nào',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Center(
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
    );
  }
}

/// Card hiển thị thông tin lớp với stats bài nộp
class _ClassSubmissionCard extends StatelessWidget {
  final AssignmentDistribution distribution;
  final VoidCallback onTap;

  const _ClassSubmissionCard({
    required this.distribution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Stats từ distribution (cần be đã có sẵn từ provider)
    final totalStudents = distribution.recipientCount ?? 0;
    final submittedCount = distribution.submittedCount ?? 0;
    final gradedCount = distribution.gradedCount ?? 0;
    final lateCount = distribution.lateCount ?? 0;
    final notSubmittedCount = totalStudents - submittedCount;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.md),
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
                      size: 24,
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
                  Icon(
                    Icons.chevron_right,
                    color: DesignColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.md),

              // Stats Row
              Row(
                children: [
                  _StatChip(
                    label: 'Tất cả',
                    count: totalStudents,
                    color: DesignColors.primary,
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  _StatChip(
                    label: 'Đã nộp',
                    count: submittedCount,
                    color: DesignColors.success,
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  _StatChip(
                    label: 'Chưa nộp',
                    count: notSubmittedCount,
                    color: DesignColors.warning,
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  _StatChip(
                    label: 'Nộp muộn',
                    count: lateCount,
                    color: DesignColors.error,
                  ),
                ],
              ),

              // Progress bar
              if (totalStudents > 0) ...[
                const SizedBox(height: DesignSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                  child: LinearProgressIndicator(
                    value: submittedCount / totalStudents,
                    backgroundColor: DesignColors.dividerLight,
                    color: DesignColors.success,
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip hiển thị số liệu stats
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: DesignTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: DesignTypography.labelSmall.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

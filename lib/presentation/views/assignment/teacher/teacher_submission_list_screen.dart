import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/submission_filter_chips.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Teacher Submission List Screen - ATC Dashboard
/// Hiển thị danh sách submissions với "Air Traffic Control" model
class TeacherSubmissionListScreen extends ConsumerStatefulWidget {
  final String distributionId;
  final String? classId;
  final String assignmentTitle;
  final String? className;

  const TeacherSubmissionListScreen({
    super.key,
    required this.distributionId,
    this.classId,
    this.assignmentTitle = '',
    this.className,
  });

  @override
  ConsumerState<TeacherSubmissionListScreen> createState() =>
      _TeacherSubmissionListScreenState();
}

class _TeacherSubmissionListScreenState
    extends ConsumerState<TeacherSubmissionListScreen> {
  SubmissionFilter _currentFilter = SubmissionFilter.all;

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(teacherSubmissionListProvider(
      distributionId: widget.distributionId,
      filter: _currentFilter,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bài nộp'),
        actions: [
          // Nút xuất bản điểm - Stage Curtain
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: 'Xuất bản điểm',
            onPressed: () => _showPublishDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SubmissionFilterChips(
            currentFilter: _currentFilter,
            onFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
            },
          ),

          // AI Loading indicator
          submissionState.when(
            data: (state) {
              if (state.isLoadingAi) {
                return Container(
                  padding: const EdgeInsets.all(DesignSpacing.sm),
                  color: DesignColors.warning.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DesignColors.warning,
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.sm),
                      Text(
                        'AI đang phân tích...',
                        style: DesignTypography.caption?.copyWith(
                          color: DesignColors.warning,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Submission list
          Expanded(
            child: submissionState.when(
              data: (state) {
                if (state.submissions.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(teacherSubmissionListProvider(
                      distributionId: widget.distributionId,
                      filter: _currentFilter,
                    ));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    itemCount: state.submissions.length,
                    itemBuilder: (context, index) {
                      final submission = state.submissions[index];
                      return SubmissionListItem(
                        submission: submission,
                        onTap: () {
                          context.pushNamed(
                            'teacher-grade-submission',
                            pathParameters: {
                              'submissionId': submission.submissionId,
                            },
                            extra: {
                              'distributionId': widget.distributionId,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: DesignColors.error,
                    ),
                    const SizedBox(height: DesignSpacing.md),
                    Text(
                      'Lỗi tải danh sách',
                      style: DesignTypography.bodyMedium,
                    ),
                    const SizedBox(height: DesignSpacing.sm),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(teacherSubmissionListProvider(
                          distributionId: widget.distributionId,
                          filter: _currentFilter,
                        ));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Nút xuất bản điểm toàn lớp
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPublishDialog(context),
        icon: const Icon(Icons.publish),
        label: const Text('Xuất bản điểm'),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Chưa có bài nộp nào',
            style: DesignTypography.titleMedium?.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Học sinh chưa nộp bài',
            style: DesignTypography.bodyMedium?.copyWith(
              color: DesignColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất bản điểm'),
        content: const Text(
          'Sau khi xuất bản, học sinh sẽ nhìn thấy điểm số. '
          'Bạn có chắc chắn muốn xuất bản?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(submissionGradingNotifierProvider.notifier)
                  .publishAllGrades(widget.distributionId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xuất bản điểm thành công'),
                  ),
                );
              }
            },
            child: const Text('Xuất bản'),
          ),
        ],
      ),
    );
  }
}

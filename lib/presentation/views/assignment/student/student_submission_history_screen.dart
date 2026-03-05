import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Màn hình lịch sử nộp bài của học sinh
class StudentSubmissionHistoryScreen extends ConsumerWidget {
  const StudentSubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(studentSubmissionHistoryProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: DesignColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: DesignIcons.smSize),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lịch sử nộp bài',
          style: TextStyle(
            fontSize: DesignTypography.bodyMediumSize,
            fontWeight: DesignTypography.bold,
            color: DesignColors.textPrimary,
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const ShimmerLoading(),
        error: (error, _) => _buildErrorState(context, error),
        data: (history) => _buildBody(context, ref, history),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Lỗi khi tải lịch sử',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> history,
  ) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSpacing.md),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final submission = history[index];
        return _buildSubmissionCard(context, submission);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Chưa có lịch sử nộp bài',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Bạn chưa nộp bài tập nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, Map<String, dynamic> submission) {
    // Extract data from submission
    final distribution = submission['assignment_distributions'] as Map<String, dynamic>?;
    final assignment = distribution?['assignments'] as Map<String, dynamic>?;
    final status = submission['status'] as String? ?? 'draft';
    final score = submission['score'] as num?;
    final submittedAt = submission['submitted_at'] as String?;
    final gradedAt = submission['graded_at'] as String?;

    final title = assignment?['title'] as String? ?? 'Bài tập';
    final description = assignment?['description'] as String?;

    DateTime? submittedDateTime;
    if (submittedAt != null) {
      submittedDateTime = DateTime.tryParse(submittedAt);
    }

    DateTime? gradedDateTime;
    if (gradedAt != null) {
      gradedDateTime = DateTime.tryParse(gradedAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  Icons.assignment,
                  color: DesignColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.textPrimary,
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),

          const SizedBox(height: DesignSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: DesignSpacing.md),

          // Info rows
          if (submittedDateTime != null)
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Nộp lúc',
              value: _formatDateTime(submittedDateTime),
            ),

          if (gradedDateTime != null) ...[
            const SizedBox(height: DesignSpacing.sm),
            _buildInfoRow(
              icon: Icons.grade,
              label: 'Ngày chấm',
              value: _formatDateTime(gradedDateTime),
            ),
          ],

          if (score != null) ...[
            const SizedBox(height: DesignSpacing.md),
            Container(
              padding: const EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: _getScoreColor(score).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: _getScoreColor(score),
                    size: 24,
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  Text(
                    'Điểm số: ${score.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'submitted':
        color = Colors.blue;
        label = 'Đã nộp';
        icon = Icons.send;
        break;
      case 'graded':
        color = Colors.green;
        label = 'Đã chấm';
        icon = Icons.check_circle;
        break;
      case 'draft':
        color = Colors.orange;
        label = 'Nháp';
        icon = Icons.edit_note;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: DesignSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(num score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

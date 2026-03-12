import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:flutter/material.dart';

/// Item widget cho submission list - ATC Dashboard
class SubmissionListItem extends StatelessWidget {
  final TeacherSubmissionItem submission;
  final VoidCallback? onTap;

  const SubmissionListItem({
    super.key,
    required this.submission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.md),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: DesignColors.primary.withValues(alpha: 0.1),
                backgroundImage: submission.studentAvatarUrl != null
                    ? NetworkImage(submission.studentAvatarUrl!)
                    : null,
                child: submission.studentAvatarUrl == null
                    ? Text(
                        _getInitials(submission.studentName),
                        style: DesignTypography.bodyMedium?.copyWith(
                          color: DesignColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: DesignSpacing.md),

              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            submission.studentName,
                            style: DesignTypography.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge nộp muộn
                        if (submission.isLate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: DesignColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DesignRadius.sm),
                            ),
                            child: Text(
                              'Nộp muộn',
                              style: DesignTypography.labelSmall?.copyWith(
                                color: DesignColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: DesignSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: DesignColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(submission.submittedAt),
                          style: DesignTypography.bodySmall?.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // AI indicator
                        if (!submission.aiGraded && submission.status == 'submitted')
                          _buildAiLoadingIndicator()
                        else
                          _buildScoreIndicator(),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: DesignColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: DesignColors.warning,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'AI đang phân tích...',
          style: DesignTypography.bodySmall?.copyWith(
            color: DesignColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator() {
    final hasScore = submission.totalScore != null;
    final isGraded = submission.status == 'graded';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isGraded
            ? DesignColors.success.withValues(alpha: 0.1)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasScore)
            Text(
              '${submission.totalScore!.toStringAsFixed(1)}',
              style: DesignTypography.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isGraded ? DesignColors.success : const Color(0xFF616161),
              ),
            )
          else
            Text(
              '—',
              style: DesignTypography.bodyMedium?.copyWith(
                color: DesignColors.textTertiary,
              ),
            ),
          if (submission.maxScore != null)
            Text(
              '/ ${submission.maxScore!.toStringAsFixed(0)}',
              style: DesignTypography.bodySmall?.copyWith(
                color: DesignColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

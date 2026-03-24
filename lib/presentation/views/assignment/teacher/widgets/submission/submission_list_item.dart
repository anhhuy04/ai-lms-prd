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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: submission.studentAvatarUrl == null
                      ? const LinearGradient(
                          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  image: submission.studentAvatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(submission.studentAvatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: submission.studentAvatarUrl == null
                    ? Center(
                        child: Text(
                          _getInitials(submission.studentName),
                          style: DesignTypography.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                        // Chấm điểm status
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
            : DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasScore)
            Text(
              submission.totalScore!.toStringAsFixed(1),
              style: DesignTypography.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isGraded ? DesignColors.success : DesignColors.textSecondary,
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

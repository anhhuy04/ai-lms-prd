import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị recent activity item
/// Teacher-specific widget cho assignment hub screen
class RecentActivityItem extends StatelessWidget {
  final Assignment assignment;
  final String className;
  final int submittedCount;
  final int totalCount;
  final String status;
  final VoidCallback? onTap;

  const RecentActivityItem({
    super.key,
    required this.assignment,
    required this.className,
    required this.submittedCount,
    required this.totalCount,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalCount > 0 ? submittedCount / totalCount : 0.0;
    final statusInfo = _getStatusInfo(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        margin: EdgeInsets.only(bottom: DesignSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A3844) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: isDark
                ? Colors.grey[700]!
                : const Color(0xFFF0F2F4),
            width: 1,
          ),
          boxShadow: [DesignElevation.level1],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: DesignTypography.bodyLarge.copyWith(
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        '$className • Hạn nộp: ${_formatDueDate(assignment.dueAt)}',
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF617589),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo['backgroundColor'],
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    statusInfo['label'] as String,
                    style: DesignTypography.caption.copyWith(
                      color: statusInfo['textColor'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: DesignIcons.xsSize,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF617589),
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        '$submittedCount/$totalCount Đã nộp',
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF617589),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.pie_chart,
                        size: DesignIcons.xsSize,
                        color: DesignColors.primary,
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        'Tiến độ: ${(progress * 100).toInt()}%',
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress < 1.0 && totalCount > 0) ...[
              SizedBox(height: DesignSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? Colors.grey[700]
                      : const Color(0xFFF0F2F4),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'cần chấm':
        return {
          'label': 'Cần chấm',
          'backgroundColor': const Color(0xFFFEE2E2).withValues(alpha: 0.4),
          'textColor': const Color(0xFFDC2626),
        };
      case 'đang chấm':
        return {
          'label': 'Đang chấm',
          'backgroundColor': const Color(0xFFFED7AA).withValues(alpha: 0.4),
          'textColor': const Color(0xFFEA580C),
        };
      default:
        return {
          'label': status,
          'backgroundColor': Colors.grey.withValues(alpha: 0.1),
          'textColor': Colors.grey[700]!,
        };
    }
  }

  String _formatDueDate(DateTime? dueAt) {
    if (dueAt == null) return 'Chưa có hạn';
    
    final now = DateTime.now();
    final difference = dueAt.difference(now);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == -1) {
      return 'Hôm qua';
    } else if (difference.inDays < 0) {
      return 'Quá hạn';
    } else if (difference.inDays == 1) {
      return 'Ngày mai';
    } else {
      // Format date manually: dd/MM/yyyy
      final day = dueAt.day.toString().padLeft(2, '0');
      final month = dueAt.month.toString().padLeft(2, '0');
      final year = dueAt.year.toString();
      return '$day/$month/$year';
    }
  }
}

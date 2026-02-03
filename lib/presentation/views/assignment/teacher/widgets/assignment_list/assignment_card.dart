import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable card widget để hiển thị assignment trong list
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final AssignmentBadgeConfig badgeConfig;
  final AssignmentActionConfig actionConfig;
  final AssignmentMetadataConfig metadataConfig;
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.badgeConfig,
    required this.actionConfig,
    required this.metadataConfig,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(DesignRadius.lg * 1.5);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap:
            onTap ??
            () {
              context.pushNamed(
                AppRoute.teacherCreateAssignment,
                extra: {'assignmentId': assignment.id},
              );
            },
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với title và badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: DesignTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeConfig.backgroundColor,
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                      border: Border.all(color: badgeConfig.borderColor),
                    ),
                    child: Text(
                      badgeConfig.label,
                      style: DesignTypography.caption.copyWith(
                        color: badgeConfig.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (assignment.description != null &&
                  assignment.description!.isNotEmpty) ...[
                SizedBox(height: DesignSpacing.sm),
                Text(
                  assignment.description!,
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: DesignSpacing.md),

              // Metadata row
              _buildMetadataRow(isDark),

              SizedBox(height: DesignSpacing.sm),

              // Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: actionConfig.onPressed,
                    icon: Icon(
                      actionConfig.icon,
                      size: 18,
                      color: DesignColors.primary,
                    ),
                    label: Text(
                      actionConfig.label,
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(bool isDark) {
    return Row(
      children: [
        if (metadataConfig.showPoints && assignment.totalPoints != null) ...[
          Icon(
            Icons.star_outline,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          SizedBox(width: DesignSpacing.xs),
          Flexible(
            child: Text(
              '${assignment.totalPoints} điểm',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
        ],
        if (metadataConfig.showDueDate && assignment.dueAt != null) ...[
          Icon(
            Icons.calendar_today,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          SizedBox(width: DesignSpacing.xs),
          Flexible(
            child: Text(
              AssignmentDateFormatter.formatDueDate(assignment.dueAt!),
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
        ],
        if (metadataConfig.showLastUpdated) ...[
          Icon(
            Icons.access_time,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          SizedBox(width: DesignSpacing.xs),
          Flexible(
            child: Text(
              AssignmentDateFormatter.formatLastUpdated(
                assignment.updatedAt ?? assignment.createdAt,
              ),
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

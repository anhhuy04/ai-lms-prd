import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'class_status_badge.dart';

/// Widget hiển thị một item lớp học trong danh sách
/// Được sử dụng trong ClassListScreen và có thể các màn hình khác
class ClassItemWidget extends StatelessWidget {
  final String className;
  final String roomInfo;
  final String schedule;
  final int studentCount;
  final int? ungradedCount;
  final String iconName;
  final Color iconColor;
  final VoidCallback onTap;
  final bool hasAssignments;

  const ClassItemWidget({
    super.key,
    required this.className,
    required this.roomInfo,
    required this.schedule,
    required this.studentCount,
    this.ungradedCount,
    required this.iconName,
    required this.iconColor,
    required this.onTap,
    this.hasAssignments = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSpacing.md),
        decoration: BoxDecoration(
          // color: Theme.of(context).cardColor,
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [DesignElevation.level2],
        ),
        child: Column(
          children: [
            // Phần thông tin chính của lớp
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  // Icon loại lớp
                  Container(
                    width: DesignIcons.lgSize,
                    height: DesignIcons.lgSize,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      size: DesignIcons.mdSize,
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  // Thông tin lớp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: DesignTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Text(
                          '$roomInfo - $schedule',
                          style: DesignTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Icon mũi tên
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: DesignIcons.mdSize,
                  ),
                ],
              ),
            ),
            // Đường phân cách
            Divider(
              height: 1,
              color: Colors.grey[200],
              indent: DesignSpacing.lg,
              endIndent: DesignSpacing.lg,
            ),
            // Phần footer với thống kê
            Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg,
                DesignSpacing.md,
                DesignSpacing.lg,
                DesignSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Số học sinh
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        size: DesignIcons.smSize,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: DesignSpacing.sm),
                      Text(
                        '$studentCount',
                        style: DesignTypography.labelMedium,
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text('Học sinh', style: DesignTypography.caption),
                    ],
                  ),
                  // Trạng thái lớp
                  ClassStatusBadge(
                    ungradedCount: ungradedCount,
                    hasAssignments: hasAssignments,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chuyển đổi tên icon từ string sang IconData
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'meeting_room':
        return Icons.meeting_room;
      default:
        return Icons.class_;
    }
  }
}

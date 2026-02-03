import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../text/smart_highlight_text.dart';
import 'class_status_badge.dart';

/// Widget hiển thị một item lớp học trong danh sách
/// Được sử dụng trong ClassListScreen và có thể các màn hình khác
/// Hỗ trợ highlight text khi có searchQuery (dùng cho search screens)
class ClassItemWidget extends StatelessWidget {
  final String className;
  final String roomInfo;
  final String schedule;
  final int studentCount;
  final int? ungradedCount;
  final String? teacherName;
  final String? memberStatus;
  final String iconName;
  final Color iconColor;
  final VoidCallback onTap;
  final bool hasAssignments;
  final String? searchQuery; // Optional: để highlight text khi tìm kiếm
  final Color? highlightColor; // Optional: màu highlight (mặc định: blue)

  const ClassItemWidget({
    super.key,
    required this.className,
    required this.roomInfo,
    required this.schedule,
    required this.studentCount,
    this.ungradedCount,
    this.teacherName,
    this.memberStatus,
    required this.iconName,
    required this.iconColor,
    required this.onTap,
    this.hasAssignments = true,
    this.searchQuery,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final hasSearchQuery = searchQuery != null && searchQuery!.isNotEmpty;
    final query = searchQuery ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [DesignElevation.level2],
        ),
        child: Column(
          children: [
            // Phần thông tin chính của lớp
            Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Row(
                children: [
                  // Icon loại lớp
                  Container(
                    width: DesignIcons.lgSize,
                    height: DesignIcons.lgSize,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      size: DesignIcons.mdSize,
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  // Thông tin lớp - hiển thị môn học và kỳ học riêng biệt
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên lớp - với highlight nếu có searchQuery
                        hasSearchQuery
                            ? SmartHighlightText(
                                fullText: className,
                                query: query,
                                style: DesignTypography.titleMedium,
                                highlightColor: highlightColor ?? Colors.blue,
                              )
                            : Text(
                                className,
                                style: DesignTypography.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        // Tên giáo viên (nếu có) hiển thị ngay dưới tên lớp - với highlight nếu có searchQuery
                        if (teacherName != null && teacherName!.isNotEmpty) ...[
                          SizedBox(height: spacing.xs),
                          hasSearchQuery
                              ? Row(
                                  children: [
                                    Text(
                                      'GV: ',
                                      style: DesignTypography.bodySmall
                                          .copyWith(color: Colors.grey[700]),
                                    ),
                                    Expanded(
                                      child: SmartHighlightText(
                                        fullText: teacherName!,
                                        query: query,
                                        style: DesignTypography.bodySmall
                                            .copyWith(color: Colors.grey[700]),
                                        highlightColor:
                                            highlightColor ?? Colors.blue,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'GV: ${teacherName!}',
                                  style: DesignTypography.bodySmall.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ],
                        SizedBox(height: spacing.xs),
                        // Môn học - chỉ highlight phần giá trị, không highlight label
                        if (roomInfo.isNotEmpty)
                          hasSearchQuery
                              ? Row(
                                  children: [
                                    Text(
                                      'Môn: ',
                                      style: DesignTypography.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    Expanded(
                                      child: SmartHighlightText(
                                        fullText: roomInfo,
                                        query: query,
                                        style: DesignTypography.bodySmall
                                            .copyWith(color: Colors.grey[600]),
                                        highlightColor:
                                            highlightColor ?? Colors.blue,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Môn: $roomInfo',
                                  style: DesignTypography.bodySmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        // Học kỳ - không highlight khi tìm kiếm
                        if (schedule.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Học kỳ: $schedule',
                            style: DesignTypography.bodySmall.copyWith(
                              color: Colors.blueGrey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
              indent: spacing.lg,
              endIndent: spacing.lg,
            ),
            // Phần footer với thống kê
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.lg,
                spacing.md,
                spacing.lg,
                spacing.md,
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
                      SizedBox(width: spacing.sm),
                      Text(
                        '$studentCount',
                        style: DesignTypography.labelMedium,
                      ),
                      SizedBox(width: spacing.xs),
                      Text('Học sinh', style: DesignTypography.caption),
                    ],
                  ),
                  // Trạng thái lớp
                  ClassStatusBadge(
                    ungradedCount: ungradedCount,
                    hasAssignments: hasAssignments,
                    memberStatus: memberStatus,
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

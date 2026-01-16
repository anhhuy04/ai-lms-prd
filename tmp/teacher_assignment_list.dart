import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Widget hiển thị danh sách bài tập cho giáo viên
/// Thiết kế theo chuẩn mới với trạng thái rõ ràng
class TeacherAssignmentList extends StatelessWidget {
  final List<Map<String, dynamic>> assignments;

  const TeacherAssignmentList({
    super.key,
    required this.assignments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: assignments.map((assignment) {
        return _buildAssignmentItem(context, assignment);
      }).toList(),
    );
  }

  /// Item bài tập đơn lẻ
  Widget _buildAssignmentItem(
    BuildContext context,
    Map<String, dynamic> assignment,
  ) {
    // Xác định trạng thái và màu sắc
    String status = assignment['status'];
    Color iconColor;
    Color badgeColor;
    String statusText;
    String badgeText;

    switch (status) {
      case 'active':
        iconColor = Colors.blue;
        badgeColor = Colors.red;
        statusText = 'Cần chấm';
        badgeText = 'Cần chấm: ${assignment['ungraded']}';
        break;
      case 'new':
        iconColor = Colors.blue;
        badgeColor = Colors.amber;
        statusText = 'Đang nộp';
        badgeText = 'Đang nộp: ${assignment['submitted']}/${assignment['totalStudents']}';
        break;
      case 'closed':
        iconColor = Colors.green;
        badgeColor = Colors.green;
        statusText = 'Đã hoàn tất';
        badgeText = 'Đã chấm: ${assignment['graded']}/${assignment['totalStudents']}';
        break;
      default:
        iconColor = Colors.grey;
        badgeColor = Colors.grey;
        statusText = 'Không xác định';
        badgeText = '';
    }

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: status == 'closed'
              ? Theme.of(context).dividerColor.withOpacity(0.5)
              : Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: status == 'closed'
            ? []
            : [DesignElevation.level1],
      ),
      child: Column(
        children: [
          // Phần thông tin chính
          GestureDetector(
            onTap: status == 'closed' ? null : () {
              // TODO: Navigate to assignment detail
            },
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  // Icon loại bài tập
                  Container(
                    width: DesignComponents.avatarSmall,
                    height: DesignComponents.avatarSmall,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.full),
                    ),
                    child: Icon(
                      _getAssignmentIcon(assignment['icon']),
                      size: DesignIcons.mdSize,
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  // Thông tin bài tập
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: DesignTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Text(
                          '${assignment['classInfo']} • Sĩ số: ${assignment['totalStudents']}',
                          style: DesignTypography.bodySmall.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Đường phân cách
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: DesignSpacing.lg,
            endIndent: DesignSpacing.lg,
          ),
          // Phần footer với trạng thái
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
                // Thời hạn
                Row(
                  children: [
                    Icon(
                      status == 'closed' ? Icons.check_circle : Icons.calendar_today,
                      size: DesignIcons.smSize,
                      color: status == 'closed' ? Colors.green : DesignColors.textSecondary,
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Text(
                      status == 'closed' ? 'Đã hoàn tất' : 'Hạn: ${assignment['dueDate']}',
                      style: DesignTypography.caption.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Trạng thái
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Row(
                    children: [
                      if (status == 'active')
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badgeColor,
                          ),
                        ),
                      if (status == 'active')
                        SizedBox(width: DesignSpacing.xs),
                      Text(
                        badgeText,
                        style: DesignTypography.caption.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chuyển đổi tên icon từ string sang IconData
  IconData _getAssignmentIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate;
      case 'menu_book':
        return Icons.menu_book;
      case 'science':
        return Icons.science;
      default:
        return Icons.assignment;
    }
  }
}

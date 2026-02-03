import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/list_item/assignment/class_detail_assignment_list_item.dart';
import 'package:flutter/material.dart';

// Export enum để dễ dàng sử dụng
export 'package:ai_mls/widgets/list_item/assignment/class_detail_assignment_list_item.dart'
    show AssignmentViewMode;

/// Widget container hiển thị danh sách bài tập trong class detail
/// Hỗ trợ cả chế độ giáo viên và học sinh
class ClassDetailAssignmentList extends StatelessWidget {
  final List<Map<String, dynamic>> assignments;
  final AssignmentViewMode viewMode;
  final Function(Map<String, dynamic>)? onItemTap;
  final Widget? emptyState;

  const ClassDetailAssignmentList({
    super.key,
    required this.assignments,
    required this.viewMode,
    this.onItemTap,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return emptyState ?? _buildDefaultEmptyState();
    }

    return Column(
      children: assignments.map((assignment) {
        return ClassDetailAssignmentListItem(
          assignment: assignment,
          viewMode: viewMode,
          onTap: onItemTap != null ? () => onItemTap!(assignment) : null,
        );
      }).toList(),
    );
  }

  /// Xây dựng empty state mặc định
  Widget _buildDefaultEmptyState() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: DesignIcons.xxlSize,
            color: DesignColors.textTertiary,
          ),
          SizedBox(height: DesignSpacing.lg),
          Text(
            'Chưa có bài tập nào',
            style: DesignTypography.titleMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            viewMode == AssignmentViewMode.teacher
                ? 'Tạo bài tập mới để bắt đầu'
                : 'Chưa có bài tập nào được giao',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

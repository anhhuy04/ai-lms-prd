import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/student_class_member_status.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị badge trạng thái của lớp học
/// - Hiển thị số bài tập chưa chấm (màu cam)
/// - Hiển thị "Đã chấm hết" (màu xanh)
/// - Hiển thị "Không có bài tập" (màu xám)
class ClassStatusBadge extends StatelessWidget {
  final int? ungradedCount;
  final bool hasAssignments;
  final String? memberStatus;

  const ClassStatusBadge({
    super.key,
    this.ungradedCount,
    this.hasAssignments = true,
    this.memberStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Ưu tiên hiển thị trạng thái tham gia lớp cho học sinh
    final statusEnum = StudentClassMemberStatus.fromString(memberStatus);
    if (statusEnum == StudentClassMemberStatus.pending) {
      return _buildPendingApprovalBadge();
    }

    if (!hasAssignments) {
      return _buildNoAssignmentsBadge();
    } else if (ungradedCount != null && ungradedCount! > 0) {
      return _buildUngradedBadge();
    } else {
      return _buildAllGradedBadge();
    }
  }

  /// Badge cho trạng thái không có bài tập
  Widget _buildNoAssignmentsBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_circle_outline, size: 18, color: Colors.grey),
          SizedBox(width: DesignSpacing.xs),
          Text('Không có bài tập', style: DesignTypography.caption),
        ],
      ),
    );
  }

  /// Badge cho trạng thái có bài tập chưa chấm
  Widget _buildUngradedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.drive_file_rename_outline,
            size: 18,
            color: Colors.orange,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            '$ungradedCount',
            style: DesignTypography.labelMedium.copyWith(color: Colors.orange),
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'chưa chấm',
            style: DesignTypography.caption.copyWith(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  /// Badge cho trạng thái đã chấm hết bài tập
  Widget _buildAllGradedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Đã chấm hết',
            style: DesignTypography.caption.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }

  /// Badge cho trạng thái đang chờ duyệt vào lớp
  Widget _buildPendingApprovalBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: DesignColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top, size: 18, color: DesignColors.primary),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Đang duyệt',
            style: DesignTypography.caption.copyWith(
              color: DesignColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

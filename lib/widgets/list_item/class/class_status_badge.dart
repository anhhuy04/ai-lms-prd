import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/student_class_member_status.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị badge trạng thái của lớp học
/// - Teacher: số bài chưa chấm / "Đã chấm hết"
/// - Student: "Đang làm X bài" / "Còn X bài chưa làm" / "Đã hoàn thành"
/// - Cả hai: "Không có bài tập" / "Đang duyệt"
class ClassStatusBadge extends StatelessWidget {
  final int? ungradedCount;
  final bool hasAssignments;
  final String? memberStatus;

  /// True khi hiển thị từ góc nhìn học sinh (đổi text sang ngữ cảnh học sinh).
  final bool isStudentView;

  /// Số bài đang làm dở (in_progress) — chỉ dùng khi isStudentView = true.
  final int? inProgressAssignmentCount;

  /// Số bài chưa bắt đầu — chỉ dùng khi isStudentView = true.
  final int? notStartedAssignmentCount;

  const ClassStatusBadge({
    super.key,
    this.ungradedCount,
    this.hasAssignments = true,
    this.memberStatus,
    this.isStudentView = false,
    this.inProgressAssignmentCount,
    this.notStartedAssignmentCount,
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
    }

    // Student view: dùng in_progress + not_started để hiển thị 2 label riêng
    if (isStudentView) {
      final inProgress = inProgressAssignmentCount ?? 0;
      final notStarted = notStartedAssignmentCount ?? 0;

      if (inProgress > 0) {
        return _buildInProgressBadge(inProgress);
      } else if (notStarted > 0) {
        return _buildNotStartedBadge(notStarted);
      } else {
        return _buildAllCompletedBadge();
      }
    }

    // Teacher view
    if (ungradedCount != null && ungradedCount! > 0) {
      return _buildUngradedBadge();
    }
    return _buildAllGradedBadge();
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

  /// Badge cho học sinh: đang làm dở (có work_session in_progress)
  Widget _buildInProgressBadge(int count) {
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
          Icon(Icons.edit_note_outlined, size: 18, color: DesignColors.primary),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Đang làm $count bài',
            style: DesignTypography.caption.copyWith(color: DesignColors.primary),
          ),
        ],
      ),
    );
  }

  /// Badge cho học sinh: còn bài chưa bắt đầu (không có work_session)
  Widget _buildNotStartedBadge(int count) {
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
          const Icon(Icons.assignment_late_outlined, size: 18, color: Colors.orange),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Còn $count bài chưa làm',
            style: DesignTypography.caption.copyWith(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  /// Badge cho học sinh: đã hoàn thành hết bài tập
  Widget _buildAllCompletedBadge() {
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
            'Đã hoàn thành',
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

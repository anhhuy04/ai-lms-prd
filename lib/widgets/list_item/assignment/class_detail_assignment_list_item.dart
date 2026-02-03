import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Enum định nghĩa chế độ xem danh sách bài tập
enum AssignmentViewMode {
  /// Chế độ giáo viên: hiển thị thống kê và trạng thái chấm bài
  teacher,

  /// Chế độ học sinh: hiển thị trạng thái cá nhân và điểm số
  student,
}

/// Widget hiển thị một item bài tập trong class detail
/// Hỗ trợ cả chế độ giáo viên và học sinh
class ClassDetailAssignmentListItem extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final AssignmentViewMode viewMode;
  final VoidCallback? onTap;

  const ClassDetailAssignmentListItem({
    super.key,
    required this.assignment,
    required this.viewMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: _getBorderColor(context), width: 1),
        boxShadow: _getBoxShadow(),
      ),
      child: Column(
        children: [
          // Phần thông tin chính
          GestureDetector(
            onTap: _isClickable() ? onTap : null,
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  // Icon loại bài tập
                  _buildIcon(),
                  SizedBox(width: DesignSpacing.md),
                  // Thông tin bài tập
                  Expanded(child: _buildInfo()),
                ],
              ),
            ),
          ),
          // Đường phân cách
          if (viewMode == AssignmentViewMode.teacher)
            Divider(
              height: 1,
              color: Colors.grey[200],
              indent: DesignSpacing.lg,
              endIndent: DesignSpacing.lg,
            ),
          // Phần footer với trạng thái và hành động
          Padding(
            padding: EdgeInsets.fromLTRB(
              DesignSpacing.lg,
              DesignSpacing.md,
              DesignSpacing.lg,
              DesignSpacing.md,
            ),
            child: viewMode == AssignmentViewMode.teacher
                ? _buildTeacherFooter(context)
                : _buildStudentFooter(context),
          ),
        ],
      ),
    );
  }

  /// Xây dựng icon bài tập
  Widget _buildIcon() {
    final iconColor = _getIconColor();
    return Container(
      width: DesignComponents.avatarSmall,
      height: DesignComponents.avatarSmall,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Icon(
        _getAssignmentIcon(assignment['icon']),
        size: DesignIcons.mdSize,
        color: iconColor,
      ),
    );
  }

  /// Xây dựng thông tin bài tập
  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assignment['title'] ?? '',
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: DesignSpacing.xs),
        Text(
          _getSubtitleText(),
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Xây dựng footer cho chế độ giáo viên
  Widget _buildTeacherFooter(BuildContext context) {
    final status = assignment['status'] ?? '';
    final statusInfo = _getTeacherStatusInfo(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Thời hạn
        Row(
          children: [
            Icon(
              status == 'closed' ? Icons.check_circle : Icons.calendar_today,
              size: DesignIcons.smSize,
              color: status == 'closed'
                  ? Colors.green
                  : DesignColors.textSecondary,
            ),
            SizedBox(width: DesignSpacing.sm),
            Text(
              status == 'closed'
                  ? 'Đã hoàn tất'
                  : 'Hạn: ${assignment['dueDate'] ?? ''}',
              style: DesignTypography.caption.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
        // Trạng thái badge
        _buildTeacherBadge(statusInfo),
      ],
    );
  }

  /// Xây dựng footer cho chế độ học sinh
  Widget _buildStudentFooter(BuildContext context) {
    final studentStatus = assignment['studentStatus'] ?? 'not_submitted';
    final statusInfo = _getStudentStatusInfo(studentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thời hạn
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: DesignIcons.smSize,
              color: DesignColors.textSecondary,
            ),
            SizedBox(width: DesignSpacing.sm),
            Text(
              'Hạn nộp: ${assignment['dueDate'] ?? ''}',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.md),
        // Badge trạng thái và nút hành động trên cùng 1 dòng
        // Tỉ lệ: Nút 45%, Khoảng cách tự do, Badge 45%
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nút hành động - 45%
            Expanded(flex: 45, child: _buildActionButton(studentStatus)),
            SizedBox(width: DesignSpacing.md),
            // Badge trạng thái - 45%
            Expanded(
              flex: 45,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildStudentBadge(statusInfo),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng badge cho giáo viên
  Widget _buildTeacherBadge(Map<String, dynamic> statusInfo) {
    final badgeColor = statusInfo['color'] as Color;
    final badgeText = statusInfo['text'] as String;
    final showDot = statusInfo['showDot'] as bool;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
            ),
          if (showDot) SizedBox(width: DesignSpacing.xs),
          Text(
            badgeText,
            style: DesignTypography.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng badge cho học sinh
  Widget _buildStudentBadge(Map<String, dynamic> statusInfo) {
    final badgeColor = statusInfo['color'] as Color;
    final badgeText = statusInfo['text'] as String;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        badgeText,
        style: DesignTypography.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Xây dựng nút hành động cho học sinh
  Widget _buildActionButton(String studentStatus) {
    switch (studentStatus) {
      case 'submitted':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: DesignSpacing.sm,
            ),
            minimumSize: const Size(0, 32),
          ),
          onPressed: onTap,
          child: const Text(
            'Xem bài đã nộp',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );

      case 'graded':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[100],
            foregroundColor: Colors.green[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: DesignSpacing.sm,
            ),
            minimumSize: const Size(0, 32),
          ),
          onPressed: onTap,
          child: const Text(
            'Xem feedback',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );

      case 'not_submitted':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: DesignSpacing.sm,
            ),
            minimumSize: const Size(0, 32),
          ),
          onPressed: onTap,
          child: const Text(
            'Nộp bài tập',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );

      default:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: DesignSpacing.sm,
            ),
            minimumSize: const Size(0, 32),
          ),
          onPressed: onTap,
          child: const Text(
            'Xem chi tiết',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
    }
  }

  /// Lấy thông tin trạng thái cho giáo viên
  Map<String, dynamic> _getTeacherStatusInfo(String status) {
    switch (status) {
      case 'active':
        return {
          'color': Colors.red,
          'text': 'Cần chấm: ${assignment['ungraded'] ?? 0}',
          'showDot': true,
        };
      case 'new':
        return {
          'color': Colors.amber,
          'text':
              'Đang nộp: ${assignment['submitted'] ?? 0}/${assignment['totalStudents'] ?? 0}',
          'showDot': false,
        };
      case 'closed':
        return {
          'color': Colors.green,
          'text':
              'Đã chấm: ${assignment['graded'] ?? 0}/${assignment['totalStudents'] ?? 0}',
          'showDot': false,
        };
      default:
        return {
          'color': Colors.grey,
          'text': 'Không xác định',
          'showDot': false,
        };
    }
  }

  /// Lấy thông tin trạng thái cho học sinh
  Map<String, dynamic> _getStudentStatusInfo(String studentStatus) {
    final score = assignment['score'];
    switch (studentStatus) {
      case 'submitted':
        return {
          'color': Colors.orange,
          'text': score != null ? 'Đã nộp • $score điểm' : 'Đã nộp',
        };
      case 'graded':
        return {
          'color': Colors.green,
          'text': score != null ? 'Đã chấm • $score điểm' : 'Đã chấm',
        };
      case 'not_submitted':
        return {'color': Colors.red, 'text': 'Chưa nộp'};
      default:
        return {'color': Colors.grey, 'text': 'Không xác định'};
    }
  }

  /// Lấy màu icon dựa trên trạng thái
  Color _getIconColor() {
    if (viewMode == AssignmentViewMode.teacher) {
      final status = assignment['status'] ?? '';
      switch (status) {
        case 'active':
        case 'new':
          return Colors.blue;
        case 'closed':
          return Colors.green;
        default:
          return Colors.grey;
      }
    } else {
      return DesignColors.primary;
    }
  }

  /// Lấy màu border
  Color _getBorderColor(BuildContext context) {
    if (viewMode == AssignmentViewMode.teacher) {
      final status = assignment['status'] ?? '';
      if (status == 'closed') {
        return Theme.of(context).dividerColor.withValues(alpha: 0.5);
      }
    }
    return Theme.of(context).dividerColor;
  }

  /// Lấy box shadow
  List<BoxShadow> _getBoxShadow() {
    if (viewMode == AssignmentViewMode.teacher) {
      final status = assignment['status'] ?? '';
      if (status == 'closed') {
        return [];
      }
    }
    return [DesignElevation.level1];
  }

  /// Kiểm tra xem item có thể click được không
  bool _isClickable() {
    if (viewMode == AssignmentViewMode.teacher) {
      final status = assignment['status'] ?? '';
      return status != 'closed';
    }
    return true;
  }

  /// Lấy text subtitle
  String _getSubtitleText() {
    if (viewMode == AssignmentViewMode.teacher) {
      return '${assignment['classInfo'] ?? ''} • Sĩ số: ${assignment['totalStudents'] ?? 0}';
    } else {
      return assignment['classInfo'] ?? '';
    }
  }

  /// Chuyển đổi tên icon từ string sang IconData
  IconData _getAssignmentIcon(String? iconName) {
    if (iconName == null) return Icons.assignment;
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

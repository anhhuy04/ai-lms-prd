import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/drawers/drawer_action_tile.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:ai_mls/presentation/views/class/teacher/student_list_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/add_student_by_code_screen.dart';

/// Drawer nội dung cài đặt lớp học
/// Hiển thị các tùy chọn quản lý và cài đặt cho lớp học
class ClassSettingsDrawer extends StatelessWidget {
  final String className;
  final String semesterInfo;
  final int pendingStudentRequests;

  const ClassSettingsDrawer({
    super.key,
    required this.className,
    required this.semesterInfo,
    this.pendingStudentRequests = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Phần quản lý học sinh
          _buildStudentManagementSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần cài đặt lớp học
          _buildClassSettingsSection(context),

          // Phần hành động nguy hiểm (xóa lớp)
          _buildDangerZoneSection(context),

          // Padding cuối
          SizedBox(height: DesignSpacing.xxxl),
        ],
      ),
    );
  }

  /// Phần quản lý học sinh
  Widget _buildStudentManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'QUẢN LÝ HỌC SINH',
          icon: Icons.people_alt_outlined,
        ),

        DrawerActionTile(
          icon: Icons.qr_code_2,
          title: 'Thêm học sinh bằng mã',
          subtitle: 'Chia sẻ mã lớp học',
          onTap: () {
            // Điều hướng đến màn hình thêm học sinh bằng mã
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddStudentByCodeScreen(
                  classId: '', // TODO: Truyền classId thực tế
                  className: className,
                ),
              ),
            );
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.person_add_alt_1,
          title: 'Duyệt học sinh',
          subtitle: pendingStudentRequests > 0
              ? '$pendingStudentRequests yêu cầu đang chờ'
              : 'Không có yêu cầu mới',
          onTap: () {
            // Điều hướng đến màn hình danh sách học sinh
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentListScreen(
                  classId: '', // TODO: Truyền classId thực tế
                  className: className,
                ),
              ),
            );
          },
          iconColor: DesignColors.primary,
          showNotificationDot: pendingStudentRequests > 0,
        ),
      ],
    );
  }

  /// Phần cài đặt lớp học
  Widget _buildClassSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'CÀI ĐẶT LỚP HỌC',
          icon: Icons.settings_outlined,
        ),

        DrawerActionTile(
          icon: Icons.edit_square,
          title: 'Chỉnh sửa thông tin',
          subtitle: 'Tên lớp, môn học, ảnh bìa',
          onTap: () {
            // TODO: Implement class info editing
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerToggleTile(
          icon: Icons.lock_outline,
          title: 'Khóa lớp học',
          subtitle: 'Ngăn học sinh mới tham gia',
          value: false,
          onChanged: (value) {
            // TODO: Implement class locking
          },
        ),
      ],
    );
  }

  /// Phần hành động nguy hiểm
  Widget _buildDangerZoneSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.md,
          ),
          child: Text(
            'NGUY HIỂM',
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.error,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        DrawerActionTile(
          icon: Icons.delete_outline,
          title: 'Xóa lớp học',
          subtitle: 'Hành động này không thể hoàn tác',
          onTap: () {
            // TODO: Implement class deletion with confirmation
            Navigator.pop(context);
          },
          iconColor: DesignColors.error,
          showChevron: false,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';

/// Drawer cài đặt nâng cao cho lớp học
/// Chuyển đổi từ HTML sang Dart theo quy tắc ánh xạ
class ClassAdvancedSettingsDrawer extends StatelessWidget {
  final String className;
  final bool showGroupToStudents;
  final bool lockGroupChanges;
  final bool allowStudentProfileEdit;
  final bool autoLockAfterSubmit;
  final bool lockClass;
  final Function(bool) onShowGroupToStudentsChanged;
  final Function(bool) onLockGroupChangesChanged;
  final Function(bool) onAllowStudentProfileEditChanged;
  final Function(bool) onAutoLockAfterSubmitChanged;
  final Function(bool) onLockClassChanged;

  const ClassAdvancedSettingsDrawer({
    super.key,
    required this.className,
    this.showGroupToStudents = true,
    this.lockGroupChanges = false,
    this.allowStudentProfileEdit = true,
    this.autoLockAfterSubmit = false,
    this.lockClass = false,
    required this.onShowGroupToStudentsChanged,
    required this.onLockGroupChangesChanged,
    required this.onAllowStudentProfileEditChanged,
    required this.onAutoLockAfterSubmitChanged,
    required this.onLockClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần kiểm soát nhóm
          _buildGroupControlSection(),

          const SizedBox(height: 16),

          // Phần hạn chế quyền học sinh
          _buildStudentRestrictionsSection(),

          const SizedBox(height: 16),

          // Phần trạng thái lớp
          _buildClassStatusSection(),
        ],
      ),
    );
  }

  /// Phần kiểm soát nhóm
  Widget _buildGroupControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Kiểm soát nhóm'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: DesignColors.dividerLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              DrawerToggleTile(
                icon: Icons.visibility,
                title: 'Hiển thị nhóm cho học sinh',
                subtitle: 'Giúp giảm áp lực khi phân hóa bài tập',
                value: showGroupToStudents,
                onChanged: onShowGroupToStudentsChanged,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                endIndent: 16,
                color: DesignColors.dividerLight,
              ),
              DrawerToggleTile(
                icon: Icons.lock,
                title: 'Khóa thay đổi nhóm',
                subtitle: 'Chỉ giáo viên được quyền đổi nhóm',
                value: lockGroupChanges,
                onChanged: onLockGroupChangesChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần hạn chế quyền học sinh
  Widget _buildStudentRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Hạn chế quyền học sinh'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: DesignColors.dividerLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              DrawerToggleTile(
                icon: Icons.badge,
                title: 'Cho phép sửa hồ sơ trong lớp',
                subtitle: 'Học sinh tự cập nhật tên và ảnh đại diện',
                value: allowStudentProfileEdit,
                onChanged: onAllowStudentProfileEditChanged,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                endIndent: 16,
                color: DesignColors.dividerLight,
              ),
              DrawerToggleTile(
                icon: Icons.verified_user,
                title: 'Tự động khóa bài sau khi nộp',
                subtitle: 'Khóa không gian làm việc ngay khi nộp bài',
                value: autoLockAfterSubmit,
                onChanged: onAutoLockAfterSubmitChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần trạng thái lớp
  Widget _buildClassStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Trạng thái lớp'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: DesignColors.dividerLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DrawerToggleTile(
            icon: Icons.lock_person,
            title: 'Khóa lớp học',
            subtitle: 'Chặn học sinh mới qua mã QR/mã lớp',
            value: lockClass,
            onChanged: onLockClassChanged,
          ),
        ),
      ],
    );
  }
}
       

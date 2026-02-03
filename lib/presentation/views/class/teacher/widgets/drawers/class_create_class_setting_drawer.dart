import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:flutter/material.dart';

/// Drawer cài đặt nâng cao cho màn hình tạo lớp học mới
/// Cho phép cấu hình các settings trước khi tạo lớp
/// Sử dụng ActionEndDrawer để có nền trắng và header chuẩn
class ClassCreateClassSettingDrawer extends StatelessWidget {
  final Map<String, dynamic> classSettings;
  final Function(String path, dynamic value) onSettingChanged;

  const ClassCreateClassSettingDrawer({
    super.key,
    required this.classSettings,
    required this.onSettingChanged,
  });

  /// Helper methods để đọc settings
  bool _getShowGroupToStudents(Map<String, dynamic> settings) =>
      settings['group_management']?['is_visible_to_students'] ?? true;

  bool _getLockGroupChanges(Map<String, dynamic> settings) =>
      settings['group_management']?['lock_groups'] ?? false;

  bool _getAllowStudentSwitch(Map<String, dynamic> settings) =>
      settings['group_management']?['allow_student_switch'] ?? false;

  bool _getAllowStudentProfileEdit(Map<String, dynamic> settings) =>
      settings['student_permissions']?['can_edit_profile_in_class'] ?? true;

  bool _getAutoLockAfterSubmit(Map<String, dynamic> settings) =>
      settings['student_permissions']?['auto_lock_on_submission'] ?? false;

  bool _getLockClass(Map<String, dynamic> settings) =>
      settings['defaults']?['lock_class'] ?? false;

  /// Helper để update nested map value
  void _updateNestedSetting(String path, dynamic value) {
    onSettingChanged(path, value);
  }

  @override
  Widget build(BuildContext context) {
    const spacing = _Spacing(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xxl: 32,
      xxxxxl: 48,
    );
    return ActionEndDrawer(
      title: 'Cài đặt nâng cao',
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phần kiểm soát nhóm
            _buildGroupControlSection(context),

            SizedBox(height: spacing.lg),

            // Phần hạn chế quyền học sinh
            _buildStudentRestrictionsSection(context),

            SizedBox(height: spacing.lg),

            // Phần trạng thái lớp
            _buildClassStatusSection(context),

            // Padding cuối
            SizedBox(height: spacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Phần kiểm soát nhóm
  Widget _buildGroupControlSection(BuildContext context) {
    const spacing = _Spacing(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xxl: 32,
      xxxxxl: 48,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
          child: Text(
            'Kiểm soát nhóm',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.visibility,
                  title: 'Hiển thị nhóm cho học sinh',
                  value: _getShowGroupToStudents(classSettings),
                  onChanged: (value) {
                    _updateNestedSetting(
                      'group_management.is_visible_to_students',
                      value,
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: Theme.of(context).dividerColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.lock,
                  title: 'Khóa thay đổi nhóm',
                  value: _getLockGroupChanges(classSettings),
                  onChanged: (value) {
                    _updateNestedSetting('group_management.lock_groups', value);
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: Theme.of(context).dividerColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.swap_horiz,
                  title: 'Cho tự chuyển nhóm',
                  value: _getAllowStudentSwitch(classSettings),
                  onChanged: (value) {
                    _updateNestedSetting(
                      'group_management.allow_student_switch',
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần hạn chế quyền học sinh
  Widget _buildStudentRestrictionsSection(BuildContext context) {
    const spacing = _Spacing(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xxl: 32,
      xxxxxl: 48,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
          child: Text(
            'Hạn chế quyền học sinh',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.badge,
                  title: 'Cho phép sửa hồ sơ trong lớp',
                  value: _getAllowStudentProfileEdit(classSettings),
                  onChanged: (value) {
                    _updateNestedSetting(
                      'student_permissions.can_edit_profile_in_class',
                      value,
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: Theme.of(context).dividerColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.verified_user,
                  title: 'Tự động khóa bài sau khi nộp',
                  value: _getAutoLockAfterSubmit(classSettings),
                  onChanged: (value) {
                    _updateNestedSetting(
                      'student_permissions.auto_lock_on_submission',
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần trạng thái lớp
  Widget _buildClassStatusSection(BuildContext context) {
    const spacing = _Spacing(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xxl: 32,
      xxxxxl: 48,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
          child: Text(
            'Trạng thái lớp',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs,
            ),
            child: DrawerToggleTile(
              icon: Icons.lock_person,
              title: 'Khóa lớp học',
              value: _getLockClass(classSettings),
              onChanged: (value) {
                _updateNestedSetting('defaults.lock_class', value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Spacing helper (temporary shim for Design System v2 migration).
/// Avoids using legacy `DesignSpacing` in presentation layer.
class _Spacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xxl;
  final double xxxxxl;

  const _Spacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xxl,
    required this.xxxxxl,
  });
}

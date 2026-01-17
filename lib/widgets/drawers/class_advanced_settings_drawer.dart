import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/domain/entities/class.dart';

/// Drawer cài đặt nâng cao cho lớp học
/// Chuyển đổi từ HTML sang Dart theo quy tắc ánh xạ
class ClassAdvancedSettingsDrawer extends StatelessWidget {
  final ClassViewModel viewModel;
  final Class classItem;

  const ClassAdvancedSettingsDrawer({
    super.key,
    required this.viewModel,
    required this.classItem,
  });

  /// Đọc settings từ classItem.classSettings
  Map<String, dynamic> get classSettings => classItem.classSettings;

  /// Helper getters để đọc settings
  bool get showGroupToStudents =>
      classSettings['group_management']?['is_visible_to_students'] ?? true;

  bool get lockGroupChanges =>
      classSettings['group_management']?['lock_groups'] ?? false;

  bool get allowStudentProfileEdit =>
      classSettings['student_permissions']?['can_edit_profile_in_class'] ??
      true;

  bool get autoLockAfterSubmit =>
      classSettings['student_permissions']?['auto_lock_on_submission'] ?? false;

  bool get lockClass => classSettings['defaults']?['lock_class'] ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần kiểm soát nhóm
          Builder(builder: (context) => _buildGroupControlSection(context)),

          const SizedBox(height: 16),

          // Phần hạn chế quyền học sinh
          Builder(
            builder: (context) => _buildStudentRestrictionsSection(context),
          ),

          const SizedBox(height: 16),

          // Phần trạng thái lớp
          Builder(builder: (context) => _buildClassStatusSection(context)),
        ],
      ),
    );
  }

  /// Phần kiểm soát nhóm
  Widget _buildGroupControlSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Kiểm soát nhóm'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.dividerLight, width: 1),
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
                onChanged: (value) async {
                  final success = await viewModel.updateClassSetting(
                    classItem.id,
                    'group_management.is_visible_to_students',
                    value,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ??
                              'Không thể cập nhật cài đặt',
                        ),
                        backgroundColor: DesignColors.error,
                      ),
                    );
                  }
                },
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
                onChanged: (value) async {
                  final success = await viewModel.updateClassSetting(
                    classItem.id,
                    'group_management.lock_groups',
                    value,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ??
                              'Không thể cập nhật cài đặt',
                        ),
                        backgroundColor: DesignColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần hạn chế quyền học sinh
  Widget _buildStudentRestrictionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Hạn chế quyền học sinh'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.dividerLight, width: 1),
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
                onChanged: (value) async {
                  final success = await viewModel.updateClassSetting(
                    classItem.id,
                    'student_permissions.can_edit_profile_in_class',
                    value,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ??
                              'Không thể cập nhật cài đặt',
                        ),
                        backgroundColor: DesignColors.error,
                      ),
                    );
                  }
                },
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
                onChanged: (value) async {
                  final success = await viewModel.updateClassSetting(
                    classItem.id,
                    'student_permissions.auto_lock_on_submission',
                    value,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ??
                              'Không thể cập nhật cài đặt',
                        ),
                        backgroundColor: DesignColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần trạng thái lớp
  Widget _buildClassStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerSectionHeader(title: 'Trạng thái lớp'),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.dividerLight, width: 1),
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
            onChanged: (value) async {
              final success = await viewModel.updateClassSetting(
                classItem.id,
                'defaults.lock_class',
                value,
              );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage ?? 'Không thể cập nhật cài đặt',
                    ),
                    backgroundColor: DesignColors.error,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

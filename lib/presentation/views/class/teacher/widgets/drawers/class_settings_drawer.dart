import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/drawers/class_settings_drawer_handlers.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/dialogs/teacher_delete_class_dialog.dart';
import 'package:ai_mls/widgets/drawers/drawer_action_tile.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Drawer nội dung cài đặt lớp học (Teacher)
/// Hiển thị các tùy chọn quản lý và cài đặt cho lớp học
class ClassSettingsDrawer extends ConsumerStatefulWidget {
  final Class classItem;

  const ClassSettingsDrawer({super.key, required this.classItem});

  @override
  ConsumerState<ClassSettingsDrawer> createState() =>
      _ClassSettingsDrawerState();
}

class _ClassSettingsDrawerState extends ConsumerState<ClassSettingsDrawer> {
  // Cache Future để tránh load lại nhiều lần
  Future<({int pending, int approved})>? _memberCountsFuture;

  /// Đọc settings từ classItem.classSettings
  /// Luôn đảm bảo không null để tránh crash khi backend trả thiếu cấu hình.
  Map<String, dynamic> get classSettings =>
      widget.classItem.classSettings ?? const <String, dynamic>{};

  /// Helper getters để đọc settings
  bool get lockClass => classSettings['defaults']?['lock_class'] ?? false;

  bool get requireApproval =>
      classSettings['enrollment']?['qr_code']?['require_approval'] ?? true;

  // Group management settings
  bool get showGroupToStudents =>
      classSettings['group_management']?['is_visible_to_students'] ?? true;

  bool get lockGroupChanges =>
      classSettings['group_management']?['lock_groups'] ?? false;

  bool get allowStudentSwitch =>
      classSettings['group_management']?['allow_student_switch'] ?? false;

  // Student permissions
  bool get allowStudentProfileEdit =>
      classSettings['student_permissions']?['can_edit_profile_in_class'] ??
      true;

  bool get autoLockAfterSubmit =>
      classSettings['student_permissions']?['auto_lock_on_submission'] ?? false;

  Future<({int pending, int approved})> _getMemberCounts() {
    // Cache Future để không spam query mỗi lần build.
    return _memberCountsFuture ??= ref
        .read(classNotifierProvider.notifier)
        .getClassMemberCounts(widget.classItem.id);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Column(
        children: [
          // Phần quản lý học sinh
          _buildStudentManagementSection(context),

          SizedBox(height: spacing.lg),

          // Phần cài đặt lớp học
          _buildClassSettingsSection(context),

          SizedBox(height: spacing.lg),

          // Phần cài đặt nâng cao (nhóm & quyền học sinh)
          _buildAdvancedSettingsSection(context),

          SizedBox(height: spacing.lg),

          // Phần hành động nguy hiểm (xóa lớp)
          _buildDangerZoneSection(context),

          // Padding cuối
          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }

  /// Phần quản lý học sinh
  Widget _buildStudentManagementSection(BuildContext context) {
    final spacing = context.spacing;
    return FutureBuilder<({int pending, int approved})>(
      future: _getMemberCounts(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.pending ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: DesignIcons.smSize,
                    color: DesignColors.textSecondary,
                  ),
                  SizedBox(width: spacing.xs),
                  Text(
                    'QUẢN LÝ HỌC SINH',
                    style: DesignTypography.labelMedium.copyWith(
                      color: DesignColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DesignColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    child: DrawerActionTile(
                      icon: Icons.qr_code_2,
                      title: 'Thêm học sinh bằng mã',
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamed(
                          AppRoute.teacherAddStudentByCode,
                          pathParameters: {'classId': widget.classItem.id},
                          extra: widget.classItem.name,
                        );
                      },
                      iconColor: DesignColors.drawerIcon,
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: spacing.xxxxxl,
                    endIndent: spacing.md,
                    color: DesignColors.dividerLight,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    child: DrawerActionTile(
                      icon: Icons.person_add_alt_1,
                      title: 'Duyệt học sinh',
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamed(
                          AppRoute.teacherStudentList,
                          pathParameters: {'classId': widget.classItem.id},
                          extra: widget.classItem.name,
                        );
                      },
                      iconColor: DesignColors.drawerIcon,
                      showNotificationDot: pendingCount > 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Phần cài đặt lớp học
  Widget _buildClassSettingsSection(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: DesignIcons.smSize,
                color: DesignColors.textSecondary,
              ),
              SizedBox(width: spacing.xs),
              Text(
                'CÀI ĐẶT LỚP HỌC',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                child: DrawerActionTile(
                  icon: Icons.edit_square,
                  title: 'Chỉnh sửa thông tin',
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed(
                      AppRoute.teacherEditClass,
                      pathParameters: {'classId': widget.classItem.id},
                      extra: widget.classItem,
                    );
                  },
                  iconColor: DesignColors.drawerIcon,
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerActionTile(
                  icon: Icons.share,
                  title: 'Chia sẻ lớp học',
                  onTap: () {
                    ClassSettingsDrawerHandlers.showShareClassDialog(
                      context,
                      widget.classItem,
                      classSettings,
                    );
                  },
                  iconColor: DesignColors.drawerIcon,
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerActionTile(
                  icon: Icons.copy,
                  title: 'Sao chép lớp học',
                  onTap: () {
                    ClassSettingsDrawerHandlers.handleDuplicateClass(
                      context,
                      ref,
                      widget.classItem,
                      classSettings,
                    );
                  },
                  iconColor: DesignColors.drawerIcon,
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerActionTile(
                  icon: Icons.download,
                  title: 'Xuất dữ liệu lớp học',
                  onTap: () {
                    ClassSettingsDrawerHandlers.handleExportClassData(
                      context,
                      ref,
                      widget.classItem,
                    );
                  },
                  iconColor: DesignColors.drawerIcon,
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.lock_outline,
                  title: 'Khóa lớp học',
                  value: lockClass,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );

                    // Optimistic update: Update UI ngay lập tức
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'defaults.lock_class',
                          value,
                        );

                    if (!context.mounted) return;

                    if (!success) {
                      // Rollback đã được xử lý trong notifier
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần cài đặt nâng cao: nhóm & quyền học sinh
  Widget _buildAdvancedSettingsSection(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
          child: Row(
            children: [
              Icon(
                Icons.tune,
                size: DesignIcons.smSize,
                color: DesignColors.textSecondary,
              ),
              SizedBox(width: spacing.xs),
              Text(
                'CÀI ĐẶT NÂNG CAO',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        // Nhóm: Kiểm soát nhóm
        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                  title: 'Hiển thị nhóm',
                  value: showGroupToStudents,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'group_management.is_visible_to_students',
                          value,
                        );

                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.lock,
                  title: 'Khóa thay đổi nhóm',
                  value: lockGroupChanges,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'group_management.lock_groups',
                          value,
                        );

                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.swap_horiz,
                  title: 'Cho tự chuyển nhóm',
                  value: allowStudentSwitch,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'group_management.allow_student_switch',
                          value,
                        );

                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        // Nhóm: Hạn chế quyền học sinh
        Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                  title: 'Cho học sinh sửa hồ sơ',
                  value: allowStudentProfileEdit,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'student_permissions.can_edit_profile_in_class',
                          value,
                        );

                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: spacing.xxxxxl,
                endIndent: spacing.sm,
                color: DesignColors.dividerLight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerToggleTile(
                  icon: Icons.verified_user,
                  title: 'khóa bài sau khi nộp',
                  value: autoLockAfterSubmit,
                  onChanged: (value) async {
                    final classNotifier = ref.read(
                      classNotifierProvider.notifier,
                    );
                    final success = await classNotifier
                        .updateClassSettingOptimistic(
                          widget.classItem.id,
                          'student_permissions.auto_lock_on_submission',
                          value,
                        );

                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể cập nhật cài đặt'),
                          backgroundColor: DesignColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phần hành động nguy hiểm
  Widget _buildDangerZoneSection(BuildContext context) {
    final spacing = context.spacing;
    return FutureBuilder<int>(
      future: _getMemberCounts()
          .then((v) => v.approved + v.pending)
          .catchError((_) => 0),
      builder: (context, snapshot) {
        final totalCount = snapshot.data ?? 0;
        final pendingCount = 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: spacing.sm, bottom: spacing.xs),
              child: Text(
                'NGUY HIỂM',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.error,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DesignColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: DrawerActionTile(
                  icon: Icons.delete_outline,
                  title: 'Xóa lớp học',
                  onTap: () =>
                      _handleDeleteClass(context, totalCount, pendingCount),
                  iconColor: DesignColors.error,
                  showChevron: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Xử lý xóa lớp học
  /// Hiển thị confirmation dialog, xóa lớp, và điều hướng về trang chủ
  Future<void> _handleDeleteClass(
    BuildContext context,
    int approvedCount,
    int pendingCount,
  ) async {
    try {
      // Bước 1: Hiển thị dialog xác nhận
      final confirmed = await DeleteConfirmationDialog.show(
        context: context,
        classItem: widget.classItem,
        studentCount: approvedCount,
        pendingCount: pendingCount,
      );

      if (confirmed != true) {
        return;
      }
      if (!context.mounted) return;

      // Bước 2: Đóng drawer
      Navigator.pop(context);

      // Đợi một chút để drawer đóng hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));

      // Bước 3: Hiển thị loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Bước 4: Thực hiện xóa lớp
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final success = await classNotifier.deleteClass(widget.classItem.id);

      // Bước 5: Đóng loading dialog
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Bước 6: Xử lý kết quả
      if (success) {
        // Navigate về danh sách lớp học
        // Pop detail screen để quay về class list
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback: navigate bằng GoRouter
          context.goNamed(AppRoute.teacherClassList);
        }

        // Hiển thị success message sau một delay nhỏ
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa lớp học thành công'),
              backgroundColor: DesignColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        });
      } else {
        // Hiển thị error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa lớp học'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error deleting class: $e',
        error: e,
        stackTrace: stackTrace,
      );

      // Đóng loading dialog nếu còn mở và hiển thị error
      if (context.mounted) {
        try {
          // Chỉ đóng UI overlay (dialogs). Không được pop route stack cấp app ở đây.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi không mong đợi: $e'),
              backgroundColor: DesignColors.error,
            ),
          );
        } catch (_) {
          // Ignore if context is already disposed
        }
      }
    }
  }
}

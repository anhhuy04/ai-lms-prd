import 'package:ai_mls/widgets/drawers/drawer_action_tile.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:flutter/material.dart';

/// Drawer nội dung cài đặt lớp học dành cho học sinh
/// Hiển thị các tùy chọn cá nhân và cài đặt phù hợp với học sinh
class StudentClassSettingsDrawer extends StatelessWidget {
  final String className;
  final String semesterInfo;
  final String studentName;
  final String? teacherName;
  final String? joinedAtText;
  final int unreadNotifications;
  final int pendingAssignments;

  // Callbacks để màn hình cha inject logic mà không sửa UI drawer
  final VoidCallback? onViewClassInfo;
  final VoidCallback? onViewJoinHistory;
  final VoidCallback? onViewTeacherInfo;
  final VoidCallback? onLeaveClass;

  final VoidCallback? onViewSubmittedAssignments;
  final VoidCallback? onViewPendingAssignments;
  final VoidCallback? onViewGradedAssignments;
  final VoidCallback? onViewAssignmentSchedule;

  final VoidCallback? onChangeTextSize;
  final VoidCallback? onChangeTheme;
  final VoidCallback? onChangeLanguage;

  final VoidCallback? onContactTeacher;
  final VoidCallback? onReportIssue;
  final VoidCallback? onOpenHelpCenter;
  final VoidCallback? onSendFeedback;

  const StudentClassSettingsDrawer({
    super.key,
    required this.className,
    required this.semesterInfo,
    required this.studentName,
    this.teacherName,
    this.joinedAtText,
    this.unreadNotifications = 0,
    this.pendingAssignments = 0,
    this.onViewClassInfo,
    this.onViewJoinHistory,
    this.onViewTeacherInfo,
    this.onLeaveClass,
    this.onViewSubmittedAssignments,
    this.onViewPendingAssignments,
    this.onViewGradedAssignments,
    this.onViewAssignmentSchedule,
    this.onChangeTextSize,
    this.onChangeTheme,
    this.onChangeLanguage,
    this.onContactTeacher,
    this.onReportIssue,
    this.onOpenHelpCenter,
    this.onSendFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Phần thông tin cá nhân
          _buildPersonalInfoSection(context),

          // Đường phân cách
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Phần cài đặt thông báo
          _buildNotificationSettingsSection(context),

          // Đường phân cách
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Phần quản lý bài tập
          _buildAssignmentManagementSection(context),

          // Đường phân cách
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Phần cài đặt hiển thị
          _buildDisplaySettingsSection(context),

          // Đường phân cách
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Phần hỗ trợ
          _buildSupportSection(context),

          // Padding cuối
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  /// Helper chung: đóng drawer rồi gọi callback (nếu có).
  void _handleAction(BuildContext context, VoidCallback? handler) {
    Navigator.pop(context);
    if (handler != null) {
      handler();
    }
  }

  /// Phần thông tin cá nhân
  Widget _buildPersonalInfoSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'THÔNG TIN LỚP HỌC',
          icon: Icons.class_,
        ),

        DrawerActionTile(
          icon: Icons.info_outline,
          title: 'Thông tin lớp học',
          subtitle: 'Xem mô tả, mã lớp, năm học',
          onTap: () {
            _handleAction(context, onViewClassInfo);
          },
          iconColor: colorScheme.primary,
        ),

        DrawerActionTile(
          icon: Icons.history,
          title: 'Lịch sử tham gia',
          subtitle:
              joinedAtText != null && joinedAtText!.isNotEmpty
                  ? 'Ngày tham gia: $joinedAtText'
                  : 'Ngày tham gia: Chưa cập nhật',
          onTap: () {
            _handleAction(context, onViewJoinHistory);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),

        DrawerActionTile(
          icon: Icons.person_outline,
          title: 'Thông tin giáo viên',
          subtitle: teacherName != null && teacherName!.isNotEmpty
              ? teacherName!
              : 'Xem thông tin giáo viên phụ trách',
          onTap: () {
            _handleAction(context, onViewTeacherInfo);
          },
          iconColor: colorScheme.primary,
        ),

        DrawerActionTile(
          icon: Icons.logout,
          title: 'Rời lớp học',
          subtitle: 'Rời khỏi lớp học này',
          onTap: () {
            _handleAction(context, onLeaveClass);
          },
          iconColor: colorScheme.error,
        ),
      ],
    );
  }

  /// Phần cài đặt thông báo
  Widget _buildNotificationSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'CÀI ĐẶT THÔNG BÁO',
          icon: Icons.notifications_outlined,
        ),

        DrawerToggleTile(
          icon: Icons.assignment,
          title: 'Thông báo bài tập mới',
          subtitle: 'Nhận thông báo khi có bài tập mới',
          value: true,
          onChanged: (value) {
            // TODO: Cập nhật cài đặt thông báo
          },
        ),

        DrawerToggleTile(
          icon: Icons.grade,
          title: 'Thông báo điểm số',
          subtitle: 'Nhận thông báo khi có điểm mới',
          value: true,
          onChanged: (value) {
            // TODO: Cập nhật cài đặt thông báo
          },
        ),

        DrawerToggleTile(
          icon: Icons.message,
          title: 'Thông báo tin nhắn',
          subtitle: 'Nhận thông báo tin nhắn từ giáo viên',
          value: false,
          onChanged: (value) {
            // TODO: Cập nhật cài đặt thông báo
          },
        ),

        DrawerToggleTile(
          icon: Icons.event,
          title: 'Thông báo sự kiện',
          subtitle: 'Nhận thông báo về các sự kiện lớp',
          value: true,
          onChanged: (value) {
            // TODO: Cập nhật cài đặt thông báo
          },
        ),
      ],
    );
  }

  /// Phần quản lý bài tập
  Widget _buildAssignmentManagementSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'QUẢN LÝ BÀI TẬP',
          icon: Icons.assignment_outlined,
        ),

        DrawerActionTile(
          icon: Icons.assignment_turned_in,
          title: 'Bài đã nộp',
          subtitle: '12 bài tập đã nộp',
          onTap: () {
            _handleAction(context, onViewSubmittedAssignments);
          },
          iconColor: Colors.green,
        ),

        DrawerActionTile(
          icon: Icons.schedule,
          title: 'Bài chưa nộp',
          subtitle: '$pendingAssignments bài tập chưa nộp',
          onTap: () {
            _handleAction(context, onViewPendingAssignments);
          },
          iconColor: Colors.orange,
          showNotificationDot: pendingAssignments > 0,
        ),

        DrawerActionTile(
          icon: Icons.grade,
          title: 'Bài đã chấm',
          subtitle: '8 bài tập đã có điểm',
          onTap: () {
            _handleAction(context, onViewGradedAssignments);
          },
          iconColor: colorScheme.primary,
        ),

        DrawerActionTile(
          icon: Icons.calendar_today,
          title: 'Lịch nộp bài',
          subtitle: 'Xem lịch nộp bài tập',
          onTap: () {
            _handleAction(context, onViewAssignmentSchedule);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),
      ],
    );
  }

  /// Phần cài đặt hiển thị
  Widget _buildDisplaySettingsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'CÀI ĐẶT HIỂN THỊ',
          icon: Icons.display_settings_outlined,
        ),

        DrawerToggleTile(
          icon: Icons.dark_mode,
          title: 'Chế độ tối',
          subtitle: 'Bật chế độ tối cho ứng dụng',
          value: false,
          onChanged: (value) {
            // TODO: Cập nhật chế độ tối
          },
        ),

        DrawerActionTile(
          icon: Icons.text_fields,
          title: 'Cỡ chữ',
          subtitle: 'Cỡ chữ trung bình',
          onTap: () {
            _handleAction(context, onChangeTextSize);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),

        DrawerActionTile(
          icon: Icons.color_lens,
          title: 'Màu sắc',
          subtitle: 'Chủ đề mặc định',
          onTap: () {
            _handleAction(context, onChangeTheme);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),

        DrawerActionTile(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          subtitle: 'Tiếng Việt',
          onTap: () {
            _handleAction(context, onChangeLanguage);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),
      ],
    );
  }

  /// Phần hỗ trợ
  Widget _buildSupportSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(title: 'HỖ TRỢ', icon: Icons.help_outline),

        DrawerActionTile(
          icon: Icons.email,
          title: 'Liên hệ giáo viên',
          subtitle: 'Gửi tin nhắn cho giáo viên',
          onTap: () {
            _handleAction(context, onContactTeacher);
          },
          iconColor: colorScheme.primary,
        ),

        DrawerActionTile(
          icon: Icons.bug_report,
          title: 'Báo cáo vấn đề',
          subtitle: 'Báo cáo lỗi hoặc vấn đề',
          onTap: () {
            _handleAction(context, onReportIssue);
          },
          iconColor: colorScheme.error,
        ),

        DrawerActionTile(
          icon: Icons.help,
          title: 'Trung tâm trợ giúp',
          subtitle: 'Xem hướng dẫn sử dụng',
          onTap: () {
            _handleAction(context, onOpenHelpCenter);
          },
          iconColor: colorScheme.onSurface.withOpacity(0.7),
        ),

        DrawerActionTile(
          icon: Icons.feedback,
          title: 'Gửi phản hồi',
          subtitle: 'Góp ý về ứng dụng',
          onTap: () {
            _handleAction(context, onSendFeedback);
          },
          iconColor: colorScheme.primary,
        ),
      ],
    );
  }
}


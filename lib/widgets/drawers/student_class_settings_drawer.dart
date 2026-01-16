import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/drawers/drawer_action_tile.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';

/// Drawer nội dung cài đặt lớp học dành cho học sinh
/// Hiển thị các tùy chọn cá nhân và cài đặt phù hợp với học sinh
class StudentClassSettingsDrawer extends StatelessWidget {
  final String className;
  final String semesterInfo;
  final String studentName;
  final int unreadNotifications;
  final int pendingAssignments;

  const StudentClassSettingsDrawer({
    super.key,
    required this.className,
    required this.semesterInfo,
    required this.studentName,
    this.unreadNotifications = 0,
    this.pendingAssignments = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Phần thông tin cá nhân
          _buildPersonalInfoSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần cài đặt thông báo
          _buildNotificationSettingsSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần quản lý bài tập
          _buildAssignmentManagementSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần cài đặt hiển thị
          _buildDisplaySettingsSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần hỗ trợ
          _buildSupportSection(context),

          // Padding cuối
          SizedBox(height: DesignSpacing.xxxl),
        ],
      ),
    );
  }

  /// Phần thông tin cá nhân
  Widget _buildPersonalInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'THÔNG TIN CÁ NHÂN',
          icon: Icons.person_outline,
        ),

        DrawerActionTile(
          icon: Icons.info_outline,
          title: 'Thông tin học sinh',
          subtitle: 'Xem thông tin cá nhân trong lớp',
          onTap: () {
            // TODO: Xem thông tin cá nhân
            Navigator.pop(context);
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.history,
          title: 'Lịch sử tham gia',
          subtitle: 'Ngày tham gia: 15/09/2023',
          onTap: () {
            // TODO: Xem lịch sử tham gia
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.assessment,
          title: 'Tiến độ học tập',
          subtitle: 'Xem điểm số và tiến độ cá nhân',
          onTap: () {
            // TODO: Xem tiến độ học tập
            Navigator.pop(context);
          },
          iconColor: DesignColors.primary,
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
            // TODO: Xem bài đã nộp
            Navigator.pop(context);
          },
          iconColor: Colors.green,
        ),

        DrawerActionTile(
          icon: Icons.schedule,
          title: 'Bài chưa nộp',
          subtitle: '$pendingAssignments bài tập chưa nộp',
          onTap: () {
            // TODO: Xem bài chưa nộp
            Navigator.pop(context);
          },
          iconColor: Colors.orange,
          showNotificationDot: pendingAssignments > 0,
        ),

        DrawerActionTile(
          icon: Icons.grade,
          title: 'Bài đã chấm',
          subtitle: '8 bài tập đã có điểm',
          onTap: () {
            // TODO: Xem bài đã chấm
            Navigator.pop(context);
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.calendar_today,
          title: 'Lịch nộp bài',
          subtitle: 'Xem lịch nộp bài tập',
          onTap: () {
            // TODO: Xem lịch nộp bài
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),
      ],
    );
  }

  /// Phần cài đặt hiển thị
  Widget _buildDisplaySettingsSection(BuildContext context) {
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
            // TODO: Chọn cỡ chữ
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.color_lens,
          title: 'Màu sắc',
          subtitle: 'Chủ đề mặc định',
          onTap: () {
            // TODO: Chọn chủ đề màu
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          subtitle: 'Tiếng Việt',
          onTap: () {
            // TODO: Chọn ngôn ngữ
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),
      ],
    );
  }

  /// Phần hỗ trợ
  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'HỖ TRỢ',
          icon: Icons.help_outline,
        ),

        DrawerActionTile(
          icon: Icons.email,
          title: 'Liên hệ giáo viên',
          subtitle: 'Gửi tin nhắn cho giáo viên',
          onTap: () {
            // TODO: Liên hệ giáo viên
            Navigator.pop(context);
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.bug_report,
          title: 'Báo cáo vấn đề',
          subtitle: 'Báo cáo lỗi hoặc vấn đề',
          onTap: () {
            // TODO: Báo cáo vấn đề
            Navigator.pop(context);
          },
          iconColor: Colors.red,
        ),

        DrawerActionTile(
          icon: Icons.help,
          title: 'Trung tâm trợ giúp',
          subtitle: 'Xem hướng dẫn sử dụng',
          onTap: () {
            // TODO: Xem trợ giúp
            Navigator.pop(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.feedback,
          title: 'Gửi phản hồi',
          subtitle: 'Góp ý về ứng dụng',
          onTap: () {
            // TODO: Gửi phản hồi
            Navigator.pop(context);
          },
          iconColor: DesignColors.primary,
        ),
      ],
    );
  }
}

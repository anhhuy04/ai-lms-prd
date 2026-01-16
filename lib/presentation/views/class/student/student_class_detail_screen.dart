import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/assignment_list.dart';
import 'package:ai_mls/widgets/search/smart_search_dialog_v2.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/drawers/student_class_settings_drawer.dart';

/// Màn hình chi tiết lớp học dành cho học sinh
/// Thiết kế theo chuẩn Design System với thông tin cá nhân và tiến độ học tập
class StudentClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String semesterInfo;
  final String studentName;

  const StudentClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.semesterInfo,
    required this.studentName,
  });

  @override
  State<StudentClassDetailScreen> createState() => _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  // State cho tìm kiếm
  final String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      endDrawer: ActionEndDrawer(
        title: 'Tùy chọn Lớp học',
        subtitle: widget.className,
        child: StudentClassSettingsDrawer(
          className: widget.className,
          semesterInfo: widget.semesterInfo,
          studentName: widget.studentName,
          unreadNotifications: 2,
          pendingAssignments: 3,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Quick Stats & Actions
                    _buildQuickStatsSection(context),
                    const SizedBox(height: 16),
                    // Student Progress Section
                    _buildStudentProgressSection(context),
                    const SizedBox(height: 16),
                    // Assignment List Section
                    _buildAssignmentListSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar với nút quay lại và thông tin lớp
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.all(DesignSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: DesignIcons.mdSize,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.className,
                  style: DesignTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  widget.semesterInfo,
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: DesignIcons.mdSize,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  _showSmartSearchDialog(context);
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: DesignIcons.mdSize,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Phần thống kê nhanh và thông tin cá nhân
  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message
          Text(
            'Xin chào, ${widget.studentName}!',
            style: DesignTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignColors.primary,
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          // Quick Stats Row
          _buildQuickStatsRow(context),
        ],
      ),
    );
  }

  /// Hàng thống kê nhanh cho học sinh
  Widget _buildQuickStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.assessment,
            iconColor: DesignColors.primary,
            value: '85%',
            label: 'Điểm trung bình',
            onTap: () {
              // TODO: Navigate to grade details
            },
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.assignment_turned_in,
            iconColor: Colors.green,
            value: '12/15',
            label: 'Bài đã nộp',
            onTap: () {
              // TODO: Navigate to submitted assignments
            },
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.schedule,
            iconColor: Colors.orange,
            value: '3',
            label: 'Sắp đến hạn',
            onTap: () {
              // TODO: Navigate to upcoming assignments
            },
          ),
        ),
      ],
    );
  }

  /// Card thống kê đơn lẻ
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [DesignElevation.level1],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: DesignIcons.lgSize, color: iconColor),
                Icon(
                  Icons.chevron_right,
                  size: DesignIcons.smSize,
                  color: DesignColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              value,
              style: DesignTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              label,
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Phần tiến độ học tập cá nhân
  Widget _buildStudentProgressSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Progress Card
          _buildStudentProgressCard(context),
        ],
      ),
    );
  }

  /// Card tiến độ học tập
  Widget _buildStudentProgressCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignColors.primary.withOpacity(0.1), DesignColors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: DesignColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [DesignElevation.level1],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignColors.primary.withOpacity(0.2),
            ),
            child: Icon(
              Icons.assessment,
              size: DesignIcons.mdSize,
              color: DesignColors.primary,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Xem điểm số và tiến độ cá nhân',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              textStyle: DesignTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // TODO: Navigate to student progress screen
            },
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }

  /// Phần danh sách bài tập
  Widget _buildAssignmentListSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header danh sách
          _buildAssignmentListHeader(),
          SizedBox(height: DesignSpacing.md),
          // Danh sách bài tập
          _buildAssignmentList(context),
        ],
      ),
    );
  }

  /// Header danh sách bài tập
  Widget _buildAssignmentListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Danh sách bài tập',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all assignments
          },
          child: Text(
            'Xem tất cả',
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Danh sách bài tập cho học sinh
  Widget _buildAssignmentList(BuildContext context) {
    // Dữ liệu mẫu cho danh sách bài tập của học sinh
    final List<Map<String, dynamic>> sampleAssignments = [
      {
        'id': '1',
        'title': 'Toán Đại Số - Chương 1: Hàm Số',
        'dueDate': 'Hôm nay, 23:59',
        'status': 'active',
        'studentStatus': 'submitted', // Trạng thái của học sinh
        'score': '9.5', // Điểm nếu đã chấm
        'icon': 'calculate',
        'classInfo': 'Lớp 10A1',
      },
      {
        'id': '2',
        'title': 'Ngữ Văn - Phân tích tác phẩm',
        'dueDate': '15/10/2023',
        'status': 'new',
        'studentStatus': 'not_submitted', // Chưa nộp
        'icon': 'menu_book',
        'classInfo': 'Lớp 11B2',
      },
      {
        'id': '3',
        'title': 'Vật Lý - Bài tập Quang học',
        'dueDate': '15/10/2023',
        'status': 'closed',
        'studentStatus': 'graded', // Đã chấm điểm
        'score': '8.0',
        'icon': 'science',
        'classInfo': 'Lớp 12A5',
      },
    ];

    return AssignmentList(
      assignments: sampleAssignments,
      viewMode: AssignmentViewMode.student,
      onItemTap: (assignment) {
        // TODO: Navigate to assignment detail or action based on studentStatus
      },
    );
  }

  /// Hiển thị Smart Search Dialog V2 - Thiết kế mới
  void _showSmartSearchDialog(BuildContext context) {
    // Dữ liệu bài tập từ danh sách hiện có
    final List<Map<String, dynamic>> assignments = [
      {
        'id': '1',
        'title': 'Toán Đại Số - Chương 1: Hàm Số',
        'subtitle': 'Lớp 10A1 • Hôm nay, 23:59',
      },
      {
        'id': '2',
        'title': 'Ngữ Văn - Phân tích tác phẩm',
        'subtitle': 'Lớp 11B2 • 15/10/2023',
      },
      {
        'id': '3',
        'title': 'Vật Lý - Bài tập Quang học',
        'subtitle': 'Lớp 12A5 • 15/10/2023',
      },
    ];

    // Dữ liệu học sinh
    final List<Map<String, dynamic>> students = [
      {
        'id': '1',
        'title': 'Nguyễn Văn An',
        'subtitle': 'Lớp 12A1',
      },
      {
        'id': '2',
        'title': 'Trần Thị Bích',
        'subtitle': 'Lớp 11A3',
      },
      {
        'id': '3',
        'title': 'Lê Minh Cường',
        'subtitle': 'Lớp 9A1',
      },
    ];

    // Dữ liệu lớp học
    final List<Map<String, dynamic>> classes = [
      {
        'id': '1',
        'title': 'Lớp 10A1 - Toán',
        'subtitle': 'Giáo viên: Nguyễn Văn A',
      },
      {
        'id': '2',
        'title': 'Lớp 11B2 - Ngữ Văn',
        'subtitle': 'Giáo viên: Trần Thị B',
      },
      {
        'id': '3',
        'title': 'Lớp 12A5 - Vật Lý',
        'subtitle': 'Giáo viên: Lê Minh C',
      },
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => SmartSearchDialogV2(
        initialQuery: _searchQuery,
        assignments: assignments,
        students: students,
        classes: classes,
        onItemSelected: (item) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn: ${item['title']}')),
          );
        },
      ),
    );
  }
}
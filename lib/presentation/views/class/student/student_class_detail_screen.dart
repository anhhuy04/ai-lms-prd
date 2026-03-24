// ignore_for_file: use_build_context_synchronously
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/class/student/widgets/drawers/student_class_settings_drawer.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/list/class_detail_assignment_list.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/search/dialogs/quick_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết lớp học dành cho học sinh
/// Thiết kế theo chuẩn Design System với thông tin cá nhân và tiến độ học tập
class StudentClassDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState
    extends ConsumerState<StudentClassDetailScreen> {
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
          onLeaveClass: () => _handleLeaveClass(context),
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
                child: RepaintBoundary(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
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
    // Watch assignments provider để tính stats
    final assignmentsAsync = ref.watch(
      studentClassAssignmentsProvider(widget.classId),
    );

    // Tính stats từ real data
    final totalAssignments =
        assignmentsAsync.whenOrNull(data: (list) => list.length) ?? 0;
    final upcomingCount =
        assignmentsAsync.whenOrNull(
          data: (list) {
            final now = DateTime.now();
            final sevenDaysLater = now.add(const Duration(days: 7));
            return list.where((a) {
              final dueAt = a['distribution_due_at'] as String?;
              if (dueAt == null) return false;
              final due = DateTime.tryParse(dueAt);
              return due != null &&
                  due.isAfter(now) &&
                  due.isBefore(sevenDaysLater);
            }).length;
          },
        ) ??
        0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.assessment,
            iconColor: DesignColors.primary,
            value: '--',
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
            value: '$totalAssignments',
            label: 'Bài tập',
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
            value: '$upcomingCount',
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
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignColors.primary.withValues(alpha: 0.1),
              DesignColors.white,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          boxShadow: [DesignElevation.level1],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignColors.primary.withValues(alpha: 0.2),
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
                context.pushNamed(
                  AppRoute.studentAnalytics,
                  extra: {'classId': widget.classId},
                );
              },
              child: const Text('Xem chi tiết'),
            ),
          ],
        ),
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

  /// Danh sách bài tập cho học sinh — real data từ Supabase với shimmer loading
  Widget _buildAssignmentList(BuildContext context) {
    final assignmentsAsync = ref.watch(
      studentClassAssignmentsProvider(widget.classId),
    );

    return assignmentsAsync.when(
      loading: () => const ShimmerAssignmentListLoading(),
      error: (error, _) => _buildAssignmentErrorState(context),
      data: (assignments) {
        return ClassDetailAssignmentList(
          assignments: assignments,
          viewMode: AssignmentViewMode.student,
          onItemTap: (assignment) {
            final distributionId = assignment['assignment_distribution_id']?.toString();
            if (distributionId != null) {
              context.pushNamed(
                AppRoute.studentAssignmentDetail,
                pathParameters: {'assignmentId': distributionId},
              );
            }
          },
        );
      },
    );
  }

  /// Error state cho danh sách bài tập
  Widget _buildAssignmentErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: DesignIcons.xlSize,
              color: DesignColors.error,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Không thể tải danh sách bài tập',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.error,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(studentClassAssignmentsProvider(widget.classId));
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị Smart Search Dialog V2 — dùng real data từ provider
  void _showSmartSearchDialog(BuildContext context) {
    // Lấy real assignments data (nếu đã load)
    final assignmentsAsync = ref.read(
      studentClassAssignmentsProvider(widget.classId),
    );
    final searchAssignments =
        assignmentsAsync.whenOrNull(
          data: (list) => list
              .map(
                (a) => <String, dynamic>{
                  'id': a['id'],
                  'title': a['title'] ?? 'Không có tiêu đề',
                  'subtitle':
                      '${widget.className} • ${a['distribution_due_at'] ?? 'Không hạn'}',
                },
              )
              .toList(),
        ) ??
        <Map<String, dynamic>>[];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => QuickSearchDialog(
        initialQuery: '',
        assignments: searchAssignments,
        students: const [], // Không cần student data cho student view
        classes: const [], // Đang ở trong chi tiết 1 lớp, không cần search lớp
        onItemSelected: (item) {
          if (dialogContext.canPop()) {
            dialogContext.pop();
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn: ${item['title']}')));
        },
      ),
    );
  }

  /// Xử lý khi học sinh rời lớp học
  Future<void> _handleLeaveClass(BuildContext context) async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận rời lớp'),
        content: Text(
          'Bạn có chắc chắn muốn rời lớp "${widget.className}"?\n\n'
          'Sau khi rời lớp, bạn sẽ không thể xem thông tin và bài tập của lớp này nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rời lớp'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return; // User cancelled
    }

    // Lấy studentId từ auth
    final auth = ref.read(authNotifierProvider);
    final studentId = auth.value?.id;
    if (studentId == null) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin học sinh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiển thị loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Gọi API để rời lớp
    final success = await ref
        .read(classNotifierProvider.notifier)
        .leaveClass(widget.classId, studentId);

    // Đóng loading dialog
    if (!mounted) return;
    Navigator.of(context).pop(); // Close loading dialog

    if (success) {
      // Hiển thị thông báo thành công
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã rời lớp "${widget.className}"'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate về danh sách lớp học
      if (!mounted) return;
      context.goNamed(AppRoute.studentClassList);
    } else {
      // Hiển thị thông báo lỗi
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể rời lớp. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

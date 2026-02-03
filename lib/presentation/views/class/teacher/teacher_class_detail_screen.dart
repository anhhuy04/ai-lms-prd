import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/drawers/class_settings_drawer.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/list/class_detail_assignment_list.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/search/dialogs/quick_search_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết lớp học dành cho giáo viên
/// Thiết kế theo chuẩn Design System với đầy đủ thông tin lớp học
class TeacherClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  final String semesterInfo;

  const TeacherClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.semesterInfo,
  });

  @override
  ConsumerState<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState
    extends ConsumerState<TeacherClassDetailScreen> {
  // State cho tìm kiếm
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // #region agent log
    if (kDebugMode && Platform.isWindows) {
      try {
        final logFile = File(
          'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
        );
        // ignore: discarded_futures
        logFile
            .writeAsString(
              '${jsonEncode({
                "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "location": "teacher_class_detail_screen.dart:35",
                "message": "TeacherClassDetailScreen initState",
                "data": {"classId": widget.classId, "className": widget.className, "semesterInfo": widget.semesterInfo},
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "F",
              })}\n',
              mode: FileMode.append,
              flush: false,
            )
            .catchError((_) => logFile);
      } catch (_) {}
    }
    // #endregion
    // Load class details khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // #region agent log
      if (kDebugMode && Platform.isWindows) {
        try {
          final logFile = File(
            'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
          );
          // ignore: discarded_futures
          logFile
              .writeAsString(
                '${jsonEncode({
                  "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                  "location": "teacher_class_detail_screen.dart:39",
                  "message": "About to load class details",
                  "data": {"classId": widget.classId, "mounted": mounted},
                  "sessionId": "debug-session",
                  "runId": "run1",
                  "hypothesisId": "F",
                })}\n',
                mode: FileMode.append,
                flush: false,
              )
              .catchError((_) => logFile);
        } catch (_) {}
      }
      // #endregion
      if (mounted) {
        try {
          ref
              .read(classNotifierProvider.notifier)
              .loadClassDetails(widget.classId)
              .catchError((error, stackTrace) {
                // #region agent log
                if (kDebugMode && Platform.isWindows) {
                  try {
                    final logFile = File(
                      'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
                    );
                    // ignore: discarded_futures
                    logFile
                        .writeAsString(
                          '${jsonEncode({
                            "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                            "timestamp": DateTime.now().millisecondsSinceEpoch,
                            "location": "teacher_class_detail_screen.dart:50",
                            "message": "Error loading class details",
                            "data": {"classId": widget.classId, "error": error.toString(), "stackTrace": stackTrace.toString()},
                            "sessionId": "debug-session",
                            "runId": "run1",
                            "hypothesisId": "F",
                          })}\n',
                          mode: FileMode.append,
                          flush: false,
                        )
                        .catchError((_) => logFile);
                  } catch (_) {}
                }
                // #endregion
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Lỗi khi tải thông tin lớp học: ${error.toString()}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
        } catch (e, stackTrace) {
          // #region agent log
          if (kDebugMode && Platform.isWindows) {
            try {
              final logFile = File(
                'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
              );
              // ignore: discarded_futures
              logFile
                  .writeAsString(
                    '${jsonEncode({
                      "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                      "location": "teacher_class_detail_screen.dart:65",
                      "message": "Exception in loadClassDetails call",
                      "data": {"classId": widget.classId, "error": e.toString(), "stackTrace": stackTrace.toString()},
                      "sessionId": "debug-session",
                      "runId": "run1",
                      "hypothesisId": "F",
                    })}\n',
                    mode: FileMode.append,
                    flush: false,
                  )
                  .catchError((_) => logFile);
            } catch (_) {}
          }
          // #endregion
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(classNotifierProvider.notifier)
        .loadClassDetails(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    // Watch ClassNotifier state để rebuild khi state thay đổi
    // Khi loadClassDetails() gọi state = state, nó sẽ trigger rebuild
    ref.watch(classNotifierProvider);

    // Lấy notifier và các giá trị hiện tại
    final classNotifier = ref.read(classNotifierProvider.notifier);
    final selectedClass = classNotifier.selectedClass;
    final isDetailLoading = classNotifier.isDetailLoading;
    final detailErrorMessage = classNotifier.detailErrorMessage;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawer: selectedClass == null
          ? null
          : ActionEndDrawer(
              title: 'Tùy chọn Lớp học',
              child: ClassSettingsDrawer(classItem: selectedClass),
            ),
      body: Builder(
        builder: (context) {
          // Loading state
          if (isDetailLoading && selectedClass == null) {
            return SafeArea(child: const ShimmerDashboardLoading());
          }

          // Error state
          if (detailErrorMessage != null && selectedClass == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detailErrorMessage,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _onRefresh(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (selectedClass == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text('Không tìm thấy lớp học', style: textTheme.bodyMedium),
                    if (detailErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        detailErrorMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _onRefresh(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  // Top App Bar
                  _buildAppBar(context, selectedClass),
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Quick Stats & Actions
                          _buildQuickStatsSection(context),
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
        },
      ),
    );
  }

  /// App Bar với nút quay lại và thông tin lớp
  Widget _buildAppBar(BuildContext context, dynamic classItem) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: navigate về class list nếu không thể pop
                context.goNamed(AppRoute.teacherClassList);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: theme.iconTheme.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  classItem.subject ?? classItem.academicYear ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
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
                  size: 22,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  _showSmartSearchDialog(context);
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 22,
                    color: theme.iconTheme.color,
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

  /// Phần thống kê nhanh và hành động
  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Row
          _buildQuickStatsRow(context),
          const SizedBox(height: 16),
          // Create New Action
          _buildCreateAssignmentCard(context),
        ],
      ),
    );
  }

  /// Hàng thống kê nhanh
  Widget _buildQuickStatsRow(BuildContext context) {
    // TODO: Tính approvedCount từ getClassMembers khi cần
    // Tạm thời dùng 0, sẽ tính sau khi có cache members trong ClassNotifier
    final approvedCount = 0;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.groups,
            iconColor: Theme.of(context).colorScheme.primary,
            value: '$approvedCount',
            label: 'Học sinh',
            onTap: () {
              // Navigate to student list using GoRouter
              context.goNamed(
                AppRoute.teacherStudentList,
                pathParameters: {'classId': widget.classId},
                extra: widget.className,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.assignment,
            iconColor: Colors.orange,
            value: '0', // Tạm thời hiển thị 0 (chưa có bảng assignments)
            label: 'Bài tập đang mở',
            onTap: () {
              // Navigate to assignment list using GoRouter
              context.go(AppRoute.teacherAssignmentListPath);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            value: '0%', // Tạm thời hiển thị 0% (chưa có bảng submissions)
            label: 'Tỷ lệ nộp bài',
            onTap: () {
              // TODO: Navigate to submission stats - Future work
              // Màn hình thống kê nộp bài chưa được implement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Chức năng thống kê nộp bài đang được phát triển',
                  ),
                ),
              );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: iconColor),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card tạo bài tập mới
  Widget _buildCreateAssignmentCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
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
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.2),
            ),
            child: Icon(Icons.add_task, size: 22, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo bài tập mới',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giao bài về nhà hoặc bài kiểm tra',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            onPressed: () {
              // Navigate to assignment list (placeholder for create flow)
              context.pushNamed(AppRoute.teacherAssignmentList);
            },
            child: const Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  /// Phần danh sách bài tập
  Widget _buildAssignmentListSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header danh sách
          _buildAssignmentListHeader(),
          const SizedBox(height: 12),
          // Danh sách bài tập
          _buildAssignmentList(context),
        ],
      ),
    );
  }

  /// Header danh sách bài tập
  Widget _buildAssignmentListHeader() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Danh sách bài tập',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // Navigate to all assignments
            context.pushNamed(AppRoute.teacherAssignmentList);
          },
          child: Text(
            'Xem tất cả',
            style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  /// Danh sách bài tập
  Widget _buildAssignmentList(BuildContext context) {
    // Dữ liệu mẫu cho danh sách bài tập
    final List<Map<String, dynamic>> sampleAssignments = [
      {
        'id': '1',
        'title': 'Toán Đại Số - Chương 1: Hàm Số',
        'dueDate': 'Hôm nay, 23:59',
        'status': 'active',
        'submitted': 25,
        'totalStudents': 45,
        'graded': 10,
        'ungraded': 15,
        'icon': 'calculate',
        'classInfo': 'Lớp 10A1',
      },
      {
        'id': '2',
        'title': 'Ngữ Văn - Phân tích tác phẩm',
        'dueDate': '15/10/2023',
        'status': 'new',
        'submitted': 12,
        'totalStudents': 38,
        'graded': 0,
        'ungraded': 12,
        'icon': 'menu_book',
        'classInfo': 'Lớp 11B2',
      },
      {
        'id': '3',
        'title': 'Vật Lý - Bài tập Quang học',
        'dueDate': '15/10/2023',
        'status': 'closed',
        'submitted': 40,
        'totalStudents': 40,
        'graded': 40,
        'ungraded': 0,
        'icon': 'science',
        'classInfo': 'Lớp 12A5',
      },
    ];

    return ClassDetailAssignmentList(
      assignments: sampleAssignments,
      viewMode: AssignmentViewMode.teacher,
      onItemTap: (assignment) {
        // TODO: Navigate to assignment detail - Future work
        // Màn hình chi tiết bài tập chưa được implement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chi tiết bài tập "${assignment['title']}" đang được phát triển',
            ),
          ),
        );
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
      {'id': '1', 'title': 'Nguyễn Văn An', 'subtitle': 'Lớp 12A1'},
      {'id': '2', 'title': 'Trần Thị Bích', 'subtitle': 'Lớp 11A3'},
      {'id': '3', 'title': 'Lê Minh Cường', 'subtitle': 'Lớp 9A1'},
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
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => QuickSearchDialog(
        initialQuery: _searchQuery,
        assignments: assignments,
        students: students,
        classes: classes,
        onItemSelected: (item) {
          if (context.canPop()) {
            context.pop();
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn: ${item['title']}')));
        },
      ),
    );
  }
}

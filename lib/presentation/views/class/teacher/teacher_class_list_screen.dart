import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/avatar_utils.dart';
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/widgets/class_item_widget.dart';
import 'package:ai_mls/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'create_class_screen.dart';
import 'teacher_class_detail_screen.dart';
import 'teacher_class_search_screen.dart';

/// Màn hình danh sách lớp học dành cho giáo viên
/// Sử dụng Riverpod + Infinite Scroll Pagination + Shimmer
/// Sử dụng AutomaticKeepAliveClientMixin để giữ state khi navigate away
class TeacherClassListScreen extends ConsumerStatefulWidget {
  const TeacherClassListScreen({super.key});

  @override
  ConsumerState<TeacherClassListScreen> createState() =>
      _TeacherClassListScreenState();
}

class _TeacherClassListScreenState extends ConsumerState<TeacherClassListScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true; // Giữ state khi navigate away

  @override
  void initState() {
    super.initState();

    // Restore scroll position sau khi data đã load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  /// Lưu scroll position vào provider
  void _saveScrollPosition() {
    final teacherId = ref.read(currentUserIdProvider);
    // #region agent log
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      logFile.writeAsStringSync(
        '${jsonEncode({
          "id": "log_${DateTime.now().millisecondsSinceEpoch}",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "location": "teacher_class_list_screen.dart:73",
          "message": "Saving scroll position",
          "data": {"teacherId": teacherId, "hasClients": _scrollController.hasClients, "offset": _scrollController.hasClients ? _scrollController.offset : 0},
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "D",
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
    if (teacherId != null && _scrollController.hasClients) {
      ref.read(scrollPositionProvider(teacherId).notifier).state =
          _scrollController.offset;
    }
  }

  /// Restore scroll position từ provider
  void _restoreScrollPosition() {
    final teacherId = ref.read(currentUserIdProvider);
    // #region agent log
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      logFile.writeAsStringSync(
        '${jsonEncode({
          "id": "log_${DateTime.now().millisecondsSinceEpoch}",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "location": "teacher_class_list_screen.dart:82",
          "message": "Attempting to restore scroll position",
          "data": {"teacherId": teacherId, "hasClients": _scrollController.hasClients},
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "D",
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
    if (teacherId != null && _scrollController.hasClients) {
      final savedPosition = ref.read(scrollPositionProvider(teacherId));
      // #region agent log
      try {
        final logFile = File(
          'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
        );
        logFile.writeAsStringSync(
          '${jsonEncode({
            "id": "log_${DateTime.now().millisecondsSinceEpoch}",
            "timestamp": DateTime.now().millisecondsSinceEpoch,
            "location": "teacher_class_list_screen.dart:86",
            "message": "Restoring scroll position",
            "data": {"teacherId": teacherId, "savedPosition": savedPosition, "hasClients": _scrollController.hasClients},
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "D",
          })}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion
      if (savedPosition > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(savedPosition);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Watch current user ID
    final teacherId = ref.watch(currentUserIdProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // #region agent log
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      logFile.writeAsStringSync(
        '${jsonEncode({
          "id": "log_${DateTime.now().millisecondsSinceEpoch}",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "location": "teacher_class_list_screen.dart:200",
          "message": "Build method - checking user state",
          "data": {"isLoading": currentUserAsync.isLoading, "hasError": currentUserAsync.hasError, "error": currentUserAsync.hasError ? currentUserAsync.error.toString() : null, "hasValue": currentUserAsync.hasValue, "valueIsNull": currentUserAsync.value == null, "teacherId": teacherId, "userIdFromValue": currentUserAsync.value?.id},
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "E",
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Loading state khi đang lấy user info
    if (currentUserAsync.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error state khi không lấy được user info
    if (currentUserAsync.hasError || teacherId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy thông tin giáo viên',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Watch providers
    // #region agent log
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      logFile.writeAsStringSync(
        '${jsonEncode({
          "id": "log_${DateTime.now().millisecondsSinceEpoch}",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "location": "teacher_class_list_screen.dart:256",
          "message": "Watching providers",
          "data": {"teacherId": teacherId},
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "G",
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}

    final pagingController = ref.watch(pagingControllerProvider(teacherId));
    final sortOption = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // #region agent log
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      logFile.writeAsStringSync(
        '${jsonEncode({
          "id": "log_${DateTime.now().millisecondsSinceEpoch}",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "location": "teacher_class_list_screen.dart:275",
          "message": "Providers watched successfully",
          "data": {"hasItemList": pagingController.itemList != null, "itemListLength": pagingController.itemList?.length ?? 0},
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "G",
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, currentUserAsync.value),
            const SizedBox(height: 12),
            // Card tạo lớp học mới
            _buildCreateClassCard(context),
            const SizedBox(height: 16),
            // Danh sách lớp học với PagedListView
            Expanded(
              child: _buildClassList(
                context,
                pagingController,
                sortOption,
                searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header với tiêu đề và avatar
  Widget _buildHeader(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lớp học của tôi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Năm học 2023 - 2024',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeacherClassSearchScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications, size: 20),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              const SizedBox(width: 6),
              AvatarUtils.buildAvatar(profile: profile),
            ],
          ),
        ],
      ),
    );
  }

  /// Card tạo lớp học mới
  Widget _buildCreateClassCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: Icon(Icons.domain_add, size: 18, color: Colors.blue[800]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm Lớp học mới',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tạo không gian lớp học để quản lý',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const CreateClassScreen(),
                    ),
                  )
                  .then((newClass) {
                    // Reload danh sách khi tạo lớp mới
                    if (newClass != null && mounted) {
                      final teacherId = ref.read(currentUserIdProvider);
                      if (teacherId != null) {
                        ref.read(pagingControllerProvider(teacherId)).refresh();
                      }
                    }
                  });
            },
            child: const Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  /// Danh sách lớp học với PagedListView
  Widget _buildClassList(
    BuildContext context,
    PagingController<int, Class> pagingController,
    ClassSortOption sortOption,
    String? searchQuery,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header danh sách với sort button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách lớp',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // TODO: Implement filter
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.sort, size: 18, color: Colors.grey[600]),
                    onPressed: () {
                      _showSortDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // PagedListView
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() {
              try {
                pagingController.refresh();
              } catch (e) {
                // #region agent log
                try {
                  final logFile = File(
                    'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
                  );
                  logFile.writeAsStringSync(
                    '${jsonEncode({
                      "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                      "location": "teacher_class_list_screen.dart:540",
                      "message": "Error refreshing pagingController",
                      "data": {"error": e.toString()},
                      "sessionId": "debug-session",
                      "runId": "run1",
                      "hypothesisId": "G",
                    })}\n',
                    mode: FileMode.append,
                  );
                } catch (_) {}
                // #endregion
              }
            }),
            child: PagedListView<int, Class>(
              pagingController: pagingController,
              scrollController: _scrollController,
              builderDelegate: PagedChildBuilderDelegate<Class>(
                itemBuilder: (context, classItem, index) {
                  // #region agent log
                  try {
                    final logFile = File(
                      'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
                    );
                    logFile.writeAsStringSync(
                      '${jsonEncode({
                        "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                        "timestamp": DateTime.now().millisecondsSinceEpoch,
                        "location": "teacher_class_list_screen.dart:582",
                        "message": "Building class item",
                        "data": {"index": index, "classId": classItem.id, "className": classItem.name},
                        "sessionId": "debug-session",
                        "runId": "run1",
                        "hypothesisId": "G",
                      })}\n',
                      mode: FileMode.append,
                    );
                  } catch (_) {}
                  // #endregion

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClassItemWidget(
                      className: classItem.name,
                      roomInfo: classItem.subject ?? 'Chưa có môn học',
                      schedule: classItem.academicYear ?? 'Chưa có năm học',
                      studentCount: 0, // TODO: Load từ class members
                      ungradedCount: 0, // TODO: Load từ class members
                      iconName: 'school',
                      iconColor: Colors.blue,
                      hasAssignments: true,
                      onTap: () {
                        // #region agent log
                        try {
                          final logFile = File(
                            'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
                          );
                          logFile.writeAsStringSync(
                            '${jsonEncode({
                              "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                              "timestamp": DateTime.now().millisecondsSinceEpoch,
                              "location": "teacher_class_list_screen.dart:522",
                              "message": "Navigating to class detail",
                              "data": {"classId": classItem.id, "className": classItem.name, "mounted": mounted},
                              "sessionId": "debug-session",
                              "runId": "run1",
                              "hypothesisId": "F",
                            })}\n',
                            mode: FileMode.append,
                          );
                        } catch (_) {}
                        // #endregion
                        if (mounted) {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherClassDetailScreen(
                                        classId: classItem.id,
                                        className: classItem.name,
                                        semesterInfo:
                                            classItem.academicYear ??
                                            'Chưa có năm học',
                                      ),
                                ),
                              )
                              .catchError((error) {
                                // #region agent log
                                try {
                                  final logFile = File(
                                    'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
                                  );
                                  logFile.writeAsStringSync(
                                    '${jsonEncode({
                                      "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                                      "location": "teacher_class_list_screen.dart:540",
                                      "message": "Navigation error",
                                      "data": {"error": error.toString()},
                                      "sessionId": "debug-session",
                                      "runId": "run1",
                                      "hypothesisId": "F",
                                    })}\n',
                                    mode: FileMode.append,
                                  );
                                } catch (_) {}
                                // #endregion
                              });
                        }
                      },
                    ),
                  );
                },
                firstPageProgressIndicatorBuilder: (context) =>
                    const ShimmerLoading(),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                firstPageErrorIndicatorBuilder: (context) =>
                    _buildErrorWidget(context, pagingController),
                newPageErrorIndicatorBuilder: (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Lỗi khi tải thêm dữ liệu',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              pagingController.retryLastFailedRequest(),
                          child: Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
                noItemsFoundIndicatorBuilder: (context) =>
                    _buildEmptyState(searchQuery),
                noMoreItemsIndicatorBuilder: (context) => _buildNoMoreItems(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Error widget
  Widget _buildErrorWidget(
    BuildContext context,
    PagingController<int, Class> pagingController,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pagingController.error?.toString() ??
                  'Không thể tải danh sách lớp học',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => pagingController.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state widget - phân biệt search vs no data
  Widget _buildEmptyState(String? searchQuery) {
    final isSearching = searchQuery != null && searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Không tìm thấy lớp học nào'
                  : 'Chưa có lớp học nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Thử tìm kiếm với từ khóa khác'
                  : 'Tạo lớp học đầu tiên của bạn',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// No more items widget
  Widget _buildNoMoreItems() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Đã hiển thị tất cả lớp học',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  /// Sort dialog
  void _showSortDialog(BuildContext context) {
    final currentSortOption = ref.read(sortOptionProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sắp xếp lớp học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            const Divider(),
            // Sort options
            _buildSortOption(
              context,
              'Tên lớp (A-Z)',
              ClassSortOption.nameAscending,
              Icons.sort_by_alpha,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Tên lớp (Z-A)',
              ClassSortOption.nameDescending,
              Icons.sort_by_alpha,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Mới nhất',
              ClassSortOption.dateNewest,
              Icons.access_time,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Cũ nhất',
              ClassSortOption.dateOldest,
              Icons.access_time,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Môn học (A-Z)',
              ClassSortOption.subjectAscending,
              Icons.subject,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Môn học (Z-A)',
              ClassSortOption.subjectDescending,
              Icons.subject,
              currentSortOption,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    ClassSortOption option,
    IconData icon,
    ClassSortOption currentOption,
  ) {
    final isSelected = currentOption == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? DesignColors.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? DesignColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: DesignColors.primary)
          : null,
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        Navigator.pop(context);
      },
    );
  }
}

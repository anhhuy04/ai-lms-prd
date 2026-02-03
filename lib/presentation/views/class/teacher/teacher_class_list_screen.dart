import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/views/class/widgets/class_primary_action_card.dart';
import 'package:ai_mls/presentation/views/class/widgets/class_screen_header.dart';
import 'package:ai_mls/widgets/dialogs/class_sort_bottom_sheet.dart';
import 'package:ai_mls/widgets/list_item/class/class_item_widget.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  void deactivate() {
    // Lưu scroll position trước khi widget bị deactivate
    // Delay việc modify provider để tránh lỗi "modify provider while building"
    Future(() {
      if (mounted) {
        _saveScrollPosition();
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Lưu scroll position vào provider
  void _saveScrollPosition() {
    // Kiểm tra mounted và scroll controller trước khi sử dụng ref
    if (!mounted || !_scrollController.hasClients) return;

    final teacherId = ref.read(currentUserIdProvider);
    if (mounted && teacherId != null && _scrollController.hasClients) {
      ref.read(scrollPositionProvider(teacherId).notifier).state =
          _scrollController.offset;
    }
  }

  /// Restore scroll position từ provider
  void _restoreScrollPosition() {
    final teacherId = ref.read(currentUserIdProvider);
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
                "location": "teacher_class_list_screen.dart:82",
                "message": "Attempting to restore scroll position",
                "data": {"teacherId": teacherId, "hasClients": _scrollController.hasClients},
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "D",
              })}\n',
              mode: FileMode.append,
              flush: false,
            )
            .catchError((_) => logFile);
      } catch (_) {}
    }
    // #endregion
    if (teacherId != null && _scrollController.hasClients) {
      final savedPosition = ref.read(scrollPositionProvider(teacherId));
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
                  "location": "teacher_class_list_screen.dart:86",
                  "message": "Restoring scroll position",
                  "data": {"teacherId": teacherId, "savedPosition": savedPosition, "hasClients": _scrollController.hasClients},
                  "sessionId": "debug-session",
                  "runId": "run1",
                  "hypothesisId": "D",
                })}\n',
                mode: FileMode.append,
                flush: false,
              )
              .catchError((_) => logFile);
        } catch (_) {}
      }
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
                "location": "teacher_class_list_screen.dart:200",
                "message": "Build method - checking user state",
                "data": {"isLoading": currentUserAsync.isLoading, "hasError": currentUserAsync.hasError, "error": currentUserAsync.hasError ? currentUserAsync.error.toString() : null, "hasValue": currentUserAsync.hasValue, "valueIsNull": currentUserAsync.value == null, "teacherId": teacherId, "userIdFromValue": currentUserAsync.value?.id},
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "E",
              })}\n',
              mode: FileMode.append,
              flush: false,
            )
            .catchError((_) => logFile);
      } catch (_) {}
    }
    // #endregion

    // Loading state khi đang lấy user info
    if (currentUserAsync.isLoading) {
      return const Scaffold(body: ShimmerLoading());
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
                "location": "teacher_class_list_screen.dart:256",
                "message": "Watching providers",
                "data": {"teacherId": teacherId},
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "G",
              })}\n',
              mode: FileMode.append,
              flush: false,
            )
            .catchError((_) => logFile);
      } catch (_) {}
    }

    final pagingController = ref.watch(pagingControllerProvider(teacherId));
    final sortOption = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(searchQueryProvider);

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
                "location": "teacher_class_list_screen.dart:275",
                "message": "Providers watched successfully",
                "data": {"hasItemList": pagingController.itemList != null, "itemListLength": pagingController.itemList?.length ?? 0},
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "G",
              })}\n',
              mode: FileMode.append,
              flush: false,
            )
            .catchError((_) => logFile);
      } catch (_) {}
    }
    // #endregion

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
    );
  }

  /// Header với tiêu đề và avatar
  Widget _buildHeader(BuildContext context, profile) {
    return ClassScreenHeader(
      onSearch: () {
        context.pushNamed(AppRoute.teacherClassSearch);
      },
      onNotifications: () {
        // TODO: Implement notifications
      },
      profile: profile,
    );
  }

  /// Card tạo lớp học mới
  Widget _buildCreateClassCard(BuildContext context) {
    return ClassPrimaryActionCard.forTeacher(
      onPressed: () {
        context.pushNamed(AppRoute.teacherCreateClass).then((newClass) {
          // Reload danh sách khi tạo lớp mới
          if (newClass != null && mounted) {
            final teacherId = ref.read(currentUserIdProvider);
            if (teacherId != null) {
              ref.read(pagingControllerProvider(teacherId)).refresh();
            }
          }
        });
      },
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
                            "location": "teacher_class_list_screen.dart:540",
                            "message": "Error refreshing pagingController",
                            "data": {"error": e.toString()},
                            "sessionId": "debug-session",
                            "runId": "run1",
                            "hypothesisId": "G",
                          })}\n',
                          mode: FileMode.append,
                          flush: false,
                        )
                        .catchError((_) => logFile);
                  } catch (_) {}
                }
                // #endregion
              }
            }),
            child: PagedListView<int, Class>(
              pagingController: pagingController,
              scrollController: _scrollController,
              builderDelegate: PagedChildBuilderDelegate<Class>(
                itemBuilder: (context, classItem, index) {
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
                              "location": "teacher_class_list_screen.dart:582",
                              "message": "Building class item",
                              "data": {"index": index, "classId": classItem.id, "className": classItem.name},
                              "sessionId": "debug-session",
                              "runId": "run1",
                              "hypothesisId": "G",
                            })}\n',
                            mode: FileMode.append,
                            flush: false,
                          )
                          .catchError((_) => logFile);
                    } catch (_) {}
                  }
                  // #endregion

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClassItemWidget(
                      className: classItem.name,
                      roomInfo: classItem.subject ?? 'Chưa có môn học',
                      schedule: classItem.academicYear ?? 'Chưa có năm học',
                      // Với giáo viên, teacherName không cần hiển thị (giáo viên hiện tại),
                      // nên để null để ClassItemWidget bỏ qua dòng GV.
                      teacherName: null,
                      memberStatus: null,
                      studentCount: classItem.studentCount ?? 0,
                      ungradedCount: 0, // TODO: Load từ class members
                      iconName: 'school',
                      iconColor: Colors.blue,
                      hasAssignments: true,
                      onTap: () {
                        if (!mounted) return;

                        // Navigate to class detail screen
                        // Sử dụng context.push() với path thay vì pushNamed() để đảm bảo route match đúng
                        final classDetailPath = AppRoute.teacherClassDetailPath(
                          classItem.id,
                        );

                        context
                            .push(
                              classDetailPath,
                              extra: {
                                'className': classItem.name,
                                'semesterInfo':
                                    classItem.academicYear ?? 'Chưa có năm học',
                              },
                            )
                            .catchError((error) {
                              // Log error nếu có
                              if (!context.mounted) return null;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể mở chi tiết lớp học: ${error.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return null; // Return null để satisfy linter
                            });
                      },
                    ),
                  );
                },
                firstPageProgressIndicatorBuilder: (context) =>
                    const ShimmerLoading(),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ShimmerLoading(),
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
    ClassSortBottomSheet.show(
      context,
      currentSortOption: currentSortOption,
      onSortOptionSelected: (option) {
        if (!mounted) return;
        ref.read(sortOptionProvider.notifier).state = option;
      },
    );
  }
}

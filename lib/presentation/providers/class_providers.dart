import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/fetchers/class_list_fetcher.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'class_providers.g.dart';

Future<void> _writeClassLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
  required String hypothesisId,
}) async {
  if (!kDebugMode) return;
  final logEntry = {
    'sessionId': 'debug-session',
    'runId': 'run1',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  if (Platform.isWindows) {
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      await logFile.parent.create(recursive: true);
      await logFile.writeAsString(
        '${jsonEncode(logEntry)}\n',
        mode: FileMode.append,
        flush: false,
      );
    } catch (_) {}
  }
}

/// Provider cho SchoolClassRepository (dùng @riverpod để codegen)
@riverpod
SchoolClassRepository schoolClassRepository(Ref ref) {
  throw UnimplementedError('Must override schoolClassRepositoryProvider');
}

/// Provider cho search query (debounced) - dùng cho danh sách lớp giáo viên
final searchQueryProvider = StateProvider<String?>((ref) => null);

/// Provider cho sort option của giáo viên
final sortOptionProvider = StateProvider<ClassSortOption>(
  (ref) => ClassSortOption.dateNewest,
);

/// Provider cho sort option của học sinh (student class list)
final studentClassSortOptionProvider = StateProvider<ClassSortOption>(
  (ref) => ClassSortOption.dateNewest,
);

/// Lọc danh sách lớp cho học sinh theo trạng thái tham gia
enum StudentClassFilterOption { all, approved, pending }

/// Provider cho filter trạng thái lớp của học sinh
final studentClassFilterOptionProvider =
    StateProvider<StudentClassFilterOption>(
      (ref) => StudentClassFilterOption.all,
    );

/// Provider cho scroll position (lưu để restore)
final scrollPositionProvider = StateProvider.family<double, String>(
  (ref, teacherId) => 0.0,
);

/// Provider cho ClassListFetcher (family provider với teacherId)
final classListFetcherProvider = Provider.family<ClassListFetcher, String>((
  ref,
  teacherId,
) {
  final repository = ref.watch(schoolClassRepositoryProvider);
  return ClassListFetcher(repository: repository, teacherId: teacherId);
});

/// Provider cho search query riêng cho Search Screen (auto-dispose)
/// Tách biệt với searchQueryProvider của List Screen
final searchScreenQueryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Provider cho search query riêng cho Student Search Screen (auto-dispose)
final studentSearchScreenQueryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Provider cho PagingController riêng cho Search Screen (auto-dispose)
/// Tự động dispose khi người dùng thoát màn hình Search
final searchPagingControllerProvider = StateProvider.autoDispose
    .family<PagingController<int, Class>, String>((ref, teacherId) {
      final controller = PagingController<int, Class>(firstPageKey: 0);
      final fetcher = ref.watch(classListFetcherProvider(teacherId));

      // Lắng nghe thay đổi search query
      ref.listen<String?>(searchScreenQueryProvider, (previous, next) {
        controller.refresh();
      });

      // Lắng nghe thay đổi sort option (dùng chung với List Screen)
      ref.listen<ClassSortOption>(sortOptionProvider, (previous, next) {
        controller.refresh();
      });

      // Setup page request listener
      controller.addPageRequestListener((pageKey) async {
        // #region agent log
        unawaited(
          _writeClassLog(
            location: 'class_providers.dart:64',
            message: 'Search page request',
            data: {
              'pageKey': pageKey,
              'teacherId': teacherId,
              'searchQuery': ref.read(searchScreenQueryProvider),
            },
            hypothesisId: 'H3',
          ),
        );
        // #endregion
        try {
          final searchQuery = ref.read(searchScreenQueryProvider);
          final sortOption = ref.read(sortOptionProvider);

          // Tạo request ID để track request và xử lý race condition
          final requestId =
              '${searchQuery ?? ''}_${pageKey}_${DateTime.now().millisecondsSinceEpoch}';

          final classes = await fetcher.fetchPage(
            pageKey: pageKey,
            searchQuery: searchQuery,
            sortOption: sortOption,
            requestId: requestId,
          );

          // Kiểm tra lại search query sau khi fetch xong
          // Nếu query đã thay đổi, bỏ qua kết quả này
          final currentQuery = ref.read(searchScreenQueryProvider);
          if (currentQuery != searchQuery) {
            return; // Bỏ qua kết quả cũ
          }

          final isLastPage = classes.length < ClassListFetcher.pageSize;

          if (isLastPage) {
            controller.appendLastPage(classes);
          } else {
            final nextPageKey = pageKey + 1;
            controller.appendPage(classes, nextPageKey);
          }
        } catch (error) {
          // #region agent log
          unawaited(
            _writeClassLog(
              location: 'class_providers.dart:95',
              message: 'Search page fetch error',
              data: {
                'pageKey': pageKey,
                'error': error.toString(),
                'teacherId': teacherId,
              },
              hypothesisId: 'H3',
            ),
          );
          // #endregion
          // Phân loại error
          Exception userFriendlyError;

          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('network') ||
              errorStr.contains('timeout') ||
              errorStr.contains('socket')) {
            userFriendlyError = Exception(
              'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
            );
          } else if (errorStr.contains('401') ||
              errorStr.contains('unauthorized') ||
              errorStr.contains('jwt')) {
            userFriendlyError = Exception(
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
            );
          } else if (errorStr.contains('403') ||
              errorStr.contains('forbidden')) {
            userFriendlyError = Exception(
              'Bạn không có quyền truy cập danh sách này.',
            );
          } else {
            userFriendlyError = Exception(
              'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
            );
          }

          controller.error = userFriendlyError;
        }
      });

      // Cleanup khi dispose
      ref.onDispose(() {
        controller.dispose();
      });

      return controller;
    });

/// Provider cho PagingController (family provider với teacherId)
/// KHÔNG dùng autoDispose để giữ cache khi navigate away
final pagingControllerProvider =
    StateProvider.family<PagingController<int, Class>, String>((
      ref,
      teacherId,
    ) {
      final controller = PagingController<int, Class>(firstPageKey: 0);
      final fetcher = ref.watch(classListFetcherProvider(teacherId));

      // Lắng nghe thay đổi search query
      ref.listen<String?>(searchQueryProvider, (previous, next) {
        // #region agent log
        unawaited(
          _writeClassLog(
            location: 'class_providers.dart:47',
            message: 'Search query changed, refreshing controller',
            data: {'previous': previous, 'next': next, 'teacherId': teacherId},
            hypothesisId: 'B',
          ),
        );
        // #endregion
        controller.refresh();
      });

      // Lắng nghe thay đổi sort option
      ref.listen<ClassSortOption>(sortOptionProvider, (previous, next) {
        // #region agent log
        unawaited(
          _writeClassLog(
            location: 'class_providers.dart:52',
            message: 'Sort option changed, refreshing controller',
            data: {
              'previous': previous.toString(),
              'next': next.toString(),
              'teacherId': teacherId,
            },
            hypothesisId: 'B',
          ),
        );
        // #endregion
        controller.refresh();
      });

      // Setup page request listener
      controller.addPageRequestListener((pageKey) async {
        // #region agent log
        unawaited(
          _writeClassLog(
            location: 'class_providers.dart:57',
            message: 'Page request listener triggered',
            data: {'pageKey': pageKey, 'teacherId': teacherId},
            hypothesisId: 'B',
          ),
        );
        // #endregion
        try {
          // Lấy giá trị mới nhất của search và sort
          final searchQuery = ref.read(searchQueryProvider);
          final sortOption = ref.read(sortOptionProvider);

          // Tạo request ID để track request và xử lý race condition
          final requestId =
              '${searchQuery ?? ''}_${pageKey}_${DateTime.now().millisecondsSinceEpoch}';

          // #region agent log
          unawaited(
            _writeClassLog(
              location: 'class_providers.dart:63',
              message: 'Fetching page with params',
              data: {
                'pageKey': pageKey,
                'searchQuery': searchQuery,
                'sortOption': sortOption.toString(),
                'teacherId': teacherId,
                'requestId': requestId,
              },
              hypothesisId: 'B',
            ),
          );
          // #endregion

          final classes = await fetcher.fetchPage(
            pageKey: pageKey,
            searchQuery: searchQuery,
            sortOption: sortOption,
            requestId: requestId,
          );

          // Kiểm tra lại search query sau khi fetch xong
          // Nếu query đã thay đổi, bỏ qua kết quả này
          final currentQuery = ref.read(searchQueryProvider);
          if (currentQuery != searchQuery) {
            return; // Bỏ qua kết quả cũ
          }

          final isLastPage = classes.length < ClassListFetcher.pageSize;
          // #region agent log
          unawaited(
            _writeClassLog(
              location: 'class_providers.dart:71',
              message: 'Page fetched successfully',
              data: {
                'pageKey': pageKey,
                'classesCount': classes.length,
                'isLastPage': isLastPage,
                'pageSize': ClassListFetcher.pageSize,
              },
              hypothesisId: 'B',
            ),
          );
          // #endregion

          if (isLastPage) {
            controller.appendLastPage(classes);
          } else {
            final nextPageKey = pageKey + 1;
            controller.appendPage(classes, nextPageKey);
          }
        } catch (error) {
          // #region agent log
          unawaited(
            _writeClassLog(
              location: 'class_providers.dart:77',
              message: 'Page fetch error',
              data: {
                'pageKey': pageKey,
                'error': error.toString(),
                'teacherId': teacherId,
              },
              hypothesisId: 'B',
            ),
          );
          // #endregion
          // Phân loại error
          Exception userFriendlyError;

          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('network') ||
              errorStr.contains('timeout') ||
              errorStr.contains('socket')) {
            userFriendlyError = Exception(
              'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
            );
          } else if (errorStr.contains('401') ||
              errorStr.contains('unauthorized') ||
              errorStr.contains('jwt')) {
            userFriendlyError = Exception(
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
            );
          } else if (errorStr.contains('403') ||
              errorStr.contains('forbidden')) {
            userFriendlyError = Exception(
              'Bạn không có quyền truy cập danh sách này.',
            );
          } else {
            userFriendlyError = Exception(
              'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
            );
          }

          controller.error = userFriendlyError;
        }
      });

      // Cleanup
      ref.onDispose(() {
        controller.dispose();
      });

      // Giữ provider alive để cache state
      ref.keepAlive();

      return controller;
    });

/// Helper function để filter classes cho student search
List<Class> _filterStudentClassesForSearch(
  List<Class> classes,
  String? searchQuery,
) {
  if (searchQuery == null || searchQuery.isEmpty) {
    return classes;
  }

  final lowerQuery = searchQuery.toLowerCase();
  return classes.where((c) {
    final name = c.name.toLowerCase();
    final subject = (c.subject ?? '').toLowerCase();
    final teacherName = (c.teacherName ?? '').toLowerCase();

    return name.contains(lowerQuery) ||
        subject.contains(lowerQuery) ||
        teacherName.contains(lowerQuery);
  }).toList();
}

/// Provider cho PagingController riêng cho Student Search Screen (auto-dispose)
/// Sử dụng classNotifierProvider làm nguồn dữ liệu và filter client-side
final studentSearchPagingControllerProvider = StateProvider.autoDispose
    .family<PagingController<int, Class>, String>((ref, studentId) {
      final controller = PagingController<int, Class>(firstPageKey: 0);

      // Lắng nghe thay đổi search query
      ref.listen<String?>(studentSearchScreenQueryProvider, (previous, next) {
        controller.refresh();
      });

      // Lắng nghe thay đổi sort option
      ref.listen<ClassSortOption>(studentClassSortOptionProvider, (
        previous,
        next,
      ) {
        controller.refresh();
      });

      // Setup page request listener
      controller.addPageRequestListener((pageKey) async {
        try {
          // Load classes nếu chưa có
          final classState = ref.read(classNotifierProvider);
          if (!classState.hasValue) {
            await ref
                .read(classNotifierProvider.notifier)
                .loadClassesByStudent(studentId);
          }

          final classesState = ref.read(classNotifierProvider);
          final allClasses = classesState.value ?? [];

          // Filter theo search query
          final searchQuery = ref.read(studentSearchScreenQueryProvider);
          final filteredClasses = _filterStudentClassesForSearch(
            allClasses,
            searchQuery,
          );

          // Sort classes
          final sortOption = ref.read(studentClassSortOptionProvider);
          final sortedClasses = SortingUtils.sortClasses(
            filteredClasses,
            sortOption,
          );

          // Vì student không dùng pagination thật sự, trả về tất cả kết quả như một page
          controller.appendLastPage(sortedClasses);
        } catch (error) {
          // Phân loại error
          Exception userFriendlyError;

          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('network') ||
              errorStr.contains('timeout') ||
              errorStr.contains('socket')) {
            userFriendlyError = Exception(
              'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
            );
          } else if (errorStr.contains('401') ||
              errorStr.contains('unauthorized') ||
              errorStr.contains('jwt')) {
            userFriendlyError = Exception(
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
            );
          } else if (errorStr.contains('403') ||
              errorStr.contains('forbidden')) {
            userFriendlyError = Exception(
              'Bạn không có quyền truy cập danh sách này.',
            );
          } else {
            userFriendlyError = Exception(
              'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
            );
          }

          controller.error = userFriendlyError;
        }
      });

      // Cleanup khi dispose
      ref.onDispose(() {
        controller.dispose();
      });

      return controller;
    });

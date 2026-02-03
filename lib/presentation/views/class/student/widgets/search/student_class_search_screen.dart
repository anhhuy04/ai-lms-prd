import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/utils/student_class_interaction_handler.dart';
import 'package:ai_mls/widgets/list_item/class/class_item_widget.dart';
import 'package:ai_mls/widgets/search/screens/core/search_screen_config.dart';
import 'package:ai_mls/widgets/search/screens/ui/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình tìm kiếm lớp học cho học sinh
/// Sử dụng GenericSearchScreen giống như teacher
class StudentClassSearchScreen extends ConsumerWidget {
  const StudentClassSearchScreen({super.key});

  /// Build class item widget với highlight
  /// Sử dụng ClassItemWidget với searchQuery để enable highlight
  static Widget _buildClassItem(
    BuildContext context,
    Class classItem,
    String searchQuery,
    WidgetRef ref,
  ) {
    final studentName =
        ref.read(authNotifierProvider).value?.fullName ?? 'Học sinh';
    return ClassItemWidget(
      className: classItem.name,
      roomInfo: classItem.subject ?? 'Chưa có môn học',
      schedule: classItem.academicYear ?? 'Chưa có năm học',
      teacherName: classItem.teacherName,
      memberStatus: classItem.memberStatus,
      studentCount: classItem.studentCount ?? 0,
      ungradedCount: null,
      iconName: 'school',
      iconColor: Colors.blue,
      hasAssignments: true,
      searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      highlightColor: Colors.blue,
      onTap: () {
        StudentClassInteractionHandler.handleClassTap(
          context,
          classItem,
          onNavigate: () {
            context.pushNamed(
              AppRoute.studentClassDetail,
              pathParameters: {'classId': classItem.id},
              extra: {
                'className': classItem.name,
                'semesterInfo': classItem.academicYear ?? 'Chưa có năm học',
                'studentName': studentName,
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tạo SearchConfig cho Class (student)
    final config = SearchScreenConfig<Class>(
      title: 'Tìm kiếm lớp học',
      hintText: 'Tìm kiếm lớp học...',
      emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
      emptyStateSubtitle: 'Tìm kiếm theo tên lớp, môn học, hoặc học kỳ',
      noResultsMessage: 'Không tìm thấy lớp học nào',
      itemBuilder: (context, classItem, query) =>
          _buildClassItem(context, classItem, query, ref),
      onItemTap: (classItem) {
        final studentName =
            ref.read(authNotifierProvider).value?.fullName ?? 'Học sinh';
        StudentClassInteractionHandler.handleClassTap(
          context,
          classItem,
          onNavigate: () {
            context.pushNamed(
              AppRoute.studentClassDetail,
              pathParameters: {'classId': classItem.id},
              extra: {
                'className': classItem.name,
                'semesterInfo': classItem.academicYear ?? 'Chưa có năm học',
                'studentName': studentName,
              },
            );
          },
        );
      },
      // fetchFunction không được sử dụng khi dùng providers
      // Provider tự động handle fetching qua studentSearchPagingControllerProvider
      fetchFunction: (pageKey, searchQuery) async {
        throw UnimplementedError(
          'fetchFunction should not be called when using providers',
        );
      },
      searchQueryProvider: studentSearchScreenQueryProvider,
      pagingControllerProvider: studentSearchPagingControllerProvider,
      getUserId: (ref) => ref.read(authNotifierProvider).value?.id,
      debounceKey: 'student-class-search-debounce',
      pageSize:
          100, // Student không dùng pagination thật sự, set lớn để hiển thị tất cả
    );

    return SearchScreen<Class>(config: config);
  }
}

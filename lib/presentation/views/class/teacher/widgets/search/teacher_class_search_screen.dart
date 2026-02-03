import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/widgets/list_item/class/class_item_widget.dart';
import 'package:ai_mls/widgets/search/screens/core/search_screen_config.dart';
import 'package:ai_mls/widgets/search/screens/ui/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình tìm kiếm lớp học sử dụng GenericSearchScreen
/// Đặt tại widgets/search để tách biệt feature-specific UI
class TeacherClassSearchScreen extends ConsumerWidget {
  const TeacherClassSearchScreen({super.key});

  /// Build class item widget với highlight
  /// Sử dụng ClassItemWidget với searchQuery để enable highlight
  static Widget _buildClassItem(
    BuildContext context,
    Class classItem,
    String searchQuery,
  ) {
    return ClassItemWidget(
      className: classItem.name,
      roomInfo: classItem.subject ?? '',
      schedule: classItem.academicYear ?? '',
      teacherName: classItem.teacherName,
      memberStatus: null,
      studentCount: classItem.studentCount ?? 0,
      iconName: 'class',
      iconColor: Colors.blue,
      hasAssignments: true,
      searchQuery: searchQuery, // Enable highlight
      highlightColor: Colors.blue,
      onTap: () {
        context.pushNamed(
          AppRoute.teacherClassDetail,
          pathParameters: {'classId': classItem.id},
          extra: {
            'className': classItem.name,
            'semesterInfo': classItem.academicYear ?? 'Chưa có năm học',
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tạo SearchConfig cho Class
    final config = SearchScreenConfig<Class>(
      title: 'Tìm kiếm lớp học',
      hintText: 'Tìm kiếm lớp học...',
      emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
      emptyStateSubtitle: 'Tìm kiếm theo tên lớp, môn học, hoặc học kỳ',
      noResultsMessage: 'Không tìm thấy lớp học nào',
      itemBuilder: _buildClassItem,
      onItemTap: (classItem) {
        context.pushNamed(
          AppRoute.teacherClassDetail,
          pathParameters: {'classId': classItem.id},
          extra: {
            'className': classItem.name,
            'semesterInfo': classItem.academicYear ?? 'Chưa có năm học',
          },
        );
      },
      // fetchFunction không được sử dụng khi dùng providers
      // Provider tự động handle fetching qua pagingControllerProvider
      fetchFunction: (pageKey, searchQuery) async {
        throw UnimplementedError(
          'fetchFunction should not be called when using providers',
        );
      },
      searchQueryProvider: searchScreenQueryProvider,
      pagingControllerProvider: searchPagingControllerProvider,
      getUserId: (ref) => ref.read(currentUserIdProvider),
      debounceKey: 'class-search-debounce',
      pageSize: 10,
    );

    return SearchScreen<Class>(config: config);
  }
}

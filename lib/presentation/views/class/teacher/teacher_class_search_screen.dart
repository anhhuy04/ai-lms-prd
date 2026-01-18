import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/widgets/search/generic_search_screen.dart';
import 'package:ai_mls/widgets/search/search_config.dart';
import 'package:ai_mls/widgets/smart_highlight_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'teacher_class_detail_screen.dart';

/// Màn hình tìm kiếm lớp học sử dụng GenericSearchScreen
/// Refactored để sử dụng generic reusable widget
class TeacherClassSearchScreen extends ConsumerWidget {
  const TeacherClassSearchScreen({super.key});

  /// Build class item widget với highlight
  static Widget _buildClassItem(
    BuildContext context,
    Class classItem,
    String searchQuery,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeacherClassDetailScreen(
              classId: classItem.id,
              className: classItem.name,
              semesterInfo: classItem.academicYear ?? 'Chưa có năm học',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 12, right: 12, bottom: DesignSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [DesignElevation.level2],
        ),
        child: Column(
          children: [
            // Phần thông tin chính của lớp
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  // Icon loại lớp
                  Container(
                    width: DesignIcons.lgSize,
                    height: DesignIcons.lgSize,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Icon(
                      Icons.class_,
                      size: DesignIcons.mdSize,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  // Thông tin lớp với highlight
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên lớp với highlight
                        SmartHighlightText(
                          fullText: classItem.name,
                          query: searchQuery,
                          style: DesignTypography.titleMedium,
                          highlightColor: Colors.blue,
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        // Môn học với highlight
                        if (classItem.subject != null)
                          SmartHighlightText(
                            fullText: 'Môn: ${classItem.subject}',
                            query: searchQuery,
                            style: DesignTypography.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                            highlightColor: Colors.blue,
                          ),
                        // Học kỳ với highlight
                        if (classItem.academicYear != null) ...[
                          SizedBox(height: 4),
                          SmartHighlightText(
                            fullText: 'Học kỳ: ${classItem.academicYear}',
                            query: searchQuery,
                            style: DesignTypography.bodySmall.copyWith(
                              color: Colors.blueGrey[600],
                              fontSize: 12,
                            ),
                            highlightColor: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Icon mũi tên
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: DesignIcons.mdSize,
                  ),
                ],
              ),
            ),
            // Đường phân cách
            Divider(
              height: 1,
              color: Colors.grey[200],
              indent: DesignSpacing.lg,
              endIndent: DesignSpacing.lg,
            ),
            // Phần footer với thống kê
            Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSpacing.lg,
                DesignSpacing.md,
                DesignSpacing.lg,
                DesignSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Số học sinh (placeholder - có thể load sau)
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        size: DesignIcons.smSize,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: DesignSpacing.sm),
                      Text('0', style: DesignTypography.labelMedium),
                      SizedBox(width: DesignSpacing.xs),
                      Text('Học sinh', style: DesignTypography.caption),
                    ],
                  ),
                  // Trạng thái lớp (placeholder)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Đang hoạt động',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tạo SearchConfig cho Class
    final config = SearchConfig<Class>(
      title: 'Tìm kiếm lớp học',
      hintText: 'Tìm kiếm lớp học...',
      emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
      emptyStateSubtitle: 'Tìm kiếm theo tên lớp, môn học, hoặc học kỳ',
      noResultsMessage: 'Không tìm thấy lớp học nào',
      itemBuilder: _buildClassItem,
      onItemTap: (classItem) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeacherClassDetailScreen(
              classId: classItem.id,
              className: classItem.name,
              semesterInfo: classItem.academicYear ?? 'Chưa có năm học',
            ),
          ),
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

    return GenericSearchScreen<Class>(config: config);
  }
}

import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';

/// Class đơn giản để fetch data, không cần StateNotifier
/// Hỗ trợ request tracking để xử lý race condition
class ClassListFetcher {
  final SchoolClassRepository _repository;
  final String _teacherId;
  
  // Request tracking để xử lý race condition
  String? _currentRequestId;
  
  static const int pageSize = 10;

  ClassListFetcher({
    required SchoolClassRepository repository,
    required String teacherId,
  })  : _repository = repository,
        _teacherId = teacherId;

  /// Fetch một page dữ liệu với request tracking
  /// [requestId] được dùng để kiểm tra xem request có còn hợp lệ không
  Future<List<Class>> fetchPage({
    required int pageKey,
    String? searchQuery,
    ClassSortOption? sortOption,
    String? requestId,
  }) async {
    // Lưu request ID hiện tại
    _currentRequestId = requestId;

    final (sortBy, ascending) = _convertSortOption(
      sortOption ?? ClassSortOption.dateNewest,
    );

    final classes = await _repository.getClassesByTeacherPaginated(
      teacherId: _teacherId,
      page: pageKey + 1, // API dùng 1-based, PagingController dùng 0-based
      pageSize: pageSize,
      searchQuery: searchQuery?.isEmpty == true ? null : searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );

    // Kiểm tra xem request có còn hợp lệ không
    // Nếu requestId đã thay đổi, nghĩa là có request mới hơn đã được gọi
    if (requestId != null && _currentRequestId != requestId) {
      // Request này đã bị override, trả về list rỗng
      return [];
    }

    return classes;
  }

  /// Convert ClassSortOption sang database column và direction
  (String column, bool ascending) _convertSortOption(ClassSortOption option) {
    switch (option) {
      case ClassSortOption.nameAscending:
        return ('name', true);
      case ClassSortOption.nameDescending:
        return ('name', false);
      case ClassSortOption.dateNewest:
        return ('created_at', false);
      case ClassSortOption.dateOldest:
        return ('created_at', true);
      case ClassSortOption.subjectAscending:
        return ('subject', true);
      case ClassSortOption.subjectDescending:
        return ('subject', false);
    }
  }
}

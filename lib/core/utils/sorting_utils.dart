import 'package:ai_mls/core/utils/vietnamese_text_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';

/// Enum cho các loại sắp xếp lớp học
enum ClassSortOption {
  nameAscending,
  nameDescending,
  dateNewest,
  dateOldest,
  subjectAscending,
  subjectDescending,
}

/// Utility class cho sắp xếp lớp học
class SortingUtils {
  SortingUtils._(); // Prevent instantiation

  /// Sắp xếp danh sách lớp học theo option đã chọn
  ///
  /// Sử dụng VietnameseTextUtils để sắp xếp đúng với tiếng Việt có dấu
  static List<Class> sortClasses(
    List<Class> classes,
    ClassSortOption sortOption,
  ) {
    final sorted = List<Class>.from(classes);

    switch (sortOption) {
      case ClassSortOption.nameAscending:
        sorted.sort(
          (a, b) => VietnameseTextUtils.compareVietnamese(a.name, b.name),
        );
        break;
      case ClassSortOption.nameDescending:
        sorted.sort(
          (a, b) => VietnameseTextUtils.compareVietnamese(b.name, a.name),
        );
        break;
      case ClassSortOption.dateNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ClassSortOption.dateOldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ClassSortOption.subjectAscending:
        sorted.sort((a, b) {
          final aSubject = a.subject ?? '';
          final bSubject = b.subject ?? '';
          return VietnameseTextUtils.compareVietnamese(aSubject, bSubject);
        });
        break;
      case ClassSortOption.subjectDescending:
        sorted.sort((a, b) {
          final aSubject = a.subject ?? '';
          final bSubject = b.subject ?? '';
          return VietnameseTextUtils.compareVietnamese(bSubject, aSubject);
        });
        break;
    }

    return sorted;
  }
}

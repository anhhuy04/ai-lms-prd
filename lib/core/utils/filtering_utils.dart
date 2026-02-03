import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';

/// Utility class cho lọc danh sách lớp học
class FilteringUtils {
  FilteringUtils._(); // Prevent instantiation

  /// Lọc danh sách lớp học cho học sinh theo trạng thái tham gia
  ///
  /// [classes] - Danh sách lớp học cần lọc
  /// [filterOption] - Tùy chọn lọc (all, approved, pending)
  /// Trả về danh sách lớp học đã được lọc
  static List<Class> filterStudentClasses(
    List<Class> classes,
    StudentClassFilterOption filterOption,
  ) {
    switch (filterOption) {
      case StudentClassFilterOption.all:
        return classes;
      case StudentClassFilterOption.approved:
        return classes.where((c) => c.isApproved).toList();
      case StudentClassFilterOption.pending:
        return classes.where((c) => c.isPending).toList();
    }
  }
}

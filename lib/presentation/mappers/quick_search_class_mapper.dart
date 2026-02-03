import 'package:ai_mls/domain/entities/class.dart';

/// Mapper để chuyển đổi Class entity sang format cho QuickSearchDialog
class QuickSearchClassMapper {
  QuickSearchClassMapper._(); // Prevent instantiation

  /// Chuyển đổi một Class thành search item cho QuickSearchDialog
  ///
  /// [classItem] - Lớp học cần map
  /// [includeMemberStatus] - Có bao gồm trạng thái tham gia trong subtitle không (mặc định: false, dùng cho student)
  ///
  /// Trả về Map với các key: id, title, subtitle, type
  static Map<String, dynamic> toSearchItem(
    Class classItem, {
    bool includeMemberStatus = false,
  }) {
    // Tạo title: "Môn học - Tên lớp" hoặc chỉ "Tên lớp"
    final subject = classItem.subject ?? '';
    final title = subject.isNotEmpty ? '$subject - ${classItem.name}' : classItem.name;

    // Tạo subtitle với thông tin giáo viên và năm học
    final teacherLabel = classItem.teacherName != null &&
            classItem.teacherName!.isNotEmpty
        ? 'GV: ${classItem.teacherName}'
        : 'GV: Chưa cập nhật';
    final academicYear = classItem.academicYear != null &&
            classItem.academicYear!.isNotEmpty
        ? classItem.academicYear
        : 'Chưa có năm học';

    final subtitleParts = <String>[teacherLabel, 'Năm học: $academicYear'];

    // Thêm trạng thái tham gia nếu là student và đang chờ duyệt
    if (includeMemberStatus && classItem.isPending) {
      subtitleParts.add('Đang chờ duyệt');
    }

    final subtitle = subtitleParts.join(' • ');

    return {
      'id': classItem.id,
      'title': title,
      'subtitle': subtitle,
      'type': 'class',
      // Thêm metadata để dùng khi navigate
      'className': classItem.name,
      'semesterInfo': academicYear,
      'memberStatus': classItem.memberStatus,
    };
  }

  /// Chuyển đổi danh sách Class thành danh sách search items
  ///
  /// [classes] - Danh sách lớp học
  /// [includeMemberStatus] - Có bao gồm trạng thái tham gia không
  ///
  /// Trả về List<Map<String, dynamic>>
  static List<Map<String, dynamic>> toSearchItems(
    List<Class> classes, {
    bool includeMemberStatus = false,
  }) {
    return classes
        .map((c) => toSearchItem(c, includeMemberStatus: includeMemberStatus))
        .toList();
  }
}

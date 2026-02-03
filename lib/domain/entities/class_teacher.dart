// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_teacher.freezed.dart';
part 'class_teacher.g.dart';

/// Entity đại diện cho giáo viên lớp học (hỗ trợ đồng giảng dạy)
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
@freezed
class ClassTeacher with _$ClassTeacher {
  /// Factory constructor cho ClassTeacher
  ///
  /// [id] - ID duy nhất (required)
  /// [classId] - ID lớp học (required)
  /// [teacherId] - ID giáo viên (required)
  /// [role] - Vai trò (default: 'teacher')
  const factory ClassTeacher({
    required String id,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @Default('teacher') String role,
  }) = _ClassTeacher;

  /// Factory constructor để tạo ClassTeacher từ JSON
  factory ClassTeacher.fromJson(Map<String, dynamic> json) =>
      _$ClassTeacherFromJson(json);

  /// Private constructor để thêm custom methods
  const ClassTeacher._();
}

// Extension để thêm custom methods cho ClassTeacher
extension ClassTeacherExtension on ClassTeacher {
  /// Validate dữ liệu của ClassTeacher
  ///
  /// Ném ra Exception nếu dữ liệu không hợp lệ
  void validate() {
    if (id.trim().isEmpty) {
      throw Exception('ID không hợp lệ');
    }
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (teacherId.trim().isEmpty) {
      throw Exception('ID giáo viên không hợp lệ');
    }
    if (role.trim().isEmpty) {
      throw Exception('Vai trò không được để trống');
    }
  }
}

// ignore_for_file: invalid_annotation_target

import 'package:ai_mls/domain/entities/class.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_class_params.freezed.dart';
part 'create_class_params.g.dart';

/// Parameters để tạo lớp học mới
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
@freezed
class CreateClassParams with _$CreateClassParams {
  /// Factory constructor cho CreateClassParams
  ///
  /// [schoolId] - ID trường học (optional)
  /// [teacherId] - ID giáo viên (required)
  /// [name] - Tên lớp học (required)
  /// [subject] - Môn học (optional)
  /// [academicYear] - Năm học (optional)
  /// [description] - Mô tả (optional)
  /// [classSettings] - Cài đặt lớp học (optional, có default)
  const factory CreateClassParams({
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    required String name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'class_settings') Map<String, dynamic>? classSettings,
  }) = _CreateClassParams;

  /// Factory constructor để tạo CreateClassParams từ JSON
  factory CreateClassParams.fromJson(Map<String, dynamic> json) =>
      _$CreateClassParamsFromJson(json);

  /// Private constructor để thêm custom methods
  const CreateClassParams._();
}

// Extension để thêm custom methods cho CreateClassParams
extension CreateClassParamsExtension on CreateClassParams {
  /// Convert sang JSON payload để gửi lên backend.
  ///
  /// - Không override `toJson()` của Freezed (tránh xung đột với code generated).
  /// - Luôn đảm bảo `class_settings` có default nếu chưa truyền.
  Map<String, dynamic> toPayloadJson() {
    final json = toJson(); // toJson() generated bởi Freezed/json_serializable
    json['class_settings'] ??= Class.defaultClassSettings();
    return json;
  }
}

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_class_params.freezed.dart';
part 'update_class_params.g.dart';

/// Parameters để cập nhật lớp học
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
///
/// Tất cả fields đều optional vì chỉ cập nhật những gì cần thiết
@freezed
class UpdateClassParams with _$UpdateClassParams {
  /// Factory constructor cho UpdateClassParams
  ///
  /// Tất cả fields đều optional
  const factory UpdateClassParams({
    String? name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'class_settings') Map<String, dynamic>? classSettings,
  }) = _UpdateClassParams;

  /// Factory constructor để tạo UpdateClassParams từ JSON
  factory UpdateClassParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateClassParamsFromJson(json);

  /// Private constructor để thêm custom methods
  const UpdateClassParams._();
}

// Extension để thêm custom methods cho UpdateClassParams
extension UpdateClassParamsExtension on UpdateClassParams {
  /// Convert sang JSON, chỉ bao gồm các fields không null
  ///
  /// Override toJson để chỉ bao gồm các fields không null
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (subject != null) json['subject'] = subject;
    if (academicYear != null) json['academic_year'] = academicYear;
    if (description != null) json['description'] = description;
    if (classSettings != null) json['class_settings'] = classSettings;
    return json;
  }

  /// Kiểm tra xem có dữ liệu để cập nhật không
  bool get isEmpty => toJson().isEmpty;
}

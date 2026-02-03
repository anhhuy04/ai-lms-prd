// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_group_params.freezed.dart';
part 'create_group_params.g.dart';

/// Parameters để tạo nhóm học tập mới
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
@freezed
class CreateGroupParams with _$CreateGroupParams {
  /// Factory constructor cho CreateGroupParams
  ///
  /// [classId] - ID lớp học (required)
  /// [name] - Tên nhóm (required)
  /// [description] - Mô tả (optional)
  const factory CreateGroupParams({
    @JsonKey(name: 'class_id') required String classId,
    required String name,
    String? description,
  }) = _CreateGroupParams;

  /// Factory constructor để tạo CreateGroupParams từ JSON
  factory CreateGroupParams.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupParamsFromJson(json);
}

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// Entity đại diện cho nhóm học tập trong lớp học
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
@freezed
class Group with _$Group {
  /// Factory constructor cho Group
  ///
  /// [id] - ID duy nhất của nhóm (required)
  /// [classId] - ID lớp học (required)
  /// [name] - Tên nhóm (required)
  /// [description] - Mô tả nhóm (optional)
  /// [createdAt] - Thời gian tạo (required)
  const factory Group({
    required String id,
    @JsonKey(name: 'class_id') required String classId,
    required String name,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Group;

  /// Factory constructor để tạo Group từ JSON
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  /// Private constructor để thêm custom methods
  const Group._();
}

// Extension để thêm custom methods cho Group
extension GroupExtension on Group {
  /// Validate dữ liệu của Group
  ///
  /// Ném ra Exception nếu dữ liệu không hợp lệ
  void validate() {
    if (id.trim().isEmpty) {
      throw Exception('ID nhóm không hợp lệ');
    }
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (name.trim().isEmpty) {
      throw Exception('Tên nhóm không được để trống');
    }
  }
}

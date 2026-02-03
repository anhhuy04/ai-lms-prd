// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';
part 'group_member.g.dart';

/// Entity đại diện cho thành viên nhóm học tập
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
@freezed
class GroupMember with _$GroupMember {
  /// Factory constructor cho GroupMember
  ///
  /// [groupId] - ID nhóm (required)
  /// [studentId] - ID học sinh (required)
  /// [joinedAt] - Thời gian tham gia (optional)
  const factory GroupMember({
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
  }) = _GroupMember;

  /// Factory constructor để tạo GroupMember từ JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);

  /// Private constructor để thêm custom methods
  const GroupMember._();
}

// Extension để thêm custom methods cho GroupMember
extension GroupMemberExtension on GroupMember {
  /// Validate dữ liệu của GroupMember
  ///
  /// Ném ra Exception nếu dữ liệu không hợp lệ
  void validate() {
    if (groupId.trim().isEmpty) {
      throw Exception('ID nhóm không hợp lệ');
    }
    if (studentId.trim().isEmpty) {
      throw Exception('ID học sinh không hợp lệ');
    }
  }
}

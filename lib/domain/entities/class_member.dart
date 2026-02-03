// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_member.freezed.dart';
part 'class_member.g.dart';

/// Entity đại diện cho thành viên lớp học (học sinh trong lớp)
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
///
/// Cách sử dụng:
/// ```dart
/// // Tạo instance
/// final member = ClassMember(
///   classId: 'class-1',
///   studentId: 'student-1',
///   status: 'pending',
/// );
///
/// // Copy với một số fields thay đổi
/// final approvedMember = member.copyWith(status: 'approved');
///
/// // JSON serialization
/// final json = member.toJson();
/// final fromJson = ClassMember.fromJson(json);
///
/// // Check status
/// if (member.isPending) { ... }
/// ```
@freezed
class ClassMember with _$ClassMember {
  /// Factory constructor cho ClassMember
  ///
  /// [classId] - ID lớp học (required)
  /// [studentId] - ID học sinh (required)
  /// [status] - Trạng thái: 'pending', 'approved', 'rejected' (required, default: 'pending')
  /// [role] - Vai trò trong lớp (optional)
  /// [joinedAt] - Thời gian tham gia (optional)
  /// [createdAt] - Thời gian tạo (optional)
  const factory ClassMember({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'student_id') required String studentId,
    @Default('pending') String status,
    String? role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ClassMember;

  /// Factory constructor để tạo ClassMember từ JSON
  ///
  /// Tự động convert snake_case từ database sang camelCase trong Dart
  factory ClassMember.fromJson(Map<String, dynamic> json) =>
      _$ClassMemberFromJson(json);

  /// Private constructor để thêm custom methods
  const ClassMember._();
}

// Extension để thêm custom methods cho ClassMember
extension ClassMemberExtension on ClassMember {
  /// Validate dữ liệu của ClassMember
  ///
  /// Ném ra Exception nếu dữ liệu không hợp lệ
  void validate() {
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (studentId.trim().isEmpty) {
      throw Exception('ID học sinh không hợp lệ');
    }
    if (!['pending', 'approved', 'rejected'].contains(status)) {
      throw Exception(
        'Trạng thái không hợp lệ. Phải là: pending, approved, hoặc rejected',
      );
    }
  }

  /// Kiểm tra xem thành viên có đang chờ duyệt không
  bool get isPending => status == 'pending';

  /// Kiểm tra xem thành viên đã được duyệt chưa
  bool get isApproved => status == 'approved';

  /// Kiểm tra xem thành viên đã bị từ chối chưa
  bool get isRejected => status == 'rejected';
}

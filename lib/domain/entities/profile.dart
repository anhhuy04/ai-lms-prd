// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Entity đại diện cho profile người dùng trong hệ thống
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
///
/// Cách sử dụng:
/// ```dart
/// // Tạo instance
/// final profile = Profile(
///   id: '123',
///   fullName: 'Nguyễn Văn A',
///   role: 'student',
///   updatedAt: DateTime.now(),
/// );
///
/// // Copy với một số fields thay đổi
/// final updatedProfile = profile.copyWith(fullName: 'Nguyễn Văn B');
///
/// // JSON serialization
/// final json = profile.toJson();
/// final fromJson = Profile.fromJson(json);
/// ```
@freezed
class Profile with _$Profile {
  /// Factory constructor cho Profile
  ///
  /// [id] - ID duy nhất của người dùng (required)
  /// [fullName] - Tên đầy đủ (optional)
  /// [role] - Vai trò: 'student', 'teacher', 'admin' (required)
  /// [avatarUrl] - URL avatar (optional)
  /// [bio] - Tiểu sử (optional)
  /// [phone] - Số điện thoại (optional)
  /// [gender] - Giới tính (optional)
  /// [metadata] - Metadata JSONB (optional) - có thể chứa API keys và các thông tin khác
  /// [updatedAt] - Thời gian cập nhật cuối cùng (required)
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    required String role,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? phone,
    String? gender,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Profile;

  /// Factory constructor để tạo Profile từ JSON
  ///
  /// Tự động convert snake_case từ database sang camelCase trong Dart
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

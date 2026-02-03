// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'student_class_member_status.dart';

part 'class.freezed.dart';
part 'class.g.dart';

/// Parse `class_settings` từ DB và tự fallback về default nếu null/sai kiểu.
///
/// Lưu ý: Hàm này cần là **top-level function** để Freezed/json_serializable
/// có thể tham chiếu ổn định trong code generated.
Map<String, dynamic> _classSettingsFromJson(Object? json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  // Một số trường hợp Supabase trả về Map<dynamic, dynamic>
  if (json is Map) {
    return Map<String, dynamic>.from(
      json.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
  return Class.defaultClassSettings();
}

/// Entity đại diện cho một lớp học trong hệ thống
///
/// Sử dụng Freezed để tạo immutable class với:
/// - Automatic copyWith method
/// - Automatic toString, ==, hashCode
/// - JSON serialization với json_serializable
///
/// Cách sử dụng:
/// ```dart
/// // Tạo instance
/// final classItem = Class(
///   id: '123',
///   teacherId: 'teacher-1',
///   name: 'Lớp Toán 10A',
///   createdAt: DateTime.now(),
///   classSettings: Class.defaultClassSettings(),
/// );
///
/// // Copy với một số fields thay đổi
/// final updatedClass = classItem.copyWith(name: 'Lớp Toán 10B');
///
/// // JSON serialization
/// final json = classItem.toJson();
/// final fromJson = Class.fromJson(json);
///
/// // Validate
/// classItem.validate();
/// ```
@freezed
class Class with _$Class {
  /// Factory constructor cho Class
  ///
  /// [id] - ID duy nhất của lớp học (required)
  /// [schoolId] - ID trường học (optional)
  /// [teacherId] - ID giáo viên chủ nhiệm (required)
  /// [name] - Tên lớp học (required)
  /// [subject] - Môn học (optional)
  /// [academicYear] - Năm học (optional)
  /// [description] - Mô tả lớp học (optional)
  /// [classSettings] - Cài đặt lớp học (required, có default)
  /// [createdAt] - Thời gian tạo (required)
  const factory Class({
    required String id,
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    required String name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,

    /// Tên giáo viên hiển thị cho học sinh.
    /// Được map từ alias SQL `teacher_name` trong các query join với bảng profiles.
    @JsonKey(name: 'teacher_name') String? teacherName,

    /// Tổng số học sinh trong lớp (đã duyệt, status = approved).
    /// Được map từ alias SQL `student_count` trong các query aggregate.
    @JsonKey(name: 'student_count') int? studentCount,

    /// Trạng thái tham gia của học sinh hiện tại trong lớp:
    /// - 'pending': Đang chờ giáo viên duyệt
    /// - 'approved': Đã vào lớp
    /// Field này chỉ có ý nghĩa trong luồng học sinh.
    @JsonKey(name: 'member_status') String? memberStatus,

    /// Cài đặt lớp học từ DB (có thể null nếu record cũ/thiếu field).
    /// Dùng fromJson để luôn có default khi DB trả về null/không đúng kiểu.
    @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
    Map<String, dynamic>? classSettings,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Class;

  /// Factory constructor để tạo Class từ JSON
  ///
  /// Tự động convert snake_case từ database sang camelCase trong Dart
  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  /// Private constructor để thêm custom methods
  const Class._();

  /// Trả về cài đặt mặc định cho lớp học
  ///
  /// Bao gồm:
  /// - defaults: lock_class = false
  /// - enrollment: QR code settings với require_approval = true
  /// - group_management: Cài đặt quản lý nhóm
  /// - student_permissions: Quyền của học sinh
  static Map<String, dynamic> defaultClassSettings() {
    return {
      'defaults': {'lock_class': false},
      'enrollment': {
        'qr_code': {
          'is_active': false,
          'join_code': null,
          'expires_at': null,
          'require_approval': true,
          'logo_enabled': true, // Mặc định bật logo trên QR code
        },
        'manual_join_limit': null,
      },
      'group_management': {
        'lock_groups': false,
        'allow_student_switch': false,
        'is_visible_to_students': true,
      },
      'student_permissions': {
        'auto_lock_on_submission': false,
        'can_edit_profile_in_class': true,
      },
    };
  }
}

// Extension để thêm custom methods cho Class
extension ClassExtension on Class {
  /// Validate dữ liệu của Class
  ///
  /// Ném ra Exception nếu dữ liệu không hợp lệ
  void validate() {
    if (name.trim().isEmpty) {
      throw Exception('Tên lớp học không được để trống');
    }
    if (teacherId.trim().isEmpty) {
      throw Exception('ID giáo viên không hợp lệ');
    }
    _validateClassSettings();
  }

  /// Validate cấu trúc của classSettings
  void _validateClassSettings() {
    final settings = classSettings ?? Class.defaultClassSettings();
    if (settings.isEmpty) {
      return;
    }

    // Validate structure của class_settings
    final enrollment = settings['enrollment'] as Map<String, dynamic>?;
    if (enrollment != null) {
      final qrCode = enrollment['qr_code'] as Map<String, dynamic>?;
      if (qrCode != null) {
        final requireApproval = qrCode['require_approval'];
        if (requireApproval != null && requireApproval is! bool) {
          throw Exception('require_approval phải là boolean');
        }
      }
    }
  }

  /// Chuyển đổi memberStatus từ String sang enum
  StudentClassMemberStatus? get memberStatusEnum =>
      StudentClassMemberStatus.fromString(memberStatus);

  /// Kiểm tra xem học sinh có đang chờ duyệt không
  bool get isPending => memberStatusEnum == StudentClassMemberStatus.pending;

  /// Kiểm tra xem học sinh đã được duyệt vào lớp chưa
  bool get isApproved => memberStatusEnum == StudentClassMemberStatus.approved;

  /// Kiểm tra xem học sinh có thể truy cập lớp không (đã được duyệt)
  bool get canAccess => isApproved;
}

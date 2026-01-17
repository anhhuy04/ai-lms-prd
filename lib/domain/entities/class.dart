/// Entity đại diện cho một lớp học trong hệ thống.
class Class {
  final String id;
  final String? schoolId;
  final String teacherId;
  final String name;
  final String? subject;
  final String? academicYear;
  final String? description;
  final Map<String, dynamic> classSettings;
  final DateTime createdAt;

  Class({
    required this.id,
    this.schoolId,
    required this.teacherId,
    required this.name,
    this.subject,
    this.academicYear,
    this.description,
    required this.classSettings,
    required this.createdAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as String,
      schoolId: json['school_id'] as String?,
      teacherId: json['teacher_id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String?,
      academicYear: json['academic_year'] as String?,
      description: json['description'] as String?,
      classSettings:
          json['class_settings'] as Map<String, dynamic>? ??
          defaultClassSettings(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'teacher_id': teacherId,
      'name': name,
      'subject': subject,
      'academic_year': academicYear,
      'description': description,
      'class_settings': classSettings,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validate dữ liệu của Class.
  /// Ném ra Exception nếu dữ liệu không hợp lệ.
  void validate() {
    if (name.trim().isEmpty) {
      throw Exception('Tên lớp học không được để trống');
    }
    if (teacherId.trim().isEmpty) {
      throw Exception('ID giáo viên không hợp lệ');
    }
    _validateClassSettings();
  }

  void _validateClassSettings() {
    if (classSettings.isEmpty) {
      return;
    }

    // Validate structure của class_settings
    final enrollment = classSettings['enrollment'] as Map<String, dynamic>?;
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

  static Map<String, dynamic> defaultClassSettings() {
    return {
      'defaults': {'lock_class': false},
      'enrollment': {
        'qr_code': {
          'is_active': false,
          'join_code': null,
          'expires_at': null,
          'require_approval': true,
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

  @override
  String toString() {
    return 'Class(\n'
        '  id: $id,\n'
        '  schoolId: $schoolId,\n'
        '  teacherId: $teacherId,\n'
        '  name: $name,\n'
        '  subject: $subject,\n'
        '  academicYear: $academicYear,\n'
        '  description: $description,\n'
        '  createdAt: ${createdAt.toIso8601String()},\n'
        ')';
  }
}

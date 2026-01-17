import 'package:ai_mls/domain/entities/class.dart';

/// Parameters để tạo lớp học mới.
class CreateClassParams {
  final String? schoolId;
  final String teacherId;
  final String name;
  final String? subject;
  final String? academicYear;
  final String? description;
  final Map<String, dynamic>? classSettings;

  CreateClassParams({
    this.schoolId,
    required this.teacherId,
    required this.name,
    this.subject,
    this.academicYear,
    this.description,
    this.classSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'teacher_id': teacherId,
      'name': name,
      'subject': subject,
      'academic_year': academicYear,
      'description': description,
      'class_settings': classSettings ?? Class.defaultClassSettings(),
    };
  }
}

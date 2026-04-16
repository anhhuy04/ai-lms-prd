// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassImpl _$$ClassImplFromJson(Map<String, dynamic> json) => _$ClassImpl(
  id: json['id'] as String,
  schoolId: json['school_id'] as String?,
  teacherId: json['teacher_id'] as String,
  name: json['name'] as String,
  subject: json['subject'] as String?,
  academicYear: json['academic_year'] as String?,
  description: json['description'] as String?,
  teacherName: json['teacher_name'] as String?,
  studentCount: (json['student_count'] as num?)?.toInt(),
  memberStatus: json['member_status'] as String?,
  totalAssignmentCount: (json['total_assignment_count'] as num?)?.toInt(),
  pendingAssignmentCount: (json['pending_assignment_count'] as num?)?.toInt(),
  inProgressAssignmentCount: (json['in_progress_assignment_count'] as num?)
      ?.toInt(),
  notStartedAssignmentCount: (json['not_started_assignment_count'] as num?)
      ?.toInt(),
  classSettings: _classSettingsFromJson(json['class_settings']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ClassImplToJson(_$ClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'teacher_id': instance.teacherId,
      'name': instance.name,
      'subject': instance.subject,
      'academic_year': instance.academicYear,
      'description': instance.description,
      'teacher_name': instance.teacherName,
      'student_count': instance.studentCount,
      'member_status': instance.memberStatus,
      'total_assignment_count': instance.totalAssignmentCount,
      'pending_assignment_count': instance.pendingAssignmentCount,
      'in_progress_assignment_count': instance.inProgressAssignmentCount,
      'not_started_assignment_count': instance.notStartedAssignmentCount,
      'class_settings': instance.classSettings,
      'created_at': instance.createdAt.toIso8601String(),
    };

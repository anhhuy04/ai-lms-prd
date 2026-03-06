// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_class_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateClassParamsImpl _$$CreateClassParamsImplFromJson(
  Map<String, dynamic> json,
) => _$CreateClassParamsImpl(
  schoolId: json['school_id'] as String?,
  teacherId: json['teacher_id'] as String,
  name: json['name'] as String,
  subject: json['subject'] as String?,
  academicYear: json['academic_year'] as String?,
  description: json['description'] as String?,
  classSettings: json['class_settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$CreateClassParamsImplToJson(
  _$CreateClassParamsImpl instance,
) => <String, dynamic>{
  'school_id': instance.schoolId,
  'teacher_id': instance.teacherId,
  'name': instance.name,
  'subject': instance.subject,
  'academic_year': instance.academicYear,
  'description': instance.description,
  'class_settings': instance.classSettings,
};

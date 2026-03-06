// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_class_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateClassParamsImpl _$$UpdateClassParamsImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateClassParamsImpl(
  name: json['name'] as String?,
  subject: json['subject'] as String?,
  academicYear: json['academic_year'] as String?,
  description: json['description'] as String?,
  classSettings: json['class_settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$UpdateClassParamsImplToJson(
  _$UpdateClassParamsImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'subject': instance.subject,
  'academic_year': instance.academicYear,
  'description': instance.description,
  'class_settings': instance.classSettings,
};

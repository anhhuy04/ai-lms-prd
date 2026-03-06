// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassTeacherImpl _$$ClassTeacherImplFromJson(Map<String, dynamic> json) =>
    _$ClassTeacherImpl(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      teacherId: json['teacher_id'] as String,
      role: json['role'] as String? ?? 'teacher',
    );

Map<String, dynamic> _$$ClassTeacherImplToJson(_$ClassTeacherImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'teacher_id': instance.teacherId,
      'role': instance.role,
    };

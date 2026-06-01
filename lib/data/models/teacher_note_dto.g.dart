// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherNoteDtoImpl _$$TeacherNoteDtoImplFromJson(Map<String, dynamic> json) =>
    _$TeacherNoteDtoImpl(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      studentId: json['student_id'] as String,
      content: json['content'] as String,
      isPrivate: json['is_private'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TeacherNoteDtoImplToJson(
  _$TeacherNoteDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'teacher_id': instance.teacherId,
  'student_id': instance.studentId,
  'content': instance.content,
  'is_private': instance.isPrivate,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

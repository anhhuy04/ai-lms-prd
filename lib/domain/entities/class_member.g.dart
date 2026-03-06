// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassMemberImpl _$$ClassMemberImplFromJson(Map<String, dynamic> json) =>
    _$ClassMemberImpl(
      classId: json['class_id'] as String,
      studentId: json['student_id'] as String,
      status: json['status'] as String? ?? 'pending',
      role: json['role'] as String?,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ClassMemberImplToJson(_$ClassMemberImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'student_id': instance.studentId,
      'status': instance.status,
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

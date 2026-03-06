// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentVariantImpl _$$AssignmentVariantImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentVariantImpl(
  id: json['id'] as String,
  assignmentId: json['assignment_id'] as String,
  variantType: json['variant_type'] as String,
  studentId: json['student_id'] as String?,
  groupId: json['group_id'] as String?,
  dueAtOverride: json['due_at_override'] == null
      ? null
      : DateTime.parse(json['due_at_override'] as String),
  customQuestions: json['custom_questions'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$AssignmentVariantImplToJson(
  _$AssignmentVariantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'assignment_id': instance.assignmentId,
  'variant_type': instance.variantType,
  'student_id': instance.studentId,
  'group_id': instance.groupId,
  'due_at_override': instance.dueAtOverride?.toIso8601String(),
  'custom_questions': instance.customQuestions,
  'created_at': instance.createdAt?.toIso8601String(),
};

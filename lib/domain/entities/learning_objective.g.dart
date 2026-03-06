// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningObjectiveImpl _$$LearningObjectiveImplFromJson(
  Map<String, dynamic> json,
) => _$LearningObjectiveImpl(
  id: json['id'] as String,
  subjectCode: json['subject_code'] as String,
  code: json['code'] as String,
  description: json['description'] as String,
  difficulty: (json['difficulty'] as num?)?.toInt(),
  parentId: json['parent_id'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$LearningObjectiveImplToJson(
  _$LearningObjectiveImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'subject_code': instance.subjectCode,
  'code': instance.code,
  'description': instance.description,
  'difficulty': instance.difficulty,
  'parent_id': instance.parentId,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      type: QuestionTypeDb.fromDb(json['type'] as String?),
      content: json['content'] as Map<String, dynamic>,
      answer: json['answer'] as Map<String, dynamic>?,
      defaultPoints: (json['default_points'] as num?)?.toDouble() ?? 1,
      difficulty: (json['difficulty'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'type': _questionTypeToJson(instance.type),
      'content': instance.content,
      'answer': instance.answer,
      'default_points': instance.defaultPoints,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'is_public': instance.isPublic,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

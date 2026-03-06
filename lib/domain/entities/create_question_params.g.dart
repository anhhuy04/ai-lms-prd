// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_question_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateQuestionParamsImpl _$$CreateQuestionParamsImplFromJson(
  Map<String, dynamic> json,
) => _$CreateQuestionParamsImpl(
  type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
  content: json['content'] as Map<String, dynamic>,
  answer: json['answer'] as Map<String, dynamic>?,
  defaultPoints: (json['defaultPoints'] as num?)?.toDouble() ?? 1,
  difficulty: (json['difficulty'] as num?)?.toInt(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isPublic: json['isPublic'] as bool? ?? false,
  objectiveIds: (json['objectiveIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$$CreateQuestionParamsImplToJson(
  _$CreateQuestionParamsImpl instance,
) => <String, dynamic>{
  'type': _$QuestionTypeEnumMap[instance.type]!,
  'content': instance.content,
  'answer': instance.answer,
  'defaultPoints': instance.defaultPoints,
  'difficulty': instance.difficulty,
  'tags': instance.tags,
  'isPublic': instance.isPublic,
  'objectiveIds': instance.objectiveIds,
  'choices': instance.choices,
};

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'multipleChoice',
  QuestionType.shortAnswer: 'shortAnswer',
  QuestionType.essay: 'essay',
  QuestionType.math: 'math',
};

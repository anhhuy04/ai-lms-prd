// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionDTOImpl _$$QuestionDTOImplFromJson(Map<String, dynamic> json) =>
    _$QuestionDTOImpl(
      type: json['type'] as String? ?? 'multiple_choice',
      content: json['content'] as Map<String, dynamic>,
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map((e) => ChoiceDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      answer: json['answer'] as Map<String, dynamic>,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      defaultPoints: (json['defaultPoints'] as num?)?.toInt() ?? 1,
      source: json['source'] as String? ?? 'teacher',
    );

Map<String, dynamic> _$$QuestionDTOImplToJson(_$QuestionDTOImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'content': instance.content,
      'choices': instance.choices,
      'answer': instance.answer,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'defaultPoints': instance.defaultPoints,
      'source': instance.source,
    };

_$ChoiceDTOImpl _$$ChoiceDTOImplFromJson(Map<String, dynamic> json) =>
    _$ChoiceDTOImpl(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChoiceDTOImplToJson(_$ChoiceDTOImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isCorrect': instance.isCorrect,
    };

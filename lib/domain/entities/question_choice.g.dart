// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionChoiceImpl _$$QuestionChoiceImplFromJson(Map<String, dynamic> json) =>
    _$QuestionChoiceImpl(
      id: (json['id'] as num).toInt(),
      questionId: json['question_id'] as String,
      content: json['content'] as Map<String, dynamic>,
      isCorrect: json['is_correct'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuestionChoiceImplToJson(
  _$QuestionChoiceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'question_id': instance.questionId,
  'content': instance.content,
  'is_correct': instance.isCorrect,
};

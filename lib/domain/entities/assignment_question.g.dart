// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentQuestionImpl _$$AssignmentQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentQuestionImpl(
  id: json['id'] as String,
  assignmentId: json['assignment_id'] as String,
  questionId: json['question_id'] as String?,
  customContent: json['custom_content'] as Map<String, dynamic>?,
  points: (json['points'] as num?)?.toDouble() ?? 1,
  rubric: json['rubric'] as Map<String, dynamic>?,
  orderIdx: (json['order_idx'] as num).toInt(),
);

Map<String, dynamic> _$$AssignmentQuestionImplToJson(
  _$AssignmentQuestionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'assignment_id': instance.assignmentId,
  'question_id': instance.questionId,
  'custom_content': instance.customContent,
  'points': instance.points,
  'rubric': instance.rubric,
  'order_idx': instance.orderIdx,
};

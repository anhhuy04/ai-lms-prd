// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionAnswerImpl _$$SubmissionAnswerImplFromJson(
  Map<String, dynamic> json,
) => _$SubmissionAnswerImpl(
  id: json['id'] as String,
  sessionId: json['session_id'] as String,
  assignmentQuestionId: json['assignment_question_id'] as String,
  answer: json['answer'] as Map<String, dynamic>?,
  aiScore: (json['ai_score'] as num?)?.toDouble(),
  aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
  aiFeedback: json['ai_feedback'] as Map<String, dynamic>?,
  finalScore: (json['final_score'] as num?)?.toDouble(),
  gradedBy: json['graded_by'] as String?,
  gradedAt: json['graded_at'] == null
      ? null
      : DateTime.parse(json['graded_at'] as String),
  teacherFeedback: json['teacher_feedback'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  assignmentQuestion: json['assignmentQuestion'] as Map<String, dynamic>?,
  questionId: json['questionId'] as String?,
  questionType: json['questionType'] as String?,
  points: (json['points'] as num?)?.toDouble(),
  customContent: json['customContent'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$SubmissionAnswerImplToJson(
  _$SubmissionAnswerImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'session_id': instance.sessionId,
  'assignment_question_id': instance.assignmentQuestionId,
  'answer': instance.answer,
  'ai_score': instance.aiScore,
  'ai_confidence': instance.aiConfidence,
  'ai_feedback': instance.aiFeedback,
  'final_score': instance.finalScore,
  'graded_by': instance.gradedBy,
  'graded_at': instance.gradedAt?.toIso8601String(),
  'teacher_feedback': instance.teacherFeedback,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'assignmentQuestion': instance.assignmentQuestion,
  'questionId': instance.questionId,
  'questionType': instance.questionType,
  'points': instance.points,
  'customContent': instance.customContent,
};

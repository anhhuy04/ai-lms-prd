// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionImpl _$$SubmissionImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionImpl(
      id: json['id'] as String,
      distributionId: json['distribution_id'] as String,
      studentId: json['student_id'] as String,
      status:
          $enumDecodeNullable(_$SubmissionStatusEnumMap, json['status']) ??
          SubmissionStatus.draft,
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
      gradedAt: json['graded_at'] == null
          ? null
          : DateTime.parse(json['graded_at'] as String),
      score: (json['score'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      totalPoints: (json['total_points'] as num?)?.toDouble(),
      answers: json['answers'] as Map<String, dynamic>? ?? const {},
      uploadedFiles:
          (json['uploaded_files'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SubmissionImplToJson(_$SubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribution_id': instance.distributionId,
      'student_id': instance.studentId,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'graded_at': instance.gradedAt?.toIso8601String(),
      'score': instance.score,
      'feedback': instance.feedback,
      'total_points': instance.totalPoints,
      'answers': instance.answers,
      'uploaded_files': instance.uploadedFiles,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.draft: 'draft',
  SubmissionStatus.submitted: 'submitted',
  SubmissionStatus.graded: 'graded',
};

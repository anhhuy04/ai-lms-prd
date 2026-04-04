// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_override.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GradeOverrideImpl _$$GradeOverrideImplFromJson(Map<String, dynamic> json) =>
    _$GradeOverrideImpl(
      id: json['id'] as String,
      submissionAnswerId: json['submission_answer_id'] as String,
      overriddenBy: json['overridden_by'] as String,
      overriddenByName: json['overridden_by_name'] as String?,
      oldScore: (json['old_score'] as num).toDouble(),
      newScore: (json['new_score'] as num).toDouble(),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$GradeOverrideImplToJson(_$GradeOverrideImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submission_answer_id': instance.submissionAnswerId,
      'overridden_by': instance.overriddenBy,
      'overridden_by_name': instance.overriddenByName,
      'old_score': instance.oldScore,
      'new_score': instance.newScore,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
    };

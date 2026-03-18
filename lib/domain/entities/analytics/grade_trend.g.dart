// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_trend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GradeTrendImpl _$$GradeTrendImplFromJson(Map<String, dynamic> json) =>
    _$GradeTrendImpl(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      assignmentName: json['assignmentName'] as String,
      assignmentId: json['assignmentId'] as String?,
    );

Map<String, dynamic> _$$GradeTrendImplToJson(_$GradeTrendImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'score': instance.score,
      'assignmentName': instance.assignmentName,
      'assignmentId': instance.assignmentId,
    };

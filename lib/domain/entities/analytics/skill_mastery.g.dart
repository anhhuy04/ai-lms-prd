// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_mastery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SkillMasteryImpl _$$SkillMasteryImplFromJson(Map<String, dynamic> json) =>
    _$SkillMasteryImpl(
      objectiveId: json['objectiveId'] as String,
      skillName: json['skillName'] as String,
      masteryLevel: (json['masteryLevel'] as num?)?.toDouble() ?? 0.0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      isStrong: json['isStrong'] as bool? ?? false,
      isWeak: json['isWeak'] as bool? ?? false,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$SkillMasteryImplToJson(_$SkillMasteryImpl instance) =>
    <String, dynamic>{
      'objectiveId': instance.objectiveId,
      'skillName': instance.skillName,
      'masteryLevel': instance.masteryLevel,
      'attempts': instance.attempts,
      'isStrong': instance.isStrong,
      'isWeak': instance.isWeak,
      'description': instance.description,
    };

_$DeepAnalysisImpl _$$DeepAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$DeepAnalysisImpl(
      tagAccuracies:
          (json['tagAccuracies'] as List<dynamic>?)
              ?.map((e) => TagAccuracy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      difficultyScores:
          (json['difficultyScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      timePerQuestion:
          (json['timePerQuestion'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      repeatedErrors:
          (json['repeatedErrors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DeepAnalysisImplToJson(_$DeepAnalysisImpl instance) =>
    <String, dynamic>{
      'tagAccuracies': instance.tagAccuracies,
      'difficultyScores': instance.difficultyScores,
      'timePerQuestion': instance.timePerQuestion,
      'repeatedErrors': instance.repeatedErrors,
    };

_$TagAccuracyImpl _$$TagAccuracyImplFromJson(Map<String, dynamic> json) =>
    _$TagAccuracyImpl(
      tag: json['tag'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
    );

Map<String, dynamic> _$$TagAccuracyImplToJson(_$TagAccuracyImpl instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'accuracy': instance.accuracy,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
    };

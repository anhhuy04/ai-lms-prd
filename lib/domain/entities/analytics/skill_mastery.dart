// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_mastery.freezed.dart';
part 'skill_mastery.g.dart';

/// Skill mastery data for radar chart visualization
@freezed
class SkillMastery with _$SkillMastery {
  const factory SkillMastery({
    required String objectiveId,
    required String skillName,
    @Default(0.0) double masteryLevel, // 0.0 - 1.0
    @Default(0) int attempts,
    @Default(false) bool isStrong, // masteryLevel >= 0.7
    @Default(false) bool isWeak, // masteryLevel < 0.4
    String? description,
  }) = _SkillMastery;

  factory SkillMastery.fromJson(Map<String, dynamic> json) =>
      _$SkillMasteryFromJson(json);
}

/// Deep analysis for strength/weakness - includes detailed metrics
@freezed
class DeepAnalysis with _$DeepAnalysis {
  const factory DeepAnalysis({
    @Default([]) List<TagAccuracy> tagAccuracies,
    @Default({}) Map<String, double> difficultyScores,
    @Default({}) Map<String, int> timePerQuestion,
    @Default([]) List<String> repeatedErrors,
  }) = _DeepAnalysis;

  factory DeepAnalysis.fromJson(Map<String, dynamic> json) =>
      _$DeepAnalysisFromJson(json);
}

/// Accuracy by tag/category
@freezed
class TagAccuracy with _$TagAccuracy {
  const factory TagAccuracy({
    required String tag,
    required double accuracy,
    required int totalQuestions,
    required int correctAnswers,
  }) = _TagAccuracy;

  factory TagAccuracy.fromJson(Map<String, dynamic> json) =>
      _$TagAccuracyFromJson(json);
}

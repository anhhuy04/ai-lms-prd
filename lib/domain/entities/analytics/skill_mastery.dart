// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_mastery.freezed.dart';
part 'skill_mastery.g.dart';

/// Skill mastery data for radar chart visualization
@freezed
class SkillMastery with _$SkillMastery {
  const factory SkillMastery({
    required String objectiveId,

    /// Raw skill identifier (e.g., 'mmt.1-6' from code column)
    required String skillName,
    @Default(0.0) double masteryLevel, // 0.0 - 1.0
    @Default(0) int attempts,
    @Default(false) bool isStrong, // masteryLevel >= 0.7
    @Default(false) bool isWeak, // masteryLevel < 0.4
    /// Human-readable description from learning_objectives.description
    /// (e.g., 'Trigonometry - Basic Concepts')
    String? description,

    /// Display name formatted for UI (human-friendly)
    /// Example: "mmt.1-6" → "MMT 1-6" or "Toán học 1-6"
    String? displayName,

    /// Full semantic label for AI analysis: [Code] - [Description]
    /// Example: "M3.1 - Lượng giác cơ bản"
    /// Used when passing to AI for recommendations/insights
    String? semanticLabel,
  }) = _SkillMastery;

  factory SkillMastery.fromJson(Map<String, dynamic> json) =>
      _$SkillMasteryFromJson(json);

  /// Private constructor for extension methods
  const SkillMastery._();
}

/// Extension methods for SkillMastery computed properties
extension SkillMasteryExtension on SkillMastery {
  /// Get human-friendly display label for UI (radar chart)
  /// MUST use description (semantic meaning), NOT the code
  /// Description is what students/teachers understand
  /// Example: description="Giải phương trình Lượng giác" → uiLabel="Giải phương trình Lượng giác"
  /// Fallback: displayName → skillName
  String get uiLabel => description ?? displayName ?? skillName;

  /// Get full semantic label for AI analysis/context
  /// Combines code and description: "M3.1 - Lượng giác cơ bản"
  /// Fallback to description if semantic label not available
  String get aiLabel => semanticLabel ?? description ?? skillName;
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

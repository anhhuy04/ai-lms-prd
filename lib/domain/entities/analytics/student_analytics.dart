// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'skill_mastery.dart';
import 'grade_trend.dart';

part 'student_analytics.freezed.dart';
part 'student_analytics.g.dart';

/// Student analytics data model - combines all personal performance metrics
@freezed
class StudentAnalytics with _$StudentAnalytics {
  const factory StudentAnalytics({
    @Default(BasicEngagementMetrics()) BasicEngagementMetrics basicMetrics,
    @Default([]) List<SkillMastery> skillMasteries,
    @Default([]) List<GradeTrend> gradeTrends,
    @Default(StrengthWeaknessAnalysis()) StrengthWeaknessAnalysis strengthsWeaknesses,
    @Default(ClassComparison()) ClassComparison classComparison,
  }) = _StudentAnalytics;

  factory StudentAnalytics.fromJson(Map<String, dynamic> json) =>
      _$StudentAnalyticsFromJson(json);
}

/// Basic engagement metrics for personal dashboard
@freezed
class BasicEngagementMetrics with _$BasicEngagementMetrics {
  const factory BasicEngagementMetrics({
    @Default(0) @JsonKey(name: 'avg_score') double avgScore,
    @Default(0) @JsonKey(name: 'on_time_rate') double onTimeRate,
    @Default(0) @JsonKey(name: 'total_time_minutes') int totalTimeMinutes,
    @Default(0) @JsonKey(name: 'submission_count') int submissionCount,
    @JsonKey(name: 'trend_direction') TrendDirection? trendDirection,
  }) = _BasicEngagementMetrics;

  factory BasicEngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$BasicEngagementMetricsFromJson(json);
}

/// Trend direction for grade movement
enum TrendDirection {
  up,
  down,
  stable,
}

/// Strength and weakness analysis
@freezed
class StrengthWeaknessAnalysis with _$StrengthWeaknessAnalysis {
  const factory StrengthWeaknessAnalysis({
    @Default([]) List<SkillMastery> strengths,
    @Default([]) List<SkillMastery> weaknesses,
  }) = _StrengthWeaknessAnalysis;

  factory StrengthWeaknessAnalysis.fromJson(Map<String, dynamic> json) =>
      _$StrengthWeaknessAnalysisFromJson(json);
}

/// Comparison against class average
@freezed
class ClassComparison with _$ClassComparison {
  const factory ClassComparison({
    @Default(0.0) @JsonKey(name: 'class_average') double classAverage,
    @Default(0.0) @JsonKey(name: 'percentile') double percentile,
    @Default(0) @JsonKey(name: 'rank') int rank,
    @Default(0) @JsonKey(name: 'total_students') int totalStudents,
  }) = _ClassComparison;

  factory ClassComparison.fromJson(Map<String, dynamic> json) =>
      _$ClassComparisonFromJson(json);
}

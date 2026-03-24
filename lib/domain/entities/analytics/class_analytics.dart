// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_analytics.freezed.dart';
part 'class_analytics.g.dart';

/// Class analytics data for teacher view
@freezed
class ClassAnalytics with _$ClassAnalytics {
  const factory ClassAnalytics({
    @Default('') @JsonKey(name: 'class_id') String classId,
    @Default('') @JsonKey(name: 'class_name') String className,
    @Default(0.0) @JsonKey(name: 'class_average') double classAverage,
    @Default(0) @JsonKey(name: 'total_students') int totalStudents,
    @Default(0) @JsonKey(name: 'total_submissions') int totalSubmissions,
    @Default(0.0) @JsonKey(name: 'submission_rate') double submissionRate,
    @Default(0.0) @JsonKey(name: 'late_submission_rate') double lateSubmissionRate,
    @Default(0) @JsonKey(name: 'late_submission_count') int lateSubmissionCount,
    WorstOffender? worstOffender,
    double? highestScore,
    double? lowestScore,
    @Default([]) List<ClassDistribution> distribution,
    @Default([]) List<SubjectDistribution> subjectDistributions,
    @Default([]) @JsonKey(name: 'top_performers') List<StudentPerformance> topPerformers,
    @Default([]) @JsonKey(name: 'bottom_performers') List<StudentPerformance> bottomPerformers,
  }) = _ClassAnalytics;

  factory ClassAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ClassAnalyticsFromJson(json);
}

/// Score distribution bucket for histogram
@freezed
class ClassDistribution with _$ClassDistribution {
  const factory ClassDistribution({
    @Default(0) int rangeStart,
    @Default(0) int rangeEnd,
    @Default(0) int count,
  }) = _ClassDistribution;

  factory ClassDistribution.fromJson(Map<String, dynamic> json) =>
      _$ClassDistributionFromJson(json);
}

/// Individual student performance for top/bottom lists
@freezed
class StudentPerformance with _$StudentPerformance {
  const factory StudentPerformance({
    required String studentId,
    required String studentName,
    required double score,
    @Default(0) int submissionCount,
  }) = _StudentPerformance;

  factory StudentPerformance.fromJson(Map<String, dynamic> json) =>
      _$StudentPerformanceFromJson(json);
}

/// Student with the most late submissions (worst offender)
@freezed
class WorstOffender with _$WorstOffender {
  const factory WorstOffender({
    required String studentId,
    required String studentName,
    required int lateCount,
  }) = _WorstOffender;

  factory WorstOffender.fromJson(Map<String, dynamic> json) =>
      _$WorstOffenderFromJson(json);
}

/// Grade distribution for a subject/assignment across score buckets.
@freezed
class SubjectDistribution with _$SubjectDistribution {
  const factory SubjectDistribution({
    required String subjectName,
    @Default(0) int below50Count,
    @Default(0) int below60Count,
    @Default(0) int below80Count,
    @Default(0) int above80Count,
    @Default([]) List<StudentScoreItem> below50Students,
    @Default([]) List<StudentScoreItem> below60Students,
    @Default([]) List<StudentScoreItem> below80Students,
    @Default([]) List<StudentScoreItem> above80Students,
  }) = _SubjectDistribution;

  factory SubjectDistribution.fromJson(Map<String, dynamic> json) =>
      _$SubjectDistributionFromJson(json);
}

/// Student with score for bucket display in bottom sheet
@freezed
class StudentScoreItem with _$StudentScoreItem {
  const factory StudentScoreItem({
    required String studentId,
    required String studentName,
    required double score,
  }) = _StudentScoreItem;

  factory StudentScoreItem.fromJson(Map<String, dynamic> json) =>
      _$StudentScoreItemFromJson(json);
}

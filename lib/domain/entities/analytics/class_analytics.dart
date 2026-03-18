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
    @Default([]) List<ClassDistribution> distribution,
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

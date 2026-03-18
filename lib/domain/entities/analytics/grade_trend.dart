// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade_trend.freezed.dart';
part 'grade_trend.g.dart';

/// Grade trend data point for line chart visualization
@freezed
class GradeTrend with _$GradeTrend {
  const factory GradeTrend({
    required DateTime date,
    required double score,
    required String assignmentName,
    String? assignmentId,
  }) = _GradeTrend;

  factory GradeTrend.fromJson(Map<String, dynamic> json) =>
      _$GradeTrendFromJson(json);
}

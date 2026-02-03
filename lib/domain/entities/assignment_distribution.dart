// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_distribution.freezed.dart';
part 'assignment_distribution.g.dart';

/// Entity cho bảng `assignment_distributions`.
@freezed
class AssignmentDistribution with _$AssignmentDistribution {
  const factory AssignmentDistribution({
    required String id,
    @JsonKey(name: 'assignment_id') required String assignmentId,
    @JsonKey(name: 'distribution_type') required String distributionType,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'student_ids') List<String>? studentIds,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') @Default(true) bool allowLate,
    @JsonKey(name: 'late_policy') Map<String, dynamic>? latePolicy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AssignmentDistribution;

  factory AssignmentDistribution.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDistributionFromJson(json);
}


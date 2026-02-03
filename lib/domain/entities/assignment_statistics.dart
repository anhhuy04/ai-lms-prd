// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_statistics.freezed.dart';
part 'assignment_statistics.g.dart';

/// Entity cho Assignment Statistics
@freezed
class AssignmentStatistics with _$AssignmentStatistics {
  const factory AssignmentStatistics({
    @Default(0) @JsonKey(name: 'total_assignments') int totalAssignments,
    @Default(0) @JsonKey(name: 'ungraded_assignments') int ungradedAssignments,
    @Default(0) @JsonKey(name: 'creating_count') int creatingCount,
    @Default(0) @JsonKey(name: 'distributing_count') int distributingCount,
    @Default(0) @JsonKey(name: 'waiting_to_assign') int waitingToAssign,
    @Default(0) @JsonKey(name: 'assigned') int assigned,
    @Default(0) @JsonKey(name: 'in_progress') int inProgress,
    @Default(0) @JsonKey(name: 'ungraded') int ungraded,
    @Default(0) @JsonKey(name: 'graded') int graded,
  }) = _AssignmentStatistics;

  factory AssignmentStatistics.fromJson(Map<String, dynamic> json) =>
      _$AssignmentStatisticsFromJson(json);
}

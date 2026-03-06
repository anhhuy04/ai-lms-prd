// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentStatisticsImpl _$$AssignmentStatisticsImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentStatisticsImpl(
  totalAssignments: (json['total_assignments'] as num?)?.toInt() ?? 0,
  ungradedAssignments: (json['ungraded_assignments'] as num?)?.toInt() ?? 0,
  creatingCount: (json['creating_count'] as num?)?.toInt() ?? 0,
  distributingCount: (json['distributing_count'] as num?)?.toInt() ?? 0,
  waitingToAssign: (json['waiting_to_assign'] as num?)?.toInt() ?? 0,
  assigned: (json['assigned'] as num?)?.toInt() ?? 0,
  inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
  ungraded: (json['ungraded'] as num?)?.toInt() ?? 0,
  graded: (json['graded'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$AssignmentStatisticsImplToJson(
  _$AssignmentStatisticsImpl instance,
) => <String, dynamic>{
  'total_assignments': instance.totalAssignments,
  'ungraded_assignments': instance.ungradedAssignments,
  'creating_count': instance.creatingCount,
  'distributing_count': instance.distributingCount,
  'waiting_to_assign': instance.waitingToAssign,
  'assigned': instance.assigned,
  'in_progress': instance.inProgress,
  'ungraded': instance.ungraded,
  'graded': instance.graded,
};

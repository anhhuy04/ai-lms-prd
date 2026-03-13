// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_distribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentDistributionImpl _$$AssignmentDistributionImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentDistributionImpl(
  id: json['id'] as String,
  assignmentId: json['assignment_id'] as String,
  distributionType: json['distribution_type'] as String,
  classId: json['class_id'] as String?,
  groupId: json['group_id'] as String?,
  studentIds: (json['student_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  availableFrom: json['available_from'] == null
      ? null
      : DateTime.parse(json['available_from'] as String),
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
  allowLate: json['allow_late'] as bool? ?? true,
  latePolicy: json['late_policy'] as Map<String, dynamic>?,
  settings: json['settings'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  subjectName: json['subjectName'] as String?,
  className: json['className'] as String?,
  groupName: json['groupName'] as String?,
  assignmentTitle: json['assignmentTitle'] as String?,
  recipientCount: (json['recipientCount'] as num?)?.toInt(),
  submittedCount: (json['submittedCount'] as num?)?.toInt(),
  gradedCount: (json['gradedCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$AssignmentDistributionImplToJson(
  _$AssignmentDistributionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'assignment_id': instance.assignmentId,
  'distribution_type': instance.distributionType,
  'class_id': instance.classId,
  'group_id': instance.groupId,
  'student_ids': instance.studentIds,
  'available_from': instance.availableFrom?.toIso8601String(),
  'due_at': instance.dueAt?.toIso8601String(),
  'time_limit_minutes': instance.timeLimitMinutes,
  'allow_late': instance.allowLate,
  'late_policy': instance.latePolicy,
  'settings': instance.settings,
  'created_at': instance.createdAt?.toIso8601String(),
  'subjectName': instance.subjectName,
  'className': instance.className,
  'groupName': instance.groupName,
  'assignmentTitle': instance.assignmentTitle,
  'recipientCount': instance.recipientCount,
  'submittedCount': instance.submittedCount,
  'gradedCount': instance.gradedCount,
};

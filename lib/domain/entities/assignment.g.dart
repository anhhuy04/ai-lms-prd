// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentImpl _$$AssignmentImplFromJson(Map<String, dynamic> json) =>
    _$AssignmentImpl(
      id: json['id'] as String,
      classId: json['class_id'] as String?,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      dueAt: json['due_at'] == null
          ? null
          : DateTime.parse(json['due_at'] as String),
      availableFrom: json['available_from'] == null
          ? null
          : DateTime.parse(json['available_from'] as String),
      timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
      allowLate: json['allow_late'] as bool? ?? true,
      totalPoints: (json['total_points'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AssignmentImplToJson(_$AssignmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'teacher_id': instance.teacherId,
      'title': instance.title,
      'description': instance.description,
      'is_published': instance.isPublished,
      'published_at': instance.publishedAt?.toIso8601String(),
      'due_at': instance.dueAt?.toIso8601String(),
      'available_from': instance.availableFrom?.toIso8601String(),
      'time_limit_minutes': instance.timeLimitMinutes,
      'allow_late': instance.allowLate,
      'total_points': instance.totalPoints,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

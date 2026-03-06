// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_tree_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentNodeImpl _$$StudentNodeImplFromJson(Map<String, dynamic> json) =>
    _$StudentNodeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      score: (json['score'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$StudentNodeImplToJson(_$StudentNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'score': instance.score,
      'note': instance.note,
    };

_$GroupNodeImpl _$$GroupNodeImplFromJson(Map<String, dynamic> json) =>
    _$GroupNodeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      students:
          (json['students'] as List<dynamic>?)
              ?.map((e) => StudentNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GroupNodeImplToJson(_$GroupNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'students': instance.students,
    };

_$ClassNodeImpl _$$ClassNodeImplFromJson(Map<String, dynamic> json) =>
    _$ClassNodeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map((e) => GroupNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      independentStudents:
          (json['independentStudents'] as List<dynamic>?)
              ?.map((e) => StudentNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ClassNodeImplToJson(_$ClassNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'totalStudents': instance.totalStudents,
      'groups': instance.groups,
      'independentStudents': instance.independentStudents,
    };

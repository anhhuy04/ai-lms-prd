// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateGroupParamsImpl _$$CreateGroupParamsImplFromJson(
  Map<String, dynamic> json,
) => _$CreateGroupParamsImpl(
  classId: json['class_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$CreateGroupParamsImplToJson(
  _$CreateGroupParamsImpl instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'name': instance.name,
  'description': instance.description,
};

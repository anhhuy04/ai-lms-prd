// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherFileModelImpl _$$TeacherFileModelImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherFileModelImpl(
  id: json['id'] as String,
  filename: json['filename'] as String,
  storagePath: json['storage_path'] as String,
  url: json['url'] as String,
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  uploadedBy: json['uploaded_by'] as String,
  processingStatus: json['processing_status'] as String? ?? 'queued',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$TeacherFileModelImplToJson(
  _$TeacherFileModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'filename': instance.filename,
  'storage_path': instance.storagePath,
  'url': instance.url,
  'mime_type': instance.mimeType,
  'size_bytes': instance.sizeBytes,
  'uploaded_by': instance.uploadedBy,
  'processing_status': instance.processingStatus,
  'created_at': instance.createdAt?.toIso8601String(),
};

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_file_model.freezed.dart';
part 'teacher_file_model.g.dart';

/// Freezed model cho bảng `files` (Teacher Knowledge Library).
/// `processingStatus` là client-side field — không có trong DB schema,
/// được inject khi tạo row mới ('queued') hoặc tracked qua ai_queue.
@freezed
class TeacherFileModel with _$TeacherFileModel {
  const factory TeacherFileModel({
    required String id,
    required String filename,
    @JsonKey(name: 'storage_path') required String storagePath,
    required String url,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'uploaded_by') required String uploadedBy,
    @JsonKey(name: 'processing_status') @Default('queued') String processingStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TeacherFileModel;

  factory TeacherFileModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherFileModelFromJson(json);
}

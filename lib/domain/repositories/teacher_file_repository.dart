import 'dart:typed_data';

import 'package:ai_mls/data/models/teacher_file_model.dart';

/// Contract cho Teacher Knowledge Library (file upload + retrieval).
abstract class ITeacherFileRepository {
  /// Upload file bytes, register in files/file_links/ai_queue tables.
  /// Returns immediately with processingStatus='queued' — UI does NOT wait for AI.
  Future<TeacherFileModel> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });

  /// Retrieve all files belonging to this teacher (via file_links join).
  Future<List<TeacherFileModel>> getTeacherFiles();

  /// Delete a file from Storage + files/file_links/ai_queue tables.
  Future<void> deleteFile(String fileId);
}

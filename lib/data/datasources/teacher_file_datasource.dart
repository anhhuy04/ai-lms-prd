import 'dart:typed_data';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho Teacher Knowledge Library (files + file_links + ai_queue).
///
/// Implements D-05 (5-step upload pipeline):
///   1. Upload binary lên Supabase Storage (teacher-documents bucket — private)
///   2. INSERT vào `files` table (metadata + signed URL)
///   3. INSERT vào `file_links` (target_type='teacher', target_id=teacherId)
///   4. INSERT vào `ai_queue` payload {file_id, action} — fire-and-forget
///   5. Return TeacherFileModel với processingStatus='queued'
class TeacherFileDataSource {
  final SupabaseClient _supabase;

  TeacherFileDataSource(this._supabase);

  /// D-05: Upload binary + save metadata + link to teacher + enqueue AI job.
  /// Returns immediately after all 4 DB operations — UI does NOT wait for AI.
  Future<TeacherFileModel> uploadAndRegisterFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required String teacherId,
  }) async {
    // Step 1: Upload to Storage (private bucket — path: teachers/{id}/{filename})
    final storagePath = 'teachers/$teacherId/$filename';
    await _supabase.storage
        .from('teacher-documents')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    // Private bucket — createSignedUrl() NOT getPublicUrl()
    final url = await _supabase.storage
        .from('teacher-documents')
        .createSignedUrl(storagePath, 60 * 60 * 24 * 7); // 7-day expiry

    // Step 2: INSERT into files table
    final fileRow = await _supabase
        .from('files')
        .insert({
          'storage_path': storagePath,
          'url': url,
          'filename': filename,
          'mime_type': mimeType,
          'size_bytes': bytes.length,
          'uploaded_by': teacherId,
        })
        .select()
        .single();

    final fileId = fileRow['id'] as String;

    // Step 3: INSERT file_links (polymorphic — target_type='teacher')
    await _supabase.from('file_links').insert({
      'file_id': fileId,
      'target_type': 'teacher',
      'target_id': teacherId,
    });

    // Step 4: INSERT ai_queue — fire-and-forget (column is `payload`, NOT `request_payload`)
    // After Migration 012, request_type='vectorize_document' is valid
    await _supabase.from('ai_queue').insert({
      'request_type': 'vectorize_document',
      'payload': {'file_id': fileId, 'action': 'extract_or_vectorize'},
      'status': 'pending',
      'attempts': 0,
    });

    AppLogger.info('[TeacherFile] Uploaded $filename → fileId=$fileId (queued for AI)');

    // Step 5: Return immediately with processingStatus='queued'
    return TeacherFileModel.fromJson({
      ...fileRow,
      'processing_status': 'queued',
    });
  }

  /// Query teacher's files via file_links join.
  /// Only returns files linked with target_type='teacher' for the given teacher.
  Future<List<TeacherFileModel>> getTeacherFiles(String teacherId) async {
    final rows = await _supabase
        .from('file_links')
        .select('files(*)')
        .eq('target_type', 'teacher')
        .eq('target_id', teacherId)
        .order('created_at', ascending: false);

    return rows
        .map((r) => r['files'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map(TeacherFileModel.fromJson)
        .toList();
  }
}

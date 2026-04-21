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

  /// Delete a temp file: Storage object + ai_queue rows + file_links + files row.
  /// Deletion order respects FK constraints: ai_queue/file_links first, then files.
  Future<void> deleteFile(String fileId) async {
    AppLogger.info('[TeacherFile] deleteFile: start fileId=$fileId');

    // Read storage_path before deleting the files row
    final fileRow = await _supabase
        .from('files')
        .select('storage_path')
        .eq('id', fileId)
        .maybeSingle();

    if (fileRow == null) {
      AppLogger.warning('[TeacherFile] deleteFile: fileId=$fileId not found — skipping');
      return;
    }

    final storagePath = fileRow['storage_path'] as String;

    // Delete from Storage bucket
    await _supabase.storage.from('teacher-documents').remove([storagePath]);
    AppLogger.info('[TeacherFile] deleteFile: storage removed path=$storagePath');

    // Delete ai_queue rows for this file
    await _supabase
        .from('ai_queue')
        .delete()
        .filter('payload->>file_id', 'eq', fileId);
    AppLogger.info('[TeacherFile] deleteFile: ai_queue rows deleted');

    // Delete file_links row
    await _supabase.from('file_links').delete().eq('file_id', fileId);
    AppLogger.info('[TeacherFile] deleteFile: file_links row deleted');

    // Delete files row
    await _supabase.from('files').delete().eq('id', fileId);
    AppLogger.info('[TeacherFile] deleteFile: files row deleted — done');
  }

  /// Query teacher's files via file_links join, enriched with real AI processing
  /// status from ai_queue (BUG-02 fix: processingStatus was always stuck at 'queued').
  Future<List<TeacherFileModel>> getTeacherFiles(String teacherId) async {
    final rows = await _supabase
        .from('file_links')
        .select('files(*)')
        .eq('target_type', 'teacher')
        .eq('target_id', teacherId)
        .order('created_at', ascending: false);

    final files = rows
        .map((r) => r['files'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .toList();

    if (files.isEmpty) return [];

    // Fetch real processing status from ai_queue for each file
    final fileIds = files.map((f) => f['id'] as String).toList();
    final queueRows = await _supabase
        .from('ai_queue')
        .select('payload, status')
        .eq('request_type', 'vectorize_document')
        .inFilter('payload->>file_id', fileIds);

    // Map fileId → ai_queue.status (latest queue entry wins)
    final statusMap = <String, String>{};
    for (final q in queueRows) {
      final fileId = q['payload']?['file_id'] as String?;
      if (fileId != null) statusMap[fileId] = q['status'] as String? ?? 'queued';
    }

    return files.map((f) {
      final fileId = f['id'] as String;
      final queueStatus = statusMap[fileId] ?? 'queued';
      return TeacherFileModel.fromJson({...f, 'processing_status': queueStatus});
    }).toList();
  }
}

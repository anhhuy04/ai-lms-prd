import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/models/teacher_note_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho bảng `teacher_notes` — ghi chú riêng tư của GV về học sinh.
class TeacherNotesDataSource {
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy danh sách ghi chú của một học sinh (RLS lọc theo GV hiện tại).
  Future<List<TeacherNoteDto>> getNotes(String studentId) async {
    try {
      final result = await _client
          .from('teacher_notes')
          .select('*')
          .eq('student_id', studentId)
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(result)
          .map(TeacherNoteDto.fromJson)
          .toList();
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesDataSource] getNotes error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Tạo ghi chú mới (teacher_id = user hiện tại).
  Future<TeacherNoteDto> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _client
          .from('teacher_notes')
          .insert({
            'teacher_id': currentUser.id,
            'student_id': studentId,
            'content': content,
            'is_private': isPrivate,
          })
          .select()
          .single();

      return TeacherNoteDto.fromJson(Map<String, dynamic>.from(result));
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesDataSource] addNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Cập nhật nội dung / quyền riêng tư của một ghi chú.
  Future<TeacherNoteDto> updateNote({
    required String id,
    required String content,
    bool? isPrivate,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content,
        if (isPrivate != null) 'is_private': isPrivate,
      };

      final result = await _client
          .from('teacher_notes')
          .update(payload)
          .eq('id', id)
          .select()
          .single();

      return TeacherNoteDto.fromJson(Map<String, dynamic>.from(result));
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesDataSource] updateNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Xóa một ghi chú.
  Future<void> deleteNote(String id) async {
    try {
      await _client.from('teacher_notes').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesDataSource] deleteNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

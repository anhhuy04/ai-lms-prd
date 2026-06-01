import 'package:ai_mls/domain/entities/teacher_note.dart';

/// Repository interface cho teacher_notes.
abstract class TeacherNotesRepository {
  /// Lấy danh sách ghi chú của một học sinh.
  Future<List<TeacherNote>> getNotes(String studentId);

  /// Tạo ghi chú mới.
  Future<TeacherNote> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  });

  /// Cập nhật một ghi chú.
  Future<TeacherNote> updateNote({
    required String id,
    required String content,
    bool? isPrivate,
  });

  /// Xóa một ghi chú.
  Future<void> deleteNote(String id);
}

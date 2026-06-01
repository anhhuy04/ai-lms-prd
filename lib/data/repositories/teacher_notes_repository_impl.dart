import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/teacher_notes_datasource.dart';
import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:ai_mls/domain/repositories/teacher_notes_repository.dart';

/// Implementation của TeacherNotesRepository.
class TeacherNotesRepositoryImpl implements TeacherNotesRepository {
  final TeacherNotesDataSource _datasource;

  TeacherNotesRepositoryImpl(this._datasource);

  @override
  Future<List<TeacherNote>> getNotes(String studentId) async {
    try {
      final dtos = await _datasource.getNotes(studentId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesRepository] getNotes error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<TeacherNote> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  }) async {
    try {
      final dto = await _datasource.addNote(
        studentId: studentId,
        content: content,
        isPrivate: isPrivate,
      );
      return dto.toEntity();
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesRepository] addNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<TeacherNote> updateNote({
    required String id,
    required String content,
    bool? isPrivate,
  }) async {
    try {
      final dto = await _datasource.updateNote(
        id: id,
        content: content,
        isPrivate: isPrivate,
      );
      return dto.toEntity();
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesRepository] updateNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _datasource.deleteNote(id);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherNotesRepository] deleteNote error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/repositories/teacher_notes_repository_impl.dart';
import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:ai_mls/domain/repositories/teacher_notes_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'datasource_providers.dart';

part 'teacher_notes_provider.g.dart';

/// Provider cho TeacherNotesRepository.
@riverpod
TeacherNotesRepository teacherNotesRepository(Ref ref) {
  final datasource = ref.watch(teacherNotesDataSourceProviderProvider);
  return TeacherNotesRepositoryImpl(datasource);
}

/// Provider lấy danh sách ghi chú của một học sinh.
@riverpod
Future<List<TeacherNote>> teacherNotes(
  Ref ref, {
  required String studentId,
}) async {
  final repository = ref.watch(teacherNotesRepositoryProvider);
  try {
    return await repository.getNotes(studentId);
  } catch (e, stackTrace) {
    AppLogger.error(
      '🔴 [TEACHER_NOTES] Error loading notes: $e',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Notifier cho các mutation (thêm/sửa/xóa) ghi chú của giáo viên.
@riverpod
class TeacherNotesNotifier extends _$TeacherNotesNotifier {
  bool _isUpdating = false;

  @override
  Future<void> build() async {}

  /// Thêm ghi chú mới rồi refresh danh sách.
  Future<void> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final repository = ref.read(teacherNotesRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.addNote(
        studentId: studentId,
        content: content,
        isPrivate: isPrivate,
      );
      AppLogger.info('📝 Added teacher note for student: $studentId');
      ref.invalidate(teacherNotesProvider(studentId: studentId));
    });

    _isUpdating = false;
  }

  /// Cập nhật một ghi chú rồi refresh danh sách.
  Future<void> updateNote({
    required String id,
    required String studentId,
    required String content,
    bool? isPrivate,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final repository = ref.read(teacherNotesRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.updateNote(
        id: id,
        content: content,
        isPrivate: isPrivate,
      );
      AppLogger.info('✏️ Updated teacher note: $id');
      ref.invalidate(teacherNotesProvider(studentId: studentId));
    });

    _isUpdating = false;
  }

  /// Xóa một ghi chú rồi refresh danh sách.
  Future<void> deleteNote({
    required String id,
    required String studentId,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final repository = ref.read(teacherNotesRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.deleteNote(id);
      AppLogger.info('🗑️ Deleted teacher note: $id');
      ref.invalidate(teacherNotesProvider(studentId: studentId));
    });

    _isUpdating = false;
  }
}

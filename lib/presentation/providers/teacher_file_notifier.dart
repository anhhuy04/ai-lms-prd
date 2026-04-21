import 'dart:typed_data';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/teacher_file_datasource.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/data/repositories/teacher_file_repository_impl.dart';
import 'package:ai_mls/domain/repositories/teacher_file_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'teacher_file_notifier.g.dart';

/// Repository provider — built with Supabase.instance (no supabaseClientProvider in codebase).
/// Class name: TeacherFileRepository → generates teacherFileRepositoryProvider
@riverpod
ITeacherFileRepository teacherFileRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  final teacherId = supabase.auth.currentUser?.id ?? '';
  return TeacherFileRepositoryImpl(
    TeacherFileDataSource(supabase),
    teacherId,
  );
}

/// Async notifier for teacher's file library.
/// Class name `TeacherFiles` → generator produces `teacherFilesProvider`.
/// Plan 05 (ContextSourcesSection) uses: ref.watch(teacherFilesProvider)
@riverpod
class TeacherFiles extends _$TeacherFiles {
  @override
  Future<List<TeacherFileModel>> build() async {
    return ref.read(teacherFileRepositoryProvider).getTeacherFiles();
  }

  /// Upload a new file and prepend it to the list.
  /// Optimistic: sets state to AsyncLoading then updates with new list.
  Future<void> uploadFile(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    // BUG-01 fix: capture current list BEFORE setting AsyncLoading.
    // Reading state.valueOrNull after state=AsyncLoading() returns null,
    // causing every upload to drop the previous list.
    final current = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(teacherFileRepositoryProvider);
      final newFile = await repo.uploadFile(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );
      AppLogger.info('[TeacherFiles] Upload success: ${newFile.filename}');
      return [newFile, ...current];
    });
  }

  /// Remove a file from state + delete from Supabase.
  Future<void> deleteFile(String fileId) async {
    final current = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherFileRepositoryProvider).deleteFile(fileId);
      AppLogger.info('[TeacherFiles] deleteFile success: $fileId');
      return current.where((f) => f.id != fileId).toList();
    });
  }
}

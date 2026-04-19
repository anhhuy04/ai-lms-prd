import 'dart:typed_data';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/teacher_file_datasource.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/domain/repositories/teacher_file_repository.dart';

/// Implementation of [ITeacherFileRepository].
/// Delegates all Supabase operations to [TeacherFileDataSource].
class TeacherFileRepositoryImpl implements ITeacherFileRepository {
  final TeacherFileDataSource _dataSource;
  final String _teacherId;

  TeacherFileRepositoryImpl(this._dataSource, this._teacherId);

  @override
  Future<TeacherFileModel> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      return await _dataSource.uploadAndRegisterFile(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        teacherId: _teacherId,
      );
    } catch (e, st) {
      AppLogger.error(
        '[TeacherFileRepo] uploadFile failed: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<TeacherFileModel>> getTeacherFiles() async {
    try {
      return await _dataSource.getTeacherFiles(_teacherId);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherFileRepo] getTeacherFiles failed: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

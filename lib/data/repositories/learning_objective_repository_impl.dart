import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/learning_objective_datasource.dart';
import 'package:ai_mls/domain/entities/learning_objective.dart';
import 'package:ai_mls/domain/repositories/learning_objective_repository.dart';

class LearningObjectiveRepositoryImpl implements LearningObjectiveRepository {
  final LearningObjectiveDataSource _ds;

  LearningObjectiveRepositoryImpl(this._ds);

  @override
  Future<LearningObjective> createObjective(
    Map<String, dynamic> payload,
  ) async {
    try {
      final row = await _ds.insertObjective(payload);
      return LearningObjective.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createObjective: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo mục tiêu học tập');
    }
  }

  @override
  Future<LearningObjective> updateObjective(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final row = await _ds.updateObjective(id, payload);
      return LearningObjective.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [REPO ERROR] updateObjective: $e', error: e, stackTrace: stackTrace);
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật mục tiêu học tập');
    }
  }

  @override
  Future<void> deleteObjective(String id) async {
    try {
      await _ds.deleteObjective(id);
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [REPO ERROR] deleteObjective: $e', error: e, stackTrace: stackTrace);
      throw ErrorTranslationUtils.translateError(e, 'Xóa mục tiêu học tập');
    }
  }

  @override
  Future<List<LearningObjective>> getObjectives({String? subjectCode}) async {
    try {
      final rows = await _ds.getObjectives(subjectCode: subjectCode);
      return rows.map(LearningObjective.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getObjectives(subjectCode: $subjectCode): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách mục tiêu học tập',
      );
    }
  }
}

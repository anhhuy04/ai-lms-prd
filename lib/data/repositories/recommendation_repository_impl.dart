import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/recommendation_datasource.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';
import 'package:ai_mls/domain/repositories/recommendation_repository.dart';

/// Implementation of RecommendationRepository
class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationDatasource _datasource;

  RecommendationRepositoryImpl({required RecommendationDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<Recommendation>> getRecommendations({
    required String userId,
    required String role,
    String? classId,
    int limit = 20,
  }) async {
    try {
      if (role == 'teacher') {
        return _datasource.getTeacherRecommendations(
          userId,
          classId: classId,
          limit: limit,
        );
      } else {
        return _datasource.getStudentRecommendations(
          userId,
          classId: classId,
          limit: limit,
        );
      }
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationRepository] getRecommendations error',
        error: e,
        stackTrace: st,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy gợi ý');
    }
  }

  @override
  Future<bool> dismissRecommendation(String recommendationId) async {
    try {
      return _datasource.dismissRecommendation(recommendationId);
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationRepository] dismissRecommendation error',
        error: e,
        stackTrace: st,
      );
      throw ErrorTranslationUtils.translateError(e, 'Bỏ gợi ý');
    }
  }

  @override
  Future<bool> bulkDismiss(List<String> ids) async {
    try {
      return _datasource.bulkDismiss(ids);
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationRepository] bulkDismiss error',
        error: e,
        stackTrace: st,
      );
      throw ErrorTranslationUtils.translateError(e, 'Bỏ nhiều gợi ý');
    }
  }

  @override
  Future<PeerComparison> getPeerComparison(
    String studentId,
    String classId,
  ) async {
    try {
      return _datasource.getPeerComparison(studentId, classId);
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationRepository] getPeerComparison error',
        error: e,
        stackTrace: st,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy so sánh lớp');
    }
  }
}

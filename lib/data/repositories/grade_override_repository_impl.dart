import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/grade_override_datasource.dart';

/// Repository interface cho grade overrides.
abstract class GradeOverrideRepository {
  /// Tạo một grade override mới.
  Future<Map<String, dynamic>> createOverride({
    required String submissionAnswerId,
    required String overriddenBy,
    required double oldScore,
    required double newScore,
    String? reason,
  });

  /// Lấy lịch sử override của một câu trả lời.
  Future<List<Map<String, dynamic>>> getOverrideHistory(String submissionAnswerId);

  /// Lấy tất cả overrides của một distribution.
  Future<List<Map<String, dynamic>>> getOverridesByDistribution(
      String distributionId);
}

/// Implementation của GradeOverrideRepository.
class GradeOverrideRepositoryImpl implements GradeOverrideRepository {
  final GradeOverrideDataSource _datasource;

  GradeOverrideRepositoryImpl(this._datasource);

  @override
  Future<Map<String, dynamic>> createOverride({
    required String submissionAnswerId,
    required String overriddenBy,
    required double oldScore,
    required double newScore,
    String? reason,
  }) async {
    try {
      return await _datasource.createGradeOverride(
        submissionAnswerId: submissionAnswerId,
        overriddenBy: overriddenBy,
        oldScore: oldScore,
        newScore: newScore,
        reason: reason,
      );
    } catch (e, st) {
      AppLogger.error(
        '[GradeOverrideRepository] createOverride error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOverrideHistory(
      String submissionAnswerId) async {
    try {
      return await _datasource.getOverrideHistory(submissionAnswerId);
    } catch (e, st) {
      AppLogger.error(
        '[GradeOverrideRepository] getOverrideHistory error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOverridesByDistribution(
      String distributionId) async {
    try {
      return await _datasource.getOverridesByDistribution(distributionId);
    } catch (e, st) {
      AppLogger.error(
        '[GradeOverrideRepository] getOverridesByDistribution error: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

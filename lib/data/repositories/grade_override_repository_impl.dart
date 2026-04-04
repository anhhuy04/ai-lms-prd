import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/grade_override_datasource.dart';
import 'package:ai_mls/domain/entities/grade_override.dart';
import 'package:ai_mls/domain/repositories/grade_override_repository.dart';

/// Implementation của GradeOverrideRepository.
class GradeOverrideRepositoryImpl implements GradeOverrideRepository {
  final GradeOverrideDataSource _datasource;

  GradeOverrideRepositoryImpl(this._datasource);

  @override
  Future<GradeOverride> createOverride({
    required String submissionAnswerId,
    required String overriddenBy,
    required double oldScore,
    required double newScore,
    String? reason,
  }) async {
    try {
      final row = await _datasource.createGradeOverride(
        submissionAnswerId: submissionAnswerId,
        overriddenBy: overriddenBy,
        oldScore: oldScore,
        newScore: newScore,
        reason: reason,
      );
      return GradeOverride.fromJson(row);
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
  Future<List<GradeOverride>> getOverrideHistory(String submissionAnswerId) async {
    try {
      final rows = await _datasource.getOverrideHistory(submissionAnswerId);
      return rows.map((row) {
        // Extract overridden_by_name from profiles join if present
        final profile = row['profiles'] as Map<String, dynamic>?;
        return GradeOverride(
          id: row['id'] as String,
          submissionAnswerId: row['submission_answer_id'] as String,
          overriddenBy: row['overridden_by'] as String,
          overriddenByName: profile?['full_name'] as String?,
          oldScore: (row['old_score'] as num).toDouble(),
          newScore: (row['new_score'] as num).toDouble(),
          reason: row['reason'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
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
  Future<List<GradeOverride>> getOverridesByDistribution(String distributionId) async {
    try {
      final rows = await _datasource.getOverridesByDistribution(distributionId);
      return rows.map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        return GradeOverride(
          id: row['id'] as String,
          submissionAnswerId: row['submission_answer_id'] as String,
          overriddenBy: row['overridden_by'] as String,
          overriddenByName: profile?['full_name'] as String?,
          oldScore: (row['old_score'] as num).toDouble(),
          newScore: (row['new_score'] as num).toDouble(),
          reason: row['reason'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
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

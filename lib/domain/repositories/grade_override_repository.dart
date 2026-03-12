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
  }) {
    return _datasource.createGradeOverride(
      submissionAnswerId: submissionAnswerId,
      overriddenBy: overriddenBy,
      oldScore: oldScore,
      newScore: newScore,
      reason: reason,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getOverrideHistory(
      String submissionAnswerId) {
    return _datasource.getOverrideHistory(submissionAnswerId);
  }

  @override
  Future<List<Map<String, dynamic>>> getOverridesByDistribution(
      String distributionId) {
    return _datasource.getOverridesByDistribution(distributionId);
  }
}

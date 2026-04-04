import 'package:ai_mls/domain/entities/grade_override.dart';

/// Repository interface cho grade overrides.
abstract class GradeOverrideRepository {
  /// Tạo một grade override mới.
  Future<GradeOverride> createOverride({
    required String submissionAnswerId,
    required String overriddenBy,
    required double oldScore,
    required double newScore,
    String? reason,
  });

  /// Lấy lịch sử override của một câu trả lời.
  Future<List<GradeOverride>> getOverrideHistory(String submissionAnswerId);

  /// Lấy tất cả overrides của một distribution.
  Future<List<GradeOverride>> getOverridesByDistribution(String distributionId);
}

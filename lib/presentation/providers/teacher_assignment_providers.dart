import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_assignment_providers.g.dart';

/// Lịch sử các lần làm của 1 student trong 1 distribution.
/// Params: (distributionId, studentId).
/// Auto-dispose, không cần invalidation thủ công — fetch lại khi widget rebuild.
final studentAttemptsProvider = FutureProvider.autoDispose
    .family<List<StudentAttemptSummary>, (String, String)>(
  (ref, params) {
    final (distributionId, studentId) = params;
    final repo = ref.watch(assignmentRepositoryProvider);
    return repo.getStudentAttempts(
      distributionId: distributionId,
      studentId: studentId,
    );
  },
);

/// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
/// Teacher-only — sẽ throw nếu không phải teacher của assignment.
/// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
@riverpod
Future<List<AggregatedScore>> aggregatedScores(
  Ref ref,
  String distributionId, {
  String? overrideRule,
}) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getAggregatedScores(
    distributionId: distributionId,
    overrideRule: overrideRule,
  );
}

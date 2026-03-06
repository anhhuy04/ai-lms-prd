import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assignment_providers.g.dart';

/// Provider cho AssignmentRepository (dùng @riverpod để codegen)
@riverpod
AssignmentRepository assignmentRepository(Ref ref) {
  throw UnimplementedError('Must override assignmentRepositoryProvider');
}

/// Bài tập đã distribute cho 1 lớp (teacher view).
/// Trả về List<Map> chứa cả assignment + distribution info.
@riverpod
Future<List<Map<String, dynamic>>> classDistributedAssignments(
  Ref ref,
  String classId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getDistributedAssignmentsByClass(classId);
}

/// Bài tập cho học sinh trong 1 lớp.
/// Filter theo distribution_type (class/group/individual).
@riverpod
Future<List<Map<String, dynamic>>> studentClassAssignments(
  Ref ref,
  String classId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return [];
  return repo.getDistributedAssignmentsForStudent(classId, studentId);
}

/// Chi tiết distribution (assignment config + stats).
@riverpod
Future<Map<String, dynamic>> distributionDetail(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getDistributionDetail(distributionId);
}

/// Danh sách submissions cho distribution (kèm student info).
@riverpod
Future<List<Map<String, dynamic>>> distributionSubmissions(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getSubmissionsByDistribution(distributionId);
}

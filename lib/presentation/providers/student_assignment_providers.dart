import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_assignment_providers.g.dart';

/// Provider cho AssignmentRepository (dùng @riverpod để codegen)
@riverpod
AssignmentRepository assignmentRepository(Ref ref) {
  throw UnimplementedError('Must override assignmentRepositoryProvider');
}

/// Danh sách bài tập của học sinh hiện tại (từ tất cả các lớp)
@riverpod
Future<List<Map<String, dynamic>>> studentAssignmentList(Ref ref) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return [];
  return repo.getStudentAssignments(studentId);
}

/// Chi tiết một bài tập cụ thể (bao gồm questions)
@riverpod
Future<Map<String, dynamic>> studentAssignmentDetail(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getDistributionDetail(distributionId);
}

/// Lấy hoặc tạo bài nộp (draft) cho một bài tập
@riverpod
Future<Map<String, dynamic>?> studentSubmission(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return null;
  return repo.getOrCreateSubmission(distributionId, studentId);
}

/// Lưu bản nháp bài nộp (auto-save)
@riverpod
Future<void> saveSubmissionDraft(
  Ref ref,
  String distributionId,
  Map<String, dynamic> answers,
  List<String> uploadedFiles,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return;
  await repo.saveSubmissionDraft(
    distributionId,
    studentId,
    answers,
    uploadedFiles,
  );
}

/// Nộp bài tập
@riverpod
Future<Map<String, dynamic>> submitAssignment(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) {
    throw Exception('User not authenticated');
  }
  return repo.submitAssignment(distributionId, studentId);
}

/// Lịch sử nộp bài của học sinh
@riverpod
Future<List<Map<String, dynamic>>> studentSubmissionHistory(Ref ref) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return [];
  return repo.getStudentSubmissionHistory(studentId);
}

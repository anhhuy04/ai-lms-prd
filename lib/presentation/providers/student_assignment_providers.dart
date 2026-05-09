import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/datasource_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_assignment_providers.g.dart';

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

/// Lấy trạng thái bài nộp (read-only) — KHÔNG tạo work_session.
/// Trả về null nếu học sinh chưa bắt đầu làm bài lần nào.
/// work_session chỉ được tạo khi học sinh bấm "Bắt đầu" vào workspace.
@riverpod
Future<Map<String, dynamic>?> studentSubmission(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return null;
  return repo.getSubmission(distributionId, studentId);
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

/// Chi tiết bài làm của học sinh để xem lại (read-only review screen).
/// Dùng distributionId + studentId — không cần submissionId.
@riverpod
Future<Map<String, dynamic>?> studentSubmissionReview(
  Ref ref,
  String distributionId,
) async {
  final ds = ref.watch(submissionDataSourceProviderProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return null;
  return ds.getStudentSubmissionDetail(distributionId, studentId);
}

/// Answers theo sessionId — dùng khi học sinh xem lại lần làm cụ thể.
/// Non-code-gen provider để tránh chạy lại build_runner.
final submissionAnswersBySessionProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, sessionId) async {
    final ds = ref.watch(submissionDataSourceProviderProvider);
    return ds.getSubmissionAnswersBySessionId(sessionId);
  },
);

/// Review detail theo sessionId — trả về cùng shape với [studentSubmissionReview]
/// nhưng metadata + answers thuộc session được truyền vào, không phải session
/// mới nhất. Dùng khi học sinh chọn 1 lần làm cụ thể từ lịch sử attempts.
final submissionReviewBySessionProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, sessionId) async {
    final ds = ref.watch(submissionDataSourceProviderProvider);
    return ds.getSessionReviewDetail(sessionId);
  },
);

/// Lịch sử nộp bài của học sinh (Tất cả các bài tập)
@riverpod
Future<List<Map<String, dynamic>>> studentSubmissionHistory(Ref ref) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return [];
  return repo.getStudentSubmissionHistory(studentId);
}

/// Lịch sử các lần làm bài (attempts) cho 1 bài tập cụ thể
@riverpod
Future<List<Map<String, dynamic>>> studentDistributionAttempts(
  Ref ref,
  String distributionId,
) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final auth = ref.watch(authNotifierProvider);
  final studentId = auth.value?.id;
  if (studentId == null) return [];
  return repo.getDistributionAttempts(distributionId, studentId);
}

/// Notifier cho tính năng làm lại bài tập.
/// Gọi [start()] để tạo redo session mới qua RPC.
/// Throws [RedoBlockedException] nếu không được phép (closed/pastDue/notAllowed/maxReached).
@riverpod
class RedoSession extends _$RedoSession {
  @override
  AsyncValue<RedoSessionResult?> build(String distributionId) =>
      const AsyncData(null);

  Future<RedoSessionResult> start() async {
    final auth = ref.read(authNotifierProvider);
    final studentId = auth.value?.id;
    if (studentId == null) {
      throw const RedoBlockedException(reason: RedoBlockReason.permission);
    }

    state = const AsyncLoading();
    try {
      final repo = ref.read(assignmentRepositoryProvider);
      final result = await repo.startRedoSession(
        distributionId: distributionId,
        studentId: studentId,
      );
      state = AsyncData(result);

      // Invalidate để refresh danh sách attempts + detail screen
      ref.invalidate(studentDistributionAttemptsProvider(distributionId));
      ref.invalidate(studentSubmissionProvider(distributionId));

      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_dashboard_providers.g.dart';

/// Bài tập sắp hết hạn (chưa nộp hoặc đang làm), sắp xếp theo due_at tăng dần.
@riverpod
Future<List<Map<String, dynamic>>> studentDueAssignments(Ref ref) async {
  final all = await ref.watch(studentAssignmentListProvider.future);
  final now = DateTime.now();

  final due = all.where((a) {
    final status = a['submission_status'] as String? ?? 'not_submitted';
    if (status == 'graded') return false;
    final dueAtStr = a['distribution_due_at'] as String?;
    if (dueAtStr == null) return true;
    final dueAt = DateTime.tryParse(dueAtStr);
    // Giữ lại nếu chưa quá hạn hơn 1 tiếng
    return dueAt == null || dueAt.isAfter(now.subtract(const Duration(hours: 1)));
  }).toList();

  due.sort((a, b) {
    final dueA = DateTime.tryParse(a['distribution_due_at'] as String? ?? '');
    final dueB = DateTime.tryParse(b['distribution_due_at'] as String? ?? '');
    if (dueA == null && dueB == null) return 0;
    if (dueA == null) return 1;
    if (dueB == null) return -1;
    return dueA.compareTo(dueB);
  });

  return due.take(5).toList();
}

/// Thống kê số bài đã nộp và chờ chấm.
@riverpod
Future<({int submitted, int pendingGrading})> studentDashboardStats(Ref ref) async {
  final history = await ref.watch(studentSubmissionHistoryProvider.future);
  final submitted = history.length;
  final pending = history
      .where((s) =>
          s['status'] == 'submitted' || s['status'] == 'ai_processing')
      .length;
  return (submitted: submitted, pendingGrading: pending);
}

/// Tiến độ hoàn thành bài tập trong tuần/tổng.
@riverpod
Future<({double progress, int remainingCount})> studentDashboardProgress(
  Ref ref,
) async {
  final all = await ref.watch(studentAssignmentListProvider.future);
  if (all.isEmpty) return (progress: 0.0, remainingCount: 0);
  final done = all
      .where((a) => (a['submission_status'] as String?) != 'not_submitted')
      .length;
  return (progress: done / all.length, remainingCount: all.length - done);
}

/// Danh sách điểm gần nhất (status = 'graded', có total_score).
@riverpod
Future<List<Map<String, dynamic>>> studentRecentScores(Ref ref) async {
  final history = await ref.watch(studentSubmissionHistoryProvider.future);
  return history
      .where((s) => s['status'] == 'graded' && s['total_score'] != null)
      .take(5)
      .toList();
}

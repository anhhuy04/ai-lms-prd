import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_dashboard_providers.g.dart';

/// Danh sách lớp của giáo viên hiện tại (dùng cho dashboard home).
/// Dùng getClassesByTeacherPaginated để có student_count trong từng Class.
@riverpod
Future<List<Class>> teacherDashboardClasses(Ref ref) async {
  final auth = ref.watch(authNotifierProvider);
  final teacherId = auth.value?.id;
  if (teacherId == null) return [];
  return ref.watch(schoolClassRepositoryProvider).getClassesByTeacherPaginated(
    teacherId: teacherId,
    page: 1,
    pageSize: 100, // Lấy tất cả, UI sẽ take(5) cho dashboard
  );
}

/// Tổng số bài nộp chờ chấm (submitted - graded) trên tất cả distributions.
@riverpod
Future<int> teacherPendingCount(Ref ref) async {
  final hub = ref.watch(teacherAssignmentHubNotifierProvider).valueOrNull;
  if (hub == null) return 0;
  int total = 0;
  for (final dist in hub.distributions) {
    final pending = (dist.submittedCount ?? 0) - (dist.gradedCount ?? 0);
    if (pending > 0) total += pending;
  }
  return total;
}

/// Đếm nhanh bài chờ chấm — không phụ thuộc vào hub nặng, chỉ 2 queries.
final teacherPendingCountFastProvider = FutureProvider.autoDispose<int>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  final teacherId = auth.value?.id;
  if (teacherId == null) return 0;
  return ref.watch(assignmentRepositoryProvider).getPendingSubmissionsCount(teacherId);
});

/// Số học sinh duy nhất (distinct student_id) trên tất cả lớp của giáo viên.
final teacherUniqueStudentCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final classes = ref.watch(teacherDashboardClassesProvider).valueOrNull;
  if (classes == null || classes.isEmpty) return 0;
  final classIds = classes.map((c) => c.id).toList();
  return ref.watch(schoolClassRepositoryProvider).getUniqueStudentCount(classIds);
});

/// Các phân công sắp hết hạn (dueAt trong tương lai), sắp xếp theo dueAt tăng dần.
/// Dùng dữ liệu đã tải sẵn từ hub — không gọi thêm DB.
@riverpod
Future<List<AssignmentDistribution>> teacherUpcomingDistributions(Ref ref) async {
  final hub = ref.watch(teacherAssignmentHubNotifierProvider).valueOrNull;
  if (hub == null) return [];
  final now = DateTime.now();
  final upcoming = hub.distributions
      .where((d) => d.dueAt != null && d.dueAt!.isAfter(now))
      .toList()
    ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
  return upcoming;
}

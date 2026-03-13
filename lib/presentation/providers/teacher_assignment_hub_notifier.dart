import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/assignment_statistics.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_assignment_hub_notifier.freezed.dart';
part 'teacher_assignment_hub_notifier.g.dart';

/// State class cho Teacher Assignment Hub
@freezed
class TeacherAssignmentHubState with _$TeacherAssignmentHubState {
  const factory TeacherAssignmentHubState({
    required AssignmentStatistics statistics,
    required List<Assignment> recentActivities,
    @Default([]) List<Assignment> assignments,
    @Default([]) List<AssignmentDistribution> distributions,
  }) = _TeacherAssignmentHubState;

  factory TeacherAssignmentHubState.fromJson(Map<String, dynamic> json) =>
      _$TeacherAssignmentHubStateFromJson(json);
}

/// Notifier cho Teacher Assignment Hub Screen
@riverpod
class TeacherAssignmentHubNotifier extends _$TeacherAssignmentHubNotifier {
  @override
  Future<TeacherAssignmentHubState> build() async {
    final auth = ref.watch(authNotifierProvider);
    final profile = auth.value;

    if (profile == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    return _loadData(profile.id);
  }

  /// Load tất cả data cho hub screen
  /// Load statistics và recent activities song song để tối ưu performance
  Future<TeacherAssignmentHubState> _loadData(String teacherId) async {
    try {
      final repository = ref.read(assignmentRepositoryProvider);

      // Load all data song song
      final results = await Future.wait([
        repository.getAssignmentStatistics(teacherId),
        repository.getRecentActivities(teacherId, limit: 10),
        repository.getAssignmentsByTeacher(teacherId),
        repository.getDistributionsByTeacher(teacherId),
      ]);

      return TeacherAssignmentHubState(
        statistics: results[0] as AssignmentStatistics,
        recentActivities: results[1] as List<Assignment>,
        assignments: results[2] as List<Assignment>,
        distributions: results[3] as List<AssignmentDistribution>,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [TEACHER_ASSIGNMENT_HUB] Error loading data: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(authNotifierProvider);
      final profile = auth.value;

      if (profile == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final newState = await _loadData(profile.id);
      state = AsyncValue.data(newState);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [TEACHER_ASSIGNMENT_HUB] Error refreshing: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

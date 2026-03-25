import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/app_logger.dart';
import '../../data/datasources/recommendation_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/recommendation/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import 'auth_providers.dart';

part 'recommendation_providers.g.dart';

/// DataSource provider for recommendations
@riverpod
RecommendationDatasource recommendationDatasource(Ref ref) {
  return RecommendationDatasource();
}

/// Repository provider for recommendations
@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final datasource = ref.watch(recommendationDatasourceProvider);
  return RecommendationRepositoryImpl(datasource: datasource);
}

/// Student recommendations provider
@riverpod
class StudentRecommendationNotifier extends _$StudentRecommendationNotifier {
  @override
  Future<List<Recommendation>> build({String? classId}) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];

    try {
      final repo = ref.watch(recommendationRepositoryProvider);
      return repo.getRecommendations(
        userId: userId,
        role: 'student',
        classId: classId,
        limit: 20,
      );
    } catch (e, st) {
      AppLogger.error(
        '[StudentRecommendationNotifier] Error loading recommendations',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> refresh({String? classId}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recommendationRepositoryProvider);
      return repo.getRecommendations(
        userId: userId,
        role: 'student',
        classId: classId,
        limit: 20,
      );
    });
  }

  Future<void> dismiss(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.dismissRecommendation(id);
      // Remove from local state
      state = state.whenData((list) {
        return list.where((r) => r.id != id).toList();
      });
    } catch (e, st) {
      AppLogger.error(
        '[StudentRecommendationNotifier] dismiss error',
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Teacher recommendations provider
@riverpod
class TeacherRecommendationNotifier extends _$TeacherRecommendationNotifier {
  @override
  Future<List<Recommendation>> build({String? classId}) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];

    try {
      final repo = ref.watch(recommendationRepositoryProvider);
      return repo.getRecommendations(
        userId: userId,
        role: 'teacher',
        classId: classId,
        limit: 20,
      );
    } catch (e, st) {
      AppLogger.error(
        '[TeacherRecommendationNotifier] Error loading recommendations',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> refresh({String? classId}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recommendationRepositoryProvider);
      return repo.getRecommendations(
        userId: userId,
        role: 'teacher',
        classId: classId,
        limit: 20,
      );
    });
  }

  Future<void> dismiss(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.dismissRecommendation(id);
      // Remove from local state
      state = state.whenData((list) {
        return list.where((r) => r.id != id).toList();
      });
    } catch (e, st) {
      AppLogger.error(
        '[TeacherRecommendationNotifier] dismiss error',
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Peer comparison provider for student analytics
@riverpod
Future<PeerComparison> peerComparison(
  Ref ref,
  String classId,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const PeerComparison();

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    return repo.getPeerComparison(userId, classId);
  } catch (e, st) {
    AppLogger.error(
      '[peerComparison] Error',
      error: e,
      stackTrace: st,
    );
    return const PeerComparison();
  }
}

/// Intervention count provider for teacher dashboard.
/// Counts high-priority recommendations (priority 1-2 = high).
@riverpod
Future<int> interventionCount(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    final recs = await repo.getRecommendations(
      userId: userId,
      role: 'teacher',
      limit: 50,
    );
    // Count recommendations with high priority (priorityValue 1 = high)
    return recs.where((r) => r.priorityValue <= 1).length;
  } catch (e, st) {
    AppLogger.error(
      '[interventionCount] Error',
      error: e,
      stackTrace: st,
    );
    return 0;
  }
}

/// Top-3 student recommendations provider (pillbox on home).
@riverpod
Future<List<Recommendation>> top3Recommendations(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    final recs = await repo.getRecommendations(
      userId: userId,
      role: 'student',
      limit: 3,
    );
    return recs;
  } catch (e, st) {
    AppLogger.error(
      '[top3Recommendations] Error',
      error: e,
      stackTrace: st,
    );
    return [];
  }
}

/// Dismiss recommendation provider (used by both teacher and student screens).
@riverpod
class DismissRecommendation extends _$DismissRecommendation {
  @override
  Future<bool> build({required String recommendationId}) async {
    return true;
  }

  Future<void> dismiss() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      final success = await repo.dismissRecommendation(recommendationId);
      state = AsyncData(success);
      if (success) {
        // Invalidate both teacher and student recommendation lists
        ref.invalidate(teacherRecommendationNotifierProvider());
        ref.invalidate(studentRecommendationNotifierProvider());
        ref.invalidate(interventionCountProvider);
        // Also invalidate top3RecommendationsProvider so home dashboard updates
        ref.invalidate(top3RecommendationsProvider);
      }
    } catch (e, st) {
      AppLogger.error(
        '[DismissRecommendation] dismiss error',
        error: e,
        stackTrace: st,
      );
      state = AsyncError(e, st);
    }
  }
}

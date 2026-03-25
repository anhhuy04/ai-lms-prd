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

  Future<void> markRead(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.markAsRead(id);
      // Update local state
      state = state.whenData((list) {
        return list.map((r) {
          if (r.id == id) {
            return Recommendation(
              id: r.id,
              userId: r.userId,
              role: r.role,
              type: r.type,
              priority: r.priority,
              title: r.title,
              description: r.description,
              actionLabel: r.actionLabel,
              actionPayload: r.actionPayload,
              isRead: true,
              isDismissed: r.isDismissed,
              createdAt: r.createdAt,
              expiresAt: r.expiresAt,
              metadata: r.metadata,
            );
          }
          return r;
        }).toList();
      });
      // Invalidate unread count
      ref.invalidate(studentUnreadRecommendationCountProvider);
    } catch (e, st) {
      AppLogger.error(
        '[StudentRecommendationNotifier] markRead error',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dismiss(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.dismissRecommendation(id);
      // Remove from local state
      state = state.whenData((list) {
        return list.where((r) => r.id != id).toList();
      });
      // Invalidate unread count
      ref.invalidate(studentUnreadRecommendationCountProvider);
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

  Future<void> markRead(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.markAsRead(id);
      state = state.whenData((list) {
        return list.map((r) {
          if (r.id == id) {
            return Recommendation(
              id: r.id,
              userId: r.userId,
              role: r.role,
              type: r.type,
              priority: r.priority,
              title: r.title,
              description: r.description,
              actionLabel: r.actionLabel,
              actionPayload: r.actionPayload,
              isRead: true,
              isDismissed: r.isDismissed,
              createdAt: r.createdAt,
              expiresAt: r.expiresAt,
              metadata: r.metadata,
            );
          }
          return r;
        }).toList();
      });
      ref.invalidate(teacherUnreadRecommendationCountProvider);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherRecommendationNotifier] markRead error',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dismiss(String id) async {
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      await repo.dismissRecommendation(id);
      state = state.whenData((list) {
        return list.where((r) => r.id != id).toList();
      });
      ref.invalidate(teacherUnreadRecommendationCountProvider);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherRecommendationNotifier] dismiss error',
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Unread student recommendation count
@riverpod
Future<int> studentUnreadRecommendationCount(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    return repo.getUnreadCount(userId);
  } catch (e, st) {
    AppLogger.error(
      '[studentUnreadRecommendationCount] Error',
      error: e,
      stackTrace: st,
    );
    return 0;
  }
}

/// Unread teacher recommendation count
@riverpod
Future<int> teacherUnreadRecommendationCount(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    return repo.getUnreadCount(userId);
  } catch (e, st) {
    AppLogger.error(
      '[teacherUnreadRecommendationCount] Error',
      error: e,
      stackTrace: st,
    );
    return 0;
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

/// Intervention count provider for teacher dashboard (priority <= 2).
/// Counts high-priority teacher recommendations.
@riverpod
Future<int> interventionCount(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  try {
    final repo = ref.watch(recommendationRepositoryProvider);
    final recs = await repo.getRecommendations(
      userId: userId,
      role: 'teacher',
      minPriority: RecommendationPriority.high,
      limit: 50,
    );
    // Count urgent (high priority = 1)
    return recs.where((r) => r.priority == RecommendationPriority.high).length;
  } catch (e, st) {
    AppLogger.error(
      '[interventionCount] Error',
      error: e,
      stackTrace: st,
    );
    return 0;
  }
}

/// Top-3 student recommendations provider (pillbox).
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
    // Sort by priority (high first) then createdAt
    recs.sort((a, b) {
      final priorityCompare = a.priorityValue.compareTo(b.priorityValue);
      if (priorityCompare != 0) return priorityCompare;
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return recs.take(3).toList();
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
      // Invalidate both teacher and student counts
      ref.invalidate(teacherUnreadRecommendationCountProvider);
      ref.invalidate(studentUnreadRecommendationCountProvider);
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/app_logger.dart';
import '../../data/datasources/analytics_datasource.dart';
import '../../domain/entities/analytics/student_analytics.dart';
import '../../domain/entities/analytics/skill_mastery.dart';
import '../../domain/entities/analytics/grade_trend.dart';
import '../../domain/entities/analytics/class_analytics.dart';
import '../../domain/entities/class.dart';
import '../views/grading/widgets/analytics/time_range_selector.dart';
import 'auth_providers.dart';
import 'class_providers.dart';

part 'analytics_providers.g.dart';

/// DataSource provider for analytics
@riverpod
AnalyticsDatasource analyticsDatasource(Ref ref) {
  return AnalyticsDatasource();
}

/// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
@riverpod
class StudentAnalyticsNotifier extends _$StudentAnalyticsNotifier {
  @override
  Future<StudentAnalytics> build({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) async {
    final studentId = ref.watch(currentUserIdProvider);

    if (studentId == null) {
      return const StudentAnalytics();
    }

    return _fetchAnalytics(studentId, classId, timeRange);
  }

  Future<StudentAnalytics> _fetchAnalytics(
    String studentId,
    String? classId,
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      final datasource = ref.watch(analyticsDatasourceProvider);

      // Calculate date range based on timeRange
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;
      if (timeRange is! AnalyticsTimeRangeAll) {
        if (timeRange is AnalyticsTimeRangeCustom) {
          startDate = timeRange.startDate;
          endDate = timeRange.endDate;
        } else {
          final days = _getDaysFromRange(timeRange);
          if (days != null) {
            endDate = now;
            startDate = now.subtract(Duration(days: days));
          }
        }
      }

      // Parallel fetch for performance
      final results = await Future.wait([
        datasource.getBasicMetrics(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
        datasource.getSkillMastery(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
        datasource.getGradeTrends(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      final basicMetrics = results[0] as BasicEngagementMetrics;
      final skillMasteries = results[1] as List<SkillMastery>;
      final gradeTrends = results[2] as List<GradeTrend>;

      // Calculate strengths/weaknesses
      final strong = skillMasteries.where((s) => s.isStrong).toList();
      final weak = skillMasteries.where((s) => s.isWeak).toList();

      return StudentAnalytics(
        basicMetrics: basicMetrics,
        skillMasteries: skillMasteries,
        gradeTrends: gradeTrends,
        strengthsWeaknesses: StrengthWeaknessAnalysis(
          strengths: strong,
          weaknesses: weak,
        ),
      );
    } catch (e, st) {
      AppLogger.error(
        '[StudentAnalytics] Error loading analytics',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  int? _getDaysFromRange(AnalyticsTimeRange range) {
    if (range is AnalyticsTimeRangeWeek) return 7;
    if (range is AnalyticsTimeRangeMonth) return 30;
    return null;
  }

  Future<void> refresh({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) async {
    final studentId = ref.read(currentUserIdProvider);
    if (studentId == null) {
      state = AsyncData(const StudentAnalytics());
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchAnalytics(studentId, classId, timeRange),
    );
  }
}

/// Skill Mastery Provider (ANL-04 - for radar chart)
@riverpod
Future<List<SkillMastery>> skillMastery(Ref ref) async {
  final studentId = ref.watch(currentUserIdProvider);

  if (studentId == null) return [];

  try {
    final datasource = ref.watch(analyticsDatasourceProvider);
    final result = await datasource.getSkillMastery(studentId);
    return result;
  } catch (e, st) {
    AppLogger.error('[SkillMastery] Error', error: e, stackTrace: st);
    rethrow;
  }
}

/// Grade Trends Provider (ANL-03 - for line chart)
@riverpod
Future<List<GradeTrend>> gradeTrends(Ref ref) async {
  final studentId = ref.watch(currentUserIdProvider);

  if (studentId == null) return [];

  try {
    final datasource = ref.watch(analyticsDatasourceProvider);
    final result = await datasource.getGradeTrends(studentId);
    return result;
  } catch (e, st) {
    AppLogger.error('[GradeTrends] Error', error: e, stackTrace: st);
    rethrow;
  }
}

/// Class Analytics Provider (ANL-02 - for teacher view)
@riverpod
Future<ClassAnalytics> classAnalytics(Ref ref, String classId) async {
  try {
    final datasource = ref.watch(analyticsDatasourceProvider);
    final result = await datasource.getClassAnalytics(classId);
    return result;
  } catch (e, st) {
    AppLogger.error('[ClassAnalytics] Error', error: e, stackTrace: st);
    rethrow;
  }
}

/// Class Comparison Provider - compares student to class average
@riverpod
Future<ClassComparison> studentClassComparison(Ref ref, String classId) async {
  final studentId = ref.watch(currentUserIdProvider);

  if (studentId == null) {
    return const ClassComparison();
  }

  try {
    final datasource = ref.watch(analyticsDatasourceProvider);
    final result = await datasource.getClassComparison(studentId, classId);
    return result;
  } catch (e, st) {
    AppLogger.error('[ClassComparison] Error', error: e, stackTrace: st);
    rethrow;
  }
}

/// Empty state detection for analytics
@riverpod
AnalyticsEmptyState analyticsEmptyState(
  Ref ref, {
  String? classId,
  AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
}) {
  final analytics = ref.watch(
    studentAnalyticsNotifierProvider(classId: classId, timeRange: timeRange),
  );

  return analytics.when(
    data: (data) {
      // Check if user has an active filter (non-default time range or specific class)
      final hasActiveFilter =
          timeRange is! AnalyticsTimeRangeAll || classId != null;

      // zeroSubmissions: no submissions at all (no filter applied)
      if (data.basicMetrics.submissionCount == 0 && !hasActiveFilter) {
        return AnalyticsEmptyState.zeroSubmissions;
      }

      // noDataInRange: filter active but no submissions in that range
      if (data.basicMetrics.submissionCount == 0 && hasActiveFilter) {
        return AnalyticsEmptyState.noDataInRange;
      }

      // normal: submissions AND skill data exist
      if (data.skillMasteries.isNotEmpty) {
        final hasGradedData = data.skillMasteries.any((s) => s.attempts > 0);
        if (hasGradedData) {
          return AnalyticsEmptyState.normal;
        }
        // submissions exist but no graded skill data yet
        return AnalyticsEmptyState.noSkillData;
      }
      // no skill masteries at all — pending grading (AI hasn't processed yet)
      return AnalyticsEmptyState.noSkillData;
    },
    loading: () => AnalyticsEmptyState.loading,
    error: (_, __) => AnalyticsEmptyState.error,
  );
}

/// Analytics empty state enum
enum AnalyticsEmptyState {
  zeroSubmissions,
  pendingGrading,
  noSkillData,
  noDataInRange,
  normal,
  loading,
  error,
}

/// Teacher viewing a specific student's analytics (override studentId).
@riverpod
class TeacherStudentAnalyticsNotifier
    extends _$TeacherStudentAnalyticsNotifier {
  @override
  Future<StudentAnalytics> build({
    required String studentId,
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) async {
    return _fetchAnalytics(studentId, classId, timeRange);
  }

  Future<StudentAnalytics> _fetchAnalytics(
    String studentId,
    String? classId,
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      final datasource = ref.watch(analyticsDatasourceProvider);

      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;
      if (timeRange is! AnalyticsTimeRangeAll) {
        if (timeRange is AnalyticsTimeRangeCustom) {
          startDate = timeRange.startDate;
          endDate = timeRange.endDate;
        } else {
          final days = _getDaysFromRange(timeRange);
          if (days != null) {
            endDate = now;
            startDate = now.subtract(Duration(days: days));
          }
        }
      }

      final results = await Future.wait([
        datasource.getBasicMetrics(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
        datasource.getSkillMastery(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
        datasource.getGradeTrends(
          studentId,
          classId: classId,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      final basicMetrics = results[0] as BasicEngagementMetrics;
      final skillMasteries = results[1] as List<SkillMastery>;
      final gradeTrends = results[2] as List<GradeTrend>;

      final strong = skillMasteries.where((s) => s.isStrong).toList();
      final weak = skillMasteries.where((s) => s.isWeak).toList();

      return StudentAnalytics(
        basicMetrics: basicMetrics,
        skillMasteries: skillMasteries,
        gradeTrends: gradeTrends,
        strengthsWeaknesses: StrengthWeaknessAnalysis(
          strengths: strong,
          weaknesses: weak,
        ),
      );
    } catch (e, st) {
      AppLogger.error(
        '[TeacherStudentAnalytics] Error loading analytics',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  int? _getDaysFromRange(AnalyticsTimeRange range) {
    if (range is AnalyticsTimeRangeWeek) return 7;
    if (range is AnalyticsTimeRangeMonth) return 30;
    return null;
  }

  Future<void> refresh({
    required String studentId,
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchAnalytics(studentId, classId, timeRange),
    );
  }
}

/// Provider lấy danh sách lớp của giáo viên hiện tại (dùng cho TeacherAnalyticsScreen)
@riverpod
Future<List<Class>> teacherClassesForAnalytics(Ref ref) async {
  final teacherId = ref.watch(currentUserIdProvider);
  if (teacherId == null) return [];

  final repo = ref.watch(schoolClassRepositoryProvider);
  return repo.getClassesByTeacher(teacherId);
}

/// Provider lấy danh sách lớp học sinh đã tham gia (dùng cho StudentAnalyticsScreen filter)
@riverpod
Future<List<Class>> studentClassesForAnalytics(Ref ref) async {
  final studentId = ref.watch(currentUserIdProvider);

  if (studentId == null) {
    return [];
  }

  try {
    final repo = ref.read(schoolClassRepositoryProvider);
    final result = await repo.getClassesByStudent(studentId);
    return result;
  } catch (e, st) {
    AppLogger.error(
      '[studentClassesForAnalytics] Error: $e',
      error: e,
      stackTrace: st,
    );
    return [];
  }
}

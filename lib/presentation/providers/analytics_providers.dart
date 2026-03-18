import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/analytics_datasource.dart';
import '../../domain/entities/analytics/student_analytics.dart';
import '../../domain/entities/analytics/skill_mastery.dart';
import '../../domain/entities/analytics/grade_trend.dart';
import '../../domain/entities/analytics/class_analytics.dart';
import 'auth_providers.dart';

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
  Future<StudentAnalytics> build() async {
    final studentId = ref.watch(currentUserIdProvider);
    if (studentId == null) {
      return const StudentAnalytics();
    }

    final datasource = ref.watch(analyticsDatasourceProvider);

    // Parallel fetch for performance
    final results = await Future.wait([
      datasource.getBasicMetrics(studentId),
      datasource.getSkillMastery(studentId),
      datasource.getGradeTrends(studentId),
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
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Skill Mastery Provider (ANL-04 - for radar chart)
@riverpod
Future<List<SkillMastery>> skillMastery(Ref ref) async {
  final studentId = ref.watch(currentUserIdProvider);
  if (studentId == null) return [];

  final datasource = ref.watch(analyticsDatasourceProvider);
  return datasource.getSkillMastery(studentId);
}

/// Grade Trends Provider (ANL-03 - for line chart)
@riverpod
Future<List<GradeTrend>> gradeTrends(Ref ref) async {
  final studentId = ref.watch(currentUserIdProvider);
  if (studentId == null) return [];

  final datasource = ref.watch(analyticsDatasourceProvider);
  return datasource.getGradeTrends(studentId);
}

/// Class Analytics Provider (ANL-02 - for teacher view)
@riverpod
Future<ClassAnalytics> classAnalytics(Ref ref, String classId) async {
  final datasource = ref.watch(analyticsDatasourceProvider);
  return datasource.getClassAnalytics(classId);
}

/// Class Comparison Provider - compares student to class average
@riverpod
Future<ClassComparison> studentClassComparison(Ref ref, String classId) async {
  final studentId = ref.watch(currentUserIdProvider);
  if (studentId == null) {
    return const ClassComparison();
  }

  final datasource = ref.watch(analyticsDatasourceProvider);
  return datasource.getClassComparison(studentId, classId);
}

/// Empty state detection for analytics
@riverpod
AnalyticsEmptyState analyticsEmptyState(Ref ref) {
  final analytics = ref.watch(studentAnalyticsNotifierProvider);

  return analytics.when(
    data: (data) {
      if (data.basicMetrics.submissionCount == 0) {
        return AnalyticsEmptyState.zeroSubmissions;
      }
      // Check for skill data
      if (data.skillMasteries.isEmpty ||
          data.skillMasteries.every((s) => s.attempts == 0)) {
        return AnalyticsEmptyState.noSkillData;
      }
      return AnalyticsEmptyState.normal;
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
  normal,
  loading,
  error,
}

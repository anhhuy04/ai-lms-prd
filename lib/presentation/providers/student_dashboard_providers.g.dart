// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentDueAssignmentsHash() =>
    r'96995982b1b7308264c72bba5c0e6c89cdd3b9e8';

/// Bài tập sắp hết hạn (chưa nộp hoặc đang làm), sắp xếp theo due_at tăng dần.
///
/// Copied from [studentDueAssignments].
@ProviderFor(studentDueAssignments)
final studentDueAssignmentsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      studentDueAssignments,
      name: r'studentDueAssignmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentDueAssignmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentDueAssignmentsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$studentDashboardStatsHash() =>
    r'fbe234e9934f8760bb08dd7fdb75041015ae05fd';

/// Thống kê số bài đã nộp và chờ chấm.
///
/// Copied from [studentDashboardStats].
@ProviderFor(studentDashboardStats)
final studentDashboardStatsProvider =
    AutoDisposeFutureProvider<({int submitted, int pendingGrading})>.internal(
      studentDashboardStats,
      name: r'studentDashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentDashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentDashboardStatsRef =
    AutoDisposeFutureProviderRef<({int submitted, int pendingGrading})>;
String _$studentDashboardProgressHash() =>
    r'd4ca636cffd81be5fa3f9eafc297291a8d9836b1';

/// Tiến độ hoàn thành bài tập trong tuần/tổng.
///
/// Copied from [studentDashboardProgress].
@ProviderFor(studentDashboardProgress)
final studentDashboardProgressProvider =
    AutoDisposeFutureProvider<({double progress, int remainingCount})>.internal(
      studentDashboardProgress,
      name: r'studentDashboardProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentDashboardProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentDashboardProgressRef =
    AutoDisposeFutureProviderRef<({double progress, int remainingCount})>;
String _$studentRecentScoresHash() =>
    r'0f27cf349c2485b57b644fbe5fb974c30cc9e0b6';

/// Danh sách điểm gần nhất (status = 'graded', có total_score).
///
/// Copied from [studentRecentScores].
@ProviderFor(studentRecentScores)
final studentRecentScoresProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      studentRecentScores,
      name: r'studentRecentScoresProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentRecentScoresHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentRecentScoresRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

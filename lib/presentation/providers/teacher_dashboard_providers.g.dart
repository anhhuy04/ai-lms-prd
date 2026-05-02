// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherDashboardClassesHash() =>
    r'2aa8921f8c32e05d1835fe59b881e0268cc31484';

/// Danh sách lớp của giáo viên hiện tại (dùng cho dashboard home).
/// Dùng getClassesByTeacherPaginated để có student_count trong từng Class.
///
/// Copied from [teacherDashboardClasses].
@ProviderFor(teacherDashboardClasses)
final teacherDashboardClassesProvider =
    AutoDisposeFutureProvider<List<Class>>.internal(
      teacherDashboardClasses,
      name: r'teacherDashboardClassesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherDashboardClassesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherDashboardClassesRef = AutoDisposeFutureProviderRef<List<Class>>;
String _$teacherPendingCountHash() =>
    r'47ab6aae12608acbbb5e94ed08a569500fd62610';

/// Tổng số bài nộp chờ chấm (submitted - graded) trên tất cả distributions.
///
/// Copied from [teacherPendingCount].
@ProviderFor(teacherPendingCount)
final teacherPendingCountProvider = AutoDisposeFutureProvider<int>.internal(
  teacherPendingCount,
  name: r'teacherPendingCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$teacherPendingCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherPendingCountRef = AutoDisposeFutureProviderRef<int>;
String _$teacherUpcomingDistributionsHash() =>
    r'29865eae57121b76da436b9ba239bad7c7bb420a';

/// Các phân công sắp hết hạn (dueAt trong tương lai), sắp xếp theo dueAt tăng dần.
/// Dùng dữ liệu đã tải sẵn từ hub — không gọi thêm DB.
///
/// Copied from [teacherUpcomingDistributions].
@ProviderFor(teacherUpcomingDistributions)
final teacherUpcomingDistributionsProvider =
    AutoDisposeFutureProvider<List<AssignmentDistribution>>.internal(
      teacherUpcomingDistributions,
      name: r'teacherUpcomingDistributionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherUpcomingDistributionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherUpcomingDistributionsRef =
    AutoDisposeFutureProviderRef<List<AssignmentDistribution>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

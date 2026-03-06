// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dashboard_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentDashboardNotifierHash() =>
    r'88e9f1b9fa9ccb79c6df95b15cf9ca774f90c9fd';

/// StudentDashboardNotifier (Riverpod) thay thế dần `StudentDashboardViewModel`.
///
/// Hiện tại dashboard của student phụ thuộc nhiều vào `AuthViewModel`.
/// Giai đoạn này migrate tối thiểu:
/// - Lấy được profile hiện tại từ AuthNotifier.
/// - Cung cấp hook `refresh()` để UI gọi (chuẩn bị cho migrate data sau).
///
/// Copied from [StudentDashboardNotifier].
@ProviderFor(StudentDashboardNotifier)
final studentDashboardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      StudentDashboardNotifier,
      Profile?
    >.internal(
      StudentDashboardNotifier.new,
      name: r'studentDashboardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentDashboardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StudentDashboardNotifier = AutoDisposeAsyncNotifier<Profile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_dashboard_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherDashboardNotifierHash() =>
    r'ea5e482e5faea500512fda74dce7126255c33247';

/// TeacherDashboardNotifier (Riverpod) thay thế dần `TeacherDashboardViewModel`.
///
/// Hiện tại dashboard của teacher phụ thuộc nhiều vào `AuthViewModel`.
/// Giai đoạn này migrate tối thiểu:
/// - Lấy được profile hiện tại từ AuthNotifier.
/// - Cung cấp hook `refresh()` để UI gọi (chuẩn bị cho migrate data sau).
///
/// Copied from [TeacherDashboardNotifier].
@ProviderFor(TeacherDashboardNotifier)
final teacherDashboardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      TeacherDashboardNotifier,
      Profile?
    >.internal(
      TeacherDashboardNotifier.new,
      name: r'teacherDashboardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherDashboardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeacherDashboardNotifier = AutoDisposeAsyncNotifier<Profile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

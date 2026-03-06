// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'1e83059625b9ebe23ad5d40af260911b9190d84f';

/// AuthNotifier (Riverpod) thay thế dần `AuthViewModel` (Provider/ChangeNotifier).
///
/// Quy ước state:
/// - `AsyncValue<Profile?>`:
///   - `data(null)`: chưa đăng nhập / chưa có session
///   - `data(Profile)`: đã đăng nhập
///   - `loading`: đang xử lý (login / check session / signout)
///   - `error`: có lỗi (message sẽ nằm trong `error.toString()`)
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, Profile?>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AsyncNotifier<Profile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

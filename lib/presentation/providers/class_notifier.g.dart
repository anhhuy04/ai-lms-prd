// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classNotifierHash() => r'df990349153db59dd8228dcc78f04772475a9d1e';

/// ClassNotifier (Riverpod) thay thế dần `ClassViewModel`.
///
/// Mục tiêu: tách logic khỏi UI, tối ưu theo Clean Architecture.
/// Lưu ý: ViewModel cũ vẫn còn để migrate UI từng bước.
///
/// Copied from [ClassNotifier].
@ProviderFor(ClassNotifier)
final classNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ClassNotifier, List<Class>>.internal(
      ClassNotifier.new,
      name: r'classNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$classNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClassNotifier = AutoDisposeAsyncNotifier<List<Class>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

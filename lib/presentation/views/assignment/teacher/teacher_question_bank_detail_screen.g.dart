// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_question_bank_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionDetailHash() => r'92627fdc51d05de734c4a08643c3769d4451d360';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [_questionDetail].
@ProviderFor(_questionDetail)
const _questionDetailProvider = _QuestionDetailFamily();

/// See also [_questionDetail].
class _QuestionDetailFamily extends Family<AsyncValue<QuestionDetail?>> {
  /// See also [_questionDetail].
  const _QuestionDetailFamily();

  /// See also [_questionDetail].
  _QuestionDetailProvider call(String id) {
    return _QuestionDetailProvider(id);
  }

  @override
  _QuestionDetailProvider getProviderOverride(
    covariant _QuestionDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_questionDetailProvider';
}

/// See also [_questionDetail].
class _QuestionDetailProvider
    extends AutoDisposeFutureProvider<QuestionDetail?> {
  /// See also [_questionDetail].
  _QuestionDetailProvider(String id)
    : this._internal(
        (ref) => _questionDetail(ref as _QuestionDetailRef, id),
        from: _questionDetailProvider,
        name: r'_questionDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$questionDetailHash,
        dependencies: _QuestionDetailFamily._dependencies,
        allTransitiveDependencies:
            _QuestionDetailFamily._allTransitiveDependencies,
        id: id,
      );

  _QuestionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<QuestionDetail?> Function(_QuestionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _QuestionDetailProvider._internal(
        (ref) => create(ref as _QuestionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<QuestionDetail?> createElement() {
    return _QuestionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _QuestionDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _QuestionDetailRef on AutoDisposeFutureProviderRef<QuestionDetail?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _QuestionDetailProviderElement
    extends AutoDisposeFutureProviderElement<QuestionDetail?>
    with _QuestionDetailRef {
  _QuestionDetailProviderElement(super.provider);

  @override
  String get id => (origin as _QuestionDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

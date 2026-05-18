// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionBankNotifierHash() =>
    r'a1bbfd186a227d1acaaca53ab73474cfb3b1f1d6';

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

abstract class _$QuestionBankNotifier
    extends BuildlessAutoDisposeAsyncNotifier<QuestionBankState> {
  late final QuestionFilter? filter;

  FutureOr<QuestionBankState> build({QuestionFilter? filter});
}

/// See also [QuestionBankNotifier].
@ProviderFor(QuestionBankNotifier)
const questionBankNotifierProvider = QuestionBankNotifierFamily();

/// See also [QuestionBankNotifier].
class QuestionBankNotifierFamily extends Family<AsyncValue<QuestionBankState>> {
  /// See also [QuestionBankNotifier].
  const QuestionBankNotifierFamily();

  /// See also [QuestionBankNotifier].
  QuestionBankNotifierProvider call({QuestionFilter? filter}) {
    return QuestionBankNotifierProvider(filter: filter);
  }

  @override
  QuestionBankNotifierProvider getProviderOverride(
    covariant QuestionBankNotifierProvider provider,
  ) {
    return call(filter: provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'questionBankNotifierProvider';
}

/// See also [QuestionBankNotifier].
class QuestionBankNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          QuestionBankNotifier,
          QuestionBankState
        > {
  /// See also [QuestionBankNotifier].
  QuestionBankNotifierProvider({QuestionFilter? filter})
    : this._internal(
        () => QuestionBankNotifier()..filter = filter,
        from: questionBankNotifierProvider,
        name: r'questionBankNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$questionBankNotifierHash,
        dependencies: QuestionBankNotifierFamily._dependencies,
        allTransitiveDependencies:
            QuestionBankNotifierFamily._allTransitiveDependencies,
        filter: filter,
      );

  QuestionBankNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final QuestionFilter? filter;

  @override
  FutureOr<QuestionBankState> runNotifierBuild(
    covariant QuestionBankNotifier notifier,
  ) {
    return notifier.build(filter: filter);
  }

  @override
  Override overrideWith(QuestionBankNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuestionBankNotifierProvider._internal(
        () => create()..filter = filter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    QuestionBankNotifier,
    QuestionBankState
  >
  createElement() {
    return _QuestionBankNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionBankNotifierProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuestionBankNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<QuestionBankState> {
  /// The parameter `filter` of this provider.
  QuestionFilter? get filter;
}

class _QuestionBankNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          QuestionBankNotifier,
          QuestionBankState
        >
    with QuestionBankNotifierRef {
  _QuestionBankNotifierProviderElement(super.provider);

  @override
  QuestionFilter? get filter => (origin as QuestionBankNotifierProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

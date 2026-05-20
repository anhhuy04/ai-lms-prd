// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_usage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionUsageHash() => r'7efe12e15e1489ae867f9e0e99686d617ef54a80';

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

/// Family provider — lấy danh sách assignments đang dùng question này.
///
/// Copied from [questionUsage].
@ProviderFor(questionUsage)
const questionUsageProvider = QuestionUsageFamily();

/// Family provider — lấy danh sách assignments đang dùng question này.
///
/// Copied from [questionUsage].
class QuestionUsageFamily extends Family<AsyncValue<List<QuestionUsageItem>>> {
  /// Family provider — lấy danh sách assignments đang dùng question này.
  ///
  /// Copied from [questionUsage].
  const QuestionUsageFamily();

  /// Family provider — lấy danh sách assignments đang dùng question này.
  ///
  /// Copied from [questionUsage].
  QuestionUsageProvider call(String questionId) {
    return QuestionUsageProvider(questionId);
  }

  @override
  QuestionUsageProvider getProviderOverride(
    covariant QuestionUsageProvider provider,
  ) {
    return call(provider.questionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'questionUsageProvider';
}

/// Family provider — lấy danh sách assignments đang dùng question này.
///
/// Copied from [questionUsage].
class QuestionUsageProvider
    extends AutoDisposeFutureProvider<List<QuestionUsageItem>> {
  /// Family provider — lấy danh sách assignments đang dùng question này.
  ///
  /// Copied from [questionUsage].
  QuestionUsageProvider(String questionId)
    : this._internal(
        (ref) => questionUsage(ref as QuestionUsageRef, questionId),
        from: questionUsageProvider,
        name: r'questionUsageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$questionUsageHash,
        dependencies: QuestionUsageFamily._dependencies,
        allTransitiveDependencies:
            QuestionUsageFamily._allTransitiveDependencies,
        questionId: questionId,
      );

  QuestionUsageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.questionId,
  }) : super.internal();

  final String questionId;

  @override
  Override overrideWith(
    FutureOr<List<QuestionUsageItem>> Function(QuestionUsageRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionUsageProvider._internal(
        (ref) => create(ref as QuestionUsageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        questionId: questionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuestionUsageItem>> createElement() {
    return _QuestionUsageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionUsageProvider && other.questionId == questionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, questionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuestionUsageRef
    on AutoDisposeFutureProviderRef<List<QuestionUsageItem>> {
  /// The parameter `questionId` of this provider.
  String get questionId;
}

class _QuestionUsageProviderElement
    extends AutoDisposeFutureProviderElement<List<QuestionUsageItem>>
    with QuestionUsageRef {
  _QuestionUsageProviderElement(super.provider);

  @override
  String get questionId => (origin as QuestionUsageProvider).questionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

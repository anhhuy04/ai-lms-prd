// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionStatsHash() => r'aa041bc2eaf74e574faa6b33deeccc5c8f7f0e52';

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

/// Family provider — fetch stats cho 1 question.
///
/// Copied from [questionStats].
@ProviderFor(questionStats)
const questionStatsProvider = QuestionStatsFamily();

/// Family provider — fetch stats cho 1 question.
///
/// Copied from [questionStats].
class QuestionStatsFamily extends Family<AsyncValue<QuestionStats>> {
  /// Family provider — fetch stats cho 1 question.
  ///
  /// Copied from [questionStats].
  const QuestionStatsFamily();

  /// Family provider — fetch stats cho 1 question.
  ///
  /// Copied from [questionStats].
  QuestionStatsProvider call(String questionId) {
    return QuestionStatsProvider(questionId);
  }

  @override
  QuestionStatsProvider getProviderOverride(
    covariant QuestionStatsProvider provider,
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
  String? get name => r'questionStatsProvider';
}

/// Family provider — fetch stats cho 1 question.
///
/// Copied from [questionStats].
class QuestionStatsProvider extends AutoDisposeFutureProvider<QuestionStats> {
  /// Family provider — fetch stats cho 1 question.
  ///
  /// Copied from [questionStats].
  QuestionStatsProvider(String questionId)
    : this._internal(
        (ref) => questionStats(ref as QuestionStatsRef, questionId),
        from: questionStatsProvider,
        name: r'questionStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$questionStatsHash,
        dependencies: QuestionStatsFamily._dependencies,
        allTransitiveDependencies:
            QuestionStatsFamily._allTransitiveDependencies,
        questionId: questionId,
      );

  QuestionStatsProvider._internal(
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
    FutureOr<QuestionStats> Function(QuestionStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionStatsProvider._internal(
        (ref) => create(ref as QuestionStatsRef),
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
  AutoDisposeFutureProviderElement<QuestionStats> createElement() {
    return _QuestionStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionStatsProvider && other.questionId == questionId;
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
mixin QuestionStatsRef on AutoDisposeFutureProviderRef<QuestionStats> {
  /// The parameter `questionId` of this provider.
  String get questionId;
}

class _QuestionStatsProviderElement
    extends AutoDisposeFutureProviderElement<QuestionStats>
    with QuestionStatsRef {
  _QuestionStatsProviderElement(super.provider);

  @override
  String get questionId => (origin as QuestionStatsProvider).questionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

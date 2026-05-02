// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_assignment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aggregatedScoresHash() => r'89c97bba55aceb9f1efa50011a3aaf7fc3571b9f';

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

/// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
/// Teacher-only — sẽ throw nếu không phải teacher của assignment.
/// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
///
/// Copied from [aggregatedScores].
@ProviderFor(aggregatedScores)
const aggregatedScoresProvider = AggregatedScoresFamily();

/// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
/// Teacher-only — sẽ throw nếu không phải teacher của assignment.
/// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
///
/// Copied from [aggregatedScores].
class AggregatedScoresFamily extends Family<AsyncValue<List<AggregatedScore>>> {
  /// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
  /// Teacher-only — sẽ throw nếu không phải teacher của assignment.
  /// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
  ///
  /// Copied from [aggregatedScores].
  const AggregatedScoresFamily();

  /// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
  /// Teacher-only — sẽ throw nếu không phải teacher của assignment.
  /// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
  ///
  /// Copied from [aggregatedScores].
  AggregatedScoresProvider call(String distributionId, {String? overrideRule}) {
    return AggregatedScoresProvider(distributionId, overrideRule: overrideRule);
  }

  @override
  AggregatedScoresProvider getProviderOverride(
    covariant AggregatedScoresProvider provider,
  ) {
    return call(provider.distributionId, overrideRule: provider.overrideRule);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'aggregatedScoresProvider';
}

/// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
/// Teacher-only — sẽ throw nếu không phải teacher của assignment.
/// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
///
/// Copied from [aggregatedScores].
class AggregatedScoresProvider
    extends AutoDisposeFutureProvider<List<AggregatedScore>> {
  /// Điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
  /// Teacher-only — sẽ throw nếu không phải teacher của assignment.
  /// Invalidate khi GV đổi score_aggregation_rule hoặc có submission mới.
  ///
  /// Copied from [aggregatedScores].
  AggregatedScoresProvider(String distributionId, {String? overrideRule})
    : this._internal(
        (ref) => aggregatedScores(
          ref as AggregatedScoresRef,
          distributionId,
          overrideRule: overrideRule,
        ),
        from: aggregatedScoresProvider,
        name: r'aggregatedScoresProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$aggregatedScoresHash,
        dependencies: AggregatedScoresFamily._dependencies,
        allTransitiveDependencies:
            AggregatedScoresFamily._allTransitiveDependencies,
        distributionId: distributionId,
        overrideRule: overrideRule,
      );

  AggregatedScoresProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
    required this.overrideRule,
  }) : super.internal();

  final String distributionId;
  final String? overrideRule;

  @override
  Override overrideWith(
    FutureOr<List<AggregatedScore>> Function(AggregatedScoresRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AggregatedScoresProvider._internal(
        (ref) => create(ref as AggregatedScoresRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
        overrideRule: overrideRule,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AggregatedScore>> createElement() {
    return _AggregatedScoresProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AggregatedScoresProvider &&
        other.distributionId == distributionId &&
        other.overrideRule == overrideRule;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);
    hash = _SystemHash.combine(hash, overrideRule.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AggregatedScoresRef
    on AutoDisposeFutureProviderRef<List<AggregatedScore>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;

  /// The parameter `overrideRule` of this provider.
  String? get overrideRule;
}

class _AggregatedScoresProviderElement
    extends AutoDisposeFutureProviderElement<List<AggregatedScore>>
    with AggregatedScoresRef {
  _AggregatedScoresProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as AggregatedScoresProvider).distributionId;
  @override
  String? get overrideRule => (origin as AggregatedScoresProvider).overrideRule;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

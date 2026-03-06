// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribute_assignment_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$distributeAssignmentNotifierHash() =>
    r'bf413b18ce3d7d5f02ce51f9580510ada8968c23';

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

abstract class _$DistributeAssignmentNotifier
    extends BuildlessAutoDisposeNotifier<DistributeAssignmentState> {
  late final String? assignmentId;

  DistributeAssignmentState build({String? assignmentId});
}

/// Notifier cho màn hình Phân phối bài tập
///
/// Copied from [DistributeAssignmentNotifier].
@ProviderFor(DistributeAssignmentNotifier)
const distributeAssignmentNotifierProvider =
    DistributeAssignmentNotifierFamily();

/// Notifier cho màn hình Phân phối bài tập
///
/// Copied from [DistributeAssignmentNotifier].
class DistributeAssignmentNotifierFamily
    extends Family<DistributeAssignmentState> {
  /// Notifier cho màn hình Phân phối bài tập
  ///
  /// Copied from [DistributeAssignmentNotifier].
  const DistributeAssignmentNotifierFamily();

  /// Notifier cho màn hình Phân phối bài tập
  ///
  /// Copied from [DistributeAssignmentNotifier].
  DistributeAssignmentNotifierProvider call({String? assignmentId}) {
    return DistributeAssignmentNotifierProvider(assignmentId: assignmentId);
  }

  @override
  DistributeAssignmentNotifierProvider getProviderOverride(
    covariant DistributeAssignmentNotifierProvider provider,
  ) {
    return call(assignmentId: provider.assignmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'distributeAssignmentNotifierProvider';
}

/// Notifier cho màn hình Phân phối bài tập
///
/// Copied from [DistributeAssignmentNotifier].
class DistributeAssignmentNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          DistributeAssignmentNotifier,
          DistributeAssignmentState
        > {
  /// Notifier cho màn hình Phân phối bài tập
  ///
  /// Copied from [DistributeAssignmentNotifier].
  DistributeAssignmentNotifierProvider({String? assignmentId})
    : this._internal(
        () => DistributeAssignmentNotifier()..assignmentId = assignmentId,
        from: distributeAssignmentNotifierProvider,
        name: r'distributeAssignmentNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$distributeAssignmentNotifierHash,
        dependencies: DistributeAssignmentNotifierFamily._dependencies,
        allTransitiveDependencies:
            DistributeAssignmentNotifierFamily._allTransitiveDependencies,
        assignmentId: assignmentId,
      );

  DistributeAssignmentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.assignmentId,
  }) : super.internal();

  final String? assignmentId;

  @override
  DistributeAssignmentState runNotifierBuild(
    covariant DistributeAssignmentNotifier notifier,
  ) {
    return notifier.build(assignmentId: assignmentId);
  }

  @override
  Override overrideWith(DistributeAssignmentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DistributeAssignmentNotifierProvider._internal(
        () => create()..assignmentId = assignmentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        assignmentId: assignmentId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    DistributeAssignmentNotifier,
    DistributeAssignmentState
  >
  createElement() {
    return _DistributeAssignmentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistributeAssignmentNotifierProvider &&
        other.assignmentId == assignmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, assignmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistributeAssignmentNotifierRef
    on AutoDisposeNotifierProviderRef<DistributeAssignmentState> {
  /// The parameter `assignmentId` of this provider.
  String? get assignmentId;
}

class _DistributeAssignmentNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          DistributeAssignmentNotifier,
          DistributeAssignmentState
        >
    with DistributeAssignmentNotifierRef {
  _DistributeAssignmentNotifierProviderElement(super.provider);

  @override
  String? get assignmentId =>
      (origin as DistributeAssignmentNotifierProvider).assignmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

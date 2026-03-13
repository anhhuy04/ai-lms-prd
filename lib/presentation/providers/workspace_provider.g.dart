// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workspaceNotifierHash() => r'd652c99bf42360630970f2fd8559cd0284be1223';

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

abstract class _$WorkspaceNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<WorkspaceState>> {
  late final String distributionId;

  AsyncValue<WorkspaceState> build(String distributionId);
}

/// State cho workspace
///
/// Copied from [WorkspaceNotifier].
@ProviderFor(WorkspaceNotifier)
const workspaceNotifierProvider = WorkspaceNotifierFamily();

/// State cho workspace
///
/// Copied from [WorkspaceNotifier].
class WorkspaceNotifierFamily extends Family<AsyncValue<WorkspaceState>> {
  /// State cho workspace
  ///
  /// Copied from [WorkspaceNotifier].
  const WorkspaceNotifierFamily();

  /// State cho workspace
  ///
  /// Copied from [WorkspaceNotifier].
  WorkspaceNotifierProvider call(String distributionId) {
    return WorkspaceNotifierProvider(distributionId);
  }

  @override
  WorkspaceNotifierProvider getProviderOverride(
    covariant WorkspaceNotifierProvider provider,
  ) {
    return call(provider.distributionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workspaceNotifierProvider';
}

/// State cho workspace
///
/// Copied from [WorkspaceNotifier].
class WorkspaceNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          WorkspaceNotifier,
          AsyncValue<WorkspaceState>
        > {
  /// State cho workspace
  ///
  /// Copied from [WorkspaceNotifier].
  WorkspaceNotifierProvider(String distributionId)
    : this._internal(
        () => WorkspaceNotifier()..distributionId = distributionId,
        from: workspaceNotifierProvider,
        name: r'workspaceNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workspaceNotifierHash,
        dependencies: WorkspaceNotifierFamily._dependencies,
        allTransitiveDependencies:
            WorkspaceNotifierFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  WorkspaceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
  }) : super.internal();

  final String distributionId;

  @override
  AsyncValue<WorkspaceState> runNotifierBuild(
    covariant WorkspaceNotifier notifier,
  ) {
    return notifier.build(distributionId);
  }

  @override
  Override overrideWith(WorkspaceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkspaceNotifierProvider._internal(
        () => create()..distributionId = distributionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    WorkspaceNotifier,
    AsyncValue<WorkspaceState>
  >
  createElement() {
    return _WorkspaceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkspaceNotifierProvider &&
        other.distributionId == distributionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkspaceNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<WorkspaceState>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _WorkspaceNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          WorkspaceNotifier,
          AsyncValue<WorkspaceState>
        >
    with WorkspaceNotifierRef {
  _WorkspaceNotifierProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as WorkspaceNotifierProvider).distributionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

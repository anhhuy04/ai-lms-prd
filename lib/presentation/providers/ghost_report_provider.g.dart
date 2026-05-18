// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ghost_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ghostReportHash() => r'a42a4499f9112d9a34470426cbb234a55e0744b7';

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

/// Family provider — emit GhostReport cho 1 assignment cụ thể.
/// Auto-dispose để không leak khi navigate away.
///
/// Copied from [ghostReport].
@ProviderFor(ghostReport)
const ghostReportProvider = GhostReportFamily();

/// Family provider — emit GhostReport cho 1 assignment cụ thể.
/// Auto-dispose để không leak khi navigate away.
///
/// Copied from [ghostReport].
class GhostReportFamily extends Family<AsyncValue<GhostReport>> {
  /// Family provider — emit GhostReport cho 1 assignment cụ thể.
  /// Auto-dispose để không leak khi navigate away.
  ///
  /// Copied from [ghostReport].
  const GhostReportFamily();

  /// Family provider — emit GhostReport cho 1 assignment cụ thể.
  /// Auto-dispose để không leak khi navigate away.
  ///
  /// Copied from [ghostReport].
  GhostReportProvider call(String assignmentId) {
    return GhostReportProvider(assignmentId);
  }

  @override
  GhostReportProvider getProviderOverride(
    covariant GhostReportProvider provider,
  ) {
    return call(provider.assignmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ghostReportProvider';
}

/// Family provider — emit GhostReport cho 1 assignment cụ thể.
/// Auto-dispose để không leak khi navigate away.
///
/// Copied from [ghostReport].
class GhostReportProvider extends AutoDisposeFutureProvider<GhostReport> {
  /// Family provider — emit GhostReport cho 1 assignment cụ thể.
  /// Auto-dispose để không leak khi navigate away.
  ///
  /// Copied from [ghostReport].
  GhostReportProvider(String assignmentId)
    : this._internal(
        (ref) => ghostReport(ref as GhostReportRef, assignmentId),
        from: ghostReportProvider,
        name: r'ghostReportProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ghostReportHash,
        dependencies: GhostReportFamily._dependencies,
        allTransitiveDependencies: GhostReportFamily._allTransitiveDependencies,
        assignmentId: assignmentId,
      );

  GhostReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.assignmentId,
  }) : super.internal();

  final String assignmentId;

  @override
  Override overrideWith(
    FutureOr<GhostReport> Function(GhostReportRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GhostReportProvider._internal(
        (ref) => create(ref as GhostReportRef),
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
  AutoDisposeFutureProviderElement<GhostReport> createElement() {
    return _GhostReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GhostReportProvider && other.assignmentId == assignmentId;
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
mixin GhostReportRef on AutoDisposeFutureProviderRef<GhostReport> {
  /// The parameter `assignmentId` of this provider.
  String get assignmentId;
}

class _GhostReportProviderElement
    extends AutoDisposeFutureProviderElement<GhostReport>
    with GhostReportRef {
  _GhostReportProviderElement(super.provider);

  @override
  String get assignmentId => (origin as GhostReportProvider).assignmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

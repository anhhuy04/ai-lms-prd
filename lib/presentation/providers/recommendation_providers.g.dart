// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendationDatasourceHash() =>
    r'654914a6c7d71eec30b38071904efc4c6bb1dedd';

/// DataSource provider for recommendations
///
/// Copied from [recommendationDatasource].
@ProviderFor(recommendationDatasource)
final recommendationDatasourceProvider =
    AutoDisposeProvider<RecommendationDatasource>.internal(
      recommendationDatasource,
      name: r'recommendationDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recommendationDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendationDatasourceRef =
    AutoDisposeProviderRef<RecommendationDatasource>;
String _$recommendationRepositoryHash() =>
    r'3c00c50900ecf2d239e85c24b4d5ccc465a04cd9';

/// Repository provider for recommendations
///
/// Copied from [recommendationRepository].
@ProviderFor(recommendationRepository)
final recommendationRepositoryProvider =
    AutoDisposeProvider<RecommendationRepository>.internal(
      recommendationRepository,
      name: r'recommendationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recommendationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendationRepositoryRef =
    AutoDisposeProviderRef<RecommendationRepository>;
String _$peerComparisonHash() => r'bfb700472ca5355ed02b49f4125ecc0d6285a9dc';

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

/// Peer comparison provider for student analytics
///
/// Copied from [peerComparison].
@ProviderFor(peerComparison)
const peerComparisonProvider = PeerComparisonFamily();

/// Peer comparison provider for student analytics
///
/// Copied from [peerComparison].
class PeerComparisonFamily extends Family<AsyncValue<PeerComparison>> {
  /// Peer comparison provider for student analytics
  ///
  /// Copied from [peerComparison].
  const PeerComparisonFamily();

  /// Peer comparison provider for student analytics
  ///
  /// Copied from [peerComparison].
  PeerComparisonProvider call(String classId) {
    return PeerComparisonProvider(classId);
  }

  @override
  PeerComparisonProvider getProviderOverride(
    covariant PeerComparisonProvider provider,
  ) {
    return call(provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'peerComparisonProvider';
}

/// Peer comparison provider for student analytics
///
/// Copied from [peerComparison].
class PeerComparisonProvider extends AutoDisposeFutureProvider<PeerComparison> {
  /// Peer comparison provider for student analytics
  ///
  /// Copied from [peerComparison].
  PeerComparisonProvider(String classId)
    : this._internal(
        (ref) => peerComparison(ref as PeerComparisonRef, classId),
        from: peerComparisonProvider,
        name: r'peerComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$peerComparisonHash,
        dependencies: PeerComparisonFamily._dependencies,
        allTransitiveDependencies:
            PeerComparisonFamily._allTransitiveDependencies,
        classId: classId,
      );

  PeerComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  Override overrideWith(
    FutureOr<PeerComparison> Function(PeerComparisonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeerComparisonProvider._internal(
        (ref) => create(ref as PeerComparisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PeerComparison> createElement() {
    return _PeerComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeerComparisonProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeerComparisonRef on AutoDisposeFutureProviderRef<PeerComparison> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _PeerComparisonProviderElement
    extends AutoDisposeFutureProviderElement<PeerComparison>
    with PeerComparisonRef {
  _PeerComparisonProviderElement(super.provider);

  @override
  String get classId => (origin as PeerComparisonProvider).classId;
}

String _$interventionCountHash() => r'570480eafae16d055b336f81c254041c2f91d362';

/// Intervention count provider for teacher dashboard.
/// Counts high-priority recommendations (priority 1-2 = high).
///
/// Copied from [interventionCount].
@ProviderFor(interventionCount)
final interventionCountProvider = AutoDisposeFutureProvider<int>.internal(
  interventionCount,
  name: r'interventionCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$interventionCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InterventionCountRef = AutoDisposeFutureProviderRef<int>;
String _$top3RecommendationsHash() =>
    r'c99cf382b194651637ff718623c3422b379b1a1a';

/// Top-3 student recommendations provider (pillbox on home).
///
/// Copied from [top3Recommendations].
@ProviderFor(top3Recommendations)
final top3RecommendationsProvider =
    AutoDisposeFutureProvider<List<Recommendation>>.internal(
      top3Recommendations,
      name: r'top3RecommendationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$top3RecommendationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef Top3RecommendationsRef =
    AutoDisposeFutureProviderRef<List<Recommendation>>;
String _$studentRecommendationNotifierHash() =>
    r'30eb25daf8a77bdf80ddeda60a9adf16b95bdc1d';

abstract class _$StudentRecommendationNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Recommendation>> {
  late final String? classId;

  FutureOr<List<Recommendation>> build({String? classId});
}

/// Student recommendations provider
///
/// Copied from [StudentRecommendationNotifier].
@ProviderFor(StudentRecommendationNotifier)
const studentRecommendationNotifierProvider =
    StudentRecommendationNotifierFamily();

/// Student recommendations provider
///
/// Copied from [StudentRecommendationNotifier].
class StudentRecommendationNotifierFamily
    extends Family<AsyncValue<List<Recommendation>>> {
  /// Student recommendations provider
  ///
  /// Copied from [StudentRecommendationNotifier].
  const StudentRecommendationNotifierFamily();

  /// Student recommendations provider
  ///
  /// Copied from [StudentRecommendationNotifier].
  StudentRecommendationNotifierProvider call({String? classId}) {
    return StudentRecommendationNotifierProvider(classId: classId);
  }

  @override
  StudentRecommendationNotifierProvider getProviderOverride(
    covariant StudentRecommendationNotifierProvider provider,
  ) {
    return call(classId: provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentRecommendationNotifierProvider';
}

/// Student recommendations provider
///
/// Copied from [StudentRecommendationNotifier].
class StudentRecommendationNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StudentRecommendationNotifier,
          List<Recommendation>
        > {
  /// Student recommendations provider
  ///
  /// Copied from [StudentRecommendationNotifier].
  StudentRecommendationNotifierProvider({String? classId})
    : this._internal(
        () => StudentRecommendationNotifier()..classId = classId,
        from: studentRecommendationNotifierProvider,
        name: r'studentRecommendationNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentRecommendationNotifierHash,
        dependencies: StudentRecommendationNotifierFamily._dependencies,
        allTransitiveDependencies:
            StudentRecommendationNotifierFamily._allTransitiveDependencies,
        classId: classId,
      );

  StudentRecommendationNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String? classId;

  @override
  FutureOr<List<Recommendation>> runNotifierBuild(
    covariant StudentRecommendationNotifier notifier,
  ) {
    return notifier.build(classId: classId);
  }

  @override
  Override overrideWith(StudentRecommendationNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudentRecommendationNotifierProvider._internal(
        () => create()..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StudentRecommendationNotifier,
    List<Recommendation>
  >
  createElement() {
    return _StudentRecommendationNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentRecommendationNotifierProvider &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentRecommendationNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Recommendation>> {
  /// The parameter `classId` of this provider.
  String? get classId;
}

class _StudentRecommendationNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StudentRecommendationNotifier,
          List<Recommendation>
        >
    with StudentRecommendationNotifierRef {
  _StudentRecommendationNotifierProviderElement(super.provider);

  @override
  String? get classId =>
      (origin as StudentRecommendationNotifierProvider).classId;
}

String _$teacherRecommendationNotifierHash() =>
    r'9c9452db3ef827151249518c60715855ec24adc7';

abstract class _$TeacherRecommendationNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Recommendation>> {
  late final String? classId;

  FutureOr<List<Recommendation>> build({String? classId});
}

/// Teacher recommendations provider
///
/// Copied from [TeacherRecommendationNotifier].
@ProviderFor(TeacherRecommendationNotifier)
const teacherRecommendationNotifierProvider =
    TeacherRecommendationNotifierFamily();

/// Teacher recommendations provider
///
/// Copied from [TeacherRecommendationNotifier].
class TeacherRecommendationNotifierFamily
    extends Family<AsyncValue<List<Recommendation>>> {
  /// Teacher recommendations provider
  ///
  /// Copied from [TeacherRecommendationNotifier].
  const TeacherRecommendationNotifierFamily();

  /// Teacher recommendations provider
  ///
  /// Copied from [TeacherRecommendationNotifier].
  TeacherRecommendationNotifierProvider call({String? classId}) {
    return TeacherRecommendationNotifierProvider(classId: classId);
  }

  @override
  TeacherRecommendationNotifierProvider getProviderOverride(
    covariant TeacherRecommendationNotifierProvider provider,
  ) {
    return call(classId: provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teacherRecommendationNotifierProvider';
}

/// Teacher recommendations provider
///
/// Copied from [TeacherRecommendationNotifier].
class TeacherRecommendationNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TeacherRecommendationNotifier,
          List<Recommendation>
        > {
  /// Teacher recommendations provider
  ///
  /// Copied from [TeacherRecommendationNotifier].
  TeacherRecommendationNotifierProvider({String? classId})
    : this._internal(
        () => TeacherRecommendationNotifier()..classId = classId,
        from: teacherRecommendationNotifierProvider,
        name: r'teacherRecommendationNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherRecommendationNotifierHash,
        dependencies: TeacherRecommendationNotifierFamily._dependencies,
        allTransitiveDependencies:
            TeacherRecommendationNotifierFamily._allTransitiveDependencies,
        classId: classId,
      );

  TeacherRecommendationNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String? classId;

  @override
  FutureOr<List<Recommendation>> runNotifierBuild(
    covariant TeacherRecommendationNotifier notifier,
  ) {
    return notifier.build(classId: classId);
  }

  @override
  Override overrideWith(TeacherRecommendationNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeacherRecommendationNotifierProvider._internal(
        () => create()..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TeacherRecommendationNotifier,
    List<Recommendation>
  >
  createElement() {
    return _TeacherRecommendationNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherRecommendationNotifierProvider &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherRecommendationNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Recommendation>> {
  /// The parameter `classId` of this provider.
  String? get classId;
}

class _TeacherRecommendationNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TeacherRecommendationNotifier,
          List<Recommendation>
        >
    with TeacherRecommendationNotifierRef {
  _TeacherRecommendationNotifierProviderElement(super.provider);

  @override
  String? get classId =>
      (origin as TeacherRecommendationNotifierProvider).classId;
}

String _$dismissRecommendationHash() =>
    r'55f67d8a2f13673b5b02664fe32e9b370685c24b';

abstract class _$DismissRecommendation
    extends BuildlessAutoDisposeAsyncNotifier<bool> {
  late final String recommendationId;

  FutureOr<bool> build({required String recommendationId});
}

/// Dismiss recommendation provider (used by both teacher and student screens).
///
/// Copied from [DismissRecommendation].
@ProviderFor(DismissRecommendation)
const dismissRecommendationProvider = DismissRecommendationFamily();

/// Dismiss recommendation provider (used by both teacher and student screens).
///
/// Copied from [DismissRecommendation].
class DismissRecommendationFamily extends Family<AsyncValue<bool>> {
  /// Dismiss recommendation provider (used by both teacher and student screens).
  ///
  /// Copied from [DismissRecommendation].
  const DismissRecommendationFamily();

  /// Dismiss recommendation provider (used by both teacher and student screens).
  ///
  /// Copied from [DismissRecommendation].
  DismissRecommendationProvider call({required String recommendationId}) {
    return DismissRecommendationProvider(recommendationId: recommendationId);
  }

  @override
  DismissRecommendationProvider getProviderOverride(
    covariant DismissRecommendationProvider provider,
  ) {
    return call(recommendationId: provider.recommendationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dismissRecommendationProvider';
}

/// Dismiss recommendation provider (used by both teacher and student screens).
///
/// Copied from [DismissRecommendation].
class DismissRecommendationProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DismissRecommendation, bool> {
  /// Dismiss recommendation provider (used by both teacher and student screens).
  ///
  /// Copied from [DismissRecommendation].
  DismissRecommendationProvider({required String recommendationId})
    : this._internal(
        () => DismissRecommendation()..recommendationId = recommendationId,
        from: dismissRecommendationProvider,
        name: r'dismissRecommendationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dismissRecommendationHash,
        dependencies: DismissRecommendationFamily._dependencies,
        allTransitiveDependencies:
            DismissRecommendationFamily._allTransitiveDependencies,
        recommendationId: recommendationId,
      );

  DismissRecommendationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.recommendationId,
  }) : super.internal();

  final String recommendationId;

  @override
  FutureOr<bool> runNotifierBuild(covariant DismissRecommendation notifier) {
    return notifier.build(recommendationId: recommendationId);
  }

  @override
  Override overrideWith(DismissRecommendation Function() create) {
    return ProviderOverride(
      origin: this,
      override: DismissRecommendationProvider._internal(
        () => create()..recommendationId = recommendationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        recommendationId: recommendationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DismissRecommendation, bool>
  createElement() {
    return _DismissRecommendationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DismissRecommendationProvider &&
        other.recommendationId == recommendationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, recommendationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DismissRecommendationRef on AutoDisposeAsyncNotifierProviderRef<bool> {
  /// The parameter `recommendationId` of this provider.
  String get recommendationId;
}

class _DismissRecommendationProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DismissRecommendation, bool>
    with DismissRecommendationRef {
  _DismissRecommendationProviderElement(super.provider);

  @override
  String get recommendationId =>
      (origin as DismissRecommendationProvider).recommendationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

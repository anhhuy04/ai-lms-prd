// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsDatasourceHash() =>
    r'09278ca2f93a8463578abbe880db3eb4e268f47a';

/// DataSource provider for analytics
///
/// Copied from [analyticsDatasource].
@ProviderFor(analyticsDatasource)
final analyticsDatasourceProvider =
    AutoDisposeProvider<AnalyticsDatasource>.internal(
      analyticsDatasource,
      name: r'analyticsDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsDatasourceRef = AutoDisposeProviderRef<AnalyticsDatasource>;
String _$skillMasteryHash() => r'989be9834842868bab99d5c7afa100d6ba09b787';

/// Skill Mastery Provider (ANL-04 - for radar chart)
///
/// Copied from [skillMastery].
@ProviderFor(skillMastery)
final skillMasteryProvider =
    AutoDisposeFutureProvider<List<SkillMastery>>.internal(
      skillMastery,
      name: r'skillMasteryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$skillMasteryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SkillMasteryRef = AutoDisposeFutureProviderRef<List<SkillMastery>>;
String _$gradeTrendsHash() => r'9a659a95d283229f09e557722b21a006516ead9e';

/// Grade Trends Provider (ANL-03 - for line chart)
///
/// Copied from [gradeTrends].
@ProviderFor(gradeTrends)
final gradeTrendsProvider =
    AutoDisposeFutureProvider<List<GradeTrend>>.internal(
      gradeTrends,
      name: r'gradeTrendsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gradeTrendsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GradeTrendsRef = AutoDisposeFutureProviderRef<List<GradeTrend>>;
String _$classAnalyticsHash() => r'104b8d356e9303ba0c1fcba8807159753a72805d';

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

/// Class Analytics Provider (ANL-02 - for teacher view)
///
/// Copied from [classAnalytics].
@ProviderFor(classAnalytics)
const classAnalyticsProvider = ClassAnalyticsFamily();

/// Class Analytics Provider (ANL-02 - for teacher view)
///
/// Copied from [classAnalytics].
class ClassAnalyticsFamily extends Family<AsyncValue<ClassAnalytics>> {
  /// Class Analytics Provider (ANL-02 - for teacher view)
  ///
  /// Copied from [classAnalytics].
  const ClassAnalyticsFamily();

  /// Class Analytics Provider (ANL-02 - for teacher view)
  ///
  /// Copied from [classAnalytics].
  ClassAnalyticsProvider call(String classId) {
    return ClassAnalyticsProvider(classId);
  }

  @override
  ClassAnalyticsProvider getProviderOverride(
    covariant ClassAnalyticsProvider provider,
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
  String? get name => r'classAnalyticsProvider';
}

/// Class Analytics Provider (ANL-02 - for teacher view)
///
/// Copied from [classAnalytics].
class ClassAnalyticsProvider extends AutoDisposeFutureProvider<ClassAnalytics> {
  /// Class Analytics Provider (ANL-02 - for teacher view)
  ///
  /// Copied from [classAnalytics].
  ClassAnalyticsProvider(String classId)
    : this._internal(
        (ref) => classAnalytics(ref as ClassAnalyticsRef, classId),
        from: classAnalyticsProvider,
        name: r'classAnalyticsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$classAnalyticsHash,
        dependencies: ClassAnalyticsFamily._dependencies,
        allTransitiveDependencies:
            ClassAnalyticsFamily._allTransitiveDependencies,
        classId: classId,
      );

  ClassAnalyticsProvider._internal(
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
    FutureOr<ClassAnalytics> Function(ClassAnalyticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassAnalyticsProvider._internal(
        (ref) => create(ref as ClassAnalyticsRef),
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
  AutoDisposeFutureProviderElement<ClassAnalytics> createElement() {
    return _ClassAnalyticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassAnalyticsProvider && other.classId == classId;
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
mixin ClassAnalyticsRef on AutoDisposeFutureProviderRef<ClassAnalytics> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassAnalyticsProviderElement
    extends AutoDisposeFutureProviderElement<ClassAnalytics>
    with ClassAnalyticsRef {
  _ClassAnalyticsProviderElement(super.provider);

  @override
  String get classId => (origin as ClassAnalyticsProvider).classId;
}

String _$studentClassComparisonHash() =>
    r'8a3999b93603e647e93f33f8111b84add496c4b4';

/// Class Comparison Provider - compares student to class average
///
/// Copied from [studentClassComparison].
@ProviderFor(studentClassComparison)
const studentClassComparisonProvider = StudentClassComparisonFamily();

/// Class Comparison Provider - compares student to class average
///
/// Copied from [studentClassComparison].
class StudentClassComparisonFamily extends Family<AsyncValue<ClassComparison>> {
  /// Class Comparison Provider - compares student to class average
  ///
  /// Copied from [studentClassComparison].
  const StudentClassComparisonFamily();

  /// Class Comparison Provider - compares student to class average
  ///
  /// Copied from [studentClassComparison].
  StudentClassComparisonProvider call(String classId) {
    return StudentClassComparisonProvider(classId);
  }

  @override
  StudentClassComparisonProvider getProviderOverride(
    covariant StudentClassComparisonProvider provider,
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
  String? get name => r'studentClassComparisonProvider';
}

/// Class Comparison Provider - compares student to class average
///
/// Copied from [studentClassComparison].
class StudentClassComparisonProvider
    extends AutoDisposeFutureProvider<ClassComparison> {
  /// Class Comparison Provider - compares student to class average
  ///
  /// Copied from [studentClassComparison].
  StudentClassComparisonProvider(String classId)
    : this._internal(
        (ref) =>
            studentClassComparison(ref as StudentClassComparisonRef, classId),
        from: studentClassComparisonProvider,
        name: r'studentClassComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentClassComparisonHash,
        dependencies: StudentClassComparisonFamily._dependencies,
        allTransitiveDependencies:
            StudentClassComparisonFamily._allTransitiveDependencies,
        classId: classId,
      );

  StudentClassComparisonProvider._internal(
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
    FutureOr<ClassComparison> Function(StudentClassComparisonRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentClassComparisonProvider._internal(
        (ref) => create(ref as StudentClassComparisonRef),
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
  AutoDisposeFutureProviderElement<ClassComparison> createElement() {
    return _StudentClassComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentClassComparisonProvider && other.classId == classId;
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
mixin StudentClassComparisonRef
    on AutoDisposeFutureProviderRef<ClassComparison> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _StudentClassComparisonProviderElement
    extends AutoDisposeFutureProviderElement<ClassComparison>
    with StudentClassComparisonRef {
  _StudentClassComparisonProviderElement(super.provider);

  @override
  String get classId => (origin as StudentClassComparisonProvider).classId;
}

String _$analyticsEmptyStateHash() =>
    r'03c920b7f6bce53a7b11f71e6a88b33748302fe0';

/// Empty state detection for analytics
///
/// Copied from [analyticsEmptyState].
@ProviderFor(analyticsEmptyState)
final analyticsEmptyStateProvider =
    AutoDisposeProvider<AnalyticsEmptyState>.internal(
      analyticsEmptyState,
      name: r'analyticsEmptyStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsEmptyStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsEmptyStateRef = AutoDisposeProviderRef<AnalyticsEmptyState>;
String _$studentAnalyticsNotifierHash() =>
    r'd3c8125a729b55c15fbf99fac1f258dc4d3956e4';

/// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
///
/// Copied from [StudentAnalyticsNotifier].
@ProviderFor(StudentAnalyticsNotifier)
final studentAnalyticsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      StudentAnalyticsNotifier,
      StudentAnalytics
    >.internal(
      StudentAnalyticsNotifier.new,
      name: r'studentAnalyticsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentAnalyticsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StudentAnalyticsNotifier = AutoDisposeAsyncNotifier<StudentAnalytics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

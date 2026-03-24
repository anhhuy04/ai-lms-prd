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
String _$skillMasteryHash() => r'8076d4ffebbd37469e39256a394449c0522dd28e';

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
String _$gradeTrendsHash() => r'057d0651d0d1a59980bdea9f9349f5f0802e530a';

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
String _$classAnalyticsHash() => r'40f38c2f0a23074c9d24aa6a8b5264d81b849e80';

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
    r'f9130a36c0d11e316c8840ffc0d6fe698cbaa9fe';

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
    r'884ba5c1d1f22e90a4a14a9af7ddbb18c5da11cf';

/// Empty state detection for analytics
///
/// Copied from [analyticsEmptyState].
@ProviderFor(analyticsEmptyState)
const analyticsEmptyStateProvider = AnalyticsEmptyStateFamily();

/// Empty state detection for analytics
///
/// Copied from [analyticsEmptyState].
class AnalyticsEmptyStateFamily extends Family<AnalyticsEmptyState> {
  /// Empty state detection for analytics
  ///
  /// Copied from [analyticsEmptyState].
  const AnalyticsEmptyStateFamily();

  /// Empty state detection for analytics
  ///
  /// Copied from [analyticsEmptyState].
  AnalyticsEmptyStateProvider call({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) {
    return AnalyticsEmptyStateProvider(classId: classId, timeRange: timeRange);
  }

  @override
  AnalyticsEmptyStateProvider getProviderOverride(
    covariant AnalyticsEmptyStateProvider provider,
  ) {
    return call(classId: provider.classId, timeRange: provider.timeRange);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'analyticsEmptyStateProvider';
}

/// Empty state detection for analytics
///
/// Copied from [analyticsEmptyState].
class AnalyticsEmptyStateProvider
    extends AutoDisposeProvider<AnalyticsEmptyState> {
  /// Empty state detection for analytics
  ///
  /// Copied from [analyticsEmptyState].
  AnalyticsEmptyStateProvider({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) : this._internal(
         (ref) => analyticsEmptyState(
           ref as AnalyticsEmptyStateRef,
           classId: classId,
           timeRange: timeRange,
         ),
         from: analyticsEmptyStateProvider,
         name: r'analyticsEmptyStateProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$analyticsEmptyStateHash,
         dependencies: AnalyticsEmptyStateFamily._dependencies,
         allTransitiveDependencies:
             AnalyticsEmptyStateFamily._allTransitiveDependencies,
         classId: classId,
         timeRange: timeRange,
       );

  AnalyticsEmptyStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.timeRange,
  }) : super.internal();

  final String? classId;
  final AnalyticsTimeRange timeRange;

  @override
  Override overrideWith(
    AnalyticsEmptyState Function(AnalyticsEmptyStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnalyticsEmptyStateProvider._internal(
        (ref) => create(ref as AnalyticsEmptyStateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        timeRange: timeRange,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AnalyticsEmptyState> createElement() {
    return _AnalyticsEmptyStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticsEmptyStateProvider &&
        other.classId == classId &&
        other.timeRange == timeRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, timeRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnalyticsEmptyStateRef on AutoDisposeProviderRef<AnalyticsEmptyState> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `timeRange` of this provider.
  AnalyticsTimeRange get timeRange;
}

class _AnalyticsEmptyStateProviderElement
    extends AutoDisposeProviderElement<AnalyticsEmptyState>
    with AnalyticsEmptyStateRef {
  _AnalyticsEmptyStateProviderElement(super.provider);

  @override
  String? get classId => (origin as AnalyticsEmptyStateProvider).classId;
  @override
  AnalyticsTimeRange get timeRange =>
      (origin as AnalyticsEmptyStateProvider).timeRange;
}

String _$teacherClassesForAnalyticsHash() =>
    r'e2931c4f8e10a954d2f8dc40e50c298c26465a29';

/// Provider lấy danh sách lớp của giáo viên hiện tại (dùng cho TeacherAnalyticsScreen)
///
/// Copied from [teacherClassesForAnalytics].
@ProviderFor(teacherClassesForAnalytics)
final teacherClassesForAnalyticsProvider =
    AutoDisposeFutureProvider<List<Class>>.internal(
      teacherClassesForAnalytics,
      name: r'teacherClassesForAnalyticsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherClassesForAnalyticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherClassesForAnalyticsRef =
    AutoDisposeFutureProviderRef<List<Class>>;
String _$studentClassesForAnalyticsHash() =>
    r'aa2848d88e81ad3e840f7ef36a6a4c1b644ebce9';

/// Provider lấy danh sách lớp học sinh đã tham gia (dùng cho StudentAnalyticsScreen filter)
///
/// Copied from [studentClassesForAnalytics].
@ProviderFor(studentClassesForAnalytics)
final studentClassesForAnalyticsProvider =
    AutoDisposeFutureProvider<List<Class>>.internal(
      studentClassesForAnalytics,
      name: r'studentClassesForAnalyticsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentClassesForAnalyticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentClassesForAnalyticsRef =
    AutoDisposeFutureProviderRef<List<Class>>;
String _$studentAnalyticsNotifierHash() =>
    r'e8d69719f5c6491f5851545c94ad9730c14dc796';

abstract class _$StudentAnalyticsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<StudentAnalytics> {
  late final String? classId;
  late final AnalyticsTimeRange timeRange;

  FutureOr<StudentAnalytics> build({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  });
}

/// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
///
/// Copied from [StudentAnalyticsNotifier].
@ProviderFor(StudentAnalyticsNotifier)
const studentAnalyticsNotifierProvider = StudentAnalyticsNotifierFamily();

/// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
///
/// Copied from [StudentAnalyticsNotifier].
class StudentAnalyticsNotifierFamily
    extends Family<AsyncValue<StudentAnalytics>> {
  /// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
  ///
  /// Copied from [StudentAnalyticsNotifier].
  const StudentAnalyticsNotifierFamily();

  /// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
  ///
  /// Copied from [StudentAnalyticsNotifier].
  StudentAnalyticsNotifierProvider call({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) {
    return StudentAnalyticsNotifierProvider(
      classId: classId,
      timeRange: timeRange,
    );
  }

  @override
  StudentAnalyticsNotifierProvider getProviderOverride(
    covariant StudentAnalyticsNotifierProvider provider,
  ) {
    return call(classId: provider.classId, timeRange: provider.timeRange);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentAnalyticsNotifierProvider';
}

/// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
///
/// Copied from [StudentAnalyticsNotifier].
class StudentAnalyticsNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StudentAnalyticsNotifier,
          StudentAnalytics
        > {
  /// Student Analytics Provider (ANL-01, ANL-03, ANL-04)
  ///
  /// Copied from [StudentAnalyticsNotifier].
  StudentAnalyticsNotifierProvider({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) : this._internal(
         () => StudentAnalyticsNotifier()
           ..classId = classId
           ..timeRange = timeRange,
         from: studentAnalyticsNotifierProvider,
         name: r'studentAnalyticsNotifierProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$studentAnalyticsNotifierHash,
         dependencies: StudentAnalyticsNotifierFamily._dependencies,
         allTransitiveDependencies:
             StudentAnalyticsNotifierFamily._allTransitiveDependencies,
         classId: classId,
         timeRange: timeRange,
       );

  StudentAnalyticsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.timeRange,
  }) : super.internal();

  final String? classId;
  final AnalyticsTimeRange timeRange;

  @override
  FutureOr<StudentAnalytics> runNotifierBuild(
    covariant StudentAnalyticsNotifier notifier,
  ) {
    return notifier.build(classId: classId, timeRange: timeRange);
  }

  @override
  Override overrideWith(StudentAnalyticsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudentAnalyticsNotifierProvider._internal(
        () => create()
          ..classId = classId
          ..timeRange = timeRange,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        timeRange: timeRange,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StudentAnalyticsNotifier,
    StudentAnalytics
  >
  createElement() {
    return _StudentAnalyticsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAnalyticsNotifierProvider &&
        other.classId == classId &&
        other.timeRange == timeRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, timeRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentAnalyticsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<StudentAnalytics> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `timeRange` of this provider.
  AnalyticsTimeRange get timeRange;
}

class _StudentAnalyticsNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StudentAnalyticsNotifier,
          StudentAnalytics
        >
    with StudentAnalyticsNotifierRef {
  _StudentAnalyticsNotifierProviderElement(super.provider);

  @override
  String? get classId => (origin as StudentAnalyticsNotifierProvider).classId;
  @override
  AnalyticsTimeRange get timeRange =>
      (origin as StudentAnalyticsNotifierProvider).timeRange;
}

String _$teacherStudentAnalyticsNotifierHash() =>
    r'452a311859fb51a1ea538e17a8c0d5f6e1034f91';

abstract class _$TeacherStudentAnalyticsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<StudentAnalytics> {
  late final String studentId;
  late final String? classId;
  late final AnalyticsTimeRange timeRange;

  FutureOr<StudentAnalytics> build({
    required String studentId,
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  });
}

/// Teacher viewing a specific student's analytics (override studentId).
///
/// Copied from [TeacherStudentAnalyticsNotifier].
@ProviderFor(TeacherStudentAnalyticsNotifier)
const teacherStudentAnalyticsNotifierProvider =
    TeacherStudentAnalyticsNotifierFamily();

/// Teacher viewing a specific student's analytics (override studentId).
///
/// Copied from [TeacherStudentAnalyticsNotifier].
class TeacherStudentAnalyticsNotifierFamily
    extends Family<AsyncValue<StudentAnalytics>> {
  /// Teacher viewing a specific student's analytics (override studentId).
  ///
  /// Copied from [TeacherStudentAnalyticsNotifier].
  const TeacherStudentAnalyticsNotifierFamily();

  /// Teacher viewing a specific student's analytics (override studentId).
  ///
  /// Copied from [TeacherStudentAnalyticsNotifier].
  TeacherStudentAnalyticsNotifierProvider call({
    required String studentId,
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) {
    return TeacherStudentAnalyticsNotifierProvider(
      studentId: studentId,
      classId: classId,
      timeRange: timeRange,
    );
  }

  @override
  TeacherStudentAnalyticsNotifierProvider getProviderOverride(
    covariant TeacherStudentAnalyticsNotifierProvider provider,
  ) {
    return call(
      studentId: provider.studentId,
      classId: provider.classId,
      timeRange: provider.timeRange,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teacherStudentAnalyticsNotifierProvider';
}

/// Teacher viewing a specific student's analytics (override studentId).
///
/// Copied from [TeacherStudentAnalyticsNotifier].
class TeacherStudentAnalyticsNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TeacherStudentAnalyticsNotifier,
          StudentAnalytics
        > {
  /// Teacher viewing a specific student's analytics (override studentId).
  ///
  /// Copied from [TeacherStudentAnalyticsNotifier].
  TeacherStudentAnalyticsNotifierProvider({
    required String studentId,
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) : this._internal(
         () => TeacherStudentAnalyticsNotifier()
           ..studentId = studentId
           ..classId = classId
           ..timeRange = timeRange,
         from: teacherStudentAnalyticsNotifierProvider,
         name: r'teacherStudentAnalyticsNotifierProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teacherStudentAnalyticsNotifierHash,
         dependencies: TeacherStudentAnalyticsNotifierFamily._dependencies,
         allTransitiveDependencies:
             TeacherStudentAnalyticsNotifierFamily._allTransitiveDependencies,
         studentId: studentId,
         classId: classId,
         timeRange: timeRange,
       );

  TeacherStudentAnalyticsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.classId,
    required this.timeRange,
  }) : super.internal();

  final String studentId;
  final String? classId;
  final AnalyticsTimeRange timeRange;

  @override
  FutureOr<StudentAnalytics> runNotifierBuild(
    covariant TeacherStudentAnalyticsNotifier notifier,
  ) {
    return notifier.build(
      studentId: studentId,
      classId: classId,
      timeRange: timeRange,
    );
  }

  @override
  Override overrideWith(TeacherStudentAnalyticsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeacherStudentAnalyticsNotifierProvider._internal(
        () => create()
          ..studentId = studentId
          ..classId = classId
          ..timeRange = timeRange,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        classId: classId,
        timeRange: timeRange,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TeacherStudentAnalyticsNotifier,
    StudentAnalytics
  >
  createElement() {
    return _TeacherStudentAnalyticsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherStudentAnalyticsNotifierProvider &&
        other.studentId == studentId &&
        other.classId == classId &&
        other.timeRange == timeRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, timeRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherStudentAnalyticsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<StudentAnalytics> {
  /// The parameter `studentId` of this provider.
  String get studentId;

  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `timeRange` of this provider.
  AnalyticsTimeRange get timeRange;
}

class _TeacherStudentAnalyticsNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TeacherStudentAnalyticsNotifier,
          StudentAnalytics
        >
    with TeacherStudentAnalyticsNotifierRef {
  _TeacherStudentAnalyticsNotifierProviderElement(super.provider);

  @override
  String get studentId =>
      (origin as TeacherStudentAnalyticsNotifierProvider).studentId;
  @override
  String? get classId =>
      (origin as TeacherStudentAnalyticsNotifierProvider).classId;
  @override
  AnalyticsTimeRange get timeRange =>
      (origin as TeacherStudentAnalyticsNotifierProvider).timeRange;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

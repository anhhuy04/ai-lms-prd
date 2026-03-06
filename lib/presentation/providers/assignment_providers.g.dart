// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentRepositoryHash() =>
    r'87d37374f4d18d389e775a1611bac08704f78478';

/// Provider cho AssignmentRepository (dùng @riverpod để codegen)
///
/// Copied from [assignmentRepository].
@ProviderFor(assignmentRepository)
final assignmentRepositoryProvider =
    AutoDisposeProvider<AssignmentRepository>.internal(
      assignmentRepository,
      name: r'assignmentRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignmentRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignmentRepositoryRef = AutoDisposeProviderRef<AssignmentRepository>;
String _$classDistributedAssignmentsHash() =>
    r'6733f1fddbe6150b5e565866cf01bacaeb46d451';

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

/// Bài tập đã distribute cho 1 lớp (teacher view).
/// Trả về List<Map> chứa cả assignment + distribution info.
///
/// Copied from [classDistributedAssignments].
@ProviderFor(classDistributedAssignments)
const classDistributedAssignmentsProvider = ClassDistributedAssignmentsFamily();

/// Bài tập đã distribute cho 1 lớp (teacher view).
/// Trả về List<Map> chứa cả assignment + distribution info.
///
/// Copied from [classDistributedAssignments].
class ClassDistributedAssignmentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Bài tập đã distribute cho 1 lớp (teacher view).
  /// Trả về List<Map> chứa cả assignment + distribution info.
  ///
  /// Copied from [classDistributedAssignments].
  const ClassDistributedAssignmentsFamily();

  /// Bài tập đã distribute cho 1 lớp (teacher view).
  /// Trả về List<Map> chứa cả assignment + distribution info.
  ///
  /// Copied from [classDistributedAssignments].
  ClassDistributedAssignmentsProvider call(String classId) {
    return ClassDistributedAssignmentsProvider(classId);
  }

  @override
  ClassDistributedAssignmentsProvider getProviderOverride(
    covariant ClassDistributedAssignmentsProvider provider,
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
  String? get name => r'classDistributedAssignmentsProvider';
}

/// Bài tập đã distribute cho 1 lớp (teacher view).
/// Trả về List<Map> chứa cả assignment + distribution info.
///
/// Copied from [classDistributedAssignments].
class ClassDistributedAssignmentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Bài tập đã distribute cho 1 lớp (teacher view).
  /// Trả về List<Map> chứa cả assignment + distribution info.
  ///
  /// Copied from [classDistributedAssignments].
  ClassDistributedAssignmentsProvider(String classId)
    : this._internal(
        (ref) => classDistributedAssignments(
          ref as ClassDistributedAssignmentsRef,
          classId,
        ),
        from: classDistributedAssignmentsProvider,
        name: r'classDistributedAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$classDistributedAssignmentsHash,
        dependencies: ClassDistributedAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            ClassDistributedAssignmentsFamily._allTransitiveDependencies,
        classId: classId,
      );

  ClassDistributedAssignmentsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(
      ClassDistributedAssignmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassDistributedAssignmentsProvider._internal(
        (ref) => create(ref as ClassDistributedAssignmentsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ClassDistributedAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassDistributedAssignmentsProvider &&
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
mixin ClassDistributedAssignmentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassDistributedAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ClassDistributedAssignmentsRef {
  _ClassDistributedAssignmentsProviderElement(super.provider);

  @override
  String get classId => (origin as ClassDistributedAssignmentsProvider).classId;
}

String _$studentClassAssignmentsHash() =>
    r'404edd324185423f92ea5914d76d1e75be074a2d';

/// Bài tập cho học sinh trong 1 lớp.
/// Filter theo distribution_type (class/group/individual).
///
/// Copied from [studentClassAssignments].
@ProviderFor(studentClassAssignments)
const studentClassAssignmentsProvider = StudentClassAssignmentsFamily();

/// Bài tập cho học sinh trong 1 lớp.
/// Filter theo distribution_type (class/group/individual).
///
/// Copied from [studentClassAssignments].
class StudentClassAssignmentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Bài tập cho học sinh trong 1 lớp.
  /// Filter theo distribution_type (class/group/individual).
  ///
  /// Copied from [studentClassAssignments].
  const StudentClassAssignmentsFamily();

  /// Bài tập cho học sinh trong 1 lớp.
  /// Filter theo distribution_type (class/group/individual).
  ///
  /// Copied from [studentClassAssignments].
  StudentClassAssignmentsProvider call(String classId) {
    return StudentClassAssignmentsProvider(classId);
  }

  @override
  StudentClassAssignmentsProvider getProviderOverride(
    covariant StudentClassAssignmentsProvider provider,
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
  String? get name => r'studentClassAssignmentsProvider';
}

/// Bài tập cho học sinh trong 1 lớp.
/// Filter theo distribution_type (class/group/individual).
///
/// Copied from [studentClassAssignments].
class StudentClassAssignmentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Bài tập cho học sinh trong 1 lớp.
  /// Filter theo distribution_type (class/group/individual).
  ///
  /// Copied from [studentClassAssignments].
  StudentClassAssignmentsProvider(String classId)
    : this._internal(
        (ref) =>
            studentClassAssignments(ref as StudentClassAssignmentsRef, classId),
        from: studentClassAssignmentsProvider,
        name: r'studentClassAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentClassAssignmentsHash,
        dependencies: StudentClassAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            StudentClassAssignmentsFamily._allTransitiveDependencies,
        classId: classId,
      );

  StudentClassAssignmentsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(
      StudentClassAssignmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentClassAssignmentsProvider._internal(
        (ref) => create(ref as StudentClassAssignmentsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _StudentClassAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentClassAssignmentsProvider && other.classId == classId;
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
mixin StudentClassAssignmentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _StudentClassAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with StudentClassAssignmentsRef {
  _StudentClassAssignmentsProviderElement(super.provider);

  @override
  String get classId => (origin as StudentClassAssignmentsProvider).classId;
}

String _$distributionDetailHash() =>
    r'b3ab7dc4cbab2758b1d6e043a852480088a8939d';

/// Chi tiết distribution (assignment config + stats).
///
/// Copied from [distributionDetail].
@ProviderFor(distributionDetail)
const distributionDetailProvider = DistributionDetailFamily();

/// Chi tiết distribution (assignment config + stats).
///
/// Copied from [distributionDetail].
class DistributionDetailFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Chi tiết distribution (assignment config + stats).
  ///
  /// Copied from [distributionDetail].
  const DistributionDetailFamily();

  /// Chi tiết distribution (assignment config + stats).
  ///
  /// Copied from [distributionDetail].
  DistributionDetailProvider call(String distributionId) {
    return DistributionDetailProvider(distributionId);
  }

  @override
  DistributionDetailProvider getProviderOverride(
    covariant DistributionDetailProvider provider,
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
  String? get name => r'distributionDetailProvider';
}

/// Chi tiết distribution (assignment config + stats).
///
/// Copied from [distributionDetail].
class DistributionDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Chi tiết distribution (assignment config + stats).
  ///
  /// Copied from [distributionDetail].
  DistributionDetailProvider(String distributionId)
    : this._internal(
        (ref) =>
            distributionDetail(ref as DistributionDetailRef, distributionId),
        from: distributionDetailProvider,
        name: r'distributionDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$distributionDetailHash,
        dependencies: DistributionDetailFamily._dependencies,
        allTransitiveDependencies:
            DistributionDetailFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  DistributionDetailProvider._internal(
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
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(DistributionDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistributionDetailProvider._internal(
        (ref) => create(ref as DistributionDetailRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _DistributionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistributionDetailProvider &&
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
mixin DistributionDetailRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _DistributionDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with DistributionDetailRef {
  _DistributionDetailProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as DistributionDetailProvider).distributionId;
}

String _$distributionSubmissionsHash() =>
    r'0a3b4ba8a4ad51bd8fe4ee636ecee635a39ffeda';

/// Danh sách submissions cho distribution (kèm student info).
///
/// Copied from [distributionSubmissions].
@ProviderFor(distributionSubmissions)
const distributionSubmissionsProvider = DistributionSubmissionsFamily();

/// Danh sách submissions cho distribution (kèm student info).
///
/// Copied from [distributionSubmissions].
class DistributionSubmissionsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Danh sách submissions cho distribution (kèm student info).
  ///
  /// Copied from [distributionSubmissions].
  const DistributionSubmissionsFamily();

  /// Danh sách submissions cho distribution (kèm student info).
  ///
  /// Copied from [distributionSubmissions].
  DistributionSubmissionsProvider call(String distributionId) {
    return DistributionSubmissionsProvider(distributionId);
  }

  @override
  DistributionSubmissionsProvider getProviderOverride(
    covariant DistributionSubmissionsProvider provider,
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
  String? get name => r'distributionSubmissionsProvider';
}

/// Danh sách submissions cho distribution (kèm student info).
///
/// Copied from [distributionSubmissions].
class DistributionSubmissionsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Danh sách submissions cho distribution (kèm student info).
  ///
  /// Copied from [distributionSubmissions].
  DistributionSubmissionsProvider(String distributionId)
    : this._internal(
        (ref) => distributionSubmissions(
          ref as DistributionSubmissionsRef,
          distributionId,
        ),
        from: distributionSubmissionsProvider,
        name: r'distributionSubmissionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$distributionSubmissionsHash,
        dependencies: DistributionSubmissionsFamily._dependencies,
        allTransitiveDependencies:
            DistributionSubmissionsFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  DistributionSubmissionsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      DistributionSubmissionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistributionSubmissionsProvider._internal(
        (ref) => create(ref as DistributionSubmissionsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _DistributionSubmissionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistributionSubmissionsProvider &&
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
mixin DistributionSubmissionsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _DistributionSubmissionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with DistributionSubmissionsRef {
  _DistributionSubmissionsProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as DistributionSubmissionsProvider).distributionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

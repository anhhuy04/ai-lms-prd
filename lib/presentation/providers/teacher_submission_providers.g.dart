// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_submission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$submissionRepositoryHash() =>
    r'075e7e03153d0a1ef19348717e931b62f64da24a';

/// Provider cho SubmissionRepository
///
/// Copied from [submissionRepository].
@ProviderFor(submissionRepository)
final submissionRepositoryProvider =
    AutoDisposeProvider<SubmissionRepository>.internal(
      submissionRepository,
      name: r'submissionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submissionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubmissionRepositoryRef = AutoDisposeProviderRef<SubmissionRepository>;
String _$teacherSubmissionListHash() =>
    r'9055f099ed48ca94c0ccc01acad2cf2616989542';

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

/// Provider lấy danh sách submissions cho teacher
///
/// Copied from [teacherSubmissionList].
@ProviderFor(teacherSubmissionList)
const teacherSubmissionListProvider = TeacherSubmissionListFamily();

/// Provider lấy danh sách submissions cho teacher
///
/// Copied from [teacherSubmissionList].
class TeacherSubmissionListFamily
    extends Family<AsyncValue<TeacherSubmissionListState>> {
  /// Provider lấy danh sách submissions cho teacher
  ///
  /// Copied from [teacherSubmissionList].
  const TeacherSubmissionListFamily();

  /// Provider lấy danh sách submissions cho teacher
  ///
  /// Copied from [teacherSubmissionList].
  TeacherSubmissionListProvider call({
    required String distributionId,
    SubmissionFilter filter = SubmissionFilter.all,
  }) {
    return TeacherSubmissionListProvider(
      distributionId: distributionId,
      filter: filter,
    );
  }

  @override
  TeacherSubmissionListProvider getProviderOverride(
    covariant TeacherSubmissionListProvider provider,
  ) {
    return call(
      distributionId: provider.distributionId,
      filter: provider.filter,
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
  String? get name => r'teacherSubmissionListProvider';
}

/// Provider lấy danh sách submissions cho teacher
///
/// Copied from [teacherSubmissionList].
class TeacherSubmissionListProvider
    extends AutoDisposeFutureProvider<TeacherSubmissionListState> {
  /// Provider lấy danh sách submissions cho teacher
  ///
  /// Copied from [teacherSubmissionList].
  TeacherSubmissionListProvider({
    required String distributionId,
    SubmissionFilter filter = SubmissionFilter.all,
  }) : this._internal(
         (ref) => teacherSubmissionList(
           ref as TeacherSubmissionListRef,
           distributionId: distributionId,
           filter: filter,
         ),
         from: teacherSubmissionListProvider,
         name: r'teacherSubmissionListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teacherSubmissionListHash,
         dependencies: TeacherSubmissionListFamily._dependencies,
         allTransitiveDependencies:
             TeacherSubmissionListFamily._allTransitiveDependencies,
         distributionId: distributionId,
         filter: filter,
       );

  TeacherSubmissionListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
    required this.filter,
  }) : super.internal();

  final String distributionId;
  final SubmissionFilter filter;

  @override
  Override overrideWith(
    FutureOr<TeacherSubmissionListState> Function(
      TeacherSubmissionListRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherSubmissionListProvider._internal(
        (ref) => create(ref as TeacherSubmissionListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TeacherSubmissionListState> createElement() {
    return _TeacherSubmissionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherSubmissionListProvider &&
        other.distributionId == distributionId &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherSubmissionListRef
    on AutoDisposeFutureProviderRef<TeacherSubmissionListState> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;

  /// The parameter `filter` of this provider.
  SubmissionFilter get filter;
}

class _TeacherSubmissionListProviderElement
    extends AutoDisposeFutureProviderElement<TeacherSubmissionListState>
    with TeacherSubmissionListRef {
  _TeacherSubmissionListProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as TeacherSubmissionListProvider).distributionId;
  @override
  SubmissionFilter get filter =>
      (origin as TeacherSubmissionListProvider).filter;
}

String _$teacherSubmissionDetailHash() =>
    r'dd60fd14bdcadbb0b70d9eb9d231ba5b664d3d52';

/// Provider chi tiết một submission cho teacher
///
/// Copied from [teacherSubmissionDetail].
@ProviderFor(teacherSubmissionDetail)
const teacherSubmissionDetailProvider = TeacherSubmissionDetailFamily();

/// Provider chi tiết một submission cho teacher
///
/// Copied from [teacherSubmissionDetail].
class TeacherSubmissionDetailFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider chi tiết một submission cho teacher
  ///
  /// Copied from [teacherSubmissionDetail].
  const TeacherSubmissionDetailFamily();

  /// Provider chi tiết một submission cho teacher
  ///
  /// Copied from [teacherSubmissionDetail].
  TeacherSubmissionDetailProvider call({required String submissionId}) {
    return TeacherSubmissionDetailProvider(submissionId: submissionId);
  }

  @override
  TeacherSubmissionDetailProvider getProviderOverride(
    covariant TeacherSubmissionDetailProvider provider,
  ) {
    return call(submissionId: provider.submissionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teacherSubmissionDetailProvider';
}

/// Provider chi tiết một submission cho teacher
///
/// Copied from [teacherSubmissionDetail].
class TeacherSubmissionDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider chi tiết một submission cho teacher
  ///
  /// Copied from [teacherSubmissionDetail].
  TeacherSubmissionDetailProvider({required String submissionId})
    : this._internal(
        (ref) => teacherSubmissionDetail(
          ref as TeacherSubmissionDetailRef,
          submissionId: submissionId,
        ),
        from: teacherSubmissionDetailProvider,
        name: r'teacherSubmissionDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherSubmissionDetailHash,
        dependencies: TeacherSubmissionDetailFamily._dependencies,
        allTransitiveDependencies:
            TeacherSubmissionDetailFamily._allTransitiveDependencies,
        submissionId: submissionId,
      );

  TeacherSubmissionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.submissionId,
  }) : super.internal();

  final String submissionId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(TeacherSubmissionDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherSubmissionDetailProvider._internal(
        (ref) => create(ref as TeacherSubmissionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        submissionId: submissionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _TeacherSubmissionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherSubmissionDetailProvider &&
        other.submissionId == submissionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, submissionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherSubmissionDetailRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _TeacherSubmissionDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with TeacherSubmissionDetailRef {
  _TeacherSubmissionDetailProviderElement(super.provider);

  @override
  String get submissionId =>
      (origin as TeacherSubmissionDetailProvider).submissionId;
}

String _$submissionAnswersHash() => r'6d6b15cb521aeeaf1eb6c3e48f6790078a141757';

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
///
/// Copied from [submissionAnswers].
@ProviderFor(submissionAnswers)
const submissionAnswersProvider = SubmissionAnswersFamily();

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
///
/// Copied from [submissionAnswers].
class SubmissionAnswersFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
  ///
  /// Copied from [submissionAnswers].
  const SubmissionAnswersFamily();

  /// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
  ///
  /// Copied from [submissionAnswers].
  SubmissionAnswersProvider call({required String submissionId}) {
    return SubmissionAnswersProvider(submissionId: submissionId);
  }

  @override
  SubmissionAnswersProvider getProviderOverride(
    covariant SubmissionAnswersProvider provider,
  ) {
    return call(submissionId: provider.submissionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'submissionAnswersProvider';
}

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
///
/// Copied from [submissionAnswers].
class SubmissionAnswersProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
  ///
  /// Copied from [submissionAnswers].
  SubmissionAnswersProvider({required String submissionId})
    : this._internal(
        (ref) => submissionAnswers(
          ref as SubmissionAnswersRef,
          submissionId: submissionId,
        ),
        from: submissionAnswersProvider,
        name: r'submissionAnswersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$submissionAnswersHash,
        dependencies: SubmissionAnswersFamily._dependencies,
        allTransitiveDependencies:
            SubmissionAnswersFamily._allTransitiveDependencies,
        submissionId: submissionId,
      );

  SubmissionAnswersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.submissionId,
  }) : super.internal();

  final String submissionId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(SubmissionAnswersRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubmissionAnswersProvider._internal(
        (ref) => create(ref as SubmissionAnswersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        submissionId: submissionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _SubmissionAnswersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubmissionAnswersProvider &&
        other.submissionId == submissionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, submissionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubmissionAnswersRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _SubmissionAnswersProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with SubmissionAnswersRef {
  _SubmissionAnswersProviderElement(super.provider);

  @override
  String get submissionId => (origin as SubmissionAnswersProvider).submissionId;
}

String _$submissionFilterNotifierHash() =>
    r'8425d25bb792f25b2f8006efa2a70a5a37029e28';

/// Provider lọc submissions
///
/// Copied from [SubmissionFilterNotifier].
@ProviderFor(SubmissionFilterNotifier)
final submissionFilterNotifierProvider =
    AutoDisposeNotifierProvider<
      SubmissionFilterNotifier,
      SubmissionFilter
    >.internal(
      SubmissionFilterNotifier.new,
      name: r'submissionFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submissionFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubmissionFilterNotifier = AutoDisposeNotifier<SubmissionFilter>;
String _$submissionGradingNotifierHash() =>
    r'8d8ff0462659b2d22795c31134157f949c60312a';

/// Provider cập nhật điểm và feedback của submission
///
/// Copied from [SubmissionGradingNotifier].
@ProviderFor(SubmissionGradingNotifier)
final submissionGradingNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SubmissionGradingNotifier, void>.internal(
      SubmissionGradingNotifier.new,
      name: r'submissionGradingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submissionGradingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubmissionGradingNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

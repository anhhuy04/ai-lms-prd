// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_submission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$submissionRepositoryHash() =>
    r'cce64da4fbe329d3ca0fc10e1b761d75c46763a2';

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
    r'bcbecc5aa1d33b53123a3f9575f37872b7b265d4';

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

String _$gradeOverrideHistoryHash() =>
    r'26eb175c85a9f580c143e5ef9de6a8d96a113bb5';

/// Provider lấy grade override history cho audit trail
///
/// Copied from [gradeOverrideHistory].
@ProviderFor(gradeOverrideHistory)
const gradeOverrideHistoryProvider = GradeOverrideHistoryFamily();

/// Provider lấy grade override history cho audit trail
///
/// Copied from [gradeOverrideHistory].
class GradeOverrideHistoryFamily
    extends Family<AsyncValue<List<GradeOverride>>> {
  /// Provider lấy grade override history cho audit trail
  ///
  /// Copied from [gradeOverrideHistory].
  const GradeOverrideHistoryFamily();

  /// Provider lấy grade override history cho audit trail
  ///
  /// Copied from [gradeOverrideHistory].
  GradeOverrideHistoryProvider call({required String submissionAnswerId}) {
    return GradeOverrideHistoryProvider(submissionAnswerId: submissionAnswerId);
  }

  @override
  GradeOverrideHistoryProvider getProviderOverride(
    covariant GradeOverrideHistoryProvider provider,
  ) {
    return call(submissionAnswerId: provider.submissionAnswerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gradeOverrideHistoryProvider';
}

/// Provider lấy grade override history cho audit trail
///
/// Copied from [gradeOverrideHistory].
class GradeOverrideHistoryProvider
    extends AutoDisposeFutureProvider<List<GradeOverride>> {
  /// Provider lấy grade override history cho audit trail
  ///
  /// Copied from [gradeOverrideHistory].
  GradeOverrideHistoryProvider({required String submissionAnswerId})
    : this._internal(
        (ref) => gradeOverrideHistory(
          ref as GradeOverrideHistoryRef,
          submissionAnswerId: submissionAnswerId,
        ),
        from: gradeOverrideHistoryProvider,
        name: r'gradeOverrideHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gradeOverrideHistoryHash,
        dependencies: GradeOverrideHistoryFamily._dependencies,
        allTransitiveDependencies:
            GradeOverrideHistoryFamily._allTransitiveDependencies,
        submissionAnswerId: submissionAnswerId,
      );

  GradeOverrideHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.submissionAnswerId,
  }) : super.internal();

  final String submissionAnswerId;

  @override
  Override overrideWith(
    FutureOr<List<GradeOverride>> Function(GradeOverrideHistoryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GradeOverrideHistoryProvider._internal(
        (ref) => create(ref as GradeOverrideHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        submissionAnswerId: submissionAnswerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GradeOverride>> createElement() {
    return _GradeOverrideHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GradeOverrideHistoryProvider &&
        other.submissionAnswerId == submissionAnswerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, submissionAnswerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GradeOverrideHistoryRef
    on AutoDisposeFutureProviderRef<List<GradeOverride>> {
  /// The parameter `submissionAnswerId` of this provider.
  String get submissionAnswerId;
}

class _GradeOverrideHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<GradeOverride>>
    with GradeOverrideHistoryRef {
  _GradeOverrideHistoryProviderElement(super.provider);

  @override
  String get submissionAnswerId =>
      (origin as GradeOverrideHistoryProvider).submissionAnswerId;
}

String _$teacherSubmissionDetailHash() =>
    r'9f141d9fd8ff30222959d11927d2ba7f6843cf87';

/// Provider chi tiết một submission cho teacher
///
/// Copied from [teacherSubmissionDetail].
@ProviderFor(teacherSubmissionDetail)
const teacherSubmissionDetailProvider = TeacherSubmissionDetailFamily();

/// Provider chi tiết một submission cho teacher
///
/// Copied from [teacherSubmissionDetail].
class TeacherSubmissionDetailFamily extends Family<AsyncValue<Submission>> {
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
    extends AutoDisposeFutureProvider<Submission> {
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
    FutureOr<Submission> Function(TeacherSubmissionDetailRef provider) create,
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
  AutoDisposeFutureProviderElement<Submission> createElement() {
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
mixin TeacherSubmissionDetailRef on AutoDisposeFutureProviderRef<Submission> {
  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _TeacherSubmissionDetailProviderElement
    extends AutoDisposeFutureProviderElement<Submission>
    with TeacherSubmissionDetailRef {
  _TeacherSubmissionDetailProviderElement(super.provider);

  @override
  String get submissionId =>
      (origin as TeacherSubmissionDetailProvider).submissionId;
}

String _$submissionAnswersHash() => r'357e414435ee3abfe79349eac6b4ecd058b0ae35';

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
///
/// Copied from [submissionAnswers].
@ProviderFor(submissionAnswers)
const submissionAnswersProvider = SubmissionAnswersFamily();

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
///
/// Copied from [submissionAnswers].
class SubmissionAnswersFamily
    extends Family<AsyncValue<List<SubmissionAnswer>>> {
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
    extends AutoDisposeFutureProvider<List<SubmissionAnswer>> {
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
    FutureOr<List<SubmissionAnswer>> Function(SubmissionAnswersRef provider)
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
  AutoDisposeFutureProviderElement<List<SubmissionAnswer>> createElement() {
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
    on AutoDisposeFutureProviderRef<List<SubmissionAnswer>> {
  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _SubmissionAnswersProviderElement
    extends AutoDisposeFutureProviderElement<List<SubmissionAnswer>>
    with SubmissionAnswersRef {
  _SubmissionAnswersProviderElement(super.provider);

  @override
  String get submissionId => (origin as SubmissionAnswersProvider).submissionId;
}

String _$teacherStudentDistributionAttemptsHash() =>
    r'19ce707bb52585a03902ca870d2828912f5b1963';

/// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
///
/// Copied from [teacherStudentDistributionAttempts].
@ProviderFor(teacherStudentDistributionAttempts)
const teacherStudentDistributionAttemptsProvider =
    TeacherStudentDistributionAttemptsFamily();

/// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
///
/// Copied from [teacherStudentDistributionAttempts].
class TeacherStudentDistributionAttemptsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
  ///
  /// Copied from [teacherStudentDistributionAttempts].
  const TeacherStudentDistributionAttemptsFamily();

  /// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
  ///
  /// Copied from [teacherStudentDistributionAttempts].
  TeacherStudentDistributionAttemptsProvider call({
    required String distributionId,
    required String studentId,
  }) {
    return TeacherStudentDistributionAttemptsProvider(
      distributionId: distributionId,
      studentId: studentId,
    );
  }

  @override
  TeacherStudentDistributionAttemptsProvider getProviderOverride(
    covariant TeacherStudentDistributionAttemptsProvider provider,
  ) {
    return call(
      distributionId: provider.distributionId,
      studentId: provider.studentId,
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
  String? get name => r'teacherStudentDistributionAttemptsProvider';
}

/// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
///
/// Copied from [teacherStudentDistributionAttempts].
class TeacherStudentDistributionAttemptsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider lấy lịch sử các lần làm bài (attempts) của 1 học sinh cho 1 bài tập (Teacher view)
  ///
  /// Copied from [teacherStudentDistributionAttempts].
  TeacherStudentDistributionAttemptsProvider({
    required String distributionId,
    required String studentId,
  }) : this._internal(
         (ref) => teacherStudentDistributionAttempts(
           ref as TeacherStudentDistributionAttemptsRef,
           distributionId: distributionId,
           studentId: studentId,
         ),
         from: teacherStudentDistributionAttemptsProvider,
         name: r'teacherStudentDistributionAttemptsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teacherStudentDistributionAttemptsHash,
         dependencies: TeacherStudentDistributionAttemptsFamily._dependencies,
         allTransitiveDependencies: TeacherStudentDistributionAttemptsFamily
             ._allTransitiveDependencies,
         distributionId: distributionId,
         studentId: studentId,
       );

  TeacherStudentDistributionAttemptsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
    required this.studentId,
  }) : super.internal();

  final String distributionId;
  final String studentId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      TeacherStudentDistributionAttemptsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherStudentDistributionAttemptsProvider._internal(
        (ref) => create(ref as TeacherStudentDistributionAttemptsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _TeacherStudentDistributionAttemptsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherStudentDistributionAttemptsProvider &&
        other.distributionId == distributionId &&
        other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherStudentDistributionAttemptsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;

  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _TeacherStudentDistributionAttemptsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with TeacherStudentDistributionAttemptsRef {
  _TeacherStudentDistributionAttemptsProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as TeacherStudentDistributionAttemptsProvider).distributionId;
  @override
  String get studentId =>
      (origin as TeacherStudentDistributionAttemptsProvider).studentId;
}

String _$batchGradeAssignmentQuestionsHash() =>
    r'8b77b472486afac353b39f3763ce85b3d23af67d';

/// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
/// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
///
/// Copied from [batchGradeAssignmentQuestions].
@ProviderFor(batchGradeAssignmentQuestions)
const batchGradeAssignmentQuestionsProvider =
    BatchGradeAssignmentQuestionsFamily();

/// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
/// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
///
/// Copied from [batchGradeAssignmentQuestions].
class BatchGradeAssignmentQuestionsFamily
    extends Family<AsyncValue<List<AssignmentQuestion>>> {
  /// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
  /// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
  ///
  /// Copied from [batchGradeAssignmentQuestions].
  const BatchGradeAssignmentQuestionsFamily();

  /// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
  /// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
  ///
  /// Copied from [batchGradeAssignmentQuestions].
  BatchGradeAssignmentQuestionsProvider call({required String distributionId}) {
    return BatchGradeAssignmentQuestionsProvider(
      distributionId: distributionId,
    );
  }

  @override
  BatchGradeAssignmentQuestionsProvider getProviderOverride(
    covariant BatchGradeAssignmentQuestionsProvider provider,
  ) {
    return call(distributionId: provider.distributionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'batchGradeAssignmentQuestionsProvider';
}

/// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
/// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
///
/// Copied from [batchGradeAssignmentQuestions].
class BatchGradeAssignmentQuestionsProvider
    extends AutoDisposeFutureProvider<List<AssignmentQuestion>> {
  /// Track 2 — Danh sách câu hỏi (assignment_questions) của 1 distribution, dùng cho
  /// màn chấm theo câu. Chain: distributionDetail → assignment_id → câu hỏi (typed).
  ///
  /// Copied from [batchGradeAssignmentQuestions].
  BatchGradeAssignmentQuestionsProvider({required String distributionId})
    : this._internal(
        (ref) => batchGradeAssignmentQuestions(
          ref as BatchGradeAssignmentQuestionsRef,
          distributionId: distributionId,
        ),
        from: batchGradeAssignmentQuestionsProvider,
        name: r'batchGradeAssignmentQuestionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$batchGradeAssignmentQuestionsHash,
        dependencies: BatchGradeAssignmentQuestionsFamily._dependencies,
        allTransitiveDependencies:
            BatchGradeAssignmentQuestionsFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  BatchGradeAssignmentQuestionsProvider._internal(
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
    FutureOr<List<AssignmentQuestion>> Function(
      BatchGradeAssignmentQuestionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BatchGradeAssignmentQuestionsProvider._internal(
        (ref) => create(ref as BatchGradeAssignmentQuestionsRef),
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
  AutoDisposeFutureProviderElement<List<AssignmentQuestion>> createElement() {
    return _BatchGradeAssignmentQuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BatchGradeAssignmentQuestionsProvider &&
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
mixin BatchGradeAssignmentQuestionsRef
    on AutoDisposeFutureProviderRef<List<AssignmentQuestion>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _BatchGradeAssignmentQuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<AssignmentQuestion>>
    with BatchGradeAssignmentQuestionsRef {
  _BatchGradeAssignmentQuestionsProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as BatchGradeAssignmentQuestionsProvider).distributionId;
}

String _$distributionAnswersByQuestionHash() =>
    r'73816ed7d964cc7d3726bc7050bbb6305c22eee9';

/// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
/// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
///
/// Copied from [distributionAnswersByQuestion].
@ProviderFor(distributionAnswersByQuestion)
const distributionAnswersByQuestionProvider =
    DistributionAnswersByQuestionFamily();

/// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
/// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
///
/// Copied from [distributionAnswersByQuestion].
class DistributionAnswersByQuestionFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
  /// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
  ///
  /// Copied from [distributionAnswersByQuestion].
  const DistributionAnswersByQuestionFamily();

  /// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
  /// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
  ///
  /// Copied from [distributionAnswersByQuestion].
  DistributionAnswersByQuestionProvider call({
    required String distributionId,
    required String assignmentQuestionId,
  }) {
    return DistributionAnswersByQuestionProvider(
      distributionId: distributionId,
      assignmentQuestionId: assignmentQuestionId,
    );
  }

  @override
  DistributionAnswersByQuestionProvider getProviderOverride(
    covariant DistributionAnswersByQuestionProvider provider,
  ) {
    return call(
      distributionId: provider.distributionId,
      assignmentQuestionId: provider.assignmentQuestionId,
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
  String? get name => r'distributionAnswersByQuestionProvider';
}

/// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
/// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
///
/// Copied from [distributionAnswersByQuestion].
class DistributionAnswersByQuestionProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Track 2 — Câu trả lời của TẤT CẢ học sinh cho 1 câu hỏi trong distribution.
  /// Trả về list map thô từ RPC (answer_id, student_name, answer, ai_score, ...).
  ///
  /// Copied from [distributionAnswersByQuestion].
  DistributionAnswersByQuestionProvider({
    required String distributionId,
    required String assignmentQuestionId,
  }) : this._internal(
         (ref) => distributionAnswersByQuestion(
           ref as DistributionAnswersByQuestionRef,
           distributionId: distributionId,
           assignmentQuestionId: assignmentQuestionId,
         ),
         from: distributionAnswersByQuestionProvider,
         name: r'distributionAnswersByQuestionProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$distributionAnswersByQuestionHash,
         dependencies: DistributionAnswersByQuestionFamily._dependencies,
         allTransitiveDependencies:
             DistributionAnswersByQuestionFamily._allTransitiveDependencies,
         distributionId: distributionId,
         assignmentQuestionId: assignmentQuestionId,
       );

  DistributionAnswersByQuestionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
    required this.assignmentQuestionId,
  }) : super.internal();

  final String distributionId;
  final String assignmentQuestionId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      DistributionAnswersByQuestionRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistributionAnswersByQuestionProvider._internal(
        (ref) => create(ref as DistributionAnswersByQuestionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
        assignmentQuestionId: assignmentQuestionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _DistributionAnswersByQuestionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistributionAnswersByQuestionProvider &&
        other.distributionId == distributionId &&
        other.assignmentQuestionId == assignmentQuestionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);
    hash = _SystemHash.combine(hash, assignmentQuestionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistributionAnswersByQuestionRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;

  /// The parameter `assignmentQuestionId` of this provider.
  String get assignmentQuestionId;
}

class _DistributionAnswersByQuestionProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with DistributionAnswersByQuestionRef {
  _DistributionAnswersByQuestionProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as DistributionAnswersByQuestionProvider).distributionId;
  @override
  String get assignmentQuestionId =>
      (origin as DistributionAnswersByQuestionProvider).assignmentQuestionId;
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
    r'5dbf9c7a722e7e7c6d8481de73c357ede820fa50';

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

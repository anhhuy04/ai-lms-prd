// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_assignment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentAssignmentListHash() =>
    r'cab6d3aa77328c5391518ac8be3caa321276504d';

/// Danh sách bài tập của học sinh hiện tại (từ tất cả các lớp)
///
/// Copied from [studentAssignmentList].
@ProviderFor(studentAssignmentList)
final studentAssignmentListProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      studentAssignmentList,
      name: r'studentAssignmentListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentAssignmentListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentAssignmentListRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$studentAssignmentDetailHash() =>
    r'ce0562ac6bb951c5d9c2bfc3e6fc197a47e00679';

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

/// Chi tiết một bài tập cụ thể (bao gồm questions)
///
/// Copied from [studentAssignmentDetail].
@ProviderFor(studentAssignmentDetail)
const studentAssignmentDetailProvider = StudentAssignmentDetailFamily();

/// Chi tiết một bài tập cụ thể (bao gồm questions)
///
/// Copied from [studentAssignmentDetail].
class StudentAssignmentDetailFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Chi tiết một bài tập cụ thể (bao gồm questions)
  ///
  /// Copied from [studentAssignmentDetail].
  const StudentAssignmentDetailFamily();

  /// Chi tiết một bài tập cụ thể (bao gồm questions)
  ///
  /// Copied from [studentAssignmentDetail].
  StudentAssignmentDetailProvider call(String distributionId) {
    return StudentAssignmentDetailProvider(distributionId);
  }

  @override
  StudentAssignmentDetailProvider getProviderOverride(
    covariant StudentAssignmentDetailProvider provider,
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
  String? get name => r'studentAssignmentDetailProvider';
}

/// Chi tiết một bài tập cụ thể (bao gồm questions)
///
/// Copied from [studentAssignmentDetail].
class StudentAssignmentDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Chi tiết một bài tập cụ thể (bao gồm questions)
  ///
  /// Copied from [studentAssignmentDetail].
  StudentAssignmentDetailProvider(String distributionId)
    : this._internal(
        (ref) => studentAssignmentDetail(
          ref as StudentAssignmentDetailRef,
          distributionId,
        ),
        from: studentAssignmentDetailProvider,
        name: r'studentAssignmentDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentAssignmentDetailHash,
        dependencies: StudentAssignmentDetailFamily._dependencies,
        allTransitiveDependencies:
            StudentAssignmentDetailFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  StudentAssignmentDetailProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(StudentAssignmentDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentAssignmentDetailProvider._internal(
        (ref) => create(ref as StudentAssignmentDetailRef),
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
    return _StudentAssignmentDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAssignmentDetailProvider &&
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
mixin StudentAssignmentDetailRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _StudentAssignmentDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with StudentAssignmentDetailRef {
  _StudentAssignmentDetailProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as StudentAssignmentDetailProvider).distributionId;
}

String _$studentSubmissionHash() => r'e693c96ce30941d4d40cf802094c32adffbb1fb3';

/// Lấy hoặc tạo bài nộp (draft) cho một bài tập
///
/// Copied from [studentSubmission].
@ProviderFor(studentSubmission)
const studentSubmissionProvider = StudentSubmissionFamily();

/// Lấy hoặc tạo bài nộp (draft) cho một bài tập
///
/// Copied from [studentSubmission].
class StudentSubmissionFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// Lấy hoặc tạo bài nộp (draft) cho một bài tập
  ///
  /// Copied from [studentSubmission].
  const StudentSubmissionFamily();

  /// Lấy hoặc tạo bài nộp (draft) cho một bài tập
  ///
  /// Copied from [studentSubmission].
  StudentSubmissionProvider call(String distributionId) {
    return StudentSubmissionProvider(distributionId);
  }

  @override
  StudentSubmissionProvider getProviderOverride(
    covariant StudentSubmissionProvider provider,
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
  String? get name => r'studentSubmissionProvider';
}

/// Lấy hoặc tạo bài nộp (draft) cho một bài tập
///
/// Copied from [studentSubmission].
class StudentSubmissionProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// Lấy hoặc tạo bài nộp (draft) cho một bài tập
  ///
  /// Copied from [studentSubmission].
  StudentSubmissionProvider(String distributionId)
    : this._internal(
        (ref) => studentSubmission(ref as StudentSubmissionRef, distributionId),
        from: studentSubmissionProvider,
        name: r'studentSubmissionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentSubmissionHash,
        dependencies: StudentSubmissionFamily._dependencies,
        allTransitiveDependencies:
            StudentSubmissionFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  StudentSubmissionProvider._internal(
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
    FutureOr<Map<String, dynamic>?> Function(StudentSubmissionRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentSubmissionProvider._internal(
        (ref) => create(ref as StudentSubmissionRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _StudentSubmissionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSubmissionProvider &&
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
mixin StudentSubmissionRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _StudentSubmissionProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with StudentSubmissionRef {
  _StudentSubmissionProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as StudentSubmissionProvider).distributionId;
}

String _$saveSubmissionDraftHash() =>
    r'b03125aecb2ff73f51d1ee6bba8e74eaecef09b5';

/// Lưu bản nháp bài nộp (auto-save)
///
/// Copied from [saveSubmissionDraft].
@ProviderFor(saveSubmissionDraft)
const saveSubmissionDraftProvider = SaveSubmissionDraftFamily();

/// Lưu bản nháp bài nộp (auto-save)
///
/// Copied from [saveSubmissionDraft].
class SaveSubmissionDraftFamily extends Family<AsyncValue<void>> {
  /// Lưu bản nháp bài nộp (auto-save)
  ///
  /// Copied from [saveSubmissionDraft].
  const SaveSubmissionDraftFamily();

  /// Lưu bản nháp bài nộp (auto-save)
  ///
  /// Copied from [saveSubmissionDraft].
  SaveSubmissionDraftProvider call(
    String distributionId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) {
    return SaveSubmissionDraftProvider(distributionId, answers, uploadedFiles);
  }

  @override
  SaveSubmissionDraftProvider getProviderOverride(
    covariant SaveSubmissionDraftProvider provider,
  ) {
    return call(
      provider.distributionId,
      provider.answers,
      provider.uploadedFiles,
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
  String? get name => r'saveSubmissionDraftProvider';
}

/// Lưu bản nháp bài nộp (auto-save)
///
/// Copied from [saveSubmissionDraft].
class SaveSubmissionDraftProvider extends AutoDisposeFutureProvider<void> {
  /// Lưu bản nháp bài nộp (auto-save)
  ///
  /// Copied from [saveSubmissionDraft].
  SaveSubmissionDraftProvider(
    String distributionId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) : this._internal(
        (ref) => saveSubmissionDraft(
          ref as SaveSubmissionDraftRef,
          distributionId,
          answers,
          uploadedFiles,
        ),
        from: saveSubmissionDraftProvider,
        name: r'saveSubmissionDraftProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$saveSubmissionDraftHash,
        dependencies: SaveSubmissionDraftFamily._dependencies,
        allTransitiveDependencies:
            SaveSubmissionDraftFamily._allTransitiveDependencies,
        distributionId: distributionId,
        answers: answers,
        uploadedFiles: uploadedFiles,
      );

  SaveSubmissionDraftProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distributionId,
    required this.answers,
    required this.uploadedFiles,
  }) : super.internal();

  final String distributionId;
  final Map<String, dynamic> answers;
  final List<String> uploadedFiles;

  @override
  Override overrideWith(
    FutureOr<void> Function(SaveSubmissionDraftRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaveSubmissionDraftProvider._internal(
        (ref) => create(ref as SaveSubmissionDraftRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distributionId: distributionId,
        answers: answers,
        uploadedFiles: uploadedFiles,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _SaveSubmissionDraftProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveSubmissionDraftProvider &&
        other.distributionId == distributionId &&
        other.answers == answers &&
        other.uploadedFiles == uploadedFiles;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distributionId.hashCode);
    hash = _SystemHash.combine(hash, answers.hashCode);
    hash = _SystemHash.combine(hash, uploadedFiles.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SaveSubmissionDraftRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;

  /// The parameter `answers` of this provider.
  Map<String, dynamic> get answers;

  /// The parameter `uploadedFiles` of this provider.
  List<String> get uploadedFiles;
}

class _SaveSubmissionDraftProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with SaveSubmissionDraftRef {
  _SaveSubmissionDraftProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as SaveSubmissionDraftProvider).distributionId;
  @override
  Map<String, dynamic> get answers =>
      (origin as SaveSubmissionDraftProvider).answers;
  @override
  List<String> get uploadedFiles =>
      (origin as SaveSubmissionDraftProvider).uploadedFiles;
}

String _$submitAssignmentHash() => r'dc1b30b984fa7380910301f2031d4e4f904201ca';

/// Nộp bài tập
///
/// Copied from [submitAssignment].
@ProviderFor(submitAssignment)
const submitAssignmentProvider = SubmitAssignmentFamily();

/// Nộp bài tập
///
/// Copied from [submitAssignment].
class SubmitAssignmentFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Nộp bài tập
  ///
  /// Copied from [submitAssignment].
  const SubmitAssignmentFamily();

  /// Nộp bài tập
  ///
  /// Copied from [submitAssignment].
  SubmitAssignmentProvider call(String distributionId) {
    return SubmitAssignmentProvider(distributionId);
  }

  @override
  SubmitAssignmentProvider getProviderOverride(
    covariant SubmitAssignmentProvider provider,
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
  String? get name => r'submitAssignmentProvider';
}

/// Nộp bài tập
///
/// Copied from [submitAssignment].
class SubmitAssignmentProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Nộp bài tập
  ///
  /// Copied from [submitAssignment].
  SubmitAssignmentProvider(String distributionId)
    : this._internal(
        (ref) => submitAssignment(ref as SubmitAssignmentRef, distributionId),
        from: submitAssignmentProvider,
        name: r'submitAssignmentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$submitAssignmentHash,
        dependencies: SubmitAssignmentFamily._dependencies,
        allTransitiveDependencies:
            SubmitAssignmentFamily._allTransitiveDependencies,
        distributionId: distributionId,
      );

  SubmitAssignmentProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(SubmitAssignmentRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubmitAssignmentProvider._internal(
        (ref) => create(ref as SubmitAssignmentRef),
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
    return _SubmitAssignmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubmitAssignmentProvider &&
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
mixin SubmitAssignmentRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `distributionId` of this provider.
  String get distributionId;
}

class _SubmitAssignmentProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with SubmitAssignmentRef {
  _SubmitAssignmentProviderElement(super.provider);

  @override
  String get distributionId =>
      (origin as SubmitAssignmentProvider).distributionId;
}

String _$studentSubmissionHistoryHash() =>
    r'a41d7a70745d1eae710fa3fb322e48a3b30844b0';

/// Lịch sử nộp bài của học sinh
///
/// Copied from [studentSubmissionHistory].
@ProviderFor(studentSubmissionHistory)
final studentSubmissionHistoryProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      studentSubmissionHistory,
      name: r'studentSubmissionHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentSubmissionHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentSubmissionHistoryRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

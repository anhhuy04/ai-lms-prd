// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherNotesRepositoryHash() =>
    r'3dbbd27d4d42ff5864dfd7a73302f4b3abe83317';

/// Provider cho TeacherNotesRepository.
///
/// Copied from [teacherNotesRepository].
@ProviderFor(teacherNotesRepository)
final teacherNotesRepositoryProvider =
    AutoDisposeProvider<TeacherNotesRepository>.internal(
      teacherNotesRepository,
      name: r'teacherNotesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherNotesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherNotesRepositoryRef =
    AutoDisposeProviderRef<TeacherNotesRepository>;
String _$teacherNotesHash() => r'8894ac0b2c936009941d7964c53091eb021ae576';

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

/// Provider lấy danh sách ghi chú của một học sinh.
///
/// Copied from [teacherNotes].
@ProviderFor(teacherNotes)
const teacherNotesProvider = TeacherNotesFamily();

/// Provider lấy danh sách ghi chú của một học sinh.
///
/// Copied from [teacherNotes].
class TeacherNotesFamily extends Family<AsyncValue<List<TeacherNote>>> {
  /// Provider lấy danh sách ghi chú của một học sinh.
  ///
  /// Copied from [teacherNotes].
  const TeacherNotesFamily();

  /// Provider lấy danh sách ghi chú của một học sinh.
  ///
  /// Copied from [teacherNotes].
  TeacherNotesProvider call({required String studentId}) {
    return TeacherNotesProvider(studentId: studentId);
  }

  @override
  TeacherNotesProvider getProviderOverride(
    covariant TeacherNotesProvider provider,
  ) {
    return call(studentId: provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teacherNotesProvider';
}

/// Provider lấy danh sách ghi chú của một học sinh.
///
/// Copied from [teacherNotes].
class TeacherNotesProvider
    extends AutoDisposeFutureProvider<List<TeacherNote>> {
  /// Provider lấy danh sách ghi chú của một học sinh.
  ///
  /// Copied from [teacherNotes].
  TeacherNotesProvider({required String studentId})
    : this._internal(
        (ref) => teacherNotes(ref as TeacherNotesRef, studentId: studentId),
        from: teacherNotesProvider,
        name: r'teacherNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherNotesHash,
        dependencies: TeacherNotesFamily._dependencies,
        allTransitiveDependencies:
            TeacherNotesFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  TeacherNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final String studentId;

  @override
  Override overrideWith(
    FutureOr<List<TeacherNote>> Function(TeacherNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherNotesProvider._internal(
        (ref) => create(ref as TeacherNotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TeacherNote>> createElement() {
    return _TeacherNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherNotesProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherNotesRef on AutoDisposeFutureProviderRef<List<TeacherNote>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _TeacherNotesProviderElement
    extends AutoDisposeFutureProviderElement<List<TeacherNote>>
    with TeacherNotesRef {
  _TeacherNotesProviderElement(super.provider);

  @override
  String get studentId => (origin as TeacherNotesProvider).studentId;
}

String _$teacherNotesNotifierHash() =>
    r'70eb2adfe8d440099fbe8361a30b0e0498188a34';

/// Notifier cho các mutation (thêm/sửa/xóa) ghi chú của giáo viên.
///
/// LƯU Ý: Các method dưới đây CỐ TÌNH ném lại exception khi thất bại thay vì
/// nuốt vào `AsyncValue` (notifier này không có ai watch nên state thay đổi sẽ
/// không hiển thị ở đâu). Widget gọi sẽ `await` → bắt lỗi → hiện SnackBar và
/// tự `ref.invalidate(teacherNotesProvider(...))` bằng ref còn sống của nó.
///
/// Copied from [TeacherNotesNotifier].
@ProviderFor(TeacherNotesNotifier)
final teacherNotesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TeacherNotesNotifier, void>.internal(
      TeacherNotesNotifier.new,
      name: r'teacherNotesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherNotesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeacherNotesNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

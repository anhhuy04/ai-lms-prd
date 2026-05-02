// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupsByClassHash() => r'6380e375139920f01727942f01362588d7a787c3';

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

/// See also [groupsByClass].
@ProviderFor(groupsByClass)
const groupsByClassProvider = GroupsByClassFamily();

/// See also [groupsByClass].
class GroupsByClassFamily extends Family<AsyncValue<List<Group>>> {
  /// See also [groupsByClass].
  const GroupsByClassFamily();

  /// See also [groupsByClass].
  GroupsByClassProvider call(String classId) {
    return GroupsByClassProvider(classId);
  }

  @override
  GroupsByClassProvider getProviderOverride(
    covariant GroupsByClassProvider provider,
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
  String? get name => r'groupsByClassProvider';
}

/// See also [groupsByClass].
class GroupsByClassProvider extends AutoDisposeFutureProvider<List<Group>> {
  /// See also [groupsByClass].
  GroupsByClassProvider(String classId)
    : this._internal(
        (ref) => groupsByClass(ref as GroupsByClassRef, classId),
        from: groupsByClassProvider,
        name: r'groupsByClassProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupsByClassHash,
        dependencies: GroupsByClassFamily._dependencies,
        allTransitiveDependencies:
            GroupsByClassFamily._allTransitiveDependencies,
        classId: classId,
      );

  GroupsByClassProvider._internal(
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
    FutureOr<List<Group>> Function(GroupsByClassRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupsByClassProvider._internal(
        (ref) => create(ref as GroupsByClassRef),
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
  AutoDisposeFutureProviderElement<List<Group>> createElement() {
    return _GroupsByClassProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupsByClassProvider && other.classId == classId;
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
mixin GroupsByClassRef on AutoDisposeFutureProviderRef<List<Group>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _GroupsByClassProviderElement
    extends AutoDisposeFutureProviderElement<List<Group>>
    with GroupsByClassRef {
  _GroupsByClassProviderElement(super.provider);

  @override
  String get classId => (origin as GroupsByClassProvider).classId;
}

String _$groupMembersWithProfilesHash() =>
    r'46a98e68c06b9f62d397249df50698cee96437c9';

/// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
///
/// Copied from [groupMembersWithProfiles].
@ProviderFor(groupMembersWithProfiles)
const groupMembersWithProfilesProvider = GroupMembersWithProfilesFamily();

/// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
///
/// Copied from [groupMembersWithProfiles].
class GroupMembersWithProfilesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
  ///
  /// Copied from [groupMembersWithProfiles].
  const GroupMembersWithProfilesFamily();

  /// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
  ///
  /// Copied from [groupMembersWithProfiles].
  GroupMembersWithProfilesProvider call(String groupId) {
    return GroupMembersWithProfilesProvider(groupId);
  }

  @override
  GroupMembersWithProfilesProvider getProviderOverride(
    covariant GroupMembersWithProfilesProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupMembersWithProfilesProvider';
}

/// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
///
/// Copied from [groupMembersWithProfiles].
class GroupMembersWithProfilesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
  ///
  /// Copied from [groupMembersWithProfiles].
  GroupMembersWithProfilesProvider(String groupId)
    : this._internal(
        (ref) => groupMembersWithProfiles(
          ref as GroupMembersWithProfilesRef,
          groupId,
        ),
        from: groupMembersWithProfilesProvider,
        name: r'groupMembersWithProfilesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMembersWithProfilesHash,
        dependencies: GroupMembersWithProfilesFamily._dependencies,
        allTransitiveDependencies:
            GroupMembersWithProfilesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupMembersWithProfilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      GroupMembersWithProfilesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersWithProfilesProvider._internal(
        (ref) => create(ref as GroupMembersWithProfilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _GroupMembersWithProfilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersWithProfilesProvider &&
        other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupMembersWithProfilesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMembersWithProfilesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with GroupMembersWithProfilesRef {
  _GroupMembersWithProfilesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMembersWithProfilesProvider).groupId;
}

String _$classStudentsWithProfilesHash() =>
    r'2d97af9ce92b9e2da2f5af8b1628e84bd647f33b';

/// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
///
/// Copied from [classStudentsWithProfiles].
@ProviderFor(classStudentsWithProfiles)
const classStudentsWithProfilesProvider = ClassStudentsWithProfilesFamily();

/// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
///
/// Copied from [classStudentsWithProfiles].
class ClassStudentsWithProfilesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
  ///
  /// Copied from [classStudentsWithProfiles].
  const ClassStudentsWithProfilesFamily();

  /// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
  ///
  /// Copied from [classStudentsWithProfiles].
  ClassStudentsWithProfilesProvider call(String classId) {
    return ClassStudentsWithProfilesProvider(classId);
  }

  @override
  ClassStudentsWithProfilesProvider getProviderOverride(
    covariant ClassStudentsWithProfilesProvider provider,
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
  String? get name => r'classStudentsWithProfilesProvider';
}

/// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
///
/// Copied from [classStudentsWithProfiles].
class ClassStudentsWithProfilesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
  ///
  /// Copied from [classStudentsWithProfiles].
  ClassStudentsWithProfilesProvider(String classId)
    : this._internal(
        (ref) => classStudentsWithProfiles(
          ref as ClassStudentsWithProfilesRef,
          classId,
        ),
        from: classStudentsWithProfilesProvider,
        name: r'classStudentsWithProfilesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$classStudentsWithProfilesHash,
        dependencies: ClassStudentsWithProfilesFamily._dependencies,
        allTransitiveDependencies:
            ClassStudentsWithProfilesFamily._allTransitiveDependencies,
        classId: classId,
      );

  ClassStudentsWithProfilesProvider._internal(
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
      ClassStudentsWithProfilesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassStudentsWithProfilesProvider._internal(
        (ref) => create(ref as ClassStudentsWithProfilesRef),
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
    return _ClassStudentsWithProfilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassStudentsWithProfilesProvider &&
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
mixin ClassStudentsWithProfilesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassStudentsWithProfilesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ClassStudentsWithProfilesRef {
  _ClassStudentsWithProfilesProviderElement(super.provider);

  @override
  String get classId => (origin as ClassStudentsWithProfilesProvider).classId;
}

String _$groupMemberCountsHash() => r'82783dcdf66708b63b2fa3c55f509d48efbc8293';

/// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
///
/// Copied from [groupMemberCounts].
@ProviderFor(groupMemberCounts)
const groupMemberCountsProvider = GroupMemberCountsFamily();

/// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
///
/// Copied from [groupMemberCounts].
class GroupMemberCountsFamily extends Family<AsyncValue<Map<String, int>>> {
  /// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
  ///
  /// Copied from [groupMemberCounts].
  const GroupMemberCountsFamily();

  /// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
  ///
  /// Copied from [groupMemberCounts].
  GroupMemberCountsProvider call(String classId) {
    return GroupMemberCountsProvider(classId);
  }

  @override
  GroupMemberCountsProvider getProviderOverride(
    covariant GroupMemberCountsProvider provider,
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
  String? get name => r'groupMemberCountsProvider';
}

/// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
///
/// Copied from [groupMemberCounts].
class GroupMemberCountsProvider
    extends AutoDisposeFutureProvider<Map<String, int>> {
  /// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
  ///
  /// Copied from [groupMemberCounts].
  GroupMemberCountsProvider(String classId)
    : this._internal(
        (ref) => groupMemberCounts(ref as GroupMemberCountsRef, classId),
        from: groupMemberCountsProvider,
        name: r'groupMemberCountsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMemberCountsHash,
        dependencies: GroupMemberCountsFamily._dependencies,
        allTransitiveDependencies:
            GroupMemberCountsFamily._allTransitiveDependencies,
        classId: classId,
      );

  GroupMemberCountsProvider._internal(
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
    FutureOr<Map<String, int>> Function(GroupMemberCountsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMemberCountsProvider._internal(
        (ref) => create(ref as GroupMemberCountsRef),
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
  AutoDisposeFutureProviderElement<Map<String, int>> createElement() {
    return _GroupMemberCountsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMemberCountsProvider && other.classId == classId;
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
mixin GroupMemberCountsRef on AutoDisposeFutureProviderRef<Map<String, int>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _GroupMemberCountsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, int>>
    with GroupMemberCountsRef {
  _GroupMemberCountsProviderElement(super.provider);

  @override
  String get classId => (origin as GroupMemberCountsProvider).classId;
}

String _$groupAssignmentProgressHash() =>
    r'687b32c7104250f8964e393cc61293d0158b1698';

/// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
///
/// Copied from [groupAssignmentProgress].
@ProviderFor(groupAssignmentProgress)
const groupAssignmentProgressProvider = GroupAssignmentProgressFamily();

/// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
///
/// Copied from [groupAssignmentProgress].
class GroupAssignmentProgressFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
  ///
  /// Copied from [groupAssignmentProgress].
  const GroupAssignmentProgressFamily();

  /// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
  ///
  /// Copied from [groupAssignmentProgress].
  GroupAssignmentProgressProvider call(String groupId) {
    return GroupAssignmentProgressProvider(groupId);
  }

  @override
  GroupAssignmentProgressProvider getProviderOverride(
    covariant GroupAssignmentProgressProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupAssignmentProgressProvider';
}

/// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
///
/// Copied from [groupAssignmentProgress].
class GroupAssignmentProgressProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
  ///
  /// Copied from [groupAssignmentProgress].
  GroupAssignmentProgressProvider(String groupId)
    : this._internal(
        (ref) =>
            groupAssignmentProgress(ref as GroupAssignmentProgressRef, groupId),
        from: groupAssignmentProgressProvider,
        name: r'groupAssignmentProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupAssignmentProgressHash,
        dependencies: GroupAssignmentProgressFamily._dependencies,
        allTransitiveDependencies:
            GroupAssignmentProgressFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupAssignmentProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      GroupAssignmentProgressRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupAssignmentProgressProvider._internal(
        (ref) => create(ref as GroupAssignmentProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _GroupAssignmentProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupAssignmentProgressProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupAssignmentProgressRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupAssignmentProgressProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with GroupAssignmentProgressRef {
  _GroupAssignmentProgressProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupAssignmentProgressProvider).groupId;
}

String _$groupNotifierHash() => r'9a267fd23cf03964be1194332b4c78710224446a';

/// See also [GroupNotifier].
@ProviderFor(GroupNotifier)
final groupNotifierProvider =
    AutoDisposeNotifierProvider<GroupNotifier, AsyncValue<void>>.internal(
      GroupNotifier.new,
      name: r'groupNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GroupNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

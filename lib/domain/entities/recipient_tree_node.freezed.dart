// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipient_tree_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentNode _$StudentNodeFromJson(Map<String, dynamic> json) {
  return _StudentNode.fromJson(json);
}

/// @nodoc
mixin _$StudentNode {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double? get score => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this StudentNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentNodeCopyWith<StudentNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentNodeCopyWith<$Res> {
  factory $StudentNodeCopyWith(
    StudentNode value,
    $Res Function(StudentNode) then,
  ) = _$StudentNodeCopyWithImpl<$Res, StudentNode>;
  @useResult
  $Res call({String id, String name, double? score, String? note});
}

/// @nodoc
class _$StudentNodeCopyWithImpl<$Res, $Val extends StudentNode>
    implements $StudentNodeCopyWith<$Res> {
  _$StudentNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? score = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentNodeImplCopyWith<$Res>
    implements $StudentNodeCopyWith<$Res> {
  factory _$$StudentNodeImplCopyWith(
    _$StudentNodeImpl value,
    $Res Function(_$StudentNodeImpl) then,
  ) = __$$StudentNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, double? score, String? note});
}

/// @nodoc
class __$$StudentNodeImplCopyWithImpl<$Res>
    extends _$StudentNodeCopyWithImpl<$Res, _$StudentNodeImpl>
    implements _$$StudentNodeImplCopyWith<$Res> {
  __$$StudentNodeImplCopyWithImpl(
    _$StudentNodeImpl _value,
    $Res Function(_$StudentNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? score = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _$StudentNodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentNodeImpl implements _StudentNode {
  const _$StudentNodeImpl({
    required this.id,
    required this.name,
    this.score,
    this.note,
  });

  factory _$StudentNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentNodeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double? score;
  @override
  final String? note;

  @override
  String toString() {
    return 'StudentNode(id: $id, name: $name, score: $score, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, score, note);

  /// Create a copy of StudentNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentNodeImplCopyWith<_$StudentNodeImpl> get copyWith =>
      __$$StudentNodeImplCopyWithImpl<_$StudentNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentNodeImplToJson(this);
  }
}

abstract class _StudentNode implements StudentNode {
  const factory _StudentNode({
    required final String id,
    required final String name,
    final double? score,
    final String? note,
  }) = _$StudentNodeImpl;

  factory _StudentNode.fromJson(Map<String, dynamic> json) =
      _$StudentNodeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double? get score;
  @override
  String? get note;

  /// Create a copy of StudentNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentNodeImplCopyWith<_$StudentNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupNode _$GroupNodeFromJson(Map<String, dynamic> json) {
  return _GroupNode.fromJson(json);
}

/// @nodoc
mixin _$GroupNode {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<StudentNode> get students => throw _privateConstructorUsedError;

  /// Serializes this GroupNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupNodeCopyWith<GroupNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupNodeCopyWith<$Res> {
  factory $GroupNodeCopyWith(GroupNode value, $Res Function(GroupNode) then) =
      _$GroupNodeCopyWithImpl<$Res, GroupNode>;
  @useResult
  $Res call({String id, String name, List<StudentNode> students});
}

/// @nodoc
class _$GroupNodeCopyWithImpl<$Res, $Val extends GroupNode>
    implements $GroupNodeCopyWith<$Res> {
  _$GroupNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? students = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            students: null == students
                ? _value.students
                : students // ignore: cast_nullable_to_non_nullable
                      as List<StudentNode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupNodeImplCopyWith<$Res>
    implements $GroupNodeCopyWith<$Res> {
  factory _$$GroupNodeImplCopyWith(
    _$GroupNodeImpl value,
    $Res Function(_$GroupNodeImpl) then,
  ) = __$$GroupNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, List<StudentNode> students});
}

/// @nodoc
class __$$GroupNodeImplCopyWithImpl<$Res>
    extends _$GroupNodeCopyWithImpl<$Res, _$GroupNodeImpl>
    implements _$$GroupNodeImplCopyWith<$Res> {
  __$$GroupNodeImplCopyWithImpl(
    _$GroupNodeImpl _value,
    $Res Function(_$GroupNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? students = null}) {
    return _then(
      _$GroupNodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        students: null == students
            ? _value._students
            : students // ignore: cast_nullable_to_non_nullable
                  as List<StudentNode>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupNodeImpl implements _GroupNode {
  const _$GroupNodeImpl({
    required this.id,
    required this.name,
    final List<StudentNode> students = const [],
  }) : _students = students;

  factory _$GroupNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupNodeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<StudentNode> _students;
  @override
  @JsonKey()
  List<StudentNode> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  @override
  String toString() {
    return 'GroupNode(id: $id, name: $name, students: $students)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._students, _students));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_students),
  );

  /// Create a copy of GroupNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupNodeImplCopyWith<_$GroupNodeImpl> get copyWith =>
      __$$GroupNodeImplCopyWithImpl<_$GroupNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupNodeImplToJson(this);
  }
}

abstract class _GroupNode implements GroupNode {
  const factory _GroupNode({
    required final String id,
    required final String name,
    final List<StudentNode> students,
  }) = _$GroupNodeImpl;

  factory _GroupNode.fromJson(Map<String, dynamic> json) =
      _$GroupNodeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<StudentNode> get students;

  /// Create a copy of GroupNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupNodeImplCopyWith<_$GroupNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassNode _$ClassNodeFromJson(Map<String, dynamic> json) {
  return _ClassNode.fromJson(json);
}

/// @nodoc
mixin _$ClassNode {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get totalStudents => throw _privateConstructorUsedError;
  List<GroupNode> get groups => throw _privateConstructorUsedError;
  List<StudentNode> get independentStudents =>
      throw _privateConstructorUsedError;

  /// Serializes this ClassNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassNodeCopyWith<ClassNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassNodeCopyWith<$Res> {
  factory $ClassNodeCopyWith(ClassNode value, $Res Function(ClassNode) then) =
      _$ClassNodeCopyWithImpl<$Res, ClassNode>;
  @useResult
  $Res call({
    String id,
    String name,
    int totalStudents,
    List<GroupNode> groups,
    List<StudentNode> independentStudents,
  });
}

/// @nodoc
class _$ClassNodeCopyWithImpl<$Res, $Val extends ClassNode>
    implements $ClassNodeCopyWith<$Res> {
  _$ClassNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? totalStudents = null,
    Object? groups = null,
    Object? independentStudents = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            totalStudents: null == totalStudents
                ? _value.totalStudents
                : totalStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            groups: null == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<GroupNode>,
            independentStudents: null == independentStudents
                ? _value.independentStudents
                : independentStudents // ignore: cast_nullable_to_non_nullable
                      as List<StudentNode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassNodeImplCopyWith<$Res>
    implements $ClassNodeCopyWith<$Res> {
  factory _$$ClassNodeImplCopyWith(
    _$ClassNodeImpl value,
    $Res Function(_$ClassNodeImpl) then,
  ) = __$$ClassNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int totalStudents,
    List<GroupNode> groups,
    List<StudentNode> independentStudents,
  });
}

/// @nodoc
class __$$ClassNodeImplCopyWithImpl<$Res>
    extends _$ClassNodeCopyWithImpl<$Res, _$ClassNodeImpl>
    implements _$$ClassNodeImplCopyWith<$Res> {
  __$$ClassNodeImplCopyWithImpl(
    _$ClassNodeImpl _value,
    $Res Function(_$ClassNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? totalStudents = null,
    Object? groups = null,
    Object? independentStudents = null,
  }) {
    return _then(
      _$ClassNodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        totalStudents: null == totalStudents
            ? _value.totalStudents
            : totalStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<GroupNode>,
        independentStudents: null == independentStudents
            ? _value._independentStudents
            : independentStudents // ignore: cast_nullable_to_non_nullable
                  as List<StudentNode>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassNodeImpl implements _ClassNode {
  const _$ClassNodeImpl({
    required this.id,
    required this.name,
    this.totalStudents = 0,
    final List<GroupNode> groups = const [],
    final List<StudentNode> independentStudents = const [],
  }) : _groups = groups,
       _independentStudents = independentStudents;

  factory _$ClassNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassNodeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final int totalStudents;
  final List<GroupNode> _groups;
  @override
  @JsonKey()
  List<GroupNode> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  final List<StudentNode> _independentStudents;
  @override
  @JsonKey()
  List<StudentNode> get independentStudents {
    if (_independentStudents is EqualUnmodifiableListView)
      return _independentStudents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_independentStudents);
  }

  @override
  String toString() {
    return 'ClassNode(id: $id, name: $name, totalStudents: $totalStudents, groups: $groups, independentStudents: $independentStudents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalStudents, totalStudents) ||
                other.totalStudents == totalStudents) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            const DeepCollectionEquality().equals(
              other._independentStudents,
              _independentStudents,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    totalStudents,
    const DeepCollectionEquality().hash(_groups),
    const DeepCollectionEquality().hash(_independentStudents),
  );

  /// Create a copy of ClassNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassNodeImplCopyWith<_$ClassNodeImpl> get copyWith =>
      __$$ClassNodeImplCopyWithImpl<_$ClassNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassNodeImplToJson(this);
  }
}

abstract class _ClassNode implements ClassNode {
  const factory _ClassNode({
    required final String id,
    required final String name,
    final int totalStudents,
    final List<GroupNode> groups,
    final List<StudentNode> independentStudents,
  }) = _$ClassNodeImpl;

  factory _ClassNode.fromJson(Map<String, dynamic> json) =
      _$ClassNodeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get totalStudents;
  @override
  List<GroupNode> get groups;
  @override
  List<StudentNode> get independentStudents;

  /// Create a copy of ClassNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassNodeImplCopyWith<_$ClassNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

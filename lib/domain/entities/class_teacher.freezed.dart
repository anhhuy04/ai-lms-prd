// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_teacher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClassTeacher _$ClassTeacherFromJson(Map<String, dynamic> json) {
  return _ClassTeacher.fromJson(json);
}

/// @nodoc
mixin _$ClassTeacher {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this ClassTeacher to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassTeacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassTeacherCopyWith<ClassTeacher> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassTeacherCopyWith<$Res> {
  factory $ClassTeacherCopyWith(
    ClassTeacher value,
    $Res Function(ClassTeacher) then,
  ) = _$ClassTeacherCopyWithImpl<$Res, ClassTeacher>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'teacher_id') String teacherId,
    String role,
  });
}

/// @nodoc
class _$ClassTeacherCopyWithImpl<$Res, $Val extends ClassTeacher>
    implements $ClassTeacherCopyWith<$Res> {
  _$ClassTeacherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassTeacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? teacherId = null,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassTeacherImplCopyWith<$Res>
    implements $ClassTeacherCopyWith<$Res> {
  factory _$$ClassTeacherImplCopyWith(
    _$ClassTeacherImpl value,
    $Res Function(_$ClassTeacherImpl) then,
  ) = __$$ClassTeacherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'teacher_id') String teacherId,
    String role,
  });
}

/// @nodoc
class __$$ClassTeacherImplCopyWithImpl<$Res>
    extends _$ClassTeacherCopyWithImpl<$Res, _$ClassTeacherImpl>
    implements _$$ClassTeacherImplCopyWith<$Res> {
  __$$ClassTeacherImplCopyWithImpl(
    _$ClassTeacherImpl _value,
    $Res Function(_$ClassTeacherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassTeacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? teacherId = null,
    Object? role = null,
  }) {
    return _then(
      _$ClassTeacherImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassTeacherImpl extends _ClassTeacher {
  const _$ClassTeacherImpl({
    required this.id,
    @JsonKey(name: 'class_id') required this.classId,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    this.role = 'teacher',
  }) : super._();

  factory _$ClassTeacherImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassTeacherImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey()
  final String role;

  @override
  String toString() {
    return 'ClassTeacher(id: $id, classId: $classId, teacherId: $teacherId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassTeacherImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, classId, teacherId, role);

  /// Create a copy of ClassTeacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassTeacherImplCopyWith<_$ClassTeacherImpl> get copyWith =>
      __$$ClassTeacherImplCopyWithImpl<_$ClassTeacherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassTeacherImplToJson(this);
  }
}

abstract class _ClassTeacher extends ClassTeacher {
  const factory _ClassTeacher({
    required final String id,
    @JsonKey(name: 'class_id') required final String classId,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    final String role,
  }) = _$ClassTeacherImpl;
  const _ClassTeacher._() : super._();

  factory _ClassTeacher.fromJson(Map<String, dynamic> json) =
      _$ClassTeacherImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  String get role;

  /// Create a copy of ClassTeacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassTeacherImplCopyWith<_$ClassTeacherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

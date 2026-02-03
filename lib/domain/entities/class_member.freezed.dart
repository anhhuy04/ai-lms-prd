// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClassMember _$ClassMemberFromJson(Map<String, dynamic> json) {
  return _ClassMember.fromJson(json);
}

/// @nodoc
mixin _$ClassMember {
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ClassMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassMemberCopyWith<ClassMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassMemberCopyWith<$Res> {
  factory $ClassMemberCopyWith(
    ClassMember value,
    $Res Function(ClassMember) then,
  ) = _$ClassMemberCopyWithImpl<$Res, ClassMember>;
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'student_id') String studentId,
    String status,
    String? role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$ClassMemberCopyWithImpl<$Res, $Val extends ClassMember>
    implements $ClassMemberCopyWith<$Res> {
  _$ClassMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? studentId = null,
    Object? status = null,
    Object? role = freezed,
    Object? joinedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassMemberImplCopyWith<$Res>
    implements $ClassMemberCopyWith<$Res> {
  factory _$$ClassMemberImplCopyWith(
    _$ClassMemberImpl value,
    $Res Function(_$ClassMemberImpl) then,
  ) = __$$ClassMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'student_id') String studentId,
    String status,
    String? role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$ClassMemberImplCopyWithImpl<$Res>
    extends _$ClassMemberCopyWithImpl<$Res, _$ClassMemberImpl>
    implements _$$ClassMemberImplCopyWith<$Res> {
  __$$ClassMemberImplCopyWithImpl(
    _$ClassMemberImpl _value,
    $Res Function(_$ClassMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? studentId = null,
    Object? status = null,
    Object? role = freezed,
    Object? joinedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ClassMemberImpl(
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassMemberImpl extends _ClassMember {
  const _$ClassMemberImpl({
    @JsonKey(name: 'class_id') required this.classId,
    @JsonKey(name: 'student_id') required this.studentId,
    this.status = 'pending',
    this.role,
    @JsonKey(name: 'joined_at') this.joinedAt,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _$ClassMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassMemberImplFromJson(json);

  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey()
  final String status;
  @override
  final String? role;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ClassMember(classId: $classId, studentId: $studentId, status: $status, role: $role, joinedAt: $joinedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassMemberImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    classId,
    studentId,
    status,
    role,
    joinedAt,
    createdAt,
  );

  /// Create a copy of ClassMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassMemberImplCopyWith<_$ClassMemberImpl> get copyWith =>
      __$$ClassMemberImplCopyWithImpl<_$ClassMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassMemberImplToJson(this);
  }
}

abstract class _ClassMember extends ClassMember {
  const factory _ClassMember({
    @JsonKey(name: 'class_id') required final String classId,
    @JsonKey(name: 'student_id') required final String studentId,
    final String status,
    final String? role,
    @JsonKey(name: 'joined_at') final DateTime? joinedAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$ClassMemberImpl;
  const _ClassMember._() : super._();

  factory _ClassMember.fromJson(Map<String, dynamic> json) =
      _$ClassMemberImpl.fromJson;

  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  String get status;
  @override
  String? get role;
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of ClassMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassMemberImplCopyWith<_$ClassMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

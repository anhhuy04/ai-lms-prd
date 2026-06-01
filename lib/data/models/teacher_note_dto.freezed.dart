// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_note_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherNoteDto _$TeacherNoteDtoFromJson(Map<String, dynamic> json) {
  return _TeacherNoteDto.fromJson(json);
}

/// @nodoc
mixin _$TeacherNoteDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_private')
  bool get isPrivate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherNoteDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherNoteDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherNoteDtoCopyWith<TeacherNoteDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherNoteDtoCopyWith<$Res> {
  factory $TeacherNoteDtoCopyWith(
    TeacherNoteDto value,
    $Res Function(TeacherNoteDto) then,
  ) = _$TeacherNoteDtoCopyWithImpl<$Res, TeacherNoteDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'student_id') String studentId,
    String content,
    @JsonKey(name: 'is_private') bool isPrivate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$TeacherNoteDtoCopyWithImpl<$Res, $Val extends TeacherNoteDto>
    implements $TeacherNoteDtoCopyWith<$Res> {
  _$TeacherNoteDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherNoteDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? studentId = null,
    Object? content = null,
    Object? isPrivate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherNoteDtoImplCopyWith<$Res>
    implements $TeacherNoteDtoCopyWith<$Res> {
  factory _$$TeacherNoteDtoImplCopyWith(
    _$TeacherNoteDtoImpl value,
    $Res Function(_$TeacherNoteDtoImpl) then,
  ) = __$$TeacherNoteDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'student_id') String studentId,
    String content,
    @JsonKey(name: 'is_private') bool isPrivate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$TeacherNoteDtoImplCopyWithImpl<$Res>
    extends _$TeacherNoteDtoCopyWithImpl<$Res, _$TeacherNoteDtoImpl>
    implements _$$TeacherNoteDtoImplCopyWith<$Res> {
  __$$TeacherNoteDtoImplCopyWithImpl(
    _$TeacherNoteDtoImpl _value,
    $Res Function(_$TeacherNoteDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherNoteDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? studentId = null,
    Object? content = null,
    Object? isPrivate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TeacherNoteDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherNoteDtoImpl extends _TeacherNoteDto {
  const _$TeacherNoteDtoImpl({
    required this.id,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    @JsonKey(name: 'student_id') required this.studentId,
    required this.content,
    @JsonKey(name: 'is_private') this.isPrivate = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : super._();

  factory _$TeacherNoteDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherNoteDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  final String content;
  @override
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TeacherNoteDto(id: $id, teacherId: $teacherId, studentId: $studentId, content: $content, isPrivate: $isPrivate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherNoteDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    teacherId,
    studentId,
    content,
    isPrivate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TeacherNoteDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherNoteDtoImplCopyWith<_$TeacherNoteDtoImpl> get copyWith =>
      __$$TeacherNoteDtoImplCopyWithImpl<_$TeacherNoteDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherNoteDtoImplToJson(this);
  }
}

abstract class _TeacherNoteDto extends TeacherNoteDto {
  const factory _TeacherNoteDto({
    required final String id,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    @JsonKey(name: 'student_id') required final String studentId,
    required final String content,
    @JsonKey(name: 'is_private') final bool isPrivate,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$TeacherNoteDtoImpl;
  const _TeacherNoteDto._() : super._();

  factory _TeacherNoteDto.fromJson(Map<String, dynamic> json) =
      _$TeacherNoteDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  String get content;
  @override
  @JsonKey(name: 'is_private')
  bool get isPrivate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of TeacherNoteDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherNoteDtoImplCopyWith<_$TeacherNoteDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TeacherNote {
  String get id => throw _privateConstructorUsedError;

  /// ID của giáo viên sở hữu ghi chú (teacher_notes.teacher_id)
  String get teacherId => throw _privateConstructorUsedError;

  /// ID của học sinh được ghi chú (teacher_notes.student_id)
  String get studentId => throw _privateConstructorUsedError;

  /// Nội dung ghi chú
  String get content => throw _privateConstructorUsedError;

  /// Ghi chú riêng tư (chỉ giáo viên thấy)
  bool get isPrivate => throw _privateConstructorUsedError;

  /// Thời điểm tạo ghi chú
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Thời điểm cập nhật gần nhất
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of TeacherNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherNoteCopyWith<TeacherNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherNoteCopyWith<$Res> {
  factory $TeacherNoteCopyWith(
    TeacherNote value,
    $Res Function(TeacherNote) then,
  ) = _$TeacherNoteCopyWithImpl<$Res, TeacherNote>;
  @useResult
  $Res call({
    String id,
    String teacherId,
    String studentId,
    String content,
    bool isPrivate,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TeacherNoteCopyWithImpl<$Res, $Val extends TeacherNote>
    implements $TeacherNoteCopyWith<$Res> {
  _$TeacherNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherNote
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
abstract class _$$TeacherNoteImplCopyWith<$Res>
    implements $TeacherNoteCopyWith<$Res> {
  factory _$$TeacherNoteImplCopyWith(
    _$TeacherNoteImpl value,
    $Res Function(_$TeacherNoteImpl) then,
  ) = __$$TeacherNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String teacherId,
    String studentId,
    String content,
    bool isPrivate,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TeacherNoteImplCopyWithImpl<$Res>
    extends _$TeacherNoteCopyWithImpl<$Res, _$TeacherNoteImpl>
    implements _$$TeacherNoteImplCopyWith<$Res> {
  __$$TeacherNoteImplCopyWithImpl(
    _$TeacherNoteImpl _value,
    $Res Function(_$TeacherNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherNote
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
      _$TeacherNoteImpl(
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

class _$TeacherNoteImpl implements _TeacherNote {
  const _$TeacherNoteImpl({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.content,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;

  /// ID của giáo viên sở hữu ghi chú (teacher_notes.teacher_id)
  @override
  final String teacherId;

  /// ID của học sinh được ghi chú (teacher_notes.student_id)
  @override
  final String studentId;

  /// Nội dung ghi chú
  @override
  final String content;

  /// Ghi chú riêng tư (chỉ giáo viên thấy)
  @override
  final bool isPrivate;

  /// Thời điểm tạo ghi chú
  @override
  final DateTime createdAt;

  /// Thời điểm cập nhật gần nhất
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TeacherNote(id: $id, teacherId: $teacherId, studentId: $studentId, content: $content, isPrivate: $isPrivate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherNoteImpl &&
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

  /// Create a copy of TeacherNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherNoteImplCopyWith<_$TeacherNoteImpl> get copyWith =>
      __$$TeacherNoteImplCopyWithImpl<_$TeacherNoteImpl>(this, _$identity);
}

abstract class _TeacherNote implements TeacherNote {
  const factory _TeacherNote({
    required final String id,
    required final String teacherId,
    required final String studentId,
    required final String content,
    required final bool isPrivate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TeacherNoteImpl;

  @override
  String get id;

  /// ID của giáo viên sở hữu ghi chú (teacher_notes.teacher_id)
  @override
  String get teacherId;

  /// ID của học sinh được ghi chú (teacher_notes.student_id)
  @override
  String get studentId;

  /// Nội dung ghi chú
  @override
  String get content;

  /// Ghi chú riêng tư (chỉ giáo viên thấy)
  @override
  bool get isPrivate;

  /// Thời điểm tạo ghi chú
  @override
  DateTime get createdAt;

  /// Thời điểm cập nhật gần nhất
  @override
  DateTime get updatedAt;

  /// Create a copy of TeacherNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherNoteImplCopyWith<_$TeacherNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

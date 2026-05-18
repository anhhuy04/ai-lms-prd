// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_vm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuestionVM {
  Question get question => throw _privateConstructorUsedError;
  bool get isOwn => throw _privateConstructorUsedError;
  bool get canEdit => throw _privateConstructorUsedError;
  bool get canDelete => throw _privateConstructorUsedError;
  bool get canSetGlobal => throw _privateConstructorUsedError;

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionVMCopyWith<QuestionVM> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionVMCopyWith<$Res> {
  factory $QuestionVMCopyWith(
    QuestionVM value,
    $Res Function(QuestionVM) then,
  ) = _$QuestionVMCopyWithImpl<$Res, QuestionVM>;
  @useResult
  $Res call({
    Question question,
    bool isOwn,
    bool canEdit,
    bool canDelete,
    bool canSetGlobal,
  });

  $QuestionCopyWith<$Res> get question;
}

/// @nodoc
class _$QuestionVMCopyWithImpl<$Res, $Val extends QuestionVM>
    implements $QuestionVMCopyWith<$Res> {
  _$QuestionVMCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? isOwn = null,
    Object? canEdit = null,
    Object? canDelete = null,
    Object? canSetGlobal = null,
  }) {
    return _then(
      _value.copyWith(
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as Question,
            isOwn: null == isOwn
                ? _value.isOwn
                : isOwn // ignore: cast_nullable_to_non_nullable
                      as bool,
            canEdit: null == canEdit
                ? _value.canEdit
                : canEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
            canDelete: null == canDelete
                ? _value.canDelete
                : canDelete // ignore: cast_nullable_to_non_nullable
                      as bool,
            canSetGlobal: null == canSetGlobal
                ? _value.canSetGlobal
                : canSetGlobal // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<$Res> get question {
    return $QuestionCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuestionVMImplCopyWith<$Res>
    implements $QuestionVMCopyWith<$Res> {
  factory _$$QuestionVMImplCopyWith(
    _$QuestionVMImpl value,
    $Res Function(_$QuestionVMImpl) then,
  ) = __$$QuestionVMImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Question question,
    bool isOwn,
    bool canEdit,
    bool canDelete,
    bool canSetGlobal,
  });

  @override
  $QuestionCopyWith<$Res> get question;
}

/// @nodoc
class __$$QuestionVMImplCopyWithImpl<$Res>
    extends _$QuestionVMCopyWithImpl<$Res, _$QuestionVMImpl>
    implements _$$QuestionVMImplCopyWith<$Res> {
  __$$QuestionVMImplCopyWithImpl(
    _$QuestionVMImpl _value,
    $Res Function(_$QuestionVMImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? isOwn = null,
    Object? canEdit = null,
    Object? canDelete = null,
    Object? canSetGlobal = null,
  }) {
    return _then(
      _$QuestionVMImpl(
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as Question,
        isOwn: null == isOwn
            ? _value.isOwn
            : isOwn // ignore: cast_nullable_to_non_nullable
                  as bool,
        canEdit: null == canEdit
            ? _value.canEdit
            : canEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
        canDelete: null == canDelete
            ? _value.canDelete
            : canDelete // ignore: cast_nullable_to_non_nullable
                  as bool,
        canSetGlobal: null == canSetGlobal
            ? _value.canSetGlobal
            : canSetGlobal // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$QuestionVMImpl implements _QuestionVM {
  const _$QuestionVMImpl({
    required this.question,
    required this.isOwn,
    required this.canEdit,
    required this.canDelete,
    required this.canSetGlobal,
  });

  @override
  final Question question;
  @override
  final bool isOwn;
  @override
  final bool canEdit;
  @override
  final bool canDelete;
  @override
  final bool canSetGlobal;

  @override
  String toString() {
    return 'QuestionVM(question: $question, isOwn: $isOwn, canEdit: $canEdit, canDelete: $canDelete, canSetGlobal: $canSetGlobal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionVMImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.isOwn, isOwn) || other.isOwn == isOwn) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            (identical(other.canDelete, canDelete) ||
                other.canDelete == canDelete) &&
            (identical(other.canSetGlobal, canSetGlobal) ||
                other.canSetGlobal == canSetGlobal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    question,
    isOwn,
    canEdit,
    canDelete,
    canSetGlobal,
  );

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionVMImplCopyWith<_$QuestionVMImpl> get copyWith =>
      __$$QuestionVMImplCopyWithImpl<_$QuestionVMImpl>(this, _$identity);
}

abstract class _QuestionVM implements QuestionVM {
  const factory _QuestionVM({
    required final Question question,
    required final bool isOwn,
    required final bool canEdit,
    required final bool canDelete,
    required final bool canSetGlobal,
  }) = _$QuestionVMImpl;

  @override
  Question get question;
  @override
  bool get isOwn;
  @override
  bool get canEdit;
  @override
  bool get canDelete;
  @override
  bool get canSetGlobal;

  /// Create a copy of QuestionVM
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionVMImplCopyWith<_$QuestionVMImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_choice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionChoice _$QuestionChoiceFromJson(Map<String, dynamic> json) {
  return _QuestionChoice.fromJson(json);
}

/// @nodoc
mixin _$QuestionChoice {
  /// Thứ tự lựa chọn trong câu hỏi (0..n).
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'question_id')
  String get questionId => throw _privateConstructorUsedError;

  /// JSON nội dung choice (text/image...)
  Map<String, dynamic> get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_correct')
  bool get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this QuestionChoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionChoiceCopyWith<QuestionChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionChoiceCopyWith<$Res> {
  factory $QuestionChoiceCopyWith(
    QuestionChoice value,
    $Res Function(QuestionChoice) then,
  ) = _$QuestionChoiceCopyWithImpl<$Res, QuestionChoice>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'question_id') String questionId,
    Map<String, dynamic> content,
    @JsonKey(name: 'is_correct') bool isCorrect,
  });
}

/// @nodoc
class _$QuestionChoiceCopyWithImpl<$Res, $Val extends QuestionChoice>
    implements $QuestionChoiceCopyWith<$Res> {
  _$QuestionChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? content = null,
    Object? isCorrect = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionChoiceImplCopyWith<$Res>
    implements $QuestionChoiceCopyWith<$Res> {
  factory _$$QuestionChoiceImplCopyWith(
    _$QuestionChoiceImpl value,
    $Res Function(_$QuestionChoiceImpl) then,
  ) = __$$QuestionChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'question_id') String questionId,
    Map<String, dynamic> content,
    @JsonKey(name: 'is_correct') bool isCorrect,
  });
}

/// @nodoc
class __$$QuestionChoiceImplCopyWithImpl<$Res>
    extends _$QuestionChoiceCopyWithImpl<$Res, _$QuestionChoiceImpl>
    implements _$$QuestionChoiceImplCopyWith<$Res> {
  __$$QuestionChoiceImplCopyWithImpl(
    _$QuestionChoiceImpl _value,
    $Res Function(_$QuestionChoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? content = null,
    Object? isCorrect = null,
  }) {
    return _then(
      _$QuestionChoiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionChoiceImpl implements _QuestionChoice {
  const _$QuestionChoiceImpl({
    required this.id,
    @JsonKey(name: 'question_id') required this.questionId,
    required final Map<String, dynamic> content,
    @JsonKey(name: 'is_correct') this.isCorrect = false,
  }) : _content = content;

  factory _$QuestionChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionChoiceImplFromJson(json);

  /// Thứ tự lựa chọn trong câu hỏi (0..n).
  @override
  final int id;
  @override
  @JsonKey(name: 'question_id')
  final String questionId;

  /// JSON nội dung choice (text/image...)
  final Map<String, dynamic> _content;

  /// JSON nội dung choice (text/image...)
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  @override
  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  @override
  String toString() {
    return 'QuestionChoice(id: $id, questionId: $questionId, content: $content, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionChoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    questionId,
    const DeepCollectionEquality().hash(_content),
    isCorrect,
  );

  /// Create a copy of QuestionChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionChoiceImplCopyWith<_$QuestionChoiceImpl> get copyWith =>
      __$$QuestionChoiceImplCopyWithImpl<_$QuestionChoiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionChoiceImplToJson(this);
  }
}

abstract class _QuestionChoice implements QuestionChoice {
  const factory _QuestionChoice({
    required final int id,
    @JsonKey(name: 'question_id') required final String questionId,
    required final Map<String, dynamic> content,
    @JsonKey(name: 'is_correct') final bool isCorrect,
  }) = _$QuestionChoiceImpl;

  factory _QuestionChoice.fromJson(Map<String, dynamic> json) =
      _$QuestionChoiceImpl.fromJson;

  /// Thứ tự lựa chọn trong câu hỏi (0..n).
  @override
  int get id;
  @override
  @JsonKey(name: 'question_id')
  String get questionId;

  /// JSON nội dung choice (text/image...)
  @override
  Map<String, dynamic> get content;
  @override
  @JsonKey(name: 'is_correct')
  bool get isCorrect;

  /// Create a copy of QuestionChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionChoiceImplCopyWith<_$QuestionChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

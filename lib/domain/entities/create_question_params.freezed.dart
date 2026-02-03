// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_question_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateQuestionParams _$CreateQuestionParamsFromJson(Map<String, dynamic> json) {
  return _CreateQuestionParams.fromJson(json);
}

/// @nodoc
mixin _$CreateQuestionParams {
  QuestionType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;
  Map<String, dynamic>? get answer => throw _privateConstructorUsedError;
  double get defaultPoints => throw _privateConstructorUsedError;
  int? get difficulty => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;

  /// Danh sách objective_ids để link vào `question_objectives`
  List<String>? get objectiveIds => throw _privateConstructorUsedError;

  /// Choices cho MCQ (id 0..n)
  List<Map<String, dynamic>>? get choices => throw _privateConstructorUsedError;

  /// Serializes this CreateQuestionParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateQuestionParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateQuestionParamsCopyWith<CreateQuestionParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateQuestionParamsCopyWith<$Res> {
  factory $CreateQuestionParamsCopyWith(
    CreateQuestionParams value,
    $Res Function(CreateQuestionParams) then,
  ) = _$CreateQuestionParamsCopyWithImpl<$Res, CreateQuestionParams>;
  @useResult
  $Res call({
    QuestionType type,
    Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    double defaultPoints,
    int? difficulty,
    List<String>? tags,
    bool isPublic,
    List<String>? objectiveIds,
    List<Map<String, dynamic>>? choices,
  });
}

/// @nodoc
class _$CreateQuestionParamsCopyWithImpl<
  $Res,
  $Val extends CreateQuestionParams
>
    implements $CreateQuestionParamsCopyWith<$Res> {
  _$CreateQuestionParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateQuestionParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? answer = freezed,
    Object? defaultPoints = null,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? isPublic = null,
    Object? objectiveIds = freezed,
    Object? choices = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as QuestionType,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            defaultPoints: null == defaultPoints
                ? _value.defaultPoints
                : defaultPoints // ignore: cast_nullable_to_non_nullable
                      as double,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            objectiveIds: freezed == objectiveIds
                ? _value.objectiveIds
                : objectiveIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            choices: freezed == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateQuestionParamsImplCopyWith<$Res>
    implements $CreateQuestionParamsCopyWith<$Res> {
  factory _$$CreateQuestionParamsImplCopyWith(
    _$CreateQuestionParamsImpl value,
    $Res Function(_$CreateQuestionParamsImpl) then,
  ) = __$$CreateQuestionParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    QuestionType type,
    Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    double defaultPoints,
    int? difficulty,
    List<String>? tags,
    bool isPublic,
    List<String>? objectiveIds,
    List<Map<String, dynamic>>? choices,
  });
}

/// @nodoc
class __$$CreateQuestionParamsImplCopyWithImpl<$Res>
    extends _$CreateQuestionParamsCopyWithImpl<$Res, _$CreateQuestionParamsImpl>
    implements _$$CreateQuestionParamsImplCopyWith<$Res> {
  __$$CreateQuestionParamsImplCopyWithImpl(
    _$CreateQuestionParamsImpl _value,
    $Res Function(_$CreateQuestionParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateQuestionParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? answer = freezed,
    Object? defaultPoints = null,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? isPublic = null,
    Object? objectiveIds = freezed,
    Object? choices = freezed,
  }) {
    return _then(
      _$CreateQuestionParamsImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as QuestionType,
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        answer: freezed == answer
            ? _value._answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        defaultPoints: null == defaultPoints
            ? _value.defaultPoints
            : defaultPoints // ignore: cast_nullable_to_non_nullable
                  as double,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        objectiveIds: freezed == objectiveIds
            ? _value._objectiveIds
            : objectiveIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        choices: freezed == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateQuestionParamsImpl implements _CreateQuestionParams {
  const _$CreateQuestionParamsImpl({
    required this.type,
    required final Map<String, dynamic> content,
    final Map<String, dynamic>? answer,
    this.defaultPoints = 1,
    this.difficulty,
    final List<String>? tags,
    this.isPublic = false,
    final List<String>? objectiveIds,
    final List<Map<String, dynamic>>? choices,
  }) : _content = content,
       _answer = answer,
       _tags = tags,
       _objectiveIds = objectiveIds,
       _choices = choices;

  factory _$CreateQuestionParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateQuestionParamsImplFromJson(json);

  @override
  final QuestionType type;
  final Map<String, dynamic> _content;
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  final Map<String, dynamic>? _answer;
  @override
  Map<String, dynamic>? get answer {
    final value = _answer;
    if (value == null) return null;
    if (_answer is EqualUnmodifiableMapView) return _answer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final double defaultPoints;
  @override
  final int? difficulty;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isPublic;

  /// Danh sách objective_ids để link vào `question_objectives`
  final List<String>? _objectiveIds;

  /// Danh sách objective_ids để link vào `question_objectives`
  @override
  List<String>? get objectiveIds {
    final value = _objectiveIds;
    if (value == null) return null;
    if (_objectiveIds is EqualUnmodifiableListView) return _objectiveIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Choices cho MCQ (id 0..n)
  final List<Map<String, dynamic>>? _choices;

  /// Choices cho MCQ (id 0..n)
  @override
  List<Map<String, dynamic>>? get choices {
    final value = _choices;
    if (value == null) return null;
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateQuestionParams(type: $type, content: $content, answer: $answer, defaultPoints: $defaultPoints, difficulty: $difficulty, tags: $tags, isPublic: $isPublic, objectiveIds: $objectiveIds, choices: $choices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateQuestionParamsImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            const DeepCollectionEquality().equals(other._answer, _answer) &&
            (identical(other.defaultPoints, defaultPoints) ||
                other.defaultPoints == defaultPoints) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            const DeepCollectionEquality().equals(
              other._objectiveIds,
              _objectiveIds,
            ) &&
            const DeepCollectionEquality().equals(other._choices, _choices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_content),
    const DeepCollectionEquality().hash(_answer),
    defaultPoints,
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    isPublic,
    const DeepCollectionEquality().hash(_objectiveIds),
    const DeepCollectionEquality().hash(_choices),
  );

  /// Create a copy of CreateQuestionParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateQuestionParamsImplCopyWith<_$CreateQuestionParamsImpl>
  get copyWith =>
      __$$CreateQuestionParamsImplCopyWithImpl<_$CreateQuestionParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateQuestionParamsImplToJson(this);
  }
}

abstract class _CreateQuestionParams implements CreateQuestionParams {
  const factory _CreateQuestionParams({
    required final QuestionType type,
    required final Map<String, dynamic> content,
    final Map<String, dynamic>? answer,
    final double defaultPoints,
    final int? difficulty,
    final List<String>? tags,
    final bool isPublic,
    final List<String>? objectiveIds,
    final List<Map<String, dynamic>>? choices,
  }) = _$CreateQuestionParamsImpl;

  factory _CreateQuestionParams.fromJson(Map<String, dynamic> json) =
      _$CreateQuestionParamsImpl.fromJson;

  @override
  QuestionType get type;
  @override
  Map<String, dynamic> get content;
  @override
  Map<String, dynamic>? get answer;
  @override
  double get defaultPoints;
  @override
  int? get difficulty;
  @override
  List<String>? get tags;
  @override
  bool get isPublic;

  /// Danh sách objective_ids để link vào `question_objectives`
  @override
  List<String>? get objectiveIds;

  /// Choices cho MCQ (id 0..n)
  @override
  List<Map<String, dynamic>>? get choices;

  /// Create a copy of CreateQuestionParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateQuestionParamsImplCopyWith<_$CreateQuestionParamsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

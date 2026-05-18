// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionDTO _$QuestionDTOFromJson(Map<String, dynamic> json) {
  return _QuestionDTO.fromJson(json);
}

/// @nodoc
mixin _$QuestionDTO {
  // multiple_choice | true_false | short_answer
  String get type =>
      throw _privateConstructorUsedError; // {"text": "Question text"} — DB questions.content jsonb
  Map<String, dynamic> get content =>
      throw _privateConstructorUsedError; // Choices for MC/TF questions; empty for short_answer
  List<ChoiceDTO> get choices =>
      throw _privateConstructorUsedError; // {"correct_index": 0} for MC, {"correct_text": "..."} for TF/SA
  Map<String, dynamic> get answer =>
      throw _privateConstructorUsedError; // INT 1-5 — matches questions.difficulty schema (NOT string 'medium')
  int get difficulty => throw _privateConstructorUsedError;
  List<String> get tags =>
      throw _privateConstructorUsedError; // Maps to questions.default_points
  int get defaultPoints =>
      throw _privateConstructorUsedError; // Question source — maps to questions.source enum column (migration 020).
  // Values: 'teacher' | 'ai_generated' | 'library' | 'imported' | 'system' | 'admin'.
  // Domain layer `QuestionSource` enum handles type-safety; DTO carries string.
  String get source => throw _privateConstructorUsedError;

  /// Serializes this QuestionDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionDTOCopyWith<QuestionDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionDTOCopyWith<$Res> {
  factory $QuestionDTOCopyWith(
    QuestionDTO value,
    $Res Function(QuestionDTO) then,
  ) = _$QuestionDTOCopyWithImpl<$Res, QuestionDTO>;
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> content,
    List<ChoiceDTO> choices,
    Map<String, dynamic> answer,
    int difficulty,
    List<String> tags,
    int defaultPoints,
    String source,
  });
}

/// @nodoc
class _$QuestionDTOCopyWithImpl<$Res, $Val extends QuestionDTO>
    implements $QuestionDTOCopyWith<$Res> {
  _$QuestionDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? choices = null,
    Object? answer = null,
    Object? difficulty = null,
    Object? tags = null,
    Object? defaultPoints = null,
    Object? source = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<ChoiceDTO>,
            answer: null == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            defaultPoints: null == defaultPoints
                ? _value.defaultPoints
                : defaultPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionDTOImplCopyWith<$Res>
    implements $QuestionDTOCopyWith<$Res> {
  factory _$$QuestionDTOImplCopyWith(
    _$QuestionDTOImpl value,
    $Res Function(_$QuestionDTOImpl) then,
  ) = __$$QuestionDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> content,
    List<ChoiceDTO> choices,
    Map<String, dynamic> answer,
    int difficulty,
    List<String> tags,
    int defaultPoints,
    String source,
  });
}

/// @nodoc
class __$$QuestionDTOImplCopyWithImpl<$Res>
    extends _$QuestionDTOCopyWithImpl<$Res, _$QuestionDTOImpl>
    implements _$$QuestionDTOImplCopyWith<$Res> {
  __$$QuestionDTOImplCopyWithImpl(
    _$QuestionDTOImpl _value,
    $Res Function(_$QuestionDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? choices = null,
    Object? answer = null,
    Object? difficulty = null,
    Object? tags = null,
    Object? defaultPoints = null,
    Object? source = null,
  }) {
    return _then(
      _$QuestionDTOImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<ChoiceDTO>,
        answer: null == answer
            ? _value._answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        defaultPoints: null == defaultPoints
            ? _value.defaultPoints
            : defaultPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionDTOImpl implements _QuestionDTO {
  const _$QuestionDTOImpl({
    this.type = 'multiple_choice',
    required final Map<String, dynamic> content,
    final List<ChoiceDTO> choices = const [],
    required final Map<String, dynamic> answer,
    this.difficulty = 3,
    final List<String> tags = const [],
    this.defaultPoints = 1,
    this.source = 'teacher',
  }) : _content = content,
       _choices = choices,
       _answer = answer,
       _tags = tags;

  factory _$QuestionDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionDTOImplFromJson(json);

  // multiple_choice | true_false | short_answer
  @override
  @JsonKey()
  final String type;
  // {"text": "Question text"} — DB questions.content jsonb
  final Map<String, dynamic> _content;
  // {"text": "Question text"} — DB questions.content jsonb
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  // Choices for MC/TF questions; empty for short_answer
  final List<ChoiceDTO> _choices;
  // Choices for MC/TF questions; empty for short_answer
  @override
  @JsonKey()
  List<ChoiceDTO> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  // {"correct_index": 0} for MC, {"correct_text": "..."} for TF/SA
  final Map<String, dynamic> _answer;
  // {"correct_index": 0} for MC, {"correct_text": "..."} for TF/SA
  @override
  Map<String, dynamic> get answer {
    if (_answer is EqualUnmodifiableMapView) return _answer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answer);
  }

  // INT 1-5 — matches questions.difficulty schema (NOT string 'medium')
  @override
  @JsonKey()
  final int difficulty;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // Maps to questions.default_points
  @override
  @JsonKey()
  final int defaultPoints;
  // Question source — maps to questions.source enum column (migration 020).
  // Values: 'teacher' | 'ai_generated' | 'library' | 'imported' | 'system' | 'admin'.
  // Domain layer `QuestionSource` enum handles type-safety; DTO carries string.
  @override
  @JsonKey()
  final String source;

  @override
  String toString() {
    return 'QuestionDTO(type: $type, content: $content, choices: $choices, answer: $answer, difficulty: $difficulty, tags: $tags, defaultPoints: $defaultPoints, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionDTOImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            const DeepCollectionEquality().equals(other._answer, _answer) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.defaultPoints, defaultPoints) ||
                other.defaultPoints == defaultPoints) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_content),
    const DeepCollectionEquality().hash(_choices),
    const DeepCollectionEquality().hash(_answer),
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    defaultPoints,
    source,
  );

  /// Create a copy of QuestionDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionDTOImplCopyWith<_$QuestionDTOImpl> get copyWith =>
      __$$QuestionDTOImplCopyWithImpl<_$QuestionDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionDTOImplToJson(this);
  }
}

abstract class _QuestionDTO implements QuestionDTO {
  const factory _QuestionDTO({
    final String type,
    required final Map<String, dynamic> content,
    final List<ChoiceDTO> choices,
    required final Map<String, dynamic> answer,
    final int difficulty,
    final List<String> tags,
    final int defaultPoints,
    final String source,
  }) = _$QuestionDTOImpl;

  factory _QuestionDTO.fromJson(Map<String, dynamic> json) =
      _$QuestionDTOImpl.fromJson;

  // multiple_choice | true_false | short_answer
  @override
  String get type; // {"text": "Question text"} — DB questions.content jsonb
  @override
  Map<String, dynamic> get content; // Choices for MC/TF questions; empty for short_answer
  @override
  List<ChoiceDTO> get choices; // {"correct_index": 0} for MC, {"correct_text": "..."} for TF/SA
  @override
  Map<String, dynamic> get answer; // INT 1-5 — matches questions.difficulty schema (NOT string 'medium')
  @override
  int get difficulty;
  @override
  List<String> get tags; // Maps to questions.default_points
  @override
  int get defaultPoints; // Question source — maps to questions.source enum column (migration 020).
  // Values: 'teacher' | 'ai_generated' | 'library' | 'imported' | 'system' | 'admin'.
  // Domain layer `QuestionSource` enum handles type-safety; DTO carries string.
  @override
  String get source;

  /// Create a copy of QuestionDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionDTOImplCopyWith<_$QuestionDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChoiceDTO _$ChoiceDTOFromJson(Map<String, dynamic> json) {
  return _ChoiceDTO.fromJson(json);
}

/// @nodoc
mixin _$ChoiceDTO {
  int get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this ChoiceDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChoiceDTOCopyWith<ChoiceDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoiceDTOCopyWith<$Res> {
  factory $ChoiceDTOCopyWith(ChoiceDTO value, $Res Function(ChoiceDTO) then) =
      _$ChoiceDTOCopyWithImpl<$Res, ChoiceDTO>;
  @useResult
  $Res call({int id, String text, bool isCorrect});
}

/// @nodoc
class _$ChoiceDTOCopyWithImpl<$Res, $Val extends ChoiceDTO>
    implements $ChoiceDTOCopyWith<$Res> {
  _$ChoiceDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ChoiceDTOImplCopyWith<$Res>
    implements $ChoiceDTOCopyWith<$Res> {
  factory _$$ChoiceDTOImplCopyWith(
    _$ChoiceDTOImpl value,
    $Res Function(_$ChoiceDTOImpl) then,
  ) = __$$ChoiceDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String text, bool isCorrect});
}

/// @nodoc
class __$$ChoiceDTOImplCopyWithImpl<$Res>
    extends _$ChoiceDTOCopyWithImpl<$Res, _$ChoiceDTOImpl>
    implements _$$ChoiceDTOImplCopyWith<$Res> {
  __$$ChoiceDTOImplCopyWithImpl(
    _$ChoiceDTOImpl _value,
    $Res Function(_$ChoiceDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
  }) {
    return _then(
      _$ChoiceDTOImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ChoiceDTOImpl implements _ChoiceDTO {
  const _$ChoiceDTOImpl({
    required this.id,
    required this.text,
    this.isCorrect = false,
  });

  factory _$ChoiceDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChoiceDTOImplFromJson(json);

  @override
  final int id;
  @override
  final String text;
  @override
  @JsonKey()
  final bool isCorrect;

  @override
  String toString() {
    return 'ChoiceDTO(id: $id, text: $text, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoiceDTOImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, isCorrect);

  /// Create a copy of ChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoiceDTOImplCopyWith<_$ChoiceDTOImpl> get copyWith =>
      __$$ChoiceDTOImplCopyWithImpl<_$ChoiceDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChoiceDTOImplToJson(this);
  }
}

abstract class _ChoiceDTO implements ChoiceDTO {
  const factory _ChoiceDTO({
    required final int id,
    required final String text,
    final bool isCorrect,
  }) = _$ChoiceDTOImpl;

  factory _ChoiceDTO.fromJson(Map<String, dynamic> json) =
      _$ChoiceDTOImpl.fromJson;

  @override
  int get id;
  @override
  String get text;
  @override
  bool get isCorrect;

  /// Create a copy of ChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoiceDTOImplCopyWith<_$ChoiceDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

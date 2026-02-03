// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String get authorId => throw _privateConstructorUsedError;

  /// Lưu trong DB là string (`questions.type`)
  @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
  QuestionType get type => throw _privateConstructorUsedError;

  /// JSON rich content (text/images/latex...) - giữ dạng Map để linh hoạt.
  Map<String, dynamic> get content => throw _privateConstructorUsedError;

  /// JSON đáp án (tuỳ type). Nullable.
  Map<String, dynamic>? get answer => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_points')
  double get defaultPoints => throw _privateConstructorUsedError;

  /// 1..5 (nullable)
  int? get difficulty => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'author_id') String authorId,
    @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
    QuestionType type,
    Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') double defaultPoints,
    int? difficulty,
    List<String>? tags,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? type = null,
    Object? content = null,
    Object? answer = freezed,
    Object? defaultPoints = null,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
    _$QuestionImpl value,
    $Res Function(_$QuestionImpl) then,
  ) = __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'author_id') String authorId,
    @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
    QuestionType type,
    Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') double defaultPoints,
    int? difficulty,
    List<String>? tags,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
    _$QuestionImpl _value,
    $Res Function(_$QuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? type = null,
    Object? content = null,
    Object? answer = freezed,
    Object? defaultPoints = null,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$QuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionImpl implements _Question {
  const _$QuestionImpl({
    required this.id,
    @JsonKey(name: 'author_id') required this.authorId,
    @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
    required this.type,
    required final Map<String, dynamic> content,
    final Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') this.defaultPoints = 1,
    this.difficulty,
    final List<String>? tags,
    @JsonKey(name: 'is_public') this.isPublic = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _content = content,
       _answer = answer,
       _tags = tags;

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'author_id')
  final String authorId;

  /// Lưu trong DB là string (`questions.type`)
  @override
  @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
  final QuestionType type;

  /// JSON rich content (text/images/latex...) - giữ dạng Map để linh hoạt.
  final Map<String, dynamic> _content;

  /// JSON rich content (text/images/latex...) - giữ dạng Map để linh hoạt.
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  /// JSON đáp án (tuỳ type). Nullable.
  final Map<String, dynamic>? _answer;

  /// JSON đáp án (tuỳ type). Nullable.
  @override
  Map<String, dynamic>? get answer {
    final value = _answer;
    if (value == null) return null;
    if (_answer is EqualUnmodifiableMapView) return _answer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'default_points')
  final double defaultPoints;

  /// 1..5 (nullable)
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
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Question(id: $id, authorId: $authorId, type: $type, content: $content, answer: $answer, defaultPoints: $defaultPoints, difficulty: $difficulty, tags: $tags, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
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
    authorId,
    type,
    const DeepCollectionEquality().hash(_content),
    const DeepCollectionEquality().hash(_answer),
    defaultPoints,
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    isPublic,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(this);
  }
}

abstract class _Question implements Question {
  const factory _Question({
    required final String id,
    @JsonKey(name: 'author_id') required final String authorId,
    @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
    required final QuestionType type,
    required final Map<String, dynamic> content,
    final Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') final double defaultPoints,
    final int? difficulty,
    final List<String>? tags,
    @JsonKey(name: 'is_public') final bool isPublic,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'author_id')
  String get authorId;

  /// Lưu trong DB là string (`questions.type`)
  @override
  @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
  QuestionType get type;

  /// JSON rich content (text/images/latex...) - giữ dạng Map để linh hoạt.
  @override
  Map<String, dynamic> get content;

  /// JSON đáp án (tuỳ type). Nullable.
  @override
  Map<String, dynamic>? get answer;
  @override
  @JsonKey(name: 'default_points')
  double get defaultPoints;

  /// 1..5 (nullable)
  @override
  int? get difficulty;
  @override
  List<String>? get tags;
  @override
  @JsonKey(name: 'is_public')
  bool get isPublic;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill_mastery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SkillMastery _$SkillMasteryFromJson(Map<String, dynamic> json) {
  return _SkillMastery.fromJson(json);
}

/// @nodoc
mixin _$SkillMastery {
  String get objectiveId => throw _privateConstructorUsedError;
  String get skillName => throw _privateConstructorUsedError;
  double get masteryLevel => throw _privateConstructorUsedError; // 0.0 - 1.0
  int get attempts => throw _privateConstructorUsedError;
  bool get isStrong =>
      throw _privateConstructorUsedError; // masteryLevel >= 0.7
  bool get isWeak => throw _privateConstructorUsedError; // masteryLevel < 0.4
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this SkillMastery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkillMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkillMasteryCopyWith<SkillMastery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkillMasteryCopyWith<$Res> {
  factory $SkillMasteryCopyWith(
    SkillMastery value,
    $Res Function(SkillMastery) then,
  ) = _$SkillMasteryCopyWithImpl<$Res, SkillMastery>;
  @useResult
  $Res call({
    String objectiveId,
    String skillName,
    double masteryLevel,
    int attempts,
    bool isStrong,
    bool isWeak,
    String? description,
  });
}

/// @nodoc
class _$SkillMasteryCopyWithImpl<$Res, $Val extends SkillMastery>
    implements $SkillMasteryCopyWith<$Res> {
  _$SkillMasteryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkillMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectiveId = null,
    Object? skillName = null,
    Object? masteryLevel = null,
    Object? attempts = null,
    Object? isStrong = null,
    Object? isWeak = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            objectiveId: null == objectiveId
                ? _value.objectiveId
                : objectiveId // ignore: cast_nullable_to_non_nullable
                      as String,
            skillName: null == skillName
                ? _value.skillName
                : skillName // ignore: cast_nullable_to_non_nullable
                      as String,
            masteryLevel: null == masteryLevel
                ? _value.masteryLevel
                : masteryLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            isStrong: null == isStrong
                ? _value.isStrong
                : isStrong // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWeak: null == isWeak
                ? _value.isWeak
                : isWeak // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SkillMasteryImplCopyWith<$Res>
    implements $SkillMasteryCopyWith<$Res> {
  factory _$$SkillMasteryImplCopyWith(
    _$SkillMasteryImpl value,
    $Res Function(_$SkillMasteryImpl) then,
  ) = __$$SkillMasteryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String objectiveId,
    String skillName,
    double masteryLevel,
    int attempts,
    bool isStrong,
    bool isWeak,
    String? description,
  });
}

/// @nodoc
class __$$SkillMasteryImplCopyWithImpl<$Res>
    extends _$SkillMasteryCopyWithImpl<$Res, _$SkillMasteryImpl>
    implements _$$SkillMasteryImplCopyWith<$Res> {
  __$$SkillMasteryImplCopyWithImpl(
    _$SkillMasteryImpl _value,
    $Res Function(_$SkillMasteryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SkillMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectiveId = null,
    Object? skillName = null,
    Object? masteryLevel = null,
    Object? attempts = null,
    Object? isStrong = null,
    Object? isWeak = null,
    Object? description = freezed,
  }) {
    return _then(
      _$SkillMasteryImpl(
        objectiveId: null == objectiveId
            ? _value.objectiveId
            : objectiveId // ignore: cast_nullable_to_non_nullable
                  as String,
        skillName: null == skillName
            ? _value.skillName
            : skillName // ignore: cast_nullable_to_non_nullable
                  as String,
        masteryLevel: null == masteryLevel
            ? _value.masteryLevel
            : masteryLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        isStrong: null == isStrong
            ? _value.isStrong
            : isStrong // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWeak: null == isWeak
            ? _value.isWeak
            : isWeak // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SkillMasteryImpl implements _SkillMastery {
  const _$SkillMasteryImpl({
    required this.objectiveId,
    required this.skillName,
    this.masteryLevel = 0.0,
    this.attempts = 0,
    this.isStrong = false,
    this.isWeak = false,
    this.description,
  });

  factory _$SkillMasteryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkillMasteryImplFromJson(json);

  @override
  final String objectiveId;
  @override
  final String skillName;
  @override
  @JsonKey()
  final double masteryLevel;
  // 0.0 - 1.0
  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final bool isStrong;
  // masteryLevel >= 0.7
  @override
  @JsonKey()
  final bool isWeak;
  // masteryLevel < 0.4
  @override
  final String? description;

  @override
  String toString() {
    return 'SkillMastery(objectiveId: $objectiveId, skillName: $skillName, masteryLevel: $masteryLevel, attempts: $attempts, isStrong: $isStrong, isWeak: $isWeak, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkillMasteryImpl &&
            (identical(other.objectiveId, objectiveId) ||
                other.objectiveId == objectiveId) &&
            (identical(other.skillName, skillName) ||
                other.skillName == skillName) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.isStrong, isStrong) ||
                other.isStrong == isStrong) &&
            (identical(other.isWeak, isWeak) || other.isWeak == isWeak) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    objectiveId,
    skillName,
    masteryLevel,
    attempts,
    isStrong,
    isWeak,
    description,
  );

  /// Create a copy of SkillMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkillMasteryImplCopyWith<_$SkillMasteryImpl> get copyWith =>
      __$$SkillMasteryImplCopyWithImpl<_$SkillMasteryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkillMasteryImplToJson(this);
  }
}

abstract class _SkillMastery implements SkillMastery {
  const factory _SkillMastery({
    required final String objectiveId,
    required final String skillName,
    final double masteryLevel,
    final int attempts,
    final bool isStrong,
    final bool isWeak,
    final String? description,
  }) = _$SkillMasteryImpl;

  factory _SkillMastery.fromJson(Map<String, dynamic> json) =
      _$SkillMasteryImpl.fromJson;

  @override
  String get objectiveId;
  @override
  String get skillName;
  @override
  double get masteryLevel; // 0.0 - 1.0
  @override
  int get attempts;
  @override
  bool get isStrong; // masteryLevel >= 0.7
  @override
  bool get isWeak; // masteryLevel < 0.4
  @override
  String? get description;

  /// Create a copy of SkillMastery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkillMasteryImplCopyWith<_$SkillMasteryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeepAnalysis _$DeepAnalysisFromJson(Map<String, dynamic> json) {
  return _DeepAnalysis.fromJson(json);
}

/// @nodoc
mixin _$DeepAnalysis {
  List<TagAccuracy> get tagAccuracies => throw _privateConstructorUsedError;
  Map<String, double> get difficultyScores =>
      throw _privateConstructorUsedError;
  Map<String, int> get timePerQuestion => throw _privateConstructorUsedError;
  List<String> get repeatedErrors => throw _privateConstructorUsedError;

  /// Serializes this DeepAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeepAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeepAnalysisCopyWith<DeepAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeepAnalysisCopyWith<$Res> {
  factory $DeepAnalysisCopyWith(
    DeepAnalysis value,
    $Res Function(DeepAnalysis) then,
  ) = _$DeepAnalysisCopyWithImpl<$Res, DeepAnalysis>;
  @useResult
  $Res call({
    List<TagAccuracy> tagAccuracies,
    Map<String, double> difficultyScores,
    Map<String, int> timePerQuestion,
    List<String> repeatedErrors,
  });
}

/// @nodoc
class _$DeepAnalysisCopyWithImpl<$Res, $Val extends DeepAnalysis>
    implements $DeepAnalysisCopyWith<$Res> {
  _$DeepAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeepAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagAccuracies = null,
    Object? difficultyScores = null,
    Object? timePerQuestion = null,
    Object? repeatedErrors = null,
  }) {
    return _then(
      _value.copyWith(
            tagAccuracies: null == tagAccuracies
                ? _value.tagAccuracies
                : tagAccuracies // ignore: cast_nullable_to_non_nullable
                      as List<TagAccuracy>,
            difficultyScores: null == difficultyScores
                ? _value.difficultyScores
                : difficultyScores // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            timePerQuestion: null == timePerQuestion
                ? _value.timePerQuestion
                : timePerQuestion // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            repeatedErrors: null == repeatedErrors
                ? _value.repeatedErrors
                : repeatedErrors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeepAnalysisImplCopyWith<$Res>
    implements $DeepAnalysisCopyWith<$Res> {
  factory _$$DeepAnalysisImplCopyWith(
    _$DeepAnalysisImpl value,
    $Res Function(_$DeepAnalysisImpl) then,
  ) = __$$DeepAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TagAccuracy> tagAccuracies,
    Map<String, double> difficultyScores,
    Map<String, int> timePerQuestion,
    List<String> repeatedErrors,
  });
}

/// @nodoc
class __$$DeepAnalysisImplCopyWithImpl<$Res>
    extends _$DeepAnalysisCopyWithImpl<$Res, _$DeepAnalysisImpl>
    implements _$$DeepAnalysisImplCopyWith<$Res> {
  __$$DeepAnalysisImplCopyWithImpl(
    _$DeepAnalysisImpl _value,
    $Res Function(_$DeepAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeepAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagAccuracies = null,
    Object? difficultyScores = null,
    Object? timePerQuestion = null,
    Object? repeatedErrors = null,
  }) {
    return _then(
      _$DeepAnalysisImpl(
        tagAccuracies: null == tagAccuracies
            ? _value._tagAccuracies
            : tagAccuracies // ignore: cast_nullable_to_non_nullable
                  as List<TagAccuracy>,
        difficultyScores: null == difficultyScores
            ? _value._difficultyScores
            : difficultyScores // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        timePerQuestion: null == timePerQuestion
            ? _value._timePerQuestion
            : timePerQuestion // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        repeatedErrors: null == repeatedErrors
            ? _value._repeatedErrors
            : repeatedErrors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeepAnalysisImpl implements _DeepAnalysis {
  const _$DeepAnalysisImpl({
    final List<TagAccuracy> tagAccuracies = const [],
    final Map<String, double> difficultyScores = const {},
    final Map<String, int> timePerQuestion = const {},
    final List<String> repeatedErrors = const [],
  }) : _tagAccuracies = tagAccuracies,
       _difficultyScores = difficultyScores,
       _timePerQuestion = timePerQuestion,
       _repeatedErrors = repeatedErrors;

  factory _$DeepAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeepAnalysisImplFromJson(json);

  final List<TagAccuracy> _tagAccuracies;
  @override
  @JsonKey()
  List<TagAccuracy> get tagAccuracies {
    if (_tagAccuracies is EqualUnmodifiableListView) return _tagAccuracies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagAccuracies);
  }

  final Map<String, double> _difficultyScores;
  @override
  @JsonKey()
  Map<String, double> get difficultyScores {
    if (_difficultyScores is EqualUnmodifiableMapView) return _difficultyScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyScores);
  }

  final Map<String, int> _timePerQuestion;
  @override
  @JsonKey()
  Map<String, int> get timePerQuestion {
    if (_timePerQuestion is EqualUnmodifiableMapView) return _timePerQuestion;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_timePerQuestion);
  }

  final List<String> _repeatedErrors;
  @override
  @JsonKey()
  List<String> get repeatedErrors {
    if (_repeatedErrors is EqualUnmodifiableListView) return _repeatedErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repeatedErrors);
  }

  @override
  String toString() {
    return 'DeepAnalysis(tagAccuracies: $tagAccuracies, difficultyScores: $difficultyScores, timePerQuestion: $timePerQuestion, repeatedErrors: $repeatedErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeepAnalysisImpl &&
            const DeepCollectionEquality().equals(
              other._tagAccuracies,
              _tagAccuracies,
            ) &&
            const DeepCollectionEquality().equals(
              other._difficultyScores,
              _difficultyScores,
            ) &&
            const DeepCollectionEquality().equals(
              other._timePerQuestion,
              _timePerQuestion,
            ) &&
            const DeepCollectionEquality().equals(
              other._repeatedErrors,
              _repeatedErrors,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_tagAccuracies),
    const DeepCollectionEquality().hash(_difficultyScores),
    const DeepCollectionEquality().hash(_timePerQuestion),
    const DeepCollectionEquality().hash(_repeatedErrors),
  );

  /// Create a copy of DeepAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeepAnalysisImplCopyWith<_$DeepAnalysisImpl> get copyWith =>
      __$$DeepAnalysisImplCopyWithImpl<_$DeepAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeepAnalysisImplToJson(this);
  }
}

abstract class _DeepAnalysis implements DeepAnalysis {
  const factory _DeepAnalysis({
    final List<TagAccuracy> tagAccuracies,
    final Map<String, double> difficultyScores,
    final Map<String, int> timePerQuestion,
    final List<String> repeatedErrors,
  }) = _$DeepAnalysisImpl;

  factory _DeepAnalysis.fromJson(Map<String, dynamic> json) =
      _$DeepAnalysisImpl.fromJson;

  @override
  List<TagAccuracy> get tagAccuracies;
  @override
  Map<String, double> get difficultyScores;
  @override
  Map<String, int> get timePerQuestion;
  @override
  List<String> get repeatedErrors;

  /// Create a copy of DeepAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeepAnalysisImplCopyWith<_$DeepAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TagAccuracy _$TagAccuracyFromJson(Map<String, dynamic> json) {
  return _TagAccuracy.fromJson(json);
}

/// @nodoc
mixin _$TagAccuracy {
  String get tag => throw _privateConstructorUsedError;
  double get accuracy => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;

  /// Serializes this TagAccuracy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagAccuracyCopyWith<TagAccuracy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagAccuracyCopyWith<$Res> {
  factory $TagAccuracyCopyWith(
    TagAccuracy value,
    $Res Function(TagAccuracy) then,
  ) = _$TagAccuracyCopyWithImpl<$Res, TagAccuracy>;
  @useResult
  $Res call({
    String tag,
    double accuracy,
    int totalQuestions,
    int correctAnswers,
  });
}

/// @nodoc
class _$TagAccuracyCopyWithImpl<$Res, $Val extends TagAccuracy>
    implements $TagAccuracyCopyWith<$Res> {
  _$TagAccuracyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
    Object? accuracy = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
  }) {
    return _then(
      _value.copyWith(
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as String,
            accuracy: null == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TagAccuracyImplCopyWith<$Res>
    implements $TagAccuracyCopyWith<$Res> {
  factory _$$TagAccuracyImplCopyWith(
    _$TagAccuracyImpl value,
    $Res Function(_$TagAccuracyImpl) then,
  ) = __$$TagAccuracyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tag,
    double accuracy,
    int totalQuestions,
    int correctAnswers,
  });
}

/// @nodoc
class __$$TagAccuracyImplCopyWithImpl<$Res>
    extends _$TagAccuracyCopyWithImpl<$Res, _$TagAccuracyImpl>
    implements _$$TagAccuracyImplCopyWith<$Res> {
  __$$TagAccuracyImplCopyWithImpl(
    _$TagAccuracyImpl _value,
    $Res Function(_$TagAccuracyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TagAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
    Object? accuracy = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
  }) {
    return _then(
      _$TagAccuracyImpl(
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as String,
        accuracy: null == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TagAccuracyImpl implements _TagAccuracy {
  const _$TagAccuracyImpl({
    required this.tag,
    required this.accuracy,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory _$TagAccuracyImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagAccuracyImplFromJson(json);

  @override
  final String tag;
  @override
  final double accuracy;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;

  @override
  String toString() {
    return 'TagAccuracy(tag: $tag, accuracy: $accuracy, totalQuestions: $totalQuestions, correctAnswers: $correctAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagAccuracyImpl &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tag, accuracy, totalQuestions, correctAnswers);

  /// Create a copy of TagAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagAccuracyImplCopyWith<_$TagAccuracyImpl> get copyWith =>
      __$$TagAccuracyImplCopyWithImpl<_$TagAccuracyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagAccuracyImplToJson(this);
  }
}

abstract class _TagAccuracy implements TagAccuracy {
  const factory _TagAccuracy({
    required final String tag,
    required final double accuracy,
    required final int totalQuestions,
    required final int correctAnswers,
  }) = _$TagAccuracyImpl;

  factory _TagAccuracy.fromJson(Map<String, dynamic> json) =
      _$TagAccuracyImpl.fromJson;

  @override
  String get tag;
  @override
  double get accuracy;
  @override
  int get totalQuestions;
  @override
  int get correctAnswers;

  /// Create a copy of TagAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagAccuracyImplCopyWith<_$TagAccuracyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

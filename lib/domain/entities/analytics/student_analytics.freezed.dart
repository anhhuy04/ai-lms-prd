// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentAnalytics _$StudentAnalyticsFromJson(Map<String, dynamic> json) {
  return _StudentAnalytics.fromJson(json);
}

/// @nodoc
mixin _$StudentAnalytics {
  BasicEngagementMetrics get basicMetrics => throw _privateConstructorUsedError;
  List<SkillMastery> get skillMasteries => throw _privateConstructorUsedError;
  List<GradeTrend> get gradeTrends => throw _privateConstructorUsedError;
  StrengthWeaknessAnalysis get strengthsWeaknesses =>
      throw _privateConstructorUsedError;
  ClassComparison get classComparison => throw _privateConstructorUsedError;

  /// Serializes this StudentAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentAnalyticsCopyWith<StudentAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentAnalyticsCopyWith<$Res> {
  factory $StudentAnalyticsCopyWith(
    StudentAnalytics value,
    $Res Function(StudentAnalytics) then,
  ) = _$StudentAnalyticsCopyWithImpl<$Res, StudentAnalytics>;
  @useResult
  $Res call({
    BasicEngagementMetrics basicMetrics,
    List<SkillMastery> skillMasteries,
    List<GradeTrend> gradeTrends,
    StrengthWeaknessAnalysis strengthsWeaknesses,
    ClassComparison classComparison,
  });

  $BasicEngagementMetricsCopyWith<$Res> get basicMetrics;
  $StrengthWeaknessAnalysisCopyWith<$Res> get strengthsWeaknesses;
  $ClassComparisonCopyWith<$Res> get classComparison;
}

/// @nodoc
class _$StudentAnalyticsCopyWithImpl<$Res, $Val extends StudentAnalytics>
    implements $StudentAnalyticsCopyWith<$Res> {
  _$StudentAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicMetrics = null,
    Object? skillMasteries = null,
    Object? gradeTrends = null,
    Object? strengthsWeaknesses = null,
    Object? classComparison = null,
  }) {
    return _then(
      _value.copyWith(
            basicMetrics: null == basicMetrics
                ? _value.basicMetrics
                : basicMetrics // ignore: cast_nullable_to_non_nullable
                      as BasicEngagementMetrics,
            skillMasteries: null == skillMasteries
                ? _value.skillMasteries
                : skillMasteries // ignore: cast_nullable_to_non_nullable
                      as List<SkillMastery>,
            gradeTrends: null == gradeTrends
                ? _value.gradeTrends
                : gradeTrends // ignore: cast_nullable_to_non_nullable
                      as List<GradeTrend>,
            strengthsWeaknesses: null == strengthsWeaknesses
                ? _value.strengthsWeaknesses
                : strengthsWeaknesses // ignore: cast_nullable_to_non_nullable
                      as StrengthWeaknessAnalysis,
            classComparison: null == classComparison
                ? _value.classComparison
                : classComparison // ignore: cast_nullable_to_non_nullable
                      as ClassComparison,
          )
          as $Val,
    );
  }

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BasicEngagementMetricsCopyWith<$Res> get basicMetrics {
    return $BasicEngagementMetricsCopyWith<$Res>(_value.basicMetrics, (value) {
      return _then(_value.copyWith(basicMetrics: value) as $Val);
    });
  }

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrengthWeaknessAnalysisCopyWith<$Res> get strengthsWeaknesses {
    return $StrengthWeaknessAnalysisCopyWith<$Res>(_value.strengthsWeaknesses, (
      value,
    ) {
      return _then(_value.copyWith(strengthsWeaknesses: value) as $Val);
    });
  }

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClassComparisonCopyWith<$Res> get classComparison {
    return $ClassComparisonCopyWith<$Res>(_value.classComparison, (value) {
      return _then(_value.copyWith(classComparison: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudentAnalyticsImplCopyWith<$Res>
    implements $StudentAnalyticsCopyWith<$Res> {
  factory _$$StudentAnalyticsImplCopyWith(
    _$StudentAnalyticsImpl value,
    $Res Function(_$StudentAnalyticsImpl) then,
  ) = __$$StudentAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BasicEngagementMetrics basicMetrics,
    List<SkillMastery> skillMasteries,
    List<GradeTrend> gradeTrends,
    StrengthWeaknessAnalysis strengthsWeaknesses,
    ClassComparison classComparison,
  });

  @override
  $BasicEngagementMetricsCopyWith<$Res> get basicMetrics;
  @override
  $StrengthWeaknessAnalysisCopyWith<$Res> get strengthsWeaknesses;
  @override
  $ClassComparisonCopyWith<$Res> get classComparison;
}

/// @nodoc
class __$$StudentAnalyticsImplCopyWithImpl<$Res>
    extends _$StudentAnalyticsCopyWithImpl<$Res, _$StudentAnalyticsImpl>
    implements _$$StudentAnalyticsImplCopyWith<$Res> {
  __$$StudentAnalyticsImplCopyWithImpl(
    _$StudentAnalyticsImpl _value,
    $Res Function(_$StudentAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicMetrics = null,
    Object? skillMasteries = null,
    Object? gradeTrends = null,
    Object? strengthsWeaknesses = null,
    Object? classComparison = null,
  }) {
    return _then(
      _$StudentAnalyticsImpl(
        basicMetrics: null == basicMetrics
            ? _value.basicMetrics
            : basicMetrics // ignore: cast_nullable_to_non_nullable
                  as BasicEngagementMetrics,
        skillMasteries: null == skillMasteries
            ? _value._skillMasteries
            : skillMasteries // ignore: cast_nullable_to_non_nullable
                  as List<SkillMastery>,
        gradeTrends: null == gradeTrends
            ? _value._gradeTrends
            : gradeTrends // ignore: cast_nullable_to_non_nullable
                  as List<GradeTrend>,
        strengthsWeaknesses: null == strengthsWeaknesses
            ? _value.strengthsWeaknesses
            : strengthsWeaknesses // ignore: cast_nullable_to_non_nullable
                  as StrengthWeaknessAnalysis,
        classComparison: null == classComparison
            ? _value.classComparison
            : classComparison // ignore: cast_nullable_to_non_nullable
                  as ClassComparison,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentAnalyticsImpl implements _StudentAnalytics {
  const _$StudentAnalyticsImpl({
    this.basicMetrics = const BasicEngagementMetrics(),
    final List<SkillMastery> skillMasteries = const [],
    final List<GradeTrend> gradeTrends = const [],
    this.strengthsWeaknesses = const StrengthWeaknessAnalysis(),
    this.classComparison = const ClassComparison(),
  }) : _skillMasteries = skillMasteries,
       _gradeTrends = gradeTrends;

  factory _$StudentAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentAnalyticsImplFromJson(json);

  @override
  @JsonKey()
  final BasicEngagementMetrics basicMetrics;
  final List<SkillMastery> _skillMasteries;
  @override
  @JsonKey()
  List<SkillMastery> get skillMasteries {
    if (_skillMasteries is EqualUnmodifiableListView) return _skillMasteries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skillMasteries);
  }

  final List<GradeTrend> _gradeTrends;
  @override
  @JsonKey()
  List<GradeTrend> get gradeTrends {
    if (_gradeTrends is EqualUnmodifiableListView) return _gradeTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradeTrends);
  }

  @override
  @JsonKey()
  final StrengthWeaknessAnalysis strengthsWeaknesses;
  @override
  @JsonKey()
  final ClassComparison classComparison;

  @override
  String toString() {
    return 'StudentAnalytics(basicMetrics: $basicMetrics, skillMasteries: $skillMasteries, gradeTrends: $gradeTrends, strengthsWeaknesses: $strengthsWeaknesses, classComparison: $classComparison)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentAnalyticsImpl &&
            (identical(other.basicMetrics, basicMetrics) ||
                other.basicMetrics == basicMetrics) &&
            const DeepCollectionEquality().equals(
              other._skillMasteries,
              _skillMasteries,
            ) &&
            const DeepCollectionEquality().equals(
              other._gradeTrends,
              _gradeTrends,
            ) &&
            (identical(other.strengthsWeaknesses, strengthsWeaknesses) ||
                other.strengthsWeaknesses == strengthsWeaknesses) &&
            (identical(other.classComparison, classComparison) ||
                other.classComparison == classComparison));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    basicMetrics,
    const DeepCollectionEquality().hash(_skillMasteries),
    const DeepCollectionEquality().hash(_gradeTrends),
    strengthsWeaknesses,
    classComparison,
  );

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentAnalyticsImplCopyWith<_$StudentAnalyticsImpl> get copyWith =>
      __$$StudentAnalyticsImplCopyWithImpl<_$StudentAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentAnalyticsImplToJson(this);
  }
}

abstract class _StudentAnalytics implements StudentAnalytics {
  const factory _StudentAnalytics({
    final BasicEngagementMetrics basicMetrics,
    final List<SkillMastery> skillMasteries,
    final List<GradeTrend> gradeTrends,
    final StrengthWeaknessAnalysis strengthsWeaknesses,
    final ClassComparison classComparison,
  }) = _$StudentAnalyticsImpl;

  factory _StudentAnalytics.fromJson(Map<String, dynamic> json) =
      _$StudentAnalyticsImpl.fromJson;

  @override
  BasicEngagementMetrics get basicMetrics;
  @override
  List<SkillMastery> get skillMasteries;
  @override
  List<GradeTrend> get gradeTrends;
  @override
  StrengthWeaknessAnalysis get strengthsWeaknesses;
  @override
  ClassComparison get classComparison;

  /// Create a copy of StudentAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentAnalyticsImplCopyWith<_$StudentAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BasicEngagementMetrics _$BasicEngagementMetricsFromJson(
  Map<String, dynamic> json,
) {
  return _BasicEngagementMetrics.fromJson(json);
}

/// @nodoc
mixin _$BasicEngagementMetrics {
  @JsonKey(name: 'avg_score')
  double get avgScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_time_rate')
  double get onTimeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_time_minutes')
  int get totalTimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'submission_count')
  int get submissionCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'trend_direction')
  TrendDirection? get trendDirection => throw _privateConstructorUsedError;

  /// Serializes this BasicEngagementMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BasicEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BasicEngagementMetricsCopyWith<BasicEngagementMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BasicEngagementMetricsCopyWith<$Res> {
  factory $BasicEngagementMetricsCopyWith(
    BasicEngagementMetrics value,
    $Res Function(BasicEngagementMetrics) then,
  ) = _$BasicEngagementMetricsCopyWithImpl<$Res, BasicEngagementMetrics>;
  @useResult
  $Res call({
    @JsonKey(name: 'avg_score') double avgScore,
    @JsonKey(name: 'on_time_rate') double onTimeRate,
    @JsonKey(name: 'total_time_minutes') int totalTimeMinutes,
    @JsonKey(name: 'submission_count') int submissionCount,
    @JsonKey(name: 'trend_direction') TrendDirection? trendDirection,
  });
}

/// @nodoc
class _$BasicEngagementMetricsCopyWithImpl<
  $Res,
  $Val extends BasicEngagementMetrics
>
    implements $BasicEngagementMetricsCopyWith<$Res> {
  _$BasicEngagementMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BasicEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgScore = null,
    Object? onTimeRate = null,
    Object? totalTimeMinutes = null,
    Object? submissionCount = null,
    Object? trendDirection = freezed,
  }) {
    return _then(
      _value.copyWith(
            avgScore: null == avgScore
                ? _value.avgScore
                : avgScore // ignore: cast_nullable_to_non_nullable
                      as double,
            onTimeRate: null == onTimeRate
                ? _value.onTimeRate
                : onTimeRate // ignore: cast_nullable_to_non_nullable
                      as double,
            totalTimeMinutes: null == totalTimeMinutes
                ? _value.totalTimeMinutes
                : totalTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            submissionCount: null == submissionCount
                ? _value.submissionCount
                : submissionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            trendDirection: freezed == trendDirection
                ? _value.trendDirection
                : trendDirection // ignore: cast_nullable_to_non_nullable
                      as TrendDirection?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BasicEngagementMetricsImplCopyWith<$Res>
    implements $BasicEngagementMetricsCopyWith<$Res> {
  factory _$$BasicEngagementMetricsImplCopyWith(
    _$BasicEngagementMetricsImpl value,
    $Res Function(_$BasicEngagementMetricsImpl) then,
  ) = __$$BasicEngagementMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'avg_score') double avgScore,
    @JsonKey(name: 'on_time_rate') double onTimeRate,
    @JsonKey(name: 'total_time_minutes') int totalTimeMinutes,
    @JsonKey(name: 'submission_count') int submissionCount,
    @JsonKey(name: 'trend_direction') TrendDirection? trendDirection,
  });
}

/// @nodoc
class __$$BasicEngagementMetricsImplCopyWithImpl<$Res>
    extends
        _$BasicEngagementMetricsCopyWithImpl<$Res, _$BasicEngagementMetricsImpl>
    implements _$$BasicEngagementMetricsImplCopyWith<$Res> {
  __$$BasicEngagementMetricsImplCopyWithImpl(
    _$BasicEngagementMetricsImpl _value,
    $Res Function(_$BasicEngagementMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BasicEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgScore = null,
    Object? onTimeRate = null,
    Object? totalTimeMinutes = null,
    Object? submissionCount = null,
    Object? trendDirection = freezed,
  }) {
    return _then(
      _$BasicEngagementMetricsImpl(
        avgScore: null == avgScore
            ? _value.avgScore
            : avgScore // ignore: cast_nullable_to_non_nullable
                  as double,
        onTimeRate: null == onTimeRate
            ? _value.onTimeRate
            : onTimeRate // ignore: cast_nullable_to_non_nullable
                  as double,
        totalTimeMinutes: null == totalTimeMinutes
            ? _value.totalTimeMinutes
            : totalTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        submissionCount: null == submissionCount
            ? _value.submissionCount
            : submissionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        trendDirection: freezed == trendDirection
            ? _value.trendDirection
            : trendDirection // ignore: cast_nullable_to_non_nullable
                  as TrendDirection?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BasicEngagementMetricsImpl implements _BasicEngagementMetrics {
  const _$BasicEngagementMetricsImpl({
    @JsonKey(name: 'avg_score') this.avgScore = 0,
    @JsonKey(name: 'on_time_rate') this.onTimeRate = 0,
    @JsonKey(name: 'total_time_minutes') this.totalTimeMinutes = 0,
    @JsonKey(name: 'submission_count') this.submissionCount = 0,
    @JsonKey(name: 'trend_direction') this.trendDirection,
  });

  factory _$BasicEngagementMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BasicEngagementMetricsImplFromJson(json);

  @override
  @JsonKey(name: 'avg_score')
  final double avgScore;
  @override
  @JsonKey(name: 'on_time_rate')
  final double onTimeRate;
  @override
  @JsonKey(name: 'total_time_minutes')
  final int totalTimeMinutes;
  @override
  @JsonKey(name: 'submission_count')
  final int submissionCount;
  @override
  @JsonKey(name: 'trend_direction')
  final TrendDirection? trendDirection;

  @override
  String toString() {
    return 'BasicEngagementMetrics(avgScore: $avgScore, onTimeRate: $onTimeRate, totalTimeMinutes: $totalTimeMinutes, submissionCount: $submissionCount, trendDirection: $trendDirection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BasicEngagementMetricsImpl &&
            (identical(other.avgScore, avgScore) ||
                other.avgScore == avgScore) &&
            (identical(other.onTimeRate, onTimeRate) ||
                other.onTimeRate == onTimeRate) &&
            (identical(other.totalTimeMinutes, totalTimeMinutes) ||
                other.totalTimeMinutes == totalTimeMinutes) &&
            (identical(other.submissionCount, submissionCount) ||
                other.submissionCount == submissionCount) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    avgScore,
    onTimeRate,
    totalTimeMinutes,
    submissionCount,
    trendDirection,
  );

  /// Create a copy of BasicEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BasicEngagementMetricsImplCopyWith<_$BasicEngagementMetricsImpl>
  get copyWith =>
      __$$BasicEngagementMetricsImplCopyWithImpl<_$BasicEngagementMetricsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BasicEngagementMetricsImplToJson(this);
  }
}

abstract class _BasicEngagementMetrics implements BasicEngagementMetrics {
  const factory _BasicEngagementMetrics({
    @JsonKey(name: 'avg_score') final double avgScore,
    @JsonKey(name: 'on_time_rate') final double onTimeRate,
    @JsonKey(name: 'total_time_minutes') final int totalTimeMinutes,
    @JsonKey(name: 'submission_count') final int submissionCount,
    @JsonKey(name: 'trend_direction') final TrendDirection? trendDirection,
  }) = _$BasicEngagementMetricsImpl;

  factory _BasicEngagementMetrics.fromJson(Map<String, dynamic> json) =
      _$BasicEngagementMetricsImpl.fromJson;

  @override
  @JsonKey(name: 'avg_score')
  double get avgScore;
  @override
  @JsonKey(name: 'on_time_rate')
  double get onTimeRate;
  @override
  @JsonKey(name: 'total_time_minutes')
  int get totalTimeMinutes;
  @override
  @JsonKey(name: 'submission_count')
  int get submissionCount;
  @override
  @JsonKey(name: 'trend_direction')
  TrendDirection? get trendDirection;

  /// Create a copy of BasicEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BasicEngagementMetricsImplCopyWith<_$BasicEngagementMetricsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

StrengthWeaknessAnalysis _$StrengthWeaknessAnalysisFromJson(
  Map<String, dynamic> json,
) {
  return _StrengthWeaknessAnalysis.fromJson(json);
}

/// @nodoc
mixin _$StrengthWeaknessAnalysis {
  List<SkillMastery> get strengths => throw _privateConstructorUsedError;
  List<SkillMastery> get weaknesses => throw _privateConstructorUsedError;

  /// Serializes this StrengthWeaknessAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrengthWeaknessAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrengthWeaknessAnalysisCopyWith<StrengthWeaknessAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrengthWeaknessAnalysisCopyWith<$Res> {
  factory $StrengthWeaknessAnalysisCopyWith(
    StrengthWeaknessAnalysis value,
    $Res Function(StrengthWeaknessAnalysis) then,
  ) = _$StrengthWeaknessAnalysisCopyWithImpl<$Res, StrengthWeaknessAnalysis>;
  @useResult
  $Res call({List<SkillMastery> strengths, List<SkillMastery> weaknesses});
}

/// @nodoc
class _$StrengthWeaknessAnalysisCopyWithImpl<
  $Res,
  $Val extends StrengthWeaknessAnalysis
>
    implements $StrengthWeaknessAnalysisCopyWith<$Res> {
  _$StrengthWeaknessAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrengthWeaknessAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? strengths = null, Object? weaknesses = null}) {
    return _then(
      _value.copyWith(
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<SkillMastery>,
            weaknesses: null == weaknesses
                ? _value.weaknesses
                : weaknesses // ignore: cast_nullable_to_non_nullable
                      as List<SkillMastery>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrengthWeaknessAnalysisImplCopyWith<$Res>
    implements $StrengthWeaknessAnalysisCopyWith<$Res> {
  factory _$$StrengthWeaknessAnalysisImplCopyWith(
    _$StrengthWeaknessAnalysisImpl value,
    $Res Function(_$StrengthWeaknessAnalysisImpl) then,
  ) = __$$StrengthWeaknessAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SkillMastery> strengths, List<SkillMastery> weaknesses});
}

/// @nodoc
class __$$StrengthWeaknessAnalysisImplCopyWithImpl<$Res>
    extends
        _$StrengthWeaknessAnalysisCopyWithImpl<
          $Res,
          _$StrengthWeaknessAnalysisImpl
        >
    implements _$$StrengthWeaknessAnalysisImplCopyWith<$Res> {
  __$$StrengthWeaknessAnalysisImplCopyWithImpl(
    _$StrengthWeaknessAnalysisImpl _value,
    $Res Function(_$StrengthWeaknessAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrengthWeaknessAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? strengths = null, Object? weaknesses = null}) {
    return _then(
      _$StrengthWeaknessAnalysisImpl(
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<SkillMastery>,
        weaknesses: null == weaknesses
            ? _value._weaknesses
            : weaknesses // ignore: cast_nullable_to_non_nullable
                  as List<SkillMastery>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrengthWeaknessAnalysisImpl implements _StrengthWeaknessAnalysis {
  const _$StrengthWeaknessAnalysisImpl({
    final List<SkillMastery> strengths = const [],
    final List<SkillMastery> weaknesses = const [],
  }) : _strengths = strengths,
       _weaknesses = weaknesses;

  factory _$StrengthWeaknessAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrengthWeaknessAnalysisImplFromJson(json);

  final List<SkillMastery> _strengths;
  @override
  @JsonKey()
  List<SkillMastery> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<SkillMastery> _weaknesses;
  @override
  @JsonKey()
  List<SkillMastery> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  @override
  String toString() {
    return 'StrengthWeaknessAnalysis(strengths: $strengths, weaknesses: $weaknesses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrengthWeaknessAnalysisImpl &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._weaknesses,
              _weaknesses,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_weaknesses),
  );

  /// Create a copy of StrengthWeaknessAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrengthWeaknessAnalysisImplCopyWith<_$StrengthWeaknessAnalysisImpl>
  get copyWith =>
      __$$StrengthWeaknessAnalysisImplCopyWithImpl<
        _$StrengthWeaknessAnalysisImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrengthWeaknessAnalysisImplToJson(this);
  }
}

abstract class _StrengthWeaknessAnalysis implements StrengthWeaknessAnalysis {
  const factory _StrengthWeaknessAnalysis({
    final List<SkillMastery> strengths,
    final List<SkillMastery> weaknesses,
  }) = _$StrengthWeaknessAnalysisImpl;

  factory _StrengthWeaknessAnalysis.fromJson(Map<String, dynamic> json) =
      _$StrengthWeaknessAnalysisImpl.fromJson;

  @override
  List<SkillMastery> get strengths;
  @override
  List<SkillMastery> get weaknesses;

  /// Create a copy of StrengthWeaknessAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrengthWeaknessAnalysisImplCopyWith<_$StrengthWeaknessAnalysisImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ClassComparison _$ClassComparisonFromJson(Map<String, dynamic> json) {
  return _ClassComparison.fromJson(json);
}

/// @nodoc
mixin _$ClassComparison {
  @JsonKey(name: 'class_average')
  double get classAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'percentile')
  double get percentile => throw _privateConstructorUsedError;
  @JsonKey(name: 'rank')
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_students')
  int get totalStudents => throw _privateConstructorUsedError;

  /// Serializes this ClassComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassComparisonCopyWith<ClassComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassComparisonCopyWith<$Res> {
  factory $ClassComparisonCopyWith(
    ClassComparison value,
    $Res Function(ClassComparison) then,
  ) = _$ClassComparisonCopyWithImpl<$Res, ClassComparison>;
  @useResult
  $Res call({
    @JsonKey(name: 'class_average') double classAverage,
    @JsonKey(name: 'percentile') double percentile,
    @JsonKey(name: 'rank') int rank,
    @JsonKey(name: 'total_students') int totalStudents,
  });
}

/// @nodoc
class _$ClassComparisonCopyWithImpl<$Res, $Val extends ClassComparison>
    implements $ClassComparisonCopyWith<$Res> {
  _$ClassComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classAverage = null,
    Object? percentile = null,
    Object? rank = null,
    Object? totalStudents = null,
  }) {
    return _then(
      _value.copyWith(
            classAverage: null == classAverage
                ? _value.classAverage
                : classAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            percentile: null == percentile
                ? _value.percentile
                : percentile // ignore: cast_nullable_to_non_nullable
                      as double,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStudents: null == totalStudents
                ? _value.totalStudents
                : totalStudents // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassComparisonImplCopyWith<$Res>
    implements $ClassComparisonCopyWith<$Res> {
  factory _$$ClassComparisonImplCopyWith(
    _$ClassComparisonImpl value,
    $Res Function(_$ClassComparisonImpl) then,
  ) = __$$ClassComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'class_average') double classAverage,
    @JsonKey(name: 'percentile') double percentile,
    @JsonKey(name: 'rank') int rank,
    @JsonKey(name: 'total_students') int totalStudents,
  });
}

/// @nodoc
class __$$ClassComparisonImplCopyWithImpl<$Res>
    extends _$ClassComparisonCopyWithImpl<$Res, _$ClassComparisonImpl>
    implements _$$ClassComparisonImplCopyWith<$Res> {
  __$$ClassComparisonImplCopyWithImpl(
    _$ClassComparisonImpl _value,
    $Res Function(_$ClassComparisonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classAverage = null,
    Object? percentile = null,
    Object? rank = null,
    Object? totalStudents = null,
  }) {
    return _then(
      _$ClassComparisonImpl(
        classAverage: null == classAverage
            ? _value.classAverage
            : classAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        percentile: null == percentile
            ? _value.percentile
            : percentile // ignore: cast_nullable_to_non_nullable
                  as double,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStudents: null == totalStudents
            ? _value.totalStudents
            : totalStudents // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassComparisonImpl implements _ClassComparison {
  const _$ClassComparisonImpl({
    @JsonKey(name: 'class_average') this.classAverage = 0.0,
    @JsonKey(name: 'percentile') this.percentile = 0.0,
    @JsonKey(name: 'rank') this.rank = 0,
    @JsonKey(name: 'total_students') this.totalStudents = 0,
  });

  factory _$ClassComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassComparisonImplFromJson(json);

  @override
  @JsonKey(name: 'class_average')
  final double classAverage;
  @override
  @JsonKey(name: 'percentile')
  final double percentile;
  @override
  @JsonKey(name: 'rank')
  final int rank;
  @override
  @JsonKey(name: 'total_students')
  final int totalStudents;

  @override
  String toString() {
    return 'ClassComparison(classAverage: $classAverage, percentile: $percentile, rank: $rank, totalStudents: $totalStudents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassComparisonImpl &&
            (identical(other.classAverage, classAverage) ||
                other.classAverage == classAverage) &&
            (identical(other.percentile, percentile) ||
                other.percentile == percentile) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.totalStudents, totalStudents) ||
                other.totalStudents == totalStudents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, classAverage, percentile, rank, totalStudents);

  /// Create a copy of ClassComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassComparisonImplCopyWith<_$ClassComparisonImpl> get copyWith =>
      __$$ClassComparisonImplCopyWithImpl<_$ClassComparisonImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassComparisonImplToJson(this);
  }
}

abstract class _ClassComparison implements ClassComparison {
  const factory _ClassComparison({
    @JsonKey(name: 'class_average') final double classAverage,
    @JsonKey(name: 'percentile') final double percentile,
    @JsonKey(name: 'rank') final int rank,
    @JsonKey(name: 'total_students') final int totalStudents,
  }) = _$ClassComparisonImpl;

  factory _ClassComparison.fromJson(Map<String, dynamic> json) =
      _$ClassComparisonImpl.fromJson;

  @override
  @JsonKey(name: 'class_average')
  double get classAverage;
  @override
  @JsonKey(name: 'percentile')
  double get percentile;
  @override
  @JsonKey(name: 'rank')
  int get rank;
  @override
  @JsonKey(name: 'total_students')
  int get totalStudents;

  /// Create a copy of ClassComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassComparisonImplCopyWith<_$ClassComparisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

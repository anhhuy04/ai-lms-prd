// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClassAnalytics _$ClassAnalyticsFromJson(Map<String, dynamic> json) {
  return _ClassAnalytics.fromJson(json);
}

/// @nodoc
mixin _$ClassAnalytics {
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_name')
  String get className => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_average')
  double get classAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_students')
  int get totalStudents => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_submissions')
  int get totalSubmissions => throw _privateConstructorUsedError;
  @JsonKey(name: 'submission_rate')
  double get submissionRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'late_submission_rate')
  double get lateSubmissionRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'late_submission_count')
  int get lateSubmissionCount => throw _privateConstructorUsedError;
  WorstOffender? get worstOffender => throw _privateConstructorUsedError;
  double? get highestScore => throw _privateConstructorUsedError;
  double? get lowestScore => throw _privateConstructorUsedError;
  List<ClassDistribution> get distribution =>
      throw _privateConstructorUsedError;
  List<SubjectDistribution> get subjectDistributions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'top_performers')
  List<StudentPerformance> get topPerformers =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'bottom_performers')
  List<StudentPerformance> get bottomPerformers =>
      throw _privateConstructorUsedError;

  /// Serializes this ClassAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassAnalyticsCopyWith<ClassAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassAnalyticsCopyWith<$Res> {
  factory $ClassAnalyticsCopyWith(
    ClassAnalytics value,
    $Res Function(ClassAnalytics) then,
  ) = _$ClassAnalyticsCopyWithImpl<$Res, ClassAnalytics>;
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'class_name') String className,
    @JsonKey(name: 'class_average') double classAverage,
    @JsonKey(name: 'total_students') int totalStudents,
    @JsonKey(name: 'total_submissions') int totalSubmissions,
    @JsonKey(name: 'submission_rate') double submissionRate,
    @JsonKey(name: 'late_submission_rate') double lateSubmissionRate,
    @JsonKey(name: 'late_submission_count') int lateSubmissionCount,
    WorstOffender? worstOffender,
    double? highestScore,
    double? lowestScore,
    List<ClassDistribution> distribution,
    List<SubjectDistribution> subjectDistributions,
    @JsonKey(name: 'top_performers') List<StudentPerformance> topPerformers,
    @JsonKey(name: 'bottom_performers')
    List<StudentPerformance> bottomPerformers,
  });

  $WorstOffenderCopyWith<$Res>? get worstOffender;
}

/// @nodoc
class _$ClassAnalyticsCopyWithImpl<$Res, $Val extends ClassAnalytics>
    implements $ClassAnalyticsCopyWith<$Res> {
  _$ClassAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? className = null,
    Object? classAverage = null,
    Object? totalStudents = null,
    Object? totalSubmissions = null,
    Object? submissionRate = null,
    Object? lateSubmissionRate = null,
    Object? lateSubmissionCount = null,
    Object? worstOffender = freezed,
    Object? highestScore = freezed,
    Object? lowestScore = freezed,
    Object? distribution = null,
    Object? subjectDistributions = null,
    Object? topPerformers = null,
    Object? bottomPerformers = null,
  }) {
    return _then(
      _value.copyWith(
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            className: null == className
                ? _value.className
                : className // ignore: cast_nullable_to_non_nullable
                      as String,
            classAverage: null == classAverage
                ? _value.classAverage
                : classAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            totalStudents: null == totalStudents
                ? _value.totalStudents
                : totalStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSubmissions: null == totalSubmissions
                ? _value.totalSubmissions
                : totalSubmissions // ignore: cast_nullable_to_non_nullable
                      as int,
            submissionRate: null == submissionRate
                ? _value.submissionRate
                : submissionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            lateSubmissionRate: null == lateSubmissionRate
                ? _value.lateSubmissionRate
                : lateSubmissionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            lateSubmissionCount: null == lateSubmissionCount
                ? _value.lateSubmissionCount
                : lateSubmissionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            worstOffender: freezed == worstOffender
                ? _value.worstOffender
                : worstOffender // ignore: cast_nullable_to_non_nullable
                      as WorstOffender?,
            highestScore: freezed == highestScore
                ? _value.highestScore
                : highestScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            lowestScore: freezed == lowestScore
                ? _value.lowestScore
                : lowestScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            distribution: null == distribution
                ? _value.distribution
                : distribution // ignore: cast_nullable_to_non_nullable
                      as List<ClassDistribution>,
            subjectDistributions: null == subjectDistributions
                ? _value.subjectDistributions
                : subjectDistributions // ignore: cast_nullable_to_non_nullable
                      as List<SubjectDistribution>,
            topPerformers: null == topPerformers
                ? _value.topPerformers
                : topPerformers // ignore: cast_nullable_to_non_nullable
                      as List<StudentPerformance>,
            bottomPerformers: null == bottomPerformers
                ? _value.bottomPerformers
                : bottomPerformers // ignore: cast_nullable_to_non_nullable
                      as List<StudentPerformance>,
          )
          as $Val,
    );
  }

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorstOffenderCopyWith<$Res>? get worstOffender {
    if (_value.worstOffender == null) {
      return null;
    }

    return $WorstOffenderCopyWith<$Res>(_value.worstOffender!, (value) {
      return _then(_value.copyWith(worstOffender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClassAnalyticsImplCopyWith<$Res>
    implements $ClassAnalyticsCopyWith<$Res> {
  factory _$$ClassAnalyticsImplCopyWith(
    _$ClassAnalyticsImpl value,
    $Res Function(_$ClassAnalyticsImpl) then,
  ) = __$$ClassAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'class_name') String className,
    @JsonKey(name: 'class_average') double classAverage,
    @JsonKey(name: 'total_students') int totalStudents,
    @JsonKey(name: 'total_submissions') int totalSubmissions,
    @JsonKey(name: 'submission_rate') double submissionRate,
    @JsonKey(name: 'late_submission_rate') double lateSubmissionRate,
    @JsonKey(name: 'late_submission_count') int lateSubmissionCount,
    WorstOffender? worstOffender,
    double? highestScore,
    double? lowestScore,
    List<ClassDistribution> distribution,
    List<SubjectDistribution> subjectDistributions,
    @JsonKey(name: 'top_performers') List<StudentPerformance> topPerformers,
    @JsonKey(name: 'bottom_performers')
    List<StudentPerformance> bottomPerformers,
  });

  @override
  $WorstOffenderCopyWith<$Res>? get worstOffender;
}

/// @nodoc
class __$$ClassAnalyticsImplCopyWithImpl<$Res>
    extends _$ClassAnalyticsCopyWithImpl<$Res, _$ClassAnalyticsImpl>
    implements _$$ClassAnalyticsImplCopyWith<$Res> {
  __$$ClassAnalyticsImplCopyWithImpl(
    _$ClassAnalyticsImpl _value,
    $Res Function(_$ClassAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? className = null,
    Object? classAverage = null,
    Object? totalStudents = null,
    Object? totalSubmissions = null,
    Object? submissionRate = null,
    Object? lateSubmissionRate = null,
    Object? lateSubmissionCount = null,
    Object? worstOffender = freezed,
    Object? highestScore = freezed,
    Object? lowestScore = freezed,
    Object? distribution = null,
    Object? subjectDistributions = null,
    Object? topPerformers = null,
    Object? bottomPerformers = null,
  }) {
    return _then(
      _$ClassAnalyticsImpl(
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        className: null == className
            ? _value.className
            : className // ignore: cast_nullable_to_non_nullable
                  as String,
        classAverage: null == classAverage
            ? _value.classAverage
            : classAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        totalStudents: null == totalStudents
            ? _value.totalStudents
            : totalStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSubmissions: null == totalSubmissions
            ? _value.totalSubmissions
            : totalSubmissions // ignore: cast_nullable_to_non_nullable
                  as int,
        submissionRate: null == submissionRate
            ? _value.submissionRate
            : submissionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        lateSubmissionRate: null == lateSubmissionRate
            ? _value.lateSubmissionRate
            : lateSubmissionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        lateSubmissionCount: null == lateSubmissionCount
            ? _value.lateSubmissionCount
            : lateSubmissionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        worstOffender: freezed == worstOffender
            ? _value.worstOffender
            : worstOffender // ignore: cast_nullable_to_non_nullable
                  as WorstOffender?,
        highestScore: freezed == highestScore
            ? _value.highestScore
            : highestScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        lowestScore: freezed == lowestScore
            ? _value.lowestScore
            : lowestScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        distribution: null == distribution
            ? _value._distribution
            : distribution // ignore: cast_nullable_to_non_nullable
                  as List<ClassDistribution>,
        subjectDistributions: null == subjectDistributions
            ? _value._subjectDistributions
            : subjectDistributions // ignore: cast_nullable_to_non_nullable
                  as List<SubjectDistribution>,
        topPerformers: null == topPerformers
            ? _value._topPerformers
            : topPerformers // ignore: cast_nullable_to_non_nullable
                  as List<StudentPerformance>,
        bottomPerformers: null == bottomPerformers
            ? _value._bottomPerformers
            : bottomPerformers // ignore: cast_nullable_to_non_nullable
                  as List<StudentPerformance>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassAnalyticsImpl implements _ClassAnalytics {
  const _$ClassAnalyticsImpl({
    @JsonKey(name: 'class_id') this.classId = '',
    @JsonKey(name: 'class_name') this.className = '',
    @JsonKey(name: 'class_average') this.classAverage = 0.0,
    @JsonKey(name: 'total_students') this.totalStudents = 0,
    @JsonKey(name: 'total_submissions') this.totalSubmissions = 0,
    @JsonKey(name: 'submission_rate') this.submissionRate = 0.0,
    @JsonKey(name: 'late_submission_rate') this.lateSubmissionRate = 0.0,
    @JsonKey(name: 'late_submission_count') this.lateSubmissionCount = 0,
    this.worstOffender,
    this.highestScore,
    this.lowestScore,
    final List<ClassDistribution> distribution = const [],
    final List<SubjectDistribution> subjectDistributions = const [],
    @JsonKey(name: 'top_performers')
    final List<StudentPerformance> topPerformers = const [],
    @JsonKey(name: 'bottom_performers')
    final List<StudentPerformance> bottomPerformers = const [],
  }) : _distribution = distribution,
       _subjectDistributions = subjectDistributions,
       _topPerformers = topPerformers,
       _bottomPerformers = bottomPerformers;

  factory _$ClassAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassAnalyticsImplFromJson(json);

  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'class_name')
  final String className;
  @override
  @JsonKey(name: 'class_average')
  final double classAverage;
  @override
  @JsonKey(name: 'total_students')
  final int totalStudents;
  @override
  @JsonKey(name: 'total_submissions')
  final int totalSubmissions;
  @override
  @JsonKey(name: 'submission_rate')
  final double submissionRate;
  @override
  @JsonKey(name: 'late_submission_rate')
  final double lateSubmissionRate;
  @override
  @JsonKey(name: 'late_submission_count')
  final int lateSubmissionCount;
  @override
  final WorstOffender? worstOffender;
  @override
  final double? highestScore;
  @override
  final double? lowestScore;
  final List<ClassDistribution> _distribution;
  @override
  @JsonKey()
  List<ClassDistribution> get distribution {
    if (_distribution is EqualUnmodifiableListView) return _distribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_distribution);
  }

  final List<SubjectDistribution> _subjectDistributions;
  @override
  @JsonKey()
  List<SubjectDistribution> get subjectDistributions {
    if (_subjectDistributions is EqualUnmodifiableListView)
      return _subjectDistributions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectDistributions);
  }

  final List<StudentPerformance> _topPerformers;
  @override
  @JsonKey(name: 'top_performers')
  List<StudentPerformance> get topPerformers {
    if (_topPerformers is EqualUnmodifiableListView) return _topPerformers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topPerformers);
  }

  final List<StudentPerformance> _bottomPerformers;
  @override
  @JsonKey(name: 'bottom_performers')
  List<StudentPerformance> get bottomPerformers {
    if (_bottomPerformers is EqualUnmodifiableListView)
      return _bottomPerformers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bottomPerformers);
  }

  @override
  String toString() {
    return 'ClassAnalytics(classId: $classId, className: $className, classAverage: $classAverage, totalStudents: $totalStudents, totalSubmissions: $totalSubmissions, submissionRate: $submissionRate, lateSubmissionRate: $lateSubmissionRate, lateSubmissionCount: $lateSubmissionCount, worstOffender: $worstOffender, highestScore: $highestScore, lowestScore: $lowestScore, distribution: $distribution, subjectDistributions: $subjectDistributions, topPerformers: $topPerformers, bottomPerformers: $bottomPerformers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassAnalyticsImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.classAverage, classAverage) ||
                other.classAverage == classAverage) &&
            (identical(other.totalStudents, totalStudents) ||
                other.totalStudents == totalStudents) &&
            (identical(other.totalSubmissions, totalSubmissions) ||
                other.totalSubmissions == totalSubmissions) &&
            (identical(other.submissionRate, submissionRate) ||
                other.submissionRate == submissionRate) &&
            (identical(other.lateSubmissionRate, lateSubmissionRate) ||
                other.lateSubmissionRate == lateSubmissionRate) &&
            (identical(other.lateSubmissionCount, lateSubmissionCount) ||
                other.lateSubmissionCount == lateSubmissionCount) &&
            (identical(other.worstOffender, worstOffender) ||
                other.worstOffender == worstOffender) &&
            (identical(other.highestScore, highestScore) ||
                other.highestScore == highestScore) &&
            (identical(other.lowestScore, lowestScore) ||
                other.lowestScore == lowestScore) &&
            const DeepCollectionEquality().equals(
              other._distribution,
              _distribution,
            ) &&
            const DeepCollectionEquality().equals(
              other._subjectDistributions,
              _subjectDistributions,
            ) &&
            const DeepCollectionEquality().equals(
              other._topPerformers,
              _topPerformers,
            ) &&
            const DeepCollectionEquality().equals(
              other._bottomPerformers,
              _bottomPerformers,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    classId,
    className,
    classAverage,
    totalStudents,
    totalSubmissions,
    submissionRate,
    lateSubmissionRate,
    lateSubmissionCount,
    worstOffender,
    highestScore,
    lowestScore,
    const DeepCollectionEquality().hash(_distribution),
    const DeepCollectionEquality().hash(_subjectDistributions),
    const DeepCollectionEquality().hash(_topPerformers),
    const DeepCollectionEquality().hash(_bottomPerformers),
  );

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassAnalyticsImplCopyWith<_$ClassAnalyticsImpl> get copyWith =>
      __$$ClassAnalyticsImplCopyWithImpl<_$ClassAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassAnalyticsImplToJson(this);
  }
}

abstract class _ClassAnalytics implements ClassAnalytics {
  const factory _ClassAnalytics({
    @JsonKey(name: 'class_id') final String classId,
    @JsonKey(name: 'class_name') final String className,
    @JsonKey(name: 'class_average') final double classAverage,
    @JsonKey(name: 'total_students') final int totalStudents,
    @JsonKey(name: 'total_submissions') final int totalSubmissions,
    @JsonKey(name: 'submission_rate') final double submissionRate,
    @JsonKey(name: 'late_submission_rate') final double lateSubmissionRate,
    @JsonKey(name: 'late_submission_count') final int lateSubmissionCount,
    final WorstOffender? worstOffender,
    final double? highestScore,
    final double? lowestScore,
    final List<ClassDistribution> distribution,
    final List<SubjectDistribution> subjectDistributions,
    @JsonKey(name: 'top_performers')
    final List<StudentPerformance> topPerformers,
    @JsonKey(name: 'bottom_performers')
    final List<StudentPerformance> bottomPerformers,
  }) = _$ClassAnalyticsImpl;

  factory _ClassAnalytics.fromJson(Map<String, dynamic> json) =
      _$ClassAnalyticsImpl.fromJson;

  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'class_name')
  String get className;
  @override
  @JsonKey(name: 'class_average')
  double get classAverage;
  @override
  @JsonKey(name: 'total_students')
  int get totalStudents;
  @override
  @JsonKey(name: 'total_submissions')
  int get totalSubmissions;
  @override
  @JsonKey(name: 'submission_rate')
  double get submissionRate;
  @override
  @JsonKey(name: 'late_submission_rate')
  double get lateSubmissionRate;
  @override
  @JsonKey(name: 'late_submission_count')
  int get lateSubmissionCount;
  @override
  WorstOffender? get worstOffender;
  @override
  double? get highestScore;
  @override
  double? get lowestScore;
  @override
  List<ClassDistribution> get distribution;
  @override
  List<SubjectDistribution> get subjectDistributions;
  @override
  @JsonKey(name: 'top_performers')
  List<StudentPerformance> get topPerformers;
  @override
  @JsonKey(name: 'bottom_performers')
  List<StudentPerformance> get bottomPerformers;

  /// Create a copy of ClassAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassAnalyticsImplCopyWith<_$ClassAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassDistribution _$ClassDistributionFromJson(Map<String, dynamic> json) {
  return _ClassDistribution.fromJson(json);
}

/// @nodoc
mixin _$ClassDistribution {
  int get rangeStart => throw _privateConstructorUsedError;
  int get rangeEnd => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this ClassDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassDistributionCopyWith<ClassDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassDistributionCopyWith<$Res> {
  factory $ClassDistributionCopyWith(
    ClassDistribution value,
    $Res Function(ClassDistribution) then,
  ) = _$ClassDistributionCopyWithImpl<$Res, ClassDistribution>;
  @useResult
  $Res call({int rangeStart, int rangeEnd, int count});
}

/// @nodoc
class _$ClassDistributionCopyWithImpl<$Res, $Val extends ClassDistribution>
    implements $ClassDistributionCopyWith<$Res> {
  _$ClassDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rangeStart = null,
    Object? rangeEnd = null,
    Object? count = null,
  }) {
    return _then(
      _value.copyWith(
            rangeStart: null == rangeStart
                ? _value.rangeStart
                : rangeStart // ignore: cast_nullable_to_non_nullable
                      as int,
            rangeEnd: null == rangeEnd
                ? _value.rangeEnd
                : rangeEnd // ignore: cast_nullable_to_non_nullable
                      as int,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassDistributionImplCopyWith<$Res>
    implements $ClassDistributionCopyWith<$Res> {
  factory _$$ClassDistributionImplCopyWith(
    _$ClassDistributionImpl value,
    $Res Function(_$ClassDistributionImpl) then,
  ) = __$$ClassDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rangeStart, int rangeEnd, int count});
}

/// @nodoc
class __$$ClassDistributionImplCopyWithImpl<$Res>
    extends _$ClassDistributionCopyWithImpl<$Res, _$ClassDistributionImpl>
    implements _$$ClassDistributionImplCopyWith<$Res> {
  __$$ClassDistributionImplCopyWithImpl(
    _$ClassDistributionImpl _value,
    $Res Function(_$ClassDistributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rangeStart = null,
    Object? rangeEnd = null,
    Object? count = null,
  }) {
    return _then(
      _$ClassDistributionImpl(
        rangeStart: null == rangeStart
            ? _value.rangeStart
            : rangeStart // ignore: cast_nullable_to_non_nullable
                  as int,
        rangeEnd: null == rangeEnd
            ? _value.rangeEnd
            : rangeEnd // ignore: cast_nullable_to_non_nullable
                  as int,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassDistributionImpl implements _ClassDistribution {
  const _$ClassDistributionImpl({
    this.rangeStart = 0,
    this.rangeEnd = 0,
    this.count = 0,
  });

  factory _$ClassDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassDistributionImplFromJson(json);

  @override
  @JsonKey()
  final int rangeStart;
  @override
  @JsonKey()
  final int rangeEnd;
  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'ClassDistribution(rangeStart: $rangeStart, rangeEnd: $rangeEnd, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassDistributionImpl &&
            (identical(other.rangeStart, rangeStart) ||
                other.rangeStart == rangeStart) &&
            (identical(other.rangeEnd, rangeEnd) ||
                other.rangeEnd == rangeEnd) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rangeStart, rangeEnd, count);

  /// Create a copy of ClassDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassDistributionImplCopyWith<_$ClassDistributionImpl> get copyWith =>
      __$$ClassDistributionImplCopyWithImpl<_$ClassDistributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassDistributionImplToJson(this);
  }
}

abstract class _ClassDistribution implements ClassDistribution {
  const factory _ClassDistribution({
    final int rangeStart,
    final int rangeEnd,
    final int count,
  }) = _$ClassDistributionImpl;

  factory _ClassDistribution.fromJson(Map<String, dynamic> json) =
      _$ClassDistributionImpl.fromJson;

  @override
  int get rangeStart;
  @override
  int get rangeEnd;
  @override
  int get count;

  /// Create a copy of ClassDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassDistributionImplCopyWith<_$ClassDistributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentPerformance _$StudentPerformanceFromJson(Map<String, dynamic> json) {
  return _StudentPerformance.fromJson(json);
}

/// @nodoc
mixin _$StudentPerformance {
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  int get submissionCount => throw _privateConstructorUsedError;

  /// Serializes this StudentPerformance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentPerformanceCopyWith<StudentPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentPerformanceCopyWith<$Res> {
  factory $StudentPerformanceCopyWith(
    StudentPerformance value,
    $Res Function(StudentPerformance) then,
  ) = _$StudentPerformanceCopyWithImpl<$Res, StudentPerformance>;
  @useResult
  $Res call({
    String studentId,
    String studentName,
    double score,
    int submissionCount,
  });
}

/// @nodoc
class _$StudentPerformanceCopyWithImpl<$Res, $Val extends StudentPerformance>
    implements $StudentPerformanceCopyWith<$Res> {
  _$StudentPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? score = null,
    Object? submissionCount = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            submissionCount: null == submissionCount
                ? _value.submissionCount
                : submissionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentPerformanceImplCopyWith<$Res>
    implements $StudentPerformanceCopyWith<$Res> {
  factory _$$StudentPerformanceImplCopyWith(
    _$StudentPerformanceImpl value,
    $Res Function(_$StudentPerformanceImpl) then,
  ) = __$$StudentPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String studentName,
    double score,
    int submissionCount,
  });
}

/// @nodoc
class __$$StudentPerformanceImplCopyWithImpl<$Res>
    extends _$StudentPerformanceCopyWithImpl<$Res, _$StudentPerformanceImpl>
    implements _$$StudentPerformanceImplCopyWith<$Res> {
  __$$StudentPerformanceImplCopyWithImpl(
    _$StudentPerformanceImpl _value,
    $Res Function(_$StudentPerformanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? score = null,
    Object? submissionCount = null,
  }) {
    return _then(
      _$StudentPerformanceImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        submissionCount: null == submissionCount
            ? _value.submissionCount
            : submissionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentPerformanceImpl implements _StudentPerformance {
  const _$StudentPerformanceImpl({
    required this.studentId,
    required this.studentName,
    required this.score,
    this.submissionCount = 0,
  });

  factory _$StudentPerformanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentPerformanceImplFromJson(json);

  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final double score;
  @override
  @JsonKey()
  final int submissionCount;

  @override
  String toString() {
    return 'StudentPerformance(studentId: $studentId, studentName: $studentName, score: $score, submissionCount: $submissionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentPerformanceImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.submissionCount, submissionCount) ||
                other.submissionCount == submissionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, studentId, studentName, score, submissionCount);

  /// Create a copy of StudentPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentPerformanceImplCopyWith<_$StudentPerformanceImpl> get copyWith =>
      __$$StudentPerformanceImplCopyWithImpl<_$StudentPerformanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentPerformanceImplToJson(this);
  }
}

abstract class _StudentPerformance implements StudentPerformance {
  const factory _StudentPerformance({
    required final String studentId,
    required final String studentName,
    required final double score,
    final int submissionCount,
  }) = _$StudentPerformanceImpl;

  factory _StudentPerformance.fromJson(Map<String, dynamic> json) =
      _$StudentPerformanceImpl.fromJson;

  @override
  String get studentId;
  @override
  String get studentName;
  @override
  double get score;
  @override
  int get submissionCount;

  /// Create a copy of StudentPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentPerformanceImplCopyWith<_$StudentPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorstOffender _$WorstOffenderFromJson(Map<String, dynamic> json) {
  return _WorstOffender.fromJson(json);
}

/// @nodoc
mixin _$WorstOffender {
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  int get lateCount => throw _privateConstructorUsedError;

  /// Serializes this WorstOffender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorstOffender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorstOffenderCopyWith<WorstOffender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorstOffenderCopyWith<$Res> {
  factory $WorstOffenderCopyWith(
    WorstOffender value,
    $Res Function(WorstOffender) then,
  ) = _$WorstOffenderCopyWithImpl<$Res, WorstOffender>;
  @useResult
  $Res call({String studentId, String studentName, int lateCount});
}

/// @nodoc
class _$WorstOffenderCopyWithImpl<$Res, $Val extends WorstOffender>
    implements $WorstOffenderCopyWith<$Res> {
  _$WorstOffenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorstOffender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? lateCount = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            lateCount: null == lateCount
                ? _value.lateCount
                : lateCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorstOffenderImplCopyWith<$Res>
    implements $WorstOffenderCopyWith<$Res> {
  factory _$$WorstOffenderImplCopyWith(
    _$WorstOffenderImpl value,
    $Res Function(_$WorstOffenderImpl) then,
  ) = __$$WorstOffenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String studentId, String studentName, int lateCount});
}

/// @nodoc
class __$$WorstOffenderImplCopyWithImpl<$Res>
    extends _$WorstOffenderCopyWithImpl<$Res, _$WorstOffenderImpl>
    implements _$$WorstOffenderImplCopyWith<$Res> {
  __$$WorstOffenderImplCopyWithImpl(
    _$WorstOffenderImpl _value,
    $Res Function(_$WorstOffenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorstOffender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? lateCount = null,
  }) {
    return _then(
      _$WorstOffenderImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        lateCount: null == lateCount
            ? _value.lateCount
            : lateCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorstOffenderImpl implements _WorstOffender {
  const _$WorstOffenderImpl({
    required this.studentId,
    required this.studentName,
    required this.lateCount,
  });

  factory _$WorstOffenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorstOffenderImplFromJson(json);

  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final int lateCount;

  @override
  String toString() {
    return 'WorstOffender(studentId: $studentId, studentName: $studentName, lateCount: $lateCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorstOffenderImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.lateCount, lateCount) ||
                other.lateCount == lateCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, studentId, studentName, lateCount);

  /// Create a copy of WorstOffender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorstOffenderImplCopyWith<_$WorstOffenderImpl> get copyWith =>
      __$$WorstOffenderImplCopyWithImpl<_$WorstOffenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorstOffenderImplToJson(this);
  }
}

abstract class _WorstOffender implements WorstOffender {
  const factory _WorstOffender({
    required final String studentId,
    required final String studentName,
    required final int lateCount,
  }) = _$WorstOffenderImpl;

  factory _WorstOffender.fromJson(Map<String, dynamic> json) =
      _$WorstOffenderImpl.fromJson;

  @override
  String get studentId;
  @override
  String get studentName;
  @override
  int get lateCount;

  /// Create a copy of WorstOffender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorstOffenderImplCopyWith<_$WorstOffenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubjectDistribution _$SubjectDistributionFromJson(Map<String, dynamic> json) {
  return _SubjectDistribution.fromJson(json);
}

/// @nodoc
mixin _$SubjectDistribution {
  String get subjectName => throw _privateConstructorUsedError;
  int get below50Count => throw _privateConstructorUsedError;
  int get below60Count => throw _privateConstructorUsedError;
  int get below80Count => throw _privateConstructorUsedError;
  int get above80Count => throw _privateConstructorUsedError;
  List<StudentScoreItem> get below50Students =>
      throw _privateConstructorUsedError;
  List<StudentScoreItem> get below60Students =>
      throw _privateConstructorUsedError;
  List<StudentScoreItem> get below80Students =>
      throw _privateConstructorUsedError;
  List<StudentScoreItem> get above80Students =>
      throw _privateConstructorUsedError;

  /// Serializes this SubjectDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectDistributionCopyWith<SubjectDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectDistributionCopyWith<$Res> {
  factory $SubjectDistributionCopyWith(
    SubjectDistribution value,
    $Res Function(SubjectDistribution) then,
  ) = _$SubjectDistributionCopyWithImpl<$Res, SubjectDistribution>;
  @useResult
  $Res call({
    String subjectName,
    int below50Count,
    int below60Count,
    int below80Count,
    int above80Count,
    List<StudentScoreItem> below50Students,
    List<StudentScoreItem> below60Students,
    List<StudentScoreItem> below80Students,
    List<StudentScoreItem> above80Students,
  });
}

/// @nodoc
class _$SubjectDistributionCopyWithImpl<$Res, $Val extends SubjectDistribution>
    implements $SubjectDistributionCopyWith<$Res> {
  _$SubjectDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? below50Count = null,
    Object? below60Count = null,
    Object? below80Count = null,
    Object? above80Count = null,
    Object? below50Students = null,
    Object? below60Students = null,
    Object? below80Students = null,
    Object? above80Students = null,
  }) {
    return _then(
      _value.copyWith(
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            below50Count: null == below50Count
                ? _value.below50Count
                : below50Count // ignore: cast_nullable_to_non_nullable
                      as int,
            below60Count: null == below60Count
                ? _value.below60Count
                : below60Count // ignore: cast_nullable_to_non_nullable
                      as int,
            below80Count: null == below80Count
                ? _value.below80Count
                : below80Count // ignore: cast_nullable_to_non_nullable
                      as int,
            above80Count: null == above80Count
                ? _value.above80Count
                : above80Count // ignore: cast_nullable_to_non_nullable
                      as int,
            below50Students: null == below50Students
                ? _value.below50Students
                : below50Students // ignore: cast_nullable_to_non_nullable
                      as List<StudentScoreItem>,
            below60Students: null == below60Students
                ? _value.below60Students
                : below60Students // ignore: cast_nullable_to_non_nullable
                      as List<StudentScoreItem>,
            below80Students: null == below80Students
                ? _value.below80Students
                : below80Students // ignore: cast_nullable_to_non_nullable
                      as List<StudentScoreItem>,
            above80Students: null == above80Students
                ? _value.above80Students
                : above80Students // ignore: cast_nullable_to_non_nullable
                      as List<StudentScoreItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectDistributionImplCopyWith<$Res>
    implements $SubjectDistributionCopyWith<$Res> {
  factory _$$SubjectDistributionImplCopyWith(
    _$SubjectDistributionImpl value,
    $Res Function(_$SubjectDistributionImpl) then,
  ) = __$$SubjectDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String subjectName,
    int below50Count,
    int below60Count,
    int below80Count,
    int above80Count,
    List<StudentScoreItem> below50Students,
    List<StudentScoreItem> below60Students,
    List<StudentScoreItem> below80Students,
    List<StudentScoreItem> above80Students,
  });
}

/// @nodoc
class __$$SubjectDistributionImplCopyWithImpl<$Res>
    extends _$SubjectDistributionCopyWithImpl<$Res, _$SubjectDistributionImpl>
    implements _$$SubjectDistributionImplCopyWith<$Res> {
  __$$SubjectDistributionImplCopyWithImpl(
    _$SubjectDistributionImpl _value,
    $Res Function(_$SubjectDistributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? below50Count = null,
    Object? below60Count = null,
    Object? below80Count = null,
    Object? above80Count = null,
    Object? below50Students = null,
    Object? below60Students = null,
    Object? below80Students = null,
    Object? above80Students = null,
  }) {
    return _then(
      _$SubjectDistributionImpl(
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        below50Count: null == below50Count
            ? _value.below50Count
            : below50Count // ignore: cast_nullable_to_non_nullable
                  as int,
        below60Count: null == below60Count
            ? _value.below60Count
            : below60Count // ignore: cast_nullable_to_non_nullable
                  as int,
        below80Count: null == below80Count
            ? _value.below80Count
            : below80Count // ignore: cast_nullable_to_non_nullable
                  as int,
        above80Count: null == above80Count
            ? _value.above80Count
            : above80Count // ignore: cast_nullable_to_non_nullable
                  as int,
        below50Students: null == below50Students
            ? _value._below50Students
            : below50Students // ignore: cast_nullable_to_non_nullable
                  as List<StudentScoreItem>,
        below60Students: null == below60Students
            ? _value._below60Students
            : below60Students // ignore: cast_nullable_to_non_nullable
                  as List<StudentScoreItem>,
        below80Students: null == below80Students
            ? _value._below80Students
            : below80Students // ignore: cast_nullable_to_non_nullable
                  as List<StudentScoreItem>,
        above80Students: null == above80Students
            ? _value._above80Students
            : above80Students // ignore: cast_nullable_to_non_nullable
                  as List<StudentScoreItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectDistributionImpl implements _SubjectDistribution {
  const _$SubjectDistributionImpl({
    required this.subjectName,
    this.below50Count = 0,
    this.below60Count = 0,
    this.below80Count = 0,
    this.above80Count = 0,
    final List<StudentScoreItem> below50Students = const [],
    final List<StudentScoreItem> below60Students = const [],
    final List<StudentScoreItem> below80Students = const [],
    final List<StudentScoreItem> above80Students = const [],
  }) : _below50Students = below50Students,
       _below60Students = below60Students,
       _below80Students = below80Students,
       _above80Students = above80Students;

  factory _$SubjectDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectDistributionImplFromJson(json);

  @override
  final String subjectName;
  @override
  @JsonKey()
  final int below50Count;
  @override
  @JsonKey()
  final int below60Count;
  @override
  @JsonKey()
  final int below80Count;
  @override
  @JsonKey()
  final int above80Count;
  final List<StudentScoreItem> _below50Students;
  @override
  @JsonKey()
  List<StudentScoreItem> get below50Students {
    if (_below50Students is EqualUnmodifiableListView) return _below50Students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_below50Students);
  }

  final List<StudentScoreItem> _below60Students;
  @override
  @JsonKey()
  List<StudentScoreItem> get below60Students {
    if (_below60Students is EqualUnmodifiableListView) return _below60Students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_below60Students);
  }

  final List<StudentScoreItem> _below80Students;
  @override
  @JsonKey()
  List<StudentScoreItem> get below80Students {
    if (_below80Students is EqualUnmodifiableListView) return _below80Students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_below80Students);
  }

  final List<StudentScoreItem> _above80Students;
  @override
  @JsonKey()
  List<StudentScoreItem> get above80Students {
    if (_above80Students is EqualUnmodifiableListView) return _above80Students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_above80Students);
  }

  @override
  String toString() {
    return 'SubjectDistribution(subjectName: $subjectName, below50Count: $below50Count, below60Count: $below60Count, below80Count: $below80Count, above80Count: $above80Count, below50Students: $below50Students, below60Students: $below60Students, below80Students: $below80Students, above80Students: $above80Students)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectDistributionImpl &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.below50Count, below50Count) ||
                other.below50Count == below50Count) &&
            (identical(other.below60Count, below60Count) ||
                other.below60Count == below60Count) &&
            (identical(other.below80Count, below80Count) ||
                other.below80Count == below80Count) &&
            (identical(other.above80Count, above80Count) ||
                other.above80Count == above80Count) &&
            const DeepCollectionEquality().equals(
              other._below50Students,
              _below50Students,
            ) &&
            const DeepCollectionEquality().equals(
              other._below60Students,
              _below60Students,
            ) &&
            const DeepCollectionEquality().equals(
              other._below80Students,
              _below80Students,
            ) &&
            const DeepCollectionEquality().equals(
              other._above80Students,
              _above80Students,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subjectName,
    below50Count,
    below60Count,
    below80Count,
    above80Count,
    const DeepCollectionEquality().hash(_below50Students),
    const DeepCollectionEquality().hash(_below60Students),
    const DeepCollectionEquality().hash(_below80Students),
    const DeepCollectionEquality().hash(_above80Students),
  );

  /// Create a copy of SubjectDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectDistributionImplCopyWith<_$SubjectDistributionImpl> get copyWith =>
      __$$SubjectDistributionImplCopyWithImpl<_$SubjectDistributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectDistributionImplToJson(this);
  }
}

abstract class _SubjectDistribution implements SubjectDistribution {
  const factory _SubjectDistribution({
    required final String subjectName,
    final int below50Count,
    final int below60Count,
    final int below80Count,
    final int above80Count,
    final List<StudentScoreItem> below50Students,
    final List<StudentScoreItem> below60Students,
    final List<StudentScoreItem> below80Students,
    final List<StudentScoreItem> above80Students,
  }) = _$SubjectDistributionImpl;

  factory _SubjectDistribution.fromJson(Map<String, dynamic> json) =
      _$SubjectDistributionImpl.fromJson;

  @override
  String get subjectName;
  @override
  int get below50Count;
  @override
  int get below60Count;
  @override
  int get below80Count;
  @override
  int get above80Count;
  @override
  List<StudentScoreItem> get below50Students;
  @override
  List<StudentScoreItem> get below60Students;
  @override
  List<StudentScoreItem> get below80Students;
  @override
  List<StudentScoreItem> get above80Students;

  /// Create a copy of SubjectDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectDistributionImplCopyWith<_$SubjectDistributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentScoreItem _$StudentScoreItemFromJson(Map<String, dynamic> json) {
  return _StudentScoreItem.fromJson(json);
}

/// @nodoc
mixin _$StudentScoreItem {
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this StudentScoreItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentScoreItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentScoreItemCopyWith<StudentScoreItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentScoreItemCopyWith<$Res> {
  factory $StudentScoreItemCopyWith(
    StudentScoreItem value,
    $Res Function(StudentScoreItem) then,
  ) = _$StudentScoreItemCopyWithImpl<$Res, StudentScoreItem>;
  @useResult
  $Res call({String studentId, String studentName, double score});
}

/// @nodoc
class _$StudentScoreItemCopyWithImpl<$Res, $Val extends StudentScoreItem>
    implements $StudentScoreItemCopyWith<$Res> {
  _$StudentScoreItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentScoreItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? score = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentScoreItemImplCopyWith<$Res>
    implements $StudentScoreItemCopyWith<$Res> {
  factory _$$StudentScoreItemImplCopyWith(
    _$StudentScoreItemImpl value,
    $Res Function(_$StudentScoreItemImpl) then,
  ) = __$$StudentScoreItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String studentId, String studentName, double score});
}

/// @nodoc
class __$$StudentScoreItemImplCopyWithImpl<$Res>
    extends _$StudentScoreItemCopyWithImpl<$Res, _$StudentScoreItemImpl>
    implements _$$StudentScoreItemImplCopyWith<$Res> {
  __$$StudentScoreItemImplCopyWithImpl(
    _$StudentScoreItemImpl _value,
    $Res Function(_$StudentScoreItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentScoreItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? score = null,
  }) {
    return _then(
      _$StudentScoreItemImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentScoreItemImpl implements _StudentScoreItem {
  const _$StudentScoreItemImpl({
    required this.studentId,
    required this.studentName,
    required this.score,
  });

  factory _$StudentScoreItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentScoreItemImplFromJson(json);

  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final double score;

  @override
  String toString() {
    return 'StudentScoreItem(studentId: $studentId, studentName: $studentName, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentScoreItemImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, studentId, studentName, score);

  /// Create a copy of StudentScoreItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentScoreItemImplCopyWith<_$StudentScoreItemImpl> get copyWith =>
      __$$StudentScoreItemImplCopyWithImpl<_$StudentScoreItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentScoreItemImplToJson(this);
  }
}

abstract class _StudentScoreItem implements StudentScoreItem {
  const factory _StudentScoreItem({
    required final String studentId,
    required final String studentName,
    required final double score,
  }) = _$StudentScoreItemImpl;

  factory _StudentScoreItem.fromJson(Map<String, dynamic> json) =
      _$StudentScoreItemImpl.fromJson;

  @override
  String get studentId;
  @override
  String get studentName;
  @override
  double get score;

  /// Create a copy of StudentScoreItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentScoreItemImplCopyWith<_$StudentScoreItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

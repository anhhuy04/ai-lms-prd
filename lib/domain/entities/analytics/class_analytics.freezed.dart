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
  List<ClassDistribution> get distribution =>
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
    List<ClassDistribution> distribution,
    @JsonKey(name: 'top_performers') List<StudentPerformance> topPerformers,
    @JsonKey(name: 'bottom_performers')
    List<StudentPerformance> bottomPerformers,
  });
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
    Object? distribution = null,
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
            distribution: null == distribution
                ? _value.distribution
                : distribution // ignore: cast_nullable_to_non_nullable
                      as List<ClassDistribution>,
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
    List<ClassDistribution> distribution,
    @JsonKey(name: 'top_performers') List<StudentPerformance> topPerformers,
    @JsonKey(name: 'bottom_performers')
    List<StudentPerformance> bottomPerformers,
  });
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
    Object? distribution = null,
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
        distribution: null == distribution
            ? _value._distribution
            : distribution // ignore: cast_nullable_to_non_nullable
                  as List<ClassDistribution>,
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
    final List<ClassDistribution> distribution = const [],
    @JsonKey(name: 'top_performers')
    final List<StudentPerformance> topPerformers = const [],
    @JsonKey(name: 'bottom_performers')
    final List<StudentPerformance> bottomPerformers = const [],
  }) : _distribution = distribution,
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
  final List<ClassDistribution> _distribution;
  @override
  @JsonKey()
  List<ClassDistribution> get distribution {
    if (_distribution is EqualUnmodifiableListView) return _distribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_distribution);
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
    return 'ClassAnalytics(classId: $classId, className: $className, classAverage: $classAverage, totalStudents: $totalStudents, totalSubmissions: $totalSubmissions, submissionRate: $submissionRate, distribution: $distribution, topPerformers: $topPerformers, bottomPerformers: $bottomPerformers)';
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
            const DeepCollectionEquality().equals(
              other._distribution,
              _distribution,
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
    const DeepCollectionEquality().hash(_distribution),
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
    final List<ClassDistribution> distribution,
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
  List<ClassDistribution> get distribution;
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

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade_trend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GradeTrend _$GradeTrendFromJson(Map<String, dynamic> json) {
  return _GradeTrend.fromJson(json);
}

/// @nodoc
mixin _$GradeTrend {
  DateTime get date => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get assignmentName => throw _privateConstructorUsedError;
  String? get assignmentId => throw _privateConstructorUsedError;

  /// Serializes this GradeTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GradeTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GradeTrendCopyWith<GradeTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradeTrendCopyWith<$Res> {
  factory $GradeTrendCopyWith(
    GradeTrend value,
    $Res Function(GradeTrend) then,
  ) = _$GradeTrendCopyWithImpl<$Res, GradeTrend>;
  @useResult
  $Res call({
    DateTime date,
    double score,
    String assignmentName,
    String? assignmentId,
  });
}

/// @nodoc
class _$GradeTrendCopyWithImpl<$Res, $Val extends GradeTrend>
    implements $GradeTrendCopyWith<$Res> {
  _$GradeTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GradeTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? score = null,
    Object? assignmentName = null,
    Object? assignmentId = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            assignmentName: null == assignmentName
                ? _value.assignmentName
                : assignmentName // ignore: cast_nullable_to_non_nullable
                      as String,
            assignmentId: freezed == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GradeTrendImplCopyWith<$Res>
    implements $GradeTrendCopyWith<$Res> {
  factory _$$GradeTrendImplCopyWith(
    _$GradeTrendImpl value,
    $Res Function(_$GradeTrendImpl) then,
  ) = __$$GradeTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    double score,
    String assignmentName,
    String? assignmentId,
  });
}

/// @nodoc
class __$$GradeTrendImplCopyWithImpl<$Res>
    extends _$GradeTrendCopyWithImpl<$Res, _$GradeTrendImpl>
    implements _$$GradeTrendImplCopyWith<$Res> {
  __$$GradeTrendImplCopyWithImpl(
    _$GradeTrendImpl _value,
    $Res Function(_$GradeTrendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GradeTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? score = null,
    Object? assignmentName = null,
    Object? assignmentId = freezed,
  }) {
    return _then(
      _$GradeTrendImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        assignmentName: null == assignmentName
            ? _value.assignmentName
            : assignmentName // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentId: freezed == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GradeTrendImpl implements _GradeTrend {
  const _$GradeTrendImpl({
    required this.date,
    required this.score,
    required this.assignmentName,
    this.assignmentId,
  });

  factory _$GradeTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradeTrendImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double score;
  @override
  final String assignmentName;
  @override
  final String? assignmentId;

  @override
  String toString() {
    return 'GradeTrend(date: $date, score: $score, assignmentName: $assignmentName, assignmentId: $assignmentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradeTrendImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.assignmentName, assignmentName) ||
                other.assignmentName == assignmentName) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, score, assignmentName, assignmentId);

  /// Create a copy of GradeTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GradeTrendImplCopyWith<_$GradeTrendImpl> get copyWith =>
      __$$GradeTrendImplCopyWithImpl<_$GradeTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradeTrendImplToJson(this);
  }
}

abstract class _GradeTrend implements GradeTrend {
  const factory _GradeTrend({
    required final DateTime date,
    required final double score,
    required final String assignmentName,
    final String? assignmentId,
  }) = _$GradeTrendImpl;

  factory _GradeTrend.fromJson(Map<String, dynamic> json) =
      _$GradeTrendImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get score;
  @override
  String get assignmentName;
  @override
  String? get assignmentId;

  /// Create a copy of GradeTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GradeTrendImplCopyWith<_$GradeTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

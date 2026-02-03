// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_assignment_hub_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherAssignmentHubState _$TeacherAssignmentHubStateFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherAssignmentHubState.fromJson(json);
}

/// @nodoc
mixin _$TeacherAssignmentHubState {
  AssignmentStatistics get statistics => throw _privateConstructorUsedError;
  List<Assignment> get recentActivities => throw _privateConstructorUsedError;

  /// Serializes this TeacherAssignmentHubState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherAssignmentHubStateCopyWith<TeacherAssignmentHubState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherAssignmentHubStateCopyWith<$Res> {
  factory $TeacherAssignmentHubStateCopyWith(
    TeacherAssignmentHubState value,
    $Res Function(TeacherAssignmentHubState) then,
  ) = _$TeacherAssignmentHubStateCopyWithImpl<$Res, TeacherAssignmentHubState>;
  @useResult
  $Res call({
    AssignmentStatistics statistics,
    List<Assignment> recentActivities,
  });

  $AssignmentStatisticsCopyWith<$Res> get statistics;
}

/// @nodoc
class _$TeacherAssignmentHubStateCopyWithImpl<
  $Res,
  $Val extends TeacherAssignmentHubState
>
    implements $TeacherAssignmentHubStateCopyWith<$Res> {
  _$TeacherAssignmentHubStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statistics = null, Object? recentActivities = null}) {
    return _then(
      _value.copyWith(
            statistics: null == statistics
                ? _value.statistics
                : statistics // ignore: cast_nullable_to_non_nullable
                      as AssignmentStatistics,
            recentActivities: null == recentActivities
                ? _value.recentActivities
                : recentActivities // ignore: cast_nullable_to_non_nullable
                      as List<Assignment>,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssignmentStatisticsCopyWith<$Res> get statistics {
    return $AssignmentStatisticsCopyWith<$Res>(_value.statistics, (value) {
      return _then(_value.copyWith(statistics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherAssignmentHubStateImplCopyWith<$Res>
    implements $TeacherAssignmentHubStateCopyWith<$Res> {
  factory _$$TeacherAssignmentHubStateImplCopyWith(
    _$TeacherAssignmentHubStateImpl value,
    $Res Function(_$TeacherAssignmentHubStateImpl) then,
  ) = __$$TeacherAssignmentHubStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AssignmentStatistics statistics,
    List<Assignment> recentActivities,
  });

  @override
  $AssignmentStatisticsCopyWith<$Res> get statistics;
}

/// @nodoc
class __$$TeacherAssignmentHubStateImplCopyWithImpl<$Res>
    extends
        _$TeacherAssignmentHubStateCopyWithImpl<
          $Res,
          _$TeacherAssignmentHubStateImpl
        >
    implements _$$TeacherAssignmentHubStateImplCopyWith<$Res> {
  __$$TeacherAssignmentHubStateImplCopyWithImpl(
    _$TeacherAssignmentHubStateImpl _value,
    $Res Function(_$TeacherAssignmentHubStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statistics = null, Object? recentActivities = null}) {
    return _then(
      _$TeacherAssignmentHubStateImpl(
        statistics: null == statistics
            ? _value.statistics
            : statistics // ignore: cast_nullable_to_non_nullable
                  as AssignmentStatistics,
        recentActivities: null == recentActivities
            ? _value._recentActivities
            : recentActivities // ignore: cast_nullable_to_non_nullable
                  as List<Assignment>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherAssignmentHubStateImpl implements _TeacherAssignmentHubState {
  const _$TeacherAssignmentHubStateImpl({
    required this.statistics,
    required final List<Assignment> recentActivities,
  }) : _recentActivities = recentActivities;

  factory _$TeacherAssignmentHubStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherAssignmentHubStateImplFromJson(json);

  @override
  final AssignmentStatistics statistics;
  final List<Assignment> _recentActivities;
  @override
  List<Assignment> get recentActivities {
    if (_recentActivities is EqualUnmodifiableListView)
      return _recentActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivities);
  }

  @override
  String toString() {
    return 'TeacherAssignmentHubState(statistics: $statistics, recentActivities: $recentActivities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherAssignmentHubStateImpl &&
            (identical(other.statistics, statistics) ||
                other.statistics == statistics) &&
            const DeepCollectionEquality().equals(
              other._recentActivities,
              _recentActivities,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    statistics,
    const DeepCollectionEquality().hash(_recentActivities),
  );

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherAssignmentHubStateImplCopyWith<_$TeacherAssignmentHubStateImpl>
  get copyWith =>
      __$$TeacherAssignmentHubStateImplCopyWithImpl<
        _$TeacherAssignmentHubStateImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherAssignmentHubStateImplToJson(this);
  }
}

abstract class _TeacherAssignmentHubState implements TeacherAssignmentHubState {
  const factory _TeacherAssignmentHubState({
    required final AssignmentStatistics statistics,
    required final List<Assignment> recentActivities,
  }) = _$TeacherAssignmentHubStateImpl;

  factory _TeacherAssignmentHubState.fromJson(Map<String, dynamic> json) =
      _$TeacherAssignmentHubStateImpl.fromJson;

  @override
  AssignmentStatistics get statistics;
  @override
  List<Assignment> get recentActivities;

  /// Create a copy of TeacherAssignmentHubState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherAssignmentHubStateImplCopyWith<_$TeacherAssignmentHubStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

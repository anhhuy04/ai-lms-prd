// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignmentStatistics _$AssignmentStatisticsFromJson(Map<String, dynamic> json) {
  return _AssignmentStatistics.fromJson(json);
}

/// @nodoc
mixin _$AssignmentStatistics {
  @JsonKey(name: 'total_assignments')
  int get totalAssignments => throw _privateConstructorUsedError;
  @JsonKey(name: 'ungraded_assignments')
  int get ungradedAssignments => throw _privateConstructorUsedError;
  @JsonKey(name: 'creating_count')
  int get creatingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'distributing_count')
  int get distributingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'waiting_to_assign')
  int get waitingToAssign => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned')
  int get assigned => throw _privateConstructorUsedError;
  @JsonKey(name: 'in_progress')
  int get inProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'ungraded')
  int get ungraded => throw _privateConstructorUsedError;
  @JsonKey(name: 'graded')
  int get graded => throw _privateConstructorUsedError;

  /// Serializes this AssignmentStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentStatisticsCopyWith<AssignmentStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentStatisticsCopyWith<$Res> {
  factory $AssignmentStatisticsCopyWith(
    AssignmentStatistics value,
    $Res Function(AssignmentStatistics) then,
  ) = _$AssignmentStatisticsCopyWithImpl<$Res, AssignmentStatistics>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_assignments') int totalAssignments,
    @JsonKey(name: 'ungraded_assignments') int ungradedAssignments,
    @JsonKey(name: 'creating_count') int creatingCount,
    @JsonKey(name: 'distributing_count') int distributingCount,
    @JsonKey(name: 'waiting_to_assign') int waitingToAssign,
    @JsonKey(name: 'assigned') int assigned,
    @JsonKey(name: 'in_progress') int inProgress,
    @JsonKey(name: 'ungraded') int ungraded,
    @JsonKey(name: 'graded') int graded,
  });
}

/// @nodoc
class _$AssignmentStatisticsCopyWithImpl<
  $Res,
  $Val extends AssignmentStatistics
>
    implements $AssignmentStatisticsCopyWith<$Res> {
  _$AssignmentStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAssignments = null,
    Object? ungradedAssignments = null,
    Object? creatingCount = null,
    Object? distributingCount = null,
    Object? waitingToAssign = null,
    Object? assigned = null,
    Object? inProgress = null,
    Object? ungraded = null,
    Object? graded = null,
  }) {
    return _then(
      _value.copyWith(
            totalAssignments: null == totalAssignments
                ? _value.totalAssignments
                : totalAssignments // ignore: cast_nullable_to_non_nullable
                      as int,
            ungradedAssignments: null == ungradedAssignments
                ? _value.ungradedAssignments
                : ungradedAssignments // ignore: cast_nullable_to_non_nullable
                      as int,
            creatingCount: null == creatingCount
                ? _value.creatingCount
                : creatingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            distributingCount: null == distributingCount
                ? _value.distributingCount
                : distributingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            waitingToAssign: null == waitingToAssign
                ? _value.waitingToAssign
                : waitingToAssign // ignore: cast_nullable_to_non_nullable
                      as int,
            assigned: null == assigned
                ? _value.assigned
                : assigned // ignore: cast_nullable_to_non_nullable
                      as int,
            inProgress: null == inProgress
                ? _value.inProgress
                : inProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            ungraded: null == ungraded
                ? _value.ungraded
                : ungraded // ignore: cast_nullable_to_non_nullable
                      as int,
            graded: null == graded
                ? _value.graded
                : graded // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentStatisticsImplCopyWith<$Res>
    implements $AssignmentStatisticsCopyWith<$Res> {
  factory _$$AssignmentStatisticsImplCopyWith(
    _$AssignmentStatisticsImpl value,
    $Res Function(_$AssignmentStatisticsImpl) then,
  ) = __$$AssignmentStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_assignments') int totalAssignments,
    @JsonKey(name: 'ungraded_assignments') int ungradedAssignments,
    @JsonKey(name: 'creating_count') int creatingCount,
    @JsonKey(name: 'distributing_count') int distributingCount,
    @JsonKey(name: 'waiting_to_assign') int waitingToAssign,
    @JsonKey(name: 'assigned') int assigned,
    @JsonKey(name: 'in_progress') int inProgress,
    @JsonKey(name: 'ungraded') int ungraded,
    @JsonKey(name: 'graded') int graded,
  });
}

/// @nodoc
class __$$AssignmentStatisticsImplCopyWithImpl<$Res>
    extends _$AssignmentStatisticsCopyWithImpl<$Res, _$AssignmentStatisticsImpl>
    implements _$$AssignmentStatisticsImplCopyWith<$Res> {
  __$$AssignmentStatisticsImplCopyWithImpl(
    _$AssignmentStatisticsImpl _value,
    $Res Function(_$AssignmentStatisticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignmentStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAssignments = null,
    Object? ungradedAssignments = null,
    Object? creatingCount = null,
    Object? distributingCount = null,
    Object? waitingToAssign = null,
    Object? assigned = null,
    Object? inProgress = null,
    Object? ungraded = null,
    Object? graded = null,
  }) {
    return _then(
      _$AssignmentStatisticsImpl(
        totalAssignments: null == totalAssignments
            ? _value.totalAssignments
            : totalAssignments // ignore: cast_nullable_to_non_nullable
                  as int,
        ungradedAssignments: null == ungradedAssignments
            ? _value.ungradedAssignments
            : ungradedAssignments // ignore: cast_nullable_to_non_nullable
                  as int,
        creatingCount: null == creatingCount
            ? _value.creatingCount
            : creatingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        distributingCount: null == distributingCount
            ? _value.distributingCount
            : distributingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        waitingToAssign: null == waitingToAssign
            ? _value.waitingToAssign
            : waitingToAssign // ignore: cast_nullable_to_non_nullable
                  as int,
        assigned: null == assigned
            ? _value.assigned
            : assigned // ignore: cast_nullable_to_non_nullable
                  as int,
        inProgress: null == inProgress
            ? _value.inProgress
            : inProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        ungraded: null == ungraded
            ? _value.ungraded
            : ungraded // ignore: cast_nullable_to_non_nullable
                  as int,
        graded: null == graded
            ? _value.graded
            : graded // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentStatisticsImpl implements _AssignmentStatistics {
  const _$AssignmentStatisticsImpl({
    @JsonKey(name: 'total_assignments') this.totalAssignments = 0,
    @JsonKey(name: 'ungraded_assignments') this.ungradedAssignments = 0,
    @JsonKey(name: 'creating_count') this.creatingCount = 0,
    @JsonKey(name: 'distributing_count') this.distributingCount = 0,
    @JsonKey(name: 'waiting_to_assign') this.waitingToAssign = 0,
    @JsonKey(name: 'assigned') this.assigned = 0,
    @JsonKey(name: 'in_progress') this.inProgress = 0,
    @JsonKey(name: 'ungraded') this.ungraded = 0,
    @JsonKey(name: 'graded') this.graded = 0,
  });

  factory _$AssignmentStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentStatisticsImplFromJson(json);

  @override
  @JsonKey(name: 'total_assignments')
  final int totalAssignments;
  @override
  @JsonKey(name: 'ungraded_assignments')
  final int ungradedAssignments;
  @override
  @JsonKey(name: 'creating_count')
  final int creatingCount;
  @override
  @JsonKey(name: 'distributing_count')
  final int distributingCount;
  @override
  @JsonKey(name: 'waiting_to_assign')
  final int waitingToAssign;
  @override
  @JsonKey(name: 'assigned')
  final int assigned;
  @override
  @JsonKey(name: 'in_progress')
  final int inProgress;
  @override
  @JsonKey(name: 'ungraded')
  final int ungraded;
  @override
  @JsonKey(name: 'graded')
  final int graded;

  @override
  String toString() {
    return 'AssignmentStatistics(totalAssignments: $totalAssignments, ungradedAssignments: $ungradedAssignments, creatingCount: $creatingCount, distributingCount: $distributingCount, waitingToAssign: $waitingToAssign, assigned: $assigned, inProgress: $inProgress, ungraded: $ungraded, graded: $graded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentStatisticsImpl &&
            (identical(other.totalAssignments, totalAssignments) ||
                other.totalAssignments == totalAssignments) &&
            (identical(other.ungradedAssignments, ungradedAssignments) ||
                other.ungradedAssignments == ungradedAssignments) &&
            (identical(other.creatingCount, creatingCount) ||
                other.creatingCount == creatingCount) &&
            (identical(other.distributingCount, distributingCount) ||
                other.distributingCount == distributingCount) &&
            (identical(other.waitingToAssign, waitingToAssign) ||
                other.waitingToAssign == waitingToAssign) &&
            (identical(other.assigned, assigned) ||
                other.assigned == assigned) &&
            (identical(other.inProgress, inProgress) ||
                other.inProgress == inProgress) &&
            (identical(other.ungraded, ungraded) ||
                other.ungraded == ungraded) &&
            (identical(other.graded, graded) || other.graded == graded));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalAssignments,
    ungradedAssignments,
    creatingCount,
    distributingCount,
    waitingToAssign,
    assigned,
    inProgress,
    ungraded,
    graded,
  );

  /// Create a copy of AssignmentStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentStatisticsImplCopyWith<_$AssignmentStatisticsImpl>
  get copyWith =>
      __$$AssignmentStatisticsImplCopyWithImpl<_$AssignmentStatisticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentStatisticsImplToJson(this);
  }
}

abstract class _AssignmentStatistics implements AssignmentStatistics {
  const factory _AssignmentStatistics({
    @JsonKey(name: 'total_assignments') final int totalAssignments,
    @JsonKey(name: 'ungraded_assignments') final int ungradedAssignments,
    @JsonKey(name: 'creating_count') final int creatingCount,
    @JsonKey(name: 'distributing_count') final int distributingCount,
    @JsonKey(name: 'waiting_to_assign') final int waitingToAssign,
    @JsonKey(name: 'assigned') final int assigned,
    @JsonKey(name: 'in_progress') final int inProgress,
    @JsonKey(name: 'ungraded') final int ungraded,
    @JsonKey(name: 'graded') final int graded,
  }) = _$AssignmentStatisticsImpl;

  factory _AssignmentStatistics.fromJson(Map<String, dynamic> json) =
      _$AssignmentStatisticsImpl.fromJson;

  @override
  @JsonKey(name: 'total_assignments')
  int get totalAssignments;
  @override
  @JsonKey(name: 'ungraded_assignments')
  int get ungradedAssignments;
  @override
  @JsonKey(name: 'creating_count')
  int get creatingCount;
  @override
  @JsonKey(name: 'distributing_count')
  int get distributingCount;
  @override
  @JsonKey(name: 'waiting_to_assign')
  int get waitingToAssign;
  @override
  @JsonKey(name: 'assigned')
  int get assigned;
  @override
  @JsonKey(name: 'in_progress')
  int get inProgress;
  @override
  @JsonKey(name: 'ungraded')
  int get ungraded;
  @override
  @JsonKey(name: 'graded')
  int get graded;

  /// Create a copy of AssignmentStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentStatisticsImplCopyWith<_$AssignmentStatisticsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

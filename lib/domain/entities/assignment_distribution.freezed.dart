// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_distribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignmentDistribution _$AssignmentDistributionFromJson(
  Map<String, dynamic> json,
) {
  return _AssignmentDistribution.fromJson(json);
}

/// @nodoc
mixin _$AssignmentDistribution {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'assignment_id')
  String get assignmentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'distribution_type')
  String get distributionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_id')
  String? get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String? get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_ids')
  List<String>? get studentIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_from')
  DateTime? get availableFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_at')
  DateTime? get dueAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_limit_minutes')
  int? get timeLimitMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_late')
  bool get allowLate => throw _privateConstructorUsedError;
  @JsonKey(name: 'late_policy')
  Map<String, dynamic>? get latePolicy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AssignmentDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentDistributionCopyWith<AssignmentDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentDistributionCopyWith<$Res> {
  factory $AssignmentDistributionCopyWith(
    AssignmentDistribution value,
    $Res Function(AssignmentDistribution) then,
  ) = _$AssignmentDistributionCopyWithImpl<$Res, AssignmentDistribution>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'distribution_type') String distributionType,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'student_ids') List<String>? studentIds,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') bool allowLate,
    @JsonKey(name: 'late_policy') Map<String, dynamic>? latePolicy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$AssignmentDistributionCopyWithImpl<
  $Res,
  $Val extends AssignmentDistribution
>
    implements $AssignmentDistributionCopyWith<$Res> {
  _$AssignmentDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? distributionType = null,
    Object? classId = freezed,
    Object? groupId = freezed,
    Object? studentIds = freezed,
    Object? availableFrom = freezed,
    Object? dueAt = freezed,
    Object? timeLimitMinutes = freezed,
    Object? allowLate = null,
    Object? latePolicy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as String,
            distributionType: null == distributionType
                ? _value.distributionType
                : distributionType // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: freezed == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentIds: freezed == studentIds
                ? _value.studentIds
                : studentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            availableFrom: freezed == availableFrom
                ? _value.availableFrom
                : availableFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueAt: freezed == dueAt
                ? _value.dueAt
                : dueAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            timeLimitMinutes: freezed == timeLimitMinutes
                ? _value.timeLimitMinutes
                : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            allowLate: null == allowLate
                ? _value.allowLate
                : allowLate // ignore: cast_nullable_to_non_nullable
                      as bool,
            latePolicy: freezed == latePolicy
                ? _value.latePolicy
                : latePolicy // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentDistributionImplCopyWith<$Res>
    implements $AssignmentDistributionCopyWith<$Res> {
  factory _$$AssignmentDistributionImplCopyWith(
    _$AssignmentDistributionImpl value,
    $Res Function(_$AssignmentDistributionImpl) then,
  ) = __$$AssignmentDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'distribution_type') String distributionType,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'student_ids') List<String>? studentIds,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') bool allowLate,
    @JsonKey(name: 'late_policy') Map<String, dynamic>? latePolicy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$AssignmentDistributionImplCopyWithImpl<$Res>
    extends
        _$AssignmentDistributionCopyWithImpl<$Res, _$AssignmentDistributionImpl>
    implements _$$AssignmentDistributionImplCopyWith<$Res> {
  __$$AssignmentDistributionImplCopyWithImpl(
    _$AssignmentDistributionImpl _value,
    $Res Function(_$AssignmentDistributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignmentDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? distributionType = null,
    Object? classId = freezed,
    Object? groupId = freezed,
    Object? studentIds = freezed,
    Object? availableFrom = freezed,
    Object? dueAt = freezed,
    Object? timeLimitMinutes = freezed,
    Object? allowLate = null,
    Object? latePolicy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AssignmentDistributionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as String,
        distributionType: null == distributionType
            ? _value.distributionType
            : distributionType // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: freezed == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentIds: freezed == studentIds
            ? _value._studentIds
            : studentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        availableFrom: freezed == availableFrom
            ? _value.availableFrom
            : availableFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueAt: freezed == dueAt
            ? _value.dueAt
            : dueAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        timeLimitMinutes: freezed == timeLimitMinutes
            ? _value.timeLimitMinutes
            : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        allowLate: null == allowLate
            ? _value.allowLate
            : allowLate // ignore: cast_nullable_to_non_nullable
                  as bool,
        latePolicy: freezed == latePolicy
            ? _value._latePolicy
            : latePolicy // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentDistributionImpl implements _AssignmentDistribution {
  const _$AssignmentDistributionImpl({
    required this.id,
    @JsonKey(name: 'assignment_id') required this.assignmentId,
    @JsonKey(name: 'distribution_type') required this.distributionType,
    @JsonKey(name: 'class_id') this.classId,
    @JsonKey(name: 'group_id') this.groupId,
    @JsonKey(name: 'student_ids') final List<String>? studentIds,
    @JsonKey(name: 'available_from') this.availableFrom,
    @JsonKey(name: 'due_at') this.dueAt,
    @JsonKey(name: 'time_limit_minutes') this.timeLimitMinutes,
    @JsonKey(name: 'allow_late') this.allowLate = true,
    @JsonKey(name: 'late_policy') final Map<String, dynamic>? latePolicy,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : _studentIds = studentIds,
       _latePolicy = latePolicy;

  factory _$AssignmentDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentDistributionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'assignment_id')
  final String assignmentId;
  @override
  @JsonKey(name: 'distribution_type')
  final String distributionType;
  @override
  @JsonKey(name: 'class_id')
  final String? classId;
  @override
  @JsonKey(name: 'group_id')
  final String? groupId;
  final List<String>? _studentIds;
  @override
  @JsonKey(name: 'student_ids')
  List<String>? get studentIds {
    final value = _studentIds;
    if (value == null) return null;
    if (_studentIds is EqualUnmodifiableListView) return _studentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'available_from')
  final DateTime? availableFrom;
  @override
  @JsonKey(name: 'due_at')
  final DateTime? dueAt;
  @override
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;
  @override
  @JsonKey(name: 'allow_late')
  final bool allowLate;
  final Map<String, dynamic>? _latePolicy;
  @override
  @JsonKey(name: 'late_policy')
  Map<String, dynamic>? get latePolicy {
    final value = _latePolicy;
    if (value == null) return null;
    if (_latePolicy is EqualUnmodifiableMapView) return _latePolicy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AssignmentDistribution(id: $id, assignmentId: $assignmentId, distributionType: $distributionType, classId: $classId, groupId: $groupId, studentIds: $studentIds, availableFrom: $availableFrom, dueAt: $dueAt, timeLimitMinutes: $timeLimitMinutes, allowLate: $allowLate, latePolicy: $latePolicy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentDistributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.distributionType, distributionType) ||
                other.distributionType == distributionType) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            const DeepCollectionEquality().equals(
              other._studentIds,
              _studentIds,
            ) &&
            (identical(other.availableFrom, availableFrom) ||
                other.availableFrom == availableFrom) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.timeLimitMinutes, timeLimitMinutes) ||
                other.timeLimitMinutes == timeLimitMinutes) &&
            (identical(other.allowLate, allowLate) ||
                other.allowLate == allowLate) &&
            const DeepCollectionEquality().equals(
              other._latePolicy,
              _latePolicy,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    assignmentId,
    distributionType,
    classId,
    groupId,
    const DeepCollectionEquality().hash(_studentIds),
    availableFrom,
    dueAt,
    timeLimitMinutes,
    allowLate,
    const DeepCollectionEquality().hash(_latePolicy),
    createdAt,
  );

  /// Create a copy of AssignmentDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentDistributionImplCopyWith<_$AssignmentDistributionImpl>
  get copyWith =>
      __$$AssignmentDistributionImplCopyWithImpl<_$AssignmentDistributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentDistributionImplToJson(this);
  }
}

abstract class _AssignmentDistribution implements AssignmentDistribution {
  const factory _AssignmentDistribution({
    required final String id,
    @JsonKey(name: 'assignment_id') required final String assignmentId,
    @JsonKey(name: 'distribution_type') required final String distributionType,
    @JsonKey(name: 'class_id') final String? classId,
    @JsonKey(name: 'group_id') final String? groupId,
    @JsonKey(name: 'student_ids') final List<String>? studentIds,
    @JsonKey(name: 'available_from') final DateTime? availableFrom,
    @JsonKey(name: 'due_at') final DateTime? dueAt,
    @JsonKey(name: 'time_limit_minutes') final int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') final bool allowLate,
    @JsonKey(name: 'late_policy') final Map<String, dynamic>? latePolicy,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$AssignmentDistributionImpl;

  factory _AssignmentDistribution.fromJson(Map<String, dynamic> json) =
      _$AssignmentDistributionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'assignment_id')
  String get assignmentId;
  @override
  @JsonKey(name: 'distribution_type')
  String get distributionType;
  @override
  @JsonKey(name: 'class_id')
  String? get classId;
  @override
  @JsonKey(name: 'group_id')
  String? get groupId;
  @override
  @JsonKey(name: 'student_ids')
  List<String>? get studentIds;
  @override
  @JsonKey(name: 'available_from')
  DateTime? get availableFrom;
  @override
  @JsonKey(name: 'due_at')
  DateTime? get dueAt;
  @override
  @JsonKey(name: 'time_limit_minutes')
  int? get timeLimitMinutes;
  @override
  @JsonKey(name: 'allow_late')
  bool get allowLate;
  @override
  @JsonKey(name: 'late_policy')
  Map<String, dynamic>? get latePolicy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of AssignmentDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentDistributionImplCopyWith<_$AssignmentDistributionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

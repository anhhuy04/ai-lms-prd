// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade_override.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GradeOverride _$GradeOverrideFromJson(Map<String, dynamic> json) {
  return _GradeOverride.fromJson(json);
}

/// @nodoc
mixin _$GradeOverride {
  String get id => throw _privateConstructorUsedError;

  /// ID của câu trả lời được ghi đè (submission_answers.id)
  @JsonKey(name: 'submission_answer_id')
  String get submissionAnswerId => throw _privateConstructorUsedError;

  /// ID của giáo viên thực hiện ghi đè
  @JsonKey(name: 'overridden_by')
  String get overriddenBy => throw _privateConstructorUsedError;

  /// Tên của giáo viên (từ join query)
  @JsonKey(name: 'overridden_by_name')
  String? get overriddenByName => throw _privateConstructorUsedError;

  /// Điểm trước khi ghi đè
  @JsonKey(name: 'old_score')
  double get oldScore => throw _privateConstructorUsedError;

  /// Điểm sau khi ghi đè
  @JsonKey(name: 'new_score')
  double get newScore => throw _privateConstructorUsedError;

  /// Lý do ghi đè (tùy chọn)
  String? get reason => throw _privateConstructorUsedError;

  /// Thời điểm tạo bản ghi ghi đè
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GradeOverride to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GradeOverride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GradeOverrideCopyWith<GradeOverride> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradeOverrideCopyWith<$Res> {
  factory $GradeOverrideCopyWith(
    GradeOverride value,
    $Res Function(GradeOverride) then,
  ) = _$GradeOverrideCopyWithImpl<$Res, GradeOverride>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_answer_id') String submissionAnswerId,
    @JsonKey(name: 'overridden_by') String overriddenBy,
    @JsonKey(name: 'overridden_by_name') String? overriddenByName,
    @JsonKey(name: 'old_score') double oldScore,
    @JsonKey(name: 'new_score') double newScore,
    String? reason,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$GradeOverrideCopyWithImpl<$Res, $Val extends GradeOverride>
    implements $GradeOverrideCopyWith<$Res> {
  _$GradeOverrideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GradeOverride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionAnswerId = null,
    Object? overriddenBy = null,
    Object? overriddenByName = freezed,
    Object? oldScore = null,
    Object? newScore = null,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            submissionAnswerId: null == submissionAnswerId
                ? _value.submissionAnswerId
                : submissionAnswerId // ignore: cast_nullable_to_non_nullable
                      as String,
            overriddenBy: null == overriddenBy
                ? _value.overriddenBy
                : overriddenBy // ignore: cast_nullable_to_non_nullable
                      as String,
            overriddenByName: freezed == overriddenByName
                ? _value.overriddenByName
                : overriddenByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            oldScore: null == oldScore
                ? _value.oldScore
                : oldScore // ignore: cast_nullable_to_non_nullable
                      as double,
            newScore: null == newScore
                ? _value.newScore
                : newScore // ignore: cast_nullable_to_non_nullable
                      as double,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GradeOverrideImplCopyWith<$Res>
    implements $GradeOverrideCopyWith<$Res> {
  factory _$$GradeOverrideImplCopyWith(
    _$GradeOverrideImpl value,
    $Res Function(_$GradeOverrideImpl) then,
  ) = __$$GradeOverrideImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_answer_id') String submissionAnswerId,
    @JsonKey(name: 'overridden_by') String overriddenBy,
    @JsonKey(name: 'overridden_by_name') String? overriddenByName,
    @JsonKey(name: 'old_score') double oldScore,
    @JsonKey(name: 'new_score') double newScore,
    String? reason,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$GradeOverrideImplCopyWithImpl<$Res>
    extends _$GradeOverrideCopyWithImpl<$Res, _$GradeOverrideImpl>
    implements _$$GradeOverrideImplCopyWith<$Res> {
  __$$GradeOverrideImplCopyWithImpl(
    _$GradeOverrideImpl _value,
    $Res Function(_$GradeOverrideImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GradeOverride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionAnswerId = null,
    Object? overriddenBy = null,
    Object? overriddenByName = freezed,
    Object? oldScore = null,
    Object? newScore = null,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$GradeOverrideImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        submissionAnswerId: null == submissionAnswerId
            ? _value.submissionAnswerId
            : submissionAnswerId // ignore: cast_nullable_to_non_nullable
                  as String,
        overriddenBy: null == overriddenBy
            ? _value.overriddenBy
            : overriddenBy // ignore: cast_nullable_to_non_nullable
                  as String,
        overriddenByName: freezed == overriddenByName
            ? _value.overriddenByName
            : overriddenByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldScore: null == oldScore
            ? _value.oldScore
            : oldScore // ignore: cast_nullable_to_non_nullable
                  as double,
        newScore: null == newScore
            ? _value.newScore
            : newScore // ignore: cast_nullable_to_non_nullable
                  as double,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GradeOverrideImpl implements _GradeOverride {
  const _$GradeOverrideImpl({
    required this.id,
    @JsonKey(name: 'submission_answer_id') required this.submissionAnswerId,
    @JsonKey(name: 'overridden_by') required this.overriddenBy,
    @JsonKey(name: 'overridden_by_name') this.overriddenByName,
    @JsonKey(name: 'old_score') required this.oldScore,
    @JsonKey(name: 'new_score') required this.newScore,
    this.reason,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$GradeOverrideImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradeOverrideImplFromJson(json);

  @override
  final String id;

  /// ID của câu trả lời được ghi đè (submission_answers.id)
  @override
  @JsonKey(name: 'submission_answer_id')
  final String submissionAnswerId;

  /// ID của giáo viên thực hiện ghi đè
  @override
  @JsonKey(name: 'overridden_by')
  final String overriddenBy;

  /// Tên của giáo viên (từ join query)
  @override
  @JsonKey(name: 'overridden_by_name')
  final String? overriddenByName;

  /// Điểm trước khi ghi đè
  @override
  @JsonKey(name: 'old_score')
  final double oldScore;

  /// Điểm sau khi ghi đè
  @override
  @JsonKey(name: 'new_score')
  final double newScore;

  /// Lý do ghi đè (tùy chọn)
  @override
  final String? reason;

  /// Thời điểm tạo bản ghi ghi đè
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'GradeOverride(id: $id, submissionAnswerId: $submissionAnswerId, overriddenBy: $overriddenBy, overriddenByName: $overriddenByName, oldScore: $oldScore, newScore: $newScore, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradeOverrideImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionAnswerId, submissionAnswerId) ||
                other.submissionAnswerId == submissionAnswerId) &&
            (identical(other.overriddenBy, overriddenBy) ||
                other.overriddenBy == overriddenBy) &&
            (identical(other.overriddenByName, overriddenByName) ||
                other.overriddenByName == overriddenByName) &&
            (identical(other.oldScore, oldScore) ||
                other.oldScore == oldScore) &&
            (identical(other.newScore, newScore) ||
                other.newScore == newScore) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    submissionAnswerId,
    overriddenBy,
    overriddenByName,
    oldScore,
    newScore,
    reason,
    createdAt,
  );

  /// Create a copy of GradeOverride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GradeOverrideImplCopyWith<_$GradeOverrideImpl> get copyWith =>
      __$$GradeOverrideImplCopyWithImpl<_$GradeOverrideImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradeOverrideImplToJson(this);
  }
}

abstract class _GradeOverride implements GradeOverride {
  const factory _GradeOverride({
    required final String id,
    @JsonKey(name: 'submission_answer_id')
    required final String submissionAnswerId,
    @JsonKey(name: 'overridden_by') required final String overriddenBy,
    @JsonKey(name: 'overridden_by_name') final String? overriddenByName,
    @JsonKey(name: 'old_score') required final double oldScore,
    @JsonKey(name: 'new_score') required final double newScore,
    final String? reason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$GradeOverrideImpl;

  factory _GradeOverride.fromJson(Map<String, dynamic> json) =
      _$GradeOverrideImpl.fromJson;

  @override
  String get id;

  /// ID của câu trả lời được ghi đè (submission_answers.id)
  @override
  @JsonKey(name: 'submission_answer_id')
  String get submissionAnswerId;

  /// ID của giáo viên thực hiện ghi đè
  @override
  @JsonKey(name: 'overridden_by')
  String get overriddenBy;

  /// Tên của giáo viên (từ join query)
  @override
  @JsonKey(name: 'overridden_by_name')
  String? get overriddenByName;

  /// Điểm trước khi ghi đè
  @override
  @JsonKey(name: 'old_score')
  double get oldScore;

  /// Điểm sau khi ghi đè
  @override
  @JsonKey(name: 'new_score')
  double get newScore;

  /// Lý do ghi đè (tùy chọn)
  @override
  String? get reason;

  /// Thời điểm tạo bản ghi ghi đè
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of GradeOverride
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GradeOverrideImplCopyWith<_$GradeOverrideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_variant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignmentVariant _$AssignmentVariantFromJson(Map<String, dynamic> json) {
  return _AssignmentVariant.fromJson(json);
}

/// @nodoc
mixin _$AssignmentVariant {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'assignment_id')
  String get assignmentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'variant_type')
  String get variantType => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String? get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String? get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_at_override')
  DateTime? get dueAtOverride => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_questions')
  Map<String, dynamic>? get customQuestions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AssignmentVariant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentVariantCopyWith<AssignmentVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentVariantCopyWith<$Res> {
  factory $AssignmentVariantCopyWith(
    AssignmentVariant value,
    $Res Function(AssignmentVariant) then,
  ) = _$AssignmentVariantCopyWithImpl<$Res, AssignmentVariant>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'variant_type') String variantType,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'due_at_override') DateTime? dueAtOverride,
    @JsonKey(name: 'custom_questions') Map<String, dynamic>? customQuestions,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$AssignmentVariantCopyWithImpl<$Res, $Val extends AssignmentVariant>
    implements $AssignmentVariantCopyWith<$Res> {
  _$AssignmentVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? variantType = null,
    Object? studentId = freezed,
    Object? groupId = freezed,
    Object? dueAtOverride = freezed,
    Object? customQuestions = freezed,
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
            variantType: null == variantType
                ? _value.variantType
                : variantType // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: freezed == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dueAtOverride: freezed == dueAtOverride
                ? _value.dueAtOverride
                : dueAtOverride // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            customQuestions: freezed == customQuestions
                ? _value.customQuestions
                : customQuestions // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AssignmentVariantImplCopyWith<$Res>
    implements $AssignmentVariantCopyWith<$Res> {
  factory _$$AssignmentVariantImplCopyWith(
    _$AssignmentVariantImpl value,
    $Res Function(_$AssignmentVariantImpl) then,
  ) = __$$AssignmentVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'variant_type') String variantType,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'due_at_override') DateTime? dueAtOverride,
    @JsonKey(name: 'custom_questions') Map<String, dynamic>? customQuestions,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$AssignmentVariantImplCopyWithImpl<$Res>
    extends _$AssignmentVariantCopyWithImpl<$Res, _$AssignmentVariantImpl>
    implements _$$AssignmentVariantImplCopyWith<$Res> {
  __$$AssignmentVariantImplCopyWithImpl(
    _$AssignmentVariantImpl _value,
    $Res Function(_$AssignmentVariantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignmentVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? variantType = null,
    Object? studentId = freezed,
    Object? groupId = freezed,
    Object? dueAtOverride = freezed,
    Object? customQuestions = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AssignmentVariantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as String,
        variantType: null == variantType
            ? _value.variantType
            : variantType // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: freezed == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dueAtOverride: freezed == dueAtOverride
            ? _value.dueAtOverride
            : dueAtOverride // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        customQuestions: freezed == customQuestions
            ? _value._customQuestions
            : customQuestions // ignore: cast_nullable_to_non_nullable
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
class _$AssignmentVariantImpl implements _AssignmentVariant {
  const _$AssignmentVariantImpl({
    required this.id,
    @JsonKey(name: 'assignment_id') required this.assignmentId,
    @JsonKey(name: 'variant_type') required this.variantType,
    @JsonKey(name: 'student_id') this.studentId,
    @JsonKey(name: 'group_id') this.groupId,
    @JsonKey(name: 'due_at_override') this.dueAtOverride,
    @JsonKey(name: 'custom_questions')
    final Map<String, dynamic>? customQuestions,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : _customQuestions = customQuestions;

  factory _$AssignmentVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentVariantImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'assignment_id')
  final String assignmentId;
  @override
  @JsonKey(name: 'variant_type')
  final String variantType;
  @override
  @JsonKey(name: 'student_id')
  final String? studentId;
  @override
  @JsonKey(name: 'group_id')
  final String? groupId;
  @override
  @JsonKey(name: 'due_at_override')
  final DateTime? dueAtOverride;
  final Map<String, dynamic>? _customQuestions;
  @override
  @JsonKey(name: 'custom_questions')
  Map<String, dynamic>? get customQuestions {
    final value = _customQuestions;
    if (value == null) return null;
    if (_customQuestions is EqualUnmodifiableMapView) return _customQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AssignmentVariant(id: $id, assignmentId: $assignmentId, variantType: $variantType, studentId: $studentId, groupId: $groupId, dueAtOverride: $dueAtOverride, customQuestions: $customQuestions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentVariantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.variantType, variantType) ||
                other.variantType == variantType) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.dueAtOverride, dueAtOverride) ||
                other.dueAtOverride == dueAtOverride) &&
            const DeepCollectionEquality().equals(
              other._customQuestions,
              _customQuestions,
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
    variantType,
    studentId,
    groupId,
    dueAtOverride,
    const DeepCollectionEquality().hash(_customQuestions),
    createdAt,
  );

  /// Create a copy of AssignmentVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentVariantImplCopyWith<_$AssignmentVariantImpl> get copyWith =>
      __$$AssignmentVariantImplCopyWithImpl<_$AssignmentVariantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentVariantImplToJson(this);
  }
}

abstract class _AssignmentVariant implements AssignmentVariant {
  const factory _AssignmentVariant({
    required final String id,
    @JsonKey(name: 'assignment_id') required final String assignmentId,
    @JsonKey(name: 'variant_type') required final String variantType,
    @JsonKey(name: 'student_id') final String? studentId,
    @JsonKey(name: 'group_id') final String? groupId,
    @JsonKey(name: 'due_at_override') final DateTime? dueAtOverride,
    @JsonKey(name: 'custom_questions')
    final Map<String, dynamic>? customQuestions,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$AssignmentVariantImpl;

  factory _AssignmentVariant.fromJson(Map<String, dynamic> json) =
      _$AssignmentVariantImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'assignment_id')
  String get assignmentId;
  @override
  @JsonKey(name: 'variant_type')
  String get variantType;
  @override
  @JsonKey(name: 'student_id')
  String? get studentId;
  @override
  @JsonKey(name: 'group_id')
  String? get groupId;
  @override
  @JsonKey(name: 'due_at_override')
  DateTime? get dueAtOverride;
  @override
  @JsonKey(name: 'custom_questions')
  Map<String, dynamic>? get customQuestions;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of AssignmentVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentVariantImplCopyWith<_$AssignmentVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

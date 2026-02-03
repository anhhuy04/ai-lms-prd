// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_objective.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LearningObjective _$LearningObjectiveFromJson(Map<String, dynamic> json) {
  return _LearningObjective.fromJson(json);
}

/// @nodoc
mixin _$LearningObjective {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'subject_code')
  String get subjectCode => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int? get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_id')
  String? get parentId => throw _privateConstructorUsedError;

  /// JSON metadata (bao gồm AI config nếu có)
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LearningObjective to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LearningObjective
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningObjectiveCopyWith<LearningObjective> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningObjectiveCopyWith<$Res> {
  factory $LearningObjectiveCopyWith(
    LearningObjective value,
    $Res Function(LearningObjective) then,
  ) = _$LearningObjectiveCopyWithImpl<$Res, LearningObjective>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'subject_code') String subjectCode,
    String code,
    String description,
    int? difficulty,
    @JsonKey(name: 'parent_id') String? parentId,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$LearningObjectiveCopyWithImpl<$Res, $Val extends LearningObjective>
    implements $LearningObjectiveCopyWith<$Res> {
  _$LearningObjectiveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningObjective
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectCode = null,
    Object? code = null,
    Object? description = null,
    Object? difficulty = freezed,
    Object? parentId = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectCode: null == subjectCode
                ? _value.subjectCode
                : subjectCode // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LearningObjectiveImplCopyWith<$Res>
    implements $LearningObjectiveCopyWith<$Res> {
  factory _$$LearningObjectiveImplCopyWith(
    _$LearningObjectiveImpl value,
    $Res Function(_$LearningObjectiveImpl) then,
  ) = __$$LearningObjectiveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'subject_code') String subjectCode,
    String code,
    String description,
    int? difficulty,
    @JsonKey(name: 'parent_id') String? parentId,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$LearningObjectiveImplCopyWithImpl<$Res>
    extends _$LearningObjectiveCopyWithImpl<$Res, _$LearningObjectiveImpl>
    implements _$$LearningObjectiveImplCopyWith<$Res> {
  __$$LearningObjectiveImplCopyWithImpl(
    _$LearningObjectiveImpl _value,
    $Res Function(_$LearningObjectiveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LearningObjective
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectCode = null,
    Object? code = null,
    Object? description = null,
    Object? difficulty = freezed,
    Object? parentId = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LearningObjectiveImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectCode: null == subjectCode
            ? _value.subjectCode
            : subjectCode // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
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
class _$LearningObjectiveImpl implements _LearningObjective {
  const _$LearningObjectiveImpl({
    required this.id,
    @JsonKey(name: 'subject_code') required this.subjectCode,
    required this.code,
    required this.description,
    this.difficulty,
    @JsonKey(name: 'parent_id') this.parentId,
    final Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : _metadata = metadata;

  factory _$LearningObjectiveImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningObjectiveImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'subject_code')
  final String subjectCode;
  @override
  final String code;
  @override
  final String description;
  @override
  final int? difficulty;
  @override
  @JsonKey(name: 'parent_id')
  final String? parentId;

  /// JSON metadata (bao gồm AI config nếu có)
  final Map<String, dynamic>? _metadata;

  /// JSON metadata (bao gồm AI config nếu có)
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'LearningObjective(id: $id, subjectCode: $subjectCode, code: $code, description: $description, difficulty: $difficulty, parentId: $parentId, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningObjectiveImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subjectCode, subjectCode) ||
                other.subjectCode == subjectCode) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    subjectCode,
    code,
    description,
    difficulty,
    parentId,
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
  );

  /// Create a copy of LearningObjective
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningObjectiveImplCopyWith<_$LearningObjectiveImpl> get copyWith =>
      __$$LearningObjectiveImplCopyWithImpl<_$LearningObjectiveImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningObjectiveImplToJson(this);
  }
}

abstract class _LearningObjective implements LearningObjective {
  const factory _LearningObjective({
    required final String id,
    @JsonKey(name: 'subject_code') required final String subjectCode,
    required final String code,
    required final String description,
    final int? difficulty,
    @JsonKey(name: 'parent_id') final String? parentId,
    final Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$LearningObjectiveImpl;

  factory _LearningObjective.fromJson(Map<String, dynamic> json) =
      _$LearningObjectiveImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'subject_code')
  String get subjectCode;
  @override
  String get code;
  @override
  String get description;
  @override
  int? get difficulty;
  @override
  @JsonKey(name: 'parent_id')
  String? get parentId;

  /// JSON metadata (bao gồm AI config nếu có)
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of LearningObjective
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningObjectiveImplCopyWith<_$LearningObjectiveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

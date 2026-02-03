// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_group_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateGroupParams _$CreateGroupParamsFromJson(Map<String, dynamic> json) {
  return _CreateGroupParams.fromJson(json);
}

/// @nodoc
mixin _$CreateGroupParams {
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this CreateGroupParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateGroupParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGroupParamsCopyWith<CreateGroupParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGroupParamsCopyWith<$Res> {
  factory $CreateGroupParamsCopyWith(
    CreateGroupParams value,
    $Res Function(CreateGroupParams) then,
  ) = _$CreateGroupParamsCopyWithImpl<$Res, CreateGroupParams>;
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    String name,
    String? description,
  });
}

/// @nodoc
class _$CreateGroupParamsCopyWithImpl<$Res, $Val extends CreateGroupParams>
    implements $CreateGroupParamsCopyWith<$Res> {
  _$CreateGroupParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGroupParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? name = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateGroupParamsImplCopyWith<$Res>
    implements $CreateGroupParamsCopyWith<$Res> {
  factory _$$CreateGroupParamsImplCopyWith(
    _$CreateGroupParamsImpl value,
    $Res Function(_$CreateGroupParamsImpl) then,
  ) = __$$CreateGroupParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'class_id') String classId,
    String name,
    String? description,
  });
}

/// @nodoc
class __$$CreateGroupParamsImplCopyWithImpl<$Res>
    extends _$CreateGroupParamsCopyWithImpl<$Res, _$CreateGroupParamsImpl>
    implements _$$CreateGroupParamsImplCopyWith<$Res> {
  __$$CreateGroupParamsImplCopyWithImpl(
    _$CreateGroupParamsImpl _value,
    $Res Function(_$CreateGroupParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateGroupParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? name = null,
    Object? description = freezed,
  }) {
    return _then(
      _$CreateGroupParamsImpl(
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateGroupParamsImpl implements _CreateGroupParams {
  const _$CreateGroupParamsImpl({
    @JsonKey(name: 'class_id') required this.classId,
    required this.name,
    this.description,
  });

  factory _$CreateGroupParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateGroupParamsImplFromJson(json);

  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  final String name;
  @override
  final String? description;

  @override
  String toString() {
    return 'CreateGroupParams(classId: $classId, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGroupParamsImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, classId, name, description);

  /// Create a copy of CreateGroupParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGroupParamsImplCopyWith<_$CreateGroupParamsImpl> get copyWith =>
      __$$CreateGroupParamsImplCopyWithImpl<_$CreateGroupParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateGroupParamsImplToJson(this);
  }
}

abstract class _CreateGroupParams implements CreateGroupParams {
  const factory _CreateGroupParams({
    @JsonKey(name: 'class_id') required final String classId,
    required final String name,
    final String? description,
  }) = _$CreateGroupParamsImpl;

  factory _CreateGroupParams.fromJson(Map<String, dynamic> json) =
      _$CreateGroupParamsImpl.fromJson;

  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  String get name;
  @override
  String? get description;

  /// Create a copy of CreateGroupParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGroupParamsImplCopyWith<_$CreateGroupParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

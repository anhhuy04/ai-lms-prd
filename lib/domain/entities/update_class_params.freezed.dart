// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_class_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpdateClassParams _$UpdateClassParamsFromJson(Map<String, dynamic> json) {
  return _UpdateClassParams.fromJson(json);
}

/// @nodoc
mixin _$UpdateClassParams {
  String? get name => throw _privateConstructorUsedError;
  String? get subject => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String? get academicYear => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_settings')
  Map<String, dynamic>? get classSettings => throw _privateConstructorUsedError;

  /// Serializes this UpdateClassParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateClassParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateClassParamsCopyWith<UpdateClassParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateClassParamsCopyWith<$Res> {
  factory $UpdateClassParamsCopyWith(
    UpdateClassParams value,
    $Res Function(UpdateClassParams) then,
  ) = _$UpdateClassParamsCopyWithImpl<$Res, UpdateClassParams>;
  @useResult
  $Res call({
    String? name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'class_settings') Map<String, dynamic>? classSettings,
  });
}

/// @nodoc
class _$UpdateClassParamsCopyWithImpl<$Res, $Val extends UpdateClassParams>
    implements $UpdateClassParamsCopyWith<$Res> {
  _$UpdateClassParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateClassParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? subject = freezed,
    Object? academicYear = freezed,
    Object? description = freezed,
    Object? classSettings = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            subject: freezed == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String?,
            academicYear: freezed == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            classSettings: freezed == classSettings
                ? _value.classSettings
                : classSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateClassParamsImplCopyWith<$Res>
    implements $UpdateClassParamsCopyWith<$Res> {
  factory _$$UpdateClassParamsImplCopyWith(
    _$UpdateClassParamsImpl value,
    $Res Function(_$UpdateClassParamsImpl) then,
  ) = __$$UpdateClassParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'class_settings') Map<String, dynamic>? classSettings,
  });
}

/// @nodoc
class __$$UpdateClassParamsImplCopyWithImpl<$Res>
    extends _$UpdateClassParamsCopyWithImpl<$Res, _$UpdateClassParamsImpl>
    implements _$$UpdateClassParamsImplCopyWith<$Res> {
  __$$UpdateClassParamsImplCopyWithImpl(
    _$UpdateClassParamsImpl _value,
    $Res Function(_$UpdateClassParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateClassParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? subject = freezed,
    Object? academicYear = freezed,
    Object? description = freezed,
    Object? classSettings = freezed,
  }) {
    return _then(
      _$UpdateClassParamsImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        subject: freezed == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String?,
        academicYear: freezed == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        classSettings: freezed == classSettings
            ? _value._classSettings
            : classSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateClassParamsImpl extends _UpdateClassParams {
  const _$UpdateClassParamsImpl({
    this.name,
    this.subject,
    @JsonKey(name: 'academic_year') this.academicYear,
    this.description,
    @JsonKey(name: 'class_settings') final Map<String, dynamic>? classSettings,
  }) : _classSettings = classSettings,
       super._();

  factory _$UpdateClassParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateClassParamsImplFromJson(json);

  @override
  final String? name;
  @override
  final String? subject;
  @override
  @JsonKey(name: 'academic_year')
  final String? academicYear;
  @override
  final String? description;
  final Map<String, dynamic>? _classSettings;
  @override
  @JsonKey(name: 'class_settings')
  Map<String, dynamic>? get classSettings {
    final value = _classSettings;
    if (value == null) return null;
    if (_classSettings is EqualUnmodifiableMapView) return _classSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'UpdateClassParams(name: $name, subject: $subject, academicYear: $academicYear, description: $description, classSettings: $classSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateClassParamsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._classSettings,
              _classSettings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    subject,
    academicYear,
    description,
    const DeepCollectionEquality().hash(_classSettings),
  );

  /// Create a copy of UpdateClassParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateClassParamsImplCopyWith<_$UpdateClassParamsImpl> get copyWith =>
      __$$UpdateClassParamsImplCopyWithImpl<_$UpdateClassParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateClassParamsImplToJson(this);
  }
}

abstract class _UpdateClassParams extends UpdateClassParams {
  const factory _UpdateClassParams({
    final String? name,
    final String? subject,
    @JsonKey(name: 'academic_year') final String? academicYear,
    final String? description,
    @JsonKey(name: 'class_settings') final Map<String, dynamic>? classSettings,
  }) = _$UpdateClassParamsImpl;
  const _UpdateClassParams._() : super._();

  factory _UpdateClassParams.fromJson(Map<String, dynamic> json) =
      _$UpdateClassParamsImpl.fromJson;

  @override
  String? get name;
  @override
  String? get subject;
  @override
  @JsonKey(name: 'academic_year')
  String? get academicYear;
  @override
  String? get description;
  @override
  @JsonKey(name: 'class_settings')
  Map<String, dynamic>? get classSettings;

  /// Create a copy of UpdateClassParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateClassParamsImplCopyWith<_$UpdateClassParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

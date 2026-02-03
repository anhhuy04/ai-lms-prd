// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignmentQuestion _$AssignmentQuestionFromJson(Map<String, dynamic> json) {
  return _AssignmentQuestion.fromJson(json);
}

/// @nodoc
mixin _$AssignmentQuestion {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'assignment_id')
  String get assignmentId => throw _privateConstructorUsedError;

  /// Nullable: NULL nếu câu hỏi được tạo mới, không reuse từ bank
  @JsonKey(name: 'question_id')
  String? get questionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_content')
  Map<String, dynamic>? get customContent => throw _privateConstructorUsedError;
  double get points => throw _privateConstructorUsedError;
  Map<String, dynamic>? get rubric => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_idx')
  int get orderIdx => throw _privateConstructorUsedError;

  /// Serializes this AssignmentQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentQuestionCopyWith<AssignmentQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentQuestionCopyWith<$Res> {
  factory $AssignmentQuestionCopyWith(
    AssignmentQuestion value,
    $Res Function(AssignmentQuestion) then,
  ) = _$AssignmentQuestionCopyWithImpl<$Res, AssignmentQuestion>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'question_id') String? questionId,
    @JsonKey(name: 'custom_content') Map<String, dynamic>? customContent,
    double points,
    Map<String, dynamic>? rubric,
    @JsonKey(name: 'order_idx') int orderIdx,
  });
}

/// @nodoc
class _$AssignmentQuestionCopyWithImpl<$Res, $Val extends AssignmentQuestion>
    implements $AssignmentQuestionCopyWith<$Res> {
  _$AssignmentQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? questionId = freezed,
    Object? customContent = freezed,
    Object? points = null,
    Object? rubric = freezed,
    Object? orderIdx = null,
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
            questionId: freezed == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customContent: freezed == customContent
                ? _value.customContent
                : customContent // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as double,
            rubric: freezed == rubric
                ? _value.rubric
                : rubric // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            orderIdx: null == orderIdx
                ? _value.orderIdx
                : orderIdx // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentQuestionImplCopyWith<$Res>
    implements $AssignmentQuestionCopyWith<$Res> {
  factory _$$AssignmentQuestionImplCopyWith(
    _$AssignmentQuestionImpl value,
    $Res Function(_$AssignmentQuestionImpl) then,
  ) = __$$AssignmentQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_id') String assignmentId,
    @JsonKey(name: 'question_id') String? questionId,
    @JsonKey(name: 'custom_content') Map<String, dynamic>? customContent,
    double points,
    Map<String, dynamic>? rubric,
    @JsonKey(name: 'order_idx') int orderIdx,
  });
}

/// @nodoc
class __$$AssignmentQuestionImplCopyWithImpl<$Res>
    extends _$AssignmentQuestionCopyWithImpl<$Res, _$AssignmentQuestionImpl>
    implements _$$AssignmentQuestionImplCopyWith<$Res> {
  __$$AssignmentQuestionImplCopyWithImpl(
    _$AssignmentQuestionImpl _value,
    $Res Function(_$AssignmentQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? questionId = freezed,
    Object? customContent = freezed,
    Object? points = null,
    Object? rubric = freezed,
    Object? orderIdx = null,
  }) {
    return _then(
      _$AssignmentQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionId: freezed == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customContent: freezed == customContent
            ? _value._customContent
            : customContent // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as double,
        rubric: freezed == rubric
            ? _value._rubric
            : rubric // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        orderIdx: null == orderIdx
            ? _value.orderIdx
            : orderIdx // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentQuestionImpl implements _AssignmentQuestion {
  const _$AssignmentQuestionImpl({
    required this.id,
    @JsonKey(name: 'assignment_id') required this.assignmentId,
    @JsonKey(name: 'question_id') this.questionId,
    @JsonKey(name: 'custom_content') final Map<String, dynamic>? customContent,
    this.points = 1,
    final Map<String, dynamic>? rubric,
    @JsonKey(name: 'order_idx') required this.orderIdx,
  }) : _customContent = customContent,
       _rubric = rubric;

  factory _$AssignmentQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentQuestionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'assignment_id')
  final String assignmentId;

  /// Nullable: NULL nếu câu hỏi được tạo mới, không reuse từ bank
  @override
  @JsonKey(name: 'question_id')
  final String? questionId;
  final Map<String, dynamic>? _customContent;
  @override
  @JsonKey(name: 'custom_content')
  Map<String, dynamic>? get customContent {
    final value = _customContent;
    if (value == null) return null;
    if (_customContent is EqualUnmodifiableMapView) return _customContent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final double points;
  final Map<String, dynamic>? _rubric;
  @override
  Map<String, dynamic>? get rubric {
    final value = _rubric;
    if (value == null) return null;
    if (_rubric is EqualUnmodifiableMapView) return _rubric;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'order_idx')
  final int orderIdx;

  @override
  String toString() {
    return 'AssignmentQuestion(id: $id, assignmentId: $assignmentId, questionId: $questionId, customContent: $customContent, points: $points, rubric: $rubric, orderIdx: $orderIdx)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            const DeepCollectionEquality().equals(
              other._customContent,
              _customContent,
            ) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality().equals(other._rubric, _rubric) &&
            (identical(other.orderIdx, orderIdx) ||
                other.orderIdx == orderIdx));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    assignmentId,
    questionId,
    const DeepCollectionEquality().hash(_customContent),
    points,
    const DeepCollectionEquality().hash(_rubric),
    orderIdx,
  );

  /// Create a copy of AssignmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentQuestionImplCopyWith<_$AssignmentQuestionImpl> get copyWith =>
      __$$AssignmentQuestionImplCopyWithImpl<_$AssignmentQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentQuestionImplToJson(this);
  }
}

abstract class _AssignmentQuestion implements AssignmentQuestion {
  const factory _AssignmentQuestion({
    required final String id,
    @JsonKey(name: 'assignment_id') required final String assignmentId,
    @JsonKey(name: 'question_id') final String? questionId,
    @JsonKey(name: 'custom_content') final Map<String, dynamic>? customContent,
    final double points,
    final Map<String, dynamic>? rubric,
    @JsonKey(name: 'order_idx') required final int orderIdx,
  }) = _$AssignmentQuestionImpl;

  factory _AssignmentQuestion.fromJson(Map<String, dynamic> json) =
      _$AssignmentQuestionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'assignment_id')
  String get assignmentId;

  /// Nullable: NULL nếu câu hỏi được tạo mới, không reuse từ bank
  @override
  @JsonKey(name: 'question_id')
  String? get questionId;
  @override
  @JsonKey(name: 'custom_content')
  Map<String, dynamic>? get customContent;
  @override
  double get points;
  @override
  Map<String, dynamic>? get rubric;
  @override
  @JsonKey(name: 'order_idx')
  int get orderIdx;

  /// Create a copy of AssignmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentQuestionImplCopyWith<_$AssignmentQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

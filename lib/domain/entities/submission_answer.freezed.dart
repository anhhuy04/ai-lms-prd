// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission_answer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubmissionAnswer _$SubmissionAnswerFromJson(Map<String, dynamic> json) {
  return _SubmissionAnswer.fromJson(json);
}

/// @nodoc
mixin _$SubmissionAnswer {
  String get id => throw _privateConstructorUsedError;

  /// ID của phiên làm việc (work_sessions.id)
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  /// ID của câu hỏi trong assignment (assignment_questions.id)
  @JsonKey(name: 'assignment_question_id')
  String get assignmentQuestionId => throw _privateConstructorUsedError;

  /// Câu trả lời của học sinh (JSON format, tùy loại câu hỏi)
  Map<String, dynamic>? get answer => throw _privateConstructorUsedError;

  /// Điểm được chấm bởi AI
  @JsonKey(name: 'ai_score')
  double? get aiScore => throw _privateConstructorUsedError;

  /// Độ tin cậy của điểm AI (0.0 - 1.0)
  @JsonKey(name: 'ai_confidence')
  double? get aiConfidence => throw _privateConstructorUsedError;

  /// Phản hồi từ AI
  @JsonKey(name: 'ai_feedback')
  Map<String, dynamic>? get aiFeedback => throw _privateConstructorUsedError;

  /// Điểm cuối cùng (sau khi teacher approve/override)
  @JsonKey(name: 'final_score')
  double? get finalScore => throw _privateConstructorUsedError;

  /// ID của giáo viên đã chấm
  @JsonKey(name: 'graded_by')
  String? get gradedBy => throw _privateConstructorUsedError;

  /// Thời điểm chấm xong
  @JsonKey(name: 'graded_at')
  DateTime? get gradedAt => throw _privateConstructorUsedError;

  /// Phản hồi từ giáo viên (teacher override feedback)
  @JsonKey(name: 'teacher_feedback')
  Map<String, dynamic>? get teacherFeedback =>
      throw _privateConstructorUsedError;

  /// Thời điểm tạo
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Thời điểm cập nhật cuối cùng
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError; // --- Extended fields from join queries ---
  /// Thông tin câu hỏi (từ assignment_questions join questions)
  /// Nullable - chỉ có khi query join
  Map<String, dynamic>? get assignmentQuestion =>
      throw _privateConstructorUsedError;

  /// ID của câu hỏi gốc (từ bảng questions)
  String? get questionId => throw _privateConstructorUsedError;

  /// Loại câu hỏi (từ bảng questions.type)
  String? get questionType => throw _privateConstructorUsedError;

  /// Điểm tối đa của câu hỏi
  double? get points => throw _privateConstructorUsedError;

  /// Nội dung tùy chỉnh (custom_content từ assignment_questions)
  Map<String, dynamic>? get customContent => throw _privateConstructorUsedError;

  /// Serializes this SubmissionAnswer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmissionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionAnswerCopyWith<SubmissionAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionAnswerCopyWith<$Res> {
  factory $SubmissionAnswerCopyWith(
    SubmissionAnswer value,
    $Res Function(SubmissionAnswer) then,
  ) = _$SubmissionAnswerCopyWithImpl<$Res, SubmissionAnswer>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'session_id') String sessionId,
    @JsonKey(name: 'assignment_question_id') String assignmentQuestionId,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'ai_score') double? aiScore,
    @JsonKey(name: 'ai_confidence') double? aiConfidence,
    @JsonKey(name: 'ai_feedback') Map<String, dynamic>? aiFeedback,
    @JsonKey(name: 'final_score') double? finalScore,
    @JsonKey(name: 'graded_by') String? gradedBy,
    @JsonKey(name: 'graded_at') DateTime? gradedAt,
    @JsonKey(name: 'teacher_feedback') Map<String, dynamic>? teacherFeedback,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    Map<String, dynamic>? assignmentQuestion,
    String? questionId,
    String? questionType,
    double? points,
    Map<String, dynamic>? customContent,
  });
}

/// @nodoc
class _$SubmissionAnswerCopyWithImpl<$Res, $Val extends SubmissionAnswer>
    implements $SubmissionAnswerCopyWith<$Res> {
  _$SubmissionAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmissionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? assignmentQuestionId = null,
    Object? answer = freezed,
    Object? aiScore = freezed,
    Object? aiConfidence = freezed,
    Object? aiFeedback = freezed,
    Object? finalScore = freezed,
    Object? gradedBy = freezed,
    Object? gradedAt = freezed,
    Object? teacherFeedback = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? assignmentQuestion = freezed,
    Object? questionId = freezed,
    Object? questionType = freezed,
    Object? points = freezed,
    Object? customContent = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignmentQuestionId: null == assignmentQuestionId
                ? _value.assignmentQuestionId
                : assignmentQuestionId // ignore: cast_nullable_to_non_nullable
                      as String,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            aiScore: freezed == aiScore
                ? _value.aiScore
                : aiScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            aiConfidence: freezed == aiConfidence
                ? _value.aiConfidence
                : aiConfidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            aiFeedback: freezed == aiFeedback
                ? _value.aiFeedback
                : aiFeedback // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            finalScore: freezed == finalScore
                ? _value.finalScore
                : finalScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            gradedBy: freezed == gradedBy
                ? _value.gradedBy
                : gradedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            gradedAt: freezed == gradedAt
                ? _value.gradedAt
                : gradedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            teacherFeedback: freezed == teacherFeedback
                ? _value.teacherFeedback
                : teacherFeedback // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            assignmentQuestion: freezed == assignmentQuestion
                ? _value.assignmentQuestion
                : assignmentQuestion // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            questionId: freezed == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            questionType: freezed == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: freezed == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as double?,
            customContent: freezed == customContent
                ? _value.customContent
                : customContent // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionAnswerImplCopyWith<$Res>
    implements $SubmissionAnswerCopyWith<$Res> {
  factory _$$SubmissionAnswerImplCopyWith(
    _$SubmissionAnswerImpl value,
    $Res Function(_$SubmissionAnswerImpl) then,
  ) = __$$SubmissionAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'session_id') String sessionId,
    @JsonKey(name: 'assignment_question_id') String assignmentQuestionId,
    Map<String, dynamic>? answer,
    @JsonKey(name: 'ai_score') double? aiScore,
    @JsonKey(name: 'ai_confidence') double? aiConfidence,
    @JsonKey(name: 'ai_feedback') Map<String, dynamic>? aiFeedback,
    @JsonKey(name: 'final_score') double? finalScore,
    @JsonKey(name: 'graded_by') String? gradedBy,
    @JsonKey(name: 'graded_at') DateTime? gradedAt,
    @JsonKey(name: 'teacher_feedback') Map<String, dynamic>? teacherFeedback,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    Map<String, dynamic>? assignmentQuestion,
    String? questionId,
    String? questionType,
    double? points,
    Map<String, dynamic>? customContent,
  });
}

/// @nodoc
class __$$SubmissionAnswerImplCopyWithImpl<$Res>
    extends _$SubmissionAnswerCopyWithImpl<$Res, _$SubmissionAnswerImpl>
    implements _$$SubmissionAnswerImplCopyWith<$Res> {
  __$$SubmissionAnswerImplCopyWithImpl(
    _$SubmissionAnswerImpl _value,
    $Res Function(_$SubmissionAnswerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmissionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? assignmentQuestionId = null,
    Object? answer = freezed,
    Object? aiScore = freezed,
    Object? aiConfidence = freezed,
    Object? aiFeedback = freezed,
    Object? finalScore = freezed,
    Object? gradedBy = freezed,
    Object? gradedAt = freezed,
    Object? teacherFeedback = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? assignmentQuestion = freezed,
    Object? questionId = freezed,
    Object? questionType = freezed,
    Object? points = freezed,
    Object? customContent = freezed,
  }) {
    return _then(
      _$SubmissionAnswerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentQuestionId: null == assignmentQuestionId
            ? _value.assignmentQuestionId
            : assignmentQuestionId // ignore: cast_nullable_to_non_nullable
                  as String,
        answer: freezed == answer
            ? _value._answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        aiScore: freezed == aiScore
            ? _value.aiScore
            : aiScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        aiConfidence: freezed == aiConfidence
            ? _value.aiConfidence
            : aiConfidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        aiFeedback: freezed == aiFeedback
            ? _value._aiFeedback
            : aiFeedback // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        finalScore: freezed == finalScore
            ? _value.finalScore
            : finalScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        gradedBy: freezed == gradedBy
            ? _value.gradedBy
            : gradedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        gradedAt: freezed == gradedAt
            ? _value.gradedAt
            : gradedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        teacherFeedback: freezed == teacherFeedback
            ? _value._teacherFeedback
            : teacherFeedback // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        assignmentQuestion: freezed == assignmentQuestion
            ? _value._assignmentQuestion
            : assignmentQuestion // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        questionId: freezed == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        questionType: freezed == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: freezed == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as double?,
        customContent: freezed == customContent
            ? _value._customContent
            : customContent // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionAnswerImpl implements _SubmissionAnswer {
  const _$SubmissionAnswerImpl({
    required this.id,
    @JsonKey(name: 'session_id') required this.sessionId,
    @JsonKey(name: 'assignment_question_id') required this.assignmentQuestionId,
    final Map<String, dynamic>? answer,
    @JsonKey(name: 'ai_score') this.aiScore,
    @JsonKey(name: 'ai_confidence') this.aiConfidence,
    @JsonKey(name: 'ai_feedback') final Map<String, dynamic>? aiFeedback,
    @JsonKey(name: 'final_score') this.finalScore,
    @JsonKey(name: 'graded_by') this.gradedBy,
    @JsonKey(name: 'graded_at') this.gradedAt,
    @JsonKey(name: 'teacher_feedback')
    final Map<String, dynamic>? teacherFeedback,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    final Map<String, dynamic>? assignmentQuestion,
    this.questionId,
    this.questionType,
    this.points,
    final Map<String, dynamic>? customContent,
  }) : _answer = answer,
       _aiFeedback = aiFeedback,
       _teacherFeedback = teacherFeedback,
       _assignmentQuestion = assignmentQuestion,
       _customContent = customContent;

  factory _$SubmissionAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionAnswerImplFromJson(json);

  @override
  final String id;

  /// ID của phiên làm việc (work_sessions.id)
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// ID của câu hỏi trong assignment (assignment_questions.id)
  @override
  @JsonKey(name: 'assignment_question_id')
  final String assignmentQuestionId;

  /// Câu trả lời của học sinh (JSON format, tùy loại câu hỏi)
  final Map<String, dynamic>? _answer;

  /// Câu trả lời của học sinh (JSON format, tùy loại câu hỏi)
  @override
  Map<String, dynamic>? get answer {
    final value = _answer;
    if (value == null) return null;
    if (_answer is EqualUnmodifiableMapView) return _answer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Điểm được chấm bởi AI
  @override
  @JsonKey(name: 'ai_score')
  final double? aiScore;

  /// Độ tin cậy của điểm AI (0.0 - 1.0)
  @override
  @JsonKey(name: 'ai_confidence')
  final double? aiConfidence;

  /// Phản hồi từ AI
  final Map<String, dynamic>? _aiFeedback;

  /// Phản hồi từ AI
  @override
  @JsonKey(name: 'ai_feedback')
  Map<String, dynamic>? get aiFeedback {
    final value = _aiFeedback;
    if (value == null) return null;
    if (_aiFeedback is EqualUnmodifiableMapView) return _aiFeedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Điểm cuối cùng (sau khi teacher approve/override)
  @override
  @JsonKey(name: 'final_score')
  final double? finalScore;

  /// ID của giáo viên đã chấm
  @override
  @JsonKey(name: 'graded_by')
  final String? gradedBy;

  /// Thời điểm chấm xong
  @override
  @JsonKey(name: 'graded_at')
  final DateTime? gradedAt;

  /// Phản hồi từ giáo viên (teacher override feedback)
  final Map<String, dynamic>? _teacherFeedback;

  /// Phản hồi từ giáo viên (teacher override feedback)
  @override
  @JsonKey(name: 'teacher_feedback')
  Map<String, dynamic>? get teacherFeedback {
    final value = _teacherFeedback;
    if (value == null) return null;
    if (_teacherFeedback is EqualUnmodifiableMapView) return _teacherFeedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Thời điểm tạo
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Thời điểm cập nhật cuối cùng
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  // --- Extended fields from join queries ---
  /// Thông tin câu hỏi (từ assignment_questions join questions)
  /// Nullable - chỉ có khi query join
  final Map<String, dynamic>? _assignmentQuestion;
  // --- Extended fields from join queries ---
  /// Thông tin câu hỏi (từ assignment_questions join questions)
  /// Nullable - chỉ có khi query join
  @override
  Map<String, dynamic>? get assignmentQuestion {
    final value = _assignmentQuestion;
    if (value == null) return null;
    if (_assignmentQuestion is EqualUnmodifiableMapView)
      return _assignmentQuestion;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// ID của câu hỏi gốc (từ bảng questions)
  @override
  final String? questionId;

  /// Loại câu hỏi (từ bảng questions.type)
  @override
  final String? questionType;

  /// Điểm tối đa của câu hỏi
  @override
  final double? points;

  /// Nội dung tùy chỉnh (custom_content từ assignment_questions)
  final Map<String, dynamic>? _customContent;

  /// Nội dung tùy chỉnh (custom_content từ assignment_questions)
  @override
  Map<String, dynamic>? get customContent {
    final value = _customContent;
    if (value == null) return null;
    if (_customContent is EqualUnmodifiableMapView) return _customContent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SubmissionAnswer(id: $id, sessionId: $sessionId, assignmentQuestionId: $assignmentQuestionId, answer: $answer, aiScore: $aiScore, aiConfidence: $aiConfidence, aiFeedback: $aiFeedback, finalScore: $finalScore, gradedBy: $gradedBy, gradedAt: $gradedAt, teacherFeedback: $teacherFeedback, createdAt: $createdAt, updatedAt: $updatedAt, assignmentQuestion: $assignmentQuestion, questionId: $questionId, questionType: $questionType, points: $points, customContent: $customContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionAnswerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.assignmentQuestionId, assignmentQuestionId) ||
                other.assignmentQuestionId == assignmentQuestionId) &&
            const DeepCollectionEquality().equals(other._answer, _answer) &&
            (identical(other.aiScore, aiScore) || other.aiScore == aiScore) &&
            (identical(other.aiConfidence, aiConfidence) ||
                other.aiConfidence == aiConfidence) &&
            const DeepCollectionEquality().equals(
              other._aiFeedback,
              _aiFeedback,
            ) &&
            (identical(other.finalScore, finalScore) ||
                other.finalScore == finalScore) &&
            (identical(other.gradedBy, gradedBy) ||
                other.gradedBy == gradedBy) &&
            (identical(other.gradedAt, gradedAt) ||
                other.gradedAt == gradedAt) &&
            const DeepCollectionEquality().equals(
              other._teacherFeedback,
              _teacherFeedback,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._assignmentQuestion,
              _assignmentQuestion,
            ) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality().equals(
              other._customContent,
              _customContent,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    assignmentQuestionId,
    const DeepCollectionEquality().hash(_answer),
    aiScore,
    aiConfidence,
    const DeepCollectionEquality().hash(_aiFeedback),
    finalScore,
    gradedBy,
    gradedAt,
    const DeepCollectionEquality().hash(_teacherFeedback),
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_assignmentQuestion),
    questionId,
    questionType,
    points,
    const DeepCollectionEquality().hash(_customContent),
  );

  /// Create a copy of SubmissionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionAnswerImplCopyWith<_$SubmissionAnswerImpl> get copyWith =>
      __$$SubmissionAnswerImplCopyWithImpl<_$SubmissionAnswerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionAnswerImplToJson(this);
  }
}

abstract class _SubmissionAnswer implements SubmissionAnswer {
  const factory _SubmissionAnswer({
    required final String id,
    @JsonKey(name: 'session_id') required final String sessionId,
    @JsonKey(name: 'assignment_question_id')
    required final String assignmentQuestionId,
    final Map<String, dynamic>? answer,
    @JsonKey(name: 'ai_score') final double? aiScore,
    @JsonKey(name: 'ai_confidence') final double? aiConfidence,
    @JsonKey(name: 'ai_feedback') final Map<String, dynamic>? aiFeedback,
    @JsonKey(name: 'final_score') final double? finalScore,
    @JsonKey(name: 'graded_by') final String? gradedBy,
    @JsonKey(name: 'graded_at') final DateTime? gradedAt,
    @JsonKey(name: 'teacher_feedback')
    final Map<String, dynamic>? teacherFeedback,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    final Map<String, dynamic>? assignmentQuestion,
    final String? questionId,
    final String? questionType,
    final double? points,
    final Map<String, dynamic>? customContent,
  }) = _$SubmissionAnswerImpl;

  factory _SubmissionAnswer.fromJson(Map<String, dynamic> json) =
      _$SubmissionAnswerImpl.fromJson;

  @override
  String get id;

  /// ID của phiên làm việc (work_sessions.id)
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;

  /// ID của câu hỏi trong assignment (assignment_questions.id)
  @override
  @JsonKey(name: 'assignment_question_id')
  String get assignmentQuestionId;

  /// Câu trả lời của học sinh (JSON format, tùy loại câu hỏi)
  @override
  Map<String, dynamic>? get answer;

  /// Điểm được chấm bởi AI
  @override
  @JsonKey(name: 'ai_score')
  double? get aiScore;

  /// Độ tin cậy của điểm AI (0.0 - 1.0)
  @override
  @JsonKey(name: 'ai_confidence')
  double? get aiConfidence;

  /// Phản hồi từ AI
  @override
  @JsonKey(name: 'ai_feedback')
  Map<String, dynamic>? get aiFeedback;

  /// Điểm cuối cùng (sau khi teacher approve/override)
  @override
  @JsonKey(name: 'final_score')
  double? get finalScore;

  /// ID của giáo viên đã chấm
  @override
  @JsonKey(name: 'graded_by')
  String? get gradedBy;

  /// Thời điểm chấm xong
  @override
  @JsonKey(name: 'graded_at')
  DateTime? get gradedAt;

  /// Phản hồi từ giáo viên (teacher override feedback)
  @override
  @JsonKey(name: 'teacher_feedback')
  Map<String, dynamic>? get teacherFeedback;

  /// Thời điểm tạo
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Thời điểm cập nhật cuối cùng
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // --- Extended fields from join queries ---
  /// Thông tin câu hỏi (từ assignment_questions join questions)
  /// Nullable - chỉ có khi query join
  @override
  Map<String, dynamic>? get assignmentQuestion;

  /// ID của câu hỏi gốc (từ bảng questions)
  @override
  String? get questionId;

  /// Loại câu hỏi (từ bảng questions.type)
  @override
  String? get questionType;

  /// Điểm tối đa của câu hỏi
  @override
  double? get points;

  /// Nội dung tùy chỉnh (custom_content từ assignment_questions)
  @override
  Map<String, dynamic>? get customContent;

  /// Create a copy of SubmissionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionAnswerImplCopyWith<_$SubmissionAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

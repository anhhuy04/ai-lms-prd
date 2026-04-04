// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Submission _$SubmissionFromJson(Map<String, dynamic> json) {
  return _Submission.fromJson(json);
}

/// @nodoc
mixin _$Submission {
  String get id => throw _privateConstructorUsedError;

  /// ID của bài tập được phân phối (assignment_distributions)
  @JsonKey(name: 'assignment_distribution_id')
  String get assignmentDistributionId => throw _privateConstructorUsedError;

  /// ID của học sinh nộp bài
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;

  /// Trạng thái hiện tại của bài nộp
  @JsonKey(name: 'status')
  SubmissionStatus get status => throw _privateConstructorUsedError;

  /// Thời điểm nộp bài (null nếu chưa nộp)
  @JsonKey(name: 'submitted_at')
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Thời điểm chấm bài xong (null nếu chưa chấm)
  @JsonKey(name: 'graded_at')
  DateTime? get gradedAt => throw _privateConstructorUsedError;

  /// Điểm số (null nếu chưa chấm)
  @JsonKey(name: 'score')
  double? get score => throw _privateConstructorUsedError;

  /// Phản hồi từ giáo viên/AI
  @JsonKey(name: 'feedback')
  String? get feedback => throw _privateConstructorUsedError;

  /// Tổng điểm tối đa của bài tập
  @JsonKey(name: 'total_points')
  double? get totalPoints => throw _privateConstructorUsedError;

  /// Map các câu trả lời theo question_id
  /// Key: question_id, Value: câu trả lời
  @JsonKey(name: 'answers')
  Map<String, dynamic> get answers => throw _privateConstructorUsedError;

  /// Danh sách URL của các file đã upload
  @JsonKey(name: 'uploaded_files')
  List<String> get uploadedFiles => throw _privateConstructorUsedError;

  /// Thời điểm tạo bài nộp
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Thời điểm cập nhật cuối cùng
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError; // === Extended fields from JOIN queries ===
  /// ID của session (work_sessions) - dùng để query submission_answers
  @JsonKey(name: 'session_id')
  String? get sessionId => throw _privateConstructorUsedError;

  /// Computed: có nộp muộn không
  @JsonKey(name: 'is_late')
  bool? get isLate => throw _privateConstructorUsedError;

  /// Tổng điểm
  @JsonKey(name: 'total_score')
  double? get totalScore => throw _privateConstructorUsedError;

  /// Profile học sinh (từ JOIN profiles)
  Map<String, dynamic>? get profiles => throw _privateConstructorUsedError;

  /// Distribution + assignment + class info (từ JOIN assignment_distributions)
  Map<String, dynamic>? get assignmentDistributions =>
      throw _privateConstructorUsedError;

  /// Work session status (từ JOIN work_sessions)
  Map<String, dynamic>? get workSessions => throw _privateConstructorUsedError;

  /// Danh sách câu trả lời (từ query riêng via session_id)
  @JsonKey(name: 'submission_answers')
  List<Map<String, dynamic>>? get submissionAnswers =>
      throw _privateConstructorUsedError;

  /// Serializes this Submission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionCopyWith<Submission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionCopyWith<$Res> {
  factory $SubmissionCopyWith(
    Submission value,
    $Res Function(Submission) then,
  ) = _$SubmissionCopyWithImpl<$Res, Submission>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_distribution_id')
    String assignmentDistributionId,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'status') SubmissionStatus status,
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,
    @JsonKey(name: 'graded_at') DateTime? gradedAt,
    @JsonKey(name: 'score') double? score,
    @JsonKey(name: 'feedback') String? feedback,
    @JsonKey(name: 'total_points') double? totalPoints,
    @JsonKey(name: 'answers') Map<String, dynamic> answers,
    @JsonKey(name: 'uploaded_files') List<String> uploadedFiles,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'is_late') bool? isLate,
    @JsonKey(name: 'total_score') double? totalScore,
    Map<String, dynamic>? profiles,
    Map<String, dynamic>? assignmentDistributions,
    Map<String, dynamic>? workSessions,
    @JsonKey(name: 'submission_answers')
    List<Map<String, dynamic>>? submissionAnswers,
  });
}

/// @nodoc
class _$SubmissionCopyWithImpl<$Res, $Val extends Submission>
    implements $SubmissionCopyWith<$Res> {
  _$SubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentDistributionId = null,
    Object? studentId = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? gradedAt = freezed,
    Object? score = freezed,
    Object? feedback = freezed,
    Object? totalPoints = freezed,
    Object? answers = null,
    Object? uploadedFiles = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? sessionId = freezed,
    Object? isLate = freezed,
    Object? totalScore = freezed,
    Object? profiles = freezed,
    Object? assignmentDistributions = freezed,
    Object? workSessions = freezed,
    Object? submissionAnswers = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            assignmentDistributionId: null == assignmentDistributionId
                ? _value.assignmentDistributionId
                : assignmentDistributionId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubmissionStatus,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            gradedAt: freezed == gradedAt
                ? _value.gradedAt
                : gradedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double?,
            feedback: freezed == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalPoints: freezed == totalPoints
                ? _value.totalPoints
                : totalPoints // ignore: cast_nullable_to_non_nullable
                      as double?,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            uploadedFiles: null == uploadedFiles
                ? _value.uploadedFiles
                : uploadedFiles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sessionId: freezed == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLate: freezed == isLate
                ? _value.isLate
                : isLate // ignore: cast_nullable_to_non_nullable
                      as bool?,
            totalScore: freezed == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            profiles: freezed == profiles
                ? _value.profiles
                : profiles // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            assignmentDistributions: freezed == assignmentDistributions
                ? _value.assignmentDistributions
                : assignmentDistributions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            workSessions: freezed == workSessions
                ? _value.workSessions
                : workSessions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            submissionAnswers: freezed == submissionAnswers
                ? _value.submissionAnswers
                : submissionAnswers // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionImplCopyWith<$Res>
    implements $SubmissionCopyWith<$Res> {
  factory _$$SubmissionImplCopyWith(
    _$SubmissionImpl value,
    $Res Function(_$SubmissionImpl) then,
  ) = __$$SubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'assignment_distribution_id')
    String assignmentDistributionId,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'status') SubmissionStatus status,
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,
    @JsonKey(name: 'graded_at') DateTime? gradedAt,
    @JsonKey(name: 'score') double? score,
    @JsonKey(name: 'feedback') String? feedback,
    @JsonKey(name: 'total_points') double? totalPoints,
    @JsonKey(name: 'answers') Map<String, dynamic> answers,
    @JsonKey(name: 'uploaded_files') List<String> uploadedFiles,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'is_late') bool? isLate,
    @JsonKey(name: 'total_score') double? totalScore,
    Map<String, dynamic>? profiles,
    Map<String, dynamic>? assignmentDistributions,
    Map<String, dynamic>? workSessions,
    @JsonKey(name: 'submission_answers')
    List<Map<String, dynamic>>? submissionAnswers,
  });
}

/// @nodoc
class __$$SubmissionImplCopyWithImpl<$Res>
    extends _$SubmissionCopyWithImpl<$Res, _$SubmissionImpl>
    implements _$$SubmissionImplCopyWith<$Res> {
  __$$SubmissionImplCopyWithImpl(
    _$SubmissionImpl _value,
    $Res Function(_$SubmissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentDistributionId = null,
    Object? studentId = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? gradedAt = freezed,
    Object? score = freezed,
    Object? feedback = freezed,
    Object? totalPoints = freezed,
    Object? answers = null,
    Object? uploadedFiles = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? sessionId = freezed,
    Object? isLate = freezed,
    Object? totalScore = freezed,
    Object? profiles = freezed,
    Object? assignmentDistributions = freezed,
    Object? workSessions = freezed,
    Object? submissionAnswers = freezed,
  }) {
    return _then(
      _$SubmissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentDistributionId: null == assignmentDistributionId
            ? _value.assignmentDistributionId
            : assignmentDistributionId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubmissionStatus,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        gradedAt: freezed == gradedAt
            ? _value.gradedAt
            : gradedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double?,
        feedback: freezed == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalPoints: freezed == totalPoints
            ? _value.totalPoints
            : totalPoints // ignore: cast_nullable_to_non_nullable
                  as double?,
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        uploadedFiles: null == uploadedFiles
            ? _value._uploadedFiles
            : uploadedFiles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sessionId: freezed == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLate: freezed == isLate
            ? _value.isLate
            : isLate // ignore: cast_nullable_to_non_nullable
                  as bool?,
        totalScore: freezed == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        profiles: freezed == profiles
            ? _value._profiles
            : profiles // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        assignmentDistributions: freezed == assignmentDistributions
            ? _value._assignmentDistributions
            : assignmentDistributions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        workSessions: freezed == workSessions
            ? _value._workSessions
            : workSessions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        submissionAnswers: freezed == submissionAnswers
            ? _value._submissionAnswers
            : submissionAnswers // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionImpl implements _Submission {
  const _$SubmissionImpl({
    required this.id,
    @JsonKey(name: 'assignment_distribution_id')
    required this.assignmentDistributionId,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'status') this.status = SubmissionStatus.draft,
    @JsonKey(name: 'submitted_at') this.submittedAt,
    @JsonKey(name: 'graded_at') this.gradedAt,
    @JsonKey(name: 'score') this.score,
    @JsonKey(name: 'feedback') this.feedback,
    @JsonKey(name: 'total_points') this.totalPoints,
    @JsonKey(name: 'answers') final Map<String, dynamic> answers = const {},
    @JsonKey(name: 'uploaded_files')
    final List<String> uploadedFiles = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'session_id') this.sessionId,
    @JsonKey(name: 'is_late') this.isLate,
    @JsonKey(name: 'total_score') this.totalScore,
    final Map<String, dynamic>? profiles,
    final Map<String, dynamic>? assignmentDistributions,
    final Map<String, dynamic>? workSessions,
    @JsonKey(name: 'submission_answers')
    final List<Map<String, dynamic>>? submissionAnswers,
  }) : _answers = answers,
       _uploadedFiles = uploadedFiles,
       _profiles = profiles,
       _assignmentDistributions = assignmentDistributions,
       _workSessions = workSessions,
       _submissionAnswers = submissionAnswers;

  factory _$SubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionImplFromJson(json);

  @override
  final String id;

  /// ID của bài tập được phân phối (assignment_distributions)
  @override
  @JsonKey(name: 'assignment_distribution_id')
  final String assignmentDistributionId;

  /// ID của học sinh nộp bài
  @override
  @JsonKey(name: 'student_id')
  final String studentId;

  /// Trạng thái hiện tại của bài nộp
  @override
  @JsonKey(name: 'status')
  final SubmissionStatus status;

  /// Thời điểm nộp bài (null nếu chưa nộp)
  @override
  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;

  /// Thời điểm chấm bài xong (null nếu chưa chấm)
  @override
  @JsonKey(name: 'graded_at')
  final DateTime? gradedAt;

  /// Điểm số (null nếu chưa chấm)
  @override
  @JsonKey(name: 'score')
  final double? score;

  /// Phản hồi từ giáo viên/AI
  @override
  @JsonKey(name: 'feedback')
  final String? feedback;

  /// Tổng điểm tối đa của bài tập
  @override
  @JsonKey(name: 'total_points')
  final double? totalPoints;

  /// Map các câu trả lời theo question_id
  /// Key: question_id, Value: câu trả lời
  final Map<String, dynamic> _answers;

  /// Map các câu trả lời theo question_id
  /// Key: question_id, Value: câu trả lời
  @override
  @JsonKey(name: 'answers')
  Map<String, dynamic> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  /// Danh sách URL của các file đã upload
  final List<String> _uploadedFiles;

  /// Danh sách URL của các file đã upload
  @override
  @JsonKey(name: 'uploaded_files')
  List<String> get uploadedFiles {
    if (_uploadedFiles is EqualUnmodifiableListView) return _uploadedFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_uploadedFiles);
  }

  /// Thời điểm tạo bài nộp
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Thời điểm cập nhật cuối cùng
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  // === Extended fields from JOIN queries ===
  /// ID của session (work_sessions) - dùng để query submission_answers
  @override
  @JsonKey(name: 'session_id')
  final String? sessionId;

  /// Computed: có nộp muộn không
  @override
  @JsonKey(name: 'is_late')
  final bool? isLate;

  /// Tổng điểm
  @override
  @JsonKey(name: 'total_score')
  final double? totalScore;

  /// Profile học sinh (từ JOIN profiles)
  final Map<String, dynamic>? _profiles;

  /// Profile học sinh (từ JOIN profiles)
  @override
  Map<String, dynamic>? get profiles {
    final value = _profiles;
    if (value == null) return null;
    if (_profiles is EqualUnmodifiableMapView) return _profiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Distribution + assignment + class info (từ JOIN assignment_distributions)
  final Map<String, dynamic>? _assignmentDistributions;

  /// Distribution + assignment + class info (từ JOIN assignment_distributions)
  @override
  Map<String, dynamic>? get assignmentDistributions {
    final value = _assignmentDistributions;
    if (value == null) return null;
    if (_assignmentDistributions is EqualUnmodifiableMapView)
      return _assignmentDistributions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Work session status (từ JOIN work_sessions)
  final Map<String, dynamic>? _workSessions;

  /// Work session status (từ JOIN work_sessions)
  @override
  Map<String, dynamic>? get workSessions {
    final value = _workSessions;
    if (value == null) return null;
    if (_workSessions is EqualUnmodifiableMapView) return _workSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Danh sách câu trả lời (từ query riêng via session_id)
  final List<Map<String, dynamic>>? _submissionAnswers;

  /// Danh sách câu trả lời (từ query riêng via session_id)
  @override
  @JsonKey(name: 'submission_answers')
  List<Map<String, dynamic>>? get submissionAnswers {
    final value = _submissionAnswers;
    if (value == null) return null;
    if (_submissionAnswers is EqualUnmodifiableListView)
      return _submissionAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Submission(id: $id, assignmentDistributionId: $assignmentDistributionId, studentId: $studentId, status: $status, submittedAt: $submittedAt, gradedAt: $gradedAt, score: $score, feedback: $feedback, totalPoints: $totalPoints, answers: $answers, uploadedFiles: $uploadedFiles, createdAt: $createdAt, updatedAt: $updatedAt, sessionId: $sessionId, isLate: $isLate, totalScore: $totalScore, profiles: $profiles, assignmentDistributions: $assignmentDistributions, workSessions: $workSessions, submissionAnswers: $submissionAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(
                  other.assignmentDistributionId,
                  assignmentDistributionId,
                ) ||
                other.assignmentDistributionId == assignmentDistributionId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.gradedAt, gradedAt) ||
                other.gradedAt == gradedAt) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            const DeepCollectionEquality().equals(
              other._uploadedFiles,
              _uploadedFiles,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            const DeepCollectionEquality().equals(other._profiles, _profiles) &&
            const DeepCollectionEquality().equals(
              other._assignmentDistributions,
              _assignmentDistributions,
            ) &&
            const DeepCollectionEquality().equals(
              other._workSessions,
              _workSessions,
            ) &&
            const DeepCollectionEquality().equals(
              other._submissionAnswers,
              _submissionAnswers,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    assignmentDistributionId,
    studentId,
    status,
    submittedAt,
    gradedAt,
    score,
    feedback,
    totalPoints,
    const DeepCollectionEquality().hash(_answers),
    const DeepCollectionEquality().hash(_uploadedFiles),
    createdAt,
    updatedAt,
    sessionId,
    isLate,
    totalScore,
    const DeepCollectionEquality().hash(_profiles),
    const DeepCollectionEquality().hash(_assignmentDistributions),
    const DeepCollectionEquality().hash(_workSessions),
    const DeepCollectionEquality().hash(_submissionAnswers),
  ]);

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      __$$SubmissionImplCopyWithImpl<_$SubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionImplToJson(this);
  }
}

abstract class _Submission implements Submission {
  const factory _Submission({
    required final String id,
    @JsonKey(name: 'assignment_distribution_id')
    required final String assignmentDistributionId,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'status') final SubmissionStatus status,
    @JsonKey(name: 'submitted_at') final DateTime? submittedAt,
    @JsonKey(name: 'graded_at') final DateTime? gradedAt,
    @JsonKey(name: 'score') final double? score,
    @JsonKey(name: 'feedback') final String? feedback,
    @JsonKey(name: 'total_points') final double? totalPoints,
    @JsonKey(name: 'answers') final Map<String, dynamic> answers,
    @JsonKey(name: 'uploaded_files') final List<String> uploadedFiles,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'session_id') final String? sessionId,
    @JsonKey(name: 'is_late') final bool? isLate,
    @JsonKey(name: 'total_score') final double? totalScore,
    final Map<String, dynamic>? profiles,
    final Map<String, dynamic>? assignmentDistributions,
    final Map<String, dynamic>? workSessions,
    @JsonKey(name: 'submission_answers')
    final List<Map<String, dynamic>>? submissionAnswers,
  }) = _$SubmissionImpl;

  factory _Submission.fromJson(Map<String, dynamic> json) =
      _$SubmissionImpl.fromJson;

  @override
  String get id;

  /// ID của bài tập được phân phối (assignment_distributions)
  @override
  @JsonKey(name: 'assignment_distribution_id')
  String get assignmentDistributionId;

  /// ID của học sinh nộp bài
  @override
  @JsonKey(name: 'student_id')
  String get studentId;

  /// Trạng thái hiện tại của bài nộp
  @override
  @JsonKey(name: 'status')
  SubmissionStatus get status;

  /// Thời điểm nộp bài (null nếu chưa nộp)
  @override
  @JsonKey(name: 'submitted_at')
  DateTime? get submittedAt;

  /// Thời điểm chấm bài xong (null nếu chưa chấm)
  @override
  @JsonKey(name: 'graded_at')
  DateTime? get gradedAt;

  /// Điểm số (null nếu chưa chấm)
  @override
  @JsonKey(name: 'score')
  double? get score;

  /// Phản hồi từ giáo viên/AI
  @override
  @JsonKey(name: 'feedback')
  String? get feedback;

  /// Tổng điểm tối đa của bài tập
  @override
  @JsonKey(name: 'total_points')
  double? get totalPoints;

  /// Map các câu trả lời theo question_id
  /// Key: question_id, Value: câu trả lời
  @override
  @JsonKey(name: 'answers')
  Map<String, dynamic> get answers;

  /// Danh sách URL của các file đã upload
  @override
  @JsonKey(name: 'uploaded_files')
  List<String> get uploadedFiles;

  /// Thời điểm tạo bài nộp
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Thời điểm cập nhật cuối cùng
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // === Extended fields from JOIN queries ===
  /// ID của session (work_sessions) - dùng để query submission_answers
  @override
  @JsonKey(name: 'session_id')
  String? get sessionId;

  /// Computed: có nộp muộn không
  @override
  @JsonKey(name: 'is_late')
  bool? get isLate;

  /// Tổng điểm
  @override
  @JsonKey(name: 'total_score')
  double? get totalScore;

  /// Profile học sinh (từ JOIN profiles)
  @override
  Map<String, dynamic>? get profiles;

  /// Distribution + assignment + class info (từ JOIN assignment_distributions)
  @override
  Map<String, dynamic>? get assignmentDistributions;

  /// Work session status (từ JOIN work_sessions)
  @override
  Map<String, dynamic>? get workSessions;

  /// Danh sách câu trả lời (từ query riêng via session_id)
  @override
  @JsonKey(name: 'submission_answers')
  List<Map<String, dynamic>>? get submissionAnswers;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

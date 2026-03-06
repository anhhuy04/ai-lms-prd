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
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
  }) : _answers = answers,
       _uploadedFiles = uploadedFiles;

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

  @override
  String toString() {
    return 'Submission(id: $id, assignmentDistributionId: $assignmentDistributionId, studentId: $studentId, status: $status, submittedAt: $submittedAt, gradedAt: $gradedAt, score: $score, feedback: $feedback, totalPoints: $totalPoints, answers: $answers, uploadedFiles: $uploadedFiles, createdAt: $createdAt, updatedAt: $updatedAt)';
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
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
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
  );

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
  DateTime? get updatedAt;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

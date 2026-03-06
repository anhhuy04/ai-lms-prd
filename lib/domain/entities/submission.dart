// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

/// Trạng thái của bài nộp
enum SubmissionStatus {
  /// Bản nháp - học sinh đang làm
  draft,

  /// Đã nộp - chờ giáo viên chấm
  submitted,

  /// Đã chấm - có điểm
  graded,
}

/// Entity cho bảng submissions - lưu trữ bài nộp của học sinh
@freezed
class Submission with _$Submission {
  const factory Submission({
    required String id,

    /// ID của bài tập được phân phối (assignment_distributions)
    @JsonKey(name: 'assignment_distribution_id') required String assignmentDistributionId,

    /// ID của học sinh nộp bài
    @JsonKey(name: 'student_id') required String studentId,

    /// Trạng thái hiện tại của bài nộp
    @JsonKey(name: 'status') @Default(SubmissionStatus.draft) SubmissionStatus status,

    /// Thời điểm nộp bài (null nếu chưa nộp)
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,

    /// Thời điểm chấm bài xong (null nếu chưa chấm)
    @JsonKey(name: 'graded_at') DateTime? gradedAt,

    /// Điểm số (null nếu chưa chấm)
    @JsonKey(name: 'score') double? score,

    /// Phản hồi từ giáo viên/AI
    @JsonKey(name: 'feedback') String? feedback,

    /// Tổng điểm tối đa của bài tập
    @JsonKey(name: 'total_points') double? totalPoints,

    /// Map các câu trả lời theo question_id
    /// Key: question_id, Value: câu trả lời
    @JsonKey(name: 'answers') @Default({}) Map<String, dynamic> answers,

    /// Danh sách URL của các file đã upload
    @JsonKey(name: 'uploaded_files') @Default([]) List<String> uploadedFiles,

    /// Thời điểm tạo bài nộp
    @JsonKey(name: 'created_at') DateTime? createdAt,

    /// Thời điểm cập nhật cuối cùng
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);
}

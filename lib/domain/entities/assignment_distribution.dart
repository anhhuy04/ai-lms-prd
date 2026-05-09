// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_distribution.freezed.dart';
part 'assignment_distribution.g.dart';

/// Entity cho bảng `assignment_distributions`.
@freezed
class AssignmentDistribution with _$AssignmentDistribution {
  const factory AssignmentDistribution({
    required String id,
    @JsonKey(name: 'assignment_id') required String assignmentId,
    @JsonKey(name: 'distribution_type') required String distributionType,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'student_ids') List<String>? studentIds,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') @Default(true) bool allowLate,
    @JsonKey(name: 'late_policy') Map<String, dynamic>? latePolicy,

    /// Cấu hình shuffle và hiển thị điểm:
    @JsonKey(name: 'settings') Map<String, dynamic>? settings,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Extended fields từ join queries
    String? className,
    String? groupName,
    String? assignmentTitle,
    /// Mẫu số "X/Y đã nộp" — tổng HS được giao bài (theo distribution_type).
    @JsonKey(name: 'recipient_count') int? recipientCount,
    /// Tử số "X/Y đã nộp" — số HS đã nộp ÍT NHẤT 1 lần (DISTINCT, đã dedupe retake).
    @JsonKey(name: 'submitted_count') int? submittedCount,
    /// Số HS có latest attempt = graded.
    @JsonKey(name: 'graded_count') int? gradedCount,
    /// Số HS có latest non-in_progress attempt nộp muộn so với due_at.
    @JsonKey(name: 'late_submission_count') int? lateSubmissionCount,
    /// Actionable Queue: số HS có latest attempt đã submit nhưng chưa graded
    /// → việc cần GV xử lý. 1 HS làm lại N lần chỉ đếm 1 lần (latest only).
    @JsonKey(name: 'pending_action_count') int? pendingActionCount,
  }) = _AssignmentDistribution;

  factory AssignmentDistribution.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDistributionFromJson(json);
}

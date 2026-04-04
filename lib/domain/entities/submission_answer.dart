// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_answer.freezed.dart';
part 'submission_answer.g.dart';

/// Entity cho bảng `submission_answers` - lưu trữ câu trả lời của học sinh cho từng câu hỏi.
@freezed
class SubmissionAnswer with _$SubmissionAnswer {
  const factory SubmissionAnswer({
    required String id,

    /// ID của phiên làm việc (work_sessions.id)
    @JsonKey(name: 'session_id') required String sessionId,

    /// ID của câu hỏi trong assignment (assignment_questions.id)
    @JsonKey(name: 'assignment_question_id') required String assignmentQuestionId,

    /// Câu trả lời của học sinh (JSON format, tùy loại câu hỏi)
    Map<String, dynamic>? answer,

    /// Điểm được chấm bởi AI
    @JsonKey(name: 'ai_score') double? aiScore,

    /// Độ tin cậy của điểm AI (0.0 - 1.0)
    @JsonKey(name: 'ai_confidence') double? aiConfidence,

    /// Phản hồi từ AI
    @JsonKey(name: 'ai_feedback') Map<String, dynamic>? aiFeedback,

    /// Điểm cuối cùng (sau khi teacher approve/override)
    @JsonKey(name: 'final_score') double? finalScore,

    /// ID của giáo viên đã chấm
    @JsonKey(name: 'graded_by') String? gradedBy,

    /// Thời điểm chấm xong
    @JsonKey(name: 'graded_at') DateTime? gradedAt,

    /// Phản hồi từ giáo viên (teacher override feedback)
    @JsonKey(name: 'teacher_feedback') Map<String, dynamic>? teacherFeedback,

    /// Thời điểm tạo
    @JsonKey(name: 'created_at') DateTime? createdAt,

    /// Thời điểm cập nhật cuối cùng
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // --- Extended fields from join queries ---

    /// Thông tin câu hỏi (từ assignment_questions join questions)
    /// Nullable - chỉ có khi query join
    Map<String, dynamic>? assignmentQuestion,

    /// ID của câu hỏi gốc (từ bảng questions)
    String? questionId,

    /// Loại câu hỏi (từ bảng questions.type)
    String? questionType,

    /// Điểm tối đa của câu hỏi
    double? points,

    /// Nội dung tùy chỉnh (custom_content từ assignment_questions)
    Map<String, dynamic>? customContent,
  }) = _SubmissionAnswer;

  factory SubmissionAnswer.fromJson(Map<String, dynamic> json) =>
      _$SubmissionAnswerFromJson(json);
}

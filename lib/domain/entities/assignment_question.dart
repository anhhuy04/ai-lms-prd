// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_question.freezed.dart';
part 'assignment_question.g.dart';

/// Entity cho bảng `assignment_questions`.
@freezed
class AssignmentQuestion with _$AssignmentQuestion {
  const factory AssignmentQuestion({
    required String id,
    @JsonKey(name: 'assignment_id') required String assignmentId,
    /// Nullable: NULL nếu câu hỏi được tạo mới, không reuse từ bank
    @JsonKey(name: 'question_id') String? questionId,
    @JsonKey(name: 'custom_content') Map<String, dynamic>? customContent,
    @Default(1) double points,
    Map<String, dynamic>? rubric,
    @JsonKey(name: 'order_idx') required int orderIdx,
  }) = _AssignmentQuestion;

  factory AssignmentQuestion.fromJson(Map<String, dynamic> json) =>
      _$AssignmentQuestionFromJson(json);
}


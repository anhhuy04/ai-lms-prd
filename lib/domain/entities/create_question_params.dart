import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_type.dart';

part 'create_question_params.freezed.dart';
part 'create_question_params.g.dart';

/// Params để tạo câu hỏi mới (Question Bank).
@freezed
class CreateQuestionParams with _$CreateQuestionParams {
  const factory CreateQuestionParams({
    required QuestionType type,
    required Map<String, dynamic> content,
    Map<String, dynamic>? answer,
    @Default(1) double defaultPoints,
    int? difficulty,
    List<String>? tags,
    @Default(false) bool isPublic,
    /// Danh sách objective_ids để link vào `question_objectives`
    List<String>? objectiveIds,
    /// Choices cho MCQ (id 0..n)
    List<Map<String, dynamic>>? choices,
  }) = _CreateQuestionParams;

  factory CreateQuestionParams.fromJson(Map<String, dynamic> json) =>
      _$CreateQuestionParamsFromJson(json);
}


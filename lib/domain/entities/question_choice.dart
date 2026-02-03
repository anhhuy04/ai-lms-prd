// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_choice.freezed.dart';
part 'question_choice.g.dart';

/// Entity cho bảng `question_choices`.
///
/// Lưu ý: PK của bảng là (id, question_id) - trong đó `id` là thứ tự 0..n.
@freezed
class QuestionChoice with _$QuestionChoice {
  const factory QuestionChoice({
    /// Thứ tự lựa chọn trong câu hỏi (0..n).
    required int id,
    @JsonKey(name: 'question_id') required String questionId,
    /// JSON nội dung choice (text/image...)
    required Map<String, dynamic> content,
    @JsonKey(name: 'is_correct') @Default(false) bool isCorrect,
  }) = _QuestionChoice;

  factory QuestionChoice.fromJson(Map<String, dynamic> json) =>
      _$QuestionChoiceFromJson(json);
}


import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_dto.freezed.dart';
part 'question_dto.g.dart';

/// Unified DTO for AI-generated/extracted questions.
///
/// Both Extraction pipeline and Generation pipeline produce this schema (D-24, D-25).
/// Pipeline agnosticism: Flutter frontend does not know which pipeline ran.
///
/// Used by StagingAreaWidget and save_questions_to_assignment RPC.
@freezed
class QuestionDTO with _$QuestionDTO {
  const factory QuestionDTO({
    // multiple_choice | true_false | short_answer
    @Default('multiple_choice') String type,

    // {"text": "Question text"} — DB questions.content jsonb
    required Map<String, dynamic> content,

    // Choices for MC/TF questions; empty for short_answer
    @Default([]) List<ChoiceDTO> choices,

    // {"correct_index": 0} for MC, {"correct_text": "..."} for TF/SA
    required Map<String, dynamic> answer,

    // INT 1-5 — matches questions.difficulty schema (NOT string 'medium')
    @Default(3) int difficulty,

    @Default([]) List<String> tags,

    // Maps to questions.default_points
    @Default(1) int defaultPoints,
  }) = _QuestionDTO;

  factory QuestionDTO.fromJson(Map<String, dynamic> json) =>
      _$QuestionDTOFromJson(json);
}

@freezed
class ChoiceDTO with _$ChoiceDTO {
  const factory ChoiceDTO({
    required int id,
    required String text,
    @Default(false) bool isCorrect,
  }) = _ChoiceDTO;

  factory ChoiceDTO.fromJson(Map<String, dynamic> json) =>
      _$ChoiceDTOFromJson(json);
}

/// Extension to convert QuestionDTO to the questions table INSERT format.
/// Note: author_id is NOT included — the save_questions_to_assignment RPC
/// adds it server-side using auth.uid().
extension QuestionDTODbExtension on QuestionDTO {
  Map<String, dynamic> toDbInsert() => {
        'type': type,
        'content': content,
        'answer': answer,
        'default_points': defaultPoints,
        'difficulty': difficulty,
        'tags': tags,
        'is_public': false,
        // Gửi choices để RPC lưu vào question_choices (format: {id, content:{text}, is_correct})
        if (choices.isNotEmpty)
          'choices': choices
              .map((c) => {
                    'id': c.id,
                    'content': {'text': c.text},
                    'is_correct': c.isCorrect,
                  })
              .toList(),
      };
}

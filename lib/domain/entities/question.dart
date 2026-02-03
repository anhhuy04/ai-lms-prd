// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_type.dart';

part 'question.freezed.dart';
part 'question.g.dart';

/// Entity cho bảng `questions`.
@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,

    /// Lưu trong DB là string (`questions.type`)
    @JsonKey(fromJson: QuestionTypeDb.fromDb, toJson: _questionTypeToJson)
    required QuestionType type,

    /// JSON rich content (text/images/latex...) - giữ dạng Map để linh hoạt.
    required Map<String, dynamic> content,

    /// JSON đáp án (tuỳ type). Nullable.
    Map<String, dynamic>? answer,
    @JsonKey(name: 'default_points') @Default(1) double defaultPoints,

    /// 1..5 (nullable)
    int? difficulty,
    List<String>? tags,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

String _questionTypeToJson(QuestionType type) => type.dbValue;

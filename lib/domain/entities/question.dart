// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_type.dart';

part 'question.freezed.dart';
part 'question.g.dart';

/// Entity cho bảng `questions`.
@freezed
class Question with _$Question {
  const Question._();

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
    @JsonKey(name: 'default_points') @Default(1.0) double defaultPoints,

    /// 1..5 (nullable)
    int? difficulty,
    @Default(<String>[]) List<String> tags,

    /// V2: Question Bank visibility. `true` = global (visible to all teachers),
    /// `false` = private (only owner). Replaces deprecated `isPublic`.
    ///
    /// Bridge v1 → v2: nếu row DB cũ chỉ có `is_public` (chưa migrate),
    /// readValue fallback sang `is_public`. Nếu row mới đã có `is_global`,
    /// giữ nguyên (precedence).
    @JsonKey(name: 'is_global', readValue: _readIsGlobal)
    @Default(false)
    bool isGlobal,

    /// V2: Origin of question — `teacher` | `ai_generated` | `imported` | ...
    @Default('teacher') String source,

    /// V2: SHA-256 hash của normalized content (for dedup).
    @JsonKey(name: 'content_hash') String? contentHash,

    /// V2: Soft delete timestamp. `null` = active.
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,

    /// Legacy v1 column — kept for backward compat reads. Use [isGlobal] instead.
    @Deprecated('Use isGlobal — removed in migration 030+')
    @JsonKey(name: 'is_public')
    @Default(false)
    bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  // ----- Derived getters -----
  bool get isActive => deletedAt == null;
  bool get isDeleted => deletedAt != null;
  bool get isAiGenerated => source == 'ai_generated';
  bool isOwnedBy(String userId) => authorId == userId;
}

String _questionTypeToJson(QuestionType type) => type.dbValue;

/// Bridge v1 → v2 ở field level: nếu JSON KHÔNG có key `is_global`,
/// fallback sang `is_public` (legacy column). Nếu có cả 2 thì `is_global`
/// thắng (precedence được đảm bảo nhờ json_serializable chỉ gọi readValue
/// khi field key tương ứng không hiện diện).
Object? _readIsGlobal(Map map, String key) {
  if (map.containsKey('is_global')) return map['is_global'];
  if (map.containsKey('is_public')) return map['is_public'];
  return null;
}

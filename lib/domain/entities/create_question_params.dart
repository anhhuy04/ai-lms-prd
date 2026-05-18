import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_source.dart';
import 'question_type.dart';

part 'create_question_params.freezed.dart';

// Const empty list with explicit type for Freezed @Default.
// Inline `<Map<String, dynamic>>[]` confuses the freezed parser
// (nested generics inside the annotation), so we hoist it out.
const List<Map<String, dynamic>> _kEmptyChoices = <Map<String, dynamic>>[];

/// Params để tạo câu hỏi mới (Question Bank).
///
/// **Task 2.4 (Question Bank Phase 2):** `source` là REQUIRED — không có default.
/// Compile-time enforce caller phải set rõ ràng (`teacher` | `aiGenerated` | ...)
/// để tránh silent drift (AI path quên set → fallback 'teacher').
///
/// **Lưu ý transition:**
/// - `isPublic` được giữ lại `@Deprecated` cho repository_impl tương thích
///   (Phase 6 sẽ migrate sang `isGlobal`).
/// - `choices` vẫn là `List<Map<String, dynamic>>` (raw map) thay vì
///   `List<QuestionChoice>` vì `QuestionChoice` yêu cầu `questionId` —
///   không thể biết tại thời điểm tạo (question chưa tồn tại).
///   Phase 6 sẽ design DTO riêng cho creation nếu cần type-safety.
/// - `fromJson` factory đã bị xoá — không có caller dùng và `QuestionSource`
///   enum serialize qua `json_serializable` sẽ drift khỏi `dbValue`.
@freezed
class CreateQuestionParams with _$CreateQuestionParams {
  const factory CreateQuestionParams({
    required QuestionType type,
    required Map<String, dynamic> content,
    required QuestionSource source,
    Map<String, dynamic>? answer,
    @Default(1.0) double defaultPoints,
    int? difficulty,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool isGlobal,

    /// **Deprecated:** dùng [isGlobal]. Giữ tạm cho repository_impl backward-compat,
    /// Phase 6 sẽ migrate.
    @Deprecated('Use isGlobal — Phase 6 migration') @Default(false) bool isPublic,

    /// Danh sách objective_ids để link vào `question_objectives`.
    @Default(<String>[]) List<String> objectiveIds,

    /// Choices cho MCQ (id 0..n). Raw map dạng:
    /// `{'id': int, 'content': {...}, 'is_correct': bool}`.
    @Default(_kEmptyChoices) List<Map<String, dynamic>> choices,
  }) = _CreateQuestionParams;
}

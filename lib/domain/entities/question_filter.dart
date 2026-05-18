import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_source.dart';
import 'question_type.dart';

part 'question_filter.freezed.dart';

/// Sort keys for question bank listing.
enum QuestionSortKey { recentlyCreated, difficulty, type, totalAttempts }

/// Value object aggregating filter/pagination/sort parameters
/// for `getQuestionsByAuthor` (and related queries) on the question bank.
@freezed
class QuestionFilter with _$QuestionFilter {
  const factory QuestionFilter({
    required String authorId,
    @Default(true) bool includeGlobal,
    @Default(false) bool includeDeleted,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    List<String>? objectiveIds,
    QuestionSource? sourceFilter,
    String? searchQuery,
    @Default(QuestionSortKey.recentlyCreated) QuestionSortKey sortBy,
    @Default(0) int page,
    @Default(20) int pageSize,
  }) = _QuestionFilter;
}

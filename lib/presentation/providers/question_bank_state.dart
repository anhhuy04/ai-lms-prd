import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/question.dart';
import '../../domain/entities/question_filter.dart';

part 'question_bank_state.freezed.dart';

@freezed
class QuestionBankState with _$QuestionBankState {
  const factory QuestionBankState({
    @Default(<Question>[]) List<Question> questions,
    @Default(false) bool hasMore,
    @Default(<String>{}) Set<String> mutatingIds,
    QuestionFilter? activeFilter,
  }) = _QuestionBankState;
}

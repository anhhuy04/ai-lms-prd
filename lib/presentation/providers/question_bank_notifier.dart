import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/create_question_params.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/question_filter.dart';
import '../../domain/failures/question_failure.dart';
import 'question_bank_providers.dart';
import 'question_bank_state.dart';

part 'question_bank_notifier.g.dart';

@riverpod
class QuestionBankNotifier extends _$QuestionBankNotifier {
  @override
  Future<QuestionBankState> build({QuestionFilter? filter}) async {
    final repo = ref.watch(questionRepositoryProvider);
    if (filter == null) {
      return const QuestionBankState();
    }
    final qs = await repo.getQuestions(filter);
    return QuestionBankState(
      questions: qs,
      activeFilter: filter,
      hasMore: qs.length >= filter.pageSize,
    );
  }

  /// Optimistic soft delete với rollback on failure.
  Future<void> softDelete(String id) async {
    final s = state.value;
    if (s == null || s.mutatingIds.contains(id)) return;
    final idx = s.questions.indexWhere((q) => q.id == id);
    if (idx < 0) return;
    final removed = s.questions[idx];

    // Optimistic remove
    state = AsyncValue.data(s.copyWith(
      questions: [...s.questions]..removeAt(idx),
      mutatingIds: {...s.mutatingIds, id},
    ));

    try {
      await ref.read(questionRepositoryProvider).softDeleteQuestion(id);
    } on QuestionFailure {
      // Rollback: re-insert at original index
      final cur = state.value!;
      state = AsyncValue.data(cur.copyWith(
        questions: [...cur.questions]
          ..insert(idx.clamp(0, cur.questions.length), removed),
        mutatingIds: cur.mutatingIds.difference({id}),
      ));
      rethrow;
    } finally {
      final cur = state.value;
      if (cur != null && cur.mutatingIds.contains(id)) {
        state = AsyncValue.data(cur.copyWith(
          mutatingIds: cur.mutatingIds.difference({id}),
        ));
      }
    }
  }

  Future<void> restore(String id) async {
    try {
      await ref.read(questionRepositoryProvider).restoreQuestion(id);
      ref.invalidateSelf();
    } on QuestionFailure {
      rethrow;
    }
  }

  Future<Question> create(CreateQuestionParams params) async {
    final q = await ref.read(questionRepositoryProvider).createQuestion(params);
    ref.invalidateSelf();
    return q;
  }
}

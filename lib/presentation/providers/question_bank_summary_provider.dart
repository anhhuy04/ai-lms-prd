import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/question_filter.dart';
import 'auth_providers.dart';
import 'question_bank_providers.dart';

part 'question_bank_summary_provider.g.dart';

class QuestionBankSummary {
  final int totalMine;
  final int totalAi;
  final int totalGlobal;

  const QuestionBankSummary({
    required this.totalMine,
    required this.totalAi,
    required this.totalGlobal,
  });

  static const empty = QuestionBankSummary(totalMine: 0, totalAi: 0, totalGlobal: 0);
}

/// Aggregated count for hub entry + drawer subtitle.
/// Single fetch up to 1000 items — adequate for current scale; replace with
/// dedicated RPC `get_question_bank_summary()` if user count exceeds.
@riverpod
Future<QuestionBankSummary> questionBankSummary(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return QuestionBankSummary.empty;
  final repo = ref.watch(questionRepositoryProvider);
  final all = await repo.getQuestions(QuestionFilter(authorId: userId, pageSize: 1000));
  final mine = all.where((q) => q.authorId == userId && q.source != 'ai_generated').length;
  final ai = all.where((q) => q.source == 'ai_generated').length;
  final global = all.where((q) => q.isGlobal).length;
  return QuestionBankSummary(totalMine: mine, totalAi: ai, totalGlobal: global);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_providers.dart';

part 'question_bank_summary_provider.g.dart';

/// Aggregated counts cho Question Bank hub card + drawer subtitle.
///
/// - [totalMine]: tổng câu hỏi của user hiện tại (alive), BAO GỒM AI-generated.
///   Đây là con số hiển thị trên card "Kho câu hỏi" trong Hub.
/// - [totalAi]: subset của totalMine có source='ai_generated'.
/// - [totalGlobal]: số câu hỏi `is_global=true` (alive) — visible cho mọi teacher.
/// - [totalTrash]: số câu hỏi của user đã soft-delete.
class QuestionBankSummary {
  final int totalMine;
  final int totalAi;
  final int totalGlobal;
  final int totalTrash;

  const QuestionBankSummary({
    required this.totalMine,
    required this.totalAi,
    required this.totalGlobal,
    required this.totalTrash,
  });

  static const empty = QuestionBankSummary(
    totalMine: 0,
    totalAi: 0,
    totalGlobal: 0,
    totalTrash: 0,
  );

  factory QuestionBankSummary.fromJson(Map<String, dynamic> json) {
    return QuestionBankSummary(
      totalMine: (json['total_mine'] as num?)?.toInt() ?? 0,
      totalAi: (json['total_ai'] as num?)?.toInt() ?? 0,
      totalGlobal: (json['total_global'] as num?)?.toInt() ?? 0,
      totalTrash: (json['total_trash'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Gọi RPC `get_question_bank_summary()` — SELECT COUNT(*) server-side,
/// scope theo `auth.uid()`. Thay thế fetch-1000-then-filter (Bug #3).
@riverpod
Future<QuestionBankSummary> questionBankSummary(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return QuestionBankSummary.empty;

  final client = Supabase.instance.client;
  final res = await client.rpc('get_question_bank_summary');
  if (res is Map) {
    return QuestionBankSummary.fromJson(Map<String, dynamic>.from(res));
  }
  return QuestionBankSummary.empty;
}

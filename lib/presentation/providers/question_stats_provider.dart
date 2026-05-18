import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'question_stats_provider.g.dart';

class QuestionStats {
  final int totalAttempts;
  final int correctCount;
  final double avgScore;
  final DateTime? lastAttempted;

  const QuestionStats({
    required this.totalAttempts,
    required this.correctCount,
    required this.avgScore,
    this.lastAttempted,
  });

  double get correctRate =>
      totalAttempts == 0 ? 0 : correctCount / totalAttempts;

  factory QuestionStats.empty() => const QuestionStats(
    totalAttempts: 0,
    correctCount: 0,
    avgScore: 0,
  );

  factory QuestionStats.fromJson(Map<String, dynamic> json) => QuestionStats(
    totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
    correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
    avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
    lastAttempted: json['last_attempted'] == null
        ? null
        : DateTime.tryParse(json['last_attempted'] as String),
  );
}

/// Family provider — fetch stats cho 1 question.
@riverpod
Future<QuestionStats> questionStats(Ref ref, String questionId) async {
  final client = Supabase.instance.client;
  final row = await client
      .from('question_stats')
      .select()
      .eq('question_id', questionId)
      .maybeSingle();
  if (row == null) return QuestionStats.empty();
  return QuestionStats.fromJson(row);
}

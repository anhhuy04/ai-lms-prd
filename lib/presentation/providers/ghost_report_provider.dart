import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/ghost_report.dart';
import 'question_bank_providers.dart';

part 'ghost_report_provider.g.dart';

/// Family provider — emit GhostReport cho 1 assignment cụ thể.
/// Auto-dispose để không leak khi navigate away.
@riverpod
Future<GhostReport> ghostReport(Ref ref, String assignmentId) {
  return ref
      .watch(questionRepositoryProvider)
      .detectGhostQuestions(assignmentId);
}

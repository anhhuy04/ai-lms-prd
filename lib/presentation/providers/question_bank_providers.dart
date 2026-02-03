import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_bank_providers.g.dart';

/// Provider cho QuestionRepository (dùng @riverpod để codegen)
@riverpod
QuestionRepository questionRepository(Ref ref) {
  throw UnimplementedError('Must override questionRepositoryProvider');
}


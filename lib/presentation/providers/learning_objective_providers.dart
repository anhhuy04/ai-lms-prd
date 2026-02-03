import 'package:ai_mls/domain/repositories/learning_objective_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learning_objective_providers.g.dart';

/// Provider cho LearningObjectiveRepository (dùng @riverpod để codegen)
@riverpod
LearningObjectiveRepository learningObjectiveRepository(Ref ref) {
  throw UnimplementedError('Must override learningObjectiveRepositoryProvider');
}


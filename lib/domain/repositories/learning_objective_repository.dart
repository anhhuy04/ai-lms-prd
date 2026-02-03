import 'package:ai_mls/domain/entities/learning_objective.dart';

/// Contract cho Learning Objectives.
abstract class LearningObjectiveRepository {
  Future<List<LearningObjective>> getObjectives({
    String? subjectCode,
  });

  Future<LearningObjective> createObjective(Map<String, dynamic> payload);
}


import '../entities/create_question_params.dart';
import '../entities/ghost_report.dart';
import '../entities/question.dart';
import '../entities/question_choice.dart';
import '../entities/question_filter.dart';
import '../entities/sync_result.dart';

abstract class QuestionRepository {
  // CRUD
  Future<Question> createQuestion(CreateQuestionParams params);
  Future<Question> updateQuestion(String id, CreateQuestionParams params);
  Future<Question?> getQuestionById(String id);
  Future<List<QuestionChoice>> getChoicesByQuestionId(String id);

  // List / search
  Future<List<Question>> getQuestions(QuestionFilter filter);

  // Soft delete
  Future<void> softDeleteQuestion(String id);
  Future<void> restoreQuestion(String id);

  // Smart Sync
  Future<Question?> checkDuplicate(String authorId, String contentHash);
  Future<GhostReport> detectGhostQuestions(String assignmentId);
  Future<SyncResult> syncAssignmentToBank(String assignmentId);
}

import '../entities/create_question_params.dart';
import '../entities/ghost_report.dart';
import '../entities/question.dart';
import '../entities/question_choice.dart';
import '../entities/question_filter.dart';
import '../entities/sync_result.dart';
import '../repositories/question_repository.dart';

class CreateQuestionUseCase {
  final QuestionRepository _repo;
  CreateQuestionUseCase(this._repo);
  Future<Question> call(CreateQuestionParams params) => _repo.createQuestion(params);
}

class UpdateQuestionUseCase {
  final QuestionRepository _repo;
  UpdateQuestionUseCase(this._repo);
  Future<Question> call(String id, CreateQuestionParams params) =>
      _repo.updateQuestion(id, params);
}

class GetQuestionBankUseCase {
  final QuestionRepository _repo;
  GetQuestionBankUseCase(this._repo);
  Future<List<Question>> call(QuestionFilter filter) => _repo.getQuestions(filter);
}

class QuestionDetail {
  final Question question;
  final List<QuestionChoice> choices;
  final List<String> objectiveIds;
  const QuestionDetail({
    required this.question,
    required this.choices,
    this.objectiveIds = const <String>[],
  });
}

class GetQuestionDetailUseCase {
  final QuestionRepository _repo;
  GetQuestionDetailUseCase(this._repo);
  Future<QuestionDetail?> call(String id) async {
    final q = await _repo.getQuestionById(id);
    if (q == null) return null;
    final choices = await _repo.getChoicesByQuestionId(q.id);
    final objectiveIds = await _repo.getObjectiveIdsByQuestionId(q.id);
    return QuestionDetail(
      question: q,
      choices: choices,
      objectiveIds: objectiveIds,
    );
  }
}

class SoftDeleteQuestionUseCase {
  final QuestionRepository _repo;
  SoftDeleteQuestionUseCase(this._repo);
  Future<void> call(String id) => _repo.softDeleteQuestion(id);
}

class RestoreQuestionUseCase {
  final QuestionRepository _repo;
  RestoreQuestionUseCase(this._repo);
  Future<void> call(String id) => _repo.restoreQuestion(id);
}

class DetectGhostQuestionsUseCase {
  final QuestionRepository _repo;
  DetectGhostQuestionsUseCase(this._repo);
  Future<GhostReport> call(String assignmentId) => _repo.detectGhostQuestions(assignmentId);
}

class SyncAssignmentToBankUseCase {
  final QuestionRepository _repo;
  SyncAssignmentToBankUseCase(this._repo);
  Future<SyncResult> call(String assignmentId) => _repo.syncAssignmentToBank(assignmentId);
}

class CheckDuplicateUseCase {
  final QuestionRepository _repo;
  CheckDuplicateUseCase(this._repo);
  Future<Question?> call(String authorId, String contentHash) =>
      _repo.checkDuplicate(authorId, contentHash);
}

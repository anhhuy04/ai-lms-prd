import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation của QuestionRepository.
/// Gộp TẤT CẢ methods vào 1 file, convert JSON → Entities và translate errors sang tiếng Việt.
class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionBankDataSource _ds;

  QuestionRepositoryImpl(this._ds);

  @override
  Future<Question> createQuestion(CreateQuestionParams params) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Bạn cần đăng nhập để tạo câu hỏi');
      }

      // 1) insert questions
      final qJson = await _ds.insertQuestion({
        'author_id': user.id,
        'type': params.type.dbValue,
        'content': params.content,
        'answer': params.answer,
        'default_points': params.defaultPoints,
        'difficulty': params.difficulty,
        'tags': params.tags,
        'is_public': params.isPublic,
      });

      final question = Question.fromJson(qJson);

      // 2) insert choices (nếu có)
      final choices = params.choices;
      if (choices != null && choices.isNotEmpty) {
        final payloads = choices.map((c) {
          final id = c['id'];
          if (id is! int) {
            throw Exception('Choice.id phải là int (0..n)');
          }
          return <String, dynamic>{
            'id': id,
            'question_id': question.id,
            'content':
                c['content'] ??
                c, // fallback: cho phép truyền trực tiếp content
            'is_correct': c['is_correct'] ?? c['isCorrect'] ?? false,
          };
        }).toList();
        await _ds.insertChoices(payloads);
      }

      // 3) insert objectives link (nếu có)
      final objectiveIds = params.objectiveIds;
      if (objectiveIds != null && objectiveIds.isNotEmpty) {
        await _ds.insertQuestionObjectives(
          objectiveIds
              .map((oid) => {'question_id': question.id, 'objective_id': oid})
              .toList(),
        );
      }

      return question;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createQuestion: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo câu hỏi');
    }
  }

  @override
  Future<Question> updateQuestion(
    String id,
    CreateQuestionParams params,
  ) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Bạn cần đăng nhập để cập nhật câu hỏi');
      }

      // 1) update questions
      final qJson = await _ds.updateQuestion(id, {
        // author_id không update
        'type': params.type.dbValue,
        'content': params.content,
        'answer': params.answer,
        'default_points': params.defaultPoints,
        'difficulty': params.difficulty,
        'tags': params.tags,
        'is_public': params.isPublic,
      });

      final question = Question.fromJson(qJson);

      // 2) replace choices
      await _ds.deleteChoicesByQuestionId(question.id);
      final choices = params.choices;
      if (choices != null && choices.isNotEmpty) {
        final payloads = choices.map((c) {
          final choiceId = c['id'];
          if (choiceId is! int) {
            throw Exception('Choice.id phải là int (0..n)');
          }
          return <String, dynamic>{
            'id': choiceId,
            'question_id': question.id,
            'content': c['content'] ?? c,
            'is_correct': c['is_correct'] ?? c['isCorrect'] ?? false,
          };
        }).toList();
        await _ds.insertChoices(payloads);
      }

      // 3) replace objectives link
      await _ds.deleteQuestionObjectivesByQuestionId(question.id);
      final objectiveIds = params.objectiveIds;
      if (objectiveIds != null && objectiveIds.isNotEmpty) {
        await _ds.insertQuestionObjectives(
          objectiveIds
              .map((oid) => {'question_id': question.id, 'objective_id': oid})
              .toList(),
        );
      }

      return question;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateQuestion(id: $id): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật câu hỏi');
    }
  }

  @override
  Future<void> deleteQuestion(String id) async {
    try {
      await _ds.deleteQuestion(id);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] deleteQuestion(id: $id): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xóa câu hỏi');
    }
  }

  @override
  Future<List<QuestionChoice>> getChoicesByQuestionId(String questionId) async {
    try {
      final rows = await _ds.getChoicesByQuestionId(questionId);
      return rows.map(QuestionChoice.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getChoicesByQuestionId(questionId: $questionId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách lựa chọn');
    }
  }

  @override
  Future<Question?> getQuestionById(String id) async {
    try {
      final row = await _ds.getQuestionById(id);
      if (row == null) return null;
      return Question.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getQuestionById(id: $id): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy thông tin câu hỏi');
    }
  }

  @override
  Future<List<Question>> getQuestionsByAuthor(
    String authorId, {
    bool includePublic = true,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final rows = await _ds.getQuestionsByAuthor(
        authorId,
        includePublic: includePublic,
        type: type,
        difficulty: difficulty,
        tags: tags,
        page: page,
        pageSize: pageSize,
      );
      return rows.map(Question.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getQuestionsByAuthor(authorId: $authorId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách câu hỏi');
    }
  }
}

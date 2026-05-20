import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/entities/create_question_params.dart';
import '../../domain/entities/ghost_report.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/question_choice.dart';
import '../../domain/entities/question_filter.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/failures/question_failure.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/question_bank_datasource.dart';

/// Implementation v2 của [QuestionRepository] (Task 3.3 — Question Bank Phase 3).
///
/// Tất cả methods được bọc qua [_guard] để map [PostgrestException] (và các
/// lỗi mạng/timeout) sang [QuestionFailure] subtypes, giữ contract đồng nhất
/// cho upper layers (use cases / notifiers).
///
/// **Deviations from the original Task 3.3 spec** (xem PHASE plan):
/// - `createQuestion` vẫn set `author_id` từ session user. Spec ban đầu dropped
///   field này nhưng `questions.author_id` là NOT NULL và không có default
///   server-side → production insert sẽ fail. Mock-based unit tests không bắt
///   được regression này.
/// - Choice payload giữ shape v1 (`{id, question_id, content, is_correct}`).
///   Spec ban đầu đề xuất `order_idx` nhưng cột không tồn tại trong schema
///   hiện tại (`question_choices` chỉ có `id, question_id, content, is_correct`).
///   Mất `is_correct` cũng sẽ phá grading.
///
/// Source / isGlobal được persist theo v2; `is_public` không còn được ghi
/// (DB trigger từ migration 020 sẽ bridge khi cần đọc).
class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionBankDataSource _ds;

  /// Resolver cho `author_id` của user hiện tại. Mặc định đọc từ
  /// `Supabase.instance.client.auth.currentUser?.id` (production). Cho phép
  /// override trong tests để tránh phụ thuộc vào Supabase init.
  final String? Function() _currentUserId;

  QuestionRepositoryImpl(
    this._ds, {
    String? Function()? currentUserIdResolver,
  }) : _currentUserId =
            currentUserIdResolver ?? _defaultCurrentUserIdResolver;

  static String? _defaultCurrentUserIdResolver() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Wrap a datasource call, normalising errors to [QuestionFailure].
  Future<T> _guard<T>(String op, Future<T> Function() task) async {
    AppLogger.info('[QuestionBank][Repo:$op] enter');
    try {
      final result = await task();
      AppLogger.info('[QuestionBank][Repo:$op] exit');
      return result;
    } on QuestionFailure {
      rethrow;
    } on PostgrestException catch (e) {
      AppLogger.warning('[QuestionBank][Repo:$op] postgrest code=${e.code}');
      throw QuestionFailure.fromPostgrest(e);
    } catch (e) {
      AppLogger.error('[QuestionBank][Repo:$op] error', error: e);
      throw QuestionFailure.fromAny(e);
    }
  }

  @override
  Future<Question> createQuestion(CreateQuestionParams params) => _guard('Create', () async {
        final userId = _currentUserId();
        if (userId == null) {
          throw PermissionDenied();
        }

        // 1) Insert questions row.
        final payload = <String, dynamic>{
          'author_id': userId,
          'type': params.type.dbValue,
          'content': params.content,
          if (params.answer != null) 'answer': params.answer,
          'default_points': params.defaultPoints,
          if (params.difficulty != null) 'difficulty': params.difficulty,
          'tags': params.tags,
          'is_global': params.isGlobal,
          'source': params.source.dbValue,
        };
        final row = await _ds.insertQuestion(payload);
        final question = Question.fromJson(row);

        // 2) Insert choices (id 0..n, with is_correct flag).
        if (params.choices.isNotEmpty) {
          final payloads = params.choices.map((c) {
            final id = c['id'];
            if (id is! int) {
              throw ArgumentError('Choice.id phải là int (0..n)');
            }
            return <String, dynamic>{
              'id': id,
              'question_id': question.id,
              'content': c['content'] ?? c,
              'is_correct': c['is_correct'] ?? c['isCorrect'] ?? false,
            };
          }).toList();
          await _ds.insertChoices(payloads);
        }

        // 3) Link objectives.
        if (params.objectiveIds.isNotEmpty) {
          await _ds.insertQuestionObjectives(
            params.objectiveIds
                .map((oid) => {
                      'question_id': question.id,
                      'objective_id': oid,
                    })
                .toList(),
          );
        }

        return question;
      });

  @override
  Future<Question> updateQuestion(String id, CreateQuestionParams params) =>
      _guard('Update', () async {
        // `source` immutable post-create — không update.
        final payload = <String, dynamic>{
          'type': params.type.dbValue,
          'content': params.content,
          if (params.answer != null) 'answer': params.answer,
          'default_points': params.defaultPoints,
          if (params.difficulty != null) 'difficulty': params.difficulty,
          'tags': params.tags,
          'is_global': params.isGlobal,
        };
        final row = await _ds.updateQuestion(id, payload);
        final question = Question.fromJson(row);

        // Replace choices.
        await _ds.deleteChoicesByQuestionId(question.id);
        if (params.choices.isNotEmpty) {
          final payloads = params.choices.map((c) {
            final choiceId = c['id'];
            if (choiceId is! int) {
              throw ArgumentError('Choice.id phải là int (0..n)');
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

        // Replace objectives link.
        await _ds.deleteQuestionObjectivesByQuestionId(question.id);
        if (params.objectiveIds.isNotEmpty) {
          await _ds.insertQuestionObjectives(
            params.objectiveIds
                .map((oid) => {
                      'question_id': question.id,
                      'objective_id': oid,
                    })
                .toList(),
          );
        }

        return question;
      });

  @override
  Future<Question?> getQuestionById(String id) => _guard('GetById', () async {
        final row = await _ds.getQuestionById(id);
        return row == null ? null : Question.fromJson(row);
      });

  @override
  Future<List<QuestionChoice>> getChoicesByQuestionId(String id) =>
      _guard('GetChoices', () async {
        final rows = await _ds.getChoicesByQuestionId(id);
        return rows.map(QuestionChoice.fromJson).toList();
      });

  @override
  Future<List<Question>> getQuestions(QuestionFilter filter) => _guard('GetList', () async {
        final rows = await _ds.getQuestions(filter);
        return rows.map(Question.fromJson).toList();
      });

  @override
  Future<void> softDeleteQuestion(String id) =>
      _guard('SoftDelete', () => _ds.softDeleteQuestion(id));

  @override
  Future<void> restoreQuestion(String id) =>
      _guard('Restore', () => _ds.restoreQuestion(id));

  @override
  Future<Question?> checkDuplicate(String authorId, String contentHash) =>
      _guard('CheckDup', () async {
        final row = await _ds.findByContentHash(authorId, contentHash);
        return row == null ? null : Question.fromJson(row);
      });

  @override
  Future<GhostReport> detectGhostQuestions(String assignmentId) =>
      _guard('DetectGhost', () async {
        final json = await _ds.detectGhostQuestions(assignmentId);
        return GhostReport.fromJson(json);
      });

  @override
  Future<SyncResult> syncAssignmentToBank(String assignmentId) =>
      _guard('Sync', () async {
        final json = await _ds.syncAssignmentToBank(assignmentId);
        return SyncResult.fromJson(json);
      });
}

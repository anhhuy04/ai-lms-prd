import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho Question Bank (questions, question_choices, question_objectives).
class QuestionBankDataSource {
  final SupabaseClient _client;
  final BaseTableDataSource _questions;
  final BaseTableDataSource _choices;
  final BaseTableDataSource _questionObjectives;

  QuestionBankDataSource(this._client)
    : _questions = BaseTableDataSource(_client, 'questions'),
      _choices = BaseTableDataSource(_client, 'question_choices'),
      _questionObjectives = BaseTableDataSource(_client, 'question_objectives');

  Future<Map<String, dynamic>> insertQuestion(Map<String, dynamic> payload) =>
      _questions.insert(payload);

  Future<Map<String, dynamic>> updateQuestion(
    String id,
    Map<String, dynamic> payload,
  ) => _questions.update(id, payload);

  Future<Map<String, dynamic>?> getQuestionById(String id) =>
      _questions.getById(id);

  Future<List<Map<String, dynamic>>> getQuestionsByAuthor(
    String authorId, {
    bool includePublic = true,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    int page = 0,
    int pageSize = 20,
  }) async {
    // BaseTableDataSource hiện chỉ hỗ trợ eq 1 cột, nên dùng query trực tiếp ở đây.
    var q = _client.from('questions').select().eq('author_id', authorId);
    if (!includePublic) {
      q = q.eq('is_public', false);
    }

    if (type != null) {
      q = q.eq('type', type.dbValue);
    }
    if (difficulty != null) {
      q = q.eq('difficulty', difficulty);
    }
    if (tags != null && tags.isNotEmpty) {
      // NOTE: any tag match (ov operator) để giống behavior client-side trước đây.
      // Nếu muốn match ALL tags, đổi sang contains('tags', tags).
      q = q.overlaps('tags', tags);
    }

    final from = page * pageSize;
    final to = from + pageSize - 1;
    final res = await q.order('created_at', ascending: false).range(from, to);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getChoicesByQuestionId(
    String questionId,
  ) async {
    final res = await _client
        .from('question_choices')
        .select()
        .eq('question_id', questionId)
        .order('id', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> insertChoices(
    List<Map<String, dynamic>> payloads,
  ) => _choices.insertMany(payloads);

  Future<void> deleteChoicesByQuestionId(String questionId) =>
      _choices.deleteWhere('question_id', questionId);

  Future<List<Map<String, dynamic>>> insertQuestionObjectives(
    List<Map<String, dynamic>> payloads,
  ) => _questionObjectives.insertMany(payloads);

  Future<void> deleteQuestionObjectivesByQuestionId(String questionId) =>
      _questionObjectives.deleteWhere('question_id', questionId);

  Future<void> deleteQuestion(String id) => _questions.delete(id);
}

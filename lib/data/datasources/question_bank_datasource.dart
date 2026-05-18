import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho Question Bank (questions, question_choices, question_objectives).
///
/// Phase 3 Task 3.2: chuyển sang soft-delete pattern (RLS migration 022 chặn
/// hard DELETE), thêm filter-driven query, content-hash dedup lookup và RPC
/// wrappers cho ghost/sync flows.
class QuestionBankDataSource {
  final SupabaseClient _client;
  final BaseTableDataSource _questions;
  final BaseTableDataSource _choices;
  final BaseTableDataSource _questionObjectives;

  QuestionBankDataSource(this._client)
    : _questions = BaseTableDataSource(_client, 'questions'),
      _choices = BaseTableDataSource(_client, 'question_choices'),
      _questionObjectives = BaseTableDataSource(_client, 'question_objectives');

  // ---------------------------------------------------------------------------
  // CRUD cơ bản (giữ nguyên — các code path khác đang dùng).
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> insertQuestion(Map<String, dynamic> payload) =>
      _questions.insert(payload);

  Future<Map<String, dynamic>> updateQuestion(
    String id,
    Map<String, dynamic> payload,
  ) => _questions.update(id, payload);

  Future<Map<String, dynamic>?> getQuestionById(String id) =>
      _questions.getById(id);

  // ---------------------------------------------------------------------------
  // Listing: filter-driven query thay cho getQuestionsByAuthor.
  // ---------------------------------------------------------------------------

  /// Liệt kê questions theo [QuestionFilter].
  ///
  /// Mặc định loại trash (`deleted_at IS NULL`); nếu `includeDeleted=true`
  /// chỉ lấy bản đã soft-delete (`deleted_at IS NOT NULL`).
  Future<List<Map<String, dynamic>>> getQuestions(QuestionFilter filter) async {
    var q = _client.from('questions').select();

    // Soft-delete filter.
    if (filter.includeDeleted) {
      q = q.not('deleted_at', 'is', null);
    } else {
      q = q.filter('deleted_at', 'is', null);
    }

    // Author scope: include_global gộp cả câu hỏi public của hệ thống.
    if (filter.includeGlobal) {
      q = q.or('author_id.eq.${filter.authorId},is_global.eq.true');
    } else {
      q = q.eq('author_id', filter.authorId);
    }

    if (filter.type != null) {
      q = q.eq('type', filter.type!.dbValue);
    }
    if (filter.difficulty != null) {
      q = q.eq('difficulty', filter.difficulty!);
    }
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      q = q.overlaps('tags', filter.tags!);
    }
    if (filter.sourceFilter != null) {
      q = q.eq('source', filter.sourceFilter!.dbValue);
    }
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      // Match trên content->>'text' để giữ tương thích legacy payload.
      // TODO Phase 5: chuyển sang FTS column khi sẵn sàng.
      q = q.ilike('content->>text', '%${filter.searchQuery}%');
    }

    final from = filter.page * filter.pageSize;
    final to = from + filter.pageSize - 1;
    final orderCol = switch (filter.sortBy) {
      QuestionSortKey.recentlyCreated => 'created_at',
      QuestionSortKey.difficulty => 'difficulty',
      QuestionSortKey.type => 'type',
      // totalAttempts cần join question_stats — Phase 5 sẽ thay.
      QuestionSortKey.totalAttempts => 'created_at',
    };
    final res = await q.order(orderCol, ascending: false).range(from, to);
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------------------------------------------------------------------------
  // Soft-delete pattern (migration 022 chặn hard DELETE qua RLS).
  // ---------------------------------------------------------------------------

  Future<void> softDeleteQuestion(String id) async {
    await _client
        .from('questions')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> restoreQuestion(String id) async {
    await _client
        .from('questions')
        .update({'deleted_at': null})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Dedup lookup: dùng cho CheckDuplicate use case.
  // ---------------------------------------------------------------------------

  /// Tìm câu hỏi sống (`deleted_at IS NULL`) của [authorId] có
  /// `content_hash == hash`. Trả về `null` nếu chưa tồn tại.
  Future<Map<String, dynamic>?> findByContentHash(
    String authorId,
    String hash,
  ) async {
    final res = await _client
        .from('questions')
        .select()
        .eq('author_id', authorId)
        .eq('content_hash', hash)
        .filter('deleted_at', 'is', null)
        .maybeSingle();
    return res;
  }

  // ---------------------------------------------------------------------------
  // Choices & objectives (giữ nguyên).
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // RPC wrappers.
  // ---------------------------------------------------------------------------

  /// Phát hiện ghost questions (câu hỏi tham chiếu trong assignment nhưng
  /// không còn trong bank).
  Future<Map<String, dynamic>> detectGhostQuestions(String assignmentId) async {
    final res = await _client.rpc(
      'detect_ghost_questions',
      params: {'p_assignment_id': assignmentId},
    );
    return Map<String, dynamic>.from(res as Map);
  }

  /// Đồng bộ câu hỏi từ assignment về question bank.
  Future<Map<String, dynamic>> syncAssignmentToBank(String assignmentId) async {
    final res = await _client.rpc(
      'sync_assignment_to_bank',
      params: {'p_assignment_id': assignmentId},
    );
    return Map<String, dynamic>.from(res as Map);
  }
}

import 'dart:async';

import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Redo Assignment — DTOs & Exceptions
// ─────────────────────────────────────────────────────────────────────────────

enum RedoBlockReason {
  closed,
  pastDue,
  notAllowed,
  maxReached,
  permission,
  sessionInProgress,
}

class RedoBlockedException implements Exception {
  const RedoBlockedException({required this.reason});
  final RedoBlockReason reason;

  @override
  String toString() => 'RedoBlockedException(reason: $reason)';
}

class RedoSessionResult {
  const RedoSessionResult({
    required this.sessionId,
    required this.attempt,
    required this.variantId,
  });
  final String sessionId;
  final int attempt;
  final String variantId;
}

class AggregatedScore {
  const AggregatedScore({
    required this.studentId,
    required this.finalScore,
    required this.attemptsCount,
    this.finalSubmissionId,
    this.finalSessionId,
  });
  final String studentId;
  final double? finalScore;
  final int attemptsCount;
  final String? finalSubmissionId;
  final String? finalSessionId;

  factory AggregatedScore.fromMap(Map<String, dynamic> m) => AggregatedScore(
        studentId: m['student_id'] as String,
        finalScore: (m['final_score'] as num?)?.toDouble(),
        attemptsCount: (m['attempts_count'] as num?)?.toInt() ?? 1,
        finalSubmissionId: m['final_submission_id'] as String?,
        finalSessionId: m['final_session_id'] as String?,
      );
}

class StudentAttemptSummary {
  const StudentAttemptSummary({
    required this.sessionId,
    required this.attempt,
    required this.sessionStatus,
    this.startedAt,
    this.submittedAt,
    this.submissionId,
    this.totalScore,
    required this.isLate,
    required this.isVoided,
  });
  final String sessionId;
  final int attempt;
  final String sessionStatus;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final String? submissionId;
  final double? totalScore;
  final bool isLate;
  final bool isVoided;

  factory StudentAttemptSummary.fromMap(Map<String, dynamic> m) =>
      StudentAttemptSummary(
        sessionId: m['session_id'] as String,
        attempt: (m['attempt'] as num).toInt(),
        sessionStatus: m['session_status'] as String? ?? 'unknown',
        startedAt: m['started_at'] != null
            ? DateTime.parse(m['started_at'] as String)
            : null,
        submittedAt: m['submitted_at'] != null
            ? DateTime.parse(m['submitted_at'] as String)
            : null,
        submissionId: m['submission_id'] as String?,
        totalScore: (m['total_score'] as num?)?.toDouble(),
        isLate: m['is_late'] as bool? ?? false,
        isVoided: m['is_voided'] as bool? ?? false,
      );
}

/// DataSource cho Assignments (assignments, assignment_questions, variants, distributions).
class AssignmentDataSource {
  final SupabaseClient _client;
  final BaseTableDataSource _assignments;
  // _assignmentQuestions (insert trực tiếp) đã bỏ — mọi ghi assignment_questions
  // đi qua RPC server-side (create/publish/replace/deep_clone/save_questions) để
  // chuẩn hoá theo khế ước Delta Override (fn_normalize_aq_content, migration 025+).
  final BaseTableDataSource _assignmentVariants;
  final BaseTableDataSource _assignmentDistributions;

  AssignmentDataSource(this._client)
    : _assignments = BaseTableDataSource(_client, 'assignments'),
      _assignmentVariants = BaseTableDataSource(_client, 'assignment_variants'),
      _assignmentDistributions = BaseTableDataSource(
        _client,
        'assignment_distributions',
      );

  Future<Map<String, dynamic>> insertAssignment(Map<String, dynamic> payload) =>
      _assignments.insert(payload);

  Future<Map<String, dynamic>> updateAssignment(
    String id,
    Map<String, dynamic> patch,
  ) => _assignments.update(id, patch);

  Future<Map<String, dynamic>?> getAssignmentById(String id) =>
      _assignments.getById(id);

  Future<List<Map<String, dynamic>>> getAssignmentsByTeacher(
    String teacherId,
  ) async {
    final res = await _client
        .from('assignments')
        .select()
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAssignmentsByClass(
    String classId,
  ) async {
    final res = await _client
        .from('assignments')
        .select()
        .eq('class_id', classId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Lấy danh sách bài tập đã distribute cho 1 lớp (teacher view).
  /// Join assignments + groups + classes để có đầy đủ thông tin.
  /// Batch fetch work_sessions để inject submission_count / graded_count.
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsByClass(
    String classId,
  ) async {
    final distRes = await _client
        .from('assignment_distributions')
        .select('*, assignments!inner(*), groups(id, name)')
        .eq('class_id', classId)
        .eq('assignments.is_published', true)
        .order('created_at', ascending: false);

    final distributions = List<Map<String, dynamic>>.from(distRes);
    if (distributions.isEmpty) return [];

    // Multi-lens stats từ RPC dedupe theo (student_id, distribution_id).
    // 1 HS làm lại N lần chỉ đếm 1. participation_count = "đã nộp ít nhất 1 lần".
    // pending_action_count = "latest session = submitted-not-graded" (cần GV xử lý).
    final statsMap = await _fetchDashboardStats(classId: classId);

    return distributions.map((dist) {
      final assignment = Map<String, dynamic>.from(dist['assignments'] as Map);
      final groupData = dist['groups'] as Map<String, dynamic>?;
      final distId = dist['id'] as String;
      final stats = statsMap[distId];

      return <String, dynamic>{
        ...assignment,
        'assignment_distribution_id': distId,
        'distribution_type': dist['distribution_type'],
        'distribution_class_id': dist['class_id'],
        'distribution_group_id': dist['group_id'],
        'distribution_group_name': groupData?['name'] as String?,
        'distribution_student_ids': dist['student_ids'],
        'distribution_due_at': dist['due_at'],
        'distribution_available_from': dist['available_from'],
        'distribution_time_limit_minutes': dist['time_limit_minutes'],
        'distribution_allow_late': dist['allow_late'],
        'distribution_settings': dist['settings'],
        // Chỉ số tiến độ: "X/Y đã nộp" với X = HS đã từng nộp, Y = mẫu số theo distribution_type.
        'submission_count': stats?['participation_count'] ?? 0,
        'graded_count': stats?['graded_count'] ?? 0,
        'total_students': stats?['total_expected'] ?? 0,
        // Chỉ số hành động: "5 bài chờ chấm/duyệt" — latest attempt submitted nhưng chưa graded.
        'pending_action_count': stats?['pending_action_count'] ?? 0,
        'late_count': stats?['late_count'] ?? 0,
      };
    }).toList();
  }

  /// Gọi RPC `get_teacher_distribution_dashboard_stats` (dedupe per student).
  /// Trả map distribution_id → {participation_count, total_expected, pending_action_count, graded_count, late_count}.
  Future<Map<String, Map<String, int>>> _fetchDashboardStats({
    String? classId,
  }) async {
    try {
      final result = await _client.rpc(
        'get_teacher_distribution_dashboard_stats',
        params: {if (classId != null) 'p_class_id': classId},
      );
      if (result == null) return {};
      final rows = List<Map<String, dynamic>>.from(result as List);
      final map = <String, Map<String, int>>{};
      for (final row in rows) {
        final distId = row['distribution_id'] as String?;
        if (distId == null) continue;
        map[distId] = {
          'participation_count': (row['participation_count'] as num?)?.toInt() ?? 0,
          'total_expected': (row['total_expected'] as num?)?.toInt() ?? 0,
          'pending_action_count':
              (row['pending_action_count'] as num?)?.toInt() ?? 0,
          'graded_count': (row['graded_count'] as num?)?.toInt() ?? 0,
          'late_count': (row['late_count'] as num?)?.toInt() ?? 0,
        };
      }
      return map;
    } catch (e, s) {
      AppLogger.error(
        '[AssignmentDatasource] _fetchDashboardStats error: $e',
        error: e,
        stackTrace: s,
      );
      return {};
    }
  }

  /// Lấy bài tập cho học sinh trong 1 lớp.
  /// Lấy tất cả distributions cho class → filter theo distribution_type:
  /// - 'class': tất cả student trong lớp đều thấy
  /// - 'individual': chỉ student nằm trong student_ids
  /// - 'group': student thuộc group_id (cần check qua group_members)
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsForStudent(
    String classId,
    String studentId,
  ) async {
    // Lấy tất cả distributions cho class này
    final distRes = await _client
        .from('assignment_distributions')
        .select('*, assignments!inner(*)')
        .eq('class_id', classId)
        .eq('assignments.is_published', true)
        .order('created_at', ascending: false);

    final distributions = List<Map<String, dynamic>>.from(distRes);

    // Lấy danh sách group mà student thuộc về (cho filter group type)
    final groupMemberRes = await _client
        .from('group_members')
        .select('group_id')
        .eq('student_id', studentId);
    final studentGroupIds = List<Map<String, dynamic>>.from(
      groupMemberRes,
    ).map((g) => g['group_id'] as String).toSet();

    // Filter distributions mà student được quyền xem
    final visibleDistributions = distributions.where((dist) {
      final distType = dist['distribution_type'] as String?;

      switch (distType) {
        case 'class':
          // Tất cả student trong lớp đều thấy
          return true;
        case 'individual':
          // Chỉ student nằm trong student_ids
          final studentIds = dist['student_ids'];
          if (studentIds is List) {
            return studentIds.contains(studentId);
          }
          return false;
        case 'group':
          // Student thuộc group được chỉ định
          final groupId = dist['group_id'] as String?;
          return groupId != null && studentGroupIds.contains(groupId);
        default:
          return false;
      }
    }).toList();

    // Fetch work_sessions của student cho các distributions này
    final distIds = visibleDistributions.map((d) => d['id'] as String).toList();
    Map<String, Map<String, dynamic>> sessionByDistId = {};
    Map<String, num?> scoreByDistId = {};
    if (distIds.isNotEmpty) {
      // Lấy session status từ work_sessions (không có total_score ở bảng này)
      final sessionsRes = await _client
          .from('work_sessions')
          .select('assignment_distribution_id, status, submitted_at')
          .inFilter('assignment_distribution_id', distIds)
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);
      for (final s in List<Map<String, dynamic>>.from(sessionsRes)) {
        final distId = s['assignment_distribution_id'] as String;
        // Ưu tiên status cao hơn: graded > submitted > in_progress
        if (!sessionByDistId.containsKey(distId)) {
          sessionByDistId[distId] = s;
        } else {
          final existing = sessionByDistId[distId]!['status'] as String?;
          final current = s['status'] as String?;
          if (existing != 'graded' && current == 'graded') {
            sessionByDistId[distId] = s;
          } else if (existing == 'in_progress' && current == 'submitted') {
            sessionByDistId[distId] = s;
          }
        }
      }

      // Dynamic Aggregation batch: mỗi distribution áp đúng score_aggregation_rule
      // của riêng nó qua RPC — không hardcode "lấy bài mới nhất".
      try {
        final batchResult = await _client.rpc(
          'get_student_final_scores_batch',
          params: {
            'p_distribution_ids': distIds,
            'p_student_id': studentId,
          },
        );
        for (final row in List<Map<String, dynamic>>.from(batchResult as List)) {
          final distId = row['distribution_id'] as String?;
          if (distId == null) continue;
          scoreByDistId[distId] = row['final_score'] as num?;
        }
      } catch (e) {
        AppLogger.warning('[AssignmentDS] Cannot fetch batch final scores: $e');
      }
    }

    // Flatten thành danh sách assignments + merge submission status
    return visibleDistributions.map((dist) {
      final assignment = Map<String, dynamic>.from(dist['assignments'] as Map);
      final session = sessionByDistId[dist['id'] as String];
      return <String, dynamic>{
        ...assignment,
        'assignment_distribution_id': dist['id'],
        'distribution_type': dist['distribution_type'],
        'distribution_due_at': dist['due_at'],
        'distribution_available_from': dist['available_from'],
        'distribution_time_limit_minutes': dist['time_limit_minutes'],
        'distribution_allow_late': dist['allow_late'],
        'distribution_settings': dist['settings'],
        'submission_status': session?['status'] ?? 'not_submitted',
        'submission_submitted_at': session?['submitted_at'],
        'score': scoreByDistId[dist['id'] as String],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAssignmentQuestions(
    String assignmentId,
  ) async {
    final res = await _client
        .from('assignment_questions')
        .select()
        .eq('assignment_id', assignmentId)
        .order('order_idx', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Track 2 (Chấm theo câu) — Lấy assignment_questions ĐÃ resolve nội dung từ
  /// question bank, dùng riêng cho màn "Chấm theo câu".
  ///
  /// KHÁC [getAssignmentQuestions] (select trần, không join bank): với câu hỏi
  /// reuse từ kho (question_id != null), `custom_content` là NULL theo khế ước
  /// Delta Override → màn chấm theo câu sẽ render trắng + suy sai loại (essay).
  /// Method này JOIN bank `questions(type, content, answer, question_choices)`
  /// và gói nội dung đã resolve vào field `custom_content` (chỉ dùng cho màn
  /// này — KHÔNG ghi DB) để [AssignmentQuestion.fromJson] parse được mà KHÔNG
  /// phải đổi entity.
  ///
  /// Khế ước precedence (gương theo getDistributionDetail + _extractQuestionType):
  /// - type:    câu bank → bank `questions.type` (custom_content KHÔNG có 'type');
  ///            câu inline → custom_content['type']. Normalize camelCase→snake_case.
  /// - text:    custom_content['override_text'] nếu có, else bank content.text.
  /// - choices: custom_content['choices'] nếu có, else bank question_choices.
  ///            Chuẩn hoá về shape màn chấm cần: {id, text, isCorrect}
  ///            (bank trả {id, content:{text}, is_correct}).
  Future<List<Map<String, dynamic>>> getAssignmentQuestionsForGrading(
    String assignmentId,
  ) async {
    // Single nested embed → tránh N+1 (mỗi câu bank không phải query riêng).
    final res = await _client
        .from('assignment_questions')
        .select(
          'id, assignment_id, question_id, points, order_idx, custom_content, rubric, '
          'questions(id, type, content, answer, question_choices(id, content, is_correct))',
        )
        .eq('assignment_id', assignmentId)
        .order('order_idx', ascending: true);

    return List<Map<String, dynamic>>.from(res)
        .map(resolveGradingRow)
        .toList();
  }

  /// Pure transform: 1 row assignment_questions (đã embed bank `questions`) →
  /// row có `custom_content` đã resolve type/text/choices theo khế ước Delta
  /// Override. Tách riêng (static, pure) để unit-test KHÔNG cần mock Supabase.
  ///
  /// Input row shape (từ embed):
  ///   {id, assignment_id, question_id, points, order_idx, custom_content, rubric,
  ///    questions: {type, content:{text}, answer,
  ///                question_choices:[{id, content:{text}, is_correct}]}}
  static Map<String, dynamic> resolveGradingRow(Map<String, dynamic> row) {
    final aq = Map<String, dynamic>.from(row);
    final bank = aq['questions'] as Map<String, dynamic>?;
    final custom = aq['custom_content'] as Map<String, dynamic>?;

    // ── type ──────────────────────────────────────────────────────────────
    String? rawType = custom?['type'] as String?;
    if (rawType == null || rawType.isEmpty) {
      rawType = bank?['type'] as String?;
    }
    final resolvedType = _normalizeQuestionType(rawType);

    // ── text ──────────────────────────────────────────────────────────────
    final bankContent = bank?['content'] as Map<String, dynamic>?;
    final resolvedText = (custom?['override_text'] as String?) ??
        (custom?['text'] as String?) ??
        (bankContent?['text']?.toString()) ??
        (custom?['question_text'] as String?) ??
        '';

    // ── choices ───────────────────────────────────────────────────────────
    // Nguồn thô: override nếu có, else bank question_choices.
    final overrideChoices = custom?['choices'] as List<dynamic>?;
    final rawChoices = (overrideChoices != null && overrideChoices.isNotEmpty)
        ? overrideChoices
        : (bank?['question_choices'] as List<dynamic>? ?? const []);
    // Chuẩn hoá MỌI nguồn về shape màn chấm cần: {id, text, isCorrect}.
    // - bank: {id, content:{text}, is_correct}
    // - override: {id, text, isCorrect} (đôi khi is_correct / content.text)
    final resolvedChoices = rawChoices.asMap().entries.map((e) {
      final idx = e.key;
      final cm = e.value as Map<String, dynamic>;
      final content = cm['content'];
      final text = cm['text']?.toString() ??
          (content is Map ? content['text']?.toString() : null) ??
          '';
      return <String, dynamic>{
        'id': cm['id'] ?? idx,
        'text': text,
        'isCorrect': cm['isCorrect'] == true || cm['is_correct'] == true,
      };
    }).toList();

    // Gói resolved vào custom_content (chỉ phục vụ render màn chấm theo câu).
    // Giữ nguyên các key gốc của custom_content nếu có (vd override_text).
    aq['custom_content'] = <String, dynamic>{
      if (custom != null) ...custom,
      'type': resolvedType,
      'text': resolvedText,
      'choices': resolvedChoices,
    };
    aq.remove('questions'); // không cần nested bank sau khi đã resolve
    return aq;
  }

  /// Normalize loại câu hỏi camelCase (dữ liệu cũ) → snake_case (chuẩn app).
  static String _normalizeQuestionType(String? rawType) {
    if (rawType == null || rawType.isEmpty) return 'essay';
    switch (rawType) {
      case 'multipleChoice':
        return 'multiple_choice';
      case 'trueFalse':
        return 'true_false';
      case 'fillBlank':
        return 'fill_blank';
      default:
        return rawType;
    }
  }

  Future<List<Map<String, dynamic>>> getDistributions(
    String assignmentId,
  ) async {
    final res = await _client
        .from('assignment_distributions')
        .select()
        .eq('assignment_id', assignmentId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getDistributionsByTeacher(
    String teacherId,
  ) async {
    // Lấy tất cả distributions của các assignments mà teacher sở hữu
    final res = await _client
        .from('assignment_distributions')
        .select('''
          *,
          assignment:assignments(title, teacher_id, is_published, total_points),
          class:classes(name)
        ''')
        .eq('assignments.teacher_id', teacherId)
        .eq('assignments.is_published', true)
        .order('created_at', ascending: false);

    final rawList = List<Map<String, dynamic>>.from(res);

    // Flatten alias fields + filter unpublished (PostgREST alias filter không đáng tin cậy)
    final distributions = <Map<String, dynamic>>[];
    for (final dist in rawList) {
      final classData = dist['class'];
      if (classData != null && classData is Map) {
        dist['className'] =
            (classData as Map<String, dynamic>)['name'] ?? 'Lớp học';
      }
      dist.remove('class');

      final assignmentData = dist['assignment'];
      bool isPublished = false;
      if (assignmentData != null && assignmentData is Map) {
        final aMap = assignmentData as Map<String, dynamic>;
        dist['assignmentTitle'] = aMap['title'];
        isPublished = aMap['is_published'] == true;
      }
      dist.remove('assignment');

      // Bỏ qua bài nháp — chỉ đưa vào danh sách bài đã published
      if (!isPublished) continue;
      distributions.add(dist);
    }

    // Multi-lens stats từ RPC dedupe theo (student, distribution).
    // submitted_count = participation (HS đã nộp ít nhất 1 lần, không phải tổng số sessions).
    // recipient_count = mẫu số theo distribution_type (class/group/individual).
    // late_submission_count = HS có latest non-in_progress session muộn so với due_at.
    final statsMap = await _fetchDashboardStats();
    for (final dist in distributions) {
      final stats = statsMap[dist['id'] as String];
      dist['submitted_count'] = stats?['participation_count'] ?? 0;
      dist['graded_count'] = stats?['graded_count'] ?? 0;
      dist['late_submission_count'] = stats?['late_count'] ?? 0;
      dist['recipient_count'] = stats?['total_expected'] ?? 0;
      dist['pending_action_count'] = stats?['pending_action_count'] ?? 0;
    }

    return distributions;
  }

  /// Tổng số HS có latest session = submitted-not-graded trên toàn bộ distribution của giáo viên.
  /// Dùng RPC dedupe (per-student per-dist), KHÔNG đếm raw work_sessions.
  /// 1 HS làm lại 3 lần chỉ tính 1 (theo latest attempt).
  Future<int> getPendingSubmissionsCount(String teacherId) async {
    try {
      final stats = await _fetchDashboardStats();
      return stats.values.fold<int>(
        0,
        (sum, s) => sum + (s['pending_action_count'] ?? 0),
      );
    } catch (e, s) {
      AppLogger.error(
        '🔴 getPendingSubmissionsCount: $e',
        error: e,
        stackTrace: s,
      );
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getVariants(String assignmentId) async {
    return _assignmentVariants.getAll(
      column: 'assignment_id',
      value: assignmentId,
      orderBy: 'created_at',
      ascending: true,
    );
  }

  Future<void> deleteAssignment(String id) => _assignments.delete(id);

  /// Insert một distribution record mới vào bảng `assignment_distributions`.
  Future<Map<String, dynamic>> insertDistribution(
    Map<String, dynamic> payload,
  ) => _assignmentDistributions.insert(payload);

  /// Cập nhật cấu hình distribution (PATCH) — chỉ update các field liên quan đến config.
  Future<Map<String, dynamic>> updateDistribution(
    String distributionId,
    Map<String, dynamic> patch,
  ) => _assignmentDistributions.update(distributionId, patch);

  /// Replace toàn bộ questions của assignment (simple & predictable).
  ///
  /// Uỷ thác cho RPC server-side `replace_assignment_questions` (migration 026):
  /// - Chuẩn hoá MỌI câu qua `fn_normalize_aq_content` để tuân thủ khế ước
  ///   Delta Override (bank private → cắt link; bank global → diff; inline → full).
  ///   Bắt buộc, vì constraint `aq_bank_linked_must_be_delta` sẽ chặn câu
  ///   bank-linked còn full payload (có key 'type').
  /// - Guard work_sessions ở server: đã có học sinh làm → update câu hiện có +
  ///   insert câu mới (KHÔNG xoá, tránh vỡ FK submission_answers); chưa có →
  ///   replace toàn bộ.
  Future<void> replaceAssignmentQuestions(
    String assignmentId,
    List<Map<String, dynamic>> items,
  ) async {
    await _client.rpc(
      'replace_assignment_questions',
      params: <String, dynamic>{
        'p_assignment_id': assignmentId,
        'p_questions': items,
      },
    );
  }

  /// Replace toàn bộ distributions của assignment.
  Future<void> replaceDistributions(
    String assignmentId,
    List<Map<String, dynamic>> items,
  ) async {
    await _assignmentDistributions.deleteWhere('assignment_id', assignmentId);
    if (items.isEmpty) return;
    await _assignmentDistributions.insertMany(items);
  }

  /// RPC create_assignment_with_questions: tạo assignment + gắn câu hỏi trong 1 transaction.
  Future<String> createAssignmentWithQuestionsRpc({
    required String teacherId,
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
  }) async {
    final payload = <String, dynamic>{
      'assignment': assignment,
      'questions': questions,
    };

    final res = await _client.rpc(
      'create_assignment_with_questions',
      params: <String, dynamic>{
        'p_teacher_id': teacherId,
        'p_payload': payload,
      },
    );

    // Function trả về uuid => Supabase decode thành String
    return res as String;
  }

  /// RPC publish assignment trong 1 transaction server-side.
  Future<Map<String, dynamic>> publishAssignmentRpc({
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> distributions,
  }) async {
    final res = await _client.rpc(
      'publish_assignment',
      params: <String, dynamic>{
        'p_assignment': assignment,
        'p_questions': questions,
        'p_distributions': distributions,
      },
    );

    // Function returns jsonb => supabase_flutter decode thành Map.
    return Map<String, dynamic>.from(res as Map);
  }

  /// Get assignment statistics for teacher
  Future<Map<String, dynamic>> getAssignmentStatistics(String teacherId) async {
    // Query tất cả assignments của teacher
    final allAssignmentsRes = await _client
        .from('assignments')
        .select('id, is_published')
        .eq('teacher_id', teacherId);
    final allAssignments = List<Map<String, dynamic>>.from(allAssignmentsRes);
    final assignmentIds = allAssignments.map((e) => e['id'] as String).toList();

    final totalAssignments = allAssignments.length;
    final creatingCount = allAssignments
        .where((e) => e['is_published'] == false)
        .length;
    final publishedIds = allAssignments
        .where((e) => e['is_published'] == true)
        .map((e) => e['id'] as String)
        .toList();

    if (assignmentIds.isEmpty) {
      return {
        'total_assignments': totalAssignments,
        'ungraded_assignments': 0,
        'creating_count': creatingCount,
        'distributing_count': 0,
        'waiting_to_assign': 0,
        'assigned': 0,
        'in_progress': 0,
        'in_progress_classes': 0,
        'ungraded': 0,
        'graded': 0,
        'total_submissions': 0,
        'late_submissions': 0,
        'dists_with_late': 0,
      };
    }

    // Query distributions (bao gồm id và class_id để map muộn → lớp)
    final allDistributionsRes = await _client
        .from('assignment_distributions')
        .select('id, assignment_id, class_id, due_at, status');
    final allDistributions = List<Map<String, dynamic>>.from(
      allDistributionsRes,
    );
    final distributions = allDistributions
        .where((e) => assignmentIds.contains(e['assignment_id'] as String? ?? ''))
        .toList();
    final distributedIds = distributions
        .map((e) => e['assignment_id'] as String)
        .toSet();

    final distributingCount = distributedIds.length;
    final waitingToAssign = publishedIds
        .where((id) => !distributedIds.contains(id))
        .length;

    // inProgress: chỉ đếm distributions của bài đã publish (giống detail page)
    final publishedIdSet = publishedIds.toSet();
    final now = DateTime.now();
    final inProgressDists = distributions.where((e) {
      if (e['status'] != 'active') return false;
      // Bỏ qua bài chưa publish — detail page dùng is_published=true
      if (!publishedIdSet.contains(e['assignment_id'] as String? ?? '')) {
        return false;
      }
      final dueAt = e['due_at'];
      if (dueAt == null) return true;
      try {
        return DateTime.parse(dueAt as String).isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();
    final inProgress = inProgressDists.length;
    final inProgressClasses = inProgressDists
        .map((e) => e['class_id'] as String?)
        .whereType<String>()
        .toSet()
        .length;

    // Map distribution_id → class_id để tính "lớp có nộp muộn"
    final distToClass = <String, String>{};
    for (final d in distributions) {
      final id = d['id'] as String?;
      final classId = d['class_id'] as String?;
      if (id != null && classId != null) distToClass[id] = classId;
    }

    // Query submissions — thêm student_id để deduplicate retake
    final allSubmissionsRes = await _client
        .from('submissions')
        .select('student_id, assignment_id, assignment_distribution_id, is_late')
        .eq('is_voided', false);
    final allSubmissions = List<Map<String, dynamic>>.from(allSubmissionsRes);
    final teacherSubmissions = allSubmissions
        .where((e) => assignmentIds.contains(e['assignment_id'] as String? ?? ''))
        .toList();

    // Deduplicate: 1 học sinh có thể làm lại → dùng unique (student_id, dist_id)
    final uniqueSubmitters = <String>{};
    final lateDistIds = <String>{};
    for (final s in teacherSubmissions) {
      final studentId = s['student_id'] as String?;
      final distId = s['assignment_distribution_id'] as String?;
      if (studentId == null || distId == null) continue;
      uniqueSubmitters.add('$studentId:$distId');
      if (s['is_late'] == true) lateDistIds.add(distId);
    }
    final totalSubmissions = uniqueSubmitters.length;
    // lateSubmissions: số unique (student, dist) có is_late=true
    final lateSubmitterKeys = <String>{};
    for (final s in teacherSubmissions) {
      if (s['is_late'] != true) continue;
      final studentId = s['student_id'] as String?;
      final distId = s['assignment_distribution_id'] as String?;
      if (studentId != null && distId != null) {
        lateSubmitterKeys.add('$studentId:$distId');
      }
    }
    final lateSubmissions = lateSubmitterKeys.length;
    // distsWithLate: số lớp (class_id) có ít nhất 1 học sinh nộp muộn
    final lateClassIds = lateDistIds
        .map((distId) => distToClass[distId])
        .whereType<String>()
        .toSet();
    final distsWithLate = lateClassIds.length;

    const ungraded = 0;
    const graded = 0;

    return {
      'total_assignments': totalAssignments,
      'ungraded_assignments': ungraded,
      'creating_count': creatingCount,
      'distributing_count': distributingCount,
      'waiting_to_assign': waitingToAssign,
      'assigned': distributingCount,
      'in_progress': inProgress,
      'in_progress_classes': inProgressClasses,
      'ungraded': ungraded,
      'graded': graded,
      'total_submissions': totalSubmissions,
      'late_submissions': lateSubmissions,
      'dists_with_late': distsWithLate,
    };
  }

  /// Get recent activities (assignments) for teacher
  /// Returns assignments ordered by updated_at (most recent first)
  Future<List<Map<String, dynamic>>> getRecentActivities(
    String teacherId, {
    int limit = 10,
  }) async {
    final res = await _client
        .from('assignments')
        .select()
        .eq('teacher_id', teacherId)
        .order('updated_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Lấy chi tiết distribution kèm assignment info và danh sách câu hỏi.
  /// Trả về Map với cấu trúc:
  /// - assignment: thông tin bài tập (title, description, total_points)
  /// - questions: danh sách câu hỏi (content, type, points)
  /// - distribution: thông tin phân phối (due_at, status, ...)
  /// - submission: thông tin bài nộp (nếu có)
  Future<Map<String, dynamic>> getDistributionDetail(
    String distributionId, {
    String? studentId,
    String? sessionId,
  }) async {
    try {
      // Bước 1: Lấy distribution và assignment
      final distRes = await _client
          .from('assignment_distributions')
          .select(
            '*, assignments(id, title, description, total_points, is_published)',
          )
          .eq('id', distributionId)
          .maybeSingle();

      if (distRes == null) {
        return {
          'assignment': {
            'title': 'Không tìm thấy',
            'description': null,
            'total_points': 0,
          },
          'questions': <Map<String, dynamic>>[],
          'distribution': <String, dynamic>{},
        };
      }

      final rawData = Map<String, dynamic>.from(distRes);
      final assignments = rawData['assignments'] as Map<String, dynamic>?;
      final assignmentId = assignments?['id'] as String?;

      // Bước 2: Lấy câu hỏi của bài tập (nếu có assignment_id)
      List<Map<String, dynamic>> questions = [];
      if (assignmentId != null) {
        // Lấy assignment_questions đơn giản trước
        final aqRes = await _client
            .from('assignment_questions')
            .select(
              'id, assignment_id, question_id, points, order_idx, custom_content, rubric',
            )
            .eq('assignment_id', assignmentId)
            .order('order_idx');

        // Nếu có assignment_questions, lấy chi tiết questions
        if ((aqRes as List).isNotEmpty) {
          final questionIds = (aqRes as List)
              .map((e) => e['question_id'] as String?)
              .whereType<String>()
              .toList();

          // Lấy tất cả question_ids từ question bank (đã được lọc ở trên)
          final validQuestionIds = questionIds;

          Map<String, Map<String, dynamic>> questionBankData = {};
          if (validQuestionIds.isNotEmpty) {
            // Query từng question một từ question bank
            for (final qId in validQuestionIds) {
              try {
                final qDetail = await _client
                    .from('questions')
                    .select(
                      'id, type, content, answer, default_points, question_choices(id, content, is_correct)',
                    )
                    .eq('id', qId)
                    .maybeSingle();

                if (qDetail != null) {
                  questionBankData[qId] = qDetail;
                }
              } catch (e) {
                // Silently ignore question fetch errors
              }
            }
          }

          // Xử lý từng assignment_question
          for (final aq in aqRes) {
            final qId = aq['question_id'] as String?;
            final customContent =
                aq['custom_content']; // JSON content khi tạo mới

            if (qId != null && questionBankData.containsKey(qId)) {
              // Case 1: Câu hỏi từ question bank
              // Delta Override Pattern: custom_content chứa các thay đổi so với bank gốc.
              // Luôn dùng bank làm nền, sau đó apply override lên trên.
              final qDetail = questionBankData[qId]!;
              final qContent =
                  qDetail['content'] as Map<String, dynamic>? ?? {};
              final qAnswer = qDetail['answer'] as Map<String, dynamic>? ?? {};

              // Resolved content = bank content + custom_content overrides
              final resolvedContent = Map<String, dynamic>.from(qContent);
              final bankChoices =
                  List<dynamic>.from(qDetail['question_choices'] ?? []);
              List<dynamic> resolvedChoices = bankChoices;

              if (customContent != null) {
                final overrideText =
                    customContent['override_text'] as String?;
                if (overrideText != null && overrideText.isNotEmpty) {
                  resolvedContent['text'] = overrideText;
                }
                final overrideChoices =
                    customContent['choices'] as List<dynamic>?;
                // Merge override choices with bank choice IDs to preserve
                // shuffle compatibility: assignment_variants.shuffled_choices
                // stores bank question_choices.id (DB PKs), so resolved choices
                // must keep those same IDs for the byId lookup in QuestionState.fromJson.
                if (overrideChoices != null &&
                    overrideChoices.isNotEmpty &&
                    overrideChoices.length == bankChoices.length) {
                  resolvedChoices =
                      overrideChoices.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value as Map<String, dynamic>;
                    final bankChoice =
                        bankChoices[idx] as Map<String, dynamic>;
                    return <String, dynamic>{
                      // Keep bank ID so shuffled_choices mapping still works
                      'id': bankChoice['id'],
                      'content': {'text': c['text'] ?? ''},
                      'is_correct':
                          c['isCorrect'] ?? c['is_correct'] ?? false,
                    };
                  }).toList();
                } else if (overrideChoices != null &&
                    overrideChoices.isNotEmpty) {
                  // Choice count changed — can't align with bank IDs;
                  // use idx IDs (shuffle won't work but content is correct)
                  resolvedChoices =
                      overrideChoices.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value as Map<String, dynamic>;
                    return <String, dynamic>{
                      'id': c['id'] is int ? c['id'] : idx,
                      'content': {'text': c['text'] ?? ''},
                      'is_correct':
                          c['isCorrect'] ?? c['is_correct'] ?? false,
                    };
                  }).toList();
                }
              }

              questions.add({
                'id': aq['id'],
                'question_id': qId,
                'content': resolvedContent,
                'answer': qAnswer,
                'type': qDetail['type'],
                'points': aq['points'],
                'order_idx': aq['order_idx'],
                'question_choices': resolvedChoices,
                'rubric': aq['rubric'],
              });
            } else if (customContent != null) {
              // Case 2: Câu hỏi tạo mới (custom_content) - Format mới
              // Format: {"override_text": "...", "choices": [...], "ai_grading_keywords": [...], ...}
              // Convert type từ camelCase sang snake_case
              String questionType = customContent['type'] ?? 'multiple_choice';
              if (questionType == 'multipleChoice') {
                questionType = 'multiple_choice';
              } else if (questionType == 'trueFalse') {
                questionType = 'true_false';
              } else if (questionType == 'fillBlank') {
                questionType = 'fill_blank';
              }

              // Get question text - ưu tiên override_text
              final questionText =
                  customContent['override_text'] ?? customContent['text'] ?? '';

              // Transform choices - format mới: [{id: "uuid", text: "...", isCorrect: true}, ...]
              List<Map<String, dynamic>> questionChoices = [];
              final choices = customContent['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                questionChoices = choices.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final choice = entry.value as Map<String, dynamic>;
                  return {
                    'id': choice['id'] is int ? choice['id'] : idx,
                    'content': {
                      // AI-generate snapshot lưu choices shape {id, content:{text}, is_correct}
                      // (từ QuestionDTO.toDbInsert) → text nằm ở content.text, không ở text.
                      // Guard `is Map` tránh crash nếu content không phải Map.
                      'text': choice['text'] ??
                          (choice['content'] is Map
                              ? (choice['content'] as Map)['text']
                              : null) ??
                          '',
                    },
                    'is_correct':
                        choice['isCorrect'] ?? choice['is_correct'] ?? false,
                  };
                }).toList();
              }

              // Get AI grading keywords for essay/short_answer
              Map<String, dynamic>? aiGradingInfo;
              final aiKeywords =
                  customContent['ai_grading_keywords'] as List<dynamic>?;
              final expectedAnswer = customContent['expected_answer'];
              if ((aiKeywords != null && aiKeywords.isNotEmpty) ||
                  expectedAnswer != null) {
                aiGradingInfo = {
                  'ai_grading_keywords': aiKeywords,
                  'expected_answer': expectedAnswer,
                };
              }

              // Get blanks for fill_in_blank
              Map<String, dynamic>? blanksInfo;
              final blanks = customContent['blanks'] as List<dynamic>?;
              if (blanks != null && blanks.isNotEmpty) {
                blanksInfo = {'blanks': blanks};
              }

              // Get pairs/distractors for matching
              Map<String, dynamic>? matchingInfo;
              final pairs = customContent['pairs'] as List<dynamic>?;
              final distractors =
                  customContent['distractors'] as List<dynamic>?;
              if (pairs != null || distractors != null) {
                matchingInfo = {
                  if (pairs != null) 'pairs': pairs,
                  if (distractors != null) 'distractors': distractors,
                };
              }

              // Build question data
              final questionData = <String, dynamic>{
                'id': aq['id'],
                'question_id': null,
                'content': {'text': questionText},
                'type': questionType,
                'points': customContent['points'] ?? aq['points'] ?? 1,
                'order_idx': aq['order_idx'],
                'question_choices': questionChoices,
                'rubric': aq['rubric'], // D-02: rubric JSONB từ assignment_questions
              };

              // Merge additional info
              if (aiGradingInfo != null) {
                questionData.addAll(aiGradingInfo);
              }
              if (blanksInfo != null) {
                questionData.addAll(blanksInfo);
              }
              if (matchingInfo != null) {
                questionData.addAll(matchingInfo);
              }

              questions.add(questionData);
            }
          }
        }

      }

      // ── Apply variant nếu có studentId (Shuffle Architecture) ──────────────
      // BUG-1 fix: 1 student có thể có nhiều variant (mỗi attempt 1 variant
      // immutable do start_redo_session/ensure_student_variant_for_session
      // tạo). Khi có sessionId → match đúng variant của attempt đó. Khi
      // không có (legacy ensure_student_variant với session_id=NULL hoặc
      // các đường gọi cũ) → chọn variant mới nhất theo created_at để khỏi
      // throw "multiple rows".
      if (studentId != null && questions.isNotEmpty) {
        try {
          Map<String, dynamic>? variantRes;
          if (sessionId != null) {
            variantRes = await _client
                .from('assignment_variants')
                .select('custom_questions')
                .eq('assignment_id', assignmentId!)
                .eq('variant_type', 'student')
                .eq('student_id', studentId)
                .eq('session_id', sessionId)
                .maybeSingle();
          }
          // Fallback: chưa biết session, hoặc variant theo session chưa được
          // tạo (đường legacy). Chọn variant mới nhất.
          if (variantRes == null) {
            final fallback = await _client
                .from('assignment_variants')
                .select('custom_questions')
                .eq('assignment_id', assignmentId!)
                .eq('variant_type', 'student')
                .eq('student_id', studentId)
                .order('created_at', ascending: false)
                .limit(1);
            if ((fallback as List).isNotEmpty) {
              variantRes = Map<String, dynamic>.from(fallback.first as Map);
            }
          }

          if (variantRes != null) {
            final customQuestions =
                variantRes['custom_questions'] as List<dynamic>?;

            if (customQuestions != null && customQuestions.isNotEmpty) {
              final variantMap = <String, Map<String, dynamic>>{};
              for (final vq in customQuestions) {
                final vqMap = vq as Map<String, dynamic>;
                variantMap[vqMap['assignment_question_id'] as String] = vqMap;
              }

              questions = questions.map((q) {
                final aqId = q['id'] as String?;
                if (aqId == null) return q;
                final variant = variantMap[aqId];
                if (variant == null) return q;
                return {
                  ...q,
                  'display_order': variant['display_order'] as int,
                  'shuffled_choices':
                      variant['shuffled_choices'] as List<dynamic>? ?? [],
                };
              }).toList();

              questions.sort((a, b) {
                final aOrder = a['display_order'] as int? ??
                    (a['order_idx'] as int? ?? 0);
                final bOrder = b['display_order'] as int? ??
                    (b['order_idx'] as int? ?? 0);
                return aOrder.compareTo(bOrder);
              });
            }
          }
        } catch (e) {
          AppLogger.warning(
            '[AssignmentDS] Failed to apply variant for student $studentId: $e',
          );
        }
      }
      // ────────────────────────────────────────────────────────────────────────

      // Đếm sĩ số lớp từ class_members (chỉ học sinh đã duyệt)
      int totalStudents = 0;
      final classId = rawData['class_id'] as String?;
      if (classId != null) {
        try {
          final members = await _client
              .from('class_members')
              .select('student_id')
              .eq('class_id', classId)
              .eq('status', 'approved');
          totalStudents = (members as List).length;
        } catch (e, st) {
          AppLogger.error(
            '[AssignmentDS] getDistributionDetail: failed to count class_members for class=$classId',
            error: e,
            stackTrace: st,
          );
        }
      }

      // Build response với cấu trúc expected bởi UI
      return {
        'assignment': {
          'id': assignmentId,
          'title': assignments?['title'] ?? 'Bài tập',
          'description': assignments?['description'],
          'total_points': assignments?['total_points'] ?? 0,
        },
        'questions': questions,
        'distribution': {
          'due_at': rawData['due_at'],
          'status': rawData['status'],
          'available_from': rawData['available_from'],
          'time_limit_minutes': rawData['time_limit_minutes'],
          'settings': rawData['settings'],
          'allow_late': rawData['allow_late'],
          'late_policy': rawData['late_policy'],
          'class_id': classId,
          'total_students': totalStudents,
        },
      };
    } catch (e, st) {
      AppLogger.error(
        '🔴 [Datasource] getDistributionDetail error: $e',
        error: e,
        stackTrace: st,
      );
      // Return safe fallback on error
      return {
        'assignment': {
          'title': 'Lỗi tải dữ liệu',
          'description': null,
          'total_points': 0,
        },
        'questions': <Map<String, dynamic>>[],
        'distribution': <String, dynamic>{},
      };
    }
  }

  /// Lấy danh sách submissions cho 1 distribution.
  /// Query submissions với assignment_distribution_id để lấy total_score.
  /// Query profiles riêng để tránh RLS block khi dùng embedded join.
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    final res = await _client
        .from('submissions')
        .select('id, student_id, submitted_at, is_late, total_score, assignment_distribution_id')
        .eq('assignment_distribution_id', distributionId)
        .order('submitted_at', ascending: false);

    final submissions = List<Map<String, dynamic>>.from(res);

    final studentIds = submissions
        .map((s) => s['student_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (studentIds.isNotEmpty) {
      final profilesRes = await _client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', studentIds);

      final profilesMap = <String, Map<String, dynamic>>{
        for (final p in List<Map<String, dynamic>>.from(profilesRes))
          p['id'] as String: p,
      };

      for (final sub in submissions) {
        final sid = sub['student_id'] as String?;
        sub['profiles'] = sid != null ? profilesMap[sid] : null;
      }
    }

    return submissions;
  }

  /// Lấy danh sách tất cả bài tập của học sinh (từ tất cả các lớp)
  /// Query submissions table để lấy tất cả distributions mà student đã được giao
  /// Thứ hạng ưu tiên của một work_session khi 1 distribution có nhiều lần làm.
  /// graded (đã chấm) > submitted/ai_processing/pending_review (đã nộp) >
  /// in_progress (đang làm) > khác. Dùng để chọn session đại diện.
  int _sessionStatusRank(String? status) {
    switch (status) {
      case 'graded':
        return 4;
      case 'submitted':
      case 'ai_processing':
      case 'pending_review':
        return 3;
      case 'in_progress':
        return 1;
      default:
        return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentAssignments(
    String studentId,
  ) async {
    // Lấy tất cả submissions của student để biết họ được giao bài tập nào
    final submissionsRes = await _client
        .from('work_sessions')
        .select('assignment_distribution_id, status, submitted_at, attempt')
        .eq('student_id', studentId);
    final submissions = List<Map<String, dynamic>>.from(submissionsRes);

    // Một distribution có thể có NHIỀU work_session (làm lại nhiều lần).
    // Phải chọn session "tốt nhất" theo cùng convention với getSubmission:
    // ưu tiên graded > submitted/ai_processing/pending_review > in_progress,
    // hoà thì lấy attempt cao nhất. KHÔNG dùng "last-wins" vì thứ tự query
    // không xác định → một bài đã chấm có thể bị một lần làm dở (in_progress)
    // đè lên, khiến trang chủ hiện sai "đang làm" + lọt vào "sắp đến hạn".
    final submissionsByDistId = <String, Map<String, dynamic>>{};
    for (final s in submissions) {
      final distId = s['assignment_distribution_id'] as String;
      final existing = submissionsByDistId[distId];
      if (existing == null) {
        submissionsByDistId[distId] = s;
        continue;
      }
      final newRank = _sessionStatusRank(s['status'] as String?);
      final oldRank = _sessionStatusRank(existing['status'] as String?);
      if (newRank > oldRank) {
        submissionsByDistId[distId] = s;
      } else if (newRank == oldRank) {
        final newAttempt = (s['attempt'] as num?)?.toInt() ?? 0;
        final oldAttempt = (existing['attempt'] as num?)?.toInt() ?? 0;
        if (newAttempt > oldAttempt) submissionsByDistId[distId] = s;
      }
    }

    // Query class_members để lấy danh sách lớp của student
    final classMembersRes = await _client
        .from('class_members')
        .select('class_id')
        .eq('student_id', studentId)
        .eq('status', 'approved');
    final classIds = List<Map<String, dynamic>>.from(
      classMembersRes,
    ).map((c) => c['class_id'] as String).toList();

    if (classIds.isEmpty) return [];

    // Query distributions cho tất cả lớp của student
    // Lọc lấy assignment đã published
    final distRes = await _client
        .from('assignment_distributions')
        .select('*, assignments!inner(*)')
        .inFilter('class_id', classIds)
        .eq('assignments.is_published', true);

    final distributions = List<Map<String, dynamic>>.from(distRes);

    // Flatten và merge với submission status
    return distributions.map((dist) {
      final assignment = Map<String, dynamic>.from(dist['assignments'] as Map);
      final distributionId = dist['id'] as String;
      final submission =
          submissionsByDistId[distributionId] ?? <String, dynamic>{};

      return <String, dynamic>{
        ...assignment,
        'assignment_distribution_id': distributionId,
        'distribution_type': dist['distribution_type'],
        'distribution_due_at': dist['due_at'],
        'distribution_available_from': dist['available_from'],
        'distribution_time_limit_minutes': dist['time_limit_minutes'],
        'distribution_allow_late': dist['allow_late'],
        'distribution_settings': dist['settings'],
        // Merge submission info
        'submission_status': submission['status'] ?? 'not_submitted',
        'submission_score': submission['score'],
        'submission_submitted_at': submission['submitted_at'],
      };
    }).toList();
  }

  /// Chỉ ĐỌC trạng thái bài nộp — KHÔNG tạo work_session mới.
  /// Dùng cho trang chi tiết bài tập (trước khi bấm "Bắt đầu").
  /// Trả về null nếu học sinh chưa bắt đầu lần nào.
  Future<Map<String, dynamic>?> getSubmission(
    String distributionId,
    String studentId,
  ) async {
    // Lấy work_session gần nhất (ưu tiên graded > submitted > in_progress)
    final sessions = await _client
        .from('work_sessions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('attempt', ascending: false);

    if ((sessions as List).isEmpty) return null;

    // Ưu tiên graded/submitted/ai_processing hơn in_progress
    final sessionList = List<Map<String, dynamic>>.from(sessions);
    final session = sessionList.firstWhere(
      (s) => s['status'] != 'in_progress',
      orElse: () => sessionList.first,
    );

    final sessionId = session['id'] as String;
    final sessionStatus = session['status'] as String? ?? 'in_progress';
    final isSubmitted = sessionStatus == 'submitted' ||
        sessionStatus == 'graded' ||
        sessionStatus == 'ai_processing' ||
        sessionStatus == 'pending_review';

    final Map<String, dynamic> answersMap = {};
    int correctCount = 0;
    int wrongCount = 0;

    if (isSubmitted) {
      // Bài đã nộp: load từ submission_answers
      final submissionAnswers = await _client
          .from('submission_answers')
          .select('assignment_question_id, answer, final_score, ai_score')
          .eq('session_id', sessionId);

      for (final sa in submissionAnswers) {
        final qId = sa['assignment_question_id'] as String?;
        if (qId != null) answersMap[qId] = sa['answer'];
        final score = (sa['final_score'] as num?) ?? (sa['ai_score'] as num?);
        if (score != null) {
          if (score > 0) {
            correctCount++;
          } else {
            wrongCount++;
          }
        }
      }
    } else {
      // Đang làm: load từ autosave_answers
      final autosaveAnswers = await _client
          .from('autosave_answers')
          .select()
          .eq('session_id', sessionId);

      for (final aa in autosaveAnswers) {
        final qId = aa['assignment_question_id'] as String?;
        if (qId != null) answersMap[qId] = aa['answer_content'];
      }
    }

    final attemptCount = sessionList
        .where((s) => ['submitted', 'graded', 'ai_processing'].contains(s['status']))
        .length;

    final result = Map<String, dynamic>.from(session);
    result['answers'] = answersMap;
    result['uploaded_files'] = <String>[];
    result['attempt_count'] = attemptCount;
    result['answered_count'] = answersMap.length;
    result['time_taken_seconds'] = session['time_spent_seconds'];
    if (isSubmitted) {
      result['correct_count'] = correctCount;
      result['wrong_count'] = wrongCount;

      // submitted_at: lấy từ bài nộp mới nhất (chỉ dùng để hiển thị thời gian)
      try {
        final latestSub = await _client
            .from('submissions')
            .select('submitted_at')
            .eq('assignment_distribution_id', distributionId)
            .eq('student_id', studentId)
            .not('is_voided', 'eq', true)
            .order('created_at', ascending: false)
            .maybeSingle();
        if (latestSub != null) {
          result['submitted_at'] ??= latestSub['submitted_at'];
        }
      } catch (e) {
        AppLogger.warning('[AssignmentDS] Cannot fetch submitted_at: $e');
      }

      // Dynamic Aggregation: điểm cuối tính theo score_aggregation_rule từ backend.
      // RPC get_student_final_score xử lý latest/max/average/first — không bao giờ
      // hardcode "lấy bài mới nhất". Khi teacher đổi rule, tất cả học sinh thấy
      // điểm mới ngay lập tức mà không cần migrate dữ liệu.
      try {
        final finalScore = await _client.rpc(
          'get_student_final_score',
          params: {
            'p_distribution_id': distributionId,
            'p_student_id': studentId,
          },
        );
        if (finalScore != null) {
          result['score'] = finalScore as num;
        }
      } catch (e) {
        AppLogger.warning('[AssignmentDS] Cannot fetch final score via RPC: $e');
      }
    }

    return result;
  }

  /// Lấy hoặc tạo bài nộp draft cho một distribution
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    // Lấy distribution để biết assignment_id và settings (để kiểm tra maxAttempts)
    final dist = await _client
        .from('assignment_distributions')
        .select('assignment_id, settings')
        .eq('id', distributionId)
        .maybeSingle();
    if (dist == null) {
      throw Exception('Bài tập không còn tồn tại hoặc đã bị thu hồi.');
    }
    final assignmentId = dist['assignment_id'] as String;
    final settings = dist['settings'] as Map<String, dynamic>? ?? {};
    final maxAttempts = (settings['max_attempts'] as num?)?.toInt();

    // Đếm số lần đã nộp (submitted/graded) cho distribution này
    final completedSessions = await _client
        .from('work_sessions')
        .select('id')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .inFilter('status', ['submitted', 'graded', 'ai_processing']);
    final attemptCount = (completedSessions as List).length;

    // Lấy session mới nhất
    final existingRes = await _client
        .from('work_sessions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existingRes != null) {
      final sessionId = existingRes['id'] as String;
      final sessionStatus = existingRes['status'] as String? ?? 'in_progress';
      final isSubmitted = sessionStatus == 'submitted' ||
          sessionStatus == 'graded' ||
          sessionStatus == 'ai_processing';

      // BUG-3 fix: LUÔN return existing session khi đã có. Khi học sinh muốn
      // làm lại (đã nộp + còn lượt) → UI gọi RPC start_redo_session — server
      // tự gán attempt = MAX(attempt)+1 atomic + check session_in_progress.
      // KHÔNG INSERT work_sessions từ client với attempt hardcode = 1 vì sẽ
      // vi phạm UNIQUE (distribution, student, attempt).
      {
        final Map<String, dynamic> answersMap = {};
        int correctCount = 0;
        int wrongCount = 0;

        if (isSubmitted) {
          // Bài đã nộp: autosave_answers bị xóa sau khi submit
          // → load từ submission_answers để xem lại đáp án
          final submissionAnswers = await _client
              .from('submission_answers')
              .select('assignment_question_id, answer, final_score, ai_score')
              .eq('session_id', sessionId);

          for (final sa in submissionAnswers) {
            final qId = sa['assignment_question_id'] as String?;
            if (qId != null) {
              answersMap[qId] = sa['answer'];
            }
            // Tính đúng/sai từ final_score hoặc ai_score
            final score = (sa['final_score'] as num?) ?? (sa['ai_score'] as num?);
            if (score != null) {
              if (score > 0) {
                correctCount++;
              } else {
                wrongCount++;
              }
            }
          }
        } else {
          // Đang làm: load từ autosave_answers
          final autosaveAnswers = await _client
              .from('autosave_answers')
              .select()
              .eq('session_id', sessionId);

          for (final aa in autosaveAnswers) {
            final qId = aa['assignment_question_id'] as String?;
            if (qId != null) {
              answersMap[qId] = aa['answer_content'];
            }
          }
        }

        final result = Map<String, dynamic>.from(existingRes);
        result['answers'] = answersMap;
        result['uploaded_files'] = <String>[];
        result['attempt_count'] = attemptCount;
        result['max_attempts'] = maxAttempts;
        result['time_taken_seconds'] = existingRes['time_spent_seconds'];
        if (isSubmitted) {
          result['correct_count'] = correctCount;
          result['wrong_count'] = wrongCount;
        }

        // BUG-2 fix: lookup submission của ĐÚNG session này. Trước đây query
        // theo (distribution, student) có thể trả về submission của attempt
        // khác sau khi student làm lại nhiều lần.
        if (isSubmitted) {
          try {
            final submissionRow = await _client
                .from('submissions')
                .select('total_score, submitted_at')
                .eq('session_id', sessionId)
                .maybeSingle();
            if (submissionRow != null) {
              result['score'] = submissionRow['total_score'];
              result['submitted_at'] ??= submissionRow['submitted_at'];
            }
          } catch (e) {
            AppLogger.warning('[AssignmentDS] Cannot fetch submission score: $e');
          }
        }

        // ensure_student_variant cũng cần gọi khi session đã tồn tại
        // vì lần đầu tạo session có thể đã fail (thiếu SECURITY DEFINER cũ)
        // RPC idempotent — gọi nhiều lần an toàn
        if (!isSubmitted) {
          try {
            await _client.rpc('ensure_student_variant', params: {
              'p_assignment_id': assignmentId,
              'p_student_id': studentId,
            });
          } catch (e) {
            AppLogger.warning(
              '[AssignmentDS] ensure_student_variant (existing session) failed: $e',
            );
          }
        }

        return result;
      }
    }

    // Chưa có session nào → đây là LẦN ĐẦU làm bài. attempt=1 hợp lệ vì
    // UNIQUE (distribution, student, attempt) chưa có row nào để vi phạm.
    // Các attempt sau (làm lại) đi qua RPC start_redo_session.
    // NOTE: Schema only accepts 'in_progress', 'submitted', 'graded' - NOT 'draft'
    final newSubmission = await _client
        .from('work_sessions')
        .insert({
          'assignment_distribution_id': distributionId,
          'assignment_id': assignmentId,
          'student_id': studentId,
          'status': 'in_progress',
          'attempt': 1,
        })
        .select()
        .single();

    // Tạo variant ngay khi bắt đầu thi (Snapshot Architecture)
    // ensure_student_variant: idempotent — tạo 1 lần, gọi lại an toàn
    try {
      await _client.rpc('ensure_student_variant', params: {
        'p_assignment_id': assignmentId,
        'p_student_id': studentId,
      });
    } catch (e) {
      // Variant failure không block học sinh làm bài
      AppLogger.warning('[AssignmentDS] ensure_student_variant failed: $e');
    }

    final result = Map<String, dynamic>.from(newSubmission);
    result['attempt_count'] = attemptCount;
    return result;
  }

  /// Lưu bản nháp bài nộp
  Future<void> saveDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    // Get session ID first (lấy session mới nhất)
    final session = await _client
        .from('work_sessions')
        .select('id')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (session == null) {
      throw Exception('Session not found');
    }

    final sessionId = session['id'] as String;

    if (answers.isNotEmpty) {
      // Batch upsert — 1 round-trip thay vì N select + N insert/update.
      // Unique constraint (session_id, assignment_question_id) đảm bảo idempotent.
      final now = DateTime.now().toIso8601String();
      final rows = answers.entries.map((entry) => {
        'session_id': sessionId,
        'assignment_question_id': entry.key,
        'answer_content': entry.value,
        'updated_at': now,
      }).toList();

      await _client
          .from('autosave_answers')
          .upsert(rows, onConflict: 'session_id,assignment_question_id');
    }

    // Update work_sessions status
    await _client
        .from('work_sessions')
        .update({
          'status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', sessionId);
  }

  /// Nộp bài tập — wrapper có rollback. Chuyển hướng lỗi qua [_rollbackSubmit]
  /// để DB không bị "kẹt" trạng thái nửa-vời (work_session=submitted nhưng
  /// chưa có submission row, hoặc ngược lại). Sau cleanup, lỗi gốc rethrow
  /// để caller hiện snackbar "Nộp bài thất bại".
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId, {
    Map<String, int>? timeLog,
  }) async {
    // Tra session_id 1 lần ở wrapper để rollback có cái mà cleanup khi
    // _doSubmitAssignment fail giữa chừng.
    final session = await _client
        .from('work_sessions')
        .select('id')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (session == null) {
      throw Exception('Session not found');
    }
    final sessionId = session['id'] as String;

    try {
      return await _doSubmitAssignment(
        distributionId: distributionId,
        studentId: studentId,
        sessionId: sessionId,
        timeLog: timeLog,
      );
    } catch (e, st) {
      AppLogger.error(
        '🔴 [SUBMIT] failed for session=$sessionId — running rollback: $e',
        error: e,
        stackTrace: st,
      );
      // Best-effort rollback. Nếu rollback cũng lỗi, log nhưng KHÔNG nuốt lỗi
      // gốc — caller cần biết submit đã fail.
      try {
        await _rollbackSubmit(sessionId);
      } catch (rollbackErr, rollbackSt) {
        AppLogger.error(
          '🔴 [SUBMIT] rollback FAILED — DB có thể lệch: $rollbackErr',
          error: rollbackErr,
          stackTrace: rollbackSt,
        );
      }
      rethrow;
    }
  }

  /// Rollback partial submit: revert work_session về 'in_progress' và xoá các
  /// row đã chèn (submissions, ai_queue, submission_answers). KHÔNG đụng vào
  /// autosave_answers vì autosave chỉ bị xoá ở bước cuối cùng của submit
  /// thành công — giữ nguyên để student có thể nộp lại sau khi sửa lỗi mạng.
  ///
  /// Idempotent: gọi nhiều lần an toàn (DELETE/UPDATE đều WHERE rỗng → no-op).
  Future<void> _rollbackSubmit(String sessionId) async {
    // 1. Lấy id của các submission_answers đã insert cho session (để xoá
    //    ai_queue trước, vì FK ai_queue.submission_answer_id không CASCADE).
    final saRows = await _client
        .from('submission_answers')
        .select('id')
        .eq('session_id', sessionId);
    final saIds = (saRows as List)
        .map((r) => r['id'] as String?)
        .whereType<String>()
        .toList();

    // 2. Xoá ai_queue: cả entry per-answer (request_type=score/feedback) lẫn
    //    entry analysis level session (submission_answer_id=NULL).
    if (saIds.isNotEmpty) {
      try {
        await _client
            .from('ai_queue')
            .delete()
            .inFilter('submission_answer_id', saIds);
      } catch (e) {
        AppLogger.warning('[ROLLBACK] delete ai_queue per-answer failed: $e');
      }
    }
    try {
      // analysis entry: payload.session_id = sessionId (lưu trong jsonb).
      await _client
          .from('ai_queue')
          .delete()
          .filter('payload->>session_id', 'eq', sessionId);
    } catch (e) {
      AppLogger.warning('[ROLLBACK] delete ai_queue analysis failed: $e');
    }

    // 3. Xoá submissions row (CQRS receipt).
    try {
      await _client.from('submissions').delete().eq('session_id', sessionId);
    } catch (e) {
      AppLogger.warning('[ROLLBACK] delete submissions failed: $e');
    }

    // 4. Xoá submission_answers.
    if (saIds.isNotEmpty) {
      try {
        await _client
            .from('submission_answers')
            .delete()
            .eq('session_id', sessionId);
      } catch (e) {
        AppLogger.warning('[ROLLBACK] delete submission_answers failed: $e');
      }
    }

    // 5. Revert work_session về 'in_progress' nếu đã bị finalize.
    //    finalize_work_session set submitted_at + time_spent — phải clear.
    try {
      await _client.from('work_sessions').update({
        'status': 'in_progress',
        'submitted_at': null,
        'time_spent_seconds': 0,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (e) {
      AppLogger.warning('[ROLLBACK] revert work_sessions failed: $e');
    }

    AppLogger.info('[ROLLBACK] cleanup completed for session=$sessionId');
  }

  /// Internal — luồng submit nguyên gốc (6 bước). Throw on bất kỳ lỗi nào;
  /// wrapper [submitAssignment] sẽ catch + rollback.
  ///
  /// Luồng xử lý:
  /// 1️⃣  READ:       autosave_answers (Lấy toàn bộ mảng ID câu hỏi và đáp án nháp)
  /// 1.1 READ:       assignment_distributions (Lấy due_at và late_policy)
  /// 1.2 READ:       assignment_questions JOIN questions (Lấy points, type và answer gốc)
  /// 2️⃣  INSERT:     submission_answers (Ghi đáp án + Chấm ngay final_score cho MCQ)
  /// 3️⃣  UPDATE:     work_sessions (Chốt status = 'submitted', cập nhật time_spent_seconds)
  /// 4️⃣  INSERT:      submissions (Sinh biên lai CQRS: lưu total_score MCQ, chốt is_late, ai_graded = false)
  /// 5️⃣  INSERT:      ai_queue (Lọc câu Tự luận/Trả lời ngắn -> status = 'pending')
  /// 6️⃣  DELETE:     autosave_answers (Dọn dẹp Vùng đệm an toàn)
  Future<Map<String, dynamic>> _doSubmitAssignment({
    required String distributionId,
    required String studentId,
    required String sessionId,
    Map<String, int>? timeLog,
  }) async {
    // Lấy session row đầy đủ (wrapper chỉ select 'id' để xác định sessionId)
    final session = await _client
        .from('work_sessions')
        .select()
        .eq('id', sessionId)
        .single();
    // localNow: chỉ dùng cho metadata (created_at, updated_at) — KHÔNG dùng cho submitted_at.
    // submitted_at và time_spent_seconds được tính bởi finalize_work_session (server-side).
    final localNow = DateTime.now().toIso8601String();

    // ========== PRO I/O OPTIMIZATION ==========
    // 1️⃣ + 1.1 + 1.2: Parallel reads (no dependencies)
    // Instead of sequential: 50ms + 50ms + 50ms = 150ms
    // Run in parallel: max(50ms, 50ms, 50ms) = 50ms
    final autosaveFuture = _client
        .from('autosave_answers')
        .select()
        .eq('session_id', sessionId);
    final distributionFuture = _client
        .from('assignment_distributions')
        .select('due_at, allow_late, late_policy, settings')
        .eq('id', distributionId)
        .maybeSingle();

    final autosaveAnswers = await autosaveFuture;
    final distribution = await distributionFuture;

    // Read AI settings from distribution (D-11/D-12)
    final rawSettings = distribution?['settings'];
    final distSettings = rawSettings is Map
        ? Map<String, dynamic>.from(rawSettings)
        : <String, dynamic>{};
    final aiEnabled = distSettings['ai_feedback_enabled'] as bool? ?? false;
    // Phase 3: công tắc RIÊNG cho AI tự chấm tự luận (mặc định tắt → GV tự chấm tay).
    final aiGradeEssay = distSettings['ai_grade_essay'] as bool? ?? false;

    // is_late và submitted_at sẽ được tính server-side bởi finalize_work_session.
    // Không tính từ client để tránh gian lận đồng hồ máy.

    // 1.2 READ: assignment_questions JOIN questions (Lấy points, type và answer gốc)
    // This depends on autosaveAnswers, so runs after
    final questionInfoMap = <String, Map<String, dynamic>>{};

    if (autosaveAnswers.isNotEmpty) {
      // Deduplicate questionIds to avoid duplicate grading
      final questionIds = autosaveAnswers
          .map((aa) => aa['assignment_question_id'] as String?)
          .whereType<String>()
          .toSet() // Remove duplicates
          .toList();

      if (questionIds.isNotEmpty) {
        // Get assignment_questions - DON'T use !inner join because question_id is NULL for custom questions
        // Type is in custom_content.type, not questions.type
        final assignmentQuestions = await _client
            .from('assignment_questions')
            .select('id, points, question_id, custom_content')
            .inFilter('id', questionIds);

        // Get correct answers from question_choices (Cấp 2) - only for linked questions
        final questionIds2 = assignmentQuestions
            .map((aq) => aq['question_id'] as String?)
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toSet() // Use Set to avoid duplicates
            .toList();

        Map<String, List<String>> correctChoiceIdsMap = {};
        Map<String, Map<String, dynamic>> questionsAnswerMap = {};
        // Type AUTHORITATIVE của câu bank-linked (S1/S2): custom_content KHÔNG
        // chứa 'type' do constraint, nên phải lấy type từ bank questions.type
        // (gương theo getDistributionDetail). Thiếu map này → mọi câu bank bị
        // mặc định 'multiple_choice' → essay/fill_blank/matching chấm 0 điểm.
        Map<String, String> questionsTypeMap = {};

        // Lấy questions.answer cho linked questions (Cấp 3 - new)
        if (questionIds2.isNotEmpty) {
          // Lấy answer + type từ questions table
          final questionsRes = await _client
              .from('questions')
              .select('id, type, answer')
              .inFilter('id', questionIds2);

          for (final q in questionsRes) {
            final qId = q['id'] as String;
            final answer = q['answer'] as Map<String, dynamic>?;
            if (answer != null) {
              questionsAnswerMap[qId] = answer;
            }
            final bankType = q['type'] as String?;
            if (bankType != null) {
              questionsTypeMap[qId] = bankType;
            }
          }

          // Lấy correct choice IDs từ question_choices
          final choicesRes = await _client
              .from('question_choices')
              .select('id, question_id')
              .eq('is_correct', true)
              .inFilter('question_id', questionIds2);

          for (final choice in choicesRes) {
            final qId = choice['question_id'] as String;
            // question_choices.id is int (0,1,2...), convert to String for comparison
            final choiceId = choice['id'].toString();
            correctChoiceIdsMap.putIfAbsent(qId, () => []).add(choiceId);
          }
        }

        for (final aq in assignmentQuestions) {
          final aqId = aq['id'] as String;
          final questionId = aq['question_id'] as String?;
          final customContent = aq['custom_content'] as Map<String, dynamic>?;

          // Suy question type theo khế ước Delta Override:
          // - Câu bank-linked (question_id != null): type AUTHORITATIVE từ bank
          //   questions.type (custom_content câu bank KHÔNG có 'type'). Mirror
          //   getDistributionDetail.
          // - Câu inline (question_id == null): type từ custom_content['type'].
          String questionType = 'multiple_choice';
          String? rawType;
          if (questionId != null && questionId.isNotEmpty) {
            rawType = questionsTypeMap[questionId];
          }
          rawType ??= customContent?['type'] as String?;
          if (rawType != null) {
            // Convert camelCase -> snake_case (dữ liệu cũ)
            if (rawType == 'multipleChoice') {
              questionType = 'multiple_choice';
            } else if (rawType == 'trueFalse') {
              questionType = 'true_false';
            } else if (rawType == 'fillBlank') {
              questionType = 'fill_blank';
            } else {
              questionType = rawType;
            }
          }

          // Get points from custom_content.points or aq['points']
          double points = 1.0;
          if (customContent != null && customContent['points'] != null) {
            points = (customContent['points'] as num).toDouble();
          } else if (aq['points'] != null) {
            points = (aq['points'] as num).toDouble();
          }

          // Cấp 1: Ưu tiên custom_content (override) - format mới dùng 'choices'
          // Format: [{id: 0, text: "...", isCorrect: true}, ...] - id là int
          // Fallback: format cũ dùng 'options'
          Map<String, dynamic>? correctAnswer;
          final choicesList =
              customContent?['choices'] ??
              customContent?['options'] as List<dynamic>?;
          if (customContent != null && choicesList != null) {
            // Lấy các choice có isCorrect = true từ custom_content.choices
            final choices = choicesList;

            final correctChoices = <int>[];
            for (final choice in choices) {
              final c = choice as Map<String, dynamic>;
              final isCorrect =
                  c['isCorrect'] == true || c['is_correct'] == true;
              final id = c['id'];

              if (isCorrect) {
                // id là int (0, 1, 2...) - matching với question_choices.id
                if (id is int) {
                  correctChoices.add(id);
                } else if (id is String) {
                  // Fallback: parse String to int
                  final parsedId = int.tryParse(id);
                  if (parsedId != null) {
                    correctChoices.add(parsedId);
                  } else {
                    AppLogger.warning(
                      '⚠️ [SUBMIT]   → Could not parse String id: $id',
                    );
                  }
                } else {
                  AppLogger.warning(
                    '⚠️ [SUBMIT]   → Unknown id type: ${id.runtimeType}',
                  );
                }
              }
            }
            if (correctChoices.isNotEmpty) {
              correctAnswer = {'correct_choices': correctChoices};
            }
          }

          // Cấp 2: Fallback to question_choices (is_correct = true)
          if (correctAnswer == null &&
              questionId != null &&
              questionId.isNotEmpty) {
            final correctChoiceIds = correctChoiceIdsMap[questionId] ?? [];
            if (correctChoiceIds.isNotEmpty) {
              correctAnswer = {'correct_choices': correctChoiceIds};
            }
          }

          // Cấp 3: Fallback to questions.answer (new - for linked questions)
          if (correctAnswer == null &&
              questionId != null &&
              questionId.isNotEmpty) {
            final qAnswer = questionsAnswerMap[questionId];
            if (qAnswer != null) {
              // Extract correct_choice_ids from questions.answer
              final correctChoiceIds =
                  qAnswer['correct_choice_ids'] as List<dynamic>?;
              if (correctChoiceIds != null && correctChoiceIds.isNotEmpty) {
                correctAnswer = {
                  'correct_choices': correctChoiceIds
                      .map((e) => e.toString())
                      .toList(),
                  'general_explanation': qAnswer['general_explanation'],
                };
              } else if (qAnswer.containsKey('ai_grading_keywords')) {
                // Essay/short_answer - use AI grading keywords
                correctAnswer = {
                  'ai_grading_keywords': qAnswer['ai_grading_keywords'],
                  'sample_response': qAnswer['sample_response'],
                };
              }
            }
          }

          // Cấp 4: fill_blank — extract `blanks` từ customContent
          // Schema: customContent.blanks = [{id, correct_values: [...], case_sensitive}]
          if (questionType == 'fill_blank' && customContent != null) {
            final blanks = customContent['blanks'] as List<dynamic>?;
            if (blanks != null && blanks.isNotEmpty) {
              correctAnswer = {
                ...?correctAnswer,
                'blanks': blanks,
              };
            }
          }

          // Cấp 5: matching — extract `pairs` từ customContent để chấm objective.
          // Schema: customContent.pairs = [{left_text, right_text}]; cặp đúng là
          // left_text[i] → right_text[i] (distractors chỉ là nhiễu, không cần chấm).
          if (questionType == 'matching' && customContent != null) {
            final pairs = customContent['pairs'] as List<dynamic>?;
            if (pairs != null && pairs.isNotEmpty) {
              correctAnswer = {
                ...?correctAnswer,
                'pairs': pairs,
              };
            }
          }

          questionInfoMap[aqId] = {
            'type': questionType,
            'points': points,
            'answer': correctAnswer,
          };
        }
      }
    }

    // Classify assignment type from ALL questions (not just answered ones)
    // 'math' chấm như problem_solving (upload ảnh + AI/GV review)
    const essayTypes = {
      'essay',
      'short_answer',
      'fill_blank',
      'math',
      'problem_solving',
    };
    const mcqTypes = {'multiple_choice', 'true_false', 'matching'};

    bool hasEssay = false;
    bool hasMcq = false;
    for (final q in questionInfoMap.values) {
      final t = q['type'] as String? ?? '';
      if (essayTypes.contains(t)) hasEssay = true;
      if (mcqTypes.contains(t)) hasMcq = true;
    }

    // 2️⃣ Save each answer to submission_answers + Auto-grade MCQ/True-False
    double totalMcqScore = 0;

    // Phase 3: theo dõi item AI sẽ THỰC SỰ xử lý → quyết định status chính xác.
    // Chỉ essay/short_answer được AI chấm (math/problem_solving defer ở edge); feedback cho MCQ.
    bool enqueuedInScopeScore = false;
    bool enqueuedFeedback = false;

    for (final aa in autosaveAnswers) {
      final questionId = aa['assignment_question_id'] as String?;
      if (questionId == null) continue;

      final studentAnswer = aa['answer_content'] as Map<String, dynamic>?;
      final qInfo = questionInfoMap[questionId];
      final questionType = qInfo?['type'] as String?;
      final points = (qInfo?['points'] as num?)?.toDouble() ?? 1.0;
      final correctAnswer = qInfo?['answer'] as Map<String, dynamic>?;

      // Validate question type
      if (questionType == null) {
        AppLogger.warning(
          '⚠️ [SUBMIT] Question $questionId: type is null - cannot grade!',
        );
      } else if (![
        'multiple_choice',
        'true_false',
        'essay',
        'short_answer',
        'fill_blank',
        'matching',
        'math',
        'problem_solving',
      ].contains(questionType)) {
        AppLogger.warning(
          '⚠️ [SUBMIT] Question $questionId: Unknown question type "$questionType"',
        );
      }

      // Auto-grade for objective questions.
      // fill_blank: auto-grade qua correct_values (trim + case_sensitive flag).
      // Không cần AI vì là exact match có whitelist nhiều biến thể correct_values.
      double? finalScore;
      bool needsAIGrading =
          questionType == 'essay' ||
          questionType == 'short_answer' ||
          questionType == 'math' ||
          questionType == 'problem_solving';
      if (studentAnswer != null &&
          (questionType == 'multiple_choice' ||
              questionType == 'true_false' ||
              questionType == 'fill_blank')) {
        // Validation: Kiểm tra answer format
        // Tử Huyệt 5: đọc format mới (selected_choice_ids) trước, fallback cũ (selected_choices)
        final selectedChoices =
            (studentAnswer['selected_choice_ids'] as List<dynamic>?) ??
            (studentAnswer['selected_choices'] as List<dynamic>?);
        if (selectedChoices == null || selectedChoices.isEmpty) {
          AppLogger.warning(
            '⚠️ [SUBMIT] Question $questionId: No selected choices in answer',
          );
        }

        if (correctAnswer == null) {
          AppLogger.warning(
            '⚠️ [SUBMIT] Question $questionId: No correct answer found for grading!',
          );
        }

        finalScore = _gradeObjectiveQuestion(
          questionType,
          studentAnswer,
          correctAnswer,
          points,
        );

        if (finalScore == null) {
          AppLogger.warning(
            '⚠️ [SUBMIT] Question $questionId: Grading returned null - possible format mismatch',
          );
        } else if (finalScore > 0) {
          totalMcqScore += finalScore;
        }
      } else if (studentAnswer != null && questionType == 'matching') {
        // Matching: chấm objective bằng pairs (không dùng selected_choice_ids).
        if (correctAnswer == null) {
          AppLogger.warning(
            '⚠️ [SUBMIT] Question $questionId: matching không có pairs để chấm',
          );
        }
        finalScore = _gradeObjectiveQuestion(
          questionType,
          studentAnswer,
          correctAnswer,
          points,
        );
        if (finalScore != null && finalScore > 0) {
          totalMcqScore += finalScore;
        }
      }

      // Phase 3 regression guard: câu khách quan (MCQ/true_false/fill_blank/matching) được
      // chấm NGAY lúc nộp → LUÔN ghi final_score (0 nếu không chấm được), để
      // maybe_mark_session_graded không hiểu nhầm là "câu chờ duyệt" và treo session ở
      // pending_review (hành vi cũ: các câu này dẫn tới graded). Câu tự luận giữ NULL.
      final double? scoreToWrite =
          needsAIGrading ? finalScore : (finalScore ?? 0);

      // Insert to submission_answers
      final result = await _client
          .from('submission_answers')
          .insert({
            'session_id': sessionId,
            'assignment_question_id': questionId,
            'answer': studentAnswer,
            if (scoreToWrite != null) 'final_score': scoreToWrite,
          })
          .select()
          .single();

      // 5️⃣ Queue ai_queue items (D-11)
      final answerId = result['id'] as String?;
      if (answerId != null) {
        if (needsAIGrading && aiGradeEssay) {
          // Phase 3: CHỈ đẩy AI chấm khi GV bật "AI tự chấm tự luận" cho bài này.
          // essay/short_answer → AI chấm; math/problem_solving sẽ defer ở edge.
          // Tắt công tắc → không enqueue → final_score NULL → status 'submitted' (GV chấm tay).
          await _client.from('ai_queue').insert({
            'submission_answer_id': answerId,
            'request_type': 'score',
            'status': 'pending',
          });
          if (questionType == 'essay' || questionType == 'short_answer') {
            enqueuedInScopeScore = true;
          }
        } else if (aiEnabled && !needsAIGrading) {
          // MCQ with AI enabled → queue feedback explanation (D-11, 07-08)
          await _client.from('ai_queue').insert({
            'submission_answer_id': answerId,
            'request_type': 'feedback',
            'status': 'pending',
          });
          enqueuedFeedback = true;
        }
      }
    }

    // 2.5️⃣ Insert submission_answers cho các câu hỏi CHƯA trả lời (bỏ trống)
    // Lấy toàn bộ assignment_questions cho assignment này
    final assignmentId = session['assignment_id'] as String?;
    if (assignmentId == null) {
      throw Exception('Assignment ID not found in session');
    }

    final allAqRes = await _client
        .from('assignment_questions')
        .select('id, custom_content, points')
        .eq('assignment_id', assignmentId);

    // Tìm các question chưa có trong autosave
    final answeredQuestionIds = autosaveAnswers
        .map((aa) => aa['assignment_question_id'] as String?)
        .whereType<String>()
        .toSet();

    for (final aq in allAqRes) {
      final aqId = aq['id'] as String;
      if (!answeredQuestionIds.contains(aqId)) {
        // Câu này bị bỏ trống → insert empty answer
        final customContent = aq['custom_content'] as Map<String, dynamic>?;
        String questionType = customContent?['type'] as String? ?? 'essay';
        // Normalize type
        if (questionType == 'multipleChoice') questionType = 'multiple_choice';
        if (questionType == 'trueFalse') questionType = 'true_false';

        // Tạo empty answer phù hợp với loại câu hỏi
        Map<String, dynamic> emptyAnswer;
        if (questionType == 'multiple_choice' || questionType == 'true_false') {
          emptyAnswer = {'selected_choice_ids': <dynamic>[]};
        } else {
          emptyAnswer = {'text': ''};
        }

        await _client.from('submission_answers').insert({
          'session_id': sessionId,
          'assignment_question_id': aqId,
          'answer': emptyAnswer,
          'final_score': 0,
        });
      }
    }

    // 3️⃣ Finalize work_sessions — "Chiếc đồng hồ Trọng tài" (server-side timestamps)
    // Phase 3 status logic:
    //   AI sẽ xử lý (essay/short_answer score HOẶC MCQ feedback) → 'ai_processing'
    //     (edge gọi maybe_mark_session_graded để nâng pending_review/graded khi xong)
    //   hasEssay nhưng AI KHÔNG xử lý (math/problem_solving/fill_blank/toàn bỏ trống) → 'submitted'
    //     (GIỮ NGUYÊN hành vi cũ — GV chấm tay; tránh kẹt vĩnh viễn ở ai_processing)
    //   MCQ + no AI → 'graded'
    // Bug B fix: chỉ 'ai_processing' khi THỰC SỰ có item AI sẽ xử lý (score/feedback đã enqueue).
    // Nhánh cũ 'else if (aiEnabled) → ai_processing' chỉ tới được khi pure-MCQ + nộp toàn trắng
    // (không enqueue gì, chỉ có item analysis) → session kẹt ai_processing vì analysis không gọi
    // maybe_mark. Khi tới đây mọi câu đã có final_score (=0) → 'graded' là đúng.
    final String submitStatus;
    if (enqueuedInScopeScore || enqueuedFeedback) {
      submitStatus = 'ai_processing';
    } else if (hasEssay) {
      submitStatus = 'submitted';
    } else {
      submitStatus = 'graded';
    }
    AppLogger.info(
      '[SUBMIT] hasEssay=$hasEssay hasMcq=$hasMcq aiEnabled=$aiEnabled → status=$submitStatus',
    );

    // RPC chốt submitted_at = now() và tính time_spent_seconds = submitted_at − started_at
    // trên server — không nhận bất kỳ tham số thời gian nào từ client
    final timingResult = await _client.rpc('finalize_work_session', params: {
      'p_session_id': sessionId,
      'p_distribution_id': distributionId,
      'p_student_id': studentId,
      'p_status': submitStatus,
    }) as Map<String, dynamic>;

    final serverSubmittedAt = timingResult['submitted_at'] as String;
    final serverIsLate = timingResult['is_late'] as bool? ?? false;
    AppLogger.info(
      '[SUBMIT] Server timing: submitted_at=$serverSubmittedAt '
      'time_spent=${timingResult['time_spent_seconds']}s is_late=$serverIsLate',
    );

    // 4️⃣ Create/update submission record (CQRS) với server-side values
    // BUG-2 fix: query bằng session_id (mỗi attempt = 1 submission row).
    // Trước đây lookup theo (distribution, student) với .maybeSingle() gây 2
    // bệnh: (a) UPDATE đè submission của attempt cũ → mất điểm lần 1, (b)
    // throw "multiple rows" khi đã có >1 attempt. Schema submissions không
    // có UNIQUE (distribution, student) chính là vì hỗ trợ nhiều attempt.
    final existingSubmission = await _client
        .from('submissions')
        .select('id')
        .eq('session_id', sessionId)
        .maybeSingle();

    if (existingSubmission != null) {
      // Cùng session re-submit (re-grade lại): update tại chỗ.
      await _client
          .from('submissions')
          .update({
            'submitted_at': serverSubmittedAt,
            'total_score': totalMcqScore,
            'is_late': serverIsLate,
            'ai_graded': false,
            'updated_at': localNow,
          })
          .eq('id', existingSubmission['id']);
    } else {
      // Mỗi session lần đầu submit → insert row mới (giữ lịch sử attempt).
      await _client.from('submissions').insert({
        'assignment_id': assignmentId,
        'assignment_distribution_id': distributionId,
        'student_id': studentId,
        'session_id': sessionId,
        'total_score': totalMcqScore,
        'is_late': serverIsLate,
        'ai_graded': false,
        'submitted_at': serverSubmittedAt,
        'created_at': localNow,
        'updated_at': localNow,
      });
    }

    final result = await _client
        .from('work_sessions')
        .select()
        .eq('id', sessionId)
        .single();

    // 5️⃣ Cleanup: Delete autosave_answers (reduce DB size)
    await _client.from('autosave_answers').delete().eq('session_id', sessionId);

    // Phase 7: Queue analysis request for recommendations (D-15) — non-blocking
    // analysis luôn chạy bất kể ai_feedback_enabled vì đây là phân tích kỹ năng cho giáo viên,
    // không phụ thuộc vào việc giáo viên có bật feedback per-câu cho học sinh hay không.
    try {
      await _client.from('ai_queue').insert({
        'submission_answer_id': null,
        'request_type': 'analysis',
        'status': 'pending',
        'payload': {'session_id': sessionId},
      });
      // Trigger Edge Function ngay sau khi queue xong — fire & forget, không block submit
      unawaited(_triggerAiQueue(sessionId));
    } catch (e) {
      AppLogger.warning('[SUBMIT] ai_queue analysis insert failed: $e');
    }

    // Phase 7: Non-blocking submission_analytics INSERT (D-03)
    try {
      await _insertSubmissionAnalytics(
        sessionId: sessionId,
        timeLog: timeLog,
      );
    } catch (e) {
      AppLogger.warning('[SUBMIT] submission_analytics insert failed: $e');
      // Non-blocking: submission still succeeds
    }

    return Map<String, dynamic>.from(result);
  }

  /// Tạo submission_analytics với time_per_question và accuracy_by_tag (D-10)
  Future<void> _insertSubmissionAnalytics({
    required String sessionId,
    Map<String, int>? timeLog,
  }) async {
    // Get submission for this session
    final submission = await _client
        .from('submissions')
        .select('id')
        .eq('session_id', sessionId)
        .maybeSingle();
    final submissionId = submission?['id'] as String?;
    if (submissionId == null) return;

    // Get submission_answers with assignment_question data
    final answers = await _client
        .from('submission_answers')
        .select('assignment_question_id, final_score')
        .eq('session_id', sessionId);

    final aqIds = answers
        .map((a) => a['assignment_question_id'] as String?)
        .whereType<String>()
        .toList();

    if (aqIds.isEmpty) return;

    // Get tags from linked questions for accuracy_by_tag
    final aqs = await _client
        .from('assignment_questions')
        .select('id, points, question_id, questions(tags)')
        .inFilter('id', aqIds);

    // Build accuracy_by_tag
    final Map<String, List<double>> tagScores = {};
    for (final aq in aqs) {
      final aqId = aq['id'] as String;
      final points = (aq['points'] as num?)?.toDouble() ?? 0;
      if (points == 0) continue;
      final answer = answers.firstWhere(
        (a) => a['assignment_question_id'] == aqId,
        orElse: () => <String, dynamic>{},
      );
      final finalScore = (answer['final_score'] as num?)?.toDouble();
      if (finalScore == null) continue;

      final accuracy = finalScore / points;
      final questionData = aq['questions'] as Map<String, dynamic>?;
      final tags = (questionData?['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      for (final tag in tags) {
        tagScores.putIfAbsent(tag, () => []).add(accuracy);
      }
    }

    final accuracyByTag = tagScores.map(
      (tag, scores) => MapEntry(
        tag,
        scores.reduce((a, b) => a + b) / scores.length,
      ),
    );

    // Validate timeLog: sum should not exceed session time + tolerance (D-10)
    Map<String, int>? validatedTimeLog = timeLog;
    if (timeLog != null && timeLog.isNotEmpty) {
      final sessionRow = await _client
          .from('work_sessions')
          .select('time_spent_seconds')
          .eq('id', sessionId)
          .maybeSingle();
      final timeSpent = (sessionRow?['time_spent_seconds'] as num?)?.toInt();
      if (timeSpent != null) {
        final sumTimeLog = timeLog.values.fold<int>(0, (a, b) => a + b);
        if (sumTimeLog > timeSpent + 60) {
          AppLogger.warning(
            '[SUBMIT] time_log invalid: sum=$sumTimeLog > timeSpent=$timeSpent — setting null',
          );
          validatedTimeLog = null;
        }
      }
    }

    await _client.from('submission_analytics').insert({
      'submission_id': submissionId,
      'metrics': {
        'time_per_question': validatedTimeLog,
        'accuracy_by_tag': accuracyByTag.isEmpty ? null : accuracyByTag,
      },
    });

    AppLogger.debug('[SUBMIT] submission_analytics inserted for $submissionId');
  }

  /// Chấm điểm tức thì cho câu hỏi khách quan (MCQ, True-False)
  /// Trả về điểm đạt được hoặc null nếu không thể chấm
  double? _gradeObjectiveQuestion(
    String? questionType,
    Map<String, dynamic> studentAnswer,
    Map<String, dynamic>? correctAnswer,
    double maxPoints,
  ) {
    if (correctAnswer == null) return null;

    try {
      // Multiple choice: format {"selected_choices": ["choice_id"]}
      if (questionType == 'multiple_choice') {
        // Tử Huyệt 5: đọc format mới trước, fallback format cũ cho backward compat
        final selectedIds =
            ((studentAnswer['selected_choice_ids'] as List<dynamic>?) ??
                    (studentAnswer['selected_choices'] as List<dynamic>?))
                ?.map((e) => e.toString())
                .toSet() ??
            {};

        // Get correct choice IDs from answer
        // Format: {"correct_choices": ["id1", "id2"]} or {"correct_choice": "id1"}
        final correctIds = <String>{};
        if (correctAnswer['correct_choices'] != null) {
          correctIds.addAll(
            (correctAnswer['correct_choices'] as List<dynamic>).map(
              (e) => e.toString(),
            ),
          );
        } else if (correctAnswer['correct_choice'] != null) {
          correctIds.add(correctAnswer['correct_choice'].toString());
        }

        // Exact match required
        if (selectedIds.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] MCQ: No selected choices');
          return 0;
        }
        if (correctIds.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] MCQ: No correct choices found');
          return 0;
        }

        final isCorrect =
            selectedIds.length == correctIds.length &&
            selectedIds.containsAll(correctIds);

        return isCorrect ? maxPoints : 0;
      }

      // True/False: format {"selected_choices": ["true"]} or {"selected_choices": ["false"]} OR {"selected_choices": [0]} OR {"selected_choices": [1]}
      if (questionType == 'true_false') {
        // Support BOTH formats: "true"/"false" strings AND int IDs (0=true, 1=false)
        // Tử Huyệt 5: đọc format mới trước cho True/False
        final selectedChoices =
            ((studentAnswer['selected_choice_ids'] as List<dynamic>?) ??
                    (studentAnswer['selected_choices'] as List<dynamic>?))
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [];

        // Choice id là opaque (giống MCQ): so khớp id dạng String, KHÔNG remap
        // int→'true'/'false'. Student gửi selected_choice_ids = [choiceId.toString()]
        // (vd '0'/'1'); correct_choices inline lưu int [0], bank/questions.answer lưu
        // string ['0'] — đều normalize về toString().toLowerCase() để khớp 2 vế.
        final correctChoices = <String>[];
        if (correctAnswer['correct_choices'] != null) {
          final rawCorrect = correctAnswer['correct_choices'] as List<dynamic>;
          for (final e in rawCorrect) {
            correctChoices.add(e.toString().toLowerCase());
          }
        } else if (correctAnswer['correct_choice'] != null) {
          correctChoices.add(
            correctAnswer['correct_choice'].toString().toLowerCase(),
          );
        }

        if (selectedChoices.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] TF: No selected choice');
          return 0;
        }
        if (correctChoices.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] TF: No correct choice found');
          return 0;
        }

        final isCorrect = selectedChoices.first == correctChoices.first;

        return isCorrect ? maxPoints : 0;
      }

      // Fill_blank: chấm từng ô qua correct_values, ăn điểm pro-rata.
      // Student answer format: {<qId>_blank_<index>: "value", ...}
      // Correct answer format: {blanks: [{id, correct_values: [...], case_sensitive}]}
      if (questionType == 'fill_blank') {
        final blanks = correctAnswer['blanks'] as List<dynamic>?;
        if (blanks == null || blanks.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] FillBlank: No blanks data');
          return null;
        }

        int correctCount = 0;
        for (var i = 0; i < blanks.length; i++) {
          final blank = blanks[i] as Map<String, dynamic>;
          final correctValues =
              (blank['correct_values'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[];
          final caseSensitive = blank['case_sensitive'] == true;

          // Match student answer bằng index hoặc bất kỳ key nào kết thúc bằng _blank_$i
          String? studentValue;
          final exactKey = studentAnswer.keys.firstWhere(
            (k) => k.endsWith('_blank_$i'),
            orElse: () => '',
          );
          if (exactKey.isNotEmpty) {
            studentValue = studentAnswer[exactKey]?.toString();
          }

          if (studentValue == null) continue;

          // Trim leading/trailing whitespace (ô trống = 0 điểm)
          final normalizedStudent = studentValue.trim();
          if (normalizedStudent.isEmpty) continue;

          // So sánh với từng correct_value, áp dụng trim + case_sensitive
          final isMatch = correctValues.any((cv) {
            final normalizedCv = cv.trim();
            if (caseSensitive) {
              return normalizedStudent == normalizedCv;
            }
            return normalizedStudent.toLowerCase() ==
                normalizedCv.toLowerCase();
          });

          if (isMatch) correctCount++;
        }

        if (blanks.isEmpty) return 0;
        return maxPoints * (correctCount / blanks.length);
      }

      // Matching: chấm objective pro-rata theo số cặp đúng.
      // Correct: pairs[i].right_text là đáp án đúng cho mục trái thứ i.
      // Student answer: {<qId>_match_<i>: <right_text đã chọn>} (lưu chuỗi right_text).
      if (questionType == 'matching') {
        final pairs = correctAnswer['pairs'] as List<dynamic>?;
        if (pairs == null || pairs.isEmpty) {
          AppLogger.warning('⚠️ [GRADING] Matching: No pairs data');
          return null;
        }

        int correctCount = 0;
        for (var i = 0; i < pairs.length; i++) {
          final pair = pairs[i] as Map<String, dynamic>;
          final correctRight = (pair['right_text']?.toString() ?? '').trim();
          if (correctRight.isEmpty) continue;

          // Match student answer bằng bất kỳ key nào kết thúc bằng _match_$i
          final exactKey = studentAnswer.keys.firstWhere(
            (k) => k.endsWith('_match_$i'),
            orElse: () => '',
          );
          if (exactKey.isEmpty) continue;
          final studentRight = studentAnswer[exactKey]?.toString().trim();
          if (studentRight == null || studentRight.isEmpty) continue;

          if (studentRight == correctRight) correctCount++;
        }

        return maxPoints * (correctCount / pairs.length);
      }
    } catch (e) {
      // Log error but don't fail the submission
      return null;
    }

    return null;
  }

  /// Lấy lịch sử nộp bài của học sinh
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    // Lấy tất cả submissions của student. Nhúng submissions(total_score) để có điểm
    // tổng (total_score nằm ở bảng submissions, không phải work_sessions) — phục vụ cả
    // màn lịch sử lẫn "Điểm số mới nhất" ở dashboard.
    final submissionsRes = await _client
        .from('work_sessions')
        .select(
          '*, submissions(total_score), assignment_distributions!inner(*, assignments(*))',
        )
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    final list = List<Map<String, dynamic>>.from(submissionsRes);

    // Flatten total_score lên top-level (submissions là mảng do FK ngược session_id)
    // để consumer đọc submission['total_score'] thống nhất.
    for (final row in list) {
      final subs = row['submissions'];
      if (subs is List && subs.isNotEmpty) {
        row['total_score'] = (subs.first as Map)['total_score'];
      } else if (subs is Map) {
        row['total_score'] = subs['total_score'];
      }
    }

    return list;
  }

  /// Lấy danh sách các lần làm bài (attempts) của 1 học sinh cho 1 bài tập cụ thể
  Future<List<Map<String, dynamic>>> getDistributionAttempts(
    String distributionId,
    String studentId,
  ) async {
    final res = await _client
        .from('work_sessions')
        .select('''
          id, status, created_at, started_at, submitted_at, time_spent_seconds, attempt,
          submissions(total_score, is_late, ai_graded, id),
          submission_answers(final_score, ai_score)
        ''')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('attempt', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  /// Trigger Edge Function process-ai-queue — fire & forget, không block submit flow.
  /// Edge Function chạy server-side, dùng API key của GIÁO VIÊN (từ profiles.metadata).
  /// Học sinh không cần cấu hình bất kỳ API key nào.
  Future<void> _triggerAiQueue(String sessionId) async {
    try {
      final projectUrl = Env.supabaseUrl.replaceAll(RegExp(r'/$'), '');
      final functionUrl = '$projectUrl/functions/v1/process-ai-queue';
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Env.supabaseAnonKey}',
        },
      ));
      await dio.post(functionUrl, data: {'session_id': sessionId});
      AppLogger.info('[AI] Edge Function triggered for session $sessionId');
    } catch (e) {
      // Non-blocking: lỗi trigger không ảnh hưởng submit
      AppLogger.warning('[AI] Edge Function trigger failed (non-blocking): $e');
    }
  }

  /// Deep Clone: tạo bản sao bất biến của assignment.
  /// Returns new_assignment_id (UUID string).
  Future<String> deepCloneAssignment(
    String srcAssignmentId,
    String clonedBy,
  ) async {
    final result = await _client.rpc(
      'deep_clone_assignment',
      params: {
        'p_src_assignment_id': srcAssignmentId,
        'p_cloned_by': clonedBy,
      },
    );
    if (result is! String || result.isEmpty) {
      throw Exception('deep_clone_assignment RPC returned invalid UUID: $result');
    }
    return result;
  }

  /// Hotfix: Update nội dung câu hỏi trong đề (Delta Override Pattern).
  /// CHỈ update assignment_questions.custom_content, KHÔNG đụng questions bank.
  /// [lock] = true khi đã có work_sessions → chỉ cho sửa text/isCorrect, không thêm/xóa choice.
  Future<Map<String, dynamic>> updateAssignmentQuestionContent(
    String assignmentQuestionId,
    Map<String, dynamic> contentPatch, {
    bool lock = false,
  }) async {
    // Rủi ro #5 fix: đi qua RPC `update_assignment_question_content` (migration 035,
    // đã apply) thay vì .update() trực tiếp. RPC merge patch vào custom_content
    // hiện tại rồi chuẩn hoá qua fn_normalize_aq_content trước khi UPDATE → đúng
    // khế ước Delta Override (câu bank GLOBAL không sửa → S1, không sinh override
    // thừa) và loại bỏ race read-modify-write của cách cũ.
    final res = await _client.rpc(
      'update_assignment_question_content',
      params: {
        'p_aq_id': assignmentQuestionId,
        'p_patch': contentPatch,
      },
    );
    return Map<String, dynamic>.from(res as Map);
  }

  /// Batch regrade: gọi RPC sau khi GV sửa đề.
  /// Returns số bài đã chấm lại.
  Future<int> batchRegradeAssignment(
    String assignmentId,
    String gradedBy,
  ) async {
    final result = await _client.rpc(
      'batch_regrade_assignment',
      params: {
        'p_assignment_id': assignmentId,
        'p_graded_by': gradedBy,
      },
    );
    return (result as int?) ?? 0;
  }

  /// Kiểm tra có work_sessions "đang hoạt động" cho assignment này không.
  /// "Active" = học sinh đang làm hoặc chờ chấm (chưa hoàn thành).
  /// Dùng để UI lock: nếu true → disable thêm/xóa choice (chỉ cho sửa text/isCorrect).
  Future<bool> hasActiveWorkSessions(String assignmentId) async {
    final res = await _client
        .from('work_sessions')
        .select('id')
        .eq('assignment_id', assignmentId)
        .inFilter('status', ['in_progress', 'ai_processing', 'pending_review'])
        .limit(1);
    return (res as List).isNotEmpty;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Redo Assignment
  // ──────────────────────────────────────────────────────────────────────────

  /// Gọi RPC start_redo_session — tạo work_session + variant mới cho redo.
  /// Throws [RedoBlockedException] với lý do cụ thể nếu không được phép.
  Future<RedoSessionResult> startRedoSession({
    required String distributionId,
    required String studentId,
  }) async {
    try {
      final result = await _client.rpc('start_redo_session', params: {
        'p_distribution_id': distributionId,
        'p_student_id': studentId,
      });
      final data = Map<String, dynamic>.from(result as Map);
      return RedoSessionResult(
        sessionId: data['session_id'] as String,
        attempt: (data['attempt'] as num).toInt(),
        variantId: data['variant_id'] as String,
      );
    } on PostgrestException catch (e) {
      throw _mapRedoException(e);
    }
  }

  /// Lấy điểm gộp cho toàn bộ distribution theo rule (latest/max/average).
  /// [overrideRule] ghi đè rule từ distribution.settings.
  Future<List<AggregatedScore>> getAggregatedScores({
    required String distributionId,
    String? overrideRule,
  }) async {
    final params = <String, dynamic>{
      'p_distribution_id': distributionId,
      if (overrideRule != null) 'p_rule': overrideRule,
    };
    final result = await _client.rpc(
      'get_aggregated_scores_for_distribution',
      params: params,
    );
    return (result as List)
        .map((e) => AggregatedScore.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Lấy lịch sử các lần làm của 1 student cho 1 distribution.
  /// Dùng view v_student_attempts_summary.
  Future<List<StudentAttemptSummary>> getStudentAttempts({
    required String distributionId,
    required String studentId,
  }) async {
    final result = await _client
        .from('v_student_attempts_summary')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('attempt');
    return (result as List)
        .map((e) => StudentAttemptSummary.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Map PostgrestException message → RedoBlockedException với reason code.
  Exception _mapRedoException(PostgrestException e) {
    final msg = e.message;
    if (msg.contains('distribution_closed')) {
      return const RedoBlockedException(reason: RedoBlockReason.closed);
    } else if (msg.contains('past_due')) {
      return const RedoBlockedException(reason: RedoBlockReason.pastDue);
    } else if (msg.contains('retake_not_allowed')) {
      return const RedoBlockedException(reason: RedoBlockReason.notAllowed);
    } else if (msg.contains('max_attempts_reached')) {
      return const RedoBlockedException(reason: RedoBlockReason.maxReached);
    } else if (msg.contains('permission_denied')) {
      return const RedoBlockedException(reason: RedoBlockReason.permission);
    } else if (msg.contains('session_in_progress')) {
      return const RedoBlockedException(reason: RedoBlockReason.sessionInProgress);
    }
    return e;
  }
}

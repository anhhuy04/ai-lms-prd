import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho submissions - các thao tác với bảng submissions.
class SubmissionDataSource {
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy submission của student (nếu có) + flatten status từ work_sessions.
  /// Trả về map với:
  ///   - `status`            : từ work_sessions ('in_progress'|'submitted'|'graded')
  ///   - `score`             : alias của submissions.total_score
  ///   - `time_taken_seconds`: từ work_sessions.time_spent_seconds
  ///   - `attempt_count`     : từ work_sessions.attempt
  /// Trả về null nếu học sinh chưa bắt đầu.
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    // Kiểm tra đã có submission chưa
    final existingRes = await _client
        .from('submissions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .maybeSingle();

    if (existingRes != null) {
      final data = Map<String, dynamic>.from(existingRes);
      // Alias total_score → score để UI đọc nhất quán
      data['score'] = data['total_score'];

      // Lấy status từ work_sessions (submissions không có status column)
      try {
        final sessionRes = await _client
            .from('work_sessions')
            .select('id, status, started_at, submitted_at, time_spent_seconds, attempt')
            .eq('assignment_distribution_id', distributionId)
            .eq('student_id', studentId)
            .order('attempt', ascending: false)
            .maybeSingle();

        if (sessionRes != null) {
          data['status'] = sessionRes['status'];
          data['time_taken_seconds'] = sessionRes['time_spent_seconds'];
          data['attempt_count'] = sessionRes['attempt'];
          data['started_at'] ??= sessionRes['started_at'];
          data['work_session_submitted_at'] = sessionRes['submitted_at'];
          // Ưu tiên work_sessions.id vì submissions.session_id có thể null
          data['resolved_session_id'] = sessionRes['id'];
        } else {
          data['status'] = data['submitted_at'] != null ? 'submitted' : 'in_progress';
        }
      } catch (e) {
        AppLogger.warning('[SubmissionDS] Cannot fetch work_sessions: $e');
        data['status'] = data['submitted_at'] != null ? 'submitted' : 'in_progress';
      }

      // Đếm câu đã trả lời + thống kê đúng/sai
      // Dùng resolved_session_id (work_sessions.id) — submissions.session_id có thể null
      final sessionId =
          (data['resolved_session_id'] ?? data['session_id']) as String?;
      final currentStatus = data['status'] as String? ?? 'in_progress';
      if (sessionId != null) {
        try {
          if (currentStatus == 'in_progress') {
            // Khi đang làm dở: đếm từ autosave_answers (chưa submit → submission_answers rỗng)
            final autosaveRes = await _client
                .from('autosave_answers')
                .select('id')
                .eq('session_id', sessionId);
            data['answered_count'] = (autosaveRes as List).length;
            data['correct_count'] = 0;
            data['wrong_count'] = 0;
          } else {
            // Đã nộp: đếm từ submission_answers + tính đúng/sai theo điểm
            final answersRes = await _client
                .from('submission_answers')
                .select('final_score, ai_score')
                .eq('session_id', sessionId);
            final answers =
                List<Map<String, dynamic>>.from(answersRes as List);
            data['answered_count'] = answers.length;
            int correct = 0;
            int wrong = 0;
            for (final a in answers) {
              final effectiveScore =
                  (a['final_score'] ?? a['ai_score'] ?? 0) as num;
              if (effectiveScore > 0) {
                correct++;
              } else {
                wrong++;
              }
            }
            data['correct_count'] = correct;
            data['wrong_count'] = wrong;
          }
        } catch (e) {
          AppLogger.warning('[SubmissionDS] Cannot fetch answers: $e');
          data['answered_count'] = 0;
          data['correct_count'] = 0;
          data['wrong_count'] = 0;
        }
      } else {
        data['answered_count'] = 0;
        data['correct_count'] = 0;
        data['wrong_count'] = 0;
      }

      return data;
    }

    // Chưa có submission → kiểm tra work_sessions xem có session in_progress không
    // (workspace tạo work_session ngay khi bắt đầu, submissions chỉ tạo lúc submit)
    try {
      final sessionRes = await _client
          .from('work_sessions')
          .select('id, status, started_at, submitted_at, time_spent_seconds, attempt')
          .eq('assignment_distribution_id', distributionId)
          .eq('student_id', studentId)
          .eq('status', 'in_progress')
          .order('attempt', ascending: false)
          .maybeSingle();

      if (sessionRes != null) {
        final data = <String, dynamic>{
          'status': 'in_progress',
          'resolved_session_id': sessionRes['id'],
          'started_at': sessionRes['started_at'],
          'time_taken_seconds': sessionRes['time_spent_seconds'],
          'attempt_count': sessionRes['attempt'],
          'score': null,
          'correct_count': 0,
          'wrong_count': 0,
        };

        // Đếm số câu đã auto-save
        try {
          final autosaveRes = await _client
              .from('autosave_answers')
              .select('id')
              .eq('session_id', sessionRes['id'] as String);
          data['answered_count'] = (autosaveRes as List).length;
        } catch (e) {
          AppLogger.warning('[SubmissionDS] Cannot fetch autosave_answers: $e');
          data['answered_count'] = 0;
        }

        return data;
      }
    } catch (e) {
      AppLogger.warning('[SubmissionDS] Cannot fetch work_sessions fallback: $e');
    }

    // Không có submission lẫn work_session → học sinh thực sự chưa bắt đầu
    return null;
  }

  /// Lưu bản nháp submission.
  Future<void> saveDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    // Tìm submission hiện có
    final existing = await _client
        .from('submissions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existing != null) {
      // Update
      await _client.from('submissions').update({
        'answers': answers,
        'uploaded_files': uploadedFiles,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      // Insert mới — KHÔNG set 'status': submissions table không có status column
      // (status lives on work_sessions)
      final now = DateTime.now().toUtc().toIso8601String();
      await _client.from('submissions').insert({
        'assignment_distribution_id': distributionId,
        'student_id': studentId,
        'answers': answers,
        'uploaded_files': uploadedFiles,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Nộp bài - cập nhật status và submitted_at.
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Update submission status
    final result = await _client
        .from('submissions')
        .update({
          'status': 'submitted',
          'submitted_at': now,
          'updated_at': now,
        })
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .select()
        .single();

    return Map<String, dynamic>.from(result);
  }

  /// Lấy lịch sử nộp bài của student.
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*)
          )
        ''')
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Lấy danh sách submissions cho 1 distribution (teacher view).
  /// Join work_sessions để lấy status (vì submissions table không có status column).
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    final result = await _client
        .from('submissions')
        .select('''
          id,
          student_id,
          assignment_id,
          assignment_distribution_id,
          session_id,
          submitted_at,
          is_late,
          total_score,
          ai_graded,
          is_voided,
          assignment_distributions(
            due_at,
            assignments(total_points)
          ),
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          ),
          work_sessions!submissions_session_id_fkey(
            id,
            status,
            submitted_at
          )
        ''')
        .eq('assignment_distribution_id', distributionId)
        .order('submitted_at', ascending: false);

    final submissions = List<Map<String, dynamic>>.from(result);

    // work_sessions!submissions_session_id_fkey là many-to-one (submissions.session_id → work_sessions.id)
    // Supabase trả về single Map, KHÔNG phải List
    for (final sub in submissions) {
      final ws = sub['work_sessions'];
      if (ws is Map) {
        // many-to-one: single object
        sub['status'] = (ws as Map<String, dynamic>)['status'] ?? 'submitted';
      } else if (ws is List && ws.isNotEmpty) {
        // fallback nếu Supabase trả về List
        sub['status'] = (ws.first as Map<String, dynamic>)['status'] ?? 'submitted';
      } else {
        sub['status'] = 'submitted';
      }
    }

    return submissions;
  }

  /// Lấy chi tiết một submission.
  /// submissions → work_sessions → submission_answers (2-level FK)
  /// Tách thành 2 query vì PostgREST không hỗ trợ join 2 cấp.
  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    // Query 1: submission + related data
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*),
            classes(name)
          ),
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          ),
          work_sessions(
            id,
            status,
            submitted_at
          )
        ''')
        .eq('id', submissionId)
        .maybeSingle();

    if (result == null) {
      throw Exception('Submission not found: $submissionId');
    }

    final submission = Map<String, dynamic>.from(result);

    // Normalize work_sessions → 'workSessions' key cho Submission.fromJson
    // PostgREST có thể trả List (reverse FK) hoặc Map (outgoing FK)
    final workSessionsRaw = submission['work_sessions'];
    AppLogger.info('[getSubmissionById] work_sessions type=${workSessionsRaw?.runtimeType}, value=$workSessionsRaw');
    if (workSessionsRaw is List && workSessionsRaw.isNotEmpty) {
      submission['workSessions'] = Map<String, dynamic>.from(workSessionsRaw.first as Map);
    } else if (workSessionsRaw is Map) {
      submission['workSessions'] = Map<String, dynamic>.from(workSessionsRaw);
    }

    // Query 2: submission_answers qua work_sessions
    final sessionId = submission['session_id'] as String?;
    if (sessionId != null) {
      final answersRes = await _client
          .from('submission_answers')
          .select('''
            *,
            assignment_questions(
              id,
              question_id(
                type
              ),
              points,
              custom_content
            )
          ''')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
      submission['submission_answers'] = answersRes;
    } else {
      submission['submission_answers'] = <Map<String, dynamic>>[];
    }

    return submission;
  }

  /// Lấy chi tiết bài làm của học sinh theo distributionId + studentId.
  /// Dùng cho trang "Xem lại bài làm" của học sinh (không cần submissionId).
  Future<Map<String, dynamic>?> getStudentSubmissionDetail(
    String distributionId,
    String studentId,
  ) async {
    // Query 1: tìm submission theo distributionId + studentId
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*),
            classes(name)
          ),
          work_sessions(
            id,
            status,
            submitted_at,
            time_spent_seconds
          )
        ''')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .maybeSingle();

    if (result == null) return null;

    final submission = Map<String, dynamic>.from(result);

    // Normalize work_sessions → dùng record đầu tiên
    final workSessionsRaw = submission['work_sessions'];
    Map<String, dynamic>? workSession;
    if (workSessionsRaw is List && workSessionsRaw.isNotEmpty) {
      workSession = Map<String, dynamic>.from(workSessionsRaw.first as Map);
    } else if (workSessionsRaw is Map) {
      workSession = Map<String, dynamic>.from(workSessionsRaw);
    }
    submission['workSessions'] = workSession;

    // Query 2: submission_answers qua session_id
    final sessionId = (workSession?['id'] ?? submission['session_id']) as String?;
    if (sessionId != null) {
      final answersRes = await _client
          .from('submission_answers')
          .select('''
            *,
            assignment_questions(
              id,
              question_id(
                type
              ),
              points,
              custom_content
            )
          ''')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
      submission['submission_answers'] = answersRes;
    } else {
      submission['submission_answers'] = <Map<String, dynamic>>[];
    }

    return submission;
  }

  /// Cập nhật điểm và phản hồi (teacher grading).
  Future<void> updateSubmissionGrade(
    String submissionId, {
    required double score,
    String? feedback,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // L7 fix: KHÔNG set 'status' — submissions table không có status column
    // Status của session được manage qua work_sessions.status (publishGrades flow)
    await _client.from('submissions').update({
      'total_score': score,
      'feedback': feedback,
      'updated_at': now,
    }).eq('id', submissionId);
  }

  /// Lấy danh sách câu trả lời của một submission (cho teacher grading).
  Future<List<Map<String, dynamic>>> getSubmissionAnswers(
    String submissionId,
  ) async {
    // Lấy session_id từ submission trước
    final submission = await _client
        .from('submissions')
        .select('session_id')
        .eq('id', submissionId)
        .single();

    final sessionId = submission['session_id'] as String?;

    if (sessionId == null) {
      AppLogger.warning(
        'getSubmissionAnswers: sessionId is null for submissionId=$submissionId',
      );
      return [];
    }

    final result = await _client
        .from('submission_answers')
        .select('''
          *,
          assignment_questions(
            id,
            question_id(
              type
            ),
            points,
            custom_content
          )
        ''')
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Cập nhật điểm cho một câu trả lời (final_score + teacher_feedback).
  Future<void> updateSubmissionAnswerGrade({
    required String answerId,
    required double finalScore,
    String? teacherFeedback,
    required String teacherId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('submission_answers').update({
      'final_score': finalScore,
      'teacher_feedback': teacherFeedback != null
          ? {'text': teacherFeedback}
          : null,
      'graded_by': teacherId,
      'graded_at': now,
      'updated_at': now,
    }).eq('id', answerId);
  }

  /// Chấp nhận điểm AI (dùng ai_score làm final_score).
  Future<void> approveAiScore(String answerId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy ai_score trước
    final answer = await _client
        .from('submission_answers')
        .select('ai_score')
        .eq('id', answerId)
        .single();

    await _client.from('submission_answers').update({
      'final_score': answer['ai_score'],
      'updated_at': now,
    }).eq('id', answerId);
  }

  /// Lấy chi tiết distribution để tính max_score.
  Future<Map<String, dynamic>?> getDistributionDetail(
    String distributionId,
  ) async {
    final result = await _client
        .from('assignment_distributions')
        .select('''
          *,
          assignments(
            id,
            title,
            total_points
          )
        ''')
        .eq('id', distributionId)
        .maybeSingle();

    return result != null ? Map<String, dynamic>.from(result) : null;
  }

  /// Publish grades - cập nhật work_sessions status thành 'graded'.
  Future<void> publishGrades(String submissionId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy session_id từ submission
    final submission = await _client
        .from('submissions')
        .select('session_id')
        .eq('id', submissionId)
        .single();

    // Status lưu ở work_sessions, không phải submissions
    if (submission['session_id'] != null) {
      await _client.from('work_sessions').update({
        'status': 'graded',
        'updated_at': now,
      }).eq('id', submission['session_id']);
    }
  }

  /// Publish grades cho toàn bộ distribution.
  Future<void> publishAllGrades(String distributionId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy tất cả submissions (chưa graded) của distribution
    // Filter qua work_sessions.status vì submissions không có cột status
    final submissions = await _client
        .from('submissions')
        .select('id, session_id')
        .eq('assignment_distribution_id', distributionId);

    for (final submission in submissions) {
      // Status lưu ở work_sessions, không phải submissions
      if (submission['session_id'] != null) {
        await _client.from('work_sessions').update({
          'status': 'graded',
          'updated_at': now,
        }).eq('id', submission['session_id']);
      }
    }
  }
}

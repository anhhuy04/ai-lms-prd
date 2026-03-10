import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho Assignments (assignments, assignment_questions, variants, distributions).
class AssignmentDataSource {
  final SupabaseClient _client;
  final BaseTableDataSource _assignments;
  final BaseTableDataSource _assignmentQuestions;
  final BaseTableDataSource _assignmentVariants;
  final BaseTableDataSource _assignmentDistributions;

  AssignmentDataSource(this._client)
    : _assignments = BaseTableDataSource(_client, 'assignments'),
      _assignmentQuestions = BaseTableDataSource(
        _client,
        'assignment_questions',
      ),
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
  /// Join assignments + assignment_distributions để có cả distribution info.
  /// Chỉ lấy assignments đã published.
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsByClass(
    String classId,
  ) async {
    // Query distributions cho class này
    final distRes = await _client
        .from('assignment_distributions')
        .select('*, assignments!inner(*)')
        .eq('class_id', classId)
        .eq('assignments.is_published', true)
        .order('created_at', ascending: false);

    final distributions = List<Map<String, dynamic>>.from(distRes);

    // Flatten: mỗi distribution trả về 1 item chứa cả assignment + distribution info
    return distributions.map((dist) {
      final assignment = Map<String, dynamic>.from(dist['assignments'] as Map);
      return <String, dynamic>{
        ...assignment,
        'assignment_distribution_id': dist['id'],
        'distribution_type': dist['distribution_type'],
        'distribution_class_id': dist['class_id'],
        'distribution_group_id': dist['group_id'],
        'distribution_student_ids': dist['student_ids'],
        'distribution_due_at': dist['due_at'],
        'distribution_available_from': dist['available_from'],
        'distribution_time_limit_minutes': dist['time_limit_minutes'],
        'distribution_allow_late': dist['allow_late'],
        'distribution_settings': dist['settings'],
      };
    }).toList();
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

    // Flatten thành danh sách assignments
    return visibleDistributions.map((dist) {
      final assignment = Map<String, dynamic>.from(dist['assignments'] as Map);
      return <String, dynamic>{
        ...assignment,
        'assignment_distribution_id': dist['id'],
        'distribution_type': dist['distribution_type'],
        'distribution_due_at': dist['due_at'],
        'distribution_available_from': dist['available_from'],
        'distribution_time_limit_minutes': dist['time_limit_minutes'],
        'distribution_allow_late': dist['allow_late'],
        'distribution_settings': dist['settings'],
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

  /// Replace toàn bộ questions của assignment (simple & predictable).
  Future<void> replaceAssignmentQuestions(
    String assignmentId,
    List<Map<String, dynamic>> items,
  ) async {
    await _assignmentQuestions.deleteWhere('assignment_id', assignmentId);
    if (items.isEmpty) return;
    await _assignmentQuestions.insertMany(items);
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
        'ungraded': 0,
        'graded': 0,
      };
    }

    // Query distributions chỉ cho assignments của teacher này
    // Vì Supabase Flutter không có inFilter, query tất cả rồi filter trong code
    // Nếu assignmentIds lớn, có thể tối ưu bằng RPC function
    final allDistributionsRes = await _client
        .from('assignment_distributions')
        .select('assignment_id, due_at');
    final allDistributions = List<Map<String, dynamic>>.from(
      allDistributionsRes,
    );
    final distributions = allDistributions
        .where((e) => assignmentIds.contains(e['assignment_id'] as String))
        .toList();
    final distributedIds = distributions
        .map((e) => e['assignment_id'] as String)
        .toSet();

    final distributingCount = distributedIds.length;
    final waitingToAssign = publishedIds
        .where((id) => !distributedIds.contains(id))
        .length;

    // Tính in_progress từ distributions đã query
    final now = DateTime.now();
    final inProgress = distributions.where((e) {
      final dueAt = e['due_at'];
      if (dueAt == null) return true;
      try {
        final dueDate = DateTime.parse(dueAt as String);
        return dueDate.isAfter(now);
      } catch (_) {
        return false;
      }
    }).length;

    // Query số bài chưa chấm và đã chấm
    // Note: Cần submissions table để tính chính xác
    // Tạm thời return 0
    const ungraded = 0;
    const graded = 0;

    return {
      'total_assignments': totalAssignments,
      'ungraded_assignments': ungraded,
      'creating_count': creatingCount,
      'distributing_count': distributingCount,
      'waiting_to_assign': waitingToAssign,
      'assigned': distributingCount, // assigned = số có distribution
      'in_progress': inProgress,
      'ungraded': ungraded,
      'graded': graded,
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
    String distributionId,
  ) async {
    try {
      AppLogger.debug('🔵 [Datasource] getDistributionDetail: $distributionId');

      // Bước 1: Lấy distribution và assignment
      final distRes = await _client
          .from('assignment_distributions')
          .select('*, assignments(id, title, description, total_points, is_published)')
          .eq('id', distributionId)
          .maybeSingle();

      if (distRes == null) {
        return {
          'assignment': {'title': 'Không tìm thấy', 'description': null, 'total_points': 0},
          'questions': <Map<String, dynamic>>[],
          'distribution': <String, dynamic>{},
        };
      }

      final rawData = Map<String, dynamic>.from(distRes);
      final assignments = rawData['assignments'] as Map<String, dynamic>?;
      final assignmentId = assignments?['id'] as String?;

      AppLogger.debug('🔵 [Datasource] assignmentId: $assignmentId');

      // Bước 2: Lấy câu hỏi của bài tập (nếu có assignment_id)
      List<Map<String, dynamic>> questions = [];
      if (assignmentId != null) {
        // Thử query trực tiếp bảng questions trước
        final questionsRes = await _client
            .from('questions')
            .select('id, type, content, default_points')
            .limit(5);
        AppLogger.debug('🔵 [Datasource] questions table sample: $questionsRes');

        // Lấy assignment_questions đơn giản trước
        final aqRes = await _client
            .from('assignment_questions')
            .select('id, assignment_id, question_id, points, order_idx, custom_content')
            .eq('assignment_id', assignmentId)
            .order('order_idx');

        AppLogger.debug('🔵 [Datasource] assignment_questions simple: $aqRes');

        // Nếu có assignment_questions, lấy chi tiết questions
        if ((aqRes as List).isNotEmpty) {
          final questionIds = (aqRes as List).map((e) => e['question_id'] as String?).whereType<String>().toList();
          AppLogger.debug('🔵 [Datasource] question_ids: $questionIds');

          // Lấy tất cả question_ids từ question bank (đã được lọc ở trên)
          final validQuestionIds = questionIds;

          Map<String, Map<String, dynamic>> questionBankData = {};
          if (validQuestionIds.isNotEmpty) {
            // Query từng question một từ question bank
            for (final qId in validQuestionIds) {
              try {
                final qDetail = await _client
                    .from('questions')
                    .select('id, type, content, default_points, question_choices(id, content, is_correct)')
                    .eq('id', qId)
                    .maybeSingle();

                if (qDetail != null) {
                  questionBankData[qId] = qDetail;
                }
              } catch (e) {
                AppLogger.debug('🔵 [Datasource] Error fetching question $qId: $e');
              }
            }
          }

          // Xử lý từng assignment_question
          for (final aq in aqRes) {
            final qId = aq['question_id'] as String?;
            final customContent = aq['custom_content']; // JSON content khi tạo mới

            if (qId != null && questionBankData.containsKey(qId)) {
              // Case 1: Câu hỏi từ question bank
              final qDetail = questionBankData[qId]!;
              questions.add({
                'id': aq['id'],
                'question_id': qId,
                'content': qDetail['content'],
                'type': qDetail['type'],
                'points': aq['points'],
                'order_idx': aq['order_idx'],
                'question_choices': qDetail['question_choices'] ?? [],
              });
            } else if (customContent != null) {
              // Case 2: Câu hỏi tạo mới (custom_content)
              questions.add({
                'id': aq['id'],
                'question_id': null,
                'content': customContent,
                'type': customContent['type'] ?? 'multiple_choice',
                'points': aq['points'],
                'order_idx': aq['order_idx'],
                'question_choices': customContent['choices'] ?? [],
              });
            }
          }
        }

        AppLogger.debug('🔵 [Datasource] final questions extracted: ${questions.length}');
      }

      // Build response với cấu trúc expected bởi UI
      return {
        'assignment': {
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
        },
      };
    } catch (e, st) {
      AppLogger.error('🔴 [Datasource] getDistributionDetail error: $e', error: e, stackTrace: st);
      // Return safe fallback on error
      return {
        'assignment': {'title': 'Lỗi tải dữ liệu', 'description': null, 'total_points': 0},
        'questions': <Map<String, dynamic>>[],
        'distribution': <String, dynamic>{},
      };
    }
  }

  /// Lấy danh sách submissions cho 1 distribution.
  /// Join profiles để có tên + avatar học sinh.
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    // Lấy distribution để biết assignment_id
    final dist = await _client
        .from('assignment_distributions')
        .select('assignment_id')
        .eq('id', distributionId)
        .single();
    final assignmentId = dist['assignment_id'] as String;

    final res = await _client
        .from('work_sessions')
        .select('*, profiles:student_id(id, full_name, avatar_url)')
        .eq('assignment_id', assignmentId)
        .order('submitted_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Lấy danh sách tất cả bài tập của học sinh (từ tất cả các lớp)
  /// Query submissions table để lấy tất cả distributions mà student đã được giao
  Future<List<Map<String, dynamic>>> getStudentAssignments(
    String studentId,
  ) async {
    // Lấy tất cả submissions của student để biết họ được giao bài tập nào
    final submissionsRes = await _client
        .from('work_sessions')
        .select('assignment_distribution_id, status, submitted_at')
        .eq('student_id', studentId);
    final submissions = List<Map<String, dynamic>>.from(submissionsRes);

    // Lấy danh sách distribution_id đã có submission (dùng để merge submission status)
    final submissionsByDistId = {
      for (final s in submissions) s['assignment_distribution_id'] as String: s,
    };

    // Query class_members để lấy danh sách lớp của student
    final classMembersRes = await _client
        .from('class_members')
        .select('class_id')
        .eq('student_id', studentId)
        .eq('status', 'active');
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

  /// Lấy hoặc tạo bài nộp draft cho một distribution
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    // Lấy distribution để biết assignment_id
    final dist = await _client
        .from('assignment_distributions')
        .select('assignment_id')
        .eq('id', distributionId)
        .single();
    final assignmentId = dist['assignment_id'] as String;

    // Kiểm tra đã có submission chưa
    final existingRes = await _client
        .from('work_sessions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existingRes != null) {
      // Fetch answers from autosave_answers table
      final autosaveAnswers = await _client
          .from('autosave_answers')
          .select()
          .eq('session_id', existingRes['id']);

      // Convert to answers map
      final Map<String, dynamic> answersMap = {};
      for (final aa in autosaveAnswers) {
        final qId = aa['assignment_question_id'] as String?;
        if (qId != null) {
          answersMap[qId] = aa['answer_content'];
        }
      }

      // Add answers to the result
      final result = Map<String, dynamic>.from(existingRes);
      result['answers'] = answersMap;
      result['uploaded_files'] = <String>[];
      return result;
    }

    // Tạo mới submission draft
    final newSubmission = await _client
        .from('work_sessions')
        .insert({
          'assignment_distribution_id': distributionId,
          'assignment_id': assignmentId,
          'student_id': studentId,
          'status': 'draft',
        })
        .select()
        .single();

    return Map<String, dynamic>.from(newSubmission);
  }

  /// Lưu bản nháp bài nộp
  Future<void> saveDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    // Get session ID first
    final session = await _client
        .from('work_sessions')
        .select('id')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (session == null) {
      throw Exception('Session not found');
    }

    final sessionId = session['id'] as String;

    // Save each answer to autosave_answers table
    for (final entry in answers.entries) {
      final questionId = entry.key;
      final answerValue = entry.value;

      // Check if exists first, then update or insert
      final existing = await _client
          .from('autosave_answers')
          .select('id')
          .eq('session_id', sessionId)
          .eq('assignment_question_id', questionId)
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await _client.from('autosave_answers').update({
          'answer_content': answerValue,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        // Insert new
        await _client.from('autosave_answers').insert({
          'session_id': sessionId,
          'assignment_question_id': questionId,
          'answer_content': answerValue,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    // Update work_sessions status
    await _client.from('work_sessions').upsert({
      'assignment_distribution_id': distributionId,
      'student_id': studentId,
      'status': 'draft',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'assignment_distribution_id,student_id');
  }

  /// Nộp bài tập
  /// Theo kiến trúc Enterprise:
  /// 1. Chốt phiên: work_sessions.status = 'submitted'
  /// 2. Dời đáp án: autosave_answers -> submission_answers
  /// 3. Tạo biên lai: submissions table (CQRS)
  /// 4. Dọn dẹp: Xóa autosave_answers
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    // Get session
    final session = await _client
        .from('work_sessions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (session == null) {
      throw Exception('Session not found');
    }

    final sessionId = session['id'] as String;
    final now = DateTime.now().toIso8601String();

    // Get answers from autosave_answers
    final autosaveAnswers = await _client
        .from('autosave_answers')
        .select()
        .eq('session_id', sessionId);

    // 2. Save each answer to submission_answers (Vùng lõi)
    for (final aa in autosaveAnswers) {
      final questionId = aa['assignment_question_id'] as String?;
      if (questionId != null) {
        await _client.from('submission_answers').insert({
          'session_id': sessionId,
          'assignment_question_id': questionId,
          'answer': aa['answer_content'],
        });
      }
    }

    // 3. Create submission record (CQRS - for fast queries)
    // Check if submission already exists
    final existingSubmission = await _client
        .from('submissions')
        .select()
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existingSubmission != null) {
      // Update existing submission
      await _client.from('submissions').update({
        'status': 'submitted',
        'submitted_at': now,
        'updated_at': now,
      }).eq('id', existingSubmission['id']);
    } else {
      // Create new submission record
      await _client.from('submissions').insert({
        'assignment_distribution_id': distributionId,
        'student_id': studentId,
        'status': 'submitted',
        'submitted_at': now,
        'created_at': now,
        'updated_at': now,
      });
    }

    // 1. Update session status
    final result = await _client
        .from('work_sessions')
        .update({
          'status': 'submitted',
          'submitted_at': now,
          'updated_at': now,
        })
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .select()
        .single();

    // 4. Cleanup: Delete autosave_answers (reduce DB size)
    await _client
        .from('autosave_answers')
        .delete()
        .eq('session_id', sessionId);

    return Map<String, dynamic>.from(result);
  }

  /// Lấy lịch sử nộp bài của học sinh
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    // Lấy tất cả submissions của student
    final submissionsRes = await _client
        .from('work_sessions')
        .select('*, assignment_distributions!inner(*, assignments(*))')
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(submissionsRes);
  }
}

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/entities/assignment_statistics.dart';
import 'package:ai_mls/domain/entities/assignment_variant.dart';
import 'package:ai_mls/domain/repositories/assignment_repository.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentDataSource _ds;

  AssignmentRepositoryImpl(this._ds);

  @override
  Future<Assignment> createAssignment(Map<String, dynamic> payload) async {
    try {
      final row = await _ds.insertAssignment(payload);
      return Assignment.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createAssignment: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo bài tập');
    }
  }

  @override
  Future<String> createAssignmentWithQuestions({
    required String teacherId,
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final id = await _ds.createAssignmentWithQuestionsRpc(
        teacherId: teacherId,
        assignment: assignment,
        questions: questions,
      );
      return id;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createAssignmentWithQuestions: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo bài tập cùng câu hỏi');
    }
  }

  @override
  Future<Assignment> saveDraft({
    required String assignmentId,
    required Map<String, dynamic> assignmentPatch,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> distributions,
  }) async {
    try {
      final row = await _ds.updateAssignment(assignmentId, assignmentPatch);
      await _ds.replaceAssignmentQuestions(assignmentId, questions);
      await _ds.replaceDistributions(assignmentId, distributions);
      return Assignment.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] saveDraft: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lưu bản nháp bài tập');
    }
  }

  @override
  Future<Assignment> publishAssignment({
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> distributions,
  }) async {
    try {
      // Debug payload để xác nhận khớp schema/RPC publish_assignment
      AppLogger.debug(
        '📤 [AssignmentRepo] publishAssignment payload:\n'
        '- assignment: $assignment\n'
        '- questions: ${questions.length} items\n'
        '- distributions: ${distributions.length} items',
      );

      final row = await _ds.publishAssignmentRpc(
        assignment: assignment,
        questions: questions,
        distributions: distributions,
      );
      return Assignment.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] publishAssignment: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xuất bản bài tập');
    }
  }

  @override
  Future<void> deleteAssignment(String id) async {
    try {
      await _ds.deleteAssignment(id);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] deleteAssignment(id: $id): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xóa bài tập');
    }
  }

  @override
  Future<Assignment> getAssignmentById(String id) async {
    try {
      final row = await _ds.getAssignmentById(id);
      if (row == null) {
        throw Exception('Không tìm thấy bài tập');
      }
      return Assignment.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentById(id: $id): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy thông tin bài tập');
    }
  }

  @override
  Future<List<Assignment>> getAssignmentsByClass(String classId) async {
    try {
      final rows = await _ds.getAssignmentsByClass(classId);
      return rows.map(Assignment.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentsByClass(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách bài tập theo lớp',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsByClass(
    String classId,
  ) async {
    try {
      return await _ds.getDistributedAssignmentsByClass(classId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getDistributedAssignmentsByClass(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách bài tập đã giao cho lớp',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsForStudent(
    String classId,
    String studentId,
  ) async {
    try {
      return await _ds.getDistributedAssignmentsForStudent(classId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getDistributedAssignmentsForStudent: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách bài tập cho học sinh',
      );
    }
  }

  @override
  Future<List<Assignment>> getAssignmentsByTeacher(String teacherId) async {
    try {
      final rows = await _ds.getAssignmentsByTeacher(teacherId);
      return rows.map(Assignment.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentsByTeacher(teacherId: $teacherId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách bài tập của giáo viên',
      );
    }
  }

  @override
  Future<List<AssignmentDistribution>> getDistributions(
    String assignmentId,
  ) async {
    try {
      final rows = await _ds.getDistributions(assignmentId);
      return rows.map(AssignmentDistribution.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getDistributions(assignmentId: $assignmentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách phân phối bài tập',
      );
    }
  }

  @override
  Future<List<AssignmentQuestion>> getAssignmentQuestions(
    String assignmentId,
  ) async {
    try {
      final rows = await _ds.getAssignmentQuestions(assignmentId);
      return rows.map(AssignmentQuestion.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentQuestions(assignmentId: $assignmentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách câu hỏi bài tập',
      );
    }
  }

  @override
  Future<List<AssignmentVariant>> getVariants(String assignmentId) async {
    try {
      final rows = await _ds.getVariants(assignmentId);
      return rows.map(AssignmentVariant.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getVariants(assignmentId: $assignmentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy danh sách biến thể bài tập',
      );
    }
  }

  @override
  Future<AssignmentStatistics> getAssignmentStatistics(String teacherId) async {
    try {
      final data = await _ds.getAssignmentStatistics(teacherId);
      return AssignmentStatistics.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentStatistics: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy thống kê bài tập');
    }
  }

  @override
  Future<List<Assignment>> getRecentActivities(
    String teacherId, {
    int limit = 10,
  }) async {
    try {
      final rows = await _ds.getRecentActivities(teacherId, limit: limit);
      return rows.map(Assignment.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getRecentActivities: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy hoạt động gần đây');
    }
  }

  @override
  Future<AssignmentDistribution> distributeAssignment({
    required String assignmentId,
    required String classId,
    required String distributionType,
    String? groupId,
    List<String>? studentIds,
    DateTime? availableFrom,
    DateTime? dueAt,
    int? timeLimitMinutes,
    bool allowLate = true,
    Map<String, dynamic>? latePolicy,
    bool sendNotification = true,

    /// Cấu hình shuffle và hiển thị điểm - lưu vào cột settings JSONB
    Map<String, dynamic>? settings,
  }) async {
    try {
      AppLogger.debug(
        '📤 [REPO] distributeAssignment: assignment=$assignmentId '
        'class=$classId type=$distributionType',
      );

      final payload = <String, dynamic>{
        'assignment_id': assignmentId,
        'distribution_type': distributionType,
        'class_id': classId,
        if (groupId != null) 'group_id': groupId,
        if (studentIds != null && studentIds.isNotEmpty)
          'student_ids': studentIds,
        if (availableFrom != null)
          'available_from': availableFrom.toIso8601String(),
        if (dueAt != null) 'due_at': dueAt.toIso8601String(),
        if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
        'allow_late': allowLate,
        if (latePolicy != null) 'late_policy': latePolicy,
        // Thêm settings cho shuffle và hiển thị điểm
        if (settings != null) 'settings': settings,
      };

      final row = await _ds.insertDistribution(payload);
      return AssignmentDistribution.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] distributeAssignment: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Phân phối bài tập');
    }
  }

  @override
  Future<Map<String, dynamic>> getDistributionDetail(
    String distributionId,
  ) async {
    try {
      return await _ds.getDistributionDetail(distributionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getDistributionDetail: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(
        e,
        'Lấy chi tiết bài tập đã giao',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    try {
      return await _ds.getSubmissionsByDistribution(distributionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getSubmissionsByDistribution: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách bài nộp');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentAssignments(
    String studentId,
  ) async {
    try {
      return await _ds.getStudentAssignments(studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getStudentAssignments: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách bài tập');
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    try {
      return await _ds.getOrCreateSubmission(distributionId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getOrCreateSubmission: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy bài nộp');
    }
  }

  @override
  Future<void> saveSubmissionDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    try {
      await _ds.saveDraft(distributionId, studentId, answers, uploadedFiles);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] saveSubmissionDraft: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lưu bản nháp');
    }
  }

  @override
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    try {
      return await _ds.submitAssignment(distributionId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] submitAssignment: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Nộp bài tập');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    try {
      return await _ds.getStudentSubmissionHistory(studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getStudentSubmissionHistory: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy lịch sử nộp bài');
    }
  }
}

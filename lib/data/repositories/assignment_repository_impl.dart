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
      AppLogger.error('🔴 [REPO ERROR] createAssignment: $e', error: e, stackTrace: stackTrace);
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
      throw ErrorTranslationUtils.translateError(
        e,
        'Tạo bài tập cùng câu hỏi',
      );
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
      AppLogger.error('🔴 [REPO ERROR] saveDraft: $e', error: e, stackTrace: stackTrace);
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
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách bài tập theo lớp');
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
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách bài tập của giáo viên');
    }
  }

  @override
  Future<List<AssignmentDistribution>> getDistributions(String assignmentId) async {
    try {
      final rows = await _ds.getDistributions(assignmentId);
      return rows.map(AssignmentDistribution.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getDistributions(assignmentId: $assignmentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách phân phối bài tập');
    }
  }

  @override
  Future<List<AssignmentQuestion>> getAssignmentQuestions(String assignmentId) async {
    try {
      final rows = await _ds.getAssignmentQuestions(assignmentId);
      return rows.map(AssignmentQuestion.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getAssignmentQuestions(assignmentId: $assignmentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách câu hỏi bài tập');
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
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách biến thể bài tập');
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
}


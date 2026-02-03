import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/entities/assignment_statistics.dart';
import 'package:ai_mls/domain/entities/assignment_variant.dart';

/// Contract cho Assignments.
abstract class AssignmentRepository {
  Future<Assignment> getAssignmentById(String id);

  Future<List<Assignment>> getAssignmentsByTeacher(String teacherId);

  Future<List<Assignment>> getAssignmentsByClass(String classId);

  Future<List<AssignmentQuestion>> getAssignmentQuestions(String assignmentId);

  Future<List<AssignmentDistribution>> getDistributions(String assignmentId);

  Future<List<AssignmentVariant>> getVariants(String assignmentId);

  Future<Assignment> createAssignment(Map<String, dynamic> payload);

  /// Tạo assignment + assignment_questions (và optionally questions mới) trong 1 RPC transactional.
  /// Trả về assignmentId được tạo.
  Future<String> createAssignmentWithQuestions({
    required String teacherId,
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
  });

  /// Persist draft: sync assignment + questions + distributions xuống DB.
  Future<Assignment> saveDraft({
    required String assignmentId,
    required Map<String, dynamic> assignmentPatch,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> distributions,
  });

  /// Publish trong 1 RPC để giảm round-trip (server-side transaction).
  Future<Assignment> publishAssignment({
    required Map<String, dynamic> assignment,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> distributions,
  });

  Future<void> deleteAssignment(String id);

  /// Get assignment statistics for teacher
  Future<AssignmentStatistics> getAssignmentStatistics(String teacherId);

  /// Get recent activities (assignments) for teacher
  Future<List<Assignment>> getRecentActivities(String teacherId, {int limit = 10});
}


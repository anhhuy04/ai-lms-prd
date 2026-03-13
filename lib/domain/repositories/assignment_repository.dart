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

  /// Lấy danh sách bài tập đã distribute cho 1 lớp (teacher view).
  /// Trả về Map chứa cả assignment info + distribution info.
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsByClass(
    String classId,
  );

  /// Lấy bài tập cho học sinh trong 1 lớp.
  /// Filter theo distribution_type (class/group/individual).
  Future<List<Map<String, dynamic>>> getDistributedAssignmentsForStudent(
    String classId,
    String studentId,
  );

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

  /// Phân phối bài tập cho lớp / nhóm / học sinh cụ thể.
  /// Tạo record trong bảng `assignment_distributions`.
  Future<AssignmentDistribution> distributeAssignment({
    required String assignmentId,
    required String classId,
    required String distributionType, // 'class' | 'group' | 'individual'
    String? groupId,
    List<String>? studentIds,
    DateTime? availableFrom,
    DateTime? dueAt,
    int? timeLimitMinutes,
    bool allowLate = true,
    Map<String, dynamic>? latePolicy,
    bool sendNotification = true,

    /// Cấu hình shuffle và hiển thị điểm - lưu vào cột settings JSONB
    /// {
    ///   "shuffle_questions": false,
    ///   "shuffle_choices": false,
    ///   "show_score_immediately": true
    /// }
    Map<String, dynamic>? settings,
  });

  /// Get assignment statistics for teacher
  Future<AssignmentStatistics> getAssignmentStatistics(String teacherId);

  /// Get recent activities (assignments) for teacher
  Future<List<Assignment>> getRecentActivities(
    String teacherId, {
    int limit = 10,
  });

  /// Get all distributions for a teacher (across all their assignments)
  Future<List<AssignmentDistribution>> getDistributionsByTeacher(String teacherId);

  /// Lấy chi tiết distribution kèm assignment info.
  Future<Map<String, dynamic>> getDistributionDetail(String distributionId);

  /// Lấy danh sách submissions cho 1 distribution (kèm student info).
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  );

  /// Lấy danh sách tất cả bài tập của học sinh (từ tất cả các lớp)
  Future<List<Map<String, dynamic>>> getStudentAssignments(String studentId);

  /// Lấy hoặc tạo bài nộp draft cho một distribution
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  );

  /// Lưu bản nháp bài nộp (học sinh)
  Future<void> saveSubmissionDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  );

  /// Nộp bài tập
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  );

  /// Lấy lịch sử nộp bài của học sinh
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  );
}

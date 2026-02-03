import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/entities/assignment_variant.dart';
import 'package:ai_mls/domain/repositories/assignment_repository.dart';

/// Usecase: Tạo assignment draft (chưa publish).
class CreateAssignmentDraftUseCase {
  final AssignmentRepository _assignmentRepository;

  CreateAssignmentDraftUseCase(this._assignmentRepository);

  /// [payload] cần bao gồm tối thiểu:
  /// - class_id
  /// - teacher_id
  /// - title
  /// - is_published = false
  Future<Assignment> call(Map<String, dynamic> payload) {
    return _assignmentRepository.createAssignment(payload);
  }
}

/// Usecase: Cập nhật metadata của assignment (title, due_at, ...).
///
/// Giai đoạn đầu có thể dùng ở phía client (local state), sau này mở rộng
/// để persist xuống DB nếu cần.
class UpdateAssignmentMetaUseCase {
  const UpdateAssignmentMetaUseCase();

  Assignment call(Assignment current, Map<String, dynamic> meta) {
    return current.copyWith(
      title: meta['title'] as String? ?? current.title,
      description: meta['description'] as String? ?? current.description,
      dueAt: meta['due_at'] as DateTime? ?? current.dueAt,
      availableFrom: meta['available_from'] as DateTime? ?? current.availableFrom,
      timeLimitMinutes:
          meta['time_limit_minutes'] as int? ?? current.timeLimitMinutes,
      allowLate: meta['allow_late'] as bool? ?? current.allowLate,
      totalPoints: meta['total_points'] as double? ?? current.totalPoints,
    );
  }
}

/// Usecase: Persist assignment draft xuống DB (assignments + assignment_questions + assignment_distributions).
class SaveAssignmentDraftUseCase {
  final AssignmentRepository _assignmentRepository;

  SaveAssignmentDraftUseCase(this._assignmentRepository);

  Future<Assignment> call({
    required Assignment draft,
    required List<AssignmentQuestion> questions,
    required List<AssignmentDistribution> distributions,
  }) async {
    // assignments table hiện chỉ lưu meta chung của bài tập.
    // Các trường về thời gian/allow_late đã được chuyển sang assignment_distributions.
    final patch = <String, dynamic>{
      'class_id': draft.classId,
      'title': draft.title,
      'description': draft.description,
      'total_points': draft.totalPoints,
      'is_published': false,
    };

    final questionRows = questions
        .map(
          (q) => <String, dynamic>{
            'assignment_id': draft.id,
            'question_id': q.questionId,
            'custom_content': q.customContent,
            'points': q.points,
            'rubric': q.rubric,
            'order_idx': q.orderIdx,
          },
        )
        .toList();

    final distributionRows = distributions
        .map(
          (d) => <String, dynamic>{
            'assignment_id': draft.id,
            'distribution_type': d.distributionType,
            'class_id': d.classId,
            'group_id': d.groupId,
            'student_ids': d.studentIds,
            'available_from': d.availableFrom?.toIso8601String(),
            'due_at': d.dueAt?.toIso8601String(),
            'time_limit_minutes': d.timeLimitMinutes,
            'allow_late': d.allowLate,
            'late_policy': d.latePolicy,
          },
        )
        .toList();

    return _assignmentRepository.saveDraft(
      assignmentId: draft.id,
      assignmentPatch: patch,
      questions: questionRows,
      distributions: distributionRows,
    );
  }
}

/// Usecase: Publish assignment trong 1 RPC (server-side transaction).
class PublishAssignmentUseCase {
  final AssignmentRepository _assignmentRepository;

  PublishAssignmentUseCase(this._assignmentRepository);

  Future<Assignment> call({
    required Assignment draft,
    required List<AssignmentQuestion> questions,
    required List<AssignmentDistribution> distributions,
  }) async {
    // assignments: chỉ chứa meta chung (class_id, teacher_id, title, description, total_points...).
    // Các trường due_at/available_from/time_limit/allow_late được lưu ở assignment_distributions.
    final assignment = <String, dynamic>{
      'id': draft.id,
      'class_id': draft.classId,
      'teacher_id': draft.teacherId,
      'title': draft.title,
      'description': draft.description,
      'total_points': draft.totalPoints,
    };

    final questionRows = questions
        .map(
          (q) => <String, dynamic>{
            'question_id': q.questionId,
            'custom_content': q.customContent,
            'points': q.points,
            'rubric': q.rubric,
            'order_idx': q.orderIdx,
          },
        )
        .toList();

    final distributionRows = distributions
        .map(
          (d) => <String, dynamic>{
            'distribution_type': d.distributionType,
            'class_id': d.classId,
            'group_id': d.groupId,
            'student_ids': d.studentIds,
            'available_from': d.availableFrom?.toIso8601String(),
            'due_at': d.dueAt?.toIso8601String(),
            'time_limit_minutes': d.timeLimitMinutes,
            'allow_late': d.allowLate,
            'late_policy': d.latePolicy,
          },
        )
        .toList();

    return _assignmentRepository.publishAssignment(
      assignment: assignment,
      questions: questionRows,
      distributions: distributionRows,
    );
  }
}

/// Usecase: Lấy đầy đủ chi tiết một assignment (questions + variants + distributions).
class AssignmentDetail {
  final Assignment assignment;
  final List<AssignmentQuestion> questions;
  final List<AssignmentDistribution> distributions;
  final List<AssignmentVariant> variants;

  const AssignmentDetail({
    required this.assignment,
    required this.questions,
    required this.distributions,
    required this.variants,
  });
}

class GetAssignmentDetailUseCase {
  final AssignmentRepository _assignmentRepository;

  GetAssignmentDetailUseCase(this._assignmentRepository);

  Future<AssignmentDetail> call(String assignmentId) async {
    final assignmentFuture = _assignmentRepository.getAssignmentById(assignmentId);
    final questionsFuture =
        _assignmentRepository.getAssignmentQuestions(assignmentId);
    final distributionsFuture =
        _assignmentRepository.getDistributions(assignmentId);
    final variantsFuture = _assignmentRepository.getVariants(assignmentId);

    // Chạy song song tất cả queries.
    final results = await Future.wait([
      assignmentFuture,
      questionsFuture,
      distributionsFuture,
      variantsFuture,
    ]);

    final assignment = results[0] as Assignment;
    final questions = results[1] as List<AssignmentQuestion>;
    final distributions = results[2] as List<AssignmentDistribution>;
    final variants = results[3] as List<AssignmentVariant>;

    return AssignmentDetail(
      assignment: assignment,
      questions: questions,
      distributions: distributions,
      variants: variants,
    );
  }
}


import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distribute_assignment_notifier.freezed.dart';
part 'distribute_assignment_notifier.g.dart';

/// State cho màn hình Phân phối bài tập
@freezed
class DistributeAssignmentState with _$DistributeAssignmentState {
  const factory DistributeAssignmentState({
    // Dữ liệu bài tập (optional – nếu được truyền vào từ hub/list)
    Assignment? assignment,
    // Danh sách bài tập được chọn (hỗ trợ phân phối nhiều bài cùng lúc)
    @Default([]) List<Assignment> selectedAssignments,

    // --- Đối tượng nhận bài (Tree Selection) ---
    RecipientSelectionResult? recipientSelection,

    // --- Thời gian ---
    DateTime? dueDate, // Ngày giờ nộp bài
    DateTime? availableFrom, // Ngày giờ mở bài (null = ngay lập tức)
    DateTime? availableUntil, // Ngày giờ đóng bài (null = không giới hạn)
    @Default(null) int? timeLimitMinutes, // Giới hạn thời gian làm bài (phút)
    // --- Cài đặt nâng cao ---
    @Default(true) bool allowLate, // Cho phép nộp muộn
    @Default(10) int latePenaltyPercent, // Phần trăm trừ điểm mỗi ngày trễ
    @Default(true) bool showScoreImmediately, // Hiển thị điểm ngay sau khi nộp
    @Default(true) bool sendNotification, // Gửi thông báo cho học sinh
    @Default(false) bool shuffleQuestions, // Đảo câu hỏi
    @Default(false) bool shuffleAnswers, // Đảo đáp án
    // --- UI State ---
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? errorMessage,
  }) = _DistributeAssignmentState;
}

/// Notifier cho màn hình Phân phối bài tập
@riverpod
class DistributeAssignmentNotifier extends _$DistributeAssignmentNotifier {
  @override
  DistributeAssignmentState build({String? assignmentId}) {
    // Kick off data loading if assignmentId is provided
    if (assignmentId != null && assignmentId.isNotEmpty) {
      Future.microtask(() => _loadAssignment(assignmentId));
    }
    return const DistributeAssignmentState();
  }

  /// Load thông tin bài tập từ repository (nếu cần prefill)
  Future<void> _loadAssignment(String rawAssignmentIds) async {
    try {
      final repository = ref.read(assignmentRepositoryProvider);

      final ids = rawAssignmentIds
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList();
      if (ids.isEmpty) return;

      final assignments = await Future.wait(
        ids.map((id) => repository.getAssignmentById(id)),
      );

      final validAssignments = assignments.whereType<Assignment>().toList();
      if (validAssignments.isEmpty) return;

      final firstAssignment = validAssignments.first;

      // Prefill state từ dữ liệu bài tập đầu tiên (cho settings) và list bài tập
      state = state.copyWith(
        assignment: firstAssignment,
        selectedAssignments: validAssignments,
        dueDate: firstAssignment.dueAt,
        availableFrom: firstAssignment.availableFrom,
        timeLimitMinutes: firstAssignment.timeLimitMinutes,
        allowLate: firstAssignment.allowLate,
      );
    } catch (e, stack) {
      AppLogger.error(
        '🔴 [DISTRIBUTE] Error loading assignment: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> loadAssignmentsByIds(List<String> ids) async {
    if (ids.isEmpty) {
      state = state.copyWith(selectedAssignments: [], assignment: null);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(assignmentRepositoryProvider);
      final assignments = await Future.wait(
        ids.map((id) => repository.getAssignmentById(id)),
      );
      final validAssignments = assignments.whereType<Assignment>().toList();
      state = state.copyWith(
        selectedAssignments: validAssignments,
        assignment: validAssignments.isNotEmpty ? validAssignments.first : null,
        isLoading: false,
      );
    } catch (e, stack) {
      state = state.copyWith(isLoading: false);
      AppLogger.error(
        '🔴 [DISTRIBUTE] Error loadAssignmentsByIds: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  // ===================== Recipient =====================

  void setRecipientSelection(RecipientSelectionResult selection) {
    state = state.copyWith(recipientSelection: selection);
  }

  void removeClassSelection(String classId) {
    if (state.recipientSelection == null) return;

    final newSelection = state.recipientSelection!.copyWith(
      fullySelectedClassIds: Set.from(
        state.recipientSelection!.fullySelectedClassIds,
      )..remove(classId),
    );
    state = state.copyWith(recipientSelection: newSelection);
  }

  void removeGroupSelection(String classId, String groupId) {
    if (state.recipientSelection == null) return;

    final newGroups = Map<String, Set<String>>.from(
      state.recipientSelection!.selectedGroupIdsByClass,
    );
    if (newGroups.containsKey(classId)) {
      newGroups[classId] = Set.from(newGroups[classId]!)..remove(groupId);
      if (newGroups[classId]!.isEmpty) {
        newGroups.remove(classId);
      }
    }

    final newSelection = state.recipientSelection!.copyWith(
      selectedGroupIdsByClass: newGroups,
    );
    state = state.copyWith(recipientSelection: newSelection);
  }

  void removeStudentSelection(String classId, String studentId) {
    if (state.recipientSelection == null) return;

    final newStudents = Map<String, Set<String>>.from(
      state.recipientSelection!.selectedStudentIdsByClass,
    );
    if (newStudents.containsKey(classId)) {
      newStudents[classId] = Set.from(newStudents[classId]!)..remove(studentId);
      if (newStudents[classId]!.isEmpty) {
        newStudents.remove(classId);
      }
    }

    final newSelection = state.recipientSelection!.copyWith(
      selectedStudentIdsByClass: newStudents,
    );
    state = state.copyWith(recipientSelection: newSelection);
  }

  // ===================== Time =====================

  void setDueDate(DateTime? dateTime) {
    state = state.copyWith(dueDate: dateTime);
  }

  void setAvailableFrom(DateTime? dateTime) {
    state = state.copyWith(availableFrom: dateTime);
  }

  void setAvailableUntil(DateTime? dateTime) {
    state = state.copyWith(availableUntil: dateTime);
  }

  void setTimeLimitMinutes(int? minutes) {
    state = state.copyWith(timeLimitMinutes: minutes);
  }

  // ===================== Advanced settings =====================

  void setAllowLate(bool value) {
    state = state.copyWith(allowLate: value);
  }

  void setLatePenaltyPercent(int percent) {
    state = state.copyWith(latePenaltyPercent: percent.clamp(0, 100));
  }

  void setShowScoreImmediately(bool value) {
    state = state.copyWith(showScoreImmediately: value);
  }

  void setSendNotification(bool value) {
    state = state.copyWith(sendNotification: value);
  }

  void setShuffleQuestions(bool value) {
    state = state.copyWith(shuffleQuestions: value);
  }

  void setShuffleAnswers(bool value) {
    state = state.copyWith(shuffleAnswers: value);
  }

  // ===================== Validation =====================

  String? _validate() {
    // Kiểm tra bài tập
    final hasAssignments = state.selectedAssignments.isNotEmpty;
    final hasSingle =
        state.assignment != null ||
        (assignmentId != null && assignmentId!.isNotEmpty);
    if (!hasAssignments && !hasSingle) {
      return 'Chưa chọn bài tập để phân phối';
    }

    // Kiểm tra người nhận
    if (state.recipientSelection == null || state.recipientSelection!.isEmpty) {
      return 'Vui lòng chọn ít nhất một lớp, nhóm hoặc học sinh';
    }

    // Kiểm tra thời gian
    if (state.dueDate != null && state.availableFrom != null) {
      if (state.dueDate!.isBefore(state.availableFrom!)) {
        return 'Ngày hết hạn phải sau ngày bắt đầu';
      }
    }
    if (state.dueDate != null && state.dueDate!.isBefore(DateTime.now())) {
      return 'Ngày hết hạn phải ở tương lai';
    }

    return null;
  }

  // ===================== Distribute now =====================

  /// Phân phối bài tập ngay lập tức (hỗ trợ multi-assignment)
  Future<void> distributeNow() async {
    final error = _validate();
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final auth = ref.read(authNotifierProvider);
      final profile = auth.value;
      if (profile == null) throw Exception('Người dùng chưa đăng nhập');

      final repository = ref.read(assignmentRepositoryProvider);

      // Xác định danh sách assignment IDs cần distribute
      final List<String> targetIds;
      if (state.selectedAssignments.isNotEmpty) {
        targetIds = state.selectedAssignments.map((a) => a.id).toList();
      } else {
        final singleId = assignmentId ?? state.assignment?.id;
        if (singleId == null) throw Exception('Không tìm thấy bài tập');
        targetIds = [singleId];
      }

      final sel = state.recipientSelection!;
      // Tử Huyệt 4: late_policy phải dùng đúng cấu trúc chuẩn hóa
      final latePolicy = state.allowLate
          ? <String, dynamic>{
              'policy_type': 'daily_deduction',
              'deduction_value': state.latePenaltyPercent,
              'unit': 'percent',
              'max_days_allowed': 7, // default 7 ngày cho phép nộp trễ
              'lowest_possible_score': 0,
            }
          : null;

      // Settings JSON - Tử Huyệt 4: thêm student_review_mode và ai_feedback_enabled
      final settings = <String, dynamic>{
        'shuffle_questions': state.shuffleQuestions,
        'shuffle_choices': state.shuffleAnswers,
        'show_score_immediately': state.showScoreImmediately,
        'student_review_mode': state.showScoreImmediately
            ? 'full_review'
            : 'score_only',
        'ai_feedback_enabled': true, // bật AI feedback theo mặc định
      };

      // Loop qua từng assignment (hỗ trợ multi-assignment)
      for (final targetAssignmentId in targetIds) {
        // 1. Phân phối cho những lớp chọn TẤT CẢ
        for (final classId in sel.fullySelectedClassIds) {
          await repository.distributeAssignment(
            assignmentId: targetAssignmentId,
            classId: classId,
            distributionType: 'class',
            availableFrom: state.availableFrom,
            dueAt: state.dueDate,
            timeLimitMinutes: state.timeLimitMinutes,
            allowLate: state.allowLate,
            latePolicy: latePolicy,
            sendNotification: state.sendNotification,
            settings: settings,
          );
        }

        // 2. Phân phối cho các nhóm — mỗi nhóm 1 row riêng
        for (final entry in sel.selectedGroupIdsByClass.entries) {
          final classId = entry.key;
          final groupIds = entry.value;
          if (groupIds.isEmpty) continue;

          // Loop từng groupId → 1 INSERT/row (khớp DB constraint: 1 group_id per row)
          for (final groupId in groupIds) {
            await repository.distributeAssignment(
              assignmentId: targetAssignmentId,
              classId: classId,
              distributionType:
                  'group', // ← DB CHECK: 'group' (không phải 'groups')
              groupId: groupId,
              availableFrom: state.availableFrom,
              dueAt: state.dueDate,
              timeLimitMinutes: state.timeLimitMinutes,
              allowLate: state.allowLate,
              latePolicy: latePolicy,
              sendNotification: state.sendNotification,
              settings: settings,
            );
          }
        }

        // 3. Phân phối cho các học sinh chọn lẻ trong từng lớp
        for (final entry in sel.selectedStudentIdsByClass.entries) {
          final classId = entry.key;
          final studentIds = entry.value;
          if (studentIds.isEmpty) continue;

          await repository.distributeAssignment(
            assignmentId: targetAssignmentId,
            classId: classId,
            distributionType:
                'individual', // ← DB CHECK: 'individual' (không phải 'students')
            studentIds: studentIds.toList(),
            availableFrom: state.availableFrom,
            dueAt: state.dueDate,
            timeLimitMinutes: state.timeLimitMinutes,
            allowLate: state.allowLate,
            latePolicy: latePolicy,
            sendNotification: state.sendNotification,
            settings: settings,
          );
        }
      }

      AppLogger.info(
        '✅ [DISTRIBUTE] Distributed ${targetIds.length} assignments successfully',
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e, stack) {
      AppLogger.error(
        '🔴 [DISTRIBUTE] Error distributing: $e',
        error: e,
        stackTrace: stack,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Phân phối thất bại: ${e.toString()}',
      );
    }
  }

  /// Lên lịch phân phối (đặt availableFrom trước)
  Future<void> scheduleDistribute(DateTime scheduledAt) async {
    setAvailableFrom(scheduledAt);
    await distributeNow();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

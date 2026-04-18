import 'dart:async';
import 'dart:io';

import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'workspace_provider.g.dart';

/// Trạng thái lưu trữ
enum SavingStatus {
  /// Chưa lưu
  idle,

  /// Đang lưu
  saving,

  /// Đã lưu
  saved,

  /// Lỗi khi lưu
  error,
}

/// Trạng thái nộp bài
enum WorkspaceSubmissionStatus {
  /// Đang làm bài (draft)
  inProgress,

  /// Đang nộp
  submitting,

  /// Đã nộp thành công
  submitted,

  /// Lỗi khi nộp
  error,
}

/// State cho workspace
@riverpod
class WorkspaceNotifier extends _$WorkspaceNotifier {
  @override
  AsyncValue<WorkspaceState> build(String distributionId) {
    // Cleanup khi provider bị dispose (auto-dispose notifier)
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _questionChannel?.unsubscribe();
      _questionChannel = null;
    });
    return const AsyncLoading();
  }

  /// Concurrency guard
  bool _isUpdating = false;

  /// Debounce timer cho auto-save
  Timer? _debounceTimer;

  /// Realtime channel: lắng nghe GV hotfix assignment_questions
  RealtimeChannel? _questionChannel;

  /// Khởi tạo workspace - load assignment và submission
  Future<void> initialize() async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      state = const AsyncLoading();

      final repo = ref.read(assignmentRepositoryProvider);
      final auth = ref.read(authNotifierProvider);
      final studentId = auth.value?.id;

      if (studentId == null) {
        throw Exception('User not authenticated');
      }

      // getOrCreateSubmission phải chạy TRƯỚC getDistributionDetail.
      // Lý do: ensure_student_variant được gọi bên trong getOrCreateSubmission.
      // Nếu gọi getDistributionDetail trước, variant chưa tồn tại → shuffle không apply.
      final submission = await repo.getOrCreateSubmission(distributionId, studentId);
      final detail = await repo.getDistributionDetail(
        distributionId,
        studentId: studentId,
      );

      // Extract data từ detail (cấu trúc mới)
      final assignment = detail['assignment'] as Map<String, dynamic>? ?? {};
      final questions = detail['questions'] as List<dynamic>? ?? [];
      final distribution = detail['distribution'] as Map<String, dynamic>? ?? {};

      // Extract existing answers - these may not exist in DB yet
      Map<String, dynamic> existingAnswers = {};
      if (submission?['answers'] is Map) {
        existingAnswers = submission!['answers'] as Map<String, dynamic>;
      }
      List<dynamic> uploadedFiles = [];
      if (submission?['uploaded_files'] is List) {
        uploadedFiles = submission!['uploaded_files'] as List<dynamic>;
      }

      // Parse server-side timing data
      final timeLimitMinutes = distribution['time_limit_minutes'] as int?;
      DateTime? sessionStartedAt;
      final startedAtRaw = submission?['started_at'] as String?;
      if (startedAtRaw != null) {
        sessionStartedAt = DateTime.tryParse(startedAtRaw);
      }

      final wsState = WorkspaceState(
        distributionId: distributionId,
        assignmentTitle: assignment['title'] as String? ?? 'Bài tập',
        totalPoints: (assignment['total_points'] as num?)?.toDouble(),
        dueAt: distribution['due_at'] != null
            ? DateTime.tryParse(distribution['due_at'] as String)
            : null,
        timeLimitMinutes: timeLimitMinutes,
        sessionStartedAt: sessionStartedAt,
        questions: questions.map((q) => QuestionState.fromJson(q as Map<String, dynamic>)).toList(),
        answers: Map<String, dynamic>.from(existingAnswers),
        uploadedFiles: List<String>.from(uploadedFiles),
        // L6 fix: include 'pending_review' — AI done, awaiting teacher.
        // Student must NOT be able to re-enter workspace in this state.
        submissionStatus: (submission?['status'] == 'submitted' ||
                submission?['status'] == 'graded' ||
                submission?['status'] == 'ai_processing' ||
                submission?['status'] == 'pending_review')
            ? WorkspaceSubmissionStatus.submitted
            : WorkspaceSubmissionStatus.inProgress,
        savingStatus: SavingStatus.idle,
      );

      state = AsyncData(wsState);

      // Subscribe Realtime: lắng nghe GV hotfix assignment_questions
      final assignmentId = detail['assignment']?['id'] as String? ??
          detail['assignment_id'] as String?;
      if (assignmentId != null) {
        _subscribeToQuestionChanges(assignmentId);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [WORKSPACE ERROR] initialize: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncError(e, stackTrace);
    } finally {
      _isUpdating = false;
    }
  }

  /// Cập nhật câu trả lời cho một câu hỏi
  void updateAnswer(String questionId, dynamic answer) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Optimistic update
    final newAnswers = Map<String, dynamic>.from(currentState.answers);
    newAnswers[questionId] = answer;

    state = AsyncData(currentState.copyWith(
      answers: newAnswers,
      savingStatus: SavingStatus.idle,
    ));

    // Auto-save after 2 seconds
    _debounceTimer?.cancel();
    EasyDebounce.debounce(
      'workspace-autosave',
      const Duration(seconds: 2),
      () => _saveDraft(),
    );
  }

  /// Public method để lưu bản nháp khi user bấm back
  Future<void> saveDraft() async {
    await _saveDraft();
  }

  /// Lưu bản nháp (auto-save hoặc manual)
  Future<void> _saveDraft() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.submissionStatus != WorkspaceSubmissionStatus.inProgress) return;

    state = AsyncData(currentState.copyWith(savingStatus: SavingStatus.saving));

    try {
      final repo = ref.read(assignmentRepositoryProvider);
      final auth = ref.read(authNotifierProvider);
      final studentId = auth.value?.id;

      if (studentId == null) return;

      await repo.saveSubmissionDraft(
        distributionId,
        studentId,
        currentState.answers,
        currentState.uploadedFiles,
      );

      final savedState = state.valueOrNull;
      if (savedState != null) {
        state = AsyncData(savedState.copyWith(savingStatus: SavingStatus.saved));

        // Reset to idle after 2 seconds — chỉ khi vẫn đang inProgress
        Future.delayed(const Duration(seconds: 2), () {
          final s = state.valueOrNull;
          if (s != null && s.submissionStatus == WorkspaceSubmissionStatus.inProgress) {
            state = AsyncData(s.copyWith(savingStatus: SavingStatus.idle));
          }
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [WORKSPACE ERROR] _saveDraft: $e',
        error: e,
        stackTrace: stackTrace,
      );
      final errorState = state.valueOrNull;
      if (errorState != null) {
        state = AsyncData(errorState.copyWith(savingStatus: SavingStatus.error));
      }
    }
  }

  /// Upload file lên Supabase Storage
  Future<String?> uploadFile(File file, {void Function(double progress)? onProgress}) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    try {
      final client = SupabaseService.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Generate unique file name
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Upload with progress tracking
      await client.storage.from('submissions').uploadBinary(
        fileName,
        await file.readAsBytes(),
        fileOptions: FileOptions(
          contentType: _getContentType(file.path),
          upsert: false,
        ),
      );

      // Get public URL
      final publicUrl = client.storage.from('submissions').getPublicUrl(fileName);

      // Update state with new file
      final newFiles = List<String>.from(currentState.uploadedFiles)..add(publicUrl);
      state = AsyncData(currentState.copyWith(uploadedFiles: newFiles));

      // Save draft with new file
      await _saveDraft();

      return publicUrl;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [WORKSPACE ERROR] uploadFile: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Xóa file đã upload
  void removeFile(String fileUrl) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newFiles = currentState.uploadedFiles.where((f) => f != fileUrl).toList();
    state = AsyncData(currentState.copyWith(uploadedFiles: newFiles));

    // Save draft
    _saveDraft();
  }

  /// Nộp bài tập
  Future<bool> submit({Map<String, int>? timeLog}) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;
    if (currentState.submissionStatus != WorkspaceSubmissionStatus.inProgress) return false;
    // Double-submit guard: ngăn 2 lần bấm nộp đồng thời
    if (_isUpdating) return false;
    _isUpdating = true;

    _debounceTimer?.cancel();
    EasyDebounce.cancel('workspace-autosave');

    state = AsyncData(currentState.copyWith(savingStatus: SavingStatus.saving));

    try {
      final repo = ref.read(assignmentRepositoryProvider);
      final auth = ref.read(authNotifierProvider);
      final studentId = auth.value?.id;

      if (studentId == null) {
        throw Exception('User not authenticated');
      }

      // Force-save trực tiếp (throws on error) trước khi submit.
      // Gọi repo thẳng thay vì _saveDraft() để lỗi không bị nuốt.
      await repo.saveSubmissionDraft(
        distributionId,
        studentId,
        currentState.answers,
        currentState.uploadedFiles,
      );

      state = AsyncData(currentState.copyWith(
        submissionStatus: WorkspaceSubmissionStatus.submitting,
        savingStatus: SavingStatus.saved,
      ));

      await repo.submitAssignment(distributionId, studentId, timeLog: timeLog);

      state = AsyncData(currentState.copyWith(
        submissionStatus: WorkspaceSubmissionStatus.submitted,
        savingStatus: SavingStatus.saved,
      ));

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [WORKSPACE ERROR] submit: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncData(currentState.copyWith(
        submissionStatus: WorkspaceSubmissionStatus.error,
        savingStatus: SavingStatus.error,
      ));
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  void _subscribeToQuestionChanges(String assignmentId) {
    // Unsubscribe channel cũ trước, null out để tránh ghost reference
    if (_questionChannel != null) {
      _questionChannel!.unsubscribe();
      _questionChannel = null;
    }
    _questionChannel = SupabaseService.client
        .channel('aq_hotfix_$assignmentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'assignment_questions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'assignment_id',
            value: assignmentId,
          ),
          callback: (payload) => _onQuestionUpdated(payload.newRecord),
        )
        .subscribe((status, [error]) {
          if (error != null) {
            AppLogger.warning('[WORKSPACE] Realtime subscription error: $error');
          }
        });
  }

  void _onQuestionUpdated(Map<String, dynamic> updatedAq) {
    // Concurrency guard: không update state khi đang có operation khác chạy
    if (_isUpdating) return;

    final current = state.valueOrNull;
    if (current == null) return;
    final aqId = updatedAq['id'] as String?;
    if (aqId == null) {
      AppLogger.warning('[WORKSPACE] Realtime: missing id in payload');
      return;
    }
    final customContent =
        updatedAq['custom_content'] as Map<String, dynamic>?;
    if (customContent == null) return;

    final updatedQuestions = current.questions.map((q) {
      if (q.id != aqId) return q;

      // Patch text
      final newText = customContent['override_text'] as String?;

      // Patch choices — apply isCorrect từ override, giữ nguyên id/content
      final overrideChoices = customContent['choices'] as List<dynamic>?;
      List<QuestionChoiceState> newChoices = q.choices;
      if (overrideChoices != null &&
          overrideChoices.length == q.choices.length) {
        newChoices = overrideChoices.asMap().entries.map((entry) {
          final idx = entry.key;
          final c = entry.value as Map<String, dynamic>;
          return q.choices[idx].copyWith(
            isCorrect: c['isCorrect'] as bool? ?? c['is_correct'] as bool?,
          );
        }).toList();
      }

      return q.copyWith(
        content: newText ?? q.content,
        choices: newChoices,
      );
    }).toList();

    state = AsyncData(current.copyWith(questions: updatedQuestions));
  }

}

/// State cho workspace
class WorkspaceState {
  final String distributionId;
  final String assignmentTitle;
  final double? totalPoints;
  final DateTime? dueAt;
  /// Giới hạn thời gian làm bài (phút), null = không giới hạn
  final int? timeLimitMinutes;
  /// Thời điểm học sinh bắt đầu làm bài (từ server — đóng đinh, không thể giả mạo)
  final DateTime? sessionStartedAt;
  final List<QuestionState> questions;
  final Map<String, dynamic> answers;
  final List<String> uploadedFiles;
  final WorkspaceSubmissionStatus submissionStatus;
  final SavingStatus savingStatus;

  const WorkspaceState({
    required this.distributionId,
    required this.assignmentTitle,
    this.totalPoints,
    this.dueAt,
    this.timeLimitMinutes,
    this.sessionStartedAt,
    required this.questions,
    required this.answers,
    required this.uploadedFiles,
    required this.submissionStatus,
    required this.savingStatus,
  });

  WorkspaceState copyWith({
    String? distributionId,
    String? assignmentTitle,
    double? totalPoints,
    DateTime? dueAt,
    int? timeLimitMinutes,
    DateTime? sessionStartedAt,
    List<QuestionState>? questions,
    Map<String, dynamic>? answers,
    List<String>? uploadedFiles,
    WorkspaceSubmissionStatus? submissionStatus,
    SavingStatus? savingStatus,
  }) {
    return WorkspaceState(
      distributionId: distributionId ?? this.distributionId,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      totalPoints: totalPoints ?? this.totalPoints,
      dueAt: dueAt ?? this.dueAt,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      savingStatus: savingStatus ?? this.savingStatus,
    );
  }

  /// Số câu hỏi đã trả lời
  int get answeredCount {
    int count = 0;
    for (final question in questions) {
      final answer = answers[question.id];
      if (answer != null) {
        if (answer is String && answer.isNotEmpty) {
          count++;
        } else if (answer is List && answer.isNotEmpty) {
          count++;
        } else if (answer is! String) {
          count++;
        }
      }
    }
    return count;
  }

  /// Tổng số câu hỏi
  int get totalQuestions => questions.length;
}

/// State cho một câu hỏi
class QuestionState {
  final String id;
  final String content;
  final String type;
  final double points;
  final List<QuestionChoiceState> choices;
  // New fields for format v2
  final List<Map<String, dynamic>>? blanks;
  final List<Map<String, dynamic>>? pairs;
  final List<Map<String, dynamic>>? distractors;
  final String? expectedAnswer;
  final List<Map<String, dynamic>>? aiGradingKeywords;
  final Map<String, dynamic>? rubric;

  const QuestionState({
    required this.id,
    required this.content,
    required this.type,
    required this.points,
    required this.choices,
    this.blanks,
    this.pairs,
    this.distractors,
    this.expectedAnswer,
    this.aiGradingKeywords,
    this.rubric,
  });

  QuestionState copyWith({
    String? id,
    String? content,
    String? type,
    double? points,
    List<QuestionChoiceState>? choices,
    List<Map<String, dynamic>>? blanks,
    List<Map<String, dynamic>>? pairs,
    List<Map<String, dynamic>>? distractors,
    String? expectedAnswer,
    List<Map<String, dynamic>>? aiGradingKeywords,
    Map<String, dynamic>? rubric,
  }) {
    return QuestionState(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      points: points ?? this.points,
      choices: choices ?? this.choices,
      blanks: blanks ?? this.blanks,
      pairs: pairs ?? this.pairs,
      distractors: distractors ?? this.distractors,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      aiGradingKeywords: aiGradingKeywords ?? this.aiGradingKeywords,
      rubric: rubric ?? this.rubric,
    );
  }

  factory QuestionState.fromJson(Map<String, dynamic> json) {
    // DEBUG: Log đầu vào
    AppLogger.debug('🔵 [WORKSPACE] QuestionState.fromJson input: $json');

    // Cấu trúc mới: trực tiếp từ detail['questions']
    // hoặc cấu trúc cũ: json['questions']
    final question = json['questions'] as Map<String, dynamic>? ?? json;

    AppLogger.debug('🔵 [WORKSPACE] question parsed: $question');

    // Handle content - could be String or Map
    // Format mới: ưu tiên override_text
    String contentStr = '';
    dynamic contentData = question['content'] ?? json['content'];
    if (contentData is String) {
      contentStr = contentData;
    } else if (contentData is Map) {
      contentStr = contentData['override_text'] as String? ?? contentData['text'] as String? ?? '';
    }

    // Handle choices - ưu tiên question['question_choices'] vì getDistributionDetail trả về key này
    List<dynamic> choicesList = [];
    // First check question['question_choices'] (from getDistributionDetail)
    choicesList = question['question_choices'] as List<dynamic>? ?? json['question_choices'] as List<dynamic>? ?? [];
    AppLogger.debug('🔵 [WORKSPACE] question_choices from DB: $choicesList');
    // Apply shuffled_choices order from variant (Shuffle Architecture)
    final shuffledIds = question['shuffled_choices'] as List<dynamic>?
        ?? json['shuffled_choices'] as List<dynamic>?;
    if (shuffledIds != null && shuffledIds.isNotEmpty && choicesList.isNotEmpty) {
      final byId = <dynamic, Map<String, dynamic>>{};
      for (final c in choicesList) {
        final cMap = c as Map<String, dynamic>;
        final cId = cMap['id'];
        if (cId != null) {
          byId[cId] = cMap;
          byId[cId.toString()] = cMap;
          final parsed = cId is int ? cId : int.tryParse(cId.toString());
          if (parsed != null) byId[parsed] = cMap;
        }
      }
      final reordered = shuffledIds.map((sid) {
        return byId[sid] ?? byId[sid.toString()] ??
            byId[sid is int ? sid : int.tryParse(sid.toString())];
      }).whereType<Map<String, dynamic>>().toList();
      if (reordered.length == choicesList.length) {
        choicesList = reordered;
      }
    }

    // If still empty, check contentData['options'] (for other formats)
    if (choicesList.isEmpty && contentData is Map) {
      final optionsData = contentData['options'] ?? contentData['choices'];
      if (optionsData is List && optionsData.isNotEmpty) {
        choicesList = optionsData.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final opt = entry.value;
          return {
            'id': index, // int format: 0, 1, 2...
            'content': {'text': opt['text'] ?? opt['content']},
            'is_correct': opt['isCorrect'] ?? opt['is_correct'] ?? false,
          };
        }).toList();
      }
    }

    // Parse blanks (for fill_blank)
    List<Map<String, dynamic>>? blanks;
    final blanksData = question['blanks'] ?? json['blanks'];
    if (blanksData is List && blanksData.isNotEmpty) {
      blanks = blanksData.cast<Map<String, dynamic>>();
    }

    // Parse pairs (for matching)
    List<Map<String, dynamic>>? pairs;
    final pairsData = question['pairs'] ?? json['pairs'];
    if (pairsData is List && pairsData.isNotEmpty) {
      pairs = pairsData.cast<Map<String, dynamic>>();
    }

    // Parse distractors (for matching)
    List<Map<String, dynamic>>? distractors;
    final distractorsData = question['distractors'] ?? json['distractors'];
    if (distractorsData is List && distractorsData.isNotEmpty) {
      distractors = distractorsData.cast<Map<String, dynamic>>();
    }

    // Parse expected_answer and ai_grading_keywords (for essay/short_answer)
    String? expectedAnswer;
    List<Map<String, dynamic>>? aiGradingKeywords;
    final expectedAnswerData = question['expected_answer'] ?? json['expected_answer'];
    if (expectedAnswerData is String) {
      expectedAnswer = expectedAnswerData;
    }
    final aiKeywordsData = question['ai_grading_keywords'] ?? json['ai_grading_keywords'];
    if (aiKeywordsData is List && aiKeywordsData.isNotEmpty) {
      aiGradingKeywords = aiKeywordsData.cast<Map<String, dynamic>>();
    }

    // Parse rubric (for essay/short_answer)
    Map<String, dynamic>? rubric;
    final rubricData = question['rubric'] ?? json['rubric'];
    if (rubricData is Map<String, dynamic>) {
      rubric = rubricData;
    }

    return QuestionState(
      id: question['id'] as String? ?? json['id'] as String? ?? '',
      content: contentStr,
      type: question['type'] as String? ?? json['type'] as String? ?? 'multiple_choice',
      points: (question['points'] as num?)?.toDouble() ?? (json['points'] as num?)?.toDouble() ?? 1.0,
      choices: choicesList
          .asMap()
          .entries
          .map((e) => QuestionChoiceState.fromJson(e.value is Map<String, dynamic> ? e.value : {}, index: e.key))
          .toList(),
      blanks: blanks,
      pairs: pairs,
      distractors: distractors,
      expectedAnswer: expectedAnswer,
      aiGradingKeywords: aiGradingKeywords,
      rubric: rubric,
    );
  }
}

/// State cho một lựa chọn trong câu hỏi trắc nghiệm
class QuestionChoiceState {
  final int id; // int: 0, 1, 2... (matching question_choices.id)
  final String content;
  final bool isCorrect;

  const QuestionChoiceState({
    required this.id,
    required this.content,
    required this.isCorrect,
  });

  QuestionChoiceState copyWith({int? id, String? content, bool? isCorrect}) =>
      QuestionChoiceState(
        id: id ?? this.id,
        content: content ?? this.content,
        isCorrect: isCorrect ?? this.isCorrect,
      );

  factory QuestionChoiceState.fromJson(Map<String, dynamic> json, {int? index}) {
    // Handle content - could be String or Map with 'text'
    String contentStr = '';
    dynamic contentData = json['content'];
    if (contentData is String) {
      contentStr = contentData;
    } else if (contentData is Map) {
      contentStr = contentData['text'] as String? ?? '';
    }

    // Parse ID - could be int or String, default to index if not present
    int id = index ?? 0;
    final idValue = json['id'];
    if (idValue is int) {
      id = idValue;
    } else if (idValue is String && idValue.isNotEmpty) {
      id = int.tryParse(idValue) ?? index ?? 0;
    }

    // Handle isCorrect - support both 'isCorrect' and 'is_correct'
    bool isCorrect = json['isCorrect'] as bool? ?? json['is_correct'] as bool? ?? false;

    return QuestionChoiceState(
      id: id,
      content: contentStr,
      isCorrect: isCorrect,
    );
  }
}

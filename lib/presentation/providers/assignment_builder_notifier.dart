import 'dart:async';

import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:ai_mls/domain/usecases/assignment_usecases.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assignment_builder_notifier.g.dart';

/// State cho Assignment Builder.
class AssignmentBuilderState {
  final Assignment? draft;
  final List<AssignmentQuestion> questions;
  final List<AssignmentDistribution> distributions;
  final bool isDirty;
  final bool isSaving;
  final bool isPublishing;
  final String? errorMessage;

  const AssignmentBuilderState({
    required this.draft,
    required this.questions,
    required this.distributions,
    required this.isDirty,
    required this.isSaving,
    required this.isPublishing,
    required this.errorMessage,
  });

  factory AssignmentBuilderState.initial() => const AssignmentBuilderState(
        draft: null,
        questions: <AssignmentQuestion>[],
        distributions: <AssignmentDistribution>[],
        isDirty: false,
        isSaving: false,
        isPublishing: false,
        errorMessage: null,
      );

  AssignmentBuilderState copyWith({
    Assignment? draft,
    List<AssignmentQuestion>? questions,
    List<AssignmentDistribution>? distributions,
    bool? isDirty,
    bool? isSaving,
    bool? isPublishing,
    String? errorMessage,
  }) {
    return AssignmentBuilderState(
      draft: draft ?? this.draft,
      questions: questions ?? this.questions,
      distributions: distributions ?? this.distributions,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      isPublishing: isPublishing ?? this.isPublishing,
      errorMessage: errorMessage,
    );
  }
}

/// AsyncNotifier quản lý flow tạo/sửa assignment.
@riverpod
class AssignmentBuilderNotifier extends _$AssignmentBuilderNotifier {
  late final AssignmentRepository _assignmentRepository;
  late final CreateAssignmentDraftUseCase _createDraftUseCase;
  late final UpdateAssignmentMetaUseCase _updateMetaUseCase;
  late final SaveAssignmentDraftUseCase _saveDraftUseCase;
  late final PublishAssignmentUseCase _publishUseCase;

  Timer? _autosaveTimer;

  @override
  Future<AssignmentBuilderState> build() async {
    _assignmentRepository = ref.read(assignmentRepositoryProvider);
    _createDraftUseCase = CreateAssignmentDraftUseCase(_assignmentRepository);
    _updateMetaUseCase = const UpdateAssignmentMetaUseCase();
    _saveDraftUseCase = SaveAssignmentDraftUseCase(_assignmentRepository);
    _publishUseCase = PublishAssignmentUseCase(_assignmentRepository);

    return AssignmentBuilderState.initial();
  }

  /// Khởi tạo assignment draft mới cho một class.
  Future<void> initNew({
    required String classId,
    required String teacherId,
  }) async {
    final current = state.value ?? AssignmentBuilderState.initial();
    if (current.draft != null) return;

    state = AsyncValue.data(
      current.copyWith(isSaving: true, errorMessage: null),
    );

    try {
      final payload = <String, dynamic>{
        'class_id': classId,
        'teacher_id': teacherId,
        'title': 'Bài tập mới',
        'is_published': false,
      };

      final draft = await _createDraftUseCase(payload);
      state = AsyncValue.data(
        AssignmentBuilderState.initial().copyWith(
          draft: draft,
          isSaving: false,
          isDirty: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật metadata trên local state và đánh dấu isDirty.
  void updateMeta(Map<String, dynamic> meta) {
    final current = state.value ?? AssignmentBuilderState.initial();
    final draft = current.draft;
    if (draft == null) return;

    final updated = _updateMetaUseCase(draft, meta);
    final newState = current.copyWith(
      draft: updated,
      isDirty: true,
      errorMessage: null,
    );
    state = AsyncValue.data(newState);

    _scheduleAutosave();
  }

  /// Thêm câu hỏi từ bank (tạm thời chỉ giữ local, chưa sync xuống DB).
  void addQuestionFromBank(AssignmentQuestion question) {
    final current = state.value ?? AssignmentBuilderState.initial();
    final updated = current.copyWith(
      questions: <AssignmentQuestion>[...current.questions, question],
      isDirty: true,
    );
    state = AsyncValue.data(updated);
    _scheduleAutosave();
  }

  /// Cập nhật distributions (UI chọn class/group/individual).
  void setDistributions(List<AssignmentDistribution> distributions) {
    final current = state.value ?? AssignmentBuilderState.initial();
    state = AsyncValue.data(
      current.copyWith(distributions: distributions, isDirty: true),
    );
    _scheduleAutosave();
  }

  void removeQuestion(String assignmentQuestionId) {
    final current = state.value ?? AssignmentBuilderState.initial();
    final updatedQuestions = current.questions
        .where((q) => q.id != assignmentQuestionId)
        .toList();
    final updated = current.copyWith(
      questions: updatedQuestions,
      isDirty: true,
    );
    state = AsyncValue.data(updated);
    _scheduleAutosave();
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    final current = state.value ?? AssignmentBuilderState.initial();
    final list = [...current.questions];
    if (oldIndex < 0 ||
        oldIndex >= list.length ||
        newIndex < 0 ||
        newIndex >= list.length) {
      return;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final updated = current.copyWith(
      questions: list,
      isDirty: true,
    );
    state = AsyncValue.data(updated);
    _scheduleAutosave();
  }

  /// Autosave draft (hiện tại chỉ là placeholder để dễ mở rộng).
  Future<void> saveDraft() async {
    final current = state.value ?? AssignmentBuilderState.initial();
    if (!current.isDirty || current.draft == null) return;

    state = AsyncValue.data(current.copyWith(isSaving: true, errorMessage: null));
    try {
      final saved = await _saveDraftUseCase(
        draft: current.draft!,
        questions: current.questions,
        distributions: current.distributions,
      );
      state = AsyncValue.data(
        current.copyWith(
          draft: saved,
          isDirty: false,
          isSaving: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        current.copyWith(
          isSaving: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Publish assignment (placeholder – sau này sẽ tạo distributions).
  Future<void> publish() async {
    final current = state.value ?? AssignmentBuilderState.initial();
    final draft = current.draft;
    if (draft == null) return;

    state = AsyncValue.data(
      current.copyWith(isPublishing: true, errorMessage: null),
    );

    try {
      final published = await _publishUseCase(
        draft: draft,
        questions: current.questions,
        distributions: current.distributions,
      );
      state = AsyncValue.data(
        current.copyWith(
          draft: published,
          isPublishing: false,
          isDirty: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    EasyDebounce.debounce(
      'assignment_builder_autosave',
      const Duration(seconds: 2),
      () async {
        await saveDraft();
      },
    );
  }
}


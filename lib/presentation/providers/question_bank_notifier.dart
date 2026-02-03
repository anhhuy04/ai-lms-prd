import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_bank_notifier.g.dart';

/// State cho Question Bank.
class QuestionBankState {
  final List<Question> questions;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final QuestionType? filterType;
  final int? filterDifficulty;
  final List<String> filterTags;
  final bool isSearching;

  const QuestionBankState({
    required this.questions,
    required this.isLoading,
    required this.hasMore,
    required this.page,
    required this.filterType,
    required this.filterDifficulty,
    required this.filterTags,
    required this.isSearching,
  });

  factory QuestionBankState.initial() => const QuestionBankState(
    questions: <Question>[],
    isLoading: false,
    hasMore: true,
    page: 0,
    filterType: null,
    filterDifficulty: null,
    filterTags: <String>[],
    isSearching: false,
  );

  QuestionBankState copyWith({
    List<Question>? questions,
    bool? isLoading,
    bool? hasMore,
    int? page,
    QuestionType? filterType,
    int? filterDifficulty,
    List<String>? filterTags,
    bool? isSearching,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      filterType: filterType ?? this.filterType,
      filterDifficulty: filterDifficulty ?? this.filterDifficulty,
      filterTags: filterTags ?? this.filterTags,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// AsyncNotifier quản lý Question Bank.
@riverpod
class QuestionBankNotifier extends _$QuestionBankNotifier {
  late final QuestionRepository _questionRepository;
  late final CreateQuestionUseCase _createQuestionUseCase;
  late final GetQuestionBankUseCase _getQuestionBankUseCase;

  @override
  Future<QuestionBankState> build() async {
    _questionRepository = ref.read(questionRepositoryProvider);
    _createQuestionUseCase = CreateQuestionUseCase(_questionRepository);
    _getQuestionBankUseCase = GetQuestionBankUseCase(_questionRepository);

    // Load initial data.
    return _loadInitialInternal();
  }

  Future<QuestionBankState> _loadInitialInternal() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return QuestionBankState.initial();
    }

    final params = GetQuestionBankParams(
      authorId: userId,
      type: state.value?.filterType,
      difficulty: state.value?.filterDifficulty,
      tags: state.value?.filterTags,
      page: 0,
      pageSize: 20,
    );

    final questions = await _getQuestionBankUseCase(params);
    return QuestionBankState.initial().copyWith(
      questions: questions,
      hasMore: questions.length == params.pageSize,
      page: 0,
    );
  }

  /// Public API: reload toàn bộ Question Bank với filter hiện tại.
  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadInitialInternal);
  }

  /// Tải thêm (paging) dựa trên filter hiện tại.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final nextPage = current.page + 1;

    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final params = GetQuestionBankParams(
        authorId: userId,
        type: current.filterType,
        difficulty: current.filterDifficulty,
        tags: current.filterTags,
        page: nextPage,
        pageSize: 20,
      );
      final nextItems = await _getQuestionBankUseCase(params);

      state = AsyncValue.data(
        current.copyWith(
          isLoading: false,
          page: nextPage,
          hasMore: nextItems.length == params.pageSize,
          questions: <Question>[...current.questions, ...nextItems],
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Áp dụng filter và reload (debounced).
  void applyFilter({QuestionType? type, int? difficulty, List<String>? tags}) {
    final current = state.value ?? QuestionBankState.initial();

    final newState = current.copyWith(
      filterType: type ?? current.filterType,
      filterDifficulty: difficulty ?? current.filterDifficulty,
      filterTags: tags ?? current.filterTags,
      isSearching: true,
    );

    state = AsyncValue.data(newState);

    EasyDebounce.debounce(
      'question_bank_filter',
      const Duration(milliseconds: 400),
      () async {
        await loadInitial();
      },
    );
  }

  /// Tạo câu hỏi mới rồi refresh bank.
  Future<void> createQuestion(CreateQuestionParams params) async {
    try {
      await _createQuestionUseCase(params);
      await loadInitial();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh thủ công.
  Future<void> refresh() => loadInitial();
}

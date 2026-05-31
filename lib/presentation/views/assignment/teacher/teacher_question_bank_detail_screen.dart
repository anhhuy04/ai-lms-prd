import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/learning_objective.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/providers/question_stats_provider.dart';
import 'package:ai_mls/presentation/providers/question_usage_provider.dart';
import 'package:ai_mls/widgets/dialogs/question_delete_confirm_dialog.dart';
import 'package:ai_mls/widgets/editor/rich_text_toolbar.dart';
import 'package:ai_mls/widgets/objective_selector/objective_selector_sheet.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_question_bank_detail_screen.g.dart';

@riverpod
Future<QuestionDetail?> _questionDetail(Ref ref, String id) {
  final repo = ref.watch(questionRepositoryProvider);
  return GetQuestionDetailUseCase(repo).call(id);
}

class TeacherQuestionBankDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const TeacherQuestionBankDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<TeacherQuestionBankDetailScreen> createState() =>
      _TeacherQuestionBankDetailScreenState();
}

/// Breakpoint để chuyển sang layout 3 cột (Stats | Preview/Edit | Usage).
/// Dưới ngưỡng này: dùng TabBar 3 tab như cũ.
const double _threeColumnBreakpoint = 1280;

class _TeacherQuestionBankDetailScreenState
    extends ConsumerState<TeacherQuestionBankDetailScreen> {
  bool _isEditing = false;

  void _enterEdit() => setState(() => _isEditing = true);
  void _exitEdit() => setState(() => _isEditing = false);

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_questionDetailProvider(widget.questionId));
    return LayoutBuilder(
      builder: (context, constraints) {
        final useThreeColumns =
            constraints.maxWidth >= _threeColumnBreakpoint;
        if (useThreeColumns) {
          // Sides clamp 280-380, center luôn lấy phần còn lại → màn càng to
          // center càng rộng, sides không phình theo.
          final sideWidth =
              (constraints.maxWidth * 0.22).clamp(280.0, 380.0);
          return _buildThreeColumnLayout(context, detailAsync, sideWidth);
        }
        return _buildTabLayout(context, detailAsync);
      },
    );
  }

  // ── Layout 3 cột cho màn rộng (desktop / web) ───────────────────────────

  Widget _buildThreeColumnLayout(
    BuildContext context,
    AsyncValue<QuestionDetail?> detailAsync,
    double sideWidth,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa câu hỏi' : 'Chi tiết câu hỏi'),
      ),
      body: detailAsync.when(
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Không tìm thấy câu hỏi.'));
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cột trái: Thống kê (fixed width)
              SizedBox(
                width: sideWidth,
                child: _SidePanelWrapper(
                  title: 'Thống kê',
                  icon: Icons.bar_chart_rounded,
                  accent: Colors.deepPurple,
                  isDark: isDark,
                  child: _StatsTab(
                    questionId: widget.questionId,
                    question: detail.question,
                  ),
                ),
              ),
              _columnDivider(isDark),
              // Cột giữa: Preview / Edit — Expanded để chiếm phần còn lại
              Expanded(
                child: _PreviewEditTab(
                  detail: detail,
                  isEditing: _isEditing,
                  onSaved: _exitEdit,
                  onCancel: _exitEdit,
                  isInThreeColumns: true,
                ),
              ),
              _columnDivider(isDark),
              // Cột phải: Lịch sử dùng (fixed width)
              SizedBox(
                width: sideWidth,
                child: _SidePanelWrapper(
                  title: 'Lịch sử dùng',
                  icon: Icons.history_rounded,
                  accent: DesignColors.warning,
                  isDark: isDark,
                  child: _UsageTab(questionId: widget.questionId),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
      bottomNavigationBar: _isEditing
          ? null
          : detailAsync.maybeWhen(
              data: (detail) => detail == null
                  ? null
                  : _ActionBar(
                      question: detail.question,
                      onEdit: _enterEdit,
                    ),
              orElse: () => null,
            ),
    );
  }

  Widget _columnDivider(bool isDark) => VerticalDivider(
        width: 1,
        thickness: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      );

  // ── Layout TabBar (mobile / tablet hẹp) — giữ nguyên hành vi cũ ─────────

  Widget _buildTabLayout(
    BuildContext context,
    AsyncValue<QuestionDetail?> detailAsync,
  ) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Chỉnh sửa câu hỏi' : 'Chi tiết câu hỏi'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Xem trước'),
              Tab(text: 'Thống kê'),
              Tab(text: 'Lịch sử dùng'),
            ],
            onTap: (_) {
              // Rời tab Xem trước khi đang edit → exit edit để tránh state lệch.
              if (_isEditing) _exitEdit();
            },
          ),
        ),
        body: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return const Center(child: Text('Không tìm thấy câu hỏi.'));
            }
            return TabBarView(
              physics: _isEditing
                  ? const NeverScrollableScrollPhysics()
                  : null,
              children: [
                _PreviewEditTab(
                  detail: detail,
                  isEditing: _isEditing,
                  onSaved: _exitEdit,
                  onCancel: _exitEdit,
                ),
                _StatsTab(
                  questionId: widget.questionId,
                  question: detail.question,
                ),
                _UsageTab(questionId: widget.questionId),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
        ),
        bottomNavigationBar: _isEditing
            ? null
            : detailAsync.maybeWhen(
                data: (detail) => detail == null
                    ? null
                    : _ActionBar(
                        question: detail.question,
                        onEdit: _enterEdit,
                      ),
                orElse: () => null,
              ),
      ),
    );
  }
}

/// Wrapper cho 2 cột phụ (Stats/Usage) trong 3-column layout — thêm header
/// chứa icon + tiêu đề để tách biệt rõ với cột giữa.
class _SidePanelWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final bool isDark;
  final Widget child;

  const _SidePanelWrapper({
    required this.title,
    required this.icon,
    required this.accent,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _columnHeaderHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.06),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: DesignTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Chiều cao chung của header cho cả 3 cột — đảm bảo content bên trong
/// align cùng baseline ở cả read/edit mode.
const double _columnHeaderHeight = 56;

// ────────────────────────────────────────────────────────────────────────────
// Preview + Edit tab. Cả 2 mode dùng chung _buildEditMode, readonly khi
// !isEditing → ẩn/disable tất cả input và button qua _isReadOnly getter.
// ────────────────────────────────────────────────────────────────────────────

class _PreviewEditTab extends ConsumerStatefulWidget {
  final QuestionDetail detail;
  final bool isEditing;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  /// Khi true → đang ở layout 3 cột. Ẩn nội bộ TabBar/Split (Sửa|Xem trước)
  /// vì người dùng đã thấy đầy đủ stats/usage ở 2 bên; center column chỉ cần
  /// hiển thị form (edit hoặc readonly) trực tiếp.
  final bool isInThreeColumns;

  const _PreviewEditTab({
    required this.detail,
    required this.isEditing,
    required this.onSaved,
    required this.onCancel,
    this.isInThreeColumns = false,
  });

  @override
  ConsumerState<_PreviewEditTab> createState() => _PreviewEditTabState();
}

class _PreviewEditTabState extends ConsumerState<_PreviewEditTab> {
  // ── Controllers ─────────────────────────────────────────────────────────
  late TextEditingController _textCtrl;
  late TextEditingController _expectedAnswerCtrl;
  late TextEditingController _explanationCtrl;
  late TextEditingController _tagInputCtrl;
  late List<TextEditingController> _choiceControllers;
  late List<bool> _choiceCorrect;
  int _correctIndex = 0;
  late List<TextEditingController> _hintControllers;

  // ── State ───────────────────────────────────────────────────────────────
  int? _difficulty;
  List<String> _tags = [];
  List<String> _learningObjectiveIds = [];
  List<LearningObjective> _selectedObjectives = [];
  bool _objectivesLoading = false;
  bool _isSaving = false;

  /// Toggle hiển thị LaTeX render bên cạnh các field nội dung + đáp án.
  /// OFF (default): chỉ TextField raw. ON: Row [TextField | MathText].
  bool _latexSideBySide = false;

  Question get _question => widget.detail.question;
  QuestionType get _questionType => _question.type;
  bool get _isChoiceType =>
      _questionType == QuestionType.multipleChoice ||
      _questionType == QuestionType.trueFalse ||
      _questionType == QuestionType.math;

  /// Convenience: khi !isEditing → tất cả input/button trong form bị khoá.
  bool get _isReadOnly => !widget.isEditing;

  @override
  void initState() {
    super.initState();
    _hydrateFromDetail();
  }

  @override
  void didUpdateWidget(_PreviewEditTab old) {
    super.didUpdateWidget(old);
    if (old.detail != widget.detail) {
      _disposeControllers();
      _hydrateFromDetail();
    }
  }

  void _hydrateFromDetail() {
    final q = _question;
    final text = _extractText(q.content);
    _textCtrl = TextEditingController(text: text);

    final sortedChoices = [...widget.detail.choices]
      ..sort((a, b) => a.id.compareTo(b.id));
    _choiceControllers = sortedChoices
        .map((c) => TextEditingController(
              text: (c.content['text'] as String?) ?? '',
            ))
        .toList();
    _choiceCorrect = sortedChoices.map((c) => c.isCorrect).toList();
    _correctIndex = _choiceCorrect.indexWhere((c) => c);
    if (_correctIndex < 0) _correctIndex = 0;

    final ans = q.answer;
    final ea =
        (ans != null) ? (ans['expected_answer'] as String? ?? '') : '';
    _expectedAnswerCtrl = TextEditingController(text: ea);

    final topExpl = (q.content['explanation'] as String?)?.trim();
    final ansExpl =
        (ans != null) ? (ans['general_explanation'] as String?)?.trim() : null;
    final initialExpl =
        (topExpl != null && topExpl.isNotEmpty) ? topExpl : (ansExpl ?? '');
    _explanationCtrl = TextEditingController(text: initialExpl);

    _difficulty = q.difficulty;
    _tags = List<String>.from(q.tags);
    _tagInputCtrl = TextEditingController();

    final hintsList = (q.content['hints'] as List?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    _hintControllers =
        hintsList.map((h) => TextEditingController(text: h)).toList();

    _learningObjectiveIds = List<String>.from(widget.detail.objectiveIds);
    _selectedObjectives = [];
    if (_learningObjectiveIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadObjectives());
    }
  }

  Future<void> _loadObjectives() async {
    if (_objectivesLoading || !mounted) return;
    setState(() => _objectivesLoading = true);
    try {
      final repo = ref.read(learningObjectiveRepositoryProvider);
      final all = await repo.getObjectives();
      final loaded =
          all.where((o) => _learningObjectiveIds.contains(o.id)).toList();
      if (mounted) setState(() => _selectedObjectives = loaded);
    } catch (_) {
      // Bỏ qua — chips sẽ chỉ hiện id nếu load lỗi.
    } finally {
      if (mounted) setState(() => _objectivesLoading = false);
    }
  }

  Future<void> _openObjectiveSelector() async {
    final selected = await ObjectiveSelectorSheet.show(
      context,
      selectedIds: _learningObjectiveIds,
      allowCreate: true,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedObjectives = selected;
      _learningObjectiveIds = selected.map((o) => o.id).toList();
    });
  }

  void _addTag() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagInputCtrl.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addHint() {
    setState(() => _hintControllers.add(TextEditingController()));
  }

  void _removeHint(int index) {
    setState(() {
      _hintControllers[index].dispose();
      _hintControllers.removeAt(index);
    });
  }

  void _disposeControllers() {
    _textCtrl.dispose();
    _expectedAnswerCtrl.dispose();
    _explanationCtrl.dispose();
    _tagInputCtrl.dispose();
    for (final c in _choiceControllers) {
      c.dispose();
    }
    for (final c in _hintControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final params = _buildParams();
      final repo = ref.read(questionRepositoryProvider);
      await repo.updateQuestion(_question.id, params);
      ref.invalidate(_questionDetailProvider(_question.id));
      if (!mounted) return;
      AppToast.info(context, 'Đã lưu thay đổi');
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Lỗi lưu: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  CreateQuestionParams _buildParams() {
    final text = _textCtrl.text.trim();
    final explanation = _explanationCtrl.text.trim();
    final hints = _hintControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final content = <String, dynamic>{
      'override_text': text,
      if (explanation.isNotEmpty) 'explanation': explanation,
      if (hints.isNotEmpty) 'hints': hints,
    };

    Map<String, dynamic>? answer;
    List<Map<String, dynamic>>? choices;

    if (_isChoiceType && _choiceControllers.isNotEmpty) {
      choices = List<Map<String, dynamic>>.generate(
        _choiceControllers.length,
        (i) => <String, dynamic>{
          'id': i,
          'text': _choiceControllers[i].text.trim(),
          'isCorrect': i == _correctIndex,
        },
      );
      final correctIds = <int>[
        for (final c in choices)
          if (c['isCorrect'] == true) c['id'] as int,
      ];
      answer = <String, dynamic>{'correct_choice_ids': correctIds};
    } else {
      final ea = _expectedAnswerCtrl.text.trim();
      answer = <String, dynamic>{
        if (ea.isNotEmpty) 'expected_answer': ea,
        if (explanation.isNotEmpty) 'general_explanation': explanation,
      };
    }

    return CreateQuestionParams(
      type: _questionType,
      content: content,
      source: QuestionSource.values.firstWhere(
        (s) => s.dbValue == _question.source,
        orElse: () => QuestionSource.teacher,
      ),
      answer: answer,
      difficulty: _difficulty,
      tags: List<String>.from(_tags),
      objectiveIds: List<String>.from(_learningObjectiveIds),
      choices: choices ?? const <Map<String, dynamic>>[],
      isGlobal: _question.isGlobal,
      defaultPoints: 1.0,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Cả 2 mode dùng chung _buildEditMode — readonly auto disable input/buttons
    // qua _isReadOnly getter.
    return _buildEditMode(context);
  }

  Widget _buildEditMode(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildEditModeInner(context, constraints.maxWidth);
      },
    );
  }

  Widget _buildEditModeInner(BuildContext context, double availableWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Toggle LaTeX side-by-side chỉ enable khi đủ rộng cho 2 cột inline
    // (640px). Dưới ngưỡng → button bị disable, force về single column.
    final canSplitInline = availableWidth >= 640;
    final typeColor = _questionType.color;

    return Column(
      children: [
        // Header — title + type chip + toggle LaTeX. 56px đồng đều với side panels.
        SizedBox(
          height: _columnHeaderHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: isDark ? 0.15 : 0.07),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Icon(
                    _isReadOnly
                        ? Icons.visibility_rounded
                        : Icons.edit_rounded,
                    size: 16,
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _isReadOnly
                      ? 'Xem trước câu hỏi'
                      : 'Chỉnh sửa câu hỏi',
                  overflow: TextOverflow.ellipsis,
                  style: DesignTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : DesignColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                // Type chip cùng hàng với title.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    _questionType.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
                // Expanded SizedBox.shrink để dồn toàn bộ phần trống đẩy
                // toggle về extreme right (không chia đôi với title).
                const Expanded(child: SizedBox.shrink()),
                // Toggle LaTeX side-by-side — đặt ở cuối row (right edge).
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: canSplitInline
                      ? () => setState(
                            () => _latexSideBySide = !_latexSideBySide,
                          )
                      : null,
                  icon: Icon(
                    _latexSideBySide
                        ? Icons.view_agenda_rounded
                        : Icons.view_column_rounded,
                    color: canSplitInline
                        ? DesignColors.primary
                        : (isDark ? Colors.grey[700] : Colors.grey[400]),
                    size: 18,
                  ),
                  tooltip: !canSplitInline
                      ? 'Cần màn rộng hơn để xem LaTeX song song'
                      : _latexSideBySide
                          ? 'Tắt xem LaTeX song song'
                          : 'Hiển thị LaTeX song song với nội dung + đáp án',
                ),
              ],
            ),
          ),
        ),
        // Body — single column. Inline LaTeX preview áp dụng riêng cho field
        // nội dung + đáp án bên trong _buildEditTabContent (xem các method
        // _buildContentField / _buildChoiceEditTile / _buildExpectedAnswerField).
        Expanded(child: _buildEditTabContent(isDark)),
          // Footer: Hủy + Lưu thay đổi (CHỈ hiện khi đang edit).
          if (!_isReadOnly)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1923) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg * 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: DesignTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 4,
                          shadowColor:
                              DesignColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg * 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.save_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                              style: DesignTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  // ── Edit panel ─────────────────────────────────────────────────────────

  Widget _buildEditTabContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cụm Nội dung + Đáp án — khi toggle LaTeX ON: 2 card cùng chiều
          // cao dynamic qua IntrinsicHeight. Bên này dài, bên kia tự dãn.
          if (_latexSideBySide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _latexCard(
                      label: 'NHẬP',
                      icon: Icons.edit_note_rounded,
                      accent: DesignColors.primary,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _contentEditorBlock(isDark),
                          const SizedBox(height: 20),
                          _answerEditorBlock(isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _latexCard(
                      label: 'XEM TRƯỚC LATEX',
                      icon: Icons.functions_rounded,
                      accent: DesignColors.info,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _contentPreviewBlock(isDark),
                          const SizedBox(height: 20),
                          _answerPreviewBlock(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _contentEditorBlock(isDark),
            const SizedBox(height: 20),
            _answerEditorBlock(isDark),
          ],
          const SizedBox(height: 20),
          _buildDifficultySection(isDark),
          const SizedBox(height: 20),
          _buildTagsSection(isDark),
          const SizedBox(height: 20),
          _buildObjectivesSection(isDark),
          const SizedBox(height: 20),
          _buildExplanationSection(isDark),
          const SizedBox(height: 20),
          _buildHintsSection(isDark),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Editor / Preview blocks cho cụm Nội dung + Đáp án ──────────────────

  Widget _contentEditorBlock(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.help_outline_rounded,
          label: 'NỘI DUNG CÂU HỎI',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        if (!_isReadOnly) ...[
          Text(
            'Chèn công thức:',
            style: DesignTypography.labelSmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          RichTextToolbar(controller: _textCtrl),
          const SizedBox(height: 10),
        ],
        _buildTextField(
          controller: _textCtrl,
          hintText: 'Nhập nội dung câu hỏi...',
          minLines: 4,
          maxLines: null, // auto-grow theo content
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _contentPreviewBlock(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.help_outline_rounded,
          label: 'NỘI DUNG CÂU HỎI',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        // minHeight 116 ≈ TextField(maxLines:4) — đồng bộ với editor.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: _latexPreviewContent(
            _textCtrl,
            isDark,
            emptyHint: '(chưa có nội dung)',
          ),
        ),
      ],
    );
  }

  Widget _answerEditorBlock(bool isDark) {
    if (_isChoiceType && _choiceControllers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionLabel(
                icon: Icons.radio_button_checked_rounded,
                label: 'CÁC ĐÁP ÁN',
                isDark: isDark,
              ),
              const Spacer(),
              if (!_isReadOnly)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                    border: Border.all(
                      color: DesignColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Tap ✓ để chọn đúng',
                    style: TextStyle(
                      fontSize: 11,
                      color: DesignColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_choiceControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildChoiceEditTile(i, isDark),
            );
          }),
        ],
      );
    }
    // Non-choice → đáp án mẫu
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.task_alt_rounded,
          label: 'ĐÁP ÁN MẪU',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        if (!_isReadOnly) ...[
          RichTextToolbar(controller: _expectedAnswerCtrl),
          const SizedBox(height: 8),
        ],
        _buildTextField(
          controller: _expectedAnswerCtrl,
          hintText: 'Nhập đáp án mẫu...',
          minLines: 4,
          maxLines: null, // auto-grow theo content
          isDark: isDark,
          fillColor: DesignColors.success.withValues(alpha: 0.05),
          borderColor: DesignColors.success.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _answerPreviewBlock(bool isDark) {
    if (_isChoiceType && _choiceControllers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            icon: Icons.radio_button_checked_rounded,
            label: 'CÁC ĐÁP ÁN',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ...List.generate(_choiceControllers.length, (i) {
            return _buildChoicePreviewRow(i, isDark);
          }),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.task_alt_rounded,
          label: 'ĐÁP ÁN MẪU',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DesignColors.success.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
            border: Border.all(
              color: DesignColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: _latexPreviewContent(
            _expectedAnswerCtrl,
            isDark,
            emptyHint: '(chưa có đáp án)',
          ),
        ),
      ],
    );
  }

  Widget _buildChoicePreviewRow(int i, bool isDark) {
    final isCorrect = i == _correctIndex;
    final label = String.fromCharCode(65 + i);
    // minHeight 50 ≈ choice edit tile height (TextField padding all(14) + 1 line).
    // padding tight (h:12, v:8) để tổng = max(50, 42) = 50 — bằng editor tile.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCorrect
              ? DesignColors.success
                  .withValues(alpha: isDark ? 0.12 : 0.07)
              : (isDark ? Colors.grey[850] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          border: Border.all(
            color: isCorrect
                ? DesignColors.success
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isCorrect ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCorrect
                    ? DesignColors.success
                    : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Inline MathText (skip _latexPreviewContent vì nó có minHeight
            // 40 sẽ độn row cao hơn editor tile).
            Expanded(
              child: ListenableBuilder(
                listenable: _choiceControllers[i],
                builder: (context, _) {
                  final text = _choiceControllers[i].text;
                  final empty = text.trim().isEmpty;
                  return MathText(
                    empty ? '(trống)' : text,
                    style: DesignTypography.bodyMedium.copyWith(
                      color: empty
                          ? (isDark ? Colors.grey[600] : Colors.grey[400])
                          : (isCorrect
                              ? DesignColors.success
                              : (isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary)),
                      fontWeight: isCorrect
                          ? FontWeight.w600
                          : FontWeight.w500,
                      height: 1.4,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceEditTile(int i, bool isDark) {
    final isCorrect = i == _correctIndex;
    final label = String.fromCharCode(65 + i);
    return GestureDetector(
      onTap: _isReadOnly
          ? null
          : () => setState(() => _correctIndex = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isCorrect
                ? DesignColors.success
                    .withValues(alpha: isDark ? 0.12 : 0.07)
                : (isDark ? const Color(0xFF1A2632) : Colors.grey[50]),
            borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
            border: Border.all(
              color: isCorrect
                  ? DesignColors.success
                  : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
              width: isCorrect ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isCorrect
                      ? DesignColors.success
                      : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? DesignColors.success
                      : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _choiceControllers[i],
                  readOnly: _isReadOnly,
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                    fontWeight:
                        isCorrect ? FontWeight.w600 : FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Đáp án $label...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (!_isReadOnly) ...[
                IconButton(
                  icon: const Icon(Icons.functions, size: 18),
                  color: DesignColors.primary,
                  tooltip: 'Chèn ký tự toán học',
                  onPressed: () => RichTextToolbar.showMathPickerFor(
                    context,
                    _choiceControllers[i],
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection(bool isDark) {
    const labels = ['Rất dễ', 'Dễ', 'Trung bình', 'Khó', 'Rất khó'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.bar_chart_rounded,
          label: 'ĐỘ KHÓ',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (i) {
              final level = i + 1;
              final isActive = _difficulty != null && _difficulty! >= level;
              return GestureDetector(
                onTap: _isReadOnly
                    ? null
                    : () => setState(() {
                          _difficulty = _difficulty == level ? null : level;
                        }),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 28,
                    color: isActive
                        ? Colors.amber[400]
                        : (isDark ? Colors.grey[600] : Colors.grey[300]),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              _difficulty != null ? labels[_difficulty! - 1] : 'Chưa chọn',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.local_offer_rounded,
          label: 'THẺ (TAGS)',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!_isReadOnly) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: DesignColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
        if (!_isReadOnly)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputCtrl,
                  onSubmitted: (_) => _addTag(),
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Thêm tag (vd: chương 1, lý thuyết)...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignRadius.lg * 1.2),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignRadius.lg * 1.2),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignRadius.lg * 1.2),
                      borderSide: BorderSide(
                        color: DesignColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTag,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignRadius.lg * 1.2),
                  ),
                ),
                child: const Text('Thêm'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildObjectivesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionLabel(
              icon: Icons.school_rounded,
              label: 'MỤC TIÊU HỌC TẬP',
              isDark: isDark,
            ),
            const Spacer(),
            if (!_isReadOnly)
              TextButton.icon(
                onPressed: _openObjectiveSelector,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Chọn'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_objectivesLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_selectedObjectives.isEmpty && _learningObjectiveIds.isEmpty)
          Text(
            _isReadOnly
                ? 'Chưa có mục tiêu nào.'
                : 'Chưa có mục tiêu nào. Bấm "Chọn" để thêm.',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          )
        else if (_selectedObjectives.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedObjectives.map((o) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                  border: Border.all(
                    color: DesignColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: DesignColors.info,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        o.description,
                        overflow: TextOverflow.ellipsis,
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        else
          Text(
            '${_learningObjectiveIds.length} mục tiêu (đang tải tên...)',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildExplanationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.lightbulb_outline_rounded,
          label: 'GỢI Ý / GIẢI THÍCH',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        if (!_isReadOnly) ...[
          RichTextToolbar(controller: _explanationCtrl),
          const SizedBox(height: 8),
        ],
        _buildTextField(
          controller: _explanationCtrl,
          hintText: 'Gợi ý cách làm hoặc giải thích đáp án...',
          maxLines: 3,
          isDark: isDark,
          fillColor: Colors.amber.withValues(alpha: 0.05),
          borderColor: Colors.amber.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildHintsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionLabel(
              icon: Icons.tips_and_updates_rounded,
              label: 'GỢI Ý THEO BẬC',
              isDark: isDark,
            ),
            const Spacer(),
            if (!_isReadOnly)
              TextButton.icon(
                onPressed: _addHint,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Thêm gợi ý'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_hintControllers.isEmpty)
          Text(
            'Chưa có gợi ý nào.',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...List.generate(_hintControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: DesignColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _hintControllers[i],
                      hintText: 'Gợi ý bậc ${i + 1}...',
                      maxLines: 2,
                      isDark: isDark,
                    ),
                  ),
                  if (!_isReadOnly)
                    IconButton(
                      onPressed: () => _removeHint(i),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: DesignColors.error,
                        size: 20,
                      ),
                      tooltip: 'Xoá',
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Inline LaTeX preview helpers ───────────────────────────────────────

  /// Render LaTeX preview (no border — card wrapper provides frame).
  /// Listens vào controller để auto-update khi user gõ.
  Widget _latexPreviewContent(
    TextEditingController controller,
    bool isDark, {
    String emptyHint = '(chưa có)',
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text;
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: MathText(
            text.trim().isEmpty ? emptyHint : text,
            style: DesignTypography.bodyMedium.copyWith(
              color: text.trim().isEmpty
                  ? (isDark ? Colors.grey[600] : Colors.grey[400])
                  : (isDark ? Colors.white : DesignColors.textPrimary),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  /// Card wrapper với label header nhỏ — tách 2 khối Soạn thảo / Xem trước
  /// thành 2 thẻ rõ rệt.
  Widget _latexCard({
    required String label,
    required IconData icon,
    required Color accent,
    required bool isDark,
    required Widget child,
  }) {
    final borderC = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F2A) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: borderC),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card header — accent-tinted, icon + label nhỏ.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
              border: Border(bottom: BorderSide(color: borderC)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 13, color: accent),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: DesignTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ],
      ),
    );
  }


  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: DesignColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, size: 14, color: DesignColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTypography.labelSmallSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int? maxLines,
    required bool isDark,
    int? minLines,
    Color? fillColor,
    Color? borderColor,
  }) {
    final bc = borderColor ?? (isDark ? Colors.grey[700]! : Colors.grey[200]!);
    final fc = fillColor ??
        (isDark
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[50]!);
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: _isReadOnly,
      style: DesignTypography.bodyMedium.copyWith(
        color: isDark ? Colors.white : DesignColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        filled: true,
        fillColor: fc,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: bc),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: bc),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: DesignColors.primary, width: 2),
        ),
      ),
    );
  }
}

String _extractText(Map<String, dynamic> content) {
  if (content['ops'] is List) {
    return (content['ops'] as List)
        .where((op) => op is Map && op['insert'] is String)
        .map((op) => (op as Map)['insert'] as String)
        .join();
  }
  if (content['text'] is String) return content['text'] as String;
  if (content['override_text'] is String) {
    return content['override_text'] as String;
  }
  return '';
}

// ────────────────────────────────────────────────────────────────────────────
// Stats / Usage tabs.
// ────────────────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  final String questionId;
  final Question? question;
  const _StatsTab({required this.questionId, this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(questionStatsProvider(questionId));
    return statsAsync.when(
      data: (stats) {
        final hasAttempts = stats.totalAttempts > 0;
        return ListView(
          padding: EdgeInsets.all(DesignSpacing.md),
          children: [
            _StatCard(
              label: 'Lượt làm',
              value: '${stats.totalAttempts}',
              icon: Icons.bar_chart_rounded,
            ),
            SizedBox(height: DesignSpacing.sm),
            _StatCard(
              label: 'Đúng',
              value: '${stats.correctCount}',
              icon: Icons.check_circle_rounded,
              color: DesignColors.success,
            ),
            SizedBox(height: DesignSpacing.sm),
            _StatCard(
              label: 'Tỉ lệ đúng',
              value: hasAttempts
                  ? '${(stats.correctRate * 100).toStringAsFixed(1)}%'
                  : '—',
              icon: Icons.percent_rounded,
              color: hasAttempts
                  ? (stats.correctRate >= 0.5
                      ? DesignColors.success
                      : DesignColors.warning)
                  : DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.sm),
            // Ngày tạo — luôn hiển thị (kể cả khi chưa có lượt làm).
            _StatCard(
              label: 'Ngày tạo',
              value: question?.createdAt == null
                  ? '—'
                  : _formatDate(question!.createdAt!),
              icon: Icons.event_rounded,
              color: Colors.deepPurple,
            ),
            SizedBox(height: DesignSpacing.sm),
            _StatCard(
              label: 'Cập nhật gần nhất',
              value: stats.lastAttempted == null
                  ? '—'
                  : _formatDate(stats.lastAttempted!),
              icon: Icons.update_rounded,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? DesignColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Icon(icon, color: c, size: 18),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                label,
                style: DesignTypography.bodySmall.copyWith(
                  color: isDark ? Colors.grey[300] : DesignColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Text(
              value,
              style: DesignTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageTab extends ConsumerWidget {
  final String questionId;
  const _UsageTab({required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(questionUsageProvider(questionId));
    return usageAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Text(
                    'Chưa có bài tập nào dùng câu hỏi này',
                    style: DesignTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(questionUsageProvider(questionId)),
          child: ListView.separated(
            padding: EdgeInsets.all(DesignSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: DesignSpacing.sm),
            itemBuilder: (_, i) => _UsageItemTile(item: items[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Text('Lỗi tải lịch sử: $e'),
        ),
      ),
    );
  }
}

class _UsageItemTile extends StatelessWidget {
  final QuestionUsageItem item;
  const _UsageItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        item.isPublished ? DesignColors.success : DesignColors.warning;
    final statusLabel = item.isPublished ? 'Đã phát hành' : 'Bản nháp';
    final dateLabel = item.publishedAt != null
        ? 'Phát hành ${_formatDate(item.publishedAt!)}'
        : item.createdAt != null
            ? 'Tạo ${_formatDate(item.createdAt!)}'
            : '';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          AppToast.info(context, 'Mở "${item.title}" — wire sau');
        },
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  item.isPublished
                      ? Icons.public
                      : Icons.edit_note_outlined,
                  color: color,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: DesignTypography.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    if (item.className != null && item.className!.isNotEmpty)
                      Text(
                        'Lớp: ${item.className}',
                        style: DesignTypography.bodySmall,
                      ),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Text(
                  statusLabel,
                  style: DesignTypography.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Action bar (Nhân bản + Sửa + Xóa). Hidden khi đang edit.
// ────────────────────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerStatefulWidget {
  final Question question;
  final VoidCallback onEdit;
  const _ActionBar({required this.question, required this.onEdit});

  @override
  ConsumerState<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends ConsumerState<_ActionBar> {
  bool _isPreparingReplicate = false;

  Question get question => widget.question;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1923) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Primary action: Sửa — prominent.
              FilledButton.icon(
                onPressed: widget.onEdit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(
                  'Sửa câu hỏi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              // Overflow menu — Nhân bản + Xóa (giấu bớt actions).
              _OverflowMenu(
                isDark: isDark,
                isPreparingReplicate: _isPreparingReplicate,
                onReplicate: () => _navigateToReplicate(context),
                onDelete: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToReplicate(BuildContext context) async {
    if (_isPreparingReplicate) return;
    setState(() => _isPreparingReplicate = true);
    try {
      final repo = ref.read(questionRepositoryProvider);
      final choices = await repo.getChoicesByQuestionId(question.id);
      // Fetch learning objectives của câu gốc để bản nhân bản giữ mục tiêu.
      final objectiveIds = await repo.getObjectiveIdsByQuestionId(question.id);

      final sortedChoices = [...choices]..sort((a, b) => a.id.compareTo(b.id));
      final optionsForForm = sortedChoices
          .map(
            (c) => <String, dynamic>{
              'text': c.content['text'] as String? ?? '',
              'isCorrect': c.isCorrect,
            },
          )
          .toList();

      final text = _extractText(question.content);
      final explanation = (question.content['explanation'] as String?) ??
          (question.answer?['explanation'] as String?) ??
          (question.answer?['general_explanation'] as String?) ??
          '';

      if (!context.mounted) return;
      context.pushNamed(
        AppRoute.teacherCreateQuestion,
        extra: <String, dynamic>{
          'questionType': question.type,
          'initialData': <String, dynamic>{
            'text': text,
            'explanation': explanation,
            'difficulty': question.difficulty,
            'tags': List<String>.from(question.tags),
            'options': optionsForForm,
            // Bản nhân bản giữ learning objectives của câu gốc.
            'learningObjectives': objectiveIds,
          },
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Lỗi mở nhân bản: $e');
    } finally {
      if (mounted) setState(() => _isPreparingReplicate = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    // Bước 1: check usage. Nếu câu hỏi đã link với bài tập nào → chỉ cho ẩn
    // (tránh phá dữ liệu bài tập đã giao/biên soạn). Nếu chưa link → cho xoá.
    final List<QuestionUsageItem> usage;
    try {
      usage = await ref.read(questionUsageProvider(question.id).future);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.error(context, 'Không kiểm tra được liên kết: $e');
      return;
    }
    if (!context.mounted) return;

    final isLinked = usage.isNotEmpty;
    final ok = await QuestionDeleteConfirmDialog.show(
      context,
      isLinked: isLinked,
      linkedCount: usage.length,
      firstAssignmentTitle: isLinked ? usage.first.title : null,
    );
    if (!ok || !context.mounted) return;

    try {
      // Cả 2 nhánh đều dùng softDelete (RLS migration 022 chặn hard DELETE).
      // Khác biệt UX: message khác — user hiểu hành động đã thực hiện.
      await ref
          .read(questionRepositoryProvider)
          .softDeleteQuestion(question.id);
      if (!context.mounted) return;
      /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.warning(context, isLinked
                ? 'Đã ẩn câu hỏi khỏi ngân hàng (giữ trong bài tập đã giao); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      AppToast.error(context, 'Lỗi: $e');
    }
  }
}

/// Overflow menu — giấu Nhân bản + Xóa sau icon `⋮` để bottom bar gọn,
/// vẫn dễ thao tác (1 tap mở menu).
class _OverflowMenu extends StatelessWidget {
  final bool isDark;
  final bool isPreparingReplicate;
  final VoidCallback onReplicate;
  final VoidCallback onDelete;

  const _OverflowMenu({
    required this.isDark,
    required this.isPreparingReplicate,
    required this.onReplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Tác vụ khác',
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      offset: const Offset(0, -8),
      onSelected: (value) {
        switch (value) {
          case 'replicate':
            if (!isPreparingReplicate) onReplicate();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'replicate',
          enabled: !isPreparingReplicate,
          child: Row(
            children: [
              isPreparingReplicate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.content_copy_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Nhân bản'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline,
                  size: 18, color: DesignColors.error),
              const SizedBox(width: 12),
              Text(
                'Xóa câu hỏi',
                style: TextStyle(color: DesignColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

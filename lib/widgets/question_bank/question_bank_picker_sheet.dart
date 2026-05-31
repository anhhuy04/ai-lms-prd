import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_notifier.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab phía trên picker — chọn nguồn dữ liệu.
enum _PickerTab { questions, assignmentFolder }

/// Bottom sheet để chọn câu hỏi từ Question Bank chèn vào assignment.
///
/// - [excludeQuestionIds]: Các câu hỏi đã có trong assignment, sẽ bị filter khỏi list.
/// - [maxItems]: Số câu tối đa được chọn mỗi lần (mặc định 50). Vượt → snackbar warning.
///
/// Trả về `List<Question>` đã chọn, hoặc `null` nếu user cancel.
class QuestionBankPickerSheet extends ConsumerStatefulWidget {
  final List<String> excludeQuestionIds;
  final int maxItems;

  const QuestionBankPickerSheet({
    super.key,
    this.excludeQuestionIds = const [],
    this.maxItems = 50,
  });

  /// Static helper để show modal.
  static Future<List<Question>?> show(
    BuildContext context, {
    List<String> excludeQuestionIds = const [],
    int maxItems = 50,
  }) {
    return showModalBottomSheet<List<Question>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => QuestionBankPickerSheet(
        excludeQuestionIds: excludeQuestionIds,
        maxItems: maxItems,
      ),
    );
  }

  @override
  ConsumerState<QuestionBankPickerSheet> createState() =>
      _QuestionBankPickerSheetState();
}

class _QuestionBankPickerSheetState
    extends ConsumerState<QuestionBankPickerSheet> {
  /// Lưu full Question objects (không chỉ ID) để khi user chọn từ
  /// assignment folder vẫn return được — không phụ thuộc filter hiện tại.
  final Map<String, Question> _selected = {};
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  QuestionType? _typeFilter;
  _PickerTab _tab = _PickerTab.questions;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return _buildContainer(
        isDark,
        const Padding(
          padding: EdgeInsets.all(DesignSpacing.xl),
          child: Center(child: Text('Vui lòng đăng nhập để truy cập kho câu hỏi')),
        ),
      );
    }

    final filter = QuestionFilter(
      authorId: userId,
      includeGlobal: true,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      type: _typeFilter,
      pageSize: 100,
    );
    final stateAsync = ref.watch(questionBankNotifierProvider(filter: filter));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _buildContainer(
        isDark,
        Column(
          children: [
            _buildHandle(isDark),
            _buildHeader(isDark),
            const Divider(height: 1),
            _buildTabBar(isDark),
            const Divider(height: 1),
            // Search + type filter chỉ ở tab Questions.
            if (_tab == _PickerTab.questions) ...[
              _buildSearchAndFilter(isDark),
              const Divider(height: 1),
            ],
            Expanded(
              child: _tab == _PickerTab.questions
                  ? _buildQuestionsList(
                      stateAsync,
                      scrollController,
                      isDark,
                    )
                  : _buildAssignmentFolderList(
                      userId,
                      scrollController,
                      isDark,
                    ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabChip(
              label: 'Câu hỏi',
              icon: Icons.quiz_outlined,
              selected: _tab == _PickerTab.questions,
              onTap: () => setState(() => _tab = _PickerTab.questions),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: _tabChip(
              label: 'Tệp bài tập',
              icon: Icons.folder_open_rounded,
              selected: _tab == _PickerTab.assignmentFolder,
              onTap: () =>
                  setState(() => _tab = _PickerTab.assignmentFolder),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? DesignColors.primary.withValues(alpha: 0.12)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(
            color: selected
                ? DesignColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? DesignColors.primary
                  : (isDark ? Colors.grey[400] : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: DesignTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? DesignColors.primary
                    : (isDark ? Colors.grey[300] : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(
    AsyncValue stateAsync,
    ScrollController scrollController,
    bool isDark,
  ) {
    return stateAsync.when(
      data: (s) {
        final available = s.questions
            .where((q) => !widget.excludeQuestionIds.contains(q.id))
            .toList();
        if (available.isEmpty) return _buildEmpty(isDark);
        return ListView.builder(
          controller: scrollController,
          itemCount: available.length,
          itemBuilder: (_, i) {
            final q = available[i];
            return _QuestionPickerItem(
              key: ValueKey(q.id),
              question: q,
              isDark: isDark,
              isSelected: _selected.containsKey(q.id),
              onToggle: (v) => _onToggle(q, v),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Text(
            'Lỗi tải kho câu hỏi: $e',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentFolderList(
    String teacherId,
    ScrollController scrollController,
    bool isDark,
  ) {
    return FutureBuilder<List<Assignment>>(
      future: ref
          .read(assignmentRepositoryProvider)
          .getAssignmentsByTeacher(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.lg),
              child: Text(
                'Lỗi tải bài tập: ${snapshot.error}',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final list = snapshot.data ?? const <Assignment>[];
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: DesignIcons.xxlSize,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: DesignSpacing.md),
                  Text(
                    'Chưa có bài tập nào',
                    style: DesignTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: list.length,
          itemBuilder: (_, i) => _AssignmentExpansion(
            assignment: list[i],
            isDark: isDark,
            excludeQuestionIds: widget.excludeQuestionIds,
            isQuestionSelected: (qid) => _selected.containsKey(qid),
            onToggleQuestion: _onToggle,
          ),
        );
      },
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildContainer(bool isDark, Widget child) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignRadius.lg * 1.5),
          ),
        ),
        child: SafeArea(top: false, child: child),
      );

  Widget _buildHandle(bool isDark) => Padding(
        padding: const EdgeInsets.only(top: DesignSpacing.sm),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildHeader(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignSpacing.lg,
          DesignSpacing.md,
          DesignSpacing.sm,
          DesignSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn câu hỏi từ kho',
                    style: DesignTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Text(
                      'Đã chọn ${_selected.length}/${widget.maxItems} câu',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Widget _buildSearchAndFilter(bool isDark) => Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm câu hỏi...',
                prefixIcon: const Icon(Icons.search, size: DesignIcons.smSize),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: DesignIcons.smSize),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                isDense: true,
              ),
              onSubmitted: (v) => setState(() => _searchQuery = v.trim()),
            ),
            const SizedBox(height: DesignSpacing.sm),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _typeFilter == null,
                    onSelected: (_) => setState(() => _typeFilter = null),
                  ),
                  ...QuestionType.values.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(left: DesignSpacing.xs),
                      child: ChoiceChip(
                        label: Text(t.label),
                        selected: _typeFilter == t,
                        selectedColor: t.color.withValues(alpha: 0.2),
                        onSelected: (_) => setState(
                          () => _typeFilter = _typeFilter == t ? null : t,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  void _onToggle(Question q, bool? v) {
    if (v == true &&
        !_selected.containsKey(q.id) &&
        _selected.length >= widget.maxItems) {
      AppToast.warning(context, 'Tối đa ${widget.maxItems} câu mỗi lần');
      return;
    }
    setState(() {
      if (v == true) {
        _selected[q.id] = q;
      } else {
        _selected.remove(q.id);
      }
    });
  }

  Widget _buildEmpty(bool isDark) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: DesignIcons.xxlSize,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: DesignSpacing.md),
              Text(
                _searchQuery.isNotEmpty || _typeFilter != null
                    ? 'Không tìm thấy câu hỏi phù hợp'
                    : 'Kho câu hỏi trống',
                style: DesignTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildFooter(bool isDark) => Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _selected.isEmpty ? null : _confirm,
                icon: const Icon(Icons.add, size: DesignIcons.smSize),
                label: Text(
                  _selected.isEmpty
                      ? 'Chưa chọn câu nào'
                      : 'Thêm ${_selected.length} câu',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Actions ───────────────────────────────────────────────────────────────

  void _confirm() {
    // _selected lưu full Question objects từ cả 2 mode (questions tab +
    // assignment folder tab) → trả về trực tiếp values, không cần filter.
    Navigator.of(context).pop(_selected.values.toList());
  }
}

/// Item card cho picker — hiển thị đầy đủ:
/// type badge + difficulty stars + source icon, question text,
/// choices preview (cho MC/TrueFalse), tags.
class _QuestionPickerItem extends ConsumerStatefulWidget {
  final Question question;
  final bool isDark;
  final bool isSelected;
  final ValueChanged<bool?> onToggle;

  const _QuestionPickerItem({
    super.key,
    required this.question,
    required this.isDark,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  ConsumerState<_QuestionPickerItem> createState() =>
      _QuestionPickerItemState();
}

class _QuestionPickerItemState extends ConsumerState<_QuestionPickerItem> {
  Future<List<QuestionChoice>>? _choicesFuture;

  static const _typesWithChoices = {
    QuestionType.multipleChoice,
    QuestionType.trueFalse,
  };

  @override
  void initState() {
    super.initState();
    if (_typesWithChoices.contains(widget.question.type)) {
      _choicesFuture = ref
          .read(questionRepositoryProvider)
          .getChoicesByQuestionId(widget.question.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final preview = _extractPreview(q.content);
    final difficulty = q.difficulty ?? 0;
    final isDark = widget.isDark;

    return InkWell(
      onTap: () => widget.onToggle(!widget.isSelected),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.xs,
        ),
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? DesignColors.primary.withValues(alpha: 0.06)
              : (isDark ? const Color(0xFF22303C) : Colors.white),
          border: Border.all(
            color: widget.isSelected
                ? DesignColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: widget.isSelected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: widget.isSelected,
                  activeColor: DesignColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: widget.onToggle,
                ),
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(q, difficulty, isDark),
                  const SizedBox(height: DesignSpacing.xs),
                  Text(
                    preview.isEmpty ? '(Chưa có nội dung)' : preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DesignTypography.bodyMedium.copyWith(
                      color: isDark
                          ? Colors.grey[100]
                          : DesignColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_choicesFuture != null) ...[
                    const SizedBox(height: DesignSpacing.sm),
                    _buildChoices(isDark),
                  ],
                  if (q.tags.isNotEmpty) ...[
                    const SizedBox(height: DesignSpacing.sm),
                    _buildTags(q.tags, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(Question q, int difficulty, bool isDark) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: q.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.xs),
          ),
          child: Text(
            q.type.label,
            style: DesignTypography.labelSmall.copyWith(
              fontSize: 11,
              color: q.type.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (difficulty > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => Icon(
                i < difficulty ? Icons.star : Icons.star_border,
                size: 13,
                color: DesignColors.warning,
              ),
            ),
          ),
        if (q.isAiGenerated)
          Tooltip(
            message: 'AI tạo',
            child: const Icon(
              Icons.auto_awesome,
              size: 14,
              color: Colors.purple,
            ),
          )
        else if (q.isGlobal)
          Tooltip(
            message: 'Toàn cầu',
            child: Icon(
              Icons.public,
              size: 14,
              color: DesignColors.success,
            ),
          ),
      ],
    );
  }

  Widget _buildChoices(bool isDark) {
    return FutureBuilder<List<QuestionChoice>>(
      future: _choicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Đang tải đáp án...',
              style: DesignTypography.labelSmall.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Không thể tải đáp án',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.error,
            ),
          );
        }
        final choices = snapshot.data ?? const <QuestionChoice>[];
        if (choices.isEmpty) return const SizedBox.shrink();
        final sorted = [...choices]..sort((a, b) => a.id.compareTo(b.id));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sorted
              .map((c) => _buildChoiceRow(c, isDark))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildChoiceRow(QuestionChoice choice, bool isDark) {
    final text = choice.content['text'] as String? ?? '';
    final label = String.fromCharCode(65 + choice.id); // A, B, C, D...
    final correct = choice.isCorrect;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: correct
            ? DesignColors.success.withValues(alpha: 0.10)
            : (isDark ? Colors.white10 : Colors.grey.shade50),
        border: Border.all(
          color: correct
              ? DesignColors.success.withValues(alpha: 0.4)
              : (isDark ? Colors.grey[700]! : Colors.grey.shade200),
        ),
        borderRadius: BorderRadius.circular(DesignRadius.xs),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: correct
                ? DesignColors.success
                : (isDark ? Colors.grey[500] : Colors.grey[500]),
          ),
          const SizedBox(width: 6),
          Text(
            '$label.',
            style: DesignTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: correct
                  ? DesignColors.success
                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text.isEmpty ? '(trống)' : text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DesignTypography.labelSmall.copyWith(
                color: correct
                    ? DesignColors.success
                    : (isDark ? Colors.grey[200] : DesignColors.textPrimary),
                fontWeight: correct ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<String> tags, bool isDark) {
    final shown = tags.take(4).toList();
    final extra = tags.length - shown.length;
    return Wrap(
      spacing: DesignSpacing.xs,
      runSpacing: 4,
      children: [
        ...shown.map(
          (t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blueGrey.withValues(alpha: 0.25)
                  : Colors.blueGrey.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(DesignRadius.xs),
            ),
            child: Text(
              '#$t',
              style: DesignTypography.labelSmall.copyWith(
                fontSize: 11,
                color: isDark ? Colors.grey[300] : Colors.blueGrey[700],
              ),
            ),
          ),
        ),
        if (extra > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              '+$extra',
              style: DesignTypography.labelSmall.copyWith(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  /// Plain-text preview từ Quill Delta hoặc plain content JSON.
  String _extractPreview(Map<String, dynamic> content) {
    if (content['ops'] is List) {
      return (content['ops'] as List)
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join()
          .replaceAll('\n', ' ')
          .trim();
    }
    if (content['text'] is String) {
      return (content['text'] as String).replaceAll('\n', ' ').trim();
    }
    return '';
  }
}

/// ExpansionTile cho 1 assignment trong tab "Tệp bài tập":
/// - Header: folder icon + title + status badge.
/// - Children: list câu hỏi bank-linked có checkbox để select.
/// - Custom question (`questionId == null`): hiển thị placeholder, không
///   select được (vì không có entry trong bank để chèn vào assignment khác).
class _AssignmentExpansion extends ConsumerWidget {
  final Assignment assignment;
  final bool isDark;
  final List<String> excludeQuestionIds;
  final bool Function(String questionId) isQuestionSelected;
  final void Function(Question q, bool? v) onToggleQuestion;

  const _AssignmentExpansion({
    required this.assignment,
    required this.isDark,
    required this.excludeQuestionIds,
    required this.isQuestionSelected,
    required this.onToggleQuestion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor =
        assignment.isPublished ? DesignColors.success : DesignColors.warning;
    final statusLabel =
        assignment.isPublished ? 'Đã phát hành' : 'Bản nháp';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22303C) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: 4,
          ),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignRadius.xs),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: DesignColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            assignment.title,
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignRadius.full),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          children: [
            FutureBuilder<List<AssignmentQuestion>>(
              future: ref
                  .read(assignmentRepositoryProvider)
                  .getAssignmentQuestions(assignment.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Lỗi: ${snapshot.error}',
                      style: TextStyle(color: DesignColors.error),
                    ),
                  );
                }
                final questions = (snapshot.data ?? []).toList()
                  ..sort((a, b) => a.orderIdx.compareTo(b.orderIdx));
                if (questions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Bài tập chưa có câu hỏi',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
                return Column(
                  children: List.generate(questions.length, (i) {
                    final aq = questions[i];
                    return _AssignmentQuestionPickerRow(
                      order: i + 1,
                      aq: aq,
                      isDark: isDark,
                      isExcluded: aq.questionId != null &&
                          excludeQuestionIds.contains(aq.questionId),
                      isSelected: aq.questionId != null &&
                          isQuestionSelected(aq.questionId!),
                      onToggle: onToggleQuestion,
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 question row trong assignment expansion:
/// - Bank question: checkbox + preview + tap → toggle select.
/// - Custom question: ổ khoá icon, italic placeholder, không select được.
class _AssignmentQuestionPickerRow extends ConsumerWidget {
  final int order;
  final AssignmentQuestion aq;
  final bool isDark;
  final bool isExcluded;
  final bool isSelected;
  final void Function(Question q, bool? v) onToggle;

  const _AssignmentQuestionPickerRow({
    required this.order,
    required this.aq,
    required this.isDark,
    required this.isExcluded,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = aq.questionId;

    // Custom question — không có entry trong bank, không chèn lại được.
    if (qid == null) {
      final preview = _extractPreview(aq.customContent ?? const {});
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ),
        leading: _orderCircle(
          order,
          DesignColors.warning,
          isDark: isDark,
          faded: true,
        ),
        title: Text(
          preview.isEmpty ? '(Câu hỏi tuỳ chỉnh)' : preview,
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Tooltip(
          message: 'Câu hỏi tuỳ chỉnh trong đề — không chèn lại được',
          child: Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: DesignColors.textSecondary,
          ),
        ),
      );
    }

    // Question đã có trong assignment đang edit → ẩn/disable.
    if (isExcluded) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ),
        leading: _orderCircle(
          order,
          DesignColors.success,
          isDark: isDark,
          faded: true,
        ),
        title: Text(
          'Đã có trong bài tập này',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.success,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: DesignColors.success,
        ),
      );
    }

    // Bank question → fetch + render với checkbox.
    return FutureBuilder<Question?>(
      future: ref.read(questionRepositoryProvider).getQuestionById(qid),
      builder: (context, snapshot) {
        final q = snapshot.data;
        final preview = q == null ? 'Đang tải...' : _extractPreview(q.content);
        return InkWell(
          onTap: q == null ? null : () => onToggle(q, !isSelected),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: DesignColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: q == null
                        ? null
                        : (v) => onToggle(q, v),
                  ),
                ),
                const SizedBox(width: 6),
                _orderCircle(order, DesignColors.primary, isDark: isDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (q != null) ...[
                        _buildMetaChip(q),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        preview.isEmpty ? '(Chưa có nội dung)' : preview,
                        style: DesignTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _orderCircle(
    int order,
    Color color, {
    required bool isDark,
    bool faded = false,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: faded ? 0.08 : 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$order',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(Question q) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: q.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.xs),
          ),
          child: Text(
            q.type.label,
            style: DesignTypography.labelSmall.copyWith(
              fontSize: 10,
              color: q.type.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if ((q.difficulty ?? 0) > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => Icon(
                i < (q.difficulty ?? 0) ? Icons.star : Icons.star_border,
                size: 10,
                color: DesignColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  String _extractPreview(Map<String, dynamic> content) {
    if (content['ops'] is List) {
      return (content['ops'] as List)
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join()
          .replaceAll('\n', ' ')
          .trim();
    }
    if (content['text'] is String) {
      return (content['text'] as String).replaceAll('\n', ' ').trim();
    }
    if (content['override_text'] is String) {
      return (content['override_text'] as String)
          .replaceAll('\n', ' ')
          .trim();
    }
    return '';
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_notifier.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Set<String> _selectedIds = {};
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  QuestionType? _typeFilter;

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
            _buildSearchAndFilter(isDark),
            const Divider(height: 1),
            Expanded(
              child: stateAsync.when(
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
                        isSelected: _selectedIds.contains(q.id),
                        onToggle: (v) => _onToggle(q, v),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
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
                  if (_selectedIds.isNotEmpty)
                    Text(
                      'Đã chọn ${_selectedIds.length}/${widget.maxItems} câu',
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
    if (v == true && _selectedIds.length >= widget.maxItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tối đa ${widget.maxItems} câu mỗi lần'),
          backgroundColor: DesignColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      if (v == true) {
        _selectedIds.add(q.id);
      } else {
        _selectedIds.remove(q.id);
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
                onPressed: _selectedIds.isEmpty ? null : _confirm,
                icon: const Icon(Icons.add, size: DesignIcons.smSize),
                label: Text(
                  _selectedIds.isEmpty
                      ? 'Chưa chọn câu nào'
                      : 'Thêm ${_selectedIds.length} câu',
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
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    // Đọc state hiện tại với CÙNG filter đang hiển thị → guarantee
    // ref nhận về danh sách đúng (đã filter type/search).
    final currentFilter = QuestionFilter(
      authorId: userId,
      includeGlobal: true,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      type: _typeFilter,
      pageSize: 100,
    );
    final stateAsync =
        ref.read(questionBankNotifierProvider(filter: currentFilter));
    final s = stateAsync.value;
    if (s == null) return;

    final selected =
        s.questions.where((q) => _selectedIds.contains(q.id)).toList();
    Navigator.of(context).pop(selected);
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

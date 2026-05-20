import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/question_stats_provider.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';

/// List item card cho Question Bank screen — phiên bản nâng cấp.
///
/// Hiển thị:
/// - Header: type badge + difficulty stars + source icon + 3-dot menu
/// - Body: preview text (max 2 lines)
/// - Tags row: tối đa 4 chips + "+N" nếu nhiều hơn
/// - Footer: ngày tạo (relative) + số lượt dùng (từ question_stats)
class QuestionBankCard extends ConsumerWidget {
  final QuestionVM vm;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const QuestionBankCard({
    super.key,
    required this.vm,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = vm.question;
    final preview = _extractPreview(q.content);

    return Semantics(
      label:
          'Câu hỏi ${q.type.label}, độ khó ${q.difficulty ?? 0} trên 5',
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: DesignSpacing.xs,
          horizontal: DesignSpacing.md,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(q),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  preview.isEmpty ? '(Chưa có nội dung)' : preview,
                  style: DesignTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (q.tags.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.sm),
                  _buildTagsRow(q.tags),
                ],
                SizedBox(height: DesignSpacing.sm),
                Divider(height: 1, color: DesignColors.dividerLight),
                SizedBox(height: DesignSpacing.sm),
                _buildFooter(context, ref, q),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Content extraction ----------

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

  // ---------- Header ----------

  Widget _buildHeader(Question q) {
    return Row(
      children: [
        _typeBadge(q.type),
        SizedBox(width: DesignSpacing.sm),
        _difficultyStars(q.difficulty ?? 0),
        SizedBox(width: DesignSpacing.sm),
        _sourceIcon(q),
        const Spacer(),
        if (vm.canEdit || vm.canDelete) _buildMenu(),
      ],
    );
  }

  Widget _typeBadge(QuestionType type) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: DesignSpacing.xs,
      vertical: 2,
    ),
    decoration: BoxDecoration(
      color: type.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(DesignRadius.sm),
    ),
    child: Text(
      type.label,
      style: DesignTypography.labelSmall.copyWith(color: type.color),
    ),
  );

  Widget _difficultyStars(int level) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (i) => Icon(
        i < level ? Icons.star : Icons.star_border,
        size: 14,
        color: DesignColors.warning,
      ),
    ),
  );

  /// Source icon — chỉ 1 icon ưu tiên theo thứ tự AI > Global > Teacher.
  Widget _sourceIcon(Question q) {
    if (q.isAiGenerated) {
      return Tooltip(
        message: 'AI tạo',
        child: const Icon(
          Icons.auto_awesome,
          size: 16,
          color: Colors.purple,
        ),
      );
    }
    if (q.isGlobal) {
      return Tooltip(
        message: 'Toàn cầu',
        child: Icon(Icons.public, size: 16, color: DesignColors.success),
      );
    }
    return Tooltip(
      message: 'Giáo viên',
      child: Icon(
        Icons.person_outline,
        size: 16,
        color: DesignColors.textSecondary,
      ),
    );
  }

  // ---------- Tags ----------

  Widget _buildTagsRow(List<String> tags) {
    final shown = tags.take(4).toList();
    final extra = tags.length - shown.length;
    return Wrap(
      spacing: DesignSpacing.xs,
      runSpacing: DesignSpacing.xs / 2,
      children: [
        ...shown.map(
          (t) => Chip(
            label: Text('#$t', style: DesignTypography.labelSmall),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
        ),
        if (extra > 0)
          Chip(
            label: Text(
              '+$extra',
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  // ---------- Footer ----------

  Widget _buildFooter(BuildContext context, WidgetRef ref, Question q) {
    final createdLabel = q.createdAt != null
        ? 'Tạo ${_relativeDate(q.createdAt!)}'
        : 'Không rõ ngày';

    final statsAsync = ref.watch(questionStatsProvider(q.id));
    final usageText = statsAsync.maybeWhen(
      data: (s) => 'Đã dùng ${s.totalAttempts} lần',
      orElse: () => 'Đã dùng — lần',
    );

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 12,
          color: DesignColors.textSecondary,
        ),
        SizedBox(width: DesignSpacing.xs / 2),
        Expanded(
          child: Text(
            createdLabel,
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        Icon(
          Icons.bar_chart,
          size: 12,
          color: DesignColors.textSecondary,
        ),
        SizedBox(width: DesignSpacing.xs / 2),
        Text(
          usageText,
          style: DesignTypography.labelSmall.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Relative date: "Hôm nay" / "Hôm qua" / "N ngày" / "N tuần" / "N tháng" / "N năm"
  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final d = dt.toLocal();
    final diff = now.difference(d);
    final days = diff.inDays;

    // Cùng ngày (compare local calendar day)
    final sameDay = now.year == d.year &&
        now.month == d.month &&
        now.day == d.day;
    if (sameDay) return 'hôm nay';

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == d.year &&
        yesterday.month == d.month &&
        yesterday.day == d.day;
    if (isYesterday) return 'hôm qua';

    if (days < 7) return '$days ngày trước';
    if (days < 30) return '${(days / 7).floor()} tuần trước';
    if (days < 365) return '${(days / 30).floor()} tháng trước';
    return '${(days / 365).floor()} năm trước';
  }

  // ---------- Menu ----------

  Widget _buildMenu() => PopupMenuButton<String>(
    onSelected: (v) {
      if (v == 'edit') onEdit?.call();
      if (v == 'delete') onDelete?.call();
      if (v == 'duplicate') onDuplicate?.call();
    },
    itemBuilder: (_) => [
      if (vm.canEdit)
        const PopupMenuItem(value: 'edit', child: Text('Sửa')),
      const PopupMenuItem(value: 'duplicate', child: Text('Sao chép')),
      if (vm.canDelete)
        const PopupMenuItem(value: 'delete', child: Text('Xóa')),
    ],
  );
}

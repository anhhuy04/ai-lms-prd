import 'package:flutter/material.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';

/// List item card cho Question Bank screen.
///
/// Hiển thị: type badge, độ khó (sao), badges Global/AI, preview content,
/// tags, và menu (Sửa / Sao chép / Xóa) tuỳ theo quyền của user trên VM.
class QuestionBankCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = vm.question;
    final preview = _extractPreview(q.content);
    final truncated = preview.length > 160
        ? '${preview.substring(0, 160)}…'
        : preview;

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
                _buildHeader(q, isDark),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  truncated.isEmpty ? '(Chưa có nội dung)' : truncated,
                  style: DesignTypography.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (q.tags.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.sm),
                  _buildTagsRow(q.tags),
                ],
              ],
            ),
          ),
        ),
      ),
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
    return '';
  }

  Widget _buildHeader(Question q, bool isDark) {
    return Row(
      children: [
        _typeBadge(q.type),
        SizedBox(width: DesignSpacing.sm),
        _difficultyStars(q.difficulty ?? 0),
        if (q.isGlobal) ...[
          SizedBox(width: DesignSpacing.sm),
          Icon(Icons.public, size: 16, color: DesignColors.success),
        ],
        if (q.isAiGenerated) ...[
          SizedBox(width: DesignSpacing.xs),
          const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
        ],
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
    children: List.generate(
      5,
      (i) => Icon(
        i < level ? Icons.star : Icons.star_border,
        size: 14,
        color: DesignColors.warning,
      ),
    ),
  );

  Widget _buildTagsRow(List<String> tags) => Wrap(
    spacing: DesignSpacing.xs,
    runSpacing: DesignSpacing.xs / 2,
    children: tags
        .take(4)
        .map(
          (t) => Chip(
            label: Text('#$t', style: DesignTypography.labelSmall),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
        )
        .toList(),
  );

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

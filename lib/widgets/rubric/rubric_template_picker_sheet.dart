import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for selecting a saved rubric template.
///
/// Shows a list of saved templates. Supports template selection (via
/// [onSelected]) and deletion (via [onDelete]).
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => RubricTemplatePickerSheet(
///     templates: templates,
///     onSelected: (template) { ... },
///     onDelete: (index) async { ... },
///   ),
/// );
/// ```
class RubricTemplatePickerSheet extends StatefulWidget {
  /// List of templates, each `{"name": String, "rubric": {"criteria": List}}`.
  final List<Map<String, dynamic>> templates;

  /// Called when user taps a template to use it.
  final ValueChanged<Map<String, dynamic>> onSelected;

  /// Called with the index of the template to delete (after confirmation).
  /// Must return a Future so errors can be caught and shown to the user.
  final Future<void> Function(int) onDelete;

  const RubricTemplatePickerSheet({
    super.key,
    required this.templates,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  State<RubricTemplatePickerSheet> createState() =>
      _RubricTemplatePickerSheetState();
}

class _RubricTemplatePickerSheetState extends State<RubricTemplatePickerSheet> {
  late List<Map<String, dynamic>> _localTemplates;

  @override
  void initState() {
    super.initState();
    _localTemplates = List.from(widget.templates);
  }

  Future<void> _handleDelete(int index) async {
    try {
      await widget.onDelete(index);
      if (mounted) setState(() => _localTemplates.removeAt(index));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DesignRadius.lg),
              topRight: Radius.circular(DesignRadius.lg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSheetHandle(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                ).copyWith(top: DesignSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chọn Mẫu Rubric',
                    style: DesignTypography.headlineMedium,
                  ),
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              if (_localTemplates.isEmpty)
                Expanded(child: _buildEmptyState())
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _localTemplates.length,
                    separatorBuilder: (_, __) => Divider(
                      color: DesignColors.dividerLight,
                      height: 1,
                    ),
                    itemBuilder: (ctx, i) => _buildTemplateItem(ctx, i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: DesignSpacing.sm),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: DesignColors.dividerMedium,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTemplateItem(BuildContext context, int index) {
    final template = _localTemplates[index];
    final rubric = template['rubric'] as Map<String, dynamic>? ?? {};
    final criteria = rubric['criteria'] as List? ?? [];
    final criteriaCount = criteria.length;
    final totalPoints = criteria.fold<int>(
      0,
      (sum, c) => sum + ((c as Map)['max_points'] as int? ?? 0),
    );

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DesignColors.tealPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Icon(
          Icons.description,
          color: DesignColors.tealPrimary,
          size: DesignIcons.mdSize,
        ),
      ),
      title: Text(
        template['name'] as String? ?? '',
        style: DesignTypography.titleMedium,
      ),
      subtitle: Text(
        '$criteriaCount tiêu chí - $totalPoints điểm',
        style: DesignTypography.caption,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: DesignColors.error,
          size: DesignIcons.smSize,
        ),
        onPressed: () => _confirmDelete(context, index),
      ),
      onTap: () => widget.onSelected(template),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: DesignIcons.xlSize,
              color: DesignColors.textTertiary,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Chưa có template nào',
              style: DesignTypography.titleMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Lưu rubric hiện tại thành mẫu để tái sử dụng sau.',
              style: DesignTypography.bodyMedium.copyWith(
                fontSize: DesignTypography.bodySmallSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    final name = _localTemplates[index]['name'] as String? ?? '';
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa mẫu'),
        content: Text(
          "Xóa mẫu '$name'? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              _handleDelete(index);
            },
            child: Text(
              'Xóa mẫu',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

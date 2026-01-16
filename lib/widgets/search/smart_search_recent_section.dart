import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Smart Search Recent Section - Hiển thị các tìm kiếm gần đây
/// Hỗ trợ xóa từng mục hoặc xóa tất cả
class SmartSearchRecentSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentSearches;
  final Function(Map<String, dynamic>) onItemSelected;
  final Function(String) onClearRecent;

  const SmartSearchRecentSection({
    super.key,
    required this.recentSearches,
    required this.onItemSelected,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gần đây',
                style: DesignTypography.caption.copyWith(
                  color: DesignColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (recentSearches.length > 1)
                TextButton(
                  onPressed: () => onClearRecent('all'),
                  child: Text(
                    'Xóa tất cả',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
          child: Wrap(
            spacing: DesignSpacing.sm,
            runSpacing: DesignSpacing.sm,
            children: recentSearches.map((search) {
              return _buildRecentSearchTag(search);
            }).toList(),
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
      ],
    );
  }

  /// Build một tag tìm kiếm gần đây
  Widget _buildRecentSearchTag(Map<String, dynamic> search) {
    final title = search['title'] ?? '';
    final icon = search['icon'] ?? Icons.history;

    return InkWell(
      onTap: () => onItemSelected(search),
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      child: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: DesignColors.dividerLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: DesignColors.textSecondary,
                size: DesignIcons.smSize,
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                title,
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: DesignSpacing.xs),
              InkWell(
                onTap: () => onClearRecent(title),
                child: Icon(
                  Icons.close,
                  color: DesignColors.textTertiary,
                  size: DesignIcons.xsSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
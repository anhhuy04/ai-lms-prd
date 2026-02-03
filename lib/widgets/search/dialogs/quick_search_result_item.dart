import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Smart Search Result Item - Hiển thị một mục kết quả tìm kiếm
/// Hỗ trợ highlight từ khóa tìm kiếm và các loại kết quả khác nhau
class QuickSearchResultItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String searchQuery;
  final VoidCallback onTap;

  const QuickSearchResultItem({
    super.key,
    required this.item,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemType = item['type'] ?? 'student';
    final title = item['title'] ?? '';
    final subtitle = item['subtitle'] ?? '';
    final icon = _getIconForType(itemType);
    final iconColor = _getColorForType(itemType);
    final iconBackground = iconColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      hoverColor: DesignColors.primary.withValues(alpha: 0.05),
      splashColor: DesignColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
        child: Row(
          children: [
            // Icon loại kết quả
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBackground,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: DesignIcons.mdSize,
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(title),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      subtitle,
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Icon mũi tên (ẩn để giữ layout)
            Opacity(
              opacity: 0.0,
              child: Icon(
                Icons.chevron_right,
                color: DesignColors.textTertiary,
                size: DesignIcons.mdSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tạo text với highlight từ khóa tìm kiếm
  Widget _buildHighlightedText(String text) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: DesignTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final queryLower = searchQuery.toLowerCase();
    final textLower = text.toLowerCase();
    final queryIndex = textLower.indexOf(queryLower);

    if (queryIndex == -1) {
      return Text(
        text,
        style: DesignTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, queryIndex),
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: text.substring(queryIndex, queryIndex + searchQuery.length),
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignColors.primary,
            ),
          ),
          TextSpan(
            text: text.substring(queryIndex + searchQuery.length),
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy icon dựa trên loại kết quả
  IconData _getIconForType(String type) {
    switch (type) {
      case 'student':
        return Icons.person;
      case 'assignment':
        return Icons.assignment;
      case 'class':
        return Icons.class_;
      case 'room':
        return Icons.meeting_room;
      case 'setting':
        return Icons.settings;
      default:
        return Icons.search;
    }
  }

  /// Lấy màu sắc dựa trên loại kết quả
  Color _getColorForType(String type) {
    switch (type) {
      case 'student':
        return DesignColors.primary;
      case 'assignment':
        return Colors.orange;
      case 'class':
        return Colors.purple;
      case 'room':
        return Colors.blue;
      case 'setting':
        return Colors.grey;
      default:
        return DesignColors.textSecondary;
    }
  }
}


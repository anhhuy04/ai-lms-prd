import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/search_field.dart';

/// Dialog tìm kiếm với gợi ý động
/// Hiển thị list gợi ý khi người dùng nhập text
class SearchDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final List<Map<String, dynamic>> items; // [{title: '', subtitle: ''}, ...]
  final Function(Map<String, dynamic>) onItemSelected;
  final String
  searchFieldKey; // Key trong item map để tìm kiếm (VD: 'title', 'name')
  final List<String>?
  additionalSearchKeys; // Các key khác để tìm kiếm (VD: ['subtitle', 'classInfo'])

  const SearchDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.items,
    required this.onItemSelected,
    required this.searchFieldKey,
    this.additionalSearchKeys,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Lọc danh sách items dựa trên search query
  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final query = _searchQuery.toLowerCase();
    return widget.items.where((item) {
      // Tìm kiếm trong primary key
      final primaryValue =
          item[widget.searchFieldKey]?.toString().toLowerCase() ?? '';
      if (primaryValue.contains(query)) return true;

      // Tìm kiếm trong additional keys
      if (widget.additionalSearchKeys != null) {
        for (final key in widget.additionalSearchKeys!) {
          final value = item[key]?.toString().toLowerCase() ?? '';
          if (value.contains(query)) return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.xxxl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: DesignColors.dividerLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: DesignTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: DesignIcons.mdSize,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: SearchField(
                controller: _controller,
                hintText: widget.hintText,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                height: DesignComponents.inputFieldHeight,
              ),
            ),
            // Search results or empty state
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  /// Build search results list hoặc empty state
  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 56, color: Colors.grey[300]),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final filteredList = _filteredItems;

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey[300]),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Không tìm thấy kết quả',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final title = item[widget.searchFieldKey]?.toString() ?? '';
        final subtitle = item['subtitle']?.toString() ?? '';

        return _buildSearchResultItem(
          title: title,
          subtitle: subtitle,
          onTap: () {
            widget.onItemSelected(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /// Build individual search result item
  Widget _buildSearchResultItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          child: Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(color: DesignColors.dividerLight, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignColors.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.search,
                    size: DesignIcons.mdSize,
                    color: DesignColors.primary,
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: DesignTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                SizedBox(width: DesignSpacing.md),
                Icon(
                  Icons.chevron_right,
                  size: DesignIcons.mdSize,
                  color: DesignColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

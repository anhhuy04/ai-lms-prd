import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/search/smart_search_result_item.dart';
import 'package:ai_mls/widgets/search/smart_search_recent_section.dart';

/// Smart Search Dialog với giao diện hiện đại và tính năng tìm kiếm thông minh
/// Hỗ trợ hiển thị lịch sử tìm kiếm và kết quả động
class SmartSearchDialog extends StatefulWidget {
  final String hintText;
  final List<Map<String, dynamic>> recentSearches;
  final List<Map<String, dynamic>> searchResults;
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onItemSelected;
  final Function(Map<String, dynamic>) onRecentItemSelected;
  final Function(String) onClearRecent;
  final String searchQuery;

  const SmartSearchDialog({
    super.key,
    required this.hintText,
    required this.recentSearches,
    required this.searchResults,
    required this.onSearch,
    required this.onItemSelected,
    required this.onRecentItemSelected,
    required this.onClearRecent,
    required this.searchQuery,
  });

  @override
  State<SmartSearchDialog> createState() => _SmartSearchDialogState();
}

class _SmartSearchDialogState extends State<SmartSearchDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xl,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.searchQuery.isEmpty)
                      SmartSearchRecentSection(
                        recentSearches: widget.recentSearches,
                        onItemSelected: widget.onRecentItemSelected,
                        onClearRecent: widget.onClearRecent,
                      ),
                    if (widget.searchQuery.isNotEmpty)
                      _buildSearchResults(),
                  ],
                ),
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Build header với thanh tìm kiếm
  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.xl,
        DesignSpacing.lg,
        DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: DesignColors.textSecondary,
                    size: DesignIcons.mdSize,
                  ),
                  suffixIcon: widget.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: DesignColors.textSecondary,
                            size: DesignIcons.smSize,
                          ),
                          onPressed: () {
                            _controller.clear();
                            widget.onSearch('');
                          },
                        )
                      : null,
                  hintText: widget.hintText,
                  hintStyle: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.lg,
                    vertical: DesignSpacing.md,
                  ),
                ),
                style: DesignTypography.bodyMedium,
                onChanged: widget.onSearch,
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build phần kết quả tìm kiếm
  Widget _buildSearchResults() {
    if (widget.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: DesignIcons.xlSize,
                color: DesignColors.textTertiary,
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Không tìm thấy kết quả',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.md,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kết quả tìm kiếm',
              style: DesignTypography.caption.copyWith(
                color: DesignColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: DesignColors.dividerLight,
          indent: DesignSpacing.lg,
          endIndent: DesignSpacing.lg,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.sm,
          ),
          itemCount: widget.searchResults.length,
          itemBuilder: (context, index) {
            final item = widget.searchResults[index];
            return SmartSearchResultItem(
              item: item,
              searchQuery: widget.searchQuery,
              onTap: () => widget.onItemSelected(item),
            );
          },
        ),
      ],
    );
  }
}
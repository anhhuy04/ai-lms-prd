import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Smart Search Dialog V2 - Thiết kế lại theo yêu cầu mới
/// Chuyên dụng cho tìm kiếm trong chi tiết lớp học
class QuickSearchDialog extends StatefulWidget {
  final String initialQuery;
  final List<Map<String, dynamic>> assignments;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> classes;
  final Function(Map<String, dynamic>) onItemSelected;

  const QuickSearchDialog({
    super.key,
    required this.initialQuery,
    required this.assignments,
    required this.students,
    required this.classes,
    required this.onItemSelected,
  });

  @override
  State<QuickSearchDialog> createState() => _QuickSearchDialogState();
}

class _QuickSearchDialogState extends State<QuickSearchDialog> {
  late TextEditingController _controller;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredAssignments = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  List<Map<String, dynamic>> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _searchQuery = widget.initialQuery;
    _filterResults();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterResults() {
    final query = _searchQuery.toLowerCase();

    setState(() {
      _filteredAssignments = widget.assignments.where((item) {
        final title = item['title']?.toString().toLowerCase() ?? '';
        final subtitle = item['subtitle']?.toString().toLowerCase() ?? '';
        return title.contains(query) || subtitle.contains(query);
      }).toList();

      _filteredStudents = widget.students.where((item) {
        final title = item['title']?.toString().toLowerCase() ?? '';
        final subtitle = item['subtitle']?.toString().toLowerCase() ?? '';
        return title.contains(query) || subtitle.contains(query);
      }).toList();

      _filteredClasses = widget.classes.where((item) {
        final title = item['title']?.toString().toLowerCase() ?? '';
        final subtitle = item['subtitle']?.toString().toLowerCase() ?? '';
        return title.contains(query) || subtitle.contains(query);
      }).toList();
    });
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
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
                    if (_searchQuery.isNotEmpty &&
                        _filteredAssignments.isNotEmpty) ...[
                      _buildAssignmentsSection(),
                      _buildDivider(),
                    ],
                    if (_searchQuery.isNotEmpty &&
                        _filteredStudents.isNotEmpty) ...[
                      _buildStudentsSection(),
                      if (_filteredClasses.isNotEmpty) _buildDivider(),
                    ],
                    if (_searchQuery.isNotEmpty &&
                        _filteredClasses.isNotEmpty) ...[
                      _buildClassesSection(),
                    ],
                    if (_searchQuery.isNotEmpty &&
                        _filteredAssignments.isEmpty &&
                        _filteredStudents.isEmpty &&
                        _filteredClasses.isEmpty) ...[
                      _buildEmptyResults(),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.xl,
        DesignSpacing.lg,
        DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
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
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: DesignColors.textSecondary,
                            size: DesignIcons.smSize,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _filterResults();
                          },
                        )
                      : null,
                  hintText: 'Tìm kiếm bài tập, học sinh, lớp học...',
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
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                  _filterResults();
                },
                onSubmitted: (query) {
                  _filterResults();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.sm,
          ),
          child: Text(
            'BÀI TẬP',
            style: DesignTypography.caption.copyWith(
              color: DesignColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _filteredAssignments.length,
          itemBuilder: (context, index) {
            final item = _filteredAssignments[index];
            return _buildResultItem(
              item: item,
              icon: Icons.assignment,
              iconColor: DesignColors.primary,
              onTap: () => widget.onItemSelected(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.sm,
          ),
          child: Text(
            'HỌC SINH',
            style: DesignTypography.caption.copyWith(
              color: DesignColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _filteredStudents.length,
          itemBuilder: (context, index) {
            final item = _filteredStudents[index];
            return _buildResultItem(
              item: item,
              icon: Icons.person,
              iconColor: Colors.orange,
              onTap: () => widget.onItemSelected(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.sm,
          ),
          child: Text(
            'LỚP HỌC',
            style: DesignTypography.caption.copyWith(
              color: DesignColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _filteredClasses.length,
          itemBuilder: (context, index) {
            final item = _filteredClasses[index];
            return _buildResultItem(
              item: item,
              icon: Icons.class_,
              iconColor: Colors.purple,
              onTap: () => widget.onItemSelected(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultItem({
    required Map<String, dynamic> item,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final title = item['title'] ?? '';
    final subtitle = item['subtitle'] ?? '';

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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: iconColor, size: DesignIcons.mdSize),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(title, _searchQuery),
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

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: DesignTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final queryLower = query.toLowerCase();
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
            text: text.substring(queryIndex, queryIndex + query.length),
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignColors.primary,
            ),
          ),
          TextSpan(
            text: text.substring(queryIndex + query.length),
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).dividerColor,
      indent: DesignSpacing.lg,
      endIndent: DesignSpacing.lg,
    );
  }

  Widget _buildFooter() {
    final totalResults =
        _filteredAssignments.length +
        _filteredStudents.length +
        _filteredClasses.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nhấn Enter để tìm tất cả',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          Text(
            '$totalResults kết quả',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị thông báo khi không có kết quả nào
  Widget _buildEmptyResults() {
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
              'Không tìm thấy kết quả nào',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Hãy thử từ khóa khác hoặc kiểm tra chính tả',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

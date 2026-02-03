import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_create_question_screen.dart';
import 'package:flutter/material.dart';

/// Widget quản lý danh sách options cho câu hỏi Multiple Choice
class QuestionOptionsList extends StatefulWidget {
  final List<QuestionOption> options;
  final ValueChanged<List<QuestionOption>> onOptionsChanged;

  const QuestionOptionsList({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  State<QuestionOptionsList> createState() => _QuestionOptionsListState();
}

class _QuestionOptionsListState extends State<QuestionOptionsList> {
  late List<QuestionOption> _options;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options);
  }

  @override
  void didUpdateWidget(QuestionOptionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      _options = List.from(widget.options);
    }
  }

  void _addOption() {
    if (_options.length < 8) {
      setState(() {
        _options.add(QuestionOption(text: ''));
        widget.onOptionsChanged(_options);
      });
    }
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options[index].controller.dispose();
        _options.removeAt(index);
        widget.onOptionsChanged(_options);
      });
    }
  }

  void _markCorrect(int index) {
    setState(() {
      // Uncheck all others (single answer)
      for (var opt in _options) {
        opt.isCorrect = false;
      }
      _options[index].isCorrect = true;
      widget.onOptionsChanged(_options);
    });
  }

  void _showBulkImportDialog() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        ),
        title: Row(
          children: [
            Icon(
              Icons.upload_file_rounded,
              size: 24,
              color: DesignColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Import Đáp Án',
                style: DesignTypography.titleMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập mỗi đáp án trên một dòng',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 8,
                style: DesignTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Ví dụ:\nĐáp án A\nĐáp án B\nĐáp án C',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Còn ${8 - _options.length} vị trí trống',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final lines = controller.text
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .toList();

              if (lines.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập ít nhất một đáp án'),
                    backgroundColor: DesignColors.error,
                  ),
                );
                return;
              }

              if (lines.length + _options.length <= 8) {
                setState(() {
                  for (var line in lines) {
                    _options.add(QuestionOption(text: line));
                  }
                  widget.onOptionsChanged(_options);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ${lines.length} đáp án'),
                    backgroundColor: DesignColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tối đa 8 lựa chọn. Bạn có thể thêm ${8 - _options.length} đáp án nữa.',
                    ),
                    backgroundColor: DesignColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  String _getOptionLabel(int index) {
    return String.fromCharCode(65 + index); // A, B, C, D...
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                      ),
                      child: Icon(
                        Icons.radio_button_checked,
                        size: 20,
                        color: DesignColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'CÁC ĐÁP ÁN',
                        style:
                            TextStyle(
                              fontSize: DesignTypography.labelSmallSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ).copyWith(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Text(
                  'Chọn đáp án đúng',
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: DesignSpacing.xxl,
            color: isDark ? Colors.grey[700] : Colors.grey[100],
          ),

          // Options List
          ..._options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionItem(context, isDark, index, option);
          }),

          SizedBox(height: DesignSpacing.md),

          // Action Buttons Row
          if (_options.length < 8)
            Row(
              children: [
                // Add Option Button (Icon only)
                Container(
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                    border: Border.all(
                      color: DesignColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addOption,
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 24,
                          color: DesignColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Import Button (Icon + Text)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]!.withValues(alpha: 0.5)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showBulkImportDialog,
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_rounded,
                                size: 20,
                                color: isDark
                                    ? Colors.grey[300]
                                    : DesignColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Import',
                                style: DesignTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : DesignColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    bool isDark,
    int index,
    QuestionOption option,
  ) {
    final label = _getOptionLabel(index);

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          // Radio Button
          Radio<bool>(
            value: true,
            groupValue: option.isCorrect,
            onChanged: (value) => _markCorrect(index),
            activeColor: DesignColors.primary,
          ),

          // Text Field
          Expanded(
            child: TextFormField(
              controller: option.controller,
              minLines: 1,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Nhập đáp án $label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  borderSide: BorderSide(color: DesignColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: DesignTypography.labelSmallSize,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
              style: DesignTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập nội dung lựa chọn';
                }
                return null;
              },
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: _options.length > 2 ? () => _removeOption(index) : null,
            icon: Icon(Icons.delete_outline, size: 20),
            color: DesignColors.error,
          ),
        ],
      ),
    );
  }
}

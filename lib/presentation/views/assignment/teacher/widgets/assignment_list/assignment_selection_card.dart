import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:flutter/material.dart';

class AssignmentSelectionCard extends StatelessWidget {
  final Assignment assignment;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const AssignmentSelectionCard({
    super.key,
    required this.assignment,
    required this.isSelected,
    required this.onChanged,
  });

  // Helper functions to mock data parsing based on title
  String _getSubjectColorClass() {
    final title = assignment.title.toLowerCase();
    if (title.contains('toán')) return 'blue';
    if (title.contains('văn')) return 'orange';
    if (title.contains('anh')) return 'purple';
    if (title.contains('lý')) return 'green';
    if (title.contains('hóa')) return 'pink';
    return 'gray';
  }

  String _getSubjectName() {
    final title = assignment.title.toLowerCase();
    if (title.contains('toán')) return 'Toán';
    if (title.contains('văn')) return 'Ngữ Văn';
    if (title.contains('anh')) return 'Tiếng Anh';
    if (title.contains('lý')) return 'Vật Lý';
    if (title.contains('hóa')) return 'Hóa học';
    return 'Môn học';
  }

  String _getGrade() {
    final title = assignment.title.toLowerCase();
    if (title.contains('10')) return 'Lớp 10';
    if (title.contains('11')) return 'Lớp 11';
    if (title.contains('12')) return 'Lớp 12';
    return 'Chung';
  }

  String _getDifficulty() {
    final title = assignment.title.toLowerCase();
    if (title.contains('nâng cao') || title.contains('khó')) return 'Khó';
    if (title.contains('dễ') || title.contains('review')) return 'Dễ';
    return 'Trung bình';
  }

  IconData _getDifficultyIcon() {
    final diff = _getDifficulty();
    if (diff == 'Khó') return Icons.signal_cellular_alt;
    if (diff == 'Dễ') return Icons.signal_cellular_alt_1_bar;
    return Icons.signal_cellular_alt_2_bar;
  }

  String _getFormat() {
    final title = assignment.title.toLowerCase();
    if (title.contains('tự luận') || title.contains('phân tích')) {
      return 'Tự luận';
    }
    return 'Trắc nghiệm';
  }

  IconData _getFormatIcon() {
    return _getFormat() == 'Tự luận' ? Icons.edit_note : Icons.check_circle;
  }

  Color _getSubjectBgColor(bool isDark) {
    final colorCls = _getSubjectColorClass();
    switch (colorCls) {
      case 'blue':
        return isDark
            ? Colors.blue[900]!.withValues(alpha: 0.3)
            : Colors.blue[100]!;
      case 'orange':
        return isDark
            ? Colors.orange[900]!.withValues(alpha: 0.3)
            : Colors.orange[100]!;
      case 'purple':
        return isDark
            ? Colors.purple[900]!.withValues(alpha: 0.3)
            : Colors.purple[100]!;
      case 'green':
        return isDark
            ? Colors.green[900]!.withValues(alpha: 0.3)
            : Colors.green[100]!;
      case 'pink':
        return isDark
            ? Colors.pink[900]!.withValues(alpha: 0.3)
            : Colors.pink[100]!;
      default:
        return isDark ? Colors.grey[800]! : Colors.grey[100]!;
    }
  }

  Color _getSubjectTextColor(bool isDark) {
    final colorCls = _getSubjectColorClass();
    switch (colorCls) {
      case 'blue':
        return isDark ? Colors.blue[300]! : Colors.blue[700]!;
      case 'orange':
        return isDark ? Colors.orange[300]! : Colors.orange[700]!;
      case 'purple':
        return isDark ? Colors.purple[300]! : Colors.purple[700]!;
      case 'green':
        return isDark ? Colors.green[300]! : Colors.green[700]!;
      case 'pink':
        return isDark ? Colors.pink[300]! : Colors.pink[700]!;
      default:
        return isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Derived tokens
    final activeBgColor = isDark
        ? DesignColors.primary.withValues(alpha: 0.1)
        : Colors.blue[50]!.withValues(alpha: 0.5);
    final inactiveBgColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final borderColor = isSelected
        ? DesignColors.primary
        : (isDark ? Colors.grey[800]! : Colors.grey[100]!);

    final subjectBg = _getSubjectBgColor(isDark);
    final subjectText = _getSubjectTextColor(isDark);
    final gradeBg = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final gradeText = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    final tMain = isDark ? Colors.white : const Color(0xFF111418);
    final tSec = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Lexend'),
      child: GestureDetector(
        onTap: () => onChanged(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : inactiveBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            boxShadow: !isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: subjectBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getSubjectName(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subjectText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: gradeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getGrade(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: gradeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tMain,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Footer details
                    Row(
                      children: [
                        _buildFooterItem(
                          icon: _getDifficultyIcon(),
                          text: _getDifficulty(),
                          color: tSec,
                        ),
                        const SizedBox(width: 12),
                        _buildFooterItem(
                          icon: _getFormatIcon(),
                          text: _getFormat(),
                          color: tSec,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Custom Checkbox mapping HTML
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? DesignColors.primary
                      : (isDark ? Colors.transparent : Colors.white),
                  border: Border.all(
                    color: isSelected
                        ? DesignColors.primary
                        : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

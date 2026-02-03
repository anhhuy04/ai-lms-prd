import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Dialog/Bottom sheet chọn thời gian làm bài
class TimeLimitPickerDialog {
  /// Hiển thị bottom sheet chọn thời gian làm bài
  /// Trả về giá trị thời gian (phút) hoặc 'unlimited'
  static Future<String?> show({
    required BuildContext context,
    String? currentValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimeLimitPickerContent(
        currentValue: currentValue,
      ),
    );
  }
}

class _TimeLimitPickerContent extends StatelessWidget {
  final String? currentValue;

  const _TimeLimitPickerContent({
    this.currentValue,
  });

  static const List<Map<String, dynamic>> _timeOptions = [
    {'value': '15', 'label': '15 phút', 'icon': Icons.timer_outlined},
    {'value': '30', 'label': '30 phút', 'icon': Icons.timer_outlined},
    {'value': '45', 'label': '45 phút', 'icon': Icons.timer_outlined},
    {'value': '60', 'label': '1 giờ', 'icon': Icons.timer_outlined},
    {'value': '90', 'label': '1.5 giờ', 'icon': Icons.timer_outlined},
    {'value': '120', 'label': '2 giờ', 'icon': Icons.timer_outlined},
    {'value': '180', 'label': '3 giờ', 'icon': Icons.timer_outlined},
    {'value': 'unlimited', 'label': 'Không giới hạn', 'icon': Icons.all_inclusive},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignRadius.lg * 2),
          topRight: Radius.circular(DesignRadius.lg * 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                    ),
                    child: Icon(
                      Icons.timer,
                      size: 24,
                      color: DesignColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn thời gian làm bài',
                          style: DesignTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : DesignColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian tối đa học sinh có thể làm bài',
                          style: DesignTypography.bodySmall.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: _timeOptions.length,
                itemBuilder: (context, index) {
                  final option = _timeOptions[index];
                  final isSelected = currentValue == option['value'];

                  return InkWell(
                    onTap: () => Navigator.pop(context, option['value']),
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DesignColors.primary.withValues(alpha: 0.1)
                            : isDark
                                ? Colors.grey[800]!.withValues(alpha: 0.5)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                        border: Border.all(
                          color: isSelected
                              ? DesignColors.primary
                              : isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? DesignColors.primary
                                : isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              option['label'] as String,
                              style: DesignTypography.bodySmall.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? DesignColors.primary
                                    : isDark
                                        ? Colors.white
                                        : DesignColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: DesignColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Custom input option
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: () => _showCustomTimeDialog(context, isDark),
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tùy chỉnh thời gian',
                        style: DesignTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomTimeDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.timer, color: DesignColors.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nhập thời gian tùy chỉnh',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số phút',
                hintText: 'Ví dụ: 75',
                prefixIcon: const Icon(Icons.timer_outlined),
                filled: true,
                fillColor: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập số phút (tối đa 480 phút = 8 giờ)',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                final minutes = int.tryParse(value);
                if (minutes != null && minutes > 0 && minutes <= 480) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, value);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

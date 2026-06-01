import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Một tuỳ chọn giọng điệu phản hồi AI.
class FeedbackToneOption {
  const FeedbackToneOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// Giá trị lưu vào metadata.feedback_tone (khớp với edge buildToneInstruction).
  final String value;

  /// Nhãn hiển thị (tiếng Việt có dấu).
  final String label;

  /// Mô tả ngắn cho từng giọng điệu.
  final String description;

  final IconData icon;
}

/// Danh sách 3 giọng điệu phản hồi AI — nguồn chân lý dùng chung cho UI + test.
///
/// Khớp với edge function `buildToneInstruction(tone)`:
/// - encouraging → động viên (mặc định)
/// - direct      → thẳng thắn
/// - detailed    → chi tiết
const List<FeedbackToneOption> kFeedbackToneOptions = [
  FeedbackToneOption(
    value: 'encouraging',
    label: 'Động viên',
    description: 'Ấm áp, nêu điểm tốt trước rồi mới góp ý nhẹ nhàng.',
    icon: Icons.favorite_outline_rounded,
  ),
  FeedbackToneOption(
    value: 'direct',
    label: 'Thẳng thắn',
    description: 'Ngắn gọn, đi thẳng vào lỗi sai, không vòng vo.',
    icon: Icons.bolt_outlined,
  ),
  FeedbackToneOption(
    value: 'detailed',
    label: 'Chi tiết',
    description: 'Phân tích cặn kẽ theo từng bước, mang tính học thuật.',
    icon: Icons.menu_book_outlined,
  ),
];

/// Control chọn giọng điệu phản hồi AI (Track 3).
///
/// Tách thành widget độc lập, không phụ thuộc Supabase, để dễ test:
/// - [value]: giá trị hiện tại ('encouraging' | 'direct' | 'detailed').
/// - [onChanged]: callback khi GV chọn — màn cha persist vào metadata.
class FeedbackToneSetting extends StatelessWidget {
  const FeedbackToneSetting({
    super.key,
    required this.value,
    required this.onChanged,
    this.isSaving = false,
  });

  final String value;
  final ValueChanged<String> onChanged;

  /// True khi đang lưu — disable tap để tránh double-submit.
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in kFeedbackToneOptions) ...[
          _buildOptionTile(option, isDark),
          if (option != kFeedbackToneOptions.last)
            const SizedBox(height: DesignSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildOptionTile(FeedbackToneOption option, bool isDark) {
    final selected = option.value == value;
    final accent = DesignColors.primary;
    final borderColor = selected
        ? accent
        : (isDark ? Colors.grey[700]! : Colors.grey[300]!);

    return InkWell(
      key: ValueKey('feedback_tone_${option.value}'),
      onTap: isSaving ? null : () => onChanged(option.value),
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.08)
              : (isDark ? Colors.grey[850] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: DesignIcons.mdSize,
              color: selected
                  ? accent
                  : (isDark ? Colors.grey[400] : DesignColors.textSecondary),
            ),
            const SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? accent
                          : (isDark
                              ? Colors.white
                              : DesignColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark
                          ? Colors.grey[400]
                          : DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: DesignIcons.mdSize,
              color: selected
                  ? accent
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

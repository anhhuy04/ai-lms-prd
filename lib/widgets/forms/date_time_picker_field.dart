import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Date picker field với label
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onClear;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onClear,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTypography.labelSmallSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ).copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: DesignColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && onDateSelected != null) {
              onDateSelected!(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    initialDate != null
                        ? '${initialDate!.year}-${initialDate!.month.toString().padLeft(2, '0')}-${initialDate!.day.toString().padLeft(2, '0')}'
                        : 'Chọn ngày',
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: initialDate != null
                          ? (isDark ? Colors.white : DesignColors.textPrimary)
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ),
                ),
                if (initialDate != null && onClear != null)
                  GestureDetector(
                    onTap: () {
                      onClear!();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                if (initialDate != null && onClear != null)
                  const SizedBox(width: 4),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Time picker field với label
class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final VoidCallback? onClear;
  final String? Function(TimeOfDay?)? validator;

  const TimePickerField({
    super.key,
    required this.label,
    this.initialTime,
    this.onTimeSelected,
    this.onClear,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTypography.labelSmallSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ).copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: initialTime ?? const TimeOfDay(hour: 23, minute: 59),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: DesignColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && onTimeSelected != null) {
              onTimeSelected!(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    initialTime != null
                        ? initialTime!.format(context)
                        : 'Chọn giờ',
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: initialTime != null
                          ? (isDark ? Colors.white : DesignColors.textPrimary)
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ),
                ),
                if (initialTime != null && onClear != null)
                  GestureDetector(
                    onTap: () {
                      onClear!();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                if (initialTime != null && onClear != null)
                  const SizedBox(width: 4),
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

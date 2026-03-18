import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';

enum AnalyticsTimeRange {
  week('Week', 7),
  month('Month', 30),
  semester('Semester', 120),
  all('All Time', null);

  final String label;
  final int? days;
  const AnalyticsTimeRange(this.label, this.days);
}

class TimeRangeSelector extends StatelessWidget {
  final AnalyticsTimeRange selected;
  final ValueChanged<AnalyticsTimeRange> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsTimeRange.values.map((range) {
          final isSelected = range == selected;
          return Padding(
            padding: EdgeInsets.only(right: DesignSpacing.sm),
            child: ChoiceChip(
              label: Text(range.label),
              selected: isSelected,
              onSelected: (_) => onChanged(range),
              selectedColor: DesignColors.primary,
              labelStyle: DesignTypography.labelMedium.copyWith(
                color: isSelected ? DesignColors.white : DesignColors.textPrimary,
              ),
              backgroundColor: DesignColors.white,
              side: BorderSide(
                color: isSelected ? DesignColors.primary : DesignColors.dividerLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:flutter/material.dart';

/// Filter chips cho submission list
class SubmissionFilterChips extends StatelessWidget {
  final SubmissionFilter currentFilter;
  final ValueChanged<SubmissionFilter> onFilterChanged;

  const SubmissionFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: SubmissionFilter.values.map((filter) {
            final isSelected = filter == currentFilter;
            return Padding(
              padding: const EdgeInsets.only(right: DesignSpacing.sm),
              child: FilterChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (_) => onFilterChanged(filter),
                backgroundColor: const Color(0xFFF5F5F5),
                selectedColor: DesignColors.primary.withValues(alpha: 0.2),
                checkmarkColor: DesignColors.primary,
                labelStyle: DesignTypography.labelMedium?.copyWith(
                  color: isSelected ? DesignColors.primary : const Color(0xFF616161),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

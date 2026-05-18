// lib/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

enum SourceChipFilter { all, mine, aiGenerated, global }

class QuestionSourceChipBar extends StatelessWidget {
  final SourceChipFilter selected;
  final ValueChanged<SourceChipFilter> onChanged;
  final Map<SourceChipFilter, int>? counts;

  const QuestionSourceChipBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        children: SourceChipFilter.values.map((f) {
          final isSelected = f == selected;
          final count = counts?[f];
          final label = count != null ? '${_label(f)} ($count)' : _label(f);
          return Padding(
            padding: EdgeInsets.only(right: DesignSpacing.xs),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(SourceChipFilter f) => switch (f) {
    SourceChipFilter.all => 'Tất cả',
    SourceChipFilter.mine => 'Của tôi',
    SourceChipFilter.aiGenerated => 'AI tạo',
    SourceChipFilter.global => 'Toàn cầu',
  };
}

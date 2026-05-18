import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';

/// Bottom sheet chọn tiêu chí sắp xếp danh sách câu hỏi trong Question Bank.
class QuestionSortBottomSheet extends StatelessWidget {
  final QuestionSortKey current;

  const QuestionSortBottomSheet({super.key, required this.current});

  static Future<QuestionSortKey?> show(
    BuildContext context,
    QuestionSortKey current,
  ) {
    return showModalBottomSheet<QuestionSortKey>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestionSortBottomSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: DesignSpacing.md),
              const Text(
                'Sắp xếp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DesignSpacing.md),
              ...QuestionSortKey.values.map(
                (k) => RadioListTile<QuestionSortKey>(
                  title: Text(_label(k)),
                  value: k,
                  groupValue: current,
                  onChanged: (v) {
                    if (v != null) Navigator.of(context).pop(v);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(QuestionSortKey k) => switch (k) {
        QuestionSortKey.recentlyCreated => 'Mới nhất',
        QuestionSortKey.difficulty => 'Độ khó',
        QuestionSortKey.type => 'Loại câu hỏi',
        QuestionSortKey.totalAttempts => 'Lượt làm',
      };
}

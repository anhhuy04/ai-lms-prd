import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question_type.dart';

/// Value object cho bộ lọc câu hỏi nâng cao trong Question Bank.
class QuestionFilterValue {
  final QuestionType? type;
  final int? difficulty;
  final List<String> tags;

  const QuestionFilterValue({
    this.type,
    this.difficulty,
    this.tags = const [],
  });

  QuestionFilterValue copyWith({
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    bool clearType = false,
    bool clearDifficulty = false,
  }) =>
      QuestionFilterValue(
        type: clearType ? null : (type ?? this.type),
        difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
        tags: tags ?? this.tags,
      );
}

class QuestionFilterBottomSheet extends StatefulWidget {
  final QuestionFilterValue initial;

  const QuestionFilterBottomSheet({super.key, required this.initial});

  static Future<QuestionFilterValue?> show(
    BuildContext context,
    QuestionFilterValue initial,
  ) {
    return showModalBottomSheet<QuestionFilterValue>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestionFilterBottomSheet(initial: initial),
    );
  }

  @override
  State<QuestionFilterBottomSheet> createState() =>
      _QuestionFilterBottomSheetState();
}

class _QuestionFilterBottomSheetState extends State<QuestionFilterBottomSheet> {
  late QuestionFilterValue _value;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DesignSpacing.md),
              const Text(
                'Bộ lọc câu hỏi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DesignSpacing.lg),

              // Loại câu hỏi
              Text('Loại câu hỏi', style: DesignTypography.titleSmall),
              const SizedBox(height: DesignSpacing.sm),
              Wrap(
                spacing: DesignSpacing.xs,
                runSpacing: DesignSpacing.xs,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _value.type == null,
                    onSelected: (_) => setState(
                      () => _value = _value.copyWith(clearType: true),
                    ),
                  ),
                  ...QuestionType.values.map(
                    (t) => ChoiceChip(
                      label: Text(t.label),
                      selected: _value.type == t,
                      onSelected: (_) => setState(
                        () => _value = _value.copyWith(type: t),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.lg),

              // Độ khó
              Text('Độ khó', style: DesignTypography.titleSmall),
              const SizedBox(height: DesignSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: (_value.difficulty ?? 0).toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _value.difficulty == null
                          ? 'Bất kỳ'
                          : '${_value.difficulty}',
                      onChanged: (v) => setState(() {
                        _value = _value.copyWith(
                          difficulty: v == 0 ? null : v.toInt(),
                          clearDifficulty: v == 0,
                        );
                      }),
                    ),
                  ),
                  Text(
                    _value.difficulty == null ? 'Bất kỳ' : '${_value.difficulty}/5',
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.lg),

              // Tags
              Text('Tags', style: DesignTypography.titleSmall),
              const SizedBox(height: DesignSpacing.sm),
              Wrap(
                spacing: DesignSpacing.xs,
                runSpacing: DesignSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ..._value.tags.map(
                    (t) => Chip(
                      label: Text('#$t'),
                      onDeleted: () => setState(() {
                        _value = _value.copyWith(
                          tags: _value.tags.where((x) => x != t).toList(),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Thêm tag...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (v) {
                        final tag = v.trim();
                        if (tag.isEmpty) return;
                        setState(() {
                          _value = _value.copyWith(
                            tags: [..._value.tags, tag],
                          );
                          _tagController.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                        () => _value = const QuestionFilterValue(),
                      ),
                      child: const Text('Đặt lại'),
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_value),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

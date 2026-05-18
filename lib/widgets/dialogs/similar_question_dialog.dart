// lib/widgets/dialogs/similar_question_dialog.dart
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';

enum SimilarQuestionAction { useExisting, createAnyway, cancel }

class SimilarQuestionDialog extends StatelessWidget {
  final Question similar;

  const SimilarQuestionDialog({super.key, required this.similar});

  /// Show dialog với câu hỏi tương tự đã tồn tại trong kho.
  /// Trả về action user chọn (useExisting / createAnyway / cancel).
  static Future<SimilarQuestionAction> show(
    BuildContext context,
    Question similar,
  ) async {
    final result = await showDialog<SimilarQuestionAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SimilarQuestionDialog(similar: similar),
    );
    return result ?? SimilarQuestionAction.cancel;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _extractPreview(similar.content);
    final truncated =
        preview.length > 240 ? '${preview.substring(0, 240)}…' : preview;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: DesignColors.warning),
          SizedBox(width: DesignSpacing.sm),
          const Expanded(child: Text('Câu hỏi tương tự đã có')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trong kho của bạn đã có câu hỏi với nội dung tương tự:'),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Text(
              truncated.isEmpty ? '(Chưa có nội dung)' : truncated,
              style: DesignTypography.bodySmall,
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Bạn muốn dùng lại câu hỏi cũ hay vẫn tạo bản mới?',
            style: DesignTypography.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(SimilarQuestionAction.cancel),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(SimilarQuestionAction.createAnyway),
          child: const Text('Vẫn tạo mới'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(SimilarQuestionAction.useExisting),
          child: const Text('Dùng câu cũ'),
        ),
      ],
    );
  }

  String _extractPreview(Map<String, dynamic> content) {
    if (content['ops'] is List) {
      return (content['ops'] as List)
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join()
          .replaceAll('\n', ' ')
          .trim();
    }
    if (content['text'] is String) {
      return (content['text'] as String).replaceAll('\n', ' ').trim();
    }
    return '';
  }
}

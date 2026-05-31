import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_notifier.dart';

class TeacherQuestionTrashScreen extends ConsumerWidget {
  const TeacherQuestionTrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    final filter = QuestionFilter(
      authorId: userId,
      includeGlobal: false,
      includeDeleted: true,
      pageSize: 100,
    );
    final stateAsync = ref.watch(questionBankNotifierProvider(filter: filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thùng rác'),
      ),
      body: stateAsync.when(
        data: (s) {
          if (s.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 64, color: Colors.grey),
                    SizedBox(height: DesignSpacing.md),
                    const Text('Thùng rác trống'),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      'Câu hỏi đã xóa sẽ giữ ở đây 30 ngày.',
                      style: DesignTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: s.questions.length,
            itemBuilder: (_, i) => _TrashItem(
              question: s.questions[i],
              onRestore: () async {
                try {
                  await ref
                      .read(questionBankNotifierProvider(filter: filter)
                          .notifier)
                      .restore(s.questions[i].id);
                  if (!context.mounted) return;
                  AppToast.info(context, 'Đã khôi phục câu hỏi');
                } catch (e) {
                  if (!context.mounted) return;
                  AppToast.error(context, 'Lỗi: $e');
                }
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _TrashItem extends StatelessWidget {
  final Question question;
  final VoidCallback onRestore;

  const _TrashItem({required this.question, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final preview = _extractPreview(question.content);
    final truncated =
        preview.length > 120 ? '${preview.substring(0, 120)}…' : preview;
    final daysAgo = question.deletedAt == null
        ? '?'
        : DateTime.now().difference(question.deletedAt!).inDays.toString();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      child: ListTile(
        title: Text(
          truncated.isEmpty ? '(Chưa có nội dung)' : truncated,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Đã xóa $daysAgo ngày trước',
          style: DesignTypography.bodySmall,
        ),
        trailing: TextButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.restore),
          label: const Text('Khôi phục'),
        ),
      ),
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

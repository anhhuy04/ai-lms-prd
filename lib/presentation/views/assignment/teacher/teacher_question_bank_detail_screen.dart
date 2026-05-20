import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/providers/question_stats_provider.dart';
import 'package:ai_mls/presentation/providers/question_usage_provider.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_question_bank_detail_screen.g.dart';

@riverpod
Future<QuestionDetail?> _questionDetail(Ref ref, String id) {
  final repo = ref.watch(questionRepositoryProvider);
  return GetQuestionDetailUseCase(repo).call(id);
}

class TeacherQuestionBankDetailScreen extends ConsumerWidget {
  final String questionId;
  const TeacherQuestionBankDetailScreen({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_questionDetailProvider(questionId));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết câu hỏi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Xem trước'),
              Tab(text: 'Thống kê'),
              Tab(text: 'Lịch sử dùng'),
            ],
          ),
        ),
        body: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return const Center(child: Text('Không tìm thấy câu hỏi.'));
            }
            return TabBarView(
              children: [
                _PreviewTab(detail: detail),
                _StatsTab(questionId: questionId),
                _UsageTab(questionId: questionId),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
        ),
        bottomNavigationBar: detailAsync.maybeWhen(
          data: (detail) =>
              detail == null ? null : _ActionBar(question: detail.question),
          orElse: () => null,
        ),
      ),
    );
  }
}

class _PreviewTab extends StatelessWidget {
  final QuestionDetail detail;
  const _PreviewTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final q = detail.question;
    final text = _extractText(q.content);
    // Explanation lives in content.explanation (cùng convention với
    // teacher_create_question_screen). Fallback sang answer.* để chịu
    // cả format AI cũ.
    final explanation = (q.content['explanation'] as String?) ??
        (q.answer?['explanation'] as String?) ??
        (q.answer?['general_explanation'] as String?) ??
        '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(question: q),
          SizedBox(height: DesignSpacing.md),
          const Divider(),
          SizedBox(height: DesignSpacing.md),
          _RawAndRendered(
            label: 'Đề bài',
            text: text.isEmpty ? '(Không có nội dung)' : text,
            style: DesignTypography.bodyLarge,
          ),
          if (detail.choices.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.lg),
            ...detail.choices.map((c) => _ChoiceRow(choice: c)),
          ],
          if (explanation.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.lg),
            Text('Giải thích:', style: DesignTypography.titleSmall),
            SizedBox(height: DesignSpacing.xs),
            _RawAndRendered(
              label: 'Giải thích',
              text: explanation,
              style: DesignTypography.bodyMedium,
              showLabel: false,
            ),
          ],
          if (q.tags.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.lg),
            Wrap(
              spacing: DesignSpacing.xs,
              children: q.tags.map((t) => Chip(label: Text('#$t'))).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _extractText(Map<String, dynamic> content) {
    if (content['ops'] is List) {
      return (content['ops'] as List)
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join();
    }
    if (content['text'] is String) return content['text'] as String;
    if (content['override_text'] is String) {
      return content['override_text'] as String;
    }
    return '';
  }
}

/// Hiển thị 2 cột: raw text (trái) + LaTeX rendered (phải) để giáo viên
/// thấy ngay công thức `$...$` render ra ra sao. Trên mobile (hẹp) sẽ
/// fallback sang xếp dọc.
class _RawAndRendered extends StatelessWidget {
  final String label;
  final String text;
  final TextStyle? style;
  final bool showLabel;

  const _RawAndRendered({
    required this.label,
    required this.text,
    this.style,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 480;
        final raw = _Column(
          title: 'Văn bản gốc',
          show: showLabel,
          child: SelectableText(text, style: style),
        );
        final rendered = _Column(
          title: 'Hiển thị (LaTeX)',
          show: showLabel,
          child: MathText(text, style: style),
        );
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              raw,
              SizedBox(height: DesignSpacing.sm),
              rendered,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: raw),
            SizedBox(width: DesignSpacing.md),
            Expanded(child: rendered),
          ],
        );
      },
    );
  }
}

class _Column extends StatelessWidget {
  final String title;
  final Widget child;
  final bool show;
  const _Column({required this.title, required this.child, this.show = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (show)
          Padding(
            padding: EdgeInsets.only(bottom: DesignSpacing.xs),
            child: Text(
              title,
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Question question;
  const _MetaRow({required this.question});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.xs,
      children: [
        Chip(
          label: Text(question.type.label),
          backgroundColor: question.type.color.withValues(alpha: 0.15),
        ),
        if (question.difficulty != null)
          Chip(label: Text('★ ${question.difficulty}')),
        Chip(label: Text('Nguồn: ${_sourceLabel(question.source)}')),
        if (question.isGlobal) const Chip(label: Text('🌐 Toàn cầu')),
      ],
    );
  }

  String _sourceLabel(String s) => switch (s) {
    'teacher' => 'Giáo viên',
    'ai_generated' => 'AI',
    'library' => 'Thư viện',
    'imported' => 'Nhập từ ngoài',
    'system' => 'Hệ thống',
    'admin' => 'Quản trị',
    _ => s,
  };
}

class _ChoiceRow extends StatelessWidget {
  final QuestionChoice choice;
  const _ChoiceRow({required this.choice});

  @override
  Widget build(BuildContext context) {
    final text = choice.content['text'] as String? ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.xs),
      padding: EdgeInsets.all(DesignSpacing.sm),
      decoration: BoxDecoration(
        color: choice.isCorrect
            ? DesignColors.success.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: choice.isCorrect
              ? DesignColors.success
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            choice.isCorrect
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: choice.isCorrect ? DesignColors.success : Colors.grey,
            size: 20,
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final isNarrow = c.maxWidth < 360;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(text),
                      SizedBox(height: DesignSpacing.xs),
                      MathText(text),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SelectableText(text)),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(child: MathText(text)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends ConsumerWidget {
  final String questionId;
  const _StatsTab({required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(questionStatsProvider(questionId));
    return statsAsync.when(
      data: (stats) {
        if (stats.totalAttempts == 0) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: DesignSpacing.md),
                  const Text('Câu hỏi chưa được dùng — chưa có thống kê'),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            mainAxisSpacing: DesignSpacing.md,
            crossAxisSpacing: DesignSpacing.md,
            children: [
              _StatCard(
                label: 'Lượt làm',
                value: '${stats.totalAttempts}',
                icon: Icons.bar_chart,
              ),
              _StatCard(
                label: 'Đúng',
                value: '${stats.correctCount}',
                icon: Icons.check_circle,
                color: DesignColors.success,
              ),
              _StatCard(
                label: 'Tỉ lệ đúng',
                value: '${(stats.correctRate * 100).toStringAsFixed(1)}%',
                icon: Icons.percent,
                color: stats.correctRate >= 0.5
                    ? DesignColors.success
                    : DesignColors.warning,
              ),
              _StatCard(
                label: 'Cập nhật gần nhất',
                value: stats.lastAttempted == null
                    ? '—'
                    : _formatDate(stats.lastAttempted!),
                icon: Icons.update,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? DesignColors.primary;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 24),
            SizedBox(height: DesignSpacing.xs),
            Text(label, style: DesignTypography.bodySmall),
            const SizedBox(height: 2),
            Text(
              value,
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageTab extends ConsumerWidget {
  final String questionId;
  const _UsageTab({required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(questionUsageProvider(questionId));
    return usageAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Text(
                    'Chưa có bài tập nào dùng câu hỏi này',
                    style: DesignTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(questionUsageProvider(questionId)),
          child: ListView.separated(
            padding: EdgeInsets.all(DesignSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: DesignSpacing.sm),
            itemBuilder: (_, i) => _UsageItemTile(item: items[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Text('Lỗi tải lịch sử: $e'),
        ),
      ),
    );
  }
}

class _UsageItemTile extends StatelessWidget {
  final QuestionUsageItem item;
  const _UsageItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isPublished
        ? DesignColors.success
        : DesignColors.warning;
    final statusLabel = item.isPublished ? 'Đã phát hành' : 'Bản nháp';
    final dateLabel = item.publishedAt != null
        ? 'Phát hành ${_formatDate(item.publishedAt!)}'
        : item.createdAt != null
        ? 'Tạo ${_formatDate(item.createdAt!)}'
        : '';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mở "${item.title}" — wire sau')),
          );
        },
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  item.isPublished
                      ? Icons.public
                      : Icons.edit_note_outlined,
                  color: color,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: DesignTypography.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    if (item.className != null && item.className!.isNotEmpty)
                      Text(
                        'Lớp: ${item.className}',
                        style: DesignTypography.bodySmall,
                      ),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Text(
                  statusLabel,
                  style: DesignTypography.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _ActionBar extends ConsumerStatefulWidget {
  final Question question;
  const _ActionBar({required this.question});

  @override
  ConsumerState<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends ConsumerState<_ActionBar> {
  bool _isDuplicating = false;

  Question get question => widget.question;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isDuplicating ? null : _duplicateQuestion,
                icon: _isDuplicating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.copy_outlined),
                label: const Text('Sao chép'),
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sửa — wire Phase 6')),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Sửa'),
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.error,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sao chép câu hỏi: tạo bản sao mới với cùng content/choices/tags/...
  /// nhưng đặt author = user hiện tại, isGlobal = false, source = teacher.
  /// Trả về snackbar success/error và mời user mở câu mới.
  Future<void> _duplicateQuestion() async {
    if (_isDuplicating) return;
    setState(() => _isDuplicating = true);
    try {
      final repo = ref.read(questionRepositoryProvider);
      // Fetch choices của câu gốc (cần raw shape cho CreateQuestionParams).
      final choices = await repo.getChoicesByQuestionId(question.id);
      final choicesRaw = ([...choices]..sort((a, b) => a.id.compareTo(b.id)))
          .asMap()
          .entries
          .map((e) => <String, dynamic>{
                'id': e.key, // re-index 0..n
                'content': Map<String, dynamic>.from(e.value.content),
                'is_correct': e.value.isCorrect,
              })
          .toList();

      // Clone content + answer (deep enough for shallow JSON maps).
      // Append " (Bản sao)" suffix để content_hash khác bản gốc,
      // tránh va UNIQUE constraint idx_questions_author_hash_unique.
      final content = Map<String, dynamic>.from(question.content);
      if (content['text'] is String) {
        content['text'] = '${content['text']} (Bản sao)';
      } else if (content['ops'] is List) {
        final ops = List<Map<String, dynamic>>.from(
          (content['ops'] as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
        ops.add({'insert': ' (Bản sao)'});
        content['ops'] = ops;
      } else {
        // Fallback: gắn marker tối thiểu để hash khác.
        content['_dup_marker'] = DateTime.now().millisecondsSinceEpoch;
      }
      final answer = question.answer == null
          ? null
          : Map<String, dynamic>.from(question.answer!);

      final params = CreateQuestionParams(
        type: question.type,
        content: content,
        source: QuestionSource.teacher,
        answer: answer,
        defaultPoints: question.defaultPoints,
        difficulty: question.difficulty,
        tags: List<String>.from(question.tags),
        isGlobal: false,
        objectiveIds: const <String>[],
        choices: choicesRaw,
      );

      final created = await repo.createQuestion(params);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã tạo bản sao câu hỏi'),
          action: SnackBarAction(
            label: 'Mở',
            onPressed: () {
              context.pushReplacement(
                AppRoute.teacherQuestionBankDetailPath(created.id),
              );
            },
          ),
        ),
      );
    } on DuplicateContentDetected catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Bản sao có nội dung trùng. Hãy chỉnh sửa bản sao trước khi lưu.',
          ),
          backgroundColor: DesignColors.warning,
        ),
      );
    } on QuestionFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.userMessage),
          backgroundColor: DesignColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi sao chép: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDuplicating = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa câu hỏi?'),
        content: const Text('Câu hỏi sẽ vào "Thùng rác".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(questionRepositoryProvider)
          .softDeleteQuestion(question.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa câu hỏi')));
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: DesignColors.error),
      );
    }
  }
}

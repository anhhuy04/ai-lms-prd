import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/question_bank/slidable_card_wrapper.dart';
import 'package:ai_mls/widgets/text/math_text.dart';

/// Family provider — list assignments của 1 teacher. Cho phép invalidate
/// sau khi xoá bài tập trong slidable action.
final teacherAssignmentsProvider =
    FutureProvider.family<List<Assignment>, String>((ref, teacherId) {
  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.getAssignmentsByTeacher(teacherId);
});

/// "Tệp bài tập" tab — list các Assignment do teacher tạo, mỗi assignment là
/// ExpansionTile sổ xuống các câu hỏi bên trong. Tap câu hỏi → navigate sang
/// trang chi tiết câu hỏi (chỉ hoạt động với câu thuộc question bank, tức
/// `questionId != null`).
class AssignmentFolderList extends ConsumerWidget {
  final String teacherId;
  final String searchQuery;

  const AssignmentFolderList({
    super.key,
    required this.teacherId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync =
        ref.watch(teacherAssignmentsProvider(teacherId));
    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Text(
            'Lỗi tải bài tập: $e',
            style: TextStyle(color: DesignColors.error),
          ),
        ),
      ),
      data: (all) {
        // Filter theo search (title + description, case-insensitive)
        var list = all;
        if (searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          list = list
              .where((a) =>
                  a.title.toLowerCase().contains(q) ||
                  (a.description?.toLowerCase().contains(q) ?? false))
              .toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Text(
                    searchQuery.trim().isEmpty
                        ? 'Chưa có bài tập nào'
                        : 'Không tìm thấy bài tập phù hợp',
                    style: DesignTypography.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        return SlidableAutoCloseBehavior(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final ratio = computeSlidableRatio(constraints.maxWidth);
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  DesignSpacing.md,
                  DesignSpacing.sm,
                  DesignSpacing.md,
                  DesignSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => SizedBox(height: DesignSpacing.sm),
                itemBuilder: (_, i) => _AssignmentTile(
                  assignment: list[i],
                  extentRatio: ratio,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AssignmentTile extends ConsumerWidget {
  final Assignment assignment;
  final double extentRatio;
  const _AssignmentTile({
    required this.assignment,
    required this.extentRatio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor =
        assignment.isPublished ? DesignColors.success : DesignColors.warning;
    final statusLabel =
        assignment.isPublished ? 'Đã phát hành' : 'Bản nháp';

    return SlidableCardWrapper(
      slidableKey: ValueKey('assignment_${assignment.id}'),
      groupTag: 'assignment_folder',
      borderRadius: DesignRadius.lg,
      margin: EdgeInsets.zero,
      extentRatio: extentRatio,
      actions: [
        CompactSlidableAction(
          onPressed: () => context.pushNamed(
            AppRoute.teacherEditAssignment,
            pathParameters: {'assignmentId': assignment.id},
          ),
          bg: DesignColors.primary,
          icon: Icons.folder_open_rounded,
          label: 'Mở tập',
        ),
        CompactSlidableAction(
          onPressed: () => _confirmDeleteAssignment(context, ref),
          bg: DesignColors.error,
          icon: Icons.delete_rounded,
          label: 'Xoá',
        ),
      ],
      child: _buildBody(context, isDark, statusColor, statusLabel, ref),
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    Color statusColor,
    String statusLabel,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: 4,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: DesignColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            assignment.title,
            style: DesignTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (assignment.createdAt != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(assignment.createdAt!),
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          children: [
            FutureBuilder<List<AssignmentQuestion>>(
              future: ref
                  .read(assignmentRepositoryProvider)
                  .getAssignmentQuestions(assignment.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Lỗi: ${snapshot.error}',
                      style: TextStyle(color: DesignColors.error),
                    ),
                  );
                }
                final questions = (snapshot.data ?? []).toList()
                  ..sort((a, b) => a.orderIdx.compareTo(b.orderIdx));
                if (questions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Bài tập chưa có câu hỏi nào',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
                return Column(
                  children: List.generate(
                    questions.length,
                    (i) => _AssignmentQuestionRow(
                      aq: questions[i],
                      displayOrder: i + 1, // 1-based theo vị trí trong list
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _confirmDeleteAssignment(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final isPublished = assignment.isPublished;
    final accent =
        isPublished ? DesignColors.warning : DesignColors.error;
    final title =
        isPublished ? 'Xoá bài tập đã phát hành?' : 'Xoá bài tập?';
    final icon = isPublished
        ? Icons.warning_amber_rounded
        : Icons.delete_forever_rounded;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 28),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPublished
                        ? Icons.shield_outlined
                        : Icons.delete_outline_rounded,
                    size: 14,
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPublished
                        ? 'Đã giao học sinh — cẩn trọng'
                        : 'Bài tập nháp — an toàn xoá',
                    style: DesignTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"${assignment.title}"',
              style: DesignTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPublished
                  ? 'Bài tập này đã được phát hành. Xoá sẽ ảnh hưởng đến '
                      'học sinh đã/đang làm bài. Hãy chắc chắn bạn đã sao '
                      'lưu dữ liệu cần thiết.'
                  : 'Bài tập sẽ bị xoá vĩnh viễn cùng với các câu hỏi tuỳ '
                      'chỉnh bên trong. Hành động không thể hoàn tác.',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: accent),
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref
          .read(assignmentRepositoryProvider)
          .deleteAssignment(assignment.id);
      if (!context.mounted) return;
      AppToast.info(context, 'Đã xoá bài tập "${assignment.title}"');
      // Trigger refresh — invalidate provider list ở parent.
      ref.invalidate(teacherAssignmentsProvider);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.error(context, 'Lỗi xoá bài tập: $e');
    }
  }
}

class _AssignmentQuestionRow extends ConsumerWidget {
  final AssignmentQuestion aq;
  final int displayOrder;
  const _AssignmentQuestionRow({
    required this.aq,
    required this.displayOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = aq.questionId;
    final orderLabel = '$displayOrder';

    // Câu hỏi tùy chỉnh — không có entry trong bank, chỉ mở sheet xem.
    if (qid == null) {
      final preview = _previewText(aq.customContent);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        leading: _orderCircle(orderLabel, DesignColors.primary),
        title: Text(
          preview,
          style: DesignTypography.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: DesignColors.textSecondary,
        ),
        onTap: () => _showCustomQuestionSheet(context, displayOrder, aq),
      );
    }

    // Câu hỏi từ bank → fetch preview + tap navigate.
    return FutureBuilder(
      future: ref.read(questionRepositoryProvider).getQuestionById(qid),
      builder: (context, snapshot) {
        final q = snapshot.data;
        final preview = _previewText(q?.content);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          leading: _orderCircle(orderLabel, DesignColors.primary),
          title: Text(
            preview,
            style: DesignTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: DesignColors.textSecondary,
          ),
          onTap: () => context.pushNamed(
            AppRoute.teacherQuestionBankDetail,
            pathParameters: {'questionId': qid},
          ),
        );
      },
    );
  }

  void _showCustomQuestionSheet(
    BuildContext context,
    int order,
    AssignmentQuestion aq,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => _CustomQuestionSheet(
          order: order,
          aq: aq,
          scrollCtrl: scrollCtrl,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _orderCircle(String label, Color color, {bool faded = false}) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: faded ? 0.10 : 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  /// Lấy preview text từ question content (hỗ trợ ops/text/override_text).
  String _previewText(Map<String, dynamic>? content) {
    if (content == null) return 'Đang tải...';
    String text = '';
    if (content['ops'] is List) {
      text = (content['ops'] as List)
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join();
    } else if (content['text'] is String) {
      text = content['text'] as String;
    } else if (content['override_text'] is String) {
      text = content['override_text'] as String;
    }
    text = text.trim();
    if (text.isEmpty) return '(không có nội dung)';
    return text;
  }
}

/// Bottom sheet xem trước câu hỏi tùy chỉnh (không tồn tại trong bank).
/// READ-ONLY: chỉ render content + đáp án + giải thích, không cho sửa.
class _CustomQuestionSheet extends StatelessWidget {
  final int order;
  final AssignmentQuestion aq;
  final ScrollController scrollCtrl;
  final bool isDark;

  const _CustomQuestionSheet({
    required this.order,
    required this.aq,
    required this.scrollCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final content = aq.customContent ?? const <String, dynamic>{};
    final text = _extractText(content);
    final explanation = (content['explanation'] as String?) ?? '';
    final hints = (content['hints'] as List?)
            ?.whereType<String>()
            .where((h) => h.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    final choices = (content['choices'] as List?)
            ?.whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList() ??
        const <Map<String, dynamic>>[];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1923) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    '$order',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Xem trước câu hỏi $order',
                    style: DesignTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    'Chỉ xem',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.warning,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Body scrollable
          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(
                    icon: Icons.help_outline_rounded,
                    label: 'NỘI DUNG CÂU HỎI',
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    text.isEmpty ? '(Không có nội dung)' : text,
                    style: DesignTypography.bodyLarge.copyWith(
                      color: isDark
                          ? Colors.white
                          : DesignColors.textPrimary,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (choices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionLabel(
                      icon: Icons.radio_button_checked_rounded,
                      label: 'CÁC ĐÁP ÁN',
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(choices.length, (i) {
                      final c = choices[i];
                      final cText = (c['text'] as String?) ??
                          ((c['content'] as Map?)?['text'] as String?) ??
                          '';
                      final isCorrect =
                          c['isCorrect'] == true || c['is_correct'] == true;
                      final label = String.fromCharCode(65 + i);
                      return _choiceRow(
                        label: label,
                        text: cText,
                        isCorrect: isCorrect,
                      );
                    }),
                  ],
                  if (explanation.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionLabel(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'GIẢI THÍCH',
                      color: DesignColors.info,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DesignColors.info.withValues(alpha: 0.06),
                        borderRadius:
                            BorderRadius.circular(DesignRadius.lg),
                        border: Border.all(
                          color: DesignColors.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: MathText(
                        explanation,
                        style: DesignTypography.bodyMedium.copyWith(
                          color: isDark
                              ? Colors.grey[200]
                              : DesignColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (hints.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionLabel(
                      icon: Icons.tips_and_updates_outlined,
                      label: 'GỢI Ý',
                      color: DesignColors.warning,
                    ),
                    const SizedBox(height: 8),
                    ...hints.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key + 1}.',
                              style: DesignTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: DesignColors.warning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MathText(
                                e.value,
                                style: DesignTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? Colors.grey[200]
                                      : DesignColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final c = color ?? DesignColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, size: 14, color: c),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _choiceRow({
    required String label,
    required String text,
    required bool isCorrect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCorrect
              ? DesignColors.success.withValues(alpha: isDark ? 0.12 : 0.07)
              : (isDark ? const Color(0xFF1A2632) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: isCorrect
                ? DesignColors.success
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isCorrect ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCorrect
                    ? DesignColors.success
                    : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MathText(
                text.isEmpty ? '(trống)' : text,
                style: DesignTypography.bodyMedium.copyWith(
                  color: isCorrect
                      ? DesignColors.success
                      : (isDark
                          ? Colors.white
                          : DesignColors.textPrimary),
                  fontWeight:
                      isCorrect ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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

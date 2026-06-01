import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:ai_mls/presentation/providers/teacher_notes_provider.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/text/math_text.dart';

/// Khu vực "Ghi chú của giáo viên" trên màn hình phân tích học sinh.
/// Giáo viên có thể xem / thêm / sửa / xóa các ghi chú riêng tư về học sinh.
class TeacherNotesSection extends ConsumerWidget {
  final String studentId;

  const TeacherNotesSection({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(teacherNotesProvider(studentId: studentId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref),
        SizedBox(height: DesignSpacing.sm),
        notesAsync.when(
          loading: () => const ShimmerLoading(),
          error: (e, st) => _buildError(),
          data: (notes) => _buildList(context, ref, notes),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Ghi chú của giáo viên',
            style: DesignTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () => _showEditDialog(context, ref),
          icon: Icon(Icons.add, size: DesignIcons.smSize),
          label: const Text('Thêm ghi chú'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonMedium,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Center(
        child: Text(
          'Không thể tải ghi chú',
          style: DesignTypography.bodyMedium.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<TeacherNote> notes,
  ) {
    if (notes.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      children: [
        for (final note in notes) ...[
          _buildNoteCard(context, ref, note),
          SizedBox(height: DesignSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonMedium,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 40,
            color: DesignColors.textSecondary,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Chưa có ghi chú',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    WidgetRef ref,
    TeacherNote note,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MathText(
            note.content,
            style: DesignTypography.bodyMedium,
          ),
          SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              if (note.isPrivate) ...[
                _buildPrivateBadge(),
                SizedBox(width: DesignSpacing.sm),
              ],
              Expanded(
                child: Text(
                  _formatUpdatedAt(note.updatedAt),
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _showEditDialog(context, ref, note: note),
                icon: Icon(
                  Icons.edit_outlined,
                  size: DesignIcons.smSize,
                  color: DesignColors.textSecondary,
                ),
                tooltip: 'Sửa',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmDelete(context, ref, note),
                icon: Icon(
                  Icons.delete_outline,
                  size: DesignIcons.smSize,
                  color: DesignColors.error,
                ),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: DesignColors.tealAccent,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: DesignIcons.xsSize,
            color: DesignColors.tealDark,
          ),
          SizedBox(width: DesignSpacing.xs / 2),
          Text(
            'Riêng tư',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.tealDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUpdatedAt(DateTime updatedAt) {
    final local = updatedAt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return 'Cập nhật: $d/$m/$y $h:$min';
  }

  /// Mở dialog thêm (note == null) hoặc sửa (note != null) ghi chú.
  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    TeacherNote? note,
  }) async {
    final controller = TextEditingController(text: note?.content ?? '');
    var isPrivate = note?.isPrivate ?? true;
    final isEdit = note != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Sửa ghi chú' : 'Thêm ghi chú'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 5,
                    minLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhập nội dung ghi chú...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Ghi chú riêng tư',
                      style: DesignTypography.bodyMedium,
                    ),
                    value: isPrivate,
                    onChanged: (v) => setState(() => isPrivate = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(isEdit ? 'Lưu' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;
    final content = controller.text.trim();
    if (content.isEmpty) return;

    final notifier = ref.read(teacherNotesNotifierProvider.notifier);
    if (isEdit) {
      await notifier.updateNote(
        id: note.id,
        studentId: studentId,
        content: content,
        isPrivate: isPrivate,
      );
    } else {
      await notifier.addNote(
        studentId: studentId,
        content: content,
        isPrivate: isPrivate,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TeacherNote note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc muốn xóa ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(teacherNotesNotifierProvider.notifier).deleteNote(
          id: note.id,
          studentId: studentId,
        );
  }
}

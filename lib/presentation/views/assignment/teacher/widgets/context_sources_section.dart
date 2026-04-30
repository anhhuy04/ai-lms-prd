import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/data/models/local_temp_file.dart';
import 'package:ai_mls/presentation/providers/local_temp_file_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget hiển thị phần "Nguồn Dữ Liệu Tham Khảo" trong màn hình tạo câu hỏi AI.
///
/// - Hiển thị danh sách tài liệu local (in-memory) dưới dạng FilterChip selectable
/// - [+] Thêm tài liệu ActionChip để pick file và extract text locally
/// - Callback `onSelectionChanged` thông báo cho parent về danh sách file được chọn
/// - Long-press chip → menu xóa file
/// - T3-3: Badge role (📋 Mẫu / 📚 Kiến thức) có thể tap để toggle — chỉ với file có parsedQuestions
class ContextSourcesSection extends ConsumerStatefulWidget {
  const ContextSourcesSection({
    super.key,
    required this.onSelectionChanged,
  });

  final void Function(List<String> fileIds) onSelectionChanged;

  @override
  ConsumerState<ContextSourcesSection> createState() =>
      _ContextSourcesSectionState();
}

class _ContextSourcesSectionState
    extends ConsumerState<ContextSourcesSection> {
  final Set<String> _selectedFileIds = {};

  void _toggleFile(String fileId) {
    setState(() {
      if (_selectedFileIds.contains(fileId)) {
        _selectedFileIds.remove(fileId);
      } else {
        _selectedFileIds.add(fileId);
      }
    });
    widget.onSelectionChanged(_selectedFileIds.toList());
  }

  /// T3-3: Toggle role template ↔ knowledgeSource.
  void _toggleFileRole(LocalTempFile file) {
    final hasQuestions = file.parsedQuestions?.isNotEmpty == true;
    final current = file.fileRole ?? (hasQuestions ? FileRole.template : FileRole.knowledgeSource);
    final next = current == FileRole.template ? FileRole.knowledgeSource : FileRole.template;
    ref.read(localTempFilesProvider.notifier).updateFileRole(file.id, next);
  }

  /// Long-press → dialog để xóa file (tách khỏi role toggle).
  void _showFileMenu(LocalTempFile file) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          file.filename,
          style: DesignTypography.bodySmall.copyWith(color: DesignColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              if (_selectedFileIds.contains(file.id)) {
                setState(() => _selectedFileIds.remove(file.id));
                widget.onSelectionChanged(_selectedFileIds.toList());
              }
              ref.read(localTempFilesProvider.notifier).removeFile(file.id);
            },
            child: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text('Xóa file', style: DesignTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddLocalFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'docx', 'pdf'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final newIds = <String>[];
    for (final file in result.files) {
      final Uint8List? bytes = file.bytes;
      if (bytes == null) continue;
      final ext = file.extension?.toLowerCase();
      final String mimeType;
      if (ext == 'xlsx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (ext == 'docx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else {
        continue;
      }
      final newId = await ref
          .read(localTempFilesProvider.notifier)
          .addFile(bytes, file.name, mimeType);
      newIds.add(newId);
    }

    if (mounted && newIds.isNotEmpty) {
      setState(() => _selectedFileIds.addAll(newIds));
      widget.onSelectionChanged(_selectedFileIds.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final files = ref.watch(localTempFilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📚 Nguồn Dữ Liệu Tham Khảo',
          style: DesignTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        _buildChipWrap(files),
      ],
    );
  }

  Widget _buildChipWrap(List<LocalTempFile> files) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: [
        ...files.map((file) => _buildFileChip(file)),
        _buildAddChip(),
      ],
    );
  }

  Widget _buildFileChip(LocalTempFile file) {
    final isSelected = _selectedFileIds.contains(file.id);
    final label = file.filename.length > 20
        ? '${file.filename.substring(0, 20)}…'
        : file.filename;

    final hasQuestions = file.parsedQuestions?.isNotEmpty == true;
    final hasText = file.extractedText?.isNotEmpty == true;
    final isExcel = file.mimeType.contains('spreadsheetml') || file.filename.toLowerCase().endsWith('.xlsx');
    final isPdf = file.mimeType.contains('pdf') || file.filename.toLowerCase().endsWith('.pdf');
    final isUnreadable = !file.isExtracting && !hasQuestions && !hasText;

    // T3-3: effective role (auto-detect nếu null)
    final effectiveRole = file.fileRole ?? (hasQuestions ? FileRole.template : FileRole.knowledgeSource);

    Widget? avatar;
    if (file.isExtracting) {
      avatar = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (hasQuestions && isExcel) {
      // Excel template
      avatar = const Icon(Icons.table_chart_rounded, size: 16, color: DesignColors.success);
    } else if (hasQuestions && !isExcel) {
      // Docx/PDF template (T3-2 parsed)
      avatar = const Icon(Icons.article_rounded, size: 16, color: DesignColors.success);
    } else if (isPdf && hasText) {
      avatar = const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Color(0xFFE53935));
    } else if (hasText) {
      // Word raw text — dùng AI
      avatar = const Icon(Icons.auto_awesome_rounded, size: 16, color: DesignColors.primary);
    } else if (isUnreadable) {
      avatar = const Icon(Icons.warning_amber_rounded, size: 16, color: DesignColors.warning);
    }

    final chip = GestureDetector(
      onLongPress: () => _showFileMenu(file),
      child: FilterChip(
        label: Text(label),
        selected: isSelected && !file.isExtracting,
        avatar: avatar,
        selectedColor: DesignColors.primary.withValues(alpha: 0.15),
        checkmarkColor: DesignColors.primary,
        labelStyle: DesignTypography.bodySmall.copyWith(
          color: isSelected ? DesignColors.primary : DesignColors.textPrimary,
        ),
        onSelected: file.isExtracting ? null : (_) => _toggleFile(file.id),
      ),
    );

    // T3-3: Hiển thị role badge bên dưới chip cho file có parsedQuestions
    if (!hasQuestions) return chip;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chip,
        GestureDetector(
          onTap: () => _toggleFileRole(file),
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: effectiveRole == FileRole.template
                  ? DesignColors.success.withValues(alpha: 0.12)
                  : DesignColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              effectiveRole == FileRole.template ? '📋 Mẫu' : '📚 Kiến thức',
              style: DesignTypography.bodySmall.copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddChip() {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: const Text('Thêm tài liệu'),
      onPressed: _pickAndAddLocalFile,
      backgroundColor: DesignColors.moonMedium,
      labelStyle: DesignTypography.bodySmall.copyWith(
        color: DesignColors.textSecondary,
      ),
    );
  }
}

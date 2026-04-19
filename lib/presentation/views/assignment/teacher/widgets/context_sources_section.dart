import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

/// Widget hiển thị phần "Nguồn Dữ Liệu Tham Khảo" trong màn hình tạo câu hỏi AI.
///
/// - Hiển thị danh sách tài liệu đã upload dưới dạng FilterChip selectable
/// - [+] Thêm tài liệu ActionChip để pick file và upload
/// - Callback `onSelectionChanged` thông báo cho parent về danh sách file được chọn
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

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'docx'],
      withData: true, // REQUIRED for bytes access on all platforms
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) return;

    final mimeType = file.extension == 'xlsx'
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

    await ref
        .read(teacherFilesProvider.notifier)
        .uploadFile(bytes, file.name, mimeType);
    // State updates automatically via teacherFilesProvider — new chip appears
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filesAsync = ref.watch(teacherFilesProvider);

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
        filesAsync.when(
          loading: _buildShimmerChips,
          error: (e, _) => _buildErrorState(),
          data: _buildChipWrap,
        ),
      ],
    );
  }

  Widget _buildShimmerChips() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Wrap(
        spacing: DesignSpacing.sm,
        runSpacing: DesignSpacing.sm,
        children: List.generate(
          3,
          (_) => Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Row(
      children: [
        Text(
          'Không thể tải tài liệu',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.error,
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        TextButton(
          onPressed: () => ref.invalidate(teacherFilesProvider),
          child: const Text('Thử lại'),
        ),
      ],
    );
  }

  Widget _buildChipWrap(List<TeacherFileModel> files) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: [
        ...files.map((file) => _buildFileChip(file)),
        _buildAddChip(),
      ],
    );
  }

  Widget _buildFileChip(TeacherFileModel file) {
    final isSelected = _selectedFileIds.contains(file.id);
    final isProcessing =
        file.processingStatus == 'queued' ||
        file.processingStatus == 'processing';

    // Truncate filename to 20 chars
    final label = file.filename.length > 20
        ? '${file.filename.substring(0, 20)}…'
        : file.filename;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      avatar: isProcessing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      selectedColor: DesignColors.primary.withValues(alpha: 0.15),
      checkmarkColor: DesignColors.primary,
      labelStyle: DesignTypography.bodySmall.copyWith(
        color: isSelected ? DesignColors.primary : DesignColors.textPrimary,
      ),
      onSelected: (_) => _toggleFile(file.id),
    );
  }

  Widget _buildAddChip() {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: const Text('Thêm tài liệu'),
      onPressed: _pickAndUploadFile,
      backgroundColor: DesignColors.moonMedium,
      labelStyle: DesignTypography.bodySmall.copyWith(
        color: DesignColors.textSecondary,
      ),
    );
  }
}

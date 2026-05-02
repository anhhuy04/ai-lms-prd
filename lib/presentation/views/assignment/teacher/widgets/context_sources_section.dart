import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/data/models/local_temp_file.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:ai_mls/presentation/providers/ai_generation_settings_notifier.dart';
import 'package:ai_mls/presentation/providers/local_temp_file_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Danh sách card tài liệu tham khảo cho Mode 2 & 3.
///
/// Mode 3 ([showRoleBadge] = true): mỗi card có 2 tầng điều khiển:
///   • Tầng 1 — toggle role 📋 Mẫu / 📚 Kiến thức (tap để đổi)
///   • Tầng 2 — sub-mode Tạo mới / Cùng dạng, hiện khi card Mẫu được chọn
class ContextSourcesSection extends ConsumerStatefulWidget {
  const ContextSourcesSection({
    super.key,
    required this.onSelectionChanged,
    this.showRoleBadge = false,
  });

  final void Function(List<String> fileIds) onSelectionChanged;
  final bool showRoleBadge;

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

  void _toggleFileRole(LocalTempFile file) {
    final next = file.effectiveRole == FileRole.template
        ? FileRole.knowledgeSource
        : FileRole.template;
    ref.read(localTempFilesProvider.notifier).updateFileRole(file.id, next);
  }

  void _removeFile(LocalTempFile file) {
    if (_selectedFileIds.contains(file.id)) {
      setState(() => _selectedFileIds.remove(file.id));
      widget.onSelectionChanged(_selectedFileIds.toList());
    }
    ref.read(localTempFilesProvider.notifier).removeFile(file.id);
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
        mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (ext == 'docx') {
        mimeType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
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

    // Pre-compute allMcq cho Tầng 2 (Cùng dạng enable/disable)
    bool allMcq = false;
    if (widget.showRoleBadge) {
      final templateQs = files
          .where((f) =>
              _selectedFileIds.contains(f.id) &&
              f.parsedQuestions?.isNotEmpty == true &&
              f.effectiveRole == FileRole.template)
          .expand((f) => f.parsedQuestions!)
          .toList();
      allMcq = templateQs.isNotEmpty &&
          templateQs.every((q) {
            final t = q['type'];
            return t == QuestionType.multipleChoice ||
                t == QuestionType.trueFalse ||
                t == QuestionType.math;
          });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Text(
              'Tài liệu tham khảo',
              style: DesignTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            if (files.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Text(
                  '${_selectedFileIds.length}/${files.length}',
                  style: DesignTypography.labelSmall.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // File cards
        if (files.isEmpty)
          _buildEmptyState(isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _buildFileCard(files[i], isDark, allMcq),
          ),

        const SizedBox(height: 8),

        // Add file button
        _buildAddButton(isDark),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[850]!.withValues(alpha: 0.4)
            : DesignColors.moonMedium.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.upload_file_outlined,
              size: 32,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 6),
            Text(
              'Chưa có tài liệu nào',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // File card
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFileCard(LocalTempFile file, bool isDark, bool allMcq) {
    final isSelected = _selectedFileIds.contains(file.id);
    final hasQuestions = file.parsedQuestions?.isNotEmpty == true;
    final isTemplate =
        widget.showRoleBadge && hasQuestions && file.effectiveRole == FileRole.template;
    final showSubMode = isTemplate && isSelected;

    final selectedBorderColor = DesignColors.primary;
    final cardBg = isSelected
        ? (isDark
            ? DesignColors.primary.withValues(alpha: 0.08)
            : DesignColors.primary.withValues(alpha: 0.04))
        : (isDark ? const Color(0xFF1E2A38) : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: isSelected
              ? selectedBorderColor.withValues(alpha: 0.5)
              : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: DesignColors.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: file.isExtracting ? null : () => _toggleFile(file.id),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main row ──────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // File icon
                  _buildFileIcon(file, isSelected),
                  const SizedBox(width: 10),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.filename,
                          style: DesignTypography.bodySmall.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? (isDark
                                    ? Colors.white
                                    : DesignColors.textPrimary)
                                : (isDark
                                    ? Colors.grey[300]
                                    : DesignColors.textSecondary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        _buildFileStatus(file, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role badge — Mode 3, hiện cho tất cả file đã xử lý xong
                      // File có parsedQuestions: tap được để toggle Mẫu ↔ KT
                      // File chỉ có text: locked "📚 Kiến thức" (không thể làm Mẫu)
                      if (widget.showRoleBadge && !file.isExtracting)
                        _buildRoleToggle(file, isDark, canToggle: hasQuestions),

                      // Delete button
                      if (!file.isExtracting) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            onPressed: () => _removeFile(file),
                            tooltip: 'Xóa file',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Sub-mode strip (Tầng 2) ───────────────────────────
            if (showSubMode)
              _buildSubModeStrip(isDark, allMcq),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(LocalTempFile file, bool isSelected) {
    final hasQuestions = file.parsedQuestions?.isNotEmpty == true;
    final hasText = file.extractedText?.isNotEmpty == true;
    final ext = file.filename.toLowerCase().split('.').last;
    final isExcel = ext == 'xlsx' || file.mimeType.contains('spreadsheetml');
    final isPdf = ext == 'pdf' || file.mimeType.contains('pdf');

    // ── Icon + màu nền theo loại file (luôn cố định) ──────────────
    final IconData icon;
    final Color typeColor;
    final String extLabel;

    if (isExcel) {
      icon = Icons.table_chart_rounded;
      typeColor = const Color(0xFF1E6B3C); // Excel green
      extLabel = 'XLS';
    } else if (isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      typeColor = const Color(0xFFD32F2F); // PDF red
      extLabel = 'PDF';
    } else {
      icon = Icons.article_rounded;
      typeColor = const Color(0xFF1565C0); // Word blue
      extLabel = 'DOC';
    }

    // ── Status badge (góc dưới-phải) — trạng thái xử lý ──────────
    // processing: spinner; parsed: ✓ xanh; raw text: •  xanh dương; unreadable: ⚠ cam
    late final Widget statusBadge;
    if (file.isExtracting) {
      statusBadge = SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: typeColor,
        ),
      );
    } else if (hasQuestions) {
      statusBadge = Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: DesignColors.success,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(Icons.check_rounded, size: 8, color: Colors.white),
      );
    } else if (hasText) {
      statusBadge = Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: DesignColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(Icons.auto_awesome, size: 7, color: Colors.white),
      );
    } else {
      // Unreadable — không có questions, không có text
      statusBadge = Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: DesignColors.warning,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(Icons.warning_rounded, size: 8, color: Colors.white),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            border: Border.all(
              color: typeColor.withValues(alpha: isSelected ? 0.4 : 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: typeColor),
              const SizedBox(height: 1),
              Text(
                extLabel,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: typeColor,
                  height: 1,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: statusBadge,
        ),
      ],
    );
  }

  Widget _buildFileStatus(LocalTempFile file, bool isDark) {
    final subColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    final style = DesignTypography.labelSmall.copyWith(color: subColor);

    final isExcel = file.mimeType.contains('spreadsheetml') ||
        file.filename.toLowerCase().endsWith('.xlsx');
    final isPdf = file.mimeType.contains('pdf') ||
        file.filename.toLowerCase().endsWith('.pdf');
    final ext = isExcel
        ? 'Excel'
        : isPdf
            ? 'PDF'
            : 'Word';

    if (file.isExtracting) {
      return Text('Đang phân tích…', style: style);
    }

    final hasQuestions = file.parsedQuestions?.isNotEmpty == true;
    final hasText = file.extractedText?.isNotEmpty == true;

    String info;
    if (hasQuestions) {
      info = '${file.parsedQuestions!.length} câu • $ext';
    } else if (hasText) {
      final chars = file.extractedText!.length;
      final display = chars >= 1000
          ? '${(chars / 1000).toStringAsFixed(1)}k ký tự'
          : '$chars ký tự';
      info = '$display • $ext';
    } else {
      info = 'Không đọc được • $ext';
    }

    return Text(info, style: style);
  }

  // ─────────────────────────────────────────────────────────────────
  // Role toggle pill (Tầng 1)
  // ─────────────────────────────────────────────────────────────────

  /// [canToggle]: true khi file có parsedQuestions (Excel/Word mẫu) — cho phép
  /// đổi giữa Mẫu ↔ Kiến thức. false khi chỉ có raw text — locked "Kiến thức".
  Widget _buildRoleToggle(LocalTempFile file, bool isDark,
      {required bool canToggle}) {
    // File không có parsedQuestions luôn là Kiến thức, không thể làm Mẫu
    final isTemplate = canToggle && file.effectiveRole == FileRole.template;

    final color = isTemplate
        ? DesignColors.success
        : (canToggle ? DesignColors.primary : Colors.grey);

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: canToggle ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: color.withValues(alpha: canToggle ? 0.3 : 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isTemplate ? '📋 Mẫu' : '📚 KT',
            style: DesignTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          // Icon swap nếu có thể toggle, lock nếu không
          Icon(
            canToggle ? Icons.swap_horiz_rounded : Icons.lock_outline_rounded,
            size: 11,
            color: color,
          ),
        ],
      ),
    );

    if (!canToggle) {
      return Tooltip(
        message: 'File text thuần — chỉ dùng làm nguồn Kiến thức',
        child: badge,
      );
    }

    return GestureDetector(
      onTap: () => _toggleFileRole(file),
      child: badge,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Sub-mode strip (Tầng 2) — chỉ hiện khi Mẫu + selected
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSubModeStrip(bool isDark, bool allMcq) {
    final current =
        ref.watch(aiGenerationSettingsNotifierProvider).templateMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[850]!.withValues(alpha: 0.6)
            : DesignColors.moonMedium.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(DesignRadius.md),
          bottomRight: Radius.circular(DesignRadius.md),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          // Label
          Text(
            'Kiểu tạo:',
            style: DesignTypography.labelSmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 8),

          // Tạo mới
          _buildSubChip(
            label: 'Tạo mới',
            icon: Icons.auto_awesome_outlined,
            selected: current == TemplateMode.styleOnly,
            disabled: false,
            activeColor: DesignColors.primary,
            isDark: isDark,
            onTap: () => ref
                .read(aiGenerationSettingsNotifierProvider.notifier)
                .setTemplateMode(TemplateMode.styleOnly),
          ),
          const SizedBox(width: 6),

          // Cùng dạng
          _buildSubChip(
            label: 'Cùng dạng',
            icon: Icons.content_copy_outlined,
            selected: current == TemplateMode.sameForm,
            disabled: !allMcq,
            activeColor: DesignColors.success,
            isDark: isDark,
            tooltip: allMcq
                ? 'Giữ cấu trúc câu, đổi số liệu/tình huống'
                : 'Cần toàn bộ câu là Trắc nghiệm',
            onTap: allMcq
                ? () => ref
                    .read(aiGenerationSettingsNotifierProvider.notifier)
                    .setTemplateMode(TemplateMode.sameForm)
                : null,
          ),

          // Tooltip giải thích khi disable
          if (!allMcq) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: 'File mẫu có câu tự luận → chỉ dùng được Tạo mới',
              child: Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubChip({
    required String label,
    required IconData icon,
    required bool selected,
    required bool disabled,
    required Color activeColor,
    required bool isDark,
    String? tooltip,
    VoidCallback? onTap,
  }) {
    final effectiveColor = disabled
        ? (isDark ? Colors.grey[600]! : Colors.grey[400]!)
        : (selected ? activeColor : (isDark ? Colors.grey[400]! : Colors.grey[600]!));

    final chip = GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark ? Colors.grey[800]! : Colors.white),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(
            color: selected
                ? activeColor.withValues(alpha: 0.5)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: effectiveColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: DesignTypography.labelSmall.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) return Tooltip(message: tooltip, child: chip);
    return chip;
  }

  // ─────────────────────────────────────────────────────────────────
  // Add file button
  // ─────────────────────────────────────────────────────────────────

  Widget _buildAddButton(bool isDark) {
    return InkWell(
      onTap: _pickAndAddLocalFile,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: isDark
                ? Colors.grey[700]!
                : DesignColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 16,
              color: DesignColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'Thêm tài liệu  (.xlsx • .docx • .pdf)',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

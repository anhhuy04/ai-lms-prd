import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/excel_template_generator.dart';
import 'package:ai_mls/core/utils/file_exporter.dart';
import 'package:ai_mls/core/utils/word_template_generator.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';

// ── Format enum ───────────────────────────────────────────────────────────────

enum SampleFileFormat {
  excelQuestions(
    'Excel\nCâu hỏi',
    Icons.table_chart_outlined,
    'Import trực tiếp vào ngân hàng câu hỏi. AI học cấu trúc từ mẫu.',
    Color(0xFF1A6FAB),
  ),
  wordQuestions(
    'Word\nCâu hỏi',
    Icons.description_outlined,
    'Tài liệu Word có câu hỏi. AI học văn phong để tạo câu mới.',
    Color(0xFF2E7D32),
  ),
  wordKnowledge(
    'Word\nKiến thức',
    Icons.menu_book_outlined,
    'Tài liệu bài giảng / kiến thức dài. AI phân tích và tạo câu hỏi.',
    Color(0xFF6A1B9A),
  );

  const SampleFileFormat(this.label, this.icon, this.hint, this.color);
  final String label;
  final IconData icon;
  final String hint;
  final Color color;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class ExportTemplateBottomSheet extends StatefulWidget {
  const ExportTemplateBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExportTemplateBottomSheet(),
    );
  }

  @override
  State<ExportTemplateBottomSheet> createState() => _ExportTemplateBottomSheetState();
}

class _ExportTemplateBottomSheetState extends State<ExportTemplateBottomSheet> {
  // format selection
  SampleFileFormat _format = SampleFileFormat.excelQuestions;

  // excel/word questions — shared type selector
  TemplateType _questionType = TemplateType.mixed;

  // excel-specific
  bool _colorHeaders = true;

  // shared (excel + word questions)
  bool _includeExamples = true;

  // shared (all formats)
  bool _includeGuide = true;

  bool _isGenerating = false;

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DesignColors.textPrimary : DesignColors.white;
    final maxH = (MediaQuery.of(context).size.height * 0.9).clamp(0.0, 700.0);

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignRadius.lg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(isDark),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: DesignSpacing.lg,
                  right: DesignSpacing.lg,
                  top: DesignSpacing.sm,
                  bottom: DesignSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark),
                    SizedBox(height: DesignSpacing.xl),

                    _buildSectionLabel('ĐỊNH DẠNG FILE', isDark),
                    SizedBox(height: DesignSpacing.sm),
                    _buildFormatSelector(isDark),
                    SizedBox(height: DesignSpacing.xs),
                    _buildFormatHint(isDark),
                    SizedBox(height: DesignSpacing.lg),

                    Divider(height: 1, color: DesignColors.dividerLight),
                    SizedBox(height: DesignSpacing.lg),

                    // Format-specific sections
                    if (_format != SampleFileFormat.wordKnowledge) ...[
                      _buildSectionLabel('LOẠI CÂU HỎI', isDark),
                      SizedBox(height: DesignSpacing.sm),
                      _buildTypeSelector(isDark),
                      SizedBox(height: DesignSpacing.lg),
                    ],

                    _buildSectionLabel('TÙY CHỌN', isDark),
                    SizedBox(height: DesignSpacing.xs),
                    _buildOptions(isDark),
                    SizedBox(height: DesignSpacing.md),

                    _buildPreview(isDark),
                    SizedBox(height: DesignSpacing.lg),

                    _buildUsageGuide(isDark),
                    SizedBox(height: DesignSpacing.xl),

                    _buildGenerateButton(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildDragHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? DesignColors.textSecondary : DesignColors.dividerMedium,
            borderRadius: BorderRadius.circular(DesignRadius.xs),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: DesignComponents.buttonHeightLarge,
          height: DesignComponents.buttonHeightLarge,
          decoration: BoxDecoration(
            color: _format.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          child: Icon(_format.icon, color: _format.color, size: DesignIcons.mdSize),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tải File Mẫu',
                style: DesignTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? DesignColors.white : DesignColors.textPrimary,
                ),
              ),
              SizedBox(height: DesignSpacing.xs),
              Text(
                'Chọn định dạng phù hợp với cách bạn muốn soạn câu hỏi',
                style: DesignTypography.bodySmall.copyWith(
                  color: isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: DesignTypography.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        color: isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
      ),
    );
  }

  Widget _buildFormatSelector(bool isDark) {
    return Row(
      children: SampleFileFormat.values
          .map((f) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: f != SampleFileFormat.values.last ? DesignSpacing.sm : 0,
                  ),
                  child: _buildFormatCard(f, isDark),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFormatCard(SampleFileFormat format, bool isDark) {
    final selected = _format == format;
    return GestureDetector(
      onTap: () => setState(() => _format = format),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md, horizontal: DesignSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? format.color.withValues(alpha: 0.09)
              : (isDark ? const Color(0xFF1E2E3E) : DesignColors.moonLight),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: selected ? format.color : (isDark ? DesignColors.textSecondary : DesignColors.dividerMedium),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              format.icon,
              size: 28,
              color: selected ? format.color : (isDark ? DesignColors.textSecondary : DesignColors.textTertiary),
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              format.label,
              textAlign: TextAlign.center,
              style: DesignTypography.labelSmall.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? format.color
                    : (isDark ? DesignColors.white : DesignColors.textPrimary),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatHint(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(_format),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _format.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: DesignIcons.xsSize, color: _format.color),
            SizedBox(width: DesignSpacing.xs),
            Expanded(
              child: Text(
                _format.hint,
                style: DesignTypography.bodySmall.copyWith(
                  color: isDark ? DesignColors.white : DesignColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return GridView.extent(
      maxCrossAxisExtent: 240,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: DesignSpacing.sm,
      crossAxisSpacing: DesignSpacing.sm,
      childAspectRatio: 2.3,
      children: TemplateType.values.map((t) => _buildTypeCard(t, isDark)).toList(),
    );
  }

  Widget _buildTypeCard(TemplateType type, bool isDark) {
    final selected = _questionType == type;
    return GestureDetector(
      onTap: () => setState(() => _questionType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? DesignColors.primary.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF1E2E3E) : DesignColors.moonLight),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: selected
                ? DesignColors.primary
                : (isDark ? DesignColors.textSecondary : DesignColors.dividerMedium),
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.xs + 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.label,
              style: DesignTypography.titleSmall.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? DesignColors.primary
                    : (isDark ? DesignColors.white : DesignColors.textPrimary),
              ),
            ),
            Text(
              type.description,
              style: DesignTypography.labelSmall.copyWith(color: DesignColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(bool isDark) {
    return Column(
      children: [
        _OptionTile(
          label: 'Thêm trang hướng dẫn',
          subtitle: _format == SampleFileFormat.excelQuestions
              ? 'Sheet giải thích cách điền template'
              : 'Phần hướng dẫn sử dụng ở đầu tài liệu',
          value: _includeGuide,
          onChanged: (v) => setState(() => _includeGuide = v),
          isDark: isDark,
        ),
        if (_format != SampleFileFormat.wordKnowledge)
          _OptionTile(
            label: 'Điền sẵn câu ví dụ',
            subtitle: _format == SampleFileFormat.excelQuestions
                ? 'Điền 5 câu ví dụ đa môn học vào từng sheet'
                : 'Điền 5 câu ví dụ thực tế — tải về là dùng test ngay',
            value: _includeExamples,
            onChanged: (v) => setState(() => _includeExamples = v),
            isDark: isDark,
          ),
        if (_format == SampleFileFormat.excelQuestions)
          _OptionTile(
            label: 'Tô màu tiêu đề cột',
            subtitle: 'Hàng header nền xanh, chữ trắng (dễ nhìn)',
            value: _colorHeaders,
            onChanged: (v) => setState(() => _colorHeaders = v),
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildPreview(bool isDark) {
    final items = _previewItems();
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Gồm:',
          style: DesignTypography.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
          ),
        ),
        ...items.map(
          (s) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm + 2,
              vertical: DesignSpacing.xs - 1,
            ),
            decoration: BoxDecoration(
              color: _format.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              border: Border.all(color: _format.color.withValues(alpha: 0.25)),
            ),
            child: Text(
              s,
              style: DesignTypography.labelSmall.copyWith(
                color: _format.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _previewItems() {
    switch (_format) {
      case SampleFileFormat.excelQuestions:
        return [
          if (_includeGuide) 'Sheet: Hướng dẫn',
          ..._questionType.sheets.map((s) => 'Sheet: $s'),
        ];
      case SampleFileFormat.wordQuestions:
        return [..._questionType.sheets, 'định dạng .docx'];
      case SampleFileFormat.wordKnowledge:
        return ['I. Tổng quan', 'II. Nội dung', 'III. Ví dụ', 'IV. Cốt lõi', 'V. Từ khóa', 'định dạng .docx'];
    }
  }

  Widget _buildGenerateButton(bool isDark) {
    final (label, icon) = switch (_format) {
      SampleFileFormat.excelQuestions => ('Tạo & Xuất file Excel (.xlsx)', Icons.table_chart_outlined),
      SampleFileFormat.wordQuestions => ('Tạo & Xuất file Word — câu hỏi (.docx)', Icons.description_outlined),
      SampleFileFormat.wordKnowledge => ('Tạo & Xuất tài liệu kiến thức (.docx)', Icons.menu_book_outlined),
    };

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _generate,
        icon: _isGenerating
            ? const SizedBox(
                width: DesignIcons.smSize,
                height: DesignIcons.smSize,
                child: CircularProgressIndicator(strokeWidth: 2, color: DesignColors.white),
              )
            : Icon(icon, size: DesignIcons.mdSize),
        label: Text(
          _isGenerating ? 'Đang tạo file...' : label,
          style: DesignTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: DesignColors.white),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _format.color,
          disabledBackgroundColor: _format.color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
        ),
      ),
    );
  }

  // ── Usage guide ────────────────────────────────────────────────────────────

  Widget _buildUsageGuide(bool isDark) {
    final steps = _usageSteps();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(_format),
        width: double.infinity,
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: _format.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: _format.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch_outlined, size: DesignIcons.smSize, color: _format.color),
                SizedBox(width: DesignSpacing.xs),
                Text(
                  'Dùng ngay sau khi tải',
                  style: DesignTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _format.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            ...steps.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(
                  bottom: e.key < steps.length - 1 ? DesignSpacing.sm : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _format.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            color: _format.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Text(
                        e.value,
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark ? DesignColors.white : DesignColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _usageSteps() {
    switch (_format) {
      case SampleFileFormat.excelQuestions:
        return [
          'Mở file Excel → các sheet đã có 5 câu ví dụ thực, giữ nguyên hoặc thay bằng câu hỏi của bạn',
          'Vào màn hình Tạo câu hỏi AI → chọn chế độ Tạo từ tài liệu (RAG)',
          'Upload file Excel → bấm nút 📋 để đặt làm Mẫu',
          'Bấm Tạo — AI học phong cách câu hỏi từ file mẫu và sinh câu mới',
        ];
      case SampleFileFormat.wordQuestions:
        return [
          'Mở file Word → đã có 5 câu ví dụ đầy đủ, giữ nguyên hoặc thay bằng câu hỏi thật rồi lưu lại',
          'Vào màn hình Tạo câu hỏi AI → chọn chế độ Tạo từ tài liệu (RAG)',
          'Upload file Word → bấm 📋 để đặt làm Mẫu',
          'Bấm Tạo — AI học văn phong và sinh câu hỏi mới cùng định dạng',
        ];
      case SampleFileFormat.wordKnowledge:
        return [
          'Mở file Word → thay nội dung trong dấu [ ] bằng kiến thức thật của bạn, lưu lại',
          'Vào màn hình Tạo câu hỏi AI → chọn chế độ Tạo từ tài liệu (RAG)',
          'Upload file → để mặc định 📚 Kiến thức (hoặc kết hợp thêm file 📋 Mẫu)',
          'Bấm Tạo — AI phân tích tài liệu và sinh câu hỏi bám sát nội dung',
        ];
    }
  }

  // ── Generate logic ─────────────────────────────────────────────────────────

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    try {
      switch (_format) {
        case SampleFileFormat.excelQuestions:
          await _generateExcel();
        case SampleFileFormat.wordQuestions:
          await _generateWordQuestions();
        case SampleFileFormat.wordKnowledge:
          await _generateWordKnowledge();
      }
    } catch (e, st) {
      AppLogger.error('[ExportTemplate] LỖI', error: e, stackTrace: st);
      if (!mounted) return;
      AppToast.error(context, 'Lỗi tạo file: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateExcel() async {
    final config = ExcelTemplateConfig(
      type: _questionType,
      sampleCount: 5,
      includeGuide: _includeGuide,
      includeExamples: _includeExamples,
      colorHeaders: _colorHeaders,
    );
    AppLogger.info('[ExportTemplate] Excel — type=${_questionType.name}');
    final bytes = ExcelTemplateGenerator.generate(config);
    if (bytes == null) throw Exception('ExcelTemplateGenerator trả về null');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'mau_cau_hoi_${_questionType.name}_$ts.xlsx';
    final saved = await exportFile(Uint8List.fromList(bytes), fileName);
    if (saved && mounted) Navigator.of(context).pop();
  }

  Future<void> _generateWordQuestions() async {
    final config = WordTemplateConfig(
      type: WordDocType.questions,
      questionType: _questionType,
      sampleCount: 5,
      includeGuide: _includeGuide,
      includeExamples: _includeExamples,
    );
    AppLogger.info('[ExportTemplate] Word câu hỏi — type=${_questionType.name}');
    final bytes = WordTemplateGenerator.generate(config);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final saved = await exportFile(bytes, 'mau_cau_hoi_${_questionType.name}_word_$ts.docx');
    if (saved && mounted) Navigator.of(context).pop();
  }

  Future<void> _generateWordKnowledge() async {
    final config = WordTemplateConfig(
      type: WordDocType.knowledge,
      includeGuide: _includeGuide,
    );
    AppLogger.info('[ExportTemplate] Word kiến thức');
    final bytes = WordTemplateGenerator.generate(config);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final saved = await exportFile(bytes, 'tai_lieu_kien_thuc_$ts.docx');
    if (saved && mounted) Navigator.of(context).pop();
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? DesignColors.white : DesignColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: DesignTypography.caption.copyWith(
                    color: isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: DesignColors.primary),
        ],
      ),
    );
  }
}

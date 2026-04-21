import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/excel_template_generator.dart';
import 'package:ai_mls/core/utils/file_exporter.dart';
import 'package:flutter/material.dart';

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
  TemplateType _type = TemplateType.mixed;
  int _sampleCount = 5;
  bool _includeGuide = true;
  bool _includeExamples = true;
  bool _colorHeaders = true;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A2632) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
              _buildDragHandle(isDark),
              SizedBox(height: DesignSpacing.lg),
              _buildHeader(isDark),
              SizedBox(height: DesignSpacing.xl),
              _buildSectionLabel('Loại câu hỏi', isDark),
              SizedBox(height: DesignSpacing.sm),
              _buildTypeSelector(isDark),
              SizedBox(height: DesignSpacing.lg),
              _buildSectionLabel('Số câu ví dụ điền sẵn', isDark),
              SizedBox(height: DesignSpacing.sm),
              _buildCounterRow(isDark),
              SizedBox(height: DesignSpacing.lg),
              _buildSectionLabel('Tùy chọn', isDark),
              SizedBox(height: DesignSpacing.xs),
              _buildOptions(isDark),
              SizedBox(height: DesignSpacing.md),
              _buildSheetPreview(isDark),
              SizedBox(height: DesignSpacing.xl),
              _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DesignColors.tealPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          child: Icon(Icons.table_chart_outlined, color: DesignColors.tealPrimary, size: 26),
        ),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xuất File Mẫu Excel',
                style: DesignTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tạo template chuẩn để import câu hỏi vào AI',
                style: DesignTypography.bodySmall.copyWith(
                  color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
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
      label.toUpperCase(),
      style: TextStyle(
        fontSize: DesignTypography.labelSmallSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: DesignSpacing.sm,
      crossAxisSpacing: DesignSpacing.sm,
      childAspectRatio: 2.3,
      children: TemplateType.values.map((t) => _buildTypeCard(t, isDark)).toList(),
    );
  }

  Widget _buildTypeCard(TemplateType type, bool isDark) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? DesignColors.primary.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF243040) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: selected
                ? DesignColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: selected
                    ? DesignColors.primary
                    : (isDark ? Colors.white : DesignColors.textPrimary),
              ),
            ),
            Text(
              type.description,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(bool isDark) {
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove_rounded,
          onTap: _sampleCount > 1 ? () => setState(() => _sampleCount--) : null,
          isDark: isDark,
        ),
        SizedBox(width: DesignSpacing.md),
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF243040) : Colors.grey[50],
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: DesignColors.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$_sampleCount',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: DesignColors.primary,
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        _CounterButton(
          icon: Icons.add_rounded,
          onTap: _sampleCount < 20 ? () => setState(() => _sampleCount++) : null,
          isDark: isDark,
        ),
        SizedBox(width: DesignSpacing.lg),
        Text(
          'câu (tối đa 20)',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(bool isDark) {
    return Column(
      children: [
        _OptionTile(
          label: 'Thêm sheet Hướng dẫn',
          subtitle: 'Sheet giải thích cách điền template',
          value: _includeGuide,
          onChanged: (v) => setState(() => _includeGuide = v),
          isDark: isDark,
        ),
        _OptionTile(
          label: 'Điền sẵn câu ví dụ',
          subtitle: 'Thêm 2 câu hỏi mẫu vào mỗi sheet',
          value: _includeExamples,
          onChanged: (v) => setState(() => _includeExamples = v),
          isDark: isDark,
        ),
        _OptionTile(
          label: 'Tô màu header',
          subtitle: 'Hàng tiêu đề nền xanh, chữ trắng',
          value: _colorHeaders,
          onChanged: (v) => setState(() => _colorHeaders = v),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSheetPreview(bool isDark) {
    final sheets = [
      if (_includeGuide) 'Hướng dẫn',
      ..._type.sheets,
    ];
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Sheets:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        ...sheets.map(
          (s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DesignColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 11,
                color: DesignColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _generate,
        icon: _isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.download_rounded, size: 20),
        label: Text(
          _isGenerating ? 'Đang tạo file...' : 'Tạo & Xuất File Excel',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: DesignColors.primary,
          disabledBackgroundColor: DesignColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    try {
      final config = ExcelTemplateConfig(
        type: _type,
        sampleCount: _sampleCount,
        includeGuide: _includeGuide,
        includeExamples: _includeExamples,
        colorHeaders: _colorHeaders,
      );

      debugPrint('[ExportTemplate] Bắt đầu tạo Excel — type=${_type.name} sampleCount=$_sampleCount');
      final bytes = ExcelTemplateGenerator.generate(config);
      debugPrint('[ExportTemplate] generate() trả về ${bytes?.length ?? "null"} bytes');
      if (bytes == null) throw Exception('ExcelTemplateGenerator.generate() trả về null');

      final fileName = 'mau_cau_hoi_${_type.name}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      debugPrint('[ExportTemplate] Xuất file: $fileName');
      if (!mounted) return;
      final saved = await exportExcelFile(bytes, fileName);
      debugPrint('[ExportTemplate] Kết quả lưu: $saved');
      if (saved && mounted) Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('[ExportTemplate] LỖI: $e');
      debugPrint('[ExportTemplate] StackTrace: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tạo file: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled
              ? DesignColors.primary.withValues(alpha: 0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: enabled
                ? DesignColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? DesignColors.primary : Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignColors.primary,
          ),
        ],
      ),
    );
  }
}

// lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart
import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/data/models/local_temp_file.dart';
import 'package:ai_mls/presentation/providers/ai_generation_settings_notifier.dart';
import 'package:ai_mls/presentation/providers/local_temp_file_notifier.dart';
import 'package:ai_mls/presentation/views/settings/widgets/export_template_bottom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EndDrawer for TeacherAiGenerateQuestionScreen.
/// Sections: API Key → Document Library (temp files) → Tools.
class AiSettingsDrawer extends ConsumerWidget {
  const AiSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: isDark ? const Color(0xFF1A2632) : DesignColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    'Cài đặt AI',
                    style: DesignTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? DesignColors.white : DesignColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
                    ),
                    onPressed: () => Scaffold.of(context).closeEndDrawer(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: DesignColors.dividerLight),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(DesignSpacing.lg),
                children: [
                  _ApiKeySection(isDark: isDark),
                  SizedBox(height: DesignSpacing.xl),
                  _DocumentLibrarySection(isDark: isDark),
                  SizedBox(height: DesignSpacing.xl),
                  _ToolsSection(isDark: isDark),
                  SizedBox(height: DesignSpacing.xl),
                  _AdvancedSection(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeySection extends StatelessWidget {
  const _ApiKeySection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _DrawerSectionCard(
      title: 'API Key',
      icon: Icons.vpn_key_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.vpn_key_outlined, color: DesignColors.primary, size: DesignIcons.mdSize),
        title: Text(
          'Cài đặt API Key',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? DesignColors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Quản lý Gemini API Key',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: DesignColors.textSecondary, size: DesignIcons.mdSize),
        onTap: () {
          Scaffold.of(context).closeEndDrawer();
          context.pushNamed(AppRoute.apiKeySetup);
        },
      ),
    );
  }
}

class _DocumentLibrarySection extends ConsumerWidget {
  const _DocumentLibrarySection({required this.isDark});

  final bool isDark;

  Future<void> _pickAndAddLocalFile(WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'docx', 'pdf'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    for (final file in result.files) {
      final Uint8List? bytes = file.bytes;
      if (bytes == null) continue;
      final ext = file.extension?.toLowerCase();
      final String mimeType;
      if (ext == 'docx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (ext == 'xlsx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else {
        continue;
      }
      await ref.read(localTempFilesProvider.notifier).addFile(bytes, file.name, mimeType);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(localTempFilesProvider);

    return _DrawerSectionCard(
      title: 'Thư viện tài liệu',
      icon: Icons.folder_outlined,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File tạm thời — lưu trong phiên làm việc',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          files.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                  child: Text(
                    'Chưa có tài liệu nào',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: files
                      .map((f) => _FileListTile(file: f, isDark: isDark))
                      .toList(),
                ),
          SizedBox(height: DesignSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickAndAddLocalFile(ref),
              icon: const Icon(Icons.upload_file_outlined, size: DesignIcons.xsSize),
              label: const Text('Thêm tài liệu'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.primary,
                side: BorderSide(color: DesignColors.primary),
                padding: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileListTile extends ConsumerWidget {
  const _FileListTile({required this.file, required this.isDark});

  final LocalTempFile file;
  final bool isDark;

  String _extractedLabel(LocalTempFile f) {
    if (f.mimeType.contains('pdf') || f.filename.toLowerCase().endsWith('.pdf')) {
      return 'Sẵn sàng (PDF → AI)';
    }
    if (f.mimeType.contains('spreadsheetml') || f.filename.toLowerCase().endsWith('.xlsx')) {
      return 'Sẵn sàng (Excel → AI)';
    }
    return 'Sẵn sàng (Word → AI)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = (file.extractedText?.isNotEmpty == true) ||
        (file.parsedQuestions?.isNotEmpty == true);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      dense: true,
      leading: file.isExtracting
          ? const SizedBox(
              width: DesignIcons.smSize,
              height: DesignIcons.smSize,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.insert_drive_file_outlined,
              size: DesignIcons.smSize,
              color: isReady ? DesignColors.success : DesignColors.textSecondary,
            ),
      title: Text(
        file.filename,
        style: DesignTypography.bodySmall.copyWith(
          color: isDark ? DesignColors.white : DesignColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        file.isExtracting
            ? 'Đang đọc nội dung...'
            : file.parsedQuestions?.isNotEmpty == true
                ? '${file.parsedQuestions!.length} câu hỏi — tải trực tiếp'
                : file.extractedText?.isNotEmpty == true
                    ? _extractedLabel(file)
                    : 'Không đọc được nội dung',
        style: DesignTypography.bodySmall.copyWith(
          color: file.isExtracting
              ? DesignColors.warning
              : isReady
                  ? DesignColors.success
                  : DesignColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline_rounded, size: DesignIcons.smSize, color: DesignColors.error),
        tooltip: 'Xóa',
        onPressed: () => ref.read(localTempFilesProvider.notifier).removeFile(file.id),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _DrawerSectionCard(
      title: 'Công cụ',
      icon: Icons.build_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.download_outlined, color: DesignColors.drawerIcon, size: DesignIcons.mdSize),
        title: Text(
          'Tải file mẫu',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? DesignColors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Excel câu hỏi · Word câu hỏi · Word kiến thức',
          style: DesignTypography.bodySmall.copyWith(color: DesignColors.textSecondary),
        ),
        trailing: Icon(Icons.chevron_right, color: DesignColors.textSecondary, size: DesignIcons.mdSize),
        onTap: () {
          Scaffold.of(context).closeEndDrawer();
          ExportTemplateBottomSheet.show(context);
        },
      ),
    );
  }
}

class _AdvancedSection extends ConsumerWidget {
  const _AdvancedSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(aiGenerationSettingsNotifierProvider);
    final notifier = ref.read(aiGenerationSettingsNotifierProvider.notifier);
    final enabled = settings.highAccuracyMode;

    return _DrawerSectionCard(
      title: 'Nâng cao',
      icon: Icons.tune_rounded,
      isDark: isDark,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: enabled,
        onChanged: notifier.setHighAccuracyMode,
        activeThumbColor: DesignColors.primary,
        secondary: Icon(
          Icons.verified_outlined,
          color: enabled ? DesignColors.primary : DesignColors.textSecondary,
          size: DesignIcons.mdSize,
        ),
        title: Text(
          'Chế độ chính xác cao',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? DesignColors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'AI tự kiểm tra mỗi câu sau khi tạo (chậm hơn ~10s, tốn 2x token, đánh dấu câu nghi ngờ)',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DrawerSectionCard extends StatelessWidget {
  const _DrawerSectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.child,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? DesignColors.primaryDark : DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [DesignElevation.level1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: DesignIcons.xsSize, color: DesignColors.primary),
              SizedBox(width: DesignSpacing.xs),
              Text(
                title,
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          child,
        ],
      ),
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// AI Question Settings Screen — dedicated AI config screen.
///
/// Contains:
///  1. API Key Setup tile → pushes to ApiKeySetupScreen
///  2. Thư viện Tài liệu section — real file list from teacherFilesProvider
///  3. Công cụ section — "Xuất file mẫu Excel" (D-16-ext)
class AiQuestionSettingsScreen extends ConsumerWidget {
  const AiQuestionSettingsScreen({super.key});

  // TODO: replace <YOUR_SUPABASE_PROJECT> with actual project ref
  static const String _templateUrl =
      'https://<YOUR_SUPABASE_PROJECT>.supabase.co/storage/v1/object/public/teacher-documents/templates/question_template.xlsx';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cài đặt AI',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        children: [
          _buildApiKeySection(context, isDark: isDark),
          SizedBox(height: DesignSpacing.xl),
          _buildDocumentLibrarySection(context, ref, isDark: isDark),
          SizedBox(height: DesignSpacing.xl),
          _buildToolsSection(context, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context, {required bool isDark}) {
    return _SectionCard(
      title: 'API Key',
      icon: Icons.vpn_key_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: _IconBox(
          icon: Icons.vpn_key_outlined,
          color: DesignColors.primary,
        ),
        title: Text(
          'Cài đặt API Key',
          style: DesignTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Quản lý Gemini API Key và các API keys khác',
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        onTap: () => context.pushNamed(AppRoute.apiKeySetup),
      ),
    );
  }

  Widget _buildDocumentLibrarySection(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
  }) {
    final filesAsync = ref.watch(teacherFilesProvider);

    return _SectionCard(
      title: 'Thư viện Tài liệu',
      icon: Icons.folder_outlined,
      isDark: isDark,
      child: filesAsync.when(
        loading: () => _buildDocumentLibraryLoading(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
          child: Text(
            'Lỗi tải tài liệu',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.error,
            ),
          ),
        ),
        data: (files) => files.isEmpty
            ? _buildEmptyLibrary(isDark)
            : _buildFileList(files, isDark),
      ),
    );
  }

  Widget _buildDocumentLibraryLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: DesignSpacing.xs),
                      Container(
                        height: 12,
                        width: 120,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLibrary(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: DesignSpacing.md),
        Icon(
          Icons.folder_open_outlined,
          size: 48,
          color: isDark ? Colors.grey[500] : DesignColors.textTertiary,
        ),
        const SizedBox(height: DesignSpacing.sm),
        Text(
          'Chưa có tài liệu nào',
          style: DesignTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : DesignColors.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSpacing.xs),
        Text(
          'Thêm tài liệu từ màn hình Tạo câu hỏi AI để AI phân tích',
          textAlign: TextAlign.center,
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.grey[500] : DesignColors.textSecondary,
          ),
        ),
        const SizedBox(height: DesignSpacing.md),
      ],
    );
  }

  Widget _buildFileList(List<TeacherFileModel> files, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      itemBuilder: (_, i) => _buildFileListTile(files[i], isDark),
    );
  }

  Widget _buildFileListTile(TeacherFileModel file, bool isDark) {
    final isProcessing =
        file.processingStatus == 'queued' ||
        file.processingStatus == 'processing';
    final isDone = file.processingStatus == 'done';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: DesignSpacing.xs,
      ),
      leading: _IconBox(
        icon: Icons.description_outlined,
        color: isDone ? DesignColors.success : DesignColors.primary,
      ),
      title: Text(
        file.filename,
        style: DesignTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : DesignColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isProcessing
            ? 'Đang xử lý...'
            : isDone
                ? 'Sẵn sàng'
                : 'Lỗi xử lý',
        style: DesignTypography.bodySmall.copyWith(
          color: isProcessing
              ? DesignColors.warning
              : isDone
                  ? DesignColors.success
                  : DesignColors.error,
        ),
      ),
      trailing: isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isDone ? Icons.check_circle_outline : Icons.error_outline,
              color: isDone ? DesignColors.success : DesignColors.error,
              size: 20,
            ),
    );
  }

  Widget _buildToolsSection(BuildContext context, {required bool isDark}) {
    return _SectionCard(
      title: 'Công cụ',
      icon: Icons.build_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: _IconBox(
          icon: Icons.download_outlined,
          color: DesignColors.tealPrimary,
        ),
        title: Text(
          'Xuất file mẫu Excel',
          style: DesignTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Tải template chuẩn để Fast Track (\$0, ~0.1s)',
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        onTap: () => _downloadExcelTemplate(context),
      ),
    );
  }

  void _downloadExcelTemplate(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _templateUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'URL đã copy vào clipboard. Mở trình duyệt để tải template',
        ),
      ),
    );
  }
}

/// Reusable section card matching SettingsScreen visual style.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: DesignColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Reusable icon container with colored background.
class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Widget essay answer field giữ cursor position khi auto-save
/// Có toolbar định dạng và upload ảnh/file
class EssayAnswerField extends ConsumerStatefulWidget {
  final String questionId;
  final dynamic initialValue;
  final String distributionId;

  const EssayAnswerField({
    super.key,
    required this.questionId,
    required this.initialValue,
    required this.distributionId,
  });

  @override
  ConsumerState<EssayAnswerField> createState() => _EssayAnswerFieldState();
}

class _EssayAnswerFieldState extends ConsumerState<EssayAnswerField> {
  late TextEditingController _controller;
  bool _isInternalUpdate = false;
  bool _isUploading = false;

  String get _textValue {
    // Parse answer from format: {"text": "content"}
    if (widget.initialValue is Map) {
      return (widget.initialValue['text'] as String?) ?? '';
    }
    return widget.initialValue ?? '';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textValue);
  }

  @override
  void didUpdateWidget(EssayAnswerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Chỉ update text nếu giá trị thay đổi từ bên ngoài và không phải do user đang gõ
    final newText = _textValue;
    final oldText = _textValue;
    if (!_isInternalUpdate &&
        newText != oldText &&
        newText != _controller.text) {
      // Lưu cursor position
      final cursorPos = _controller.selection.baseOffset;
      _controller.text = newText;
      // Restore cursor position gần nhất có thể
      final newPos = cursorPos.clamp(0, _controller.text.length);
      _controller.selection = TextSelection.collapsed(offset: newPos);
    }
    _isInternalUpdate = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _isInternalUpdate = true;
    ref
        .read(workspaceNotifierProvider(widget.distributionId).notifier)
        .updateAnswer(widget.questionId, {"text": value});
  }

  void _applyBoldFormatting() {
    _insertMarkdownFormatting('**', '**');
  }

  void _applyItalicFormatting() {
    _insertMarkdownFormatting('*', '*');
  }

  void _insertMarkdownFormatting(String prefix, String suffix) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start;
    final end = selection.end;

    if (start < 0 || end < 0) return;

    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');

    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: end + prefix.length + suffix.length,
    );
    _onTextChanged(newText);
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignRadius.lg * 1.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_rounded),
                title: const Text('Chọn file'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_rounded),
                title: const Text('Hủy'),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;

    try {
      setState(() => _isUploading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        final publicUrl = await ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .uploadFile(file);

        if (publicUrl != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tải ảnh lên'),
              backgroundColor: DesignColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    if (!mounted) return;

    try {
      setState(() => _isUploading = true);

      final ImagePicker picker = ImagePicker();
      // Pick any file (not just images)
      final XFile? file = await picker.pickMedia();

      if (file != null && mounted) {
        final dartFile = File(file.path);
        final publicUrl = await ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .uploadFile(dartFile);

        if (publicUrl != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tải file lên'),
              backgroundColor: DesignColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải file: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workspaceAsync = ref.watch(workspaceNotifierProvider(widget.distributionId));

    return workspaceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Lỗi: $e'),
      data: (workspace) {
        final uploadedFiles = workspace.uploadedFiles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToolbarButton(
                    icon: Icons.format_bold_rounded,
                    onPressed: _applyBoldFormatting,
                    isDark: isDark,
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_italic_rounded,
                    onPressed: _applyItalicFormatting,
                    isDark: isDark,
                  ),
                  _buildToolbarButton(
                    icon: Icons.image_rounded,
                    onPressed: _showImageSourceDialog,
                    isDark: isDark,
                  ),
                  _buildToolbarButton(
                    icon: Icons.attach_file_rounded,
                    onPressed: _showImageSourceDialog,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Text Field
            TextFormField(
              controller: _controller,
              minLines: 4,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              style: DesignTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời của bạn...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  borderSide: BorderSide(color: DesignColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(DesignSpacing.md),
              ),
              onChanged: _onTextChanged,
            ),

            // Uploaded files preview
            if (uploadedFiles.isNotEmpty || _isUploading) ...[
              const SizedBox(height: 16),
              _buildFilesPreview(uploadedFiles, isDark),
            ],
          ],
        );
      },
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: isDark ? Colors.grey[300] : Colors.grey[700],
      splashRadius: 18,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _buildFilesPreview(List<String> files, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isUploading)
          Container(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Đang tải lên...',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: files.map((fileUrl) {
            final isImage = fileUrl.toLowerCase().contains(
              RegExp(r'\.(jpg|jpeg|png|gif|webp)$'),
            );

            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignRadius.md - 1),
                child: isImage
                    ? Image.network(
                        fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFileIcon(fileUrl),
                      )
                    : _buildFileIcon(fileUrl),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileIcon(String fileUrl) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              fileUrl.split('/').last,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

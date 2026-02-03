import 'dart:io';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget để chọn và hiển thị multiple images cho câu hỏi
class QuestionImagePicker extends StatefulWidget {
  final List<XFile> images;
  final ValueChanged<List<XFile>> onImagesChanged;
  final int maxImages;

  const QuestionImagePicker({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  State<QuestionImagePicker> createState() => _QuestionImagePickerState();
}

class _QuestionImagePickerState extends State<QuestionImagePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (widget.images.length >= widget.maxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tối đa ${widget.maxImages} hình ảnh'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Giảm chất lượng để tối ưu hiệu năng
        maxWidth: 1920, // Giới hạn kích thước
        maxHeight: 1920,
      );

      if (image != null) {
        // Kiểm tra file có tồn tại không
        final file = File(image.path);
        if (await file.exists()) {
          final newImages = List<XFile>.from(widget.images)..add(image);
          widget.onImagesChanged(newImages);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không tìm thấy file ảnh'),
                backgroundColor: DesignColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    final newImages = List<XFile>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(newImages);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
                child: Icon(Icons.image, size: 20, color: DesignColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'HÌNH ẢNH',
                  style:
                      TextStyle(
                        fontSize: DesignTypography.labelSmallSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ).copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
              ),
              if (widget.images.isNotEmpty)
                Text(
                  '${widget.images.length}/${widget.maxImages}',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),

          if (widget.images.isEmpty)
            OutlinedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('Thêm hình ảnh'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: DesignColors.primary.withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: DesignSpacing.sm,
                mainAxisSpacing: DesignSpacing.sm,
                childAspectRatio: 1.0,
              ),
              itemCount:
                  widget.images.length +
                  (widget.images.length < widget.maxImages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < widget.images.length) {
                  return _buildImageThumbnail(context, isDark, index);
                } else {
                  return _buildAddImageButton(context, isDark);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, bool isDark, int index) {
    final image = widget.images[index];
    final file = File(image.path);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          child: FutureBuilder<bool>(
            future: file.exists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              }

              return Image.file(
                file,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 40),
                        const SizedBox(height: 4),
                        Text(
                          'Lỗi tải ảnh',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: DesignColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

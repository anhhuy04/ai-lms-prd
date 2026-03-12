import 'dart:async';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// Teacher Feedback Editor - Cho phép GV sửa lời phê AI
/// Có debounce 1000ms để tránh gọi API quá nhiều
class TeacherFeedbackEditor extends StatefulWidget {
  final String answerId;
  final String? aiFeedback;
  final String? teacherFeedback;
  final void Function(String feedback) onSave;

  const TeacherFeedbackEditor({
    super.key,
    required this.answerId,
    this.aiFeedback,
    this.teacherFeedback,
    required this.onSave,
  });

  @override
  State<TeacherFeedbackEditor> createState() => _TeacherFeedbackEditorState();
}

class _TeacherFeedbackEditorState extends State<TeacherFeedbackEditor> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize with teacher feedback if exists, otherwise use AI feedback
    _controller = TextEditingController(
      text: widget.teacherFeedback ?? widget.aiFeedback ?? '',
    );
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges = _controller.text != (widget.teacherFeedback ?? widget.aiFeedback ?? '');
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }

    // Debounce 1000ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_hasChanges && _controller.text.isNotEmpty) {
        _saveFeedback();
      }
    });
  }

  Future<void> _saveFeedback() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      widget.onSave(_controller.text);
      AppLogger.info('✅ Teacher feedback saved for answer: ${widget.answerId}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu lời phê'),
            duration: Duration(seconds: 1),
          ),
        );
        setState(() => _hasChanges = false);
      }
    } catch (e) {
      AppLogger.error('Error saving teacher feedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Force save on blur or on navigate away
  void forceSave() {
    _debounceTimer?.cancel();
    if (_hasChanges && _controller.text.isNotEmpty) {
      _saveFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiFeedbackText = _extractFeedbackText(widget.aiFeedback);

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: const Border(
          top: BorderSide(color: DesignColors.dividerMedium),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Feedback (read-only)
          if (aiFeedbackText.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: DesignColors.primary,
                ),
                const SizedBox(width: DesignSpacing.xs),
                Text(
                  'Feedback AI:',
                  style: DesignTypography.bodySmall?.copyWith(
                    color: DesignColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignSpacing.sm),
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                border: Border.all(
                  color: DesignColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                aiFeedbackText,
                style: DesignTypography.bodyMedium?.copyWith(
                  color: DesignColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: DesignSpacing.md),
          ],

          // Teacher Feedback (editable)
          Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 16,
                color: DesignColors.success,
              ),
              const SizedBox(width: DesignSpacing.xs),
              Text(
                'Lời phê của giáo viên:',
                style: DesignTypography.bodySmall?.copyWith(
                  color: DesignColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isSaving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_hasChanges)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.xs),
                  ),
                  child: Text(
                    'Chưa lưu',
                    style: DesignTypography.bodySmall?.copyWith(
                      color: DesignColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignSpacing.xs),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập lời phê cho học sinh...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                borderSide: const BorderSide(
                  color: DesignColors.success,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(DesignSpacing.sm),
            ),
            onEditingComplete: forceSave,
          ),
          const SizedBox(height: DesignSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: (_hasChanges && !_isSaving) ? forceSave : null,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Lưu ngay'),
            ),
          ),
        ],
      ),
    );
  }

  String _extractFeedbackText(dynamic feedback) {
    if (feedback == null) return '';
    if (feedback is String) return feedback;
    if (feedback is Map) {
      // Extract text from JSON structure like {text: "..."}
      return feedback['text']?.toString() ?? feedback.toString();
    }
    return feedback.toString();
  }
}

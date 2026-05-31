import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/sync_result.dart';
import 'package:ai_mls/presentation/providers/ghost_report_provider.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';

/// Cảnh báo banner trong assignment builder khi có câu hỏi inline (ghost)
/// chưa được đồng bộ vào Question Bank.
///
/// Chỉ hiển thị cho draft assignments. Published assignments giữ
/// immutable snapshot nên không cần đồng bộ.
///
/// Dismiss chỉ trong session — banner xuất hiện lại sau khi reload.
class GhostQuestionsBanner extends ConsumerStatefulWidget {
  final String assignmentId;
  final bool isDraft;
  final VoidCallback? onSyncSuccess;

  const GhostQuestionsBanner({
    super.key,
    required this.assignmentId,
    required this.isDraft,
    this.onSyncSuccess,
  });

  @override
  ConsumerState<GhostQuestionsBanner> createState() =>
      _GhostQuestionsBannerState();
}

class _GhostQuestionsBannerState extends ConsumerState<GhostQuestionsBanner> {
  bool _dismissed = false;
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    // Published assignments use immutable snapshot — không cần sync.
    if (!widget.isDraft || _dismissed) return const SizedBox.shrink();

    final reportAsync = ref.watch(ghostReportProvider(widget.assignmentId));
    return reportAsync.when(
      data: (report) {
        if (!report.hasGhosts) return const SizedBox.shrink();
        return _buildBanner(report.ghostCount);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(int count) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.warning.withValues(alpha: 0.15),
        border:
            Border.all(color: DesignColors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Semantics(
        liveRegion: true,
        label: 'Cảnh báo: $count câu hỏi chưa đồng bộ vào kho',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: DesignColors.warning,
              size: 24,
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phát hiện $count câu chưa đồng bộ vào kho',
                    style: DesignTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Đồng bộ để có thể chỉnh sửa từ Ngân hàng câu hỏi.',
                    style: DesignTypography.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            if (_isSyncing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: _handleSync,
                child: const Text('Đồng bộ ngay'),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(() => _dismissed = true),
              tooltip: 'Tạm ẩn',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đồng bộ vào Ngân hàng câu hỏi?'),
        content: const Text(
          'Câu hỏi trùng sẽ được liên kết, câu mới sẽ tạo mới trong kho. '
          'Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng bộ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSyncing = true);
    AppLogger.info('[QuestionBank][Sync] rpc_start aid=${widget.assignmentId}');
    try {
      final SyncResult result = await ref
          .read(questionRepositoryProvider)
          .syncAssignmentToBank(widget.assignmentId);
      AppLogger.info(
          '[QuestionBank][Sync] rpc_done created=${result.created} linked=${result.linked}');
      if (!mounted) return;
      AppToast.success(context, 'Đã tạo ${result.created} mới, liên kết ${result.linked} câu trùng');
      ref.invalidate(ghostReportProvider(widget.assignmentId));
      widget.onSyncSuccess?.call();
    } catch (e) {
      AppLogger.error('[QuestionBank][Sync] rpc_failed', error: e);
      if (!mounted) return;
      AppToast.error(context, 'Lỗi đồng bộ: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }
}

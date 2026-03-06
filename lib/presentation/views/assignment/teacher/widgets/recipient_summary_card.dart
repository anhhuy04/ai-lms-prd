import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart';
import 'package:flutter/material.dart';

/// Lựa chọn đối tượng nhận bài
class RecipientSummaryCard extends StatelessWidget {
  final RecipientSelectionResult? selection;
  final bool isDark;
  final VoidCallback onModify;

  const RecipientSummaryCard({
    super.key,
    required this.selection,
    required this.isDark,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selection != null && !selection!.isEmpty;
    final totalClasses = selection?.totalClasses ?? 0;
    final totalGroups = selection?.totalGroups ?? 0;
    final totalStudents = selection?.totalStudents ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSelection ? 'Tổng quan phân bố' : 'Chưa chọn đối tượng',
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                if (hasSelection)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Đã chọn: $totalClasses Lớp, $totalGroups Nhóm, $totalStudents Học sinh',
                      style: DesignTypography.caption.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Bấm "Thay đổi" để chọn lớp hoặc nhóm',
                      style: DesignTypography.caption.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onModify,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Thay đổi',
              style: DesignTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:flutter/material.dart';

/// Widget quản lý phân phối bài tập (class, group, individual students)
class AssignmentDistributionManager extends StatefulWidget {
  final List<AssignmentDistribution> distributions;
  final ValueChanged<List<AssignmentDistribution>> onDistributionsChanged;
  final String? classId; // Class ID của assignment (nếu có)

  const AssignmentDistributionManager({
    super.key,
    required this.distributions,
    required this.onDistributionsChanged,
    this.classId,
  });

  @override
  State<AssignmentDistributionManager> createState() =>
      _AssignmentDistributionManagerState();
}

class _AssignmentDistributionManagerState
    extends State<AssignmentDistributionManager> {
  late List<AssignmentDistribution> _distributions;

  @override
  void initState() {
    super.initState();
    _distributions = List.from(widget.distributions);
  }

  @override
  void didUpdateWidget(AssignmentDistributionManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.distributions != oldWidget.distributions) {
      _distributions = List.from(widget.distributions);
    }
  }

  void _notifyChange() {
    widget.onDistributionsChanged(_distributions);
  }

  void _addDistribution() {
    // TODO: Show dialog to add distribution
    // For now, add a placeholder
    setState(() {
      _distributions = [
        ..._distributions,
        AssignmentDistribution(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          assignmentId: '',
          distributionType: 'class',
          classId: widget.classId,
        ),
      ];
      _notifyChange();
    });
  }

  void _removeDistribution(int index) {
    setState(() {
      _distributions.removeAt(index);
      _notifyChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                    ),
                    child: Icon(
                      Icons.send,
                      size: 20,
                      color: DesignColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PHÂN PHỐI BÀI TẬP',
                    style: TextStyle(
                      fontSize: DesignTypography.labelSmallSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ).copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _addDistribution,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          if (_distributions.isEmpty)
            Container(
              padding: EdgeInsets.all(DesignSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Text(
                    'Chưa có phân phối nào',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  Text(
                    'Thêm phân phối để gửi bài tập đến lớp, nhóm hoặc học sinh cụ thể',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._distributions.asMap().entries.map((entry) {
              final index = entry.key;
              final distribution = entry.value;
              return _buildDistributionItem(context, isDark, distribution, index);
            }),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(
    BuildContext context,
    bool isDark,
    AssignmentDistribution distribution,
    int index,
  ) {
    String typeLabel;
    IconData typeIcon;
    switch (distribution.distributionType) {
      case 'class':
        typeLabel = 'Toàn bộ lớp';
        typeIcon = Icons.group;
        break;
      case 'group':
        typeLabel = 'Nhóm';
        typeIcon = Icons.group_work;
        break;
      case 'individual':
        typeLabel = 'Học sinh cụ thể';
        typeIcon = Icons.person;
        break;
      default:
        typeLabel = 'Không xác định';
        typeIcon = Icons.help_outline;
    }

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(typeIcon, size: 18, color: DesignColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                if (distribution.dueAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Hết hạn: ${_formatDateTime(distribution.dueAt!)}',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeDistribution(index),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: DesignColors.error,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

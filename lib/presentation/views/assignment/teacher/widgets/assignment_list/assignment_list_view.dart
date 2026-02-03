import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/widgets/refresh/app_refresh_indicator.dart';
import 'package:flutter/material.dart';

/// Reusable list view widget cho assignment list
class AssignmentListView extends StatelessWidget {
  final List<Assignment> assignments;
  final AssignmentBadgeConfig badgeConfig;
  final AssignmentActionConfig Function(Assignment) actionBuilder;
  final AssignmentMetadataConfig metadataConfig;
  final AssignmentEmptyState emptyState;
  final VoidCallback onRefresh;

  /// Optional tap handler cho cả card.
  /// Nếu truyền, khi tap vào card sẽ gọi hàm này (có thể dùng để điều hướng + reload).
  final Future<void> Function(Assignment)? onTap;

  /// Optional delete handler. Nếu được truyền, list sẽ hỗ trợ swipe-to-delete.
  /// onDelete should return true nếu xóa thành công (để Dismissible hoàn tất).
  final Future<bool> Function(Assignment)? onDelete;

  const AssignmentListView({
    super.key,
    required this.assignments,
    required this.badgeConfig,
    required this.actionBuilder,
    required this.metadataConfig,
    required this.emptyState,
    required this.onRefresh,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: assignments.isEmpty
          ? emptyState
          : ListView.builder(
              padding: EdgeInsets.all(DesignSpacing.lg),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final card = AssignmentCard(
                  assignment: assignment,
                  badgeConfig: badgeConfig,
                  onTap: onTap != null ? () => onTap!(assignment) : null,
                  actionConfig: actionBuilder(assignment),
                  metadataConfig: metadataConfig,
                );

                if (onDelete == null) return card;

                return Dismissible(
                  key: ValueKey(assignment.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: DesignColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignRadius.lg * 1.5,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                    child: Icon(
                      Icons.delete_outline,
                      color: DesignColors.error,
                    ),
                  ),
                  confirmDismiss: (_) => onDelete!(assignment),
                  child: card,
                );
              },
            ),
    );
  }
}

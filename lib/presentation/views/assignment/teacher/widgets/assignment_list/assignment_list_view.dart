import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/widgets/refresh/app_refresh_indicator.dart';
import 'package:flutter/material.dart';

/// Reusable list view widget cho assignment list.
///
/// Có 2 cách cấu hình badge/metadata:
///   • Cố định cùng cho mọi item: truyền [badgeConfig] + [metadataConfig].
///   • Per-card (vd. trang "Tất cả" trộn cả nháp + xuất bản): truyền
///     [badgeConfigBuilder] / [metadataConfigBuilder]. Builder được ưu tiên
///     nếu có; fallback về config cố định.
class AssignmentListView extends StatelessWidget {
  final List<Assignment> assignments;
  final AssignmentBadgeConfig badgeConfig;
  final AssignmentBadgeConfig Function(Assignment)? badgeConfigBuilder;
  final AssignmentActionConfig Function(Assignment) actionBuilder;
  final AssignmentMetadataConfig metadataConfig;
  final AssignmentMetadataConfig Function(Assignment)? metadataConfigBuilder;
  final AssignmentEmptyState emptyState;
  final VoidCallback onRefresh;

  /// Optional tap handler cho cả card.
  /// Nếu truyền, khi tap vào card sẽ gọi hàm này (có thể dùng để điều hướng + reload).
  final Future<void> Function(Assignment)? onTap;

  /// Optional delete handler. Nếu được truyền, list sẽ hỗ trợ swipe-to-delete.
  /// onDelete should return true nếu xóa thành công (để Dismissible hoàn tất).
  final Future<bool> Function(Assignment)? onDelete;

  /// Per-item delete enable: khi truyền và trả false → item đó không cho swipe.
  /// Dùng khi list trộn (vd. mode "Tất cả") chỉ cho xoá bài nháp.
  final bool Function(Assignment)? canDelete;

  const AssignmentListView({
    super.key,
    required this.assignments,
    required this.badgeConfig,
    required this.actionBuilder,
    required this.metadataConfig,
    required this.emptyState,
    required this.onRefresh,
    this.badgeConfigBuilder,
    this.metadataConfigBuilder,
    this.onTap,
    this.onDelete,
    this.canDelete,
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
                final effectiveBadge =
                    badgeConfigBuilder?.call(assignment) ?? badgeConfig;
                final effectiveMeta = metadataConfigBuilder?.call(assignment) ??
                    metadataConfig;
                final card = AssignmentCard(
                  assignment: assignment,
                  badgeConfig: effectiveBadge,
                  onTap: onTap != null ? () => onTap!(assignment) : null,
                  actionConfig: actionBuilder(assignment),
                  metadataConfig: effectiveMeta,
                );

                final allowSwipe = onDelete != null &&
                    (canDelete?.call(assignment) ?? true);
                if (!allowSwipe) return card;

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

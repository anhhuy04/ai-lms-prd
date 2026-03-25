import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart' show Recommendation, RecommendationPriority, RecommendationType;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// RecommendationCard: Universal card for displaying recommendations.
/// Used by both Teacher (intervention) and Student (learning resource).
/// Supports: priority badge, title, description, resource chips, dismiss.
class RecommendationCard extends ConsumerWidget {
  final Recommendation recommendation;
  final VoidCallback? onDismiss;
  final bool compact;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onDismiss,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = recommendation;

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: _getBorderColor(rec.priority),
          width: rec.isUrgent ? 1.5 : 1.0,
        ),
        boxShadow: [DesignElevation.level2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: priority badge + dismiss
          Padding(
            padding: EdgeInsets.all(compact ? DesignSpacing.sm : DesignSpacing.md),
            child: Row(
              children: [
                _buildPriorityBadge(rec.priority),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    rec.title,
                    style: compact
                        ? DesignTypography.titleSmall
                        : DesignTypography.titleMedium,
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: DesignIcons.smSize,
                      color: Colors.grey,
                    ),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'An goi y',
                  ),
              ],
            ),
          ),

          // Description
          if (rec.description.isNotEmpty && !compact) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              child: Text(
                rec.description,
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
          ],

          // Resource chips
          if (rec.hasResources) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              child: _buildResourceChips(context, rec, compact),
            ),
            SizedBox(height: DesignSpacing.sm),
          ],

          // Type badge + created date
          Padding(
            padding: EdgeInsets.fromLTRB(
              DesignSpacing.md,
              0,
              DesignSpacing.md,
              compact ? DesignSpacing.sm : DesignSpacing.md,
            ),
            child: Row(
              children: [
                _buildTypeBadge(rec.type),
                const Spacer(),
                if (rec.createdAt != null)
                  Text(
                    _formatDate(rec.createdAt!),
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(RecommendationPriority priority) {
    final (label, color) = _getPriorityConfig(priority);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Text(
        label,
        style: DesignTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildTypeBadge(RecommendationType type) {
    final label = switch (type) {
      RecommendationType.peerComparison => 'So sanh',
      RecommendationType.skillGap => 'Ky nang yeu',
      RecommendationType.intervention => 'Can thiep',
      RecommendationType.lateSubmissionAlert => 'Nop muon',
      RecommendationType.engagementAlert => 'Canh bao tham gia',
      RecommendationType.atRiskWarning => 'Rui ro',
      RecommendationType.assignmentSuggestion => 'Goi y bai tap',
      RecommendationType.studyTip => 'Meo hoc tap',
      RecommendationType.improvementOpportunity => 'Co hoi cai thien',
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Text(
        label,
        style: DesignTypography.labelSmall.copyWith(
          color: DesignColors.primary,
        ),
      ),
    );
  }

  Widget _buildResourceChips(BuildContext context, Recommendation rec, bool compact) {
    final chips = <Widget>[];

    for (final assignmentId in rec.exercises.take(compact ? 1 : 3)) {
      chips.add(_buildResourceChip(
        icon: Icons.edit_note,
        label: 'On tap',
        onTap: () => _navigateToExercise(context, assignmentId),
      ));
    }

    for (final videoUrl in rec.videos.take(compact ? 1 : 2)) {
      chips.add(_buildResourceChip(
        icon: Icons.play_circle_outline,
        label: 'Video',
        onTap: () => _launchUrl(videoUrl),
      ));
    }

    for (final docUrl in rec.documents.take(compact ? 1 : 2)) {
      chips.add(_buildResourceChip(
        icon: Icons.description_outlined,
        label: 'Tai lieu',
        onTap: () => _launchUrl(docUrl),
      ));
    }

    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.xs,
      children: chips,
    );
  }

  Future<void> _navigateToExercise(BuildContext context, String distributionId) async {
    if (context.mounted) {
      context.pushNamed(
        AppRoute.studentAssignmentWorkspace,
        pathParameters: {'distributionId': distributionId},
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildResourceChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.full),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DesignRadius.full),
          border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: DesignColors.primary),
            SizedBox(width: DesignSpacing.xs),
            Text(
              label,
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return DesignColors.error;
      case RecommendationPriority.medium:
        return DesignColors.warning;
      case RecommendationPriority.low:
        return Colors.grey.shade300;
    }
  }

  (String label, Color color) _getPriorityConfig(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return ('Khan cap', DesignColors.error);
      case RecommendationPriority.medium:
        return ('Cao', DesignColors.warning);
      case RecommendationPriority.low:
        return ('Thap', Colors.grey);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hom nay';
    if (diff.inDays == 1) return 'Hom qua';
    if (diff.inDays < 7) return '${diff.inDays} ngay truoc';
    return '${date.day}/${date.month}';
  }
}

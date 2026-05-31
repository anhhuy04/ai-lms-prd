import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/recommendation_card.dart';
import 'package:ai_mls/widgets/responsive/wide_content_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

/// StudentRecommendationsTab: "Hop thuoc dau giuong" pillbox (REC-02).
/// Shows student recommendations (LIMIT 20).
/// Compact cards, quick access to learning resources.
class StudentRecommendationsTab extends ConsumerWidget {
  const StudentRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(studentRecommendationNotifierProvider());

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Gợi ý học tập',
          style: DesignTypography.titleLarge,
        ),
        automaticallyImplyLeading: true,
      ),
      body: WideContentWrapper(
        child: recsAsync.when(
        data: (recs) {
          if (recs.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentRecommendationNotifierProvider());
            },
            child: ListView.builder(
              padding: EdgeInsets.all(DesignSpacing.md),
              itemCount: recs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeaderCard(recs.length);
                }

                final rec = recs[index - 1];
                return RecommendationCard(
                  recommendation: rec,
                  compact: true,
                  onDismiss: () async {
                    await _dismiss(ref, rec.id);
                    if (context.mounted) {
                      AppToast.info(context, 'Đã xóa gợi ý');
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(ref, e.toString()),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int count) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignColors.primary.withValues(alpha: 0.10),
            DesignColors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(Icons.auto_awesome_rounded,
                color: DesignColors.primary, size: 24),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dành cho bạn',
                  style: DesignTypography.titleMedium.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$count gợi ý dựa trên kết quả học tập gần đây',
                  style: DesignTypography.bodySmall
                      .copyWith(color: DesignColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: DesignColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.thumb_up_rounded,
                size: 56,
                color: DesignColors.success,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Bạn đang học rất tốt!',
              style: DesignTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Tiếp tục làm bài để duy trì phong độ.\nGợi ý sẽ xuất hiện khi cần.',
              style: DesignTypography.bodyMedium
                  .copyWith(color: DesignColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(DesignSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 80,
            margin: EdgeInsets.only(bottom: DesignSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: DesignColors.error),
            SizedBox(height: DesignSpacing.md),
            Text('Lỗi tải dữ liệu',
                style: DesignTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: DesignSpacing.xs),
            Text(
              error,
              style: DesignTypography.bodySmall
                  .copyWith(color: DesignColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              onPressed: () =>
                  ref.invalidate(studentRecommendationNotifierProvider()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.lg,
                    vertical: DesignSpacing.sm),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dismiss(WidgetRef ref, String recommendationId) async {
    await ref.read(
      dismissRecommendationProvider(recommendationId: recommendationId).notifier,
    ).dismiss();
    // Also invalidate top3RecommendationsProvider so home dashboard updates
    ref.invalidate(top3RecommendationsProvider);
  }
}

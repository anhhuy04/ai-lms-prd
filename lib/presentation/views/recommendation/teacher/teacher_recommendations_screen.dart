import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/recommendation_card.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Filter mode for teacher recommendations
enum _FilterMode { all, urgent }

/// TeacherRecommendationsScreen: Full recommendations list for teachers (REC-01).
/// Shows all intervention suggestions across all classes.
/// Includes filter chips at top.
class TeacherRecommendationsScreen extends ConsumerStatefulWidget {
  const TeacherRecommendationsScreen({super.key});

  @override
  ConsumerState<TeacherRecommendationsScreen> createState() =>
      _TeacherRecommendationsScreenState();
}

class _TeacherRecommendationsScreenState
    extends ConsumerState<TeacherRecommendationsScreen> {
  String? _selectedClassId;
  _FilterMode _filterMode = _FilterMode.all;

  @override
  Widget build(BuildContext context) {
    final recsAsync = ref.watch(
      teacherRecommendationNotifierProvider(classId: _selectedClassId),
    );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(recsAsync),
          _buildFilterRow(),
          Expanded(
            child: recsAsync.when(
              data: (recs) {
                if (recs.isEmpty) {
                  return _buildEmptyState();
                }

                // Apply filter: urgent = priorityValue <= 2 (high + medium)
                final urgent = recs.where((r) => r.priorityValue <= 2).toList();
                final normal = recs.where((r) => r.priorityValue > 2).toList();

                // Filter display based on mode
                final showUrgent = _filterMode == _FilterMode.all || _filterMode == _FilterMode.urgent;
                final showNormal = _filterMode == _FilterMode.all;

                final isFilteredEmpty =
                    (showUrgent ? urgent.isEmpty : true) &&
                        (showNormal ? normal.isEmpty : true);
                if (isFilteredEmpty) {
                  return _buildFilterEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      teacherRecommendationNotifierProvider(classId: _selectedClassId),
                    );
                  },
                  child: ListView(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    children: [
                      if (showUrgent && urgent.isNotEmpty) ...[
                        _buildSectionHeader(
                            'Cần chú ý', DesignColors.error, urgent.length),
                        ...urgent.map((rec) => RecommendationCard(
                              recommendation: rec,
                              onDismiss: () => _dismiss(rec.id),
                            )),
                        SizedBox(height: DesignSpacing.lg),
                      ],
                      if (showNormal && normal.isNotEmpty) ...[
                        _buildSectionHeader(
                            'Gợi ý khác', DesignColors.primary, normal.length),
                        ...normal.map((rec) => RecommendationCard(
                              recommendation: rec,
                              onDismiss: () => _dismiss(rec.id),
                            )),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (e, _) => _buildErrorState(e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(AsyncValue recsAsync) {
    final recs = recsAsync.valueOrNull;
    if (recs == null) return const SizedBox.shrink();
    final urgentCount =
        (recs as List).where((r) => r.priorityValue <= 2).length;
    final totalCount = recs.length;
    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(
          DesignSpacing.md, DesignSpacing.md, DesignSpacing.md, 0),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignColors.error.withValues(alpha: 0.08),
            DesignColors.warning.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
            color: DesignColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DesignColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(Icons.insights_rounded,
                color: DesignColors.error, size: 24),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$urgentCount học sinh cần chú ý',
                  style: DesignTypography.titleMedium.copyWith(
                    color: DesignColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tổng $totalCount gợi ý từ kết quả học tập gần đây',
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

  Widget _buildFilterEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off_outlined,
                size: 48, color: DesignColors.textTertiary),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Không có gợi ý phù hợp với bộ lọc',
              style: DesignTypography.bodyMedium
                  .copyWith(color: DesignColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Row(
        children: [
          _buildFilterChip(
            icon: Icons.list_rounded,
            label: 'Tất cả',
            selected: _filterMode == _FilterMode.all,
            mode: _FilterMode.all,
          ),
          SizedBox(width: DesignSpacing.sm),
          _buildFilterChip(
            icon: Icons.priority_high_rounded,
            label: 'Khẩn cấp',
            selected: _filterMode == _FilterMode.urgent,
            mode: _FilterMode.urgent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool selected,
    required _FilterMode mode,
  }) {
    final activeColor = mode == _FilterMode.urgent
        ? DesignColors.error
        : DesignColors.primary;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? activeColor : DesignColors.textSecondary,
      ),
      label: Text(
        label,
        style: DesignTypography.labelMedium.copyWith(
          color: selected ? activeColor : DesignColors.textPrimary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() {
          _filterMode = mode;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: activeColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: selected ? activeColor : DesignColors.dividerLight,
        width: selected ? 1.2 : 1,
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: DesignSpacing.sm,
        top: DesignSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Text(
            title,
            style: DesignTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
            ),
            child: Text(
              '$count',
              style: DesignTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // 5a: copy TRUNG TÍNH (gộp "chưa có dữ liệu" ∪ "không có cảnh báo"). Teacher không có
    // tín hiệu rẻ để phân biệt 2 trạng thái này (phải join nhiều lớp/HS) → không khẳng định
    // "Mọi học sinh đều ổn" (gây hiểu nhầm khi thực ra generator chưa chạy). Lỗi tải xử lý riêng.
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
                color: DesignColors.textTertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 56,
                color: DesignColors.textTertiary,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Chưa có gợi ý',
              style: DesignTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Gợi ý sẽ xuất hiện sau khi học sinh hoàn thành\nbài và hệ thống phân tích kết quả.',
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
            height: 120,
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

  Widget _buildErrorState(String error) {
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
              onPressed: () => ref.invalidate(
                teacherRecommendationNotifierProvider(classId: _selectedClassId),
              ),
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

  Future<void> _dismiss(String recommendationId) async {
    // Use notifier dismiss → updates local state immediately for smooth UX
    await ref.read(teacherRecommendationNotifierProvider(classId: _selectedClassId).notifier).dismiss(recommendationId);
    if (mounted) {
      AppToast.info(context, 'Đã xóa gợi ý');
    }
  }
}

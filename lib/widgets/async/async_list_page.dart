import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';

typedef AsyncItemWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// Generic async list page với:
/// - Future<List<T>> cho dữ liệu
/// - Shimmer skeleton trong lúc load
/// - Empty state & error state theo DesignTokens
class AsyncListPage<T> extends StatelessWidget {
  final Future<List<T>> future;
  final AsyncItemWidgetBuilder<T> itemBuilder;

  /// Skeleton hiển thị khi đang load – mặc định dùng ShimmerListTileLoading.
  final Widget? loadingSkeleton;

  /// Widget hiển thị khi danh sách rỗng.
  final Widget? emptyState;

  /// Widget hiển thị khi lỗi.
  final Widget Function(Object error)? errorBuilder;

  /// Padding chung cho ListView.
  final EdgeInsetsGeometry? padding;

  /// Physics của list (vd: BouncingScrollPhysics cho iOS feel).
  final ScrollPhysics? physics;

  const AsyncListPage({
    super.key,
    required this.future,
    required this.itemBuilder,
    this.loadingSkeleton,
    this.emptyState,
    this.errorBuilder,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = DesignSpacing.responsive(context);

    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        // 1) Đang load -> Shimmer
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingSkeleton ??
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.screenPadding,
                  vertical: spacing.paddingSmall,
                ),
                child: const ShimmerListTileLoading(),
              );
        }

        // 2) Lỗi
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return Center(child: errorBuilder!(snapshot.error!));
          }
          return _DefaultErrorState(error: snapshot.error);
        }

        final items = snapshot.data ?? <T>[];

        // 3) Không có dữ liệu
        if (items.isEmpty) {
          return emptyState ?? const _DefaultEmptyState();
        }

        // 4) Có dữ liệu -> ListView.builder
        return ListView.builder(
          padding: padding ??
              EdgeInsets.fromLTRB(
                spacing.screenPadding,
                spacing.paddingSmall,
                spacing.screenPadding,
                spacing.paddingLarge,
              ),
          physics: physics ?? const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index], index);
          },
        );
      },
    );
  }
}

class _DefaultEmptyState extends StatelessWidget {
  const _DefaultEmptyState();

  @override
  Widget build(BuildContext context) {
    final spacing = DesignSpacing.responsive(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: DesignIcons.lgSize,
              color: DesignColors.textTertiary,
            ),
            SizedBox(height: spacing.paddingSmall),
            Text(
              'Không có dữ liệu hiển thị',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultErrorState extends StatelessWidget {
  final Object? error;

  const _DefaultErrorState({this.error});

  @override
  Widget build(BuildContext context) {
    final spacing = DesignSpacing.responsive(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: DesignColors.error,
              size: DesignIcons.lgSize,
            ),
            SizedBox(height: spacing.paddingSmall),
            Text(
              'Đã xảy ra lỗi khi tải dữ liệu',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              SizedBox(height: spacing.paddingSmall),
              Text(
                '$error',
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


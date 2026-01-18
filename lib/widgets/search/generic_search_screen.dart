import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/search/search_config.dart';
import 'package:ai_mls/widgets/shimmer_loading.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Generic Search Screen widget có thể tái sử dụng cho nhiều loại dữ liệu
///
/// Sử dụng generic type T để hỗ trợ Class, Subject, Assignment, Student, ...
/// Tất cả behavior được customize qua SearchConfig<T>
class GenericSearchScreen<T> extends ConsumerStatefulWidget {
  final SearchConfig<T> config;

  GenericSearchScreen({super.key, required this.config}) {
    // Validate config khi khởi tạo
    config.validate();
  }

  @override
  ConsumerState<GenericSearchScreen<T>> createState() =>
      _GenericSearchScreenState<T>();
}

class _GenericSearchScreenState<T>
    extends ConsumerState<GenericSearchScreen<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Autofocus search field khi màn hình được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  @override
  void dispose() {
    // QUAN TRỌNG: Cancel debounce và dispose controllers
    EasyDebounce.cancel('search-debounce-${widget.config.debounceKey}');
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Xử lý search với debouncing
  /// Gọi refresh() khi query thay đổi để reset pageKey về 0
  void _onSearchChanged(String query, WidgetRef ref) {
    EasyDebounce.debounce(
      'search-debounce-${widget.config.debounceKey}',
      widget.config.debounceDuration,
      () {
        if (!mounted) return;

        // Update query provider
        final trimmedQuery = query.trim();
        ref.read(widget.config.searchQueryProvider.notifier).state =
            trimmedQuery.isEmpty ? null : trimmedQuery;

        // QUAN TRỌNG: Refresh để reset pageKey về 0
        final userId = widget.config.getUserId(ref);
        if (userId != null) {
          final pagingController = ref.read(
            widget.config.pagingControllerProvider(userId),
          );
          pagingController.refresh(); // Reset về trang 1
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.config.getUserId(ref);

    // Error state khi không lấy được userId
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.config.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: DesignIcons.xlSize,
                color: DesignColors.error.withOpacity(0.7),
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Không tìm thấy thông tin người dùng',
                style: DesignTypography.titleMedium.copyWith(
                  fontWeight: DesignTypography.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pagingController = ref.watch(
      widget.config.pagingControllerProvider(userId),
    );
    final searchQuery = ref.watch(widget.config.searchQueryProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: Text(widget.config.title, textAlign: TextAlign.center),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            _buildSearchField(context),
            SizedBox(height: DesignSpacing.md),
            // Danh sách kết quả với PagedListView
            Expanded(
              child: _buildSearchList(context, pagingController, searchQuery),
            ),
          ],
        ),
      ),
    );
  }

  /// Search field với autofocus, clear button, và textInputAction
  Widget _buildSearchField(BuildContext context) {
    final searchQuery = ref.watch(widget.config.searchQueryProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
        border: Border.all(color: DesignColors.dividerMedium),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true, // Tự động hiện bàn phím khi vào trang
        textInputAction: TextInputAction.search, // Đổi nút Enter thành Search
        decoration: InputDecoration(
          hintText: widget.config.hintText,
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: DesignColors.textTertiary),
          suffixIcon: (searchQuery != null && searchQuery.isNotEmpty)
              ? IconButton(
                  icon: Icon(Icons.clear, size: DesignIcons.smSize),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(widget.config.searchQueryProvider.notifier).state =
                        null;
                    final userId = widget.config.getUserId(ref);
                    if (userId != null) {
                      ref
                          .read(widget.config.pagingControllerProvider(userId))
                          .refresh();
                    }
                  },
                )
              : null,
        ),
        onChanged: (value) => _onSearchChanged(value, ref),
        onSubmitted: (value) {
          // Khi nhấn Search trên bàn phím, trigger search ngay
          _onSearchChanged(value, ref);
        },
      ),
    );
  }

  /// Danh sách kết quả với PagedListView
  Widget _buildSearchList(
    BuildContext context,
    PagingController<int, T> pagingController,
    String? searchQuery,
  ) {
    // Empty state khi chưa nhập query
    if (searchQuery == null || searchQuery.isEmpty) {
      if (widget.config.emptyStateBuilder != null) {
        return widget.config.emptyStateBuilder!(context);
      }

      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: DesignIcons.xxlSize,
                color: DesignColors.textTertiary,
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                widget.config.emptyStateMessage,
                style: DesignTypography.titleMedium.copyWith(
                  fontWeight: DesignTypography.bold,
                  color: DesignColors.textPrimary,
                ),
              ),
              if (widget.config.emptyStateSubtitle != null) ...[
                SizedBox(height: DesignSpacing.sm),
                Text(
                  widget.config.emptyStateSubtitle!,
                  style: DesignTypography.bodyMedium.copyWith(
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

    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        try {
          pagingController.refresh();
        } catch (e) {
          // Ignore errors during refresh
        }
      }),
      child: PagedListView<int, T>(
        pagingController: pagingController,
        scrollController: _scrollController,
        // QUAN TRỌNG: Keyboard dismiss khi scroll
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        builderDelegate: PagedChildBuilderDelegate<T>(
          itemBuilder: (context, item, index) {
            return widget.config.itemBuilder(context, item, searchQuery);
          },
          firstPageProgressIndicatorBuilder: (context) =>
              const ShimmerLoading(),
          newPageProgressIndicatorBuilder: (context) => Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: const Center(child: CircularProgressIndicator()),
          ),
          firstPageErrorIndicatorBuilder: (context) =>
              _buildErrorWidget(context, pagingController),
          newPageErrorIndicatorBuilder: (context) => Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Lỗi khi tải thêm dữ liệu',
                    style: TextStyle(color: DesignColors.error),
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  ElevatedButton(
                    onPressed: () => pagingController.retryLastFailedRequest(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => _buildNoResultsState(),
          noMoreItemsIndicatorBuilder: (context) => _buildNoMoreItems(),
        ),
      ),
    );
  }

  /// Error widget
  Widget _buildErrorWidget(
    BuildContext context,
    PagingController<int, T> pagingController,
  ) {
    final errorMessage = widget.config.errorMessageBuilder != null
        ? widget.config.errorMessageBuilder!(
            pagingController.error ?? Exception('Unknown error'),
          )
        : (pagingController.error?.toString() ?? 'Đã xảy ra lỗi');

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: DesignIcons.xlSize,
              color: DesignColors.error.withOpacity(0.7),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Đã xảy ra lỗi',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: DesignTypography.bold,
                color: DesignColors.error,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              errorMessage,
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => pagingController.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// No results state
  Widget _buildNoResultsState() {
    if (widget.config.noResultsBuilder != null) {
      return widget.config.noResultsBuilder!(context);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: DesignIcons.xxlSize,
              color: DesignColors.textTertiary,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              widget.config.noResultsMessage,
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: DesignTypography.bold,
                color: DesignColors.textPrimary,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// No more items widget
  Widget _buildNoMoreItems() {
    return Padding(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Center(
        child: Text(
          'Đã hiển thị tất cả kết quả',
          style: DesignTypography.caption.copyWith(
            color: DesignColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

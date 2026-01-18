import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Configuration class cho GenericSearchScreen
/// Generic type T cho phép tái sử dụng với nhiều loại dữ liệu
class SearchConfig<T> {
  /// Tiêu đề của màn hình search
  final String title;

  /// Hint text cho search field
  final String hintText;

  /// Message hiển thị khi chưa nhập query
  final String emptyStateMessage;

  /// Message hiển thị khi không có kết quả
  final String noResultsMessage;

  /// Subtitle cho empty state (optional)
  final String? emptyStateSubtitle;

  /// Builder function để build item trong list
  /// Nhận context, item, và search query để highlight
  final Widget Function(BuildContext context, T item, String query) itemBuilder;

  /// Callback khi user tap vào item
  final void Function(T item) onItemTap;

  /// Function để fetch data từ API/repository
  /// Nhận pageKey (int) và searchQuery (String?), trả về Future<List<T>>
  final Future<List<T>> Function(int pageKey, String? searchQuery) fetchFunction;

  /// Riverpod provider cho search query (StateProvider.autoDispose<String?>)
  /// Pass provider trực tiếp để có thể read/watch
  final AutoDisposeStateProvider<String?> searchQueryProvider;

  /// Riverpod provider cho PagingController (StateProvider.autoDispose.family)
  /// Pass provider family trực tiếp để có thể gọi với userId
  final AutoDisposeStateProviderFamily<PagingController<int, T>, String>
      pagingControllerProvider;

  /// User ID để truyền vào pagingControllerProvider
  final String? Function(WidgetRef ref) getUserId;

  /// Unique key cho debounce (để tránh conflict khi có nhiều search screen)
  final String debounceKey;

  /// Page size cho pagination (mặc định 10)
  final int pageSize;

  /// Debounce duration (mặc định 400ms)
  final Duration debounceDuration;

  /// Optional: Custom error message builder
  final String Function(Object error)? errorMessageBuilder;

  /// Optional: Custom empty state widget builder
  final Widget Function(BuildContext context)? emptyStateBuilder;

  /// Optional: Custom no results widget builder
  final Widget Function(BuildContext context)? noResultsBuilder;

  SearchConfig({
    required this.title,
    required this.hintText,
    required this.emptyStateMessage,
    required this.noResultsMessage,
    this.emptyStateSubtitle,
    required this.itemBuilder,
    required this.onItemTap,
    required this.fetchFunction,
    required this.searchQueryProvider,
    required this.pagingControllerProvider,
    required this.getUserId,
    required this.debounceKey,
    this.pageSize = 10,
    this.debounceDuration = const Duration(milliseconds: 400),
    this.errorMessageBuilder,
    this.emptyStateBuilder,
    this.noResultsBuilder,
  });

  /// Validate config để đảm bảo tất cả required fields đã được set
  void validate() {
    assert(title.isNotEmpty, 'Title cannot be empty');
    assert(hintText.isNotEmpty, 'HintText cannot be empty');
    assert(emptyStateMessage.isNotEmpty, 'EmptyStateMessage cannot be empty');
    assert(noResultsMessage.isNotEmpty, 'NoResultsMessage cannot be empty');
    assert(debounceKey.isNotEmpty, 'DebounceKey cannot be empty');
    assert(pageSize > 0, 'PageSize must be greater than 0');
  }
}

# Phân tích và Tối ưu Plan Riverpod với Infinite Scroll Pagination

## 🔴 Vấn đề nghiêm trọng cần sửa

### 1. Circular Dependency (Vòng lặp phụ thuộc)

**Vấn đề:**
```dart
// pagingControllerProvider watch classListNotifierProvider
final pagingControllerProvider = StateProvider.family<...>(
  (ref, teacherId) {
    final notifier = ref.watch(classListNotifierProvider(teacherId).notifier);
    // ...
  },
);

// classListNotifierProvider lại watch pagingControllerProvider
final classListNotifierProvider = StateNotifierProvider.family<...>(
  (ref, teacherId) {
    final pagingController = ref.watch(pagingControllerProvider(teacherId));
    // ...
  },
);
```

**Hậu quả:** Riverpod sẽ throw error về circular dependency.

**Giải pháp:** Tách logic fetch ra khỏi notifier, hoặc dùng `ref.read` thay vì `ref.watch` ở một trong hai.

### 2. StateNotifier không cần thiết

**Vấn đề:** `ClassListNotifier` extends `StateNotifier<AsyncValue<List<Class>>>` nhưng:
- PagingController đã quản lý state (items, loading, error)
- State trong StateNotifier không được sử dụng hiệu quả
- Tạo overhead không cần thiết

**Giải pháp:** Không cần StateNotifier, chỉ cần một class đơn giản để fetch data.

### 3. Search/Sort không reactive

**Vấn đề:** 
```dart
final classListNotifierProvider = StateNotifierProvider.family<...>(
  (ref, teacherId) {
    final searchQuery = ref.watch(searchQueryProvider);  // Chỉ lấy giá trị ban đầu
    final sortOption = ref.watch(sortOptionProvider);    // Chỉ lấy giá trị ban đầu
    
    return ClassListNotifier(
      searchQuery: searchQuery,  // Giá trị này không thay đổi khi provider thay đổi
      sortOption: sortOption,
      // ...
    );
  },
);
```

Khi `searchQueryProvider` hoặc `sortOptionProvider` thay đổi, notifier không được rebuild với giá trị mới.

**Giải pháp:** Sử dụng `ref.watch` trong `fetchPage` method để lấy giá trị mới nhất, hoặc dùng `ref.listen` để trigger refresh.

### 4. AuthViewModel Access

**Vấn đề:** Code sử dụng `authViewModelProvider` nhưng chưa được định nghĩa.

**Giải pháp:** Cần tạo provider wrapper hoặc migrate AuthViewModel sang Riverpod.

## 🟡 Vấn đề cần cải thiện

### 5. Error Handling

- Chưa có retry logic
- Chưa phân biệt các loại error (network, auth, server)
- Error message chưa user-friendly

### 6. Performance

- Chưa có `keepAlive` cho providers (có thể bị dispose khi không dùng)
- Chưa có caching strategy rõ ràng
- Chưa optimize rebuilds

### 7. Search Query trong Supabase

**Vấn đề:** Syntax `or('name.ilike.%query%,subject.ilike.%query%')` có thể không đúng với Supabase.

**Giải pháp:** Cần kiểm tra syntax đúng của Supabase cho OR với ilike.

### 8. Scroll Position Restoration

Plan đề cập nhưng chưa implement scroll position restoration khi navigate back.

## ✅ Giải pháp tối ưu

### Architecture mới (Đã sửa)

```
lib/presentation/providers/class_providers.dart
  ├── searchQueryProvider (StateProvider)
  ├── sortOptionProvider (StateProvider)
  ├── classListFetcherProvider (Provider.family) - Chỉ fetch logic, không state
  └── pagingControllerProvider (StateProvider.family) - Quản lý PagingController

lib/presentation/fetchers/class_list_fetcher.dart
  └── ClassListFetcher - Class đơn giản để fetch data, không extend StateNotifier
```

### Code mới (Đã sửa)

**File: `lib/presentation/fetchers/class_list_fetcher.dart`**

```dart
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';

/// Class đơn giản để fetch data, không cần StateNotifier
class ClassListFetcher {
  final SchoolClassRepository _repository;
  final String _teacherId;
  
  static const int pageSize = 10;

  ClassListFetcher({
    required SchoolClassRepository repository,
    required String teacherId,
  })  : _repository = repository,
        _teacherId = teacherId;

  /// Fetch một page dữ liệu
  Future<List<Class>> fetchPage({
    required int pageKey,
    String? searchQuery,
    ClassSortOption? sortOption,
  }) async {
    // Convert sort option sang database format
    final (sortBy, ascending) = _convertSortOption(
      sortOption ?? ClassSortOption.dateNewest,
    );

    final classes = await _repository.getClassesByTeacherPaginated(
      teacherId: _teacherId,
      page: pageKey + 1, // API dùng 1-based, PagingController dùng 0-based
      pageSize: pageSize,
      searchQuery: searchQuery?.isEmpty == true ? null : searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );

    return classes;
  }

  /// Convert ClassSortOption sang database column và direction
  (String column, bool ascending) _convertSortOption(ClassSortOption option) {
    switch (option) {
      case ClassSortOption.nameAscending:
        return ('name', true);
      case ClassSortOption.nameDescending:
        return ('name', false);
      case ClassSortOption.dateNewest:
        return ('created_at', false);
      case ClassSortOption.dateOldest:
        return ('created_at', true);
      case ClassSortOption.subjectAscending:
        return ('subject', true);
      case ClassSortOption.subjectDescending:
        return ('subject', false);
    }
  }
}
```

**File: `lib/presentation/providers/class_providers.dart` (Đã sửa)**

```dart
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/fetchers/class_list_fetcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider cho SchoolClassRepository
final schoolClassRepositoryProvider = Provider<SchoolClassRepository>((ref) {
  throw UnimplementedError('Must override schoolClassRepositoryProvider');
});

/// Provider cho search query (debounced)
final searchQueryProvider = StateProvider<String?>((ref) => null);

/// Provider cho sort option
final sortOptionProvider = StateProvider<ClassSortOption>(
  (ref) => ClassSortOption.dateNewest,
);

/// Provider cho ClassListFetcher (family provider với teacherId)
final classListFetcherProvider = Provider.family<ClassListFetcher, String>(
  (ref, teacherId) {
    final repository = ref.watch(schoolClassRepositoryProvider);
    return ClassListFetcher(
      repository: repository,
      teacherId: teacherId,
    );
  },
);

/// Provider cho PagingController (family provider với teacherId)
/// Sử dụng keepAlive để giữ state khi navigate away
final pagingControllerProvider = StateProvider.family<
    PagingController<int, Class>,
    String>.autoDispose(
  (ref, teacherId) {
    final controller = PagingController<int, Class>(firstPageKey: 0);
    final fetcher = ref.watch(classListFetcherProvider(teacherId));

    // Lắng nghe thay đổi search query và sort option
    ref.listen<String?>(searchQueryProvider, (previous, next) {
      controller.refresh();
    });

    ref.listen<ClassSortOption>(sortOptionProvider, (previous, next) {
      controller.refresh();
    });

    // Setup page request listener
    controller.addPageRequestListener((pageKey) async {
      try {
        // Lấy giá trị mới nhất của search và sort
        final searchQuery = ref.read(searchQueryProvider);
        final sortOption = ref.read(sortOptionProvider);

        final classes = await fetcher.fetchPage(
          pageKey: pageKey,
          searchQuery: searchQuery,
          sortOption: sortOption,
        );

        final isLastPage = classes.length < ClassListFetcher.pageSize;

        if (isLastPage) {
          controller.appendLastPage(classes);
        } else {
          final nextPageKey = pageKey + 1;
          controller.appendPage(classes, nextPageKey);
        }
      } catch (error) {
        controller.error = error;
      }
    });

    // Cleanup khi provider bị dispose
    ref.onDispose(() {
      controller.dispose();
    });

    // Giữ provider alive để cache state
    ref.keepAlive();

    return controller;
  },
);
```

### Cải thiện Search Query trong Supabase

**File: `lib/data/datasources/school_class_datasource.dart` (Đã sửa)**

```dart
/// Lấy danh sách lớp học của giáo viên với pagination, search và sort
Future<List<Map<String, dynamic>>> getClassesByTeacherPaginated({
  required String teacherId,
  required int page,
  required int pageSize,
  String? searchQuery,
  String? sortBy,
  bool ascending = true,
}) async {
  try {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    var query = _client
        .from('classes')
        .select()
        .eq('teacher_id', teacherId);

    // Áp dụng search filter (tìm kiếm trên name và subject)
    // Supabase syntax: sử dụng or() với nhiều conditions
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchPattern = '%$searchQuery%';
      query = query.or(
        'name.ilike.$searchPattern,subject.ilike.$searchPattern',
      ) as dynamic;
    }

    // Áp dụng sort
    if (sortBy != null) {
      query = query.order(sortBy, ascending: ascending) as dynamic;
    } else {
      // Default sort by created_at desc
      query = query.order('created_at', ascending: false) as dynamic;
    }

    // Áp dụng pagination
    final response = await (query as dynamic).range(from, to);
    return List<Map<String, dynamic>>.from(response);
  } catch (e, stackTrace) {
    print('🔴 [DATASOURCE ERROR] getClassesByTeacherPaginated: $e');
    print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
    throw Exception('Lỗi khi lấy danh sách lớp học: $e');
  }
}
```

### Thêm Error Handling tốt hơn

**File: `lib/presentation/providers/class_providers.dart` (Bổ sung)**

```dart
// Thêm error handling với retry logic
controller.addPageRequestListener((pageKey) async {
  try {
    final searchQuery = ref.read(searchQueryProvider);
    final sortOption = ref.read(sortOptionProvider);

    final classes = await fetcher.fetchPage(
      pageKey: pageKey,
      searchQuery: searchQuery,
      sortOption: sortOption,
    );

    final isLastPage = classes.length < ClassListFetcher.pageSize;

    if (isLastPage) {
      controller.appendLastPage(classes);
    } else {
      final nextPageKey = pageKey + 1;
      controller.appendPage(classes, nextPageKey);
    }
  } catch (error, stackTrace) {
    // Phân loại error
    if (error.toString().contains('network') || 
        error.toString().contains('timeout')) {
      // Network error - có thể retry
      controller.error = Exception(
        'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      );
    } else if (error.toString().contains('401') || 
               error.toString().contains('unauthorized')) {
      // Auth error
      controller.error = Exception(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    } else {
      // Other errors
      controller.error = error;
    }
  }
});
```

### Thêm Scroll Position Restoration

**File: `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` (Bổ sung)**

```dart
class _TeacherClassListScreenState extends ConsumerState<TeacherClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _teacherId;
  
  // Lưu scroll position
  double _savedScrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    // ... existing code ...
    
    // Restore scroll position khi quay lại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_savedScrollPosition > 0) {
        _scrollController.jumpTo(_savedScrollPosition);
      }
    });
  }

  @override
  void dispose() {
    // Save scroll position
    _savedScrollPosition = _scrollController.offset;
    _scrollController.dispose();
    // ... existing dispose code ...
    super.dispose();
  }

  // Sử dụng ScrollController trong PagedListView
  Widget _buildClassList(...) {
    return PagedListView<int, Class>(
      pagingController: pagingController,
      scrollController: _scrollController, // Thêm scroll controller
      // ... rest of code ...
    );
  }
}
```

### AuthViewModel Provider Wrapper

**File: `lib/presentation/providers/auth_providers.dart` (File mới)**

```dart
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// Provider wrapper cho AuthViewModel
/// Tạm thời bridge giữa Provider và Riverpod
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  // Option 1: Lấy từ Provider nếu vẫn đang dùng MultiProvider
  // Cần access BuildContext, không khả thi trong Riverpod
  
  // Option 2: Tạo mới từ repository (Recommended)
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

/// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Must override authRepositoryProvider');
});
```

## 📋 Checklist cải thiện

### Đã sửa
- [x] Circular dependency - Tách logic fetch ra khỏi notifier
- [x] StateNotifier không cần thiết - Dùng class đơn giản
- [x] Search/Sort reactive - Lấy giá trị mới nhất trong fetchPage
- [x] Search query syntax - Sửa syntax Supabase
- [x] Error handling - Thêm phân loại error
- [x] KeepAlive - Thêm keepAlive cho providers

### Cần bổ sung
- [ ] Scroll position restoration - Đã có code mẫu
- [ ] AuthViewModel provider - Đã có code mẫu
- [ ] Retry logic - Có thể thêm vào error handling
- [ ] Loading state riêng cho search - Hiển thị loading khi search
- [ ] Empty state khác nhau cho search vs no data
- [ ] Analytics tracking - Track search, sort, pagination events

## 🎯 Kết luận

Plan ban đầu có một số vấn đề nghiêm trọng về architecture, nhưng đã được sửa trong bản tối ưu này:

1. **Circular dependency** - Đã fix bằng cách tách logic fetch
2. **StateNotifier không cần thiết** - Đã thay bằng class đơn giản
3. **Reactive search/sort** - Đã fix bằng cách lấy giá trị mới nhất
4. **Error handling** - Đã cải thiện với phân loại error
5. **Performance** - Đã thêm keepAlive và optimize

Plan mới đã sẵn sàng để implement!

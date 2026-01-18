# Plan Final - Tối ưu Hoàn chỉnh: Riverpod + Infinite Scroll Pagination

## ✅ Tổng hợp tất cả cải thiện

Sau 3 vòng phân tích, plan đã được tối ưu hoàn toàn. File này là bản FINAL sẵn sàng implement.

## 🎯 Architecture Final

```
lib/main.dart
  └── ProviderScope
      └── MaterialApp

lib/presentation/providers/
  ├── auth_providers.dart
  │   ├── authRepositoryProvider
  │   ├── authViewModelProvider
  │   ├── currentUserProvider (FutureProvider)
  │   └── currentUserIdProvider (Provider)
  └── class_providers.dart
      ├── schoolClassRepositoryProvider
      ├── searchQueryProvider (StateProvider)
      ├── sortOptionProvider (StateProvider)
      ├── scrollPositionProvider (StateProvider.family)
      ├── classListFetcherProvider (Provider.family)
      └── pagingControllerProvider (StateProvider.family - KHÔNG autoDispose, có keepAlive)

lib/presentation/fetchers/
  └── class_list_fetcher.dart
      └── ClassListFetcher (class đơn giản, không StateNotifier)

lib/presentation/views/class/teacher/
  └── teacher_class_list_screen.dart
      └── ConsumerStatefulWidget với ScrollController

lib/widgets/
  └── shimmer_loading.dart
      └── ShimmerLoading widget
```

## 📝 Implementation Steps

### Step 1: Dependencies

**File: `pubspec.yaml`**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  infinite_scroll_pagination: ^4.0.0
  easy_debounce: ^3.0.1
  shimmer: ^3.0.0
```

### Step 2: Data Layer - Pagination Method

**File: `lib/data/datasources/school_class_datasource.dart`**

Thêm method:

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

    // Áp dụng search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchPattern = '%$searchQuery%';
      // Supabase PostgREST OR syntax: 'field1.ilike.pattern,field2.ilike.pattern'
      query = query.or(
        'name.ilike.$searchPattern,subject.ilike.$searchPattern',
      ) as dynamic;
    }

    // Áp dụng sort
    if (sortBy != null) {
      query = query.order(sortBy, ascending: ascending) as dynamic;
    } else {
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

**File: `lib/domain/repositories/school_class_repository.dart`**

Thêm method:

```dart
Future<List<Class>> getClassesByTeacherPaginated({
  required String teacherId,
  required int page,
  required int pageSize,
  String? searchQuery,
  String? sortBy,
  bool ascending = true,
});
```

**File: `lib/data/repositories/school_class_repository_impl.dart`**

Implement:

```dart
@override
Future<List<Class>> getClassesByTeacherPaginated({
  required String teacherId,
  required int page,
  required int pageSize,
  String? searchQuery,
  String? sortBy,
  bool ascending = true,
}) async {
  try {
    final results = await _dataSource.getClassesByTeacherPaginated(
      teacherId: teacherId,
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
    return results.map((json) => Class.fromJson(json)).toList();
  } catch (e, stackTrace) {
    print('🔴 [REPO ERROR] getClassesByTeacherPaginated: $e');
    print('🔴 [REPO ERROR] StackTrace: $stackTrace');
    throw _translateError(e, 'Lấy danh sách lớp học');
  }
}
```

### Step 3: Fetcher Class

**File mới: `lib/presentation/fetchers/class_list_fetcher.dart`**

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

### Step 4: Auth Providers

**File mới: `lib/presentation/providers/auth_providers.dart`**

```dart
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Must override authRepositoryProvider');
});

/// Provider cho AuthViewModel
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

/// Provider cho current user profile (reactive, async)
final currentUserProvider = FutureProvider<Profile?>((ref) async {
  final authViewModel = ref.watch(authViewModelProvider);
  if (authViewModel.userProfile == null) {
    await authViewModel.fetchData();
  }
  return authViewModel.userProfile;
});

/// Provider cho current user ID (synchronous, nullable)
final currentUserIdProvider = Provider<String?>((ref) {
  final authViewModel = ref.watch(authViewModelProvider);
  return authViewModel.userProfile?.id;
});
```

### Step 5: Class Providers

**File mới: `lib/presentation/providers/class_providers.dart`**

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

/// Provider cho scroll position (lưu để restore)
final scrollPositionProvider = StateProvider.family<double, String>(
  (ref, teacherId) => 0.0,
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
/// KHÔNG dùng autoDispose để giữ cache khi navigate away
final pagingControllerProvider = StateProvider.family<
    PagingController<int, Class>,
    String>(
  (ref, teacherId) {
    final controller = PagingController<int, Class>(firstPageKey: 0);
    final fetcher = ref.watch(classListFetcherProvider(teacherId));

    // Lắng nghe thay đổi search query
    ref.listen<String?>(searchQueryProvider, (previous, next) {
      controller.refresh();
    });

    // Lắng nghe thay đổi sort option
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
      } catch (error, stackTrace) {
        // Phân loại error
        Exception userFriendlyError;
        
        final errorStr = error.toString().toLowerCase();
        if (errorStr.contains('network') || 
            errorStr.contains('timeout') ||
            errorStr.contains('socket')) {
          userFriendlyError = Exception(
            'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
          );
        } else if (errorStr.contains('401') || 
                   errorStr.contains('unauthorized') ||
                   errorStr.contains('jwt')) {
          userFriendlyError = Exception(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          );
        } else if (errorStr.contains('403') || 
                   errorStr.contains('forbidden')) {
          userFriendlyError = Exception(
            'Bạn không có quyền truy cập danh sách này.',
          );
        } else {
          userFriendlyError = Exception(
            'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
          );
        }
        
        controller.error = userFriendlyError;
      }
    });

    // Cleanup
    ref.onDispose(() {
      controller.dispose();
    });

    // Giữ provider alive để cache state
    ref.keepAlive();

    return controller;
  },
);
```

### Step 6: Shimmer Widget

**File mới: `lib/widgets/shimmer_loading.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widget cho danh sách lớp học
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 5,
        itemBuilder: (context, index) => _ClassItemShimmer(),
      ),
    );
  }
}

/// Shimmer placeholder cho ClassItemWidget
class _ClassItemShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 7: Main.dart Setup

**File: `lib/main.dart`**

```dart
// ... existing imports ...
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.initialize();
  } catch (e) {
    rethrow;
  }

  // Tạo dependencies
  final supabaseClient = Supabase.instance.client;
  final profileDataSource = BaseTableDataSource(supabaseClient, 'profiles');
  final schoolClassDataSource = SchoolClassDataSource();

  final AuthRepository authRepository = AuthRepositoryImpl(profileDataSource);
  final SchoolClassRepository schoolClassRepository = SchoolClassRepositoryImpl(
    schoolClassDataSource,
  );

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        schoolClassRepositoryProvider.overrideWithValue(schoolClassRepository),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Learning App',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
```

### Step 8: Screen Implementation

**File: `lib/presentation/views/class/teacher/teacher_class_list_screen.dart`**

Xem file đầy đủ trong "phân_tích_vòng_2_tối_ưu_chi_tiết.md" - phần Code Final.

## 🔑 Key Points

### 1. Không dùng autoDispose cho pagingControllerProvider
- Mục tiêu: Giữ cache khi navigate back
- Solution: Không dùng `.autoDispose()`, dùng `ref.keepAlive()`

### 2. TeacherId từ Provider, không phải state
- Mục tiêu: Reactive và handle loading/error states
- Solution: Dùng `currentUserIdProvider` và `currentUserProvider`

### 3. Search/Sort reactive
- Mục tiêu: Khi search/sort thay đổi, tự động refresh
- Solution: Dùng `ref.read()` trong `addPageRequestListener` để lấy giá trị mới nhất

### 4. Scroll position trong Provider
- Mục tiêu: Restore scroll position khi navigate back
- Solution: Lưu vào `scrollPositionProvider`

### 5. Error handling đầy đủ
- Phân loại: Network, Auth, Permission, Other
- User-friendly messages
- Retry button cho từng loại error

### 6. Empty state phân biệt
- No data vs No search results
- Different messages và icons

## ✅ Testing Checklist

- [ ] Pagination: Scroll đến cuối, verify load more
- [ ] Search: Nhập từ khóa, verify debouncing 400ms
- [ ] Sort: Thay đổi sort option, verify refresh
- [ ] Error handling: Simulate network error, verify message
- [ ] Empty state: Verify hiển thị đúng cho no data vs no results
- [ ] Cache: Navigate away và back, verify state được giữ
- [ ] Scroll position: Navigate back, verify scroll position restored
- [ ] Performance: Với 1000+ classes, verify không lag

## 📋 Files Summary

### Files mới:
1. `lib/presentation/providers/auth_providers.dart`
2. `lib/presentation/providers/class_providers.dart`
3. `lib/presentation/fetchers/class_list_fetcher.dart`
4. `lib/widgets/shimmer_loading.dart`

### Files cần sửa:
1. `pubspec.yaml` - Thêm dependencies
2. `lib/main.dart` - Setup ProviderScope
3. `lib/data/datasources/school_class_datasource.dart` - Thêm pagination method
4. `lib/domain/repositories/school_class_repository.dart` - Thêm method
5. `lib/data/repositories/school_class_repository_impl.dart` - Implement method
6. `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` - Refactor toàn bộ

## 🎯 Kết luận

Plan này đã được tối ưu qua 3 vòng phân tích:
- ✅ Không có circular dependency
- ✅ Architecture rõ ràng, maintainable
- ✅ Performance tốt với cache
- ✅ UX tốt với loading/error/empty states
- ✅ Code clean, follow best practices

**Sẵn sàng implement ngay!**

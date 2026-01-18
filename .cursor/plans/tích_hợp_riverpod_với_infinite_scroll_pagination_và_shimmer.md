# Tích hợp Riverpod với Infinite Scroll Pagination, Debouncing và Shimmer

## Mục tiêu

Tối ưu hiệu năng danh sách lớp học bằng cách:
1. **Riverpod** làm state management chính (thay thế Provider)
2. Sử dụng `infinite_scroll_pagination` để quản lý pagination tự động
3. Sử dụng `easy_debounce` cho tìm kiếm (300-500ms delay)
4. Sử dụng `shimmer` effect thay vì CircularProgressIndicator
5. Server-side pagination với search và sort
6. Tự động refresh khi search/sort thay đổi
7. Cache state với Riverpod để giữ vị trí scroll khi navigate back

## Phân tích hiện tại

### Vấn đề

- `getClassesByTeacher()` tải toàn bộ danh sách một lần (không có pagination)
- Sorting được thực hiện ở client-side (gây lag với dữ liệu lớn)
- Không có debouncing cho tìm kiếm
- Loading state chỉ có CircularProgressIndicator
- Đang dùng Provider với ChangeNotifier (không có cache tự động)
- Khi navigate back, danh sách bị reload từ đầu

### Architecture hiện tại

```
lib/main.dart
  └── MultiProvider (Provider pattern)
      ├── ChangeNotifierProvider<AuthViewModel>
      ├── ChangeNotifierProvider<ClassViewModel>
      └── ChangeNotifierProxyProvider<StudentDashboardViewModel>

lib/presentation/viewmodels/class_viewmodel.dart
  └── ClassViewModel extends ChangeNotifier
      ├── List<Class> _classes = []
      ├── bool _isLoading
      └── Future<void> loadClasses(String teacherId)

lib/presentation/views/class/teacher/teacher_class_list_screen.dart
  └── Consumer<ClassViewModel>
      ├── ScrollController _scrollController
      ├── int _displayedCount = 10 (client-side pagination)
      └── SortingUtils.sortClasses() (client-side sorting)
```

### Architecture mới với Riverpod

```
lib/main.dart
  └── ProviderScope (Riverpod)
      └── MaterialApp

lib/presentation/providers/class_providers.dart
  ├── final classListProvider = StateNotifierProvider<ClassListNotifier, AsyncValue<List<Class>>>
  ├── final searchQueryProvider = StateProvider<String?>((ref) => null)
  ├── final sortOptionProvider = StateProvider<ClassSortOption>((ref) => ClassSortOption.dateNewest)
  └── final pagingControllerProvider = StateProvider.family<PagingController<int, Class>, String>((ref, teacherId) => ...)

lib/presentation/notifiers/class_list_notifier.dart
  └── ClassListNotifier extends StateNotifier<AsyncValue<List<Class>>>
      └── Tích hợp với PagingController

lib/presentation/views/class/teacher/teacher_class_list_screen.dart
  └── ConsumerWidget
      ├── PagedListView<int, Class>
      ├── TextField với EasyDebounce
      └── ShimmerLoading widget
```

## Implementation Plan

### Bước 1: Thêm Dependencies

**File: `pubspec.yaml`**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  infinite_scroll_pagination: ^4.0.0
  easy_debounce: ^3.0.1
  shimmer: ^3.0.0
```

**Lưu ý:** Giữ lại `provider: ^6.0.0` nếu có screens khác vẫn đang dùng Provider. Có thể migrate dần dần.

### Bước 2: Setup Riverpod trong main.dart

**File: `lib/main.dart`**

Thay đổi:
- Xóa `MultiProvider`
- Thêm `ProviderScope` wrapper
- Tạo providers cho repositories (để inject dependencies)

```dart
// Thêm import
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tạo providers cho repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Lấy từ dependency injection hoặc tạo mới
  return authRepository;
});

final schoolClassRepositoryProvider = Provider<SchoolClassRepository>((ref) {
  return schoolClassRepository;
});

// Wrap MaterialApp với ProviderScope
void main() async {
  // ... existing code ...
  
  runApp(
    ProviderScope(
      child: MyApp(
        authRepository: authRepository,
        schoolClassRepository: schoolClassRepository,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  // ... existing code ...
  
  @override
  Widget build(BuildContext context) {
    // Xóa MultiProvider, chỉ giữ MaterialApp
    return MaterialApp(
      title: 'AI Learning App',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
```

### Bước 3: Thêm Server-side Pagination với Search/Sort

**File: `lib/data/datasources/school_class_datasource.dart`**

Thêm method mới:

```dart
/// Lấy danh sách lớp học của giáo viên với pagination, search và sort
Future<List<Map<String, dynamic>>> getClassesByTeacherPaginated({
  required String teacherId,
  required int page,
  required int pageSize,
  String? searchQuery,
  String? sortBy, // 'name', 'created_at', 'subject'
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
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,subject.ilike.%$searchQuery%') as dynamic;
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

**File: `lib/domain/repositories/school_class_repository.dart`**

Thêm method:

```dart
/// Lấy danh sách lớp học của giáo viên với pagination, search và sort
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

Implement method:

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

### Bước 4: Tạo Riverpod Providers và Notifiers

**File mới: `lib/presentation/providers/class_providers.dart`**

```dart
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/notifiers/class_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider cho SchoolClassRepository
final schoolClassRepositoryProvider = Provider<SchoolClassRepository>((ref) {
  throw UnimplementedError('Must override schoolClassRepositoryProvider');
});

/// Provider cho search query (debounced)
final searchQueryProvider = StateProvider<String?>((ref) => null);

/// Provider cho sort option
final sortOptionProvider = StateProvider<ClassSortOption>((ref) => ClassSortOption.dateNewest);

/// Provider cho PagingController (family provider với teacherId)
final pagingControllerProvider = StateProvider.family<PagingController<int, Class>, String>(
  (ref, teacherId) {
    final controller = PagingController<int, Class>(firstPageKey: 0);
    final notifier = ref.watch(classListNotifierProvider(teacherId).notifier);
    
    // Lắng nghe thay đổi search query
    ref.listen<String?>(searchQueryProvider, (previous, next) {
      controller.refresh();
    });
    
    // Lắng nghe thay đổi sort option
    ref.listen<ClassSortOption>(sortOptionProvider, (previous, next) {
      controller.refresh();
    });
    
    // Setup page request listener
    controller.addPageRequestListener((pageKey) {
      notifier.fetchPage(pageKey);
    });
    
    // Cleanup khi provider bị dispose
    ref.onDispose(() {
      controller.dispose();
    });
    
    return controller;
  },
);

/// Provider cho ClassListNotifier (family provider với teacherId)
final classListNotifierProvider = StateNotifierProvider.family<ClassListNotifier, AsyncValue<List<Class>>, String>(
  (ref, teacherId) {
    final repository = ref.watch(schoolClassRepositoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortOption = ref.watch(sortOptionProvider);
    
    return ClassListNotifier(
      repository: repository,
      teacherId: teacherId,
      searchQuery: searchQuery,
      sortOption: sortOption,
      pagingController: ref.watch(pagingControllerProvider(teacherId)),
    );
  },
);

/// Helper function để convert ClassSortOption sang database column và direction
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
```

**File mới: `lib/presentation/notifiers/class_list_notifier.dart`**

```dart
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Notifier quản lý danh sách lớp học với pagination
class ClassListNotifier extends StateNotifier<AsyncValue<List<Class>>> {
  final SchoolClassRepository _repository;
  final String _teacherId;
  final String? _searchQuery;
  final ClassSortOption _sortOption;
  final PagingController<int, Class> _pagingController;
  
  static const int _pageSize = 10;

  ClassListNotifier({
    required SchoolClassRepository repository,
    required String teacherId,
    String? searchQuery,
    ClassSortOption sortOption = ClassSortOption.dateNewest,
    required PagingController<int, Class> pagingController,
  })  : _repository = repository,
        _teacherId = teacherId,
        _searchQuery = searchQuery,
        _sortOption = sortOption,
        _pagingController = pagingController,
        super(const AsyncValue.loading());

  /// Fetch một page dữ liệu
  Future<void> fetchPage(int pageKey) async {
    try {
      // Convert sort option sang database format
      final (sortBy, ascending) = _convertSortOption(_sortOption);
      
      final classes = await _repository.getClassesByTeacherPaginated(
        teacherId: _teacherId,
        page: pageKey + 1, // API dùng 1-based, PagingController dùng 0-based
        pageSize: _pageSize,
        searchQuery: _searchQuery?.isEmpty == true ? null : _searchQuery,
        sortBy: sortBy,
        ascending: ascending,
      );

      final isLastPage = classes.length < _pageSize;
      
      if (isLastPage) {
        _pagingController.appendLastPage(classes);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(classes, nextPageKey);
      }
      
      // Update state với tất cả items đã load
      final allItems = _pagingController.itemList ?? [];
      state = AsyncValue.data(allItems);
    } catch (error, stackTrace) {
      _pagingController.error = error;
      state = AsyncValue.error(error, stackTrace);
    }
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

### Bước 5: Refactor Screen với Riverpod và PagedListView

**File: `lib/presentation/views/class/teacher/teacher_class_list_screen.dart`**

Thay đổi chính:

1. **Chuyển từ StatefulWidget sang ConsumerWidget**
2. **Xóa pagination state cũ**: `_displayedCount`, `_scrollController`, `_onScroll()`, `_loadMoreItems()`
3. **Thêm search field** với debouncing
4. **Thay ListView.builder bằng PagedListView**
5. **Sử dụng Riverpod providers** thay vì Provider

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/avatar_utils.dart';
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/widgets/class_item_widget.dart';
import 'package:ai_mls/widgets/search/smart_search_dialog_v2.dart';
import 'package:ai_mls/widgets/shimmer_loading.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'create_class_screen.dart';
import 'teacher_class_detail_screen.dart';

/// Màn hình danh sách lớp học dành cho giáo viên
/// Sử dụng Riverpod + Infinite Scroll Pagination + Shimmer
class TeacherClassListScreen extends ConsumerStatefulWidget {
  const TeacherClassListScreen({super.key});

  @override
  ConsumerState<TeacherClassListScreen> createState() => _TeacherClassListScreenState();
}

class _TeacherClassListScreenState extends ConsumerState<TeacherClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _teacherId;

  @override
  void initState() {
    super.initState();
    // Lấy teacherId từ AuthViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = ref.read(authViewModelProvider);
      _teacherId = authViewModel.userProfile?.id;
      
      if (_teacherId != null) {
        // Initialize PagingController sẽ tự động trigger fetchPage(0)
        ref.read(pagingControllerProvider(_teacherId!));
      }
    });
    
    // Lắng nghe thay đổi search text với debouncing
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    EasyDebounce.cancel('class-search');
    super.dispose();
  }

  /// Xử lý search với debouncing
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    EasyDebounce.debounce(
      'class-search',
      const Duration(milliseconds: 400),
      () {
        ref.read(searchQueryProvider.notifier).state = query.isEmpty ? null : query;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_teacherId == null) {
      return Scaffold(
        body: Center(
          child: Text('Không tìm thấy thông tin giáo viên'),
        ),
      );
    }

    final pagingController = ref.watch(pagingControllerProvider(_teacherId!));
    final sortOption = ref.watch(sortOptionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 12),
            // Search field
            _buildSearchField(context),
            const SizedBox(height: 12),
            // Card tạo lớp học mới
            _buildCreateClassCard(context),
            const SizedBox(height: 16),
            // Danh sách lớp học với PagedListView
            Expanded(child: _buildClassList(context, pagingController, sortOption)),
          ],
        ),
      ),
    );
  }

  /// Header với tiêu đề và avatar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lớp học của tôi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Năm học 2023 - 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  _showSearchDialog(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              const SizedBox(width: 6),
              Consumer(
                builder: (context, ref, _) {
                  final authViewModel = ref.watch(authViewModelProvider);
                  final profile = authViewModel.userProfile;
                  return AvatarUtils.buildAvatar(profile: profile);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Search field với debouncing
  Widget _buildSearchField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm lớp học...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  /// Card tạo lớp học mới
  Widget _buildCreateClassCard(BuildContext context) {
    // ... giữ nguyên code cũ ...
  }

  /// Danh sách lớp học với PagedListView
  Widget _buildClassList(
    BuildContext context,
    PagingController<int, Class> pagingController,
    ClassSortOption sortOption,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header danh sách với sort button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách lớp',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // TODO: Implement filter
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      _showSortDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // PagedListView
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() => pagingController.refresh()),
            child: PagedListView<int, Class>(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<Class>(
                itemBuilder: (context, classItem, index) {
                  return ClassItemWidget(
                    className: classItem.name,
                    roomInfo: classItem.subject ?? 'Chưa có môn học',
                    schedule: classItem.academicYear ?? 'Chưa có năm học',
                    studentCount: 0, // TODO: Load từ class members
                    ungradedCount: 0, // TODO: Load từ class members
                    iconName: 'school',
                    iconColor: Colors.blue,
                    hasAssignments: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TeacherClassDetailScreen(
                            classId: classItem.id,
                            className: classItem.name,
                            semesterInfo: classItem.academicYear ?? 'Chưa có năm học',
                          ),
                        ),
                      );
                    },
                  );
                },
                firstPageProgressIndicatorBuilder: (context) => ShimmerLoading(),
                newPageProgressIndicatorBuilder: (context) => ShimmerLoading(),
                firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
                  context,
                  pagingController,
                ),
                newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
                  context,
                  pagingController,
                ),
                noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),
                noMoreItemsIndicatorBuilder: (context) => _buildNoMoreItems(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Error widget
  Widget _buildErrorWidget(
    BuildContext context,
    PagingController<int, Class> pagingController,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pagingController.error?.toString() ?? 'Không thể tải danh sách lớp học',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lớp học nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo lớp học đầu tiên của bạn',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// No more items widget
  Widget _buildNoMoreItems() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Đã hiển thị tất cả lớp học',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Sort dialog
  void _showSortDialog(BuildContext context) {
    final currentSortOption = ref.read(sortOptionProvider);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sắp xếp lớp học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            const Divider(),
            // Sort options
            _buildSortOption(
              context,
              'Tên lớp (A-Z)',
              ClassSortOption.nameAscending,
              Icons.sort_by_alpha,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Tên lớp (Z-A)',
              ClassSortOption.nameDescending,
              Icons.sort_by_alpha,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Mới nhất',
              ClassSortOption.dateNewest,
              Icons.access_time,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Cũ nhất',
              ClassSortOption.dateOldest,
              Icons.access_time,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Môn học (A-Z)',
              ClassSortOption.subjectAscending,
              Icons.subject,
              currentSortOption,
            ),
            _buildSortOption(
              context,
              'Môn học (Z-A)',
              ClassSortOption.subjectDescending,
              Icons.subject,
              currentSortOption,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    ClassSortOption option,
    IconData icon,
    ClassSortOption currentOption,
  ) {
    final isSelected = currentOption == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? DesignColors.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? DesignColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: DesignColors.primary)
          : null,
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        Navigator.pop(context);
      },
    );
  }

  /// Search dialog (giữ nguyên logic cũ nếu cần)
  void _showSearchDialog(BuildContext context) {
    // ... giữ nguyên code cũ ...
  }
}
```

**Lưu ý:** Cần tạo `authViewModelProvider` nếu chưa có. Có thể migrate AuthViewModel sang Riverpod hoặc tạo provider wrapper.

### Bước 6: Tạo Shimmer Loading Widget

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
          // Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Text placeholders
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

### Bước 7: Migration AuthViewModel sang Riverpod (nếu cần)

Nếu `TeacherClassListScreen` cần access `AuthViewModel`, có 2 options:

**Option 1:** Tạo provider wrapper cho AuthViewModel hiện tại
```dart
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  // Lấy từ Provider nếu vẫn đang dùng MultiProvider ở đâu đó
  // Hoặc tạo mới từ repository
  throw UnimplementedError('Must provide AuthViewModel');
});
```

**Option 2:** Migrate AuthViewModel sang Riverpod hoàn toàn
- Tạo `AuthNotifier extends StateNotifier<AuthState>`
- Tạo `authNotifierProvider`
- Update tất cả screens đang dùng AuthViewModel

### Bước 8: Update main.dart để inject providers

**File: `lib/main.dart`**

```dart
// ... existing imports ...
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tạo providers với dependencies
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Must override in main()');
});

final schoolClassRepositoryProvider = Provider<SchoolClassRepository>((ref) {
  throw UnimplementedError('Must override in main()');
});

void main() async {
  // ... existing initialization code ...
  
  // Tạo repositories
  final authRepository = AuthRepositoryImpl(profileDataSource);
  final schoolClassRepository = SchoolClassRepositoryImpl(schoolClassDataSource);

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

## Lưu ý quan trọng

### 1. Server-side Sorting

Cần map `ClassSortOption` enum sang database column names:
- `nameAscending/nameDescending` → `sortBy: 'name'`
- `dateNewest/dateOldest` → `sortBy: 'created_at'`
- `subjectAscending/subjectDescending` → `sortBy: 'subject'`

### 2. Search với PostgreSQL

Sử dụng PostgreSQL `ilike` cho case-insensitive search trên `name` và `subject`:
```sql
name.ilike.%query% OR subject.ilike.%query%
```

### 3. Refresh Logic

Khi search hoặc sort thay đổi, `pagingController.refresh()` sẽ tự động:
- Clear current items
- Reset về page 0
- Gọi `fetchPage(0)` với parameters mới

### 4. Cache với Riverpod

Riverpod tự động cache state:
- Khi navigate back, `pagingControllerProvider` vẫn giữ state
- Items đã load vẫn còn trong memory
- Scroll position có thể được restore (cần thêm ScrollController nếu muốn)

### 5. Vietnamese Sorting

Server-side sorting sẽ xử lý đúng với PostgreSQL collation, không cần client-side normalization.

### 6. Migration Strategy

Có thể migrate từng phần:
- Giữ Provider cho các screens khác
- Chỉ TeacherClassListScreen dùng Riverpod
- Dần dần migrate các screens khác

## Kết quả mong đợi

- Chỉ tải 10 items mỗi lần từ database
- Tìm kiếm có debouncing 400ms
- Loading state với shimmer effect mượt mà
- Tự động load more khi scroll đến cuối
- Sort/search thay đổi tự động refresh
- Cache state với Riverpod - giữ vị trí khi navigate back
- Không lag ngay cả với hàng ngàn classes
- Code gọn gàng, dễ maintain với Riverpod

## Testing Checklist

- [ ] Test pagination: scroll đến cuối, verify load more
- [ ] Test search: nhập từ khóa, verify debouncing 400ms
- [ ] Test sort: thay đổi sort option, verify refresh
- [ ] Test error handling: simulate network error
- [ ] Test empty state: verify hiển thị khi không có data
- [ ] Test cache: navigate away và back, verify state được giữ
- [ ] Test performance: với 1000+ classes, verify không lag

## Files cần thay đổi

1. `pubspec.yaml` - Thêm dependencies
2. `lib/main.dart` - Setup ProviderScope
3. `lib/data/datasources/school_class_datasource.dart` - Thêm method pagination
4. `lib/domain/repositories/school_class_repository.dart` - Thêm method mới
5. `lib/data/repositories/school_class_repository_impl.dart` - Implement method mới
6. `lib/presentation/providers/class_providers.dart` - **File mới** - Riverpod providers
7. `lib/presentation/notifiers/class_list_notifier.dart` - **File mới** - Notifier với PagingController
8. `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` - Refactor toàn bộ
9. `lib/widgets/shimmer_loading.dart` - **File mới** - Shimmer widget

## Migration Notes

- Có thể giữ Provider cho các screens khác, chỉ migrate TeacherClassListScreen
- AuthViewModel có thể tạo provider wrapper hoặc migrate sau
- Test kỹ trước khi deploy production

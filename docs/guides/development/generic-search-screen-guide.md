# Hướng dẫn sử dụng Generic Search Screen

## Tổng quan

`GenericSearchScreen` là một widget có thể tái sử dụng được thiết kế để tạo màn hình tìm kiếm cho bất kỳ loại dữ liệu nào (Class, Subject, Assignment, Student, ...). Widget này sử dụng generic type `T` và được cấu hình hoàn toàn thông qua `SearchConfig<T>`.

## Cấu trúc Files

```
lib/widgets/search/
├── search_config.dart          # Class cấu hình SearchConfig<T>
└── generic_search_screen.dart  # Widget GenericSearchScreen<T>
```

## Tính năng

### ✅ Các tính năng đã được tích hợp

- **Debouncing**: Tự động debounce 400ms khi người dùng nhập
- **Autofocus**: Tự động focus vào ô tìm kiếm khi mở màn hình
- **Clear button**: Nút xóa xuất hiện khi có text
- **Keyboard dismiss**: Tự động ẩn bàn phím khi scroll
- **Pagination**: Hỗ trợ infinite scroll pagination
- **Error handling**: Xử lý lỗi với retry button
- **Empty states**: Hiển thị empty state và no results state
- **Loading states**: Shimmer loading cho trang đầu, CircularProgressIndicator cho các trang tiếp theo
- **Highlight**: Hỗ trợ highlight từ khóa tìm kiếm (thông qua itemBuilder)
- **Dispose**: Tự động dispose controllers và cancel debounce
- **Refresh logic**: Tự động refresh khi query thay đổi

## Cách sử dụng

### Bước 1: Tạo SearchConfig

Tạo một instance của `SearchConfig<T>` với type `T` là entity bạn muốn tìm kiếm:

```dart
final config = SearchConfig<Class>(
  // Required fields
  title: 'Tìm kiếm lớp học',
  hintText: 'Tìm kiếm lớp học...',
  emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
  noResultsMessage: 'Không tìm thấy lớp học nào',
  itemBuilder: _buildClassItem,
  onItemTap: (classItem) {
    // Navigate to detail screen
  },
  fetchFunction: (pageKey, searchQuery) async {
    // Not used when using providers
    throw UnimplementedError();
  },
  searchQueryProvider: searchScreenQueryProvider,
  pagingControllerProvider: searchPagingControllerProvider,
  getUserId: (ref) => ref.read(currentUserIdProvider),
  debounceKey: 'class-search-debounce',
  
  // Optional fields
  emptyStateSubtitle: 'Tìm kiếm theo tên lớp, môn học, hoặc học kỳ',
  pageSize: 10,
  debounceDuration: const Duration(milliseconds: 400),
);
```

### Bước 2: Tạo Item Builder

Tạo một function để build item trong danh sách kết quả:

```dart
static Widget _buildClassItem(
  BuildContext context,
  Class classItem,
  String searchQuery,
) {
  return GestureDetector(
    onTap: () {
      // Navigate to detail
    },
    child: Container(
      // Your item UI here
      // Use SmartHighlightText để highlight từ khóa
      child: SmartHighlightText(
        fullText: classItem.name,
        query: searchQuery,
        style: DesignTypography.titleMedium,
        highlightColor: Colors.blue,
      ),
    ),
  );
}
```

### Bước 3: Tạo Providers

Tạo các Riverpod providers cho search query và paging controller:

```dart
// Provider cho search query (auto-dispose)
final searchScreenQueryProvider = StateProvider.autoDispose<String?>((ref) => null);

// Provider cho PagingController (auto-dispose family)
final searchPagingControllerProvider = StateProvider.autoDispose.family<
    PagingController<int, Class>,
    String>(
  (ref, userId) {
    final controller = PagingController<int, Class>(firstPageKey: 0);
    final fetcher = ref.watch(classListFetcherProvider(userId));

    // Listen to query changes
    ref.listen<String?>(searchScreenQueryProvider, (previous, next) {
      controller.refresh();
    });

    // Setup page request listener
    controller.addPageRequestListener((pageKey) async {
      try {
        final searchQuery = ref.read(searchScreenQueryProvider);
        final classes = await fetcher.fetchPage(
          pageKey: pageKey,
          searchQuery: searchQuery,
        );
        
        final isLastPage = classes.length < pageSize;
        if (isLastPage) {
          controller.appendLastPage(classes);
        } else {
          controller.appendPage(classes, pageKey + 1);
        }
      } catch (error) {
        controller.error = error;
      }
    });

    ref.onDispose(() {
      controller.dispose();
    });

    return controller;
  },
);
```

### Bước 4: Sử dụng GenericSearchScreen

Trong widget của bạn, sử dụng `GenericSearchScreen` với config đã tạo:

```dart
class TeacherClassSearchScreen extends ConsumerWidget {
  const TeacherClassSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = SearchConfig<Class>(
      // ... config như trên
    );

    return GenericSearchScreen<Class>(config: config);
  }
}
```

## Ví dụ hoàn chỉnh

Xem file `lib/presentation/views/class/teacher/teacher_class_search_screen.dart` để xem ví dụ hoàn chỉnh.

## SearchConfig Parameters

### Required Parameters

| Parameter | Type | Mô tả |
|-----------|------|-------|
| `title` | `String` | Tiêu đề hiển thị trên AppBar |
| `hintText` | `String` | Hint text trong ô tìm kiếm |
| `emptyStateMessage` | `String` | Message khi chưa nhập query |
| `noResultsMessage` | `String` | Message khi không có kết quả |
| `itemBuilder` | `Widget Function(BuildContext, T, String)` | Function build item trong list |
| `onItemTap` | `void Function(T)` | Callback khi tap vào item |
| `fetchFunction` | `Future<List<T>> Function(int, String?)` | Function fetch data (không dùng khi có provider) |
| `searchQueryProvider` | `AutoDisposeStateProvider<String?>` | Provider cho search query |
| `pagingControllerProvider` | `AutoDisposeStateProviderFamily<PagingController<int, T>, String>` | Provider cho paging controller |
| `getUserId` | `String? Function(WidgetRef)` | Function lấy user ID |
| `debounceKey` | `String` | Unique key cho debounce |

### Optional Parameters

| Parameter | Type | Default | Mô tả |
|-----------|------|---------|-------|
| `emptyStateSubtitle` | `String?` | `null` | Subtitle cho empty state |
| `pageSize` | `int` | `10` | Số items mỗi trang |
| `debounceDuration` | `Duration` | `400ms` | Thời gian debounce |
| `errorMessageBuilder` | `String Function(Object)?` | `null` | Custom error message builder |
| `emptyStateBuilder` | `Widget Function(BuildContext)?` | `null` | Custom empty state widget |
| `noResultsBuilder` | `Widget Function(BuildContext)?` | `null` | Custom no results widget |

## Tùy chỉnh UI

### Custom Empty State

```dart
config: SearchConfig<Class>(
  // ...
  emptyStateBuilder: (context) => Center(
    child: Column(
      children: [
        Icon(Icons.search, size: 64),
        Text('Custom empty state'),
      ],
    ),
  ),
)
```

### Custom No Results

```dart
config: SearchConfig<Class>(
  // ...
  noResultsBuilder: (context) => Center(
    child: Column(
      children: [
        Icon(Icons.search_off, size: 64),
        Text('Custom no results'),
      ],
    ),
  ),
)
```

### Custom Error Message

```dart
config: SearchConfig<Class>(
  // ...
  errorMessageBuilder: (error) {
    if (error.toString().contains('network')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã xảy ra lỗi';
  },
)
```

## Highlight Text

Để highlight từ khóa tìm kiếm trong item, sử dụng `SmartHighlightText` widget:

```dart
SmartHighlightText(
  fullText: classItem.name,
  query: searchQuery,
  style: DesignTypography.titleMedium,
  highlightColor: Colors.blue,
)
```

Widget này tự động:
- Normalize tiếng Việt (loại bỏ dấu)
- Tìm và highlight các từ khóa khớp
- Hỗ trợ tìm kiếm không dấu (ví dụ: "toan" → "Toán")

## Best Practices

### 1. Tách Item Builder thành static method

```dart
class TeacherClassSearchScreen extends ConsumerWidget {
  static Widget _buildClassItem(
    BuildContext context,
    Class classItem,
    String searchQuery,
  ) {
    // Item UI
  }
}
```

### 2. Sử dụng unique debounceKey

Mỗi search screen nên có debounceKey riêng để tránh conflict:

```dart
debounceKey: 'class-search-debounce',  // Cho Class
debounceKey: 'subject-search-debounce', // Cho Subject
```

### 3. Provider naming convention

Đặt tên provider rõ ràng:

```dart
// Cho Class search
final searchScreenQueryProvider = ...;
final searchPagingControllerProvider = ...;

// Cho Subject search
final subjectSearchQueryProvider = ...;
final subjectSearchPagingControllerProvider = ...;
```

### 4. Error handling trong Provider

Luôn xử lý error trong page request listener:

```dart
controller.addPageRequestListener((pageKey) async {
  try {
    // Fetch data
  } catch (error) {
    // Phân loại error và set user-friendly message
    Exception userFriendlyError;
    if (error.toString().contains('network')) {
      userFriendlyError = Exception('Lỗi kết nối mạng');
    } else {
      userFriendlyError = Exception('Đã xảy ra lỗi');
    }
    controller.error = userFriendlyError;
  }
});
```

### 5. Race condition handling

Kiểm tra query có thay đổi sau khi fetch xong:

```dart
final searchQuery = ref.read(searchScreenQueryProvider);
final classes = await fetcher.fetchPage(
  pageKey: pageKey,
  searchQuery: searchQuery,
);

// Kiểm tra lại query sau khi fetch
final currentQuery = ref.read(searchScreenQueryProvider);
if (currentQuery != searchQuery) {
  return; // Bỏ qua kết quả cũ
}
```

## Troubleshooting

### Vấn đề: Search không hoạt động

**Nguyên nhân**: Provider không được setup đúng

**Giải pháp**: 
- Kiểm tra `searchQueryProvider` và `pagingControllerProvider` đã được tạo chưa
- Đảm bảo `getUserId` trả về đúng user ID
- Kiểm tra listener trong provider có gọi `refresh()` khi query thay đổi

### Vấn đề: Highlight không hoạt động

**Nguyên nhân**: Không sử dụng `SmartHighlightText` hoặc query không được truyền vào

**Giải pháp**:
- Sử dụng `SmartHighlightText` trong `itemBuilder`
- Đảm bảo `searchQuery` được truyền vào `itemBuilder` function

### Vấn đề: Memory leak

**Nguyên nhân**: Controllers không được dispose

**Giải pháp**:
- `GenericSearchScreen` tự động dispose controllers
- Đảm bảo provider có `ref.onDispose(() => controller.dispose())`

### Vấn đề: Debounce không hoạt động

**Nguyên nhân**: DebounceKey bị conflict hoặc không unique

**Giải pháp**:
- Sử dụng unique debounceKey cho mỗi search screen
- Kiểm tra `EasyDebounce.cancel()` được gọi trong dispose

## Tái sử dụng cho các Entity khác

### Ví dụ: Subject Search

```dart
final subjectSearchConfig = SearchConfig<Subject>(
  title: 'Tìm kiếm môn học',
  hintText: 'Tìm kiếm môn học...',
  emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
  noResultsMessage: 'Không tìm thấy môn học nào',
  itemBuilder: _buildSubjectItem,
  onItemTap: (subject) => navigateToSubjectDetail(subject),
  searchQueryProvider: subjectSearchQueryProvider,
  pagingControllerProvider: subjectSearchPagingControllerProvider,
  getUserId: (ref) => ref.read(currentUserIdProvider),
  debounceKey: 'subject-search-debounce',
);
```

### Ví dụ: Student Search

```dart
final studentSearchConfig = SearchConfig<Student>(
  title: 'Tìm kiếm học sinh',
  hintText: 'Tìm kiếm học sinh...',
  emptyStateMessage: 'Nhập từ khóa để tìm kiếm',
  noResultsMessage: 'Không tìm thấy học sinh nào',
  itemBuilder: _buildStudentItem,
  onItemTap: (student) => navigateToStudentDetail(student),
  searchQueryProvider: studentSearchQueryProvider,
  pagingControllerProvider: studentSearchPagingControllerProvider,
  getUserId: (ref) => ref.read(currentUserIdProvider),
  debounceKey: 'student-search-debounce',
);
```

## Tóm tắt

`GenericSearchScreen` là một giải pháp mạnh mẽ và linh hoạt để tạo màn hình tìm kiếm cho bất kỳ entity nào. Chỉ cần:

1. Tạo `SearchConfig<T>` với các thông tin cần thiết
2. Tạo providers cho query và paging controller
3. Tạo item builder function
4. Sử dụng `GenericSearchScreen<T>` với config

Tất cả các tính năng như debouncing, pagination, error handling, empty states đã được tích hợp sẵn, giúp bạn tiết kiệm thời gian và đảm bảo consistency trong toàn bộ ứng dụng.

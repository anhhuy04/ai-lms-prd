# Hướng Dẫn Tích Hợp ViewModel Vào UI - MVVM Pattern

## Tổng Quan

Tài liệu này mô tả cách tích hợp ViewModel vào UI screens theo MVVM pattern, sử dụng Provider package và tuân thủ Clean Architecture.

## Cấu Trúc ViewModel

### 1. State Management với ChangeNotifier

```dart
class ClassViewModel extends ChangeNotifier {
  // State properties
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  List<Class> _classes = [];
  List<Class> get classes => _classes;
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Quan trọng: phải gọi để UI cập nhật
  }
  
  // Public methods
  Future<void> loadClasses(String teacherId) async {
    _setLoading(true);
    try {
      _classes = await _repository.getClassesByTeacher(teacherId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
```

### 2. Các State Properties Quan Trọng

#### Loading States
- `isLoading`: Đang tải dữ liệu chính
- `isCreating`: Đang tạo mới
- `isUpdating`: Đang cập nhật
- `isDeleting`: Đang xóa
- `isProcessing`: Tổng hợp tất cả trạng thái xử lý

#### Error States
- `errorMessage`: Thông báo lỗi (đã được translate sang tiếng Việt)
- `hasError`: Kiểm tra có lỗi không

#### Data States
- `classes`: Danh sách dữ liệu
- `selectedClass`: Item đang được chọn
- Computed properties: `classCount`, `pendingCount`, etc.

## Tích Hợp Vào UI

### 1. Setup Provider trong main.dart

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Auth ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            repository: AuthRepositoryImpl(
              dataSource: SupabaseDataSource(),
            ),
          ),
        ),
        // Class ViewModel
        ChangeNotifierProvider(
          create: (context) => ClassViewModel(
            SchoolClassRepositoryImpl(
              dataSource: SchoolClassDataSource(),
            ),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Sử dụng Consumer trong Screen

#### Pattern 1: Consumer cho toàn bộ widget tree

```dart
class TeacherClassListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ClassViewModel>(
        builder: (context, viewModel, child) {
          // UI sẽ tự động rebuild khi ViewModel thay đổi
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.hasError) {
            return ErrorWidget(message: viewModel.errorMessage);
          }
          
          return ListView.builder(
            itemCount: viewModel.classes.length,
            itemBuilder: (context, index) {
              return ClassItemWidget(
                classItem: viewModel.classes[index],
              );
            },
          );
        },
      ),
    );
  }
}
```

#### Pattern 2: Consumer cho phần cụ thể (Tối ưu hơn)

```dart
class TeacherClassListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Không cần Consumer
      body: Column(
        children: [
          _buildHeader(), // Không cần Consumer
          Expanded(
            child: Consumer<ClassViewModel>(
              builder: (context, viewModel, _) {
                // Chỉ phần này rebuild khi ViewModel thay đổi
                return _buildClassList(viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Pattern 3: context.read() cho actions (Không rebuild)

```dart
ElevatedButton(
  onPressed: () {
    // Sử dụng context.read() khi chỉ cần gọi method, không cần rebuild
    final viewModel = context.read<ClassViewModel>();
    viewModel.loadClasses(teacherId);
  },
  child: Text('Tải lại'),
)
```

### 3. Xử Lý Các Trạng Thái UI

#### Loading State

```dart
Widget _buildClassList(ClassViewModel viewModel) {
  if (viewModel.isLoading && viewModel.classes.isEmpty) {
    return Center(
      child: CircularProgressIndicator(
        color: DesignColors.tealPrimary,
      ),
    );
  }
  
  // ... rest of UI
}
```

#### Error State

```dart
Widget _buildErrorState(ClassViewModel viewModel) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: DesignColors.error),
        SizedBox(height: DesignSpacing.lg),
        Text(
          viewModel.errorMessage ?? 'Đã xảy ra lỗi',
          style: DesignTypography.bodyMedium,
        ),
        SizedBox(height: DesignSpacing.lg),
        ElevatedButton(
          onPressed: () {
            viewModel.clearError();
            viewModel.loadClasses(teacherId);
          },
          child: Text('Thử lại'),
        ),
      ],
    ),
  );
}
```

#### Empty State

```dart
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.school_outlined,
          size: DesignIcons.xxlSize,
          color: DesignColors.textTertiary,
        ),
        SizedBox(height: DesignSpacing.lg),
        Text(
          'Chưa có lớp học nào',
          style: DesignTypography.titleMedium,
        ),
        SizedBox(height: DesignSpacing.sm),
        Text(
          'Tạo lớp học đầu tiên để bắt đầu',
          style: DesignTypography.bodyMedium,
        ),
      ],
    ),
  );
}
```

#### Success State với Data

```dart
Widget _buildClassList(ClassViewModel viewModel) {
  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(),
    child: ListView.builder(
      itemCount: viewModel.classes.length,
      itemBuilder: (context, index) {
        final classItem = viewModel.classes[index];
        return ClassItemWidget(
          className: classItem.name,
          onTap: () => _navigateToDetail(context, classItem),
        );
      },
    ),
  );
}
```

### 4. Xử Lý User Actions

#### Tạo mới

```dart
Future<void> _createClass() async {
  final viewModel = context.read<ClassViewModel>();
  final params = CreateClassParams(
    teacherId: teacherId,
    name: _nameController.text,
    // ... other params
  );
  
  final newClass = await viewModel.createClass(params);
  
  if (newClass != null && mounted) {
    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lớp học đã được tạo thành công!'),
        backgroundColor: DesignColors.success,
      ),
    );
    
    // Điều hướng hoặc reload
    Navigator.pop(context, newClass);
  } else if (viewModel.hasError && mounted) {
    // Hiển thị lỗi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel.errorMessage ?? 'Đã xảy ra lỗi'),
        backgroundColor: DesignColors.error,
      ),
    );
  }
}
```

#### Cập nhật

```dart
Future<void> _updateClass(String classId) async {
  final viewModel = context.read<ClassViewModel>();
  final params = UpdateClassParams(
    name: _nameController.text,
    // ... other params
  );
  
  final success = await viewModel.updateClass(classId, params);
  
  if (success && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật thành công!'),
        backgroundColor: DesignColors.success,
      ),
    );
  } else if (viewModel.hasError && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel.errorMessage ?? 'Đã xảy ra lỗi'),
        backgroundColor: DesignColors.error,
      ),
    );
  }
}
```

#### Xóa

```dart
Future<void> _deleteClass(String classId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Xác nhận xóa'),
      content: Text('Bạn có chắc chắn muốn xóa lớp học này?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Xóa', style: TextStyle(color: DesignColors.error)),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    final viewModel = context.read<ClassViewModel>();
    final success = await viewModel.deleteClass(classId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa lớp học'),
          backgroundColor: DesignColors.success,
        ),
      );
    }
  }
}
```

### 5. Sử Dụng RefreshableViewModel Mixin

```dart
class ClassViewModel extends ChangeNotifier with RefreshableViewModel {
  @override
  Future<void> fetchData() async {
    // Implement logic load dữ liệu
    _classes = await _repository.getClassesByTeacher(teacherId);
  }
}

// Trong UI
RefreshIndicator(
  onRefresh: () => viewModel.refresh(),
  child: ListView(...),
)
```

## Best Practices

### 1. Tối Ưu Performance

✅ **DO:**
- Sử dụng `Consumer` chỉ cho phần UI cần rebuild
- Sử dụng `context.read()` cho actions không cần rebuild
- Tách UI thành các widgets nhỏ để giảm rebuild scope

❌ **DON'T:**
- Không wrap toàn bộ Scaffold trong Consumer nếu không cần
- Không gọi `notifyListeners()` quá nhiều lần
- Không đặt logic business trong UI

### 2. Error Handling

✅ **DO:**
- Luôn kiểm tra `mounted` trước khi show SnackBar/Dialog
- Hiển thị error messages từ ViewModel (đã được translate)
- Cung cấp action để retry khi có lỗi

❌ **DON'T:**
- Không bỏ qua errors
- Không hiển thị technical errors trực tiếp cho user
- Không để UI crash khi ViewModel có lỗi

### 3. Loading States

✅ **DO:**
- Hiển thị loading indicator khi `isLoading = true`
- Disable buttons khi `isProcessing = true`
- Show skeleton loaders cho better UX

❌ **DON'T:**
- Không show loading nếu đã có data (chỉ show khi empty)
- Không block toàn bộ UI khi loading

### 4. State Management

✅ **DO:**
- Gọi `notifyListeners()` sau mỗi state change
- Clear error messages khi bắt đầu action mới
- Maintain single source of truth trong ViewModel

❌ **DON'T:**
- Không mutate state trực tiếp từ UI
- Không duplicate state giữa ViewModel và UI
- Không forget dispose ViewModel khi không cần

## Ví Dụ Hoàn Chỉnh

Xem file `lib/presentation/views/class/teacher/teacher_class_list_screen_v2.dart` để xem ví dụ implementation đầy đủ.

## Checklist Khi Tạo Screen Mới

- [ ] ViewModel đã được setup trong Provider
- [ ] Screen sử dụng Consumer để lắng nghe ViewModel
- [ ] Xử lý loading state
- [ ] Xử lý error state
- [ ] Xử lý empty state
- [ ] Xử lý success state với data
- [ ] User actions gọi methods từ ViewModel
- [ ] Error messages được hiển thị cho user
- [ ] Kiểm tra `mounted` trước khi show SnackBar/Dialog
- [ ] Sử dụng DesignTokens cho UI consistency
- [ ] Code pass `flutter analyze`
- [ ] Code được format bằng `dart format`

## Tài Liệu Tham Khảo

- `lib/presentation/viewmodels/class_viewmodel.dart` - ViewModel example
- `lib/presentation/views/class/teacher/teacher_class_list_screen_v2.dart` - UI integration example
- `memory-bank/systemPatterns.md` - Architecture patterns
- `docs/ai/AI_INSTRUCTIONS.md` - Clean Architecture rules

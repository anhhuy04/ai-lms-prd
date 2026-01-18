---
name: Bảng Kế Hoạch Tổng Quát AI LMS
overview: ""
todos:
  - id: todo-1768634220316-hy58f442h
    content: tôi mới thêm mcp dart vào, bạn hãy ghi trong rules lúc nào nên tự sử dung, lúc nào ko cần, ghi rõ cách dùng trong đó
    status: completed
  - id: todo-1768635613582-t3ht05fxs
    content: "tối ưu lại code giao diện để sau này có thể chia ra chỉnh giao diện cho các loại màn hình, các loại máy khác nhau như laptop, pc, tablet, điện thoại,... . Và chỉnh sửa lại các rules để code lại theo chuẩn "
    status: pending
  - id: todo-1768643598490-sbyotqa8d
    content: tối ưu và lọc lại các file docs, md. đọc toàn bộ các file đó và tiếnh hành sàn lọc, suy nghĩ, phân tích. file nào dùng để hiển thị cho người đọc hiểu thì sẽ viết và để vào 1 forder riêng còn file nào dùng để cho ai agent hiểu thì để riêng.
    status: completed
  - id: todo-1768643713129-kt8dw6bxl
    content: kiểm tra các liên kết, chỉ mục của những file docs cần liên kết vs .clinerules đã tối ưu hay chưa. nếu có vấn đề j cần tối ưu hoặc thi triển để giúp project sau này làm việc ổn định với agent hơn thì hãy đề xuất để tôi quyết định
    status: completed
---

# Bảng Kế Hoạch Tổng Quát - AI LMS Project

## Mục đích

Bảng kế hoạch này cung cấp workflow chuẩn và checklist để thực hiện các task trong dự án AI LMS một cách nhất quán và hiệu quả.

---

## WORKFLOW CHUẨN KHI BẮT ĐẦU TASK

### Bước 1: Đọc Context (BẮT BUỘC)

- [ ] Đọc `.clinerules` để hiểu quy tắc làm việc
- [ ] Đọc tất cả files trong `memory-bank/`:
  - `projectbrief.md` - Tổng quan dự án
  - `productContext.md` - Context sản phẩm
  - `activeContext.md` - Context hiện tại và next steps
  - `systemPatterns.md` - Patterns và kiến trúc
  - `techContext.md` - Tech stack và setup
  - `progress.md` - Tiến độ và status
  - `DESIGN_SYSTEM_GUIDE.md` - Design system
- [ ] Đọc `docs/ai/AI_INSTRUCTIONS.md` nếu cần hiểu chi tiết về cấu trúc

### Bước 2: Kiểm tra Database Schema (Nếu liên quan đến DB)

- [ ] Sử dụng Supabase MCP để kiểm tra schema bảng trước khi tạo model
- [ ] Xác nhận các cột thực tế, không giả định
- [ ] Kiểm tra RLS policies nếu cần

### Bước 3: Xác định Files Cần Tạo/Chỉnh Sửa

- [ ] Liệt kê đầy đủ đường dẫn files theo Clean Architecture:
  - Domain: `lib/domain/entities/`, `lib/domain/repositories/`
  - Data: `lib/data/datasources/`, `lib/data/repositories/`
  - Presentation: `lib/presentation/views/`, `lib/presentation/viewmodels/`
  - Widgets: `lib/widgets/` (nếu reusable)
- [ ] Đảm bảo tuân thủ cấu trúc thư mục trong `AI_INSTRUCTIONS.md`

### Bước 4: Implement Code

- [ ] Tuân thủ Clean Architecture: Presentation → Domain → Data
- [ ] Sử dụng MVVM pattern với ChangeNotifier
- [ ] Áp dụng Design Tokens từ `design_tokens.dart`
- [ ] Error handling: Vietnamese messages trong Repository layer
- [ ] Code quality: Functions ≤ 50 dòng, Classes ≤ 300 dòng

### Bước 5: Kiểm tra và Hoàn thiện

- [ ] Chạy `flutter analyze` và fix tất cả warnings
- [ ] Chạy `dart format` để format code
- [ ] Kiểm tra compilation: `flutter build` (nếu cần)
- [ ] Cập nhật Memory Bank files nếu có thay đổi quan trọng

---

## CHECKLIST THEO LOẠI TASK

### Task: Tạo Feature Mới (Ví dụ: Assignment Builder)

#### Phase 1: Domain Layer

- [ ] Tạo Entity trong `lib/domain/entities/`
  - [ ] Định nghĩa fields phù hợp với database schema
  - [ ] Implement `fromJson()` và `toJson()`
  - [ ] Validation logic nếu cần
- [ ] Tạo Repository Interface trong `lib/domain/repositories/`
  - [ ] Định nghĩa abstract methods
  - [ ] Return types là Domain Entities
- [ ] Tạo UseCase (nếu logic phức tạp) trong `lib/domain/usecases/`

#### Phase 2: Data Layer

- [ ] Tạo DataSource trong `lib/data/datasources/`
  - [ ] **QUAN TRỌNG:** Tất cả Supabase calls chỉ ở đây
  - [ ] Sử dụng BaseTableDataSource nếu có thể
  - [ ] Error handling: throw CustomException với message tiếng Anh
- [ ] Tạo Repository Implementation trong `lib/data/repositories/`
  - [ ] Implement interface từ Domain layer
  - [ ] Convert DataSource responses → Domain Entities
  - [ ] **QUAN TRỌNG:** Translate errors sang tiếng Việt
  - [ ] Error recovery logic nếu cần

#### Phase 3: Presentation Layer

- [ ] Tạo ViewModel trong `lib/presentation/viewmodels/`
  - [ ] Extend ChangeNotifier
  - [ ] Inject Repository qua constructor
  - [ ] State management: initial, loading, success, error
  - [ ] Methods: async functions gọi Repository
  - [ ] notifyListeners() sau mỗi state change
- [ ] Tạo View/Screen trong `lib/presentation/views/`
  - [ ] Sử dụng Consumer<ViewModel> hoặc context.read<ViewModel>
  - [ ] UI sử dụng Design Tokens (colors, spacing, typography)
  - [ ] Error display: SnackBar hoặc Dialog
  - [ ] Loading states: CircularProgressIndicator
- [ ] Register ViewModel trong `main.dart` với ChangeNotifierProvider
- [ ] Thêm route trong `lib/core/routes/app_routes.dart` (nếu cần)

#### Phase 4: Widgets (Nếu Reusable)

- [ ] Tạo widget trong `lib/widgets/` nếu được sử dụng > 2 lần
- [ ] Sử dụng Design Tokens
- [ ] Document usage trong code comments

---

### Task: Tạo/Cập Nhật Screen

#### Checklist UI Screen

- [ ] Import Design Tokens: `import 'package:ai_mls/core/constants/design_tokens.dart';`
- [ ] Import ResponsiveUtils: `import 'package:ai_mls/core/utils/responsive_utils.dart';`
- [ ] Import ResponsiveWidgets: `import 'package:ai_mls/widgets/responsive/responsive_*.dart';`
- [ ] Sử dụng DesignColors thay vì hardcoded colors
- [ ] Sử dụng DesignSpacing thay vì hardcoded spacing
- [ ] Sử dụng DesignTypography thay vì hardcoded font sizes
- [ ] Sử dụng DesignRadius cho border radius
- [ ] Sử dụng DesignElevation cho shadows
- [ ] **Responsive Design (BẮT BUỘC):**
  - [ ] Wrap screen với `ResponsiveScreen` hoặc sử dụng `ResponsiveContainer`
  - [ ] Sử dụng `ResponsivePadding` thay vì hardcoded EdgeInsets
  - [ ] Sử dụng `ResponsiveText` cho text cần responsive sizing
  - [ ] Sử dụng `ResponsiveGrid` cho grid layouts
  - [ ] Sử dụng `ResponsiveRow` cho row layouts với spacing responsive
  - [ ] Sử dụng `ResponsiveCard` cho cards với padding responsive
  - [ ] Sử dụng `ResponsiveUtils.getLayoutConfig()` để lấy spacing values
  - [ ] **KHÔNG** sử dụng MediaQuery trực tiếp trong UI code
  - [ ] **KHÔNG** hardcode device-specific values
- [ ] Tách widget: Functions > 50 dòng → tách thành `_build*()` methods
- [ ] Const constructors khi có thể
- [ ] Error handling: Hiển thị errors từ ViewModel
- [ ] Loading states: Hiển thị loading indicator
- [ ] Test trên mobile, tablet, desktop sizes

#### Checklist Screen với ViewModel

- [ ] ViewModel đã được register trong `main.dart`
- [ ] Sử dụng Consumer hoặc context.read để access ViewModel
- [ ] Handle state changes: loading, success, error
- [ ] Dispose ViewModel nếu cần (thường không cần với Provider)

---

### Task: Tạo Dialog

#### Checklist Dialog

- [ ] Sử dụng FlexibleDialog system từ `lib/widgets/dialogs/`
- [ ] Responsive sizing: Mobile 90% (max 340px), Tablet 70% (max 480px), Desktop 50% (max 560px)
- [ ] Sử dụng Design Tokens cho styling
- [ ] Animation: Fade + scale (300ms duration)
- [ ] Dark mode support: Automatic theme adaptation
- [ ] Button types: Primary, Secondary, Tertiary
- [ ] Icon: Automatic based on dialog type

#### Dialog Types Available

- `FlexibleDialog` - Core widget với 5 types
- `SuccessDialog` - Success confirmations
- `WarningDialog` - Confirmations và warnings
- `ErrorDialog` - Error handling

---

### Task: Tạo Drawer

#### Checklist Drawer

- [ ] Sử dụng ActionEndDrawer làm container (340px width)
- [ ] Tạo content widget riêng (StatelessWidget)
- [ ] Sử dụng DrawerSectionHeader cho section headers
- [ ] Sử dụng DrawerActionTile cho action items
- [ ] Sử dụng DrawerToggleTile cho toggle switches
- [ ] Sử dụng Design Tokens cho tất cả styling
- [ ] Integrate với Scaffold.endDrawer

---

### Task: Database Operations

#### Checklist Database

- [ ] **BẮT BUỘC:** Kiểm tra schema bằng Supabase MCP trước khi tạo model
- [ ] Tạo migration script trong `db/` nếu cần thay đổi schema
- [ ] Kiểm tra RLS policies
- [ ] DataSource: Tất cả Supabase calls chỉ ở đây
- [ ] Repository: Convert responses → Domain Entities
- [ ] Error translation: Tiếng Việt trong Repository layer

---

### Task: HTML → Dart Conversion

#### Checklist Conversion

- [ ] Ánh xạ HTML elements → Flutter widgets:
  - `<div>` → Container/Column/Row
  - `<button>` → ElevatedButton/TextButton
  - `<input>` → TextField/TextFormField
  - `<img>` → Image.network/Image.asset
- [ ] Tách widget: Nếu > 50 dòng hoặc tái sử dụng
- [ ] Sử dụng Design Tokens cho styling
- [ ] Giải thích mapping sau khi convert

---

## QUY TẮC QUAN TRỌNG

### Architecture Rules

1. **Clean Architecture:** Presentation → Domain → Data (không được vi phạm)
2. **Supabase Calls:** Chỉ trong `lib/data/datasources/`
3. **Error Translation:** Tiếng Việt trong Repository layer
4. **State Management:** ChangeNotifier + Provider

### Code Quality Rules

1. **Functions:** ≤ 50 dòng (tách nếu vượt)
2. **Classes:** ≤ 300 dòng (refactor nếu vượt)
3. **Format:** `dart format` trước khi commit
4. **Analyze:** `flutter analyze` phải pass
5. **Const:** Sử dụng const constructor khi có thể

### Design System Rules

1. **NO hardcoded colors** → Use `DesignColors.*`
2. **NO hardcoded spacing** → Use `DesignSpacing.*`
3. **NO hardcoded font sizes** → Use `DesignTypography.*`
4. **NO hardcoded icon sizes** → Use `DesignIcons.*`
5. **NO hardcoded border radius** → Use `DesignRadius.*`
6. **NO custom shadows** → Use `DesignElevation.level*`
7. **NO magic numbers** → Use `DesignComponents.*`

### Responsive Design Rules

1. **BẮT BUỘC:** Sử dụng `ResponsiveUtils` để detect device type
2. **BẮT BUỘC:** Sử dụng `ResponsiveLayoutConfig` để lấy layout config
3. **BẮT BUỘC:** Ưu tiên sử dụng widgets từ `lib/widgets/responsive/`
4. **KHÔNG** hardcode device-specific values
5. **KHÔNG** sử dụng MediaQuery trực tiếp trong UI code
6. **KHÔNG** sử dụng hardcoded EdgeInsets → Use `ResponsivePadding`
7. **Layout Structure:**

   - Mobile: Single column, full width
   - Tablet: 2 columns, max width 768px
   - Desktop: 3+ columns, max width 1200px

8. **Sử dụng `ResponsiveScreen` wrapper cho screens mới**
9. **Sử dụng `ResponsiveLayoutConfig` cho spacing values**
10. **Font sizes tự động scale theo device type qua `ResponsiveText`**

### Git Workflow Rules

1. **Commit message:** `[type] description` (ví dụ: `[feat] Add assignment builder`)
2. **One commit = One feature** (không commit nhiều features không liên quan)
3. **Check before commit:** `flutter analyze` và `dart format`

---

## CẬP NHẬT MEMORY BANK

### Khi nào cập nhật

- Sau khi hoàn thành code changes quan trọng
- Khi phát hiện patterns mới
- Khi có thay đổi về kiến trúc
- Khi user yêu cầu "update memory bank"

### Files cần cập nhật

- `activeContext.md`: Recently Completed, Current Sprint Focus
- `progress.md`: What works, Current status
- `systemPatterns.md`: Thêm patterns mới nếu có
- `techContext.md`: Dependencies hoặc setup nếu có thay đổi

### Cách cập nhật

- Sử dụng `read_file` để đọc file
- Sử dụng `write` hoặc `search_replace` để cập nhật
- **KHÔNG** sử dụng MCP Memory tool (Memory Bank là files thực tế)

---

## TEMPLATE CHO CÁC TASK PHỔ BIẾN

### Template: Tạo Entity

```dart
// lib/domain/entities/example.dart
class Example {
  final String id;
  final String name;
  final DateTime createdAt;

  Example({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### Template: Tạo Repository Interface

```dart
// lib/domain/repositories/example_repository.dart
import 'package:ai_mls/domain/entities/example.dart';

abstract class ExampleRepository {
  Future<Example> getExample(String id);
  Future<List<Example>> getExamples();
  Future<void> createExample(Example example);
}
```

### Template: Tạo DataSource

```dart
// lib/data/datasources/example_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_mls/core/utils/custom_exception.dart';

class ExampleDataSource {
  final SupabaseClient _client;

  ExampleDataSource(this._client);

  Future<Map<String, dynamic>> getExample(String id) async {
    try {
      final response = await _client
          .from('examples')
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw CustomException(message: 'Failed to get example: $e');
    }
  }
}
```

### Template: Tạo Repository Implementation

```dart
// lib/data/repositories/example_repository_impl.dart
import 'package:ai_mls/domain/entities/example.dart';
import 'package:ai_mls/domain/repositories/example_repository.dart';
import 'package:ai_mls/data/datasources/example_datasource.dart';
import 'package:ai_mls/core/utils/custom_exception.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleDataSource _dataSource;

  ExampleRepositoryImpl(this._dataSource);

  @override
  Future<Example> getExample(String id) async {
    try {
      final response = await _dataSource.getExample(id);
      return Example.fromJson(response);
    } on CustomException catch (e) {
      // Translate error to Vietnamese
      throw CustomException(message: 'Không thể lấy dữ liệu: ${e.message}');
    }
  }
}
```

### Template: Tạo ViewModel

```dart
// lib/presentation/viewmodels/example_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:ai_mls/domain/entities/example.dart';
import 'package:ai_mls/domain/repositories/example_repository.dart';

class ExampleViewModel extends ChangeNotifier {
  final ExampleRepository _repository;

  ExampleViewModel(this._repository);

  // State
  bool _isLoading = false;
  String? _errorMessage;
  Example? _example;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Example? get example => _example;

  // Methods
  Future<void> loadExample(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _example = await _repository.getExample(id);
      _errorMessage = null;
    } on CustomException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Template: Tạo Screen với ViewModel

```dart

// lib/
```

### Template: Tạo Responsive Screen

```dart
// lib/presentation/views/example/example_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/responsive_utils.dart';
import 'package:ai_mls/widgets/responsive/responsive_screen.dart';
import 'package:ai_mls/widgets/responsive/responsive_container.dart';
import 'package:ai_mls/widgets/responsive/responsive_padding.dart';
import 'package:ai_mls/widgets/responsive/responsive_text.dart';
import 'package:ai_mls/widgets/responsive/responsive_row.dart';
import 'package:ai_mls/widgets/responsive/responsive_grid.dart';
import 'package:ai_mls/widgets/responsive/responsive_card.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScreen(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ListView(
      padding: EdgeInsets.all(config.screenPadding),
      children: [
        ResponsiveText(
          'Tiêu đề',
          fontSize: DesignTypography.headlineLargeSize,
        ),
        SizedBox(height: config.sectionSpacing),
        ResponsiveCard(
          child: ResponsiveText('Nội dung card'),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ListView(
      padding: EdgeInsets.all(config.screenPadding),
      children: [
        ResponsiveText(
          'Tiêu đề',
          fontSize: DesignTypography.headlineLargeSize,
        ),
        SizedBox(height: config.sectionSpacing),
        ResponsiveGrid(
          children: [
            ResponsiveCard(child: ResponsiveText('Card 1')),
            ResponsiveCard(child: ResponsiveText('Card 2')),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ListView(
      padding: EdgeInsets.all(config.screenPadding),
      children: [
        ResponsiveText(
          'Tiêu đề',
          fontSize: DesignTypography.headlineLargeSize,
        ),
        SizedBox(height: config.sectionSpacing),
        ResponsiveGrid(
          desktopColumns: 3,
          children: [
            ResponsiveCard(child: ResponsiveText('Card 1')),
            ResponsiveCard(child: ResponsiveText('Card 2')),
            ResponsiveCard(child: ResponsiveText('Card 3')),
          ],
        ),
      ],
    );
  }
}
```

**Lưu ý:**

- Sử dụng `ResponsiveScreen` wrapper để tự động apply responsive layout
- Sử dụng `ResponsiveUtils.getLayoutConfig()` để lấy spacing values
- Sử dụng responsive widgets thay vì hardcoded values
- Có thể tạo layout riêng cho từng device type hoặc dùng chung
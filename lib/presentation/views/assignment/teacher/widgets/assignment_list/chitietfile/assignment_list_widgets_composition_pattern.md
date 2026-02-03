# Assignment List Widgets - Composition Pattern

## Tổng quan

Thư mục `lib/presentation/views/assignment/teacher/widgets/assignment_list/` chứa các widget tái sử dụng được thiết kế theo **Composition Pattern** để hiển thị danh sách assignment. Pattern này giúp:

- **Giảm code trùng lặp**: Tái sử dụng widget thay vì copy-paste code
- **Dễ maintain**: Sửa 1 chỗ, áp dụng cho tất cả màn hình
- **Dễ mở rộng**: Thêm loại assignment mới chỉ cần config
- **Dễ test**: Test từng widget nhỏ riêng biệt
- **Performance tốt**: Chỉ rebuild phần cần thiết

## Cấu trúc Files

### 1. `assignment_list.dart` (Export File)
**Chức năng**: File export để import tất cả widgets cùng lúc

**Mục đích**: 
- Tập trung exports, dễ import: `import 'package:.../assignment_list.dart'`
- Cung cấp documentation và usage examples

**Usage**:
```dart
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list.dart';
```

---

### 2. `assignment_card.dart` (Card Widget)
**Chức năng**: Widget hiển thị một assignment trong danh sách

**Thành phần**:
- **Header**: Title + Badge (trạng thái: "Bản nháp" hoặc "Đã xuất bản")
- **Description**: Mô tả bài tập (nếu có)
- **Metadata**: Điểm, ngày hết hạn, thời gian cập nhật
- **Action Button**: Nút hành động (Chỉnh sửa/Xem chi tiết)

**Parameters**:
- `assignment`: Assignment entity
- `badgeConfig`: Config cho badge (màu sắc, text)
- `actionConfig`: Config cho action button (icon, label, callback)
- `metadataConfig`: Config hiển thị metadata (showPoints, showDueDate, showLastUpdated)
- `onTap`: Callback khi tap vào card (optional, default: navigate to edit)

**Design Pattern**: 
- **StatelessWidget**: Pure UI component, không có state
- **Composition**: Nhận config từ bên ngoài, không hardcode logic

**Usage**:
```dart
AssignmentCard(
  assignment: assignment,
  badgeConfig: AssignmentBadgeConfig.draft,
  actionConfig: AssignmentActionConfig(
    label: 'Chỉnh sửa',
    icon: Icons.edit_outlined,
    onPressed: () => navigateToEdit(assignment),
  ),
  metadataConfig: AssignmentMetadataConfig.draft,
)
```

---

### 3. `assignment_card_config.dart` (Configuration Classes)
**Chức năng**: Định nghĩa các config classes để customize AssignmentCard

**Classes**:

#### `AssignmentBadgeConfig`
Config cho badge hiển thị trạng thái assignment:
- `label`: Text hiển thị ("Bản nháp", "Đã xuất bản")
- `backgroundColor`: Màu nền badge
- `borderColor`: Màu viền badge
- `textColor`: Màu chữ badge

**Presets**:
- `AssignmentBadgeConfig.draft`: Badge màu cam cho draft
- `AssignmentBadgeConfig.published`: Badge màu xanh lá cho published

#### `AssignmentActionConfig`
Config cho action button:
- `label`: Text button ("Chỉnh sửa", "Xem chi tiết")
- `icon`: Icon button (Icons.edit_outlined, Icons.visibility_outlined)
- `onPressed`: Callback khi click button

#### `AssignmentMetadataConfig`
Config cho metadata display:
- `showPoints`: Hiển thị điểm (default: true)
- `showDueDate`: Hiển thị ngày hết hạn (default: false)
- `showLastUpdated`: Hiển thị thời gian cập nhật (default: true)

**Presets**:
- `AssignmentMetadataConfig.draft`: Không hiển thị due date
- `AssignmentMetadataConfig.published`: Hiển thị đầy đủ metadata

**Design Pattern**: 
- **Value Objects**: Immutable config objects
- **Factory Methods**: Preset configs cho các use cases phổ biến

---

### 4. `assignment_list_view.dart` (List View Widget)
**Chức năng**: Widget wrapper cho danh sách assignments với pull-to-refresh

**Thành phần**:
- **AppRefreshIndicator**: Wrap để có pull-to-refresh
- **ListView.builder**: Render danh sách assignments
- **Empty State**: Hiển thị khi danh sách rỗng

**Parameters**:
- `assignments`: List assignments để hiển thị
- `badgeConfig`: Config badge cho tất cả cards
- `actionBuilder`: Function tạo action config cho từng assignment
- `metadataConfig`: Config metadata cho tất cả cards
- `emptyState`: Empty state widget
- `onRefresh`: Callback khi pull-to-refresh

**Design Pattern**:
- **Composition**: Compose AssignmentCard và EmptyState
- **Builder Pattern**: `actionBuilder` function để customize action cho từng item

**Usage**:
```dart
AssignmentListView(
  assignments: filteredAssignments,
  badgeConfig: AssignmentBadgeConfig.draft,
  actionBuilder: (assignment) => AssignmentActionConfig(...),
  metadataConfig: AssignmentMetadataConfig.draft,
  emptyState: AssignmentEmptyState.draft(),
  onRefresh: () async => refresh(),
)
```

---

### 5. `assignment_empty_state.dart` (Empty State Widget)
**Chức năng**: Widget hiển thị khi danh sách assignment rỗng

**Thành phần**:
- **Icon**: Icon đại diện (Icons.edit_document, Icons.assignment_outlined)
- **Title**: Tiêu đề ("Chưa có bài tập nháp")
- **Description**: Mô tả hướng dẫn

**Factory Methods**:
- `AssignmentEmptyState.draft()`: Empty state cho draft assignments
- `AssignmentEmptyState.published()`: Empty state cho published assignments

**Design Pattern**:
- **Factory Pattern**: Factory methods cho các preset
- **StatelessWidget**: Pure UI component

**Usage**:
```dart
AssignmentEmptyState.draft()
// hoặc
AssignmentEmptyState(
  icon: Icons.custom_icon,
  title: 'Custom Title',
  description: 'Custom Description',
)
```

---

### 6. `assignment_error_state.dart` (Error State Widget)
**Chức năng**: Widget hiển thị khi có lỗi xảy ra

**Thành phần**:
- **Error Icon**: Icon lỗi
- **Error Message**: Thông báo lỗi
- **Retry Button**: Nút thử lại
- **Pull-to-refresh**: Hỗ trợ pull-to-refresh để retry

**Parameters**:
- `error`: Error message string
- `onRetry`: Callback khi click retry button

**Design Pattern**:
- **StatelessWidget**: Pure UI component
- **Composition**: Wrap trong AppRefreshIndicator

**Usage**:
```dart
AssignmentErrorState(
  error: error.toString(),
  onRetry: () => refresh(),
)
```

---

### 7. `assignment_date_formatter.dart` (Utility Class)
**Chức năng**: Utility class để format dates cho assignment cards

**Methods**:

#### `formatLastUpdated(DateTime? dateTime)`
Format thời gian cập nhật thành text dễ đọc:
- "Vừa xong" (< 1 phút)
- "X phút trước" (< 1 giờ)
- "X giờ trước" (< 1 ngày)
- "Hôm qua" (1 ngày)
- "X ngày trước" (< 7 ngày)
- "DD/MM/YYYY" (≥ 7 ngày)

#### `formatDueDate(DateTime dueDate)`
Format ngày hết hạn:
- "Hết hạn hôm nay" (0 ngày)
- "Hết hạn ngày mai" (1 ngày)
- "Hết hạn sau X ngày" (> 1 ngày)
- "Đã hết hạn" (quá hạn)

**Design Pattern**:
- **Static Utility Class**: Không cần instance, chỉ có static methods
- **Pure Functions**: Không có side effects

**Usage**:
```dart
AssignmentDateFormatter.formatLastUpdated(assignment.updatedAt)
AssignmentDateFormatter.formatDueDate(assignment.dueAt!)
```

---

## Design Principles

### 1. Composition over Configuration
- Không dùng config class phức tạp
- Tách thành các widget nhỏ, compose lại
- Mỗi widget có trách nhiệm rõ ràng

### 2. Single Responsibility
- Mỗi widget chỉ làm 1 việc
- `AssignmentCard`: Hiển thị 1 assignment
- `AssignmentListView`: Quản lý list và refresh
- `AssignmentEmptyState`: Hiển thị empty state

### 3. Open/Closed Principle
- Open for extension: Dễ thêm loại assignment mới
- Closed for modification: Không cần sửa code cũ

### 4. Dependency Inversion
- Widget nhận config từ bên ngoài
- Không hardcode logic trong widget

## Best Practices

### ✅ Nên làm:
1. **Sử dụng preset configs**: `AssignmentBadgeConfig.draft`, `AssignmentMetadataConfig.published`
2. **Compose widgets**: Screen chỉ compose, không có logic UI phức tạp
3. **Tái sử dụng**: Dùng lại widgets cho các màn hình tương tự
4. **Test từng widget**: Test riêng từng widget nhỏ

### ❌ Không nên:
1. **Hardcode config**: Không hardcode màu sắc, text trong widget
2. **Copy-paste code**: Không copy code, dùng lại widgets
3. **Logic phức tạp trong widget**: Logic nên ở screen hoặc viewmodel
4. **Over-engineering**: Không tạo config class quá phức tạp

## Ví dụ sử dụng

### Screen sử dụng widgets:

```dart
class TeacherDraftAssignmentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Kho bài tập nháp')),
      body: FutureBuilder<List<Assignment>>(
        future: loadAssignments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AssignmentErrorState(
              error: snapshot.error.toString(),
              onRetry: () => refresh(),
            );
          }
          
          final assignments = filterDrafts(snapshot.data ?? []);
          
          return AssignmentListView(
            assignments: assignments,
            badgeConfig: AssignmentBadgeConfig.draft,
            actionBuilder: (assignment) => AssignmentActionConfig(
              label: 'Chỉnh sửa',
              icon: Icons.edit_outlined,
              onPressed: () => navigateToEdit(assignment),
            ),
            metadataConfig: AssignmentMetadataConfig.draft,
            emptyState: AssignmentEmptyState.draft(),
            onRefresh: () => refresh(),
          );
        },
      ),
    );
  }
}
```

## Mở rộng

Để thêm loại assignment mới (ví dụ: "Đã phân phối"):

1. **Thêm badge config**:
```dart
// Trong assignment_card_config.dart
static const distributed = AssignmentBadgeConfig(
  label: 'Đã phân phối',
  backgroundColor: Color(0xFFE0E7FF),
  borderColor: Color(0xFFA78BFA),
  textColor: Color(0xFF6366F1),
);
```

2. **Thêm empty state** (nếu cần):
```dart
// Trong assignment_empty_state.dart
factory AssignmentEmptyState.distributed() {
  return const AssignmentEmptyState(
    icon: Icons.share,
    title: 'Chưa có bài tập đã phân phối',
    description: 'Phân phối bài tập để quản lý tại đây',
  );
}
```

3. **Sử dụng trong screen**:
```dart
AssignmentListView(
  assignments: distributedAssignments,
  badgeConfig: AssignmentBadgeConfig.distributed,
  // ... other configs
)
```

## Kết luận

Pattern này giúp:
- ✅ Code gọn, dễ đọc
- ✅ Dễ maintain và mở rộng
- ✅ Tái sử dụng cao
- ✅ Test dễ dàng
- ✅ Performance tốt

Tuân thủ các nguyên tắc này giúp codebase dễ maintain và scale tốt.

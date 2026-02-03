# Giải thích các File trong Assignment List Widgets

## Tổng quan

Thư mục `lib/presentation/views/assignment/teacher/widgets/assignment_list/` chứa các widget tái sử dụng được thiết kế theo **Composition Pattern** để hiển thị danh sách assignment. Pattern này giúp giảm code trùng lặp, dễ maintain và mở rộng.

---

## 1. `assignment_list.dart` (Export File)

**Chức năng**: File export để import tất cả widgets cùng lúc

**Mục đích**: 
- Tập trung exports, dễ import: `import 'package:.../assignment_list.dart'`
- Cung cấp documentation và usage examples
- Giảm số lượng import statements trong code

**Cấu trúc**:
```dart
export 'assignment_card.dart';
export 'assignment_card_config.dart';
export 'assignment_date_formatter.dart';
export 'assignment_empty_state.dart';
export 'assignment_error_state.dart';
export 'assignment_list_view.dart';
```

**Usage**:
```dart
// Thay vì import từng file:
import 'assignment_card.dart';
import 'assignment_card_config.dart';
// ...

// Chỉ cần:
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list.dart';
```

---

## 2. `assignment_card.dart` (Card Widget)

**Chức năng**: Widget hiển thị một assignment trong danh sách

**Thành phần hiển thị**:
- **Header**: Title + Badge (trạng thái: "Bản nháp" hoặc "Đã xuất bản")
- **Description**: Mô tả bài tập (nếu có)
- **Metadata**: Điểm, ngày hết hạn, thời gian cập nhật
- **Action Button**: Nút hành động (Chỉnh sửa/Xem chi tiết)

**Parameters**:
- `assignment`: Assignment entity cần hiển thị
- `badgeConfig`: Config cho badge (màu sắc, text) - từ `AssignmentBadgeConfig`
- `actionConfig`: Config cho action button (icon, label, callback) - từ `AssignmentActionConfig`
- `metadataConfig`: Config hiển thị metadata (showPoints, showDueDate, showLastUpdated) - từ `AssignmentMetadataConfig`
- `onTap`: Callback khi tap vào card (optional, default: navigate to edit)

**Design Pattern**: 
- **StatelessWidget**: Pure UI component, không có state
- **Composition**: Nhận config từ bên ngoài, không hardcode logic
- **Single Responsibility**: Chỉ render UI, không có business logic

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

**Lợi ích**:
- Tái sử dụng cho mọi loại assignment (draft, published, distributed, etc.)
- Dễ customize thông qua config
- Dễ test vì là pure widget

---

## 3. `assignment_card_config.dart` (Configuration Classes)

**Chức năng**: Định nghĩa các config classes để customize AssignmentCard

### 3.1. `AssignmentBadgeConfig`
Config cho badge hiển thị trạng thái assignment:
- `label`: Text hiển thị ("Bản nháp", "Đã xuất bản")
- `backgroundColor`: Màu nền badge
- `borderColor`: Màu viền badge
- `textColor`: Màu chữ badge

**Presets**:
- `AssignmentBadgeConfig.draft`: Badge màu cam cho draft
- `AssignmentBadgeConfig.published`: Badge màu xanh lá cho published

**Usage**:
```dart
// Sử dụng preset
badgeConfig: AssignmentBadgeConfig.draft

// Hoặc tạo custom
badgeConfig: AssignmentBadgeConfig(
  label: 'Đã phân phối',
  backgroundColor: Colors.blue[50]!,
  borderColor: Colors.blue[300]!,
  textColor: Colors.blue[700]!,
)
```

### 3.2. `AssignmentActionConfig`
Config cho action button:
- `label`: Text button ("Chỉnh sửa", "Xem chi tiết")
- `icon`: Icon button (Icons.edit_outlined, Icons.visibility_outlined)
- `onPressed`: Callback khi click button

**Usage**:
```dart
actionConfig: AssignmentActionConfig(
  label: 'Chỉnh sửa',
  icon: Icons.edit_outlined,
  onPressed: () => navigateToEdit(assignment),
)
```

### 3.3. `AssignmentMetadataConfig`
Config cho metadata display:
- `showPoints`: Hiển thị điểm (default: true)
- `showDueDate`: Hiển thị ngày hết hạn (default: false)
- `showLastUpdated`: Hiển thị thời gian cập nhật (default: true)

**Presets**:
- `AssignmentMetadataConfig.draft`: Không hiển thị due date
- `AssignmentMetadataConfig.published`: Hiển thị đầy đủ metadata

**Usage**:
```dart
metadataConfig: AssignmentMetadataConfig.draft
// hoặc
metadataConfig: AssignmentMetadataConfig(
  showPoints: true,
  showDueDate: true,
  showLastUpdated: true,
)
```

**Design Pattern**: 
- **Value Objects**: Immutable config objects
- **Factory Methods**: Preset configs cho các use cases phổ biến

---

## 4. `assignment_list_view.dart` (List View Widget)

**Chức năng**: Widget wrapper cho danh sách assignments với pull-to-refresh

**Thành phần**:
- **AppRefreshIndicator**: Wrap để có pull-to-refresh
- **ListView.builder**: Render danh sách assignments
- **Empty State**: Hiển thị khi danh sách rỗng

**Parameters**:
- `assignments`: List assignments để hiển thị
- `badgeConfig`: Config badge cho tất cả cards
- `actionBuilder`: Function tạo action config cho từng assignment (cho phép customize per item)
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
  actionBuilder: (assignment) => AssignmentActionConfig(
    label: 'Chỉnh sửa',
    icon: Icons.edit_outlined,
    onPressed: () => navigateToEdit(assignment),
  ),
  metadataConfig: AssignmentMetadataConfig.draft,
  emptyState: AssignmentEmptyState.draft(),
  onRefresh: () async => refresh(),
)
```

**Lợi ích**:
- Tự động xử lý empty state
- Tự động xử lý pull-to-refresh
- Dễ customize action cho từng assignment

---

## 5. `assignment_empty_state.dart` (Empty State Widget)

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
// Sử dụng factory method
emptyState: AssignmentEmptyState.draft()

// Hoặc tạo custom
emptyState: AssignmentEmptyState(
  icon: Icons.custom_icon,
  title: 'Custom Title',
  description: 'Custom Description',
)
```

**Lợi ích**:
- Tái sử dụng cho các loại assignment khác nhau
- Dễ customize icon, title, description
- Hỗ trợ pull-to-refresh (wrap trong SingleChildScrollView)

---

## 6. `assignment_error_state.dart` (Error State Widget)

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

**Lợi ích**:
- Tái sử dụng cho mọi error state
- Hỗ trợ cả retry button và pull-to-refresh
- Consistent error UI across app

---

## 7. `assignment_date_formatter.dart` (Utility Class)

**Chức năng**: Utility class để format dates cho assignment cards

### 7.1. `formatLastUpdated(DateTime? dateTime)`
Format thời gian cập nhật thành text dễ đọc:
- "Vừa xong" (< 1 phút)
- "X phút trước" (< 1 giờ)
- "X giờ trước" (< 1 ngày)
- "Hôm qua" (1 ngày)
- "X ngày trước" (< 7 ngày)
- "DD/MM/YYYY" (≥ 7 ngày)

**Usage**:
```dart
AssignmentDateFormatter.formatLastUpdated(assignment.updatedAt)
```

### 7.2. `formatDueDate(DateTime dueDate)`
Format ngày hết hạn:
- "Hết hạn hôm nay" (0 ngày)
- "Hết hạn ngày mai" (1 ngày)
- "Hết hạn sau X ngày" (> 1 ngày)
- "Đã hết hạn" (quá hạn)

**Usage**:
```dart
AssignmentDateFormatter.formatDueDate(assignment.dueAt!)
```

**Design Pattern**:
- **Static Utility Class**: Không cần instance, chỉ có static methods
- **Pure Functions**: Không có side effects

**Lợi ích**:
- Tái sử dụng logic format dates
- Consistent date formatting across app
- Dễ test và maintain

---

## Tóm tắt

| File | Chức năng | Pattern | Tái sử dụng |
|------|-----------|---------|-------------|
| `assignment_list.dart` | Export file | Module Pattern | ✅ |
| `assignment_card.dart` | Card widget | Composition | ✅ High |
| `assignment_card_config.dart` | Config classes | Value Objects | ✅ High |
| `assignment_list_view.dart` | List view wrapper | Composition | ✅ High |
| `assignment_empty_state.dart` | Empty state | Factory Pattern | ✅ Medium |
| `assignment_error_state.dart` | Error state | Composition | ✅ Medium |
| `assignment_date_formatter.dart` | Date utility | Static Utility | ✅ High |

---

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

---

## Ví dụ sử dụng hoàn chỉnh

```dart
// Screen chỉ compose các widget
class TeacherDraftAssignmentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Kho bài tập nháp')),
      body: FutureBuilder<List<Assignment>>(
        future: loadAssignments(),
        builder: (context, snapshot) {
          // Error state
          if (snapshot.hasError) {
            return AssignmentErrorState(
              error: snapshot.error.toString(),
              onRetry: () => refresh(),
            );
          }
          
          // Filter và sort
          final assignments = filterDrafts(snapshot.data ?? []);
          
          // List view với các widget compose
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

---

## Kết luận

Pattern này giúp:
- ✅ Code gọn, dễ đọc (giảm ~70% code trùng lặp)
- ✅ Dễ maintain (sửa 1 chỗ, áp dụng cho tất cả)
- ✅ Dễ mở rộng (thêm loại assignment mới chỉ cần config)
- ✅ Dễ test (test từng widget nhỏ)
- ✅ Performance tốt (chỉ rebuild phần cần thiết)
- ✅ Nhất quán UI/UX

Tuân thủ các nguyên tắc này giúp codebase dễ maintain và scale tốt.

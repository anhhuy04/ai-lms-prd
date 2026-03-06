---
name: ui-widgets
description: "Kích hoạt khi code UI, thiết kế Layout, Widget composition, áp dụng Design Tokens, giải quyết lỗi Overflow/Rebuild UI, tối ưu performance render."
---

# Kỹ năng: UI, Widgets & Performance

Tuân thủ các chuẩn sau khi code tệp UI / Widgets:

## 1. Composition Over Inheritance (Module hoá UI)

- ĐỪNG NHÉT HẾT VÀO HÀM `build()`. Max 50 dòng — split thành private methods `_buildXxx()`.
- Widget dùng lại 2+ lần → tách thành `StatelessWidget` riêng trong file riêng.
- Dùng `const` constructors everywhere.

```dart
// ❌ SAI — fat build()
Widget build(BuildContext context) {
  return Column(children: [
    // 200 dòng code...
  ]);
}

// ✅ ĐÚNG — composition
Widget build(BuildContext context) {
  return Column(children: [
    _buildHeader(),
    _buildCourseList(),
    _buildFooterActions(),
  ]);
}
```

## 2. Design Tokens — Bắt buộc

| Loại | Dùng | Cấm |
|---|---|---|
| Màu sắc | `DesignColors.*` | `Color(0xFF...)`, `Colors.blue` |
| Spacing | `DesignSpacing.xs/sm/md/lg/xl` | `EdgeInsets.all(16)` raw |
| Typography | `DesignTypography.*` | `TextStyle(fontSize: 14)` raw |
| Icon size | `DesignIcons.*` | hardcoded `24.0` |
| Border radius | `DesignRadius.*` | `BorderRadius.circular(8)` raw |
| Shadows | `DesignElevation.level*` | `BoxShadow(...)` raw |

Khoảng cách dùng `Gap(16)` từ `gap` package, không dùng `SizedBox(height: 16)` hay `Padding` bọc loạn.

## 3. Loading States (Bắt buộc UX)

### 3.1 Shimmer Loading - Khi nào dùng

Không dùng màn hình trắng hay spinner đơn thuần cho list/page load:

```dart
// ✅ List có avatar + text
ShimmerListTileLoading()

// ✅ Class list / card list lớn
ShimmerLoading()

// ✅ Dashboard / trang tổng hợp
ShimmerDashboardLoading()

// ✅ Chỉ dùng cho submit button / thao tác ngắn
CircularProgressIndicator(strokeWidth: 2)
```

Tất cả shimmer widgets: `lib/widgets/loading/shimmer_loading.dart`

### 3.2 Tách riêng phần Load - QUAN TRỌNG

**NGUYÊN TẮC:** Khi tạo mới màn hình có load dữ liệu:
- Header, title, search bar, filters → KHÔNG bị load cùng
- Chỉ phần nội dung/danh sách mới bị load

**Cách thực hiện:**

```dart
// ❌ SAI - Toàn bộ screen bị load
Scaffold(
  body: FutureBuilder(
    future: apiCall(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return ShimmerLoading(); // Load cả header!
      }
      return Column(children: [
        Header(), // Bị load cùng
        ListView(), // Bị load cùng
      ]);
    }
  )
)

// ✅ ĐÚNG - Tách riêng phần load
Scaffold(
  body: Column(
    children: [
      // Header - HIỆN NGAY, không load
      _buildHeader(),

      // Chỉ phần list bị load
      Expanded(
        child: _ContentSection() // Widget riêng có FutureBuilder
      ),
    ]
  )
)

// Widget riêng cho phần load
class _ContentSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(repoProvider).getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: ShimmerLoading(); // Chỉ shimmer phần content
          );
        }
        return ListView(...);
      }
    );
  }
}
```

**Quy tắc quan trọng:**
1. **Tách widget riêng** cho phần load data (thường là `_XxxListSection`)
2. **Dùng `ConsumerWidget`** hoặc `ConsumerStatefulWidget` để truy cập providers
3. **Shimmer chỉ bao quanh** phần list/content, không bao gồm header/search
4. **Design tokens** dùng cho cả header và content (đồng bộ màu/spacing)

## 4. Responsive với flutter_screenutil

```dart
// Kích thước
Container(width: 200.w, height: 100.h)

// Font
Text('Hello', style: TextStyle(fontSize: 16.sp))

// Border radius
BorderRadius.circular(8.r)

// Breakpoints
if (DesignBreakpoints.isTablet(context)) { ... }
```

## 5. UI Bugs & Fixes

```dart
// Overflow → SingleChildScrollView
SingleChildScrollView(child: Column(children: [...]))

// RenderBox not laid out (ListView trong Column)
Expanded(child: ListView.builder(...))
// hoặc
SizedBox(height: 300.h, child: ListView.builder(...))

// Lag rebuild → RepaintBoundary cho UI phức tạp tĩnh
RepaintBoundary(
  child: ComplexStaticChart(data: data),
)

// List item lag → tách class + const
class CourseListItem extends StatelessWidget {
  const CourseListItem({required this.course, super.key}); // const!
  final CourseEntity course;
}
```

## 6. Performance Patterns

### AutomaticKeepAliveClientMixin — Giữ state tab

```dart
class CourseTabContent extends StatefulWidget { ... }

class _CourseTabContentState extends State<CourseTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // BẮT BUỘC gọi super.build
    return CourseListScreen();
  }
}
```

### Keyboard dismiss on scroll

```dart
ListView.builder(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  itemBuilder: (context, index) => ...,
)
```

### Search Highlighting (Vietnamese)

```dart
// Dùng SmartHighlightText cho tất cả kết quả search — hỗ trợ dấu tiếng Việt
SmartHighlightText(
  text: course.title,
  highlight: searchQuery,
  style: DesignTypography.body1,
  highlightStyle: DesignTypography.body1.copyWith(
    color: DesignColors.primary,
    fontWeight: FontWeight.bold,
  ),
)
```

## 7. Specific Component Guidelines

- **Switch trong danh sách cài đặt**: Bọc `Transform.scale(scale: 0.65)` để đồng nhất kích thước với Design.
- **Touch targets**: Tối thiểu 48×48dp — dùng `InkWell` với `minimumSize`.
- **Accessibility**: Thêm `Semantics` label cho icon buttons, images không có text.

```dart
// Switch scale
Transform.scale(
  scale: 0.65,
  child: Switch(value: isEnabled, onChanged: onChanged),
)

// Accessible icon button
Semantics(
  label: 'Xóa khóa học',
  child: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
)
```

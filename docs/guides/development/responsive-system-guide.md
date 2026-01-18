# Responsive System Guide - AI LMS

## Tổng quan

Hệ thống Responsive UI được thiết kế để tự động điều chỉnh giao diện cho các loại thiết bị khác nhau (mobile, tablet, desktop) một cách nhất quán và dễ dàng bảo trì.

## Kiến trúc

### Core Infrastructure

#### 1. Device Types (`lib/core/constants/device_types.dart`)

Định nghĩa các loại thiết bị:
- `DeviceType.mobile` - < 600dp
- `DeviceType.tablet` - 600-1199dp
- `DeviceType.desktop` - >= 1200dp

#### 2. Responsive Config (`lib/core/constants/responsive_config.dart`)

Cung cấp cấu hình layout cho từng device type:
- `screenPadding` - Padding từ cạnh màn hình
- `cardPadding` - Padding bên trong cards
- `sectionSpacing` - Khoảng cách giữa các sections
- `maxColumns` - Số cột tối đa cho grid
- `maxContentWidth` - Chiều rộng tối đa của nội dung
- `gridSpacing` - Khoảng cách giữa các items trong grid
- `itemSpacing` - Khoảng cách giữa các items

#### 3. Responsive Utils (`lib/core/utils/responsive_utils.dart`)

Utilities chính để:
- Detect device type: `getDeviceType()`, `isMobile()`, `isTablet()`, `isDesktop()`
- Tính toán responsive values: `responsiveValue()`
- Lấy screen dimensions: `screenWidth()`, `screenHeight()`
- Lấy layout config: `getLayoutConfig()`

### Responsive Widgets

Tất cả widgets responsive nằm trong `lib/widgets/responsive/`:

#### ResponsiveContainer
Container tự động điều chỉnh padding/spacing theo device type.

```dart
ResponsiveContainer(
  child: YourWidget(),
)
```

#### ResponsivePadding
Padding tự động theo device type.

```dart
ResponsivePadding(
  all: 16.0, // hoặc horizontal, vertical, top, bottom, left, right
  child: YourWidget(),
)
```

#### ResponsiveText
Text với font size tự động scale theo device type.

```dart
ResponsiveText(
  'Your text',
  fontSize: 16.0, // Base size cho mobile
  style: TextStyle(color: Colors.black),
)
```

#### ResponsiveGrid
Grid layout tự động điều chỉnh số cột theo device type.

```dart
ResponsiveGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  children: [
    Card1(),
    Card2(),
    Card3(),
  ],
)
```

#### ResponsiveRow
Row với responsive spacing và alignment.

```dart
ResponsiveRow(
  spacing: 16.0, // Tự động điều chỉnh
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

#### ResponsiveCard
Card với responsive padding và sizing.

```dart
ResponsiveCard(
  padding: EdgeInsets.all(16), // Optional override
  decoration: BoxDecoration(...), // Optional
  child: YourContent(),
)
```

#### ResponsiveScreen
Wrapper cho screens để tự động apply responsive layout.

```dart
ResponsiveScreen(
  mobile: MobileLayout(),
  tablet: TabletLayout(), // Optional
  desktop: DesktopLayout(), // Optional
  useMaxWidth: true,
  maxContentWidth: 1200.0, // Optional
)
```

## Cách sử dụng

### 1. Tạo Screen mới với Responsive System

```dart
import 'package:ai_mls/core/utils/responsive_utils.dart';
import 'package:ai_mls/widgets/responsive/responsive_screen.dart';
import 'package:ai_mls/widgets/responsive/responsive_text.dart';
import 'package:ai_mls/widgets/responsive/responsive_card.dart';

class MyScreen extends StatelessWidget {
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
        ResponsiveText('Title', fontSize: 20),
        SizedBox(height: config.sectionSpacing),
        ResponsiveCard(child: Text('Content')),
      ],
    );
  }
}
```

### 2. Sử dụng Responsive Values

```dart
// Lấy config cho device hiện tại
final config = ResponsiveUtils.getLayoutConfig(context);

// Sử dụng spacing từ config
SizedBox(height: config.sectionSpacing);
EdgeInsets.all(config.screenPadding);

// Tính toán responsive value
final padding = ResponsiveUtils.responsiveValue(
  context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

### 3. Responsive Grid Layout

```dart
ResponsiveGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  spacing: 16.0,
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### 4. Responsive Text

```dart
ResponsiveText(
  'Your text here',
  fontSize: DesignTypography.bodyMediumSize, // Base size
  style: TextStyle(fontWeight: FontWeight.bold),
)
```

## Breakpoints

| Device Type | Width Range | Max Content Width | Columns |
|-------------|-------------|-------------------|---------|
| Mobile | < 600dp | Full width | 1 |
| Tablet | 600-1199dp | 768dp | 2 |
| Desktop | >= 1200dp | 1200dp | 3+ |

## Best Practices

### ✅ DO

1. **Luôn sử dụng ResponsiveUtils** để detect device type
2. **Luôn sử dụng ResponsiveLayoutConfig** để lấy spacing values
3. **Ưu tiên responsive widgets** từ `lib/widgets/responsive/`
4. **Sử dụng ResponsiveScreen** wrapper cho screens mới
5. **Test trên multiple screen sizes** sau mỗi thay đổi

### ❌ DON'T

1. **KHÔNG** hardcode device-specific values
2. **KHÔNG** sử dụng MediaQuery trực tiếp trong UI code
3. **KHÔNG** sử dụng hardcoded EdgeInsets
4. **KHÔNG** giả định screen size cụ thể

## Migration Guide

### Từ Hardcoded sang Responsive

**Trước:**
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello', style: TextStyle(fontSize: 16)),
)
```

**Sau:**
```dart
ResponsiveCard(
  child: ResponsiveText(
    'Hello',
    fontSize: DesignTypography.bodyMediumSize,
  ),
)
```

### Từ MediaQuery sang ResponsiveUtils

**Trước:**
```dart
final width = MediaQuery.of(context).size.width;
if (width < 600) {
  // Mobile layout
}
```

**Sau:**
```dart
if (ResponsiveUtils.isMobile(context)) {
  // Mobile layout
}
```

## Examples

### Example 1: Simple Screen

```dart
class SimpleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    
    return Scaffold(
      body: ResponsivePadding(
        all: config.screenPadding,
        child: Column(
          children: [
            ResponsiveText('Title', fontSize: 24),
            SizedBox(height: config.sectionSpacing),
            ResponsiveCard(child: Text('Content')),
          ],
        ),
      ),
    );
  }
}
```

### Example 2: Grid Layout

```dart
class GridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScreen(
      child: ResponsiveGrid(
        mobileColumns: 1,
        tabletColumns: 2,
        desktopColumns: 3,
        children: items.map((item) => ItemCard(item)).toList(),
      ),
    );
  }
}
```

### Example 3: Conditional Layout

```dart
Widget build(BuildContext context) {
  if (ResponsiveUtils.isMobile(context)) {
    return MobileLayout();
  } else if (ResponsiveUtils.isTablet(context)) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

## Troubleshooting

### Vấn đề: Layout không responsive

**Giải pháp:** Đảm bảo bạn đang sử dụng responsive widgets và không hardcode values.

### Vấn đề: Spacing không đúng

**Giải pháp:** Sử dụng `ResponsiveUtils.getLayoutConfig()` để lấy spacing values.

### Vấn đề: Text quá nhỏ/lớn

**Giải pháp:** Sử dụng `ResponsiveText` thay vì `Text` với hardcoded fontSize.

## Tài liệu tham khảo

- Design Tokens: `lib/core/constants/design_tokens.dart`
- Responsive Config: `lib/core/constants/responsive_config.dart`
- Responsive Utils: `lib/core/utils/responsive_utils.dart`
- Responsive Widgets: `lib/widgets/responsive/`

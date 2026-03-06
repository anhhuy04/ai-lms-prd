# 60 — UI & Design System

## MANDATORY: Read Design Docs Before Any UI Change
1. `memory-bank/DESIGN_SYSTEM_GUIDE.md`
2. `memory-bank/systemPatterns.md` (Design System section)
3. `lib/core/constants/design_tokens.dart`

## Design Tokens — Always Use, Never Hardcode
| Token | Source | ❌ Never |
|---|---|---|
| Colors | `DesignColors.*` | `Color(0xFF...)`, `Colors.blue` |
| Spacing | `DesignSpacing.xs/sm/md/lg/xl` | `EdgeInsets.all(16)` raw |
| Typography | `DesignTypography.*` | `TextStyle(fontSize: 14)` raw |
| Icons size | `DesignIcons.*` | hardcoded `24.0` |
| Border radius | `DesignRadius.*` | `BorderRadius.circular(8)` raw |
| Shadows | `DesignElevation.level*` | `BoxShadow(...)` raw |

## Component Standards
- Button: 44dp (medium), 36dp (small), 52dp (large)
- Input field: 48dp height
- Card min height: 100dp
- AppBar: 56dp
- Touch targets: minimum 48×48dp

## Responsive
- All sizing: `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- Device type checks: `DesignBreakpoints.*`

## Loading States (Mandatory UX)

### 3.1 Shimmer Loading - Khi nào dùng

No blank/spinner-only screens for list/page loads:
```dart
// ✅ List with avatars + text
ShimmerListTileLoading()

// ✅ Class list / large card list
ShimmerLoading()

// ✅ Dashboard / aggregate page
ShimmerDashboardLoading()

// ✅ Submit button / short op only
CircularProgressIndicator(strokeWidth: 2)
```
All shimmer widgets: `lib/widgets/loading/shimmer_loading.dart`

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

### 3.3 Quy tắc quan trọng

1. **Tách widget riêng** cho phần load data (thường là `_XxxListSection`)
2. **Dùng `ConsumerWidget`** hoặc `ConsumerStatefulWidget` để truy cập providers
3. **Shimmer chỉ bao quanh** phần list/content, không bao gồm header/search
4. **Design tokens** dùng cho cả header và content (đồng bộ màu/spacing)

## Search Highlighting
Use `SmartHighlightText` for ALL search result highlighting (supports Vietnamese diacritics).

## Key Behaviors
- Keyboard dismiss on scroll: `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`
- State-preserving tabs/pages: `AutomaticKeepAliveClientMixin`
- RenderFlex overflow: prefer `Flexible`, `Expanded`, `SingleChildScrollView`
- Null-safety in widget tree: always check before accessing properties

## Logging / I/O in UI (Forbidden)
- No `writeAsStringSync()` or network log in runtime UI loop
- Debug file log only: `kDebugMode && Platform.isWindows` + `.catchError`

## Accessibility
- Contrast ratio ≥ 4.5:1 for text
- Semantic labels for screen readers

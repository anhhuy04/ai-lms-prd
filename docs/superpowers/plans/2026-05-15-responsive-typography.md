# Responsive Typography Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Đồng bộ font chữ toàn app bằng cách inject `ResponsiveTypography` (tier-based scale 1.0/1.1/1.2 theo `DesignBreakpoints`) vào `ThemeData.textTheme` qua `MaterialApp.builder`, rồi migrate 79 file hardcoded `fontSize` thành `Theme.of(context).textTheme.X`.

**Architecture:** 3 tầng — Core (`ResponsiveTypography` engine đọc `DesignTypography` const làm base size) → Config (`MaterialApp.builder` bọc `MediaQuery` clamp 0.9–1.3 + `Theme` override) → UI (chỉ gọi `Theme.of(context).textTheme.X`). Không dùng `flutter_screenutil .sp` cho font. Migration chia 3 phase, 4 zone, mỗi commit độc lập có thể `git revert`.

**Tech Stack:** Flutter 3.16+, Riverpod, GoRouter (đã có). Mới: chỉ thêm class Dart thuần trong `lib/core/constants/design_tokens.dart`. KHÔNG thêm package.

**Spec tham chiếu:** `docs/superpowers/specs/2026-05-15-responsive-typography-design.md`

---

## File Structure (Mapping trước khi code)

### Tạo mới
- `test/unit/core/constants/responsive_typography_test.dart` — Unit test cho engine

### Sửa
- `lib/core/constants/design_tokens.dart` — Thêm `ResponsiveTypography` class cuối file (sau `DesignAccessibility`)
- `lib/core/theme/app_theme.dart` — Bỏ `.sp` trong `textTheme` static, thêm sub-themes (`inputDecorationTheme`, `bottomNavigationBarTheme`, `tabBarTheme`) dùng `textTheme.X` từ context
- `lib/main.dart` — Bổ sung logic vào `MaterialApp.router.builder` (line 305-314) để inject responsive textTheme + clamp textScaler
- `analysis_options.yaml` — Thêm script reference cho lint guard
- `.claude/CLAUDE.md` — Update §9 UI & Design System

### Sửa (Phase 2 migration — 79 file đã liệt kê trong spec)
- 6 file Zone A (Dashboard)
- ~25 file Zone B (Assignment)
- ~20 file Zone C (Class & Profile & Auth & Settings)
- ~25 file Zone D (Shared Widgets + dialog/sheet R10 wrapper)

### KHÔNG sửa
- `lib/core/utils/excel_template_generator.dart` — Output Excel point, không phải logical pixel (R1)
- `lib/core/utils/avatar_utils.dart` — Cần kiểm tra: nếu là generate avatar bitmap thì giữ literal
- Mọi file thư viện third-party trong `.dart_tool/`

---

## Phase 1 — Engine (cốt lõi, không break UI)

### Task 1.1: Viết unit test cho `ResponsiveTypography.scaleFactorFor()`

**Files:**
- Test: `test/unit/core/constants/responsive_typography_test.dart` (tạo mới)

- [ ] **Step 1: Tạo file test với 3 case mobile/tablet/desktop**

Tạo `test/unit/core/constants/responsive_typography_test.dart`:

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveTypography.scaleFactorFor', () {
    test('returns 1.0 for mobile width (<600)', () {
      expect(ResponsiveTypography.scaleFactorFor(width: 375), 1.0);
      expect(ResponsiveTypography.scaleFactorFor(width: 599.9), 1.0);
    });

    test('returns 1.1 for tablet width (600-1199)', () {
      expect(ResponsiveTypography.scaleFactorFor(width: 600), 1.1);
      expect(ResponsiveTypography.scaleFactorFor(width: 768), 1.1);
      expect(ResponsiveTypography.scaleFactorFor(width: 1199.9), 1.1);
    });

    test('returns 1.2 for desktop width (>=1200)', () {
      expect(ResponsiveTypography.scaleFactorFor(width: 1200), 1.2);
      expect(ResponsiveTypography.scaleFactorFor(width: 1920), 1.2);
    });
  });

  group('ResponsiveTypography.buildTextTheme', () {
    testWidgets('scales bodyMedium 14 → 16.8 on desktop', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late TextTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme = ResponsiveTypography.buildTextTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.bodyMedium!.fontSize, closeTo(16.8, 0.01));
      expect(theme.displayLarge!.fontSize, closeTo(33.6, 0.01));
      expect(theme.labelSmall!.fontSize, closeTo(13.2, 0.01));
    });

    testWidgets('keeps bodyMedium 14 on mobile width', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late TextTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme = ResponsiveTypography.buildTextTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.bodyMedium!.fontSize, closeTo(14.0, 0.01));
      expect(theme.displayLarge!.fontSize, closeTo(28.0, 0.01));
    });

    testWidgets('preserves weight from DesignTypography', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      addTearDown(tester.view.resetPhysicalSize);

      late TextTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme = ResponsiveTypography.buildTextTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.titleLarge!.fontWeight, FontWeight.w700); // bold
      expect(theme.titleMedium!.fontWeight, FontWeight.w600); // semiBold
      expect(theme.bodyMedium!.fontWeight, FontWeight.w400); // regular
      expect(theme.labelMedium!.fontWeight, FontWeight.w500); // medium
    });
  });
}
```

- [ ] **Step 2: Chạy test, verify FAIL với "ResponsiveTypography not defined"**

```bash
flutter test test/unit/core/constants/responsive_typography_test.dart
```

Expected output: `Error: Undefined name 'ResponsiveTypography'`.

---

### Task 1.2: Thêm class `ResponsiveTypography` vào `design_tokens.dart`

**Files:**
- Modify: `lib/core/constants/design_tokens.dart` (append cuối file, sau line 688 — sau `DesignAccessibility`)

- [ ] **Step 1: Append class engine vào cuối file**

Mở `lib/core/constants/design_tokens.dart`. Sau dòng cuối (line 688, `}` đóng `DesignAccessibility`), thêm:

```dart

// ==================== RESPONSIVE TYPOGRAPHY ENGINE ====================
/// Engine tính TextTheme động theo kích thước màn hình.
///
/// Đọc base sizes từ DesignTypography static const (mobile baseline)
/// và scale theo tier:
/// - Mobile (<600):    1.0×
/// - Tablet (600-1199): 1.1×
/// - Desktop (≥1200):   1.2×
///
/// KHÔNG dùng flutter_screenutil .sp.
///
/// Sử dụng qua MaterialApp.builder để bơm vào ThemeData.textTheme.
/// Sau đó UI chỉ cần gọi `Theme.of(context).textTheme.X`.
class ResponsiveTypography {
  ResponsiveTypography._();

  /// Tính scale factor theo screen width.
  ///
  /// Tách static để test được độc lập (không cần BuildContext).
  static double scaleFactorFor({required double width}) {
    if (width >= DesignBreakpoints.desktop) return 1.2;
    if (width >= DesignBreakpoints.tabletSmall) return 1.1;
    return 1.0;
  }

  /// Build TextTheme đã scale theo MediaQuery của context.
  ///
  /// PHẢI gọi trong MaterialApp.builder (context đã có MediaQuery).
  /// KHÔNG gọi trong main() hoặc constructor của widget gốc.
  static TextTheme buildTextTheme(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = scaleFactorFor(width: width);

    return TextTheme(
      displayLarge: DesignTypography.displayLarge.copyWith(
        fontSize: DesignTypography.displayLargeSize * scale,
      ),
      displayMedium: DesignTypography.displayMedium.copyWith(
        fontSize: DesignTypography.displayMediumSize * scale,
      ),
      displaySmall: TextStyle(
        fontSize: DesignTypography.displaySmallSize * scale,
        fontWeight: DesignTypography.bold,
        height: DesignTypography.lineHeightTight,
        color: DesignColors.textPrimary,
      ),
      headlineLarge: DesignTypography.headlineLarge.copyWith(
        fontSize: DesignTypography.headlineLargeSize * scale,
      ),
      headlineMedium: DesignTypography.headlineMedium.copyWith(
        fontSize: DesignTypography.headlineMediumSize * scale,
      ),
      headlineSmall: TextStyle(
        fontSize: DesignTypography.headlineSmallSize * scale,
        fontWeight: DesignTypography.semiBold,
        height: DesignTypography.lineHeightNormal,
        color: DesignColors.textPrimary,
      ),
      titleLarge: DesignTypography.titleLarge.copyWith(
        fontSize: DesignTypography.titleLargeSize * scale,
      ),
      titleMedium: DesignTypography.titleMedium.copyWith(
        fontSize: DesignTypography.titleMediumSize * scale,
      ),
      titleSmall: DesignTypography.titleSmall.copyWith(
        fontSize: DesignTypography.titleSmallSize * scale,
      ),
      bodyLarge: DesignTypography.bodyLarge.copyWith(
        fontSize: DesignTypography.bodyLargeSize * scale,
      ),
      bodyMedium: DesignTypography.bodyMedium.copyWith(
        fontSize: DesignTypography.bodyMediumSize * scale,
      ),
      bodySmall: DesignTypography.bodySmall.copyWith(
        fontSize: DesignTypography.bodySmallSize * scale,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTypography.labelLargeSize * scale,
        fontWeight: DesignTypography.medium,
        height: DesignTypography.lineHeightNormal,
        color: DesignColors.textPrimary,
      ),
      labelMedium: DesignTypography.labelMedium.copyWith(
        fontSize: DesignTypography.labelMediumSize * scale,
      ),
      labelSmall: DesignTypography.labelSmall.copyWith(
        fontSize: DesignTypography.labelSmallSize * scale,
      ),
    );
  }
}
```

- [ ] **Step 2: Chạy lại test, verify PASS**

```bash
flutter test test/unit/core/constants/responsive_typography_test.dart
```

Expected output: `All tests passed!` (5 tests).

- [ ] **Step 3: Chạy `flutter analyze` để check warning**

```bash
flutter analyze lib/core/constants/design_tokens.dart
```

Expected: `No issues found!`. Nếu có warning về import thiếu — sửa.

- [ ] **Step 4: Commit task 1.2**

```bash
git add lib/core/constants/design_tokens.dart test/unit/core/constants/responsive_typography_test.dart
git commit -m "$(cat <<'EOF'
feat(typography): add ResponsiveTypography engine

Tier-based scale 1.0/1.1/1.2 theo DesignBreakpoints. Đọc base sizes
từ DesignTypography const. Không dùng .sp. Có unit test scale logic
+ widget test buildTextTheme cho mobile/desktop.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 1.3: Wire `MaterialApp.builder` inject textTheme + clamp textScaler

**Files:**
- Modify: `lib/main.dart:305-314` (builder của `MaterialApp.router`)

- [ ] **Step 1: Đọc lại `lib/main.dart:300-315` để verify pattern hiện tại**

```bash
sed -n '300,316p' lib/main.dart
```

Expected: thấy `MaterialApp.router(...)` với `builder: (context, child) { return GestureDetector(...); }`.

- [ ] **Step 2: Sửa `MaterialApp.router.builder` để bơm responsive textTheme**

Trong `lib/main.dart`, tìm khối (khoảng line 305-314):

```dart
builder: (context, child) {
  return GestureDetector(
    onTap: () {
      // Đảm bảo keyboard ẩn khi tap bất kỳ đâu
      FocusScope.of(context).unfocus();
    },
    behavior: HitTestBehavior.opaque,
    child: child,
  );
},
```

Thay bằng:

```dart
builder: (context, child) {
  // === Responsive Typography Injection ===
  // Engine pattern: bọc lại MediaQuery (clamp OS textScaler 0.9-1.3)
  // và Theme (override textTheme đã scale theo tier device).
  // Phải đặt trong MaterialApp.builder vì lúc này context đã có MediaQuery.
  final responsiveTextTheme = ResponsiveTypography.buildTextTheme(context);
  final clampedTextScaler = MediaQuery.textScalerOf(context).clamp(
    minScaleFactor: 0.9,
    maxScaleFactor: 1.3,
  );

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
    child: Theme(
      data: Theme.of(context).copyWith(textTheme: responsiveTextTheme),
      child: GestureDetector(
        onTap: () {
          // Đảm bảo keyboard ẩn khi tap bất kỳ đâu
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    ),
  );
},
```

- [ ] **Step 3: Thêm import nếu thiếu**

Đảm bảo `lib/main.dart` đã có (line 9):

```dart
import 'package:ai_mls/core/constants/design_tokens.dart';
```

Nếu chưa có, thêm vào khối import.

- [ ] **Step 4: Verify analyze**

```bash
flutter analyze lib/main.dart
```

Expected: `No issues found!`.

- [ ] **Step 5: Verify build debug (smoke test app khởi động)**

```bash
flutter build apk --debug --target-platform=android-arm64
```

Expected: build success. KHÔNG chạy app lên device.

- [ ] **Step 6: Commit task 1.3**

```bash
git add lib/main.dart
git commit -m "feat(typography): inject ResponsiveTypography vào MaterialApp.builder

Clamp OS textScaler 0.9-1.3 + override Theme.textTheme với scale động.
Đặt trong MaterialApp.builder để có MediaQuery (chicken-and-egg fix).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 1.4: Sửa `app_theme.dart` — bỏ `.sp`, giữ static textTheme tối thiểu

**Files:**
- Modify: `lib/core/theme/app_theme.dart:52-59` (block `textTheme`)

- [ ] **Step 1: Bỏ `.sp` trong textTheme static**

Trong `lib/core/theme/app_theme.dart`, tìm khối line 52-59:

```dart
textTheme: TextTheme(
  titleLarge: DesignTypography.titleLarge.copyWith(
    fontSize: DesignTypography.titleLargeSize.sp,
  ),
  bodyMedium: DesignTypography.bodyMedium.copyWith(
    fontSize: DesignTypography.bodyMediumSize.sp,
  ),
),
```

Thay bằng (static baseline — sẽ bị `MaterialApp.builder` override với responsive version):

```dart
textTheme: TextTheme(
  displayLarge: DesignTypography.displayLarge,
  displayMedium: DesignTypography.displayMedium,
  headlineLarge: DesignTypography.headlineLarge,
  headlineMedium: DesignTypography.headlineMedium,
  titleLarge: DesignTypography.titleLarge,
  titleMedium: DesignTypography.titleMedium,
  titleSmall: DesignTypography.titleSmall,
  bodyLarge: DesignTypography.bodyLarge,
  bodyMedium: DesignTypography.bodyMedium,
  bodySmall: DesignTypography.bodySmall,
  labelMedium: DesignTypography.labelMedium,
  labelSmall: DesignTypography.labelSmall,
),
```

- [ ] **Step 2: Bỏ import `flutter_screenutil` nếu không còn dùng trong file này**

Sau khi sửa, grep:

```bash
rg "\.sp|\.w|\.h|\.r" lib/core/theme/app_theme.dart
```

Nếu output rỗng → bỏ dòng import `import 'package:flutter_screenutil/flutter_screenutil.dart';` ở đầu file (line 3).

- [ ] **Step 3: Verify analyze**

```bash
flutter analyze lib/core/theme/app_theme.dart
```

Expected: `No issues found!`.

- [ ] **Step 4: Commit task 1.4**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "fix(theme): remove .sp from app_theme textTheme

Static baseline đầy đủ 12 slot. MaterialApp.builder sẽ override
với ResponsiveTypography.buildTextTheme(context) khi runtime.
Tránh double-scale (.sp × tier scale)."
```

---

### Task 1.5: Thêm sub-themes vào `app_theme.dart` (TextField, BottomNav, Tab)

**Files:**
- Modify: `lib/core/theme/app_theme.dart` (thêm trước dòng `switchTheme:` line 60)

- [ ] **Step 1: Thêm 3 sub-theme vào ThemeData**

Trong `lib/core/theme/app_theme.dart`, trước `switchTheme:` (line 60), thêm:

```dart
inputDecorationTheme: InputDecorationTheme(
  hintStyle: DesignTypography.bodyMedium.copyWith(
    color: DesignColors.textTertiary,
  ),
  labelStyle: DesignTypography.bodyMedium,
  helperStyle: DesignTypography.bodySmall,
  errorStyle: DesignTypography.bodySmall.copyWith(
    color: DesignColors.error,
  ),
),
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  selectedLabelStyle: DesignTypography.labelMedium,
  unselectedLabelStyle: DesignTypography.labelSmall,
),
tabBarTheme: TabBarThemeData(
  labelStyle: DesignTypography.titleSmall,
  unselectedLabelStyle: DesignTypography.titleSmall.copyWith(
    fontWeight: DesignTypography.regular,
  ),
),
```

**Lưu ý:** Sub-theme này dùng `DesignTypography` static làm fallback. Khi `MaterialApp.builder` override `textTheme` runtime, các widget có thể chọn ưu tiên `Theme.of(context).textTheme.X` thay vì sub-theme — đây là hành vi Flutter mặc định. Trong test, nếu BottomNav label không scale, vào Phase 2 Zone D ta sẽ chuyển sub-theme này thành dynamic (build trong `MaterialApp.builder` cùng `textTheme`).

- [ ] **Step 2: Verify analyze + build**

```bash
flutter analyze lib/core/theme/app_theme.dart
flutter build apk --debug --target-platform=android-arm64
```

Expected: cả hai pass.

- [ ] **Step 3: Commit task 1.5**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): add inputDecoration/bottomNav/tabBar sub-themes

Tham chiếu DesignTypography static cho fallback. Sẽ bị override
bởi responsive textTheme trong MaterialApp.builder."
```

---

### Task 1.6: Re-generate golden test baselines (nếu có)

**Files:**
- Tất cả golden test trong `test/` dir

- [ ] **Step 1: Tìm xem có golden test không**

```bash
rg "matchesGoldenFile" test/ --type dart -l
```

Nếu output rỗng → **bỏ qua Task 1.6**, sang Task 1.7.

- [ ] **Step 2: Nếu có golden test, re-generate baseline**

```bash
flutter test --update-goldens
```

Expected: tất cả golden test pass (re-write file ảnh).

- [ ] **Step 3: Verify diff goldens hợp lý (không nên có ảnh ngẫu nhiên)**

```bash
git status test/
git diff --stat test/
```

- [ ] **Step 4: Commit golden baselines**

```bash
git add test/
git commit -m "test(typography): regenerate golden baselines after engine wire-up"
```

---

### Task 1.7: Verify Phase 1 toàn diện

- [ ] **Step 1: Chạy full test suite**

```bash
flutter test
```

Expected: tất cả pass. Nếu fail → kiểm tra test nào, có thể là assertion `expect(textStyle.fontSize, 14)` cũ — fix thủ công theo snap rule trong spec mục 4.1.

- [ ] **Step 2: Analyze toàn dự án**

```bash
flutter analyze
```

Expected: 0 error mới. Warning hiện có (legacy) chấp nhận.

- [ ] **Step 3: Build debug**

```bash
flutter build apk --debug --target-platform=android-arm64
```

Expected: build success.

- [ ] **Step 4: Smoke test runtime (nếu có thiết bị/emulator sẵn)**

Chạy app, navigate vào Home. Verify:
- App khởi động không crash.
- Font ở dashboard hiện tại VẪN như cũ (Phase 1 KHÔNG đổi UI rõ rệt — vì 79 file vẫn dùng hardcoded fontSize, override Theme không có hiệu lực ở các file đó).

Nếu app crash → rollback các commit Phase 1 và debug trước khi sang Phase 2.

🛑 **STOP — đây là kết thúc Phase 1.** Spec yêu cầu dừng tại đây để user review trước khi migrate UI code. KHÔNG tự động sang Phase 2.

---

## Phase 2 — Migration Workflow (Template chung cho 4 zone)

> **Lưu ý:** Phase 2 sẽ thực thi sau khi user duyệt kết quả Phase 1. Mỗi zone = 1 commit độc lập, có thể `git revert` riêng. Workflow dưới đây áp dụng identical cho cả 4 zone — chỉ khác danh sách file.

### Workflow chuẩn cho mỗi file (áp dụng từng file một)

Cho mỗi file `<TARGET_FILE>` trong zone:

- [ ] **Step 1: Đọc file để hiểu context**

```bash
cat <TARGET_FILE>
```

Note các pattern `fontSize:` và weight đi kèm.

- [ ] **Step 2: Liệt kê tất cả `fontSize:` literal**

```bash
rg "fontSize:" <TARGET_FILE> -n
```

- [ ] **Step 3: Áp snap rule từ spec mục 4.1 — viết bảng conversion**

Cho mỗi match, xác định slot dựa trên (size, weight, context). Ví dụ:

```
Line 149: fontSize: 13         → bodySmall (default cho 13 lạc loài)
Line 158: fontSize: 12 white70 → bodySmall.copyWith(color: white70)
Line 190: fontSize: 26 bold    → displayMedium
Line 198: fontSize: 9          → labelSmall (promote up)
Line 332: fontSize: 18 (no weight info → check context, likely titleMedium hoặc titleLarge)
```

**Snap rule reference (copy từ spec §4.1):**
| Code cũ | Slot mới |
|---|---|
| `fontSize: 9` hoặc `10` | `labelSmall` |
| `fontSize: 11` | `labelSmall` |
| `fontSize: 12` + regular | `bodySmall` |
| `fontSize: 12` + medium/semiBold | `labelMedium` |
| `fontSize: 13` | `bodySmall` (default) |
| `fontSize: 14` + regular | `bodyMedium` |
| `fontSize: 14` + medium | `labelLarge` |
| `fontSize: 14` + semiBold/bold | `titleSmall` |
| `fontSize: 16` + regular | `bodyLarge` |
| `fontSize: 16` + semiBold/bold | `titleMedium` |
| `fontSize: 18` + semiBold | `headlineSmall` |
| `fontSize: 18` + bold | `titleLarge` |
| `fontSize: 20` | `headlineMedium` |
| `fontSize: 22` | `headlineLarge` |
| `fontSize: 24` | `displaySmall` |
| `fontSize: 26` | `displayMedium` |
| `fontSize: 28` | `displayLarge` |
| `fontSize: >28` | `displayLarge` + rà soát |

- [ ] **Step 4: Thực hiện replace bằng Edit tool**

Cho mỗi match, sửa theo 2 pattern:

**Pattern A — TextStyle thuần (chỉ có fontSize + weight):**

```dart
// ❌ TRƯỚC
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)

// ✅ SAU
style: Theme.of(context).textTheme.titleLarge
```

**Pattern B — TextStyle có color/letterSpacing/decoration khác:**

```dart
// ❌ TRƯỚC
style: TextStyle(
  fontSize: 14,
  color: Colors.white70,
  fontWeight: FontWeight.w500,
)

// ✅ SAU
style: Theme.of(context).textTheme.labelLarge?.copyWith(
  color: Colors.white70,
)
```

**Pattern C — TextStyle trong const context (StatelessWidget const):**

```dart
// ❌ TRƯỚC
const Text('Hello', style: TextStyle(fontSize: 14))

// ✅ SAU (bỏ const ở Text vì style giờ là runtime)
Text('Hello', style: Theme.of(context).textTheme.bodyMedium)
```

- [ ] **Step 5: Verify file analyze**

```bash
flutter analyze <TARGET_FILE>
```

Expected: 0 error.

- [ ] **Step 6: Verify grep guard**

```bash
rg "fontSize:" <TARGET_FILE>
```

Expected: empty (hoặc chỉ còn các dòng có comment `// typography:ignore-scale` cho output ngoài app — file UI bình thường KHÔNG có comment này).

---

### Zone A — Dashboard (6 file)

**Files target:**
1. `lib/presentation/views/dashboard/widgets/dashboard_top_bar.dart`
2. `lib/presentation/views/dashboard/student_dashboard_screen.dart`
3. `lib/presentation/views/dashboard/teacher_dashboard_screen.dart`
4. `lib/presentation/views/dashboard/home/student_home_content_screen.dart`
5. `lib/presentation/views/dashboard/home/teacher_home_content_screen.dart`
6. `lib/presentation/views/dashboard/home/widgets/teacher_home_wide_layout.dart`

- [ ] **Step Zone-A.1:** Áp workflow chuẩn cho file 1 (`dashboard_top_bar.dart`)
- [ ] **Step Zone-A.2:** Áp workflow chuẩn cho file 2 (`student_dashboard_screen.dart`)
- [ ] **Step Zone-A.3:** Áp workflow chuẩn cho file 3 (`teacher_dashboard_screen.dart`)
- [ ] **Step Zone-A.4:** Áp workflow chuẩn cho file 4 (`student_home_content_screen.dart`) — **file này đã dùng nhiều `DesignTypography.X`, chỉ replace các `fontSize: <number>` còn sót**
- [ ] **Step Zone-A.5:** Áp workflow chuẩn cho file 5 (`teacher_home_content_screen.dart`) — **file user thấy lỗi rõ nhất, làm kỹ**
- [ ] **Step Zone-A.6:** Áp workflow chuẩn cho file 6 (`teacher_home_wide_layout.dart`)
- [ ] **Step Zone-A.7: Zone-wide verify**

```bash
rg "fontSize:\s*\d" lib/presentation/views/dashboard/
flutter analyze lib/presentation/views/dashboard/
flutter test
flutter build apk --debug --target-platform=android-arm64
```

Expected: grep = empty, analyze = 0 error, test pass, build OK.

- [ ] **Step Zone-A.8: Visual regression check 3 form factor**

Chạy app trên 3 device giả lập:
1. Phone (vd Pixel 4, 393×851)
2. Tablet (vd iPad Mini, 768×1024)
3. Web/Desktop (chạy `flutter run -d chrome --web-renderer html`, resize ≥1200)

Trên mỗi form factor: vào dashboard, screenshot, so sánh với baseline (nếu có) hoặc visual inspection — font phải scale đúng tier, không có dòng nào bị quá nhỏ/tràn.

- [ ] **Step Zone-A.9: Commit Zone A**

```bash
git add lib/presentation/views/dashboard/
git commit -m "refactor(typography): migrate Zone A — Dashboard

Thay 79 hardcoded fontSize trong 6 file dashboard thành
Theme.of(context).textTheme.X theo snap rule spec §4.1.

Verified: phone/tablet/desktop visual, analyze clean, test pass.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Zone B — Assignment (~25 file)

**Files target** (sẽ rà soát lại trước khi bắt đầu vì có file mới):
```
lib/presentation/views/assignment/student/assignment_list_screen.dart
lib/presentation/views/assignment/student/student_assignment_detail_screen.dart
lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
lib/presentation/views/assignment/student/student_submission_confirm_screen.dart
lib/presentation/views/assignment/student/student_submission_history_screen.dart
lib/presentation/views/assignment/student/student_submission_review_screen.dart
lib/presentation/views/assignment/student/widgets/essay_answer_field.dart
lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
lib/presentation/views/assignment/teacher/teacher_assignment_bank_screen.dart
lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart
lib/presentation/views/assignment/teacher/teacher_assignment_selection_screen.dart
lib/presentation/views/assignment/teacher/teacher_class_submission_list_screen.dart
lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart
lib/presentation/views/assignment/teacher/teacher_distribute_assignment_screen.dart
lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart
lib/presentation/views/assignment/teacher/teacher_submission_list_screen.dart
lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_filter_sort_bar.dart
lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_selection_card.dart
lib/presentation/views/assignment/teacher/widgets/context_sources_section.dart
lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_image_picker.dart
lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_list_drawer.dart
lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_options_list.dart
lib/presentation/views/assignment/teacher/widgets/distribution/assignment_distribution_manager.dart
lib/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart
lib/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart
lib/presentation/views/assignment/teacher/widgets/staging_area_widget.dart
```

- [ ] **Step Zone-B.1:** Re-grep để verify danh sách hiện tại

```bash
rg "fontSize:\s*\d" lib/presentation/views/assignment/ -l
```

- [ ] **Step Zone-B.2 .. Zone-B.N:** Áp workflow chuẩn cho từng file (sub-task per file)

- [ ] **Step Zone-B.verify: Zone-wide verify** (giống Zone-A.7)
- [ ] **Step Zone-B.visual: Visual check** (giống Zone-A.8)
- [ ] **Step Zone-B.commit: Commit Zone B**

```bash
git add lib/presentation/views/assignment/
git commit -m "refactor(typography): migrate Zone B — Assignment ($N file)

Snap rule applied. Visual verified phone/tablet/desktop."
```

---

### Zone C — Class & Profile & Auth & Settings (~20 file)

**Files target:**
```
lib/presentation/views/class/student/student_class_list_screen.dart
lib/presentation/views/class/student/student_group_detail_screen.dart
lib/presentation/views/class/student/student_group_screen.dart
lib/presentation/views/class/teacher/create_class_screen.dart
lib/presentation/views/class/teacher/edit_class_screen.dart
lib/presentation/views/class/teacher/student_list_screen.dart
lib/presentation/views/class/teacher/teacher_assignment_detail_screen.dart
lib/presentation/views/class/teacher/teacher_class_detail_screen.dart
lib/presentation/views/class/teacher/teacher_class_list_screen.dart
lib/presentation/views/class/teacher/teacher_group_detail_screen.dart
lib/presentation/views/class/teacher/teacher_group_management_screen.dart
lib/presentation/views/class/widgets/class_primary_action_card.dart
lib/presentation/views/class/widgets/class_screen_header.dart
lib/presentation/views/profile/profile_screen.dart
lib/presentation/views/auth/login_screen.dart
lib/presentation/views/auth/register_screen.dart
lib/presentation/views/splash/splash_screen.dart
lib/presentation/views/settings/api_key_setup_screen.dart
lib/presentation/views/settings/ai_question_settings_screen.dart
lib/presentation/views/settings/settings_screen.dart
lib/presentation/views/settings/widgets/export_template_bottom_sheet.dart
lib/presentation/utils/student_class_interaction_handler.dart
```

- [ ] **Step Zone-C.1:** Re-grep verify danh sách
- [ ] **Step Zone-C.2 .. Zone-C.N:** Áp workflow chuẩn từng file
- [ ] **Step Zone-C.verify, Zone-C.visual, Zone-C.commit:** Giống Zone B

---

### Zone D — Shared Widgets + Dialog/Sheet wrapping (~25 file + R10 fix)

**Files target — UI widgets:**
```
lib/widgets/list_item/class/class_item_widget.dart
lib/widgets/list_item/assignment/class_detail_assignment_list_item.dart
lib/widgets/forms/labeled_text_field.dart
lib/widgets/forms/labeled_textarea.dart
lib/widgets/forms/select_field.dart
lib/widgets/forms/date_time_picker_field.dart
lib/widgets/dialogs/assignment_filter_bottom_sheet.dart
lib/widgets/dialogs/assignment_sort_bottom_sheet.dart
lib/widgets/dialogs/class_sort_bottom_sheet.dart
lib/widgets/rubric/interactive_rubric_grader.dart
lib/widgets/rubric/read_only_rubric_viewer.dart
lib/widgets/rubric/rubric_template_picker_sheet.dart
lib/widgets/math/math_input_toolbar.dart
lib/widgets/search/shared/search_field.dart
lib/widgets/responsive/responsive_text.dart
lib/presentation/views/grading/teacher_analytics_screen.dart
lib/presentation/views/grading/widgets/analytics/charts/line_trend_chart.dart
lib/presentation/views/grading/widgets/analytics/teacher/cards/class_overview_card.dart
lib/presentation/views/grading/widgets/analytics/teacher/charts/grade_distribution_heatmap.dart
lib/presentation/views/recommendation/widgets/dual_radar_chart.dart
```

**File EDGE CASE — không migrate, chỉ thêm comment:**
- `lib/core/utils/excel_template_generator.dart` — thêm header comment `// typography:ignore-scale` ngay đầu file
- `lib/core/utils/avatar_utils.dart` — **kiểm tra**: nếu là render avatar bitmap (canvas/painter), giữ literal + comment. Nếu là Text widget → migrate bình thường.

- [ ] **Step Zone-D.1:** Re-grep verify danh sách
- [ ] **Step Zone-D.2 .. Zone-D.N:** Áp workflow chuẩn từng file widget
- [ ] **Step Zone-D.excel:** Thêm comment `// typography:ignore-scale` vào `excel_template_generator.dart`:

```bash
# Mở file, thêm dòng comment ở line 1 (trước import đầu tiên):
# // typography:ignore-scale — Excel point sizes, không scale theo screen
```

- [ ] **Step Zone-D.avatar:** Inspect `avatar_utils.dart` để quyết định migrate hay ignore-scale.
- [ ] **Step Zone-D.R3:** Fix `DefaultTextStyle` propagation (3 file)

Đã phát hiện 3 file dùng `DefaultTextStyle`:
```
lib/presentation/views/dashboard/student_dashboard_screen.dart
lib/presentation/views/dashboard/teacher_dashboard_screen.dart
lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_selection_card.dart
```

Cho mỗi file, tìm pattern:

```dart
DefaultTextStyle(
  style: TextStyle(fontSize: ..., color: ...),
  child: ...,
)
```

Đổi thành:

```dart
DefaultTextStyle.merge(
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: ..., // giữ color cũ
  ),
  child: ...,
)
```

`.merge()` thay vì replace `DefaultTextStyle()` constructor — để inherit từ Theme thay vì chặn.

- [ ] **Step Zone-D.R10:** Audit `showDialog` / `showModalBottomSheet` (44 call site)

```bash
rg "showDialog\(|showModalBottomSheet\(" lib --type dart -n > /tmp/dialog_sites.txt
```

Cho mỗi call site, kiểm tra builder có gọi `Theme.of(context)` hoặc `MediaQuery.of(context)` không. **Nếu dialog nội dung dùng text bình thường (Text widget với style từ Theme)** → KHÔNG cần wrap (Flutter auto-propagate qua `Navigator.context`).

**CHỈ wrap khi:** dialog/sheet phát hiện chữ phình to bất thường trên thiết bị có OS textScaler ≥ 1.3 (visual check ở Zone-D.visual).

Pattern wrap:

```dart
showDialog(
  context: context,
  builder: (dialogContext) => MediaQuery(
    data: MediaQuery.of(context), // mượn caller context (đã clamp)
    child: Theme(
      data: Theme.of(context),
      child: AlertDialog(...),
    ),
  ),
)
```

- [ ] **Step Zone-D.charts:** Mapping injection cho chart third-party (R2/R11)

3 file dùng `fl_chart` cần xử lý đặc biệt vì widget thư viện KHÔNG inherit Theme:
- `lib/presentation/views/recommendation/widgets/dual_radar_chart.dart`
- `lib/presentation/views/grading/widgets/analytics/charts/line_trend_chart.dart`
- `lib/presentation/views/grading/widgets/analytics/teacher/charts/grade_distribution_heatmap.dart`

Pattern thay đổi (KHÔNG dùng workflow chuẩn):

```dart
// ❌ TRƯỚC
SideTitles(
  getTitlesWidget: (value, meta) => Text(
    '$value',
    style: const TextStyle(fontSize: 11),
  ),
)

// ✅ SAU — explicit map textTheme value vào prop của thư viện
SideTitles(
  getTitlesWidget: (value, meta) => Text(
    '$value',
    style: Theme.of(context).textTheme.labelSmall, // inherit fail-safe
  ),
)
```

Nếu thư viện expose prop `textStyle` trực tiếp (vd `axisTitleStyle`, `tooltipTextStyle`), truyền vào prop đó thay vì wrap Text widget. Mục đích: thư viện sẽ KHÔNG fallback về font đen Roboto 14 mặc định.

Lưu ý file `lib/widgets/responsive/responsive_text.dart` — đọc trước, nếu là wrapper tự định nghĩa scale logic → có thể XÓA luôn (engine mới làm việc này global), hoặc giữ nhưng đổi nội dung thành `Text(text, style: Theme.of(context).textTheme.X)`. Hỏi user nếu file có >50 dòng logic.

- [ ] **Step Zone-D.R9:** Audit `RichText` / `Text.rich` (13 file)

```bash
rg "Text\.rich|RichText\(" lib --type dart -l
```

Cho mỗi file, tìm pattern:

```dart
Text.rich(
  TextSpan(
    children: [TextSpan(text: '...')],
  ),
)
```

Thêm root style explicit:

```dart
Text.rich(
  TextSpan(
    style: Theme.of(context).textTheme.bodyMedium, // ROOT STYLE
    children: [TextSpan(text: '...')],
  ),
)
```

- [ ] **Step Zone-D.verify:** Zone-wide verify (giống Zone-A.7)
- [ ] **Step Zone-D.visual:** Visual check 3 form factor + **đặc biệt test dialog/bottomsheet với OS textScaler tăng (Settings → Display → Font size → Largest)**
- [ ] **Step Zone-D.commit:** Commit Zone D

```bash
git add lib/widgets/ lib/core/utils/excel_template_generator.dart lib/core/utils/avatar_utils.dart lib/presentation/views/grading/ lib/presentation/views/recommendation/widgets/
git commit -m "refactor(typography): migrate Zone D — Shared Widgets + edge cases

- Migrate widget/forms/dialogs/rubric/math/search ($N file)
- Fix DefaultTextStyle.merge() (R3, 3 file)
- Audit + wrap dialogs có textScaler issue (R10)
- Explicit root TextSpan style cho RichText (R9, 13 file)
- Mark excel_template_generator typography:ignore-scale (R1)"
```

---

### Phase 2 Exit Criteria

- [ ] **Step Phase2.guard:** Grep toàn dự án phải empty (trừ file có `typography:ignore-scale`)

```bash
rg "fontSize:\s*\d" lib --type dart | rg -v "typography:ignore-scale"
```

Expected: empty output.

- [ ] **Step Phase2.test:** Full test suite pass

```bash
flutter test
```

- [ ] **Step Phase2.build:** Build cả 2 platform

```bash
flutter build apk --debug
flutter build web
```

🛑 **STOP — đây là kết thúc Phase 2.** Bàn giao cho user smoke test trên thiết bị thật trước khi sang Phase 3.

---

## Phase 3 — Guard (chống tái phát)

### Task 3.1: Thêm CI lint script chặn hardcoded fontSize

**Files:**
- Create: `scripts/lint_typography.sh` (cross-platform bash, chạy được trên Windows Git Bash + CI Linux)

- [ ] **Step 1: Tạo script**

```bash
#!/usr/bin/env bash
# scripts/lint_typography.sh
# Fail CI nếu có fontSize literal trong lib/ (trừ file có typography:ignore-scale)

set -euo pipefail

VIOLATIONS=$(grep -rn "fontSize:\s*[0-9]" lib --include="*.dart" \
  | grep -v "typography:ignore-scale" || true)

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Hardcoded fontSize detected:"
  echo "$VIOLATIONS"
  echo ""
  echo "Use Theme.of(context).textTheme.X instead."
  echo "If genuinely necessary (Excel/PDF export), add '// typography:ignore-scale' to file."
  exit 1
fi

echo "✅ No hardcoded fontSize violations."
```

- [ ] **Step 2: Make executable + test local**

```bash
chmod +x scripts/lint_typography.sh
./scripts/lint_typography.sh
```

Expected: `✅ No hardcoded fontSize violations.` (vì Phase 2 đã dọn).

- [ ] **Step 3: Wire vào CI nếu có (`.github/workflows/`)**

Kiểm tra:

```bash
ls .github/workflows/ 2>/dev/null
```

Nếu có file YAML, thêm step vào job lint:

```yaml
- name: Typography lint
  run: bash scripts/lint_typography.sh
```

Nếu không có CI workflow — bỏ qua, chỉ giữ script local.

- [ ] **Step 4: Commit task 3.1**

```bash
git add scripts/lint_typography.sh
git add .github/workflows/ 2>/dev/null
git commit -m "ci(typography): add lint guard chặn hardcoded fontSize"
```

---

### Task 3.2: Update `.claude/CLAUDE.md` §9 UI & Design System

**Files:**
- Modify: `.claude/CLAUDE.md`

- [ ] **Step 1: Tìm section §9 hiện tại**

```bash
rg "## 9\.|UI & Design System" .claude/CLAUDE.md -n
```

- [ ] **Step 2: Thay khối "Typography" trong bảng Design Tokens**

Hiện tại trong §9 có dòng:
```
| Typography | `DesignTypography.*` | `TextStyle(fontSize:14)` raw |
```

Thay bằng:
```
| Typography | `Theme.of(context).textTheme.X` | `TextStyle(fontSize:14)`, `DesignTypography.X` static (trừ context-less) |
```

- [ ] **Step 3: Thêm sub-section "Typography Rules" ngay sau bảng**

```markdown
### Typography Rules (BẮT BUỘC)

1. **UI có context:** dùng `Theme.of(context).textTheme.titleMedium` (15 slot Material 3).
2. **Override color/weight:** dùng `.copyWith()`:
   ```dart
   Theme.of(context).textTheme.titleMedium?.copyWith(color: DesignColors.primary)
   ```
3. **Context-less code** (service, isolate, global toast): dùng `DesignTypography.bodyMedium` static (mobile baseline, không scale).
4. **RichText / Text.rich:** BẮT BUỘC truyền root style:
   ```dart
   Text.rich(TextSpan(style: Theme.of(context).textTheme.bodyMedium, children: [...]))
   ```
5. **Excel/PDF export:** giữ `fontSize: <số>` + thêm comment `// typography:ignore-scale` ở đầu file.
6. **CẤM:** `fontSize: <number>` literal trong UI code. CI sẽ fail.

Tham chiếu spec: `docs/superpowers/specs/2026-05-15-responsive-typography-design.md`.
```

- [ ] **Step 4: Commit task 3.2**

```bash
git add .claude/CLAUDE.md
git commit -m "docs(claude): update §9 typography rules — use Theme.textTheme"
```

---

### Task 3.3: Thêm dartdoc cảnh báo vào `DesignTypography` static TextStyle

**Files:**
- Modify: `lib/core/constants/design_tokens.dart:293-382` (các `static TextStyle ...`)

- [ ] **Step 1: Thêm dartdoc class-level cho `DesignTypography`**

Trong `lib/core/constants/design_tokens.dart`, trên dòng `class DesignTypography {` (line 239), thêm:

```dart
/// Static typography tokens — mobile baseline (KHÔNG scale theo device).
///
/// **Khi nào dùng `DesignTypography.bodyMedium` (static TextStyle)?**
/// CHỈ khi không có `BuildContext`:
/// - Service layer, background isolate, global toast/notification.
/// - Code chạy trước khi `MaterialApp` khởi tạo (vd Sentry boot UI).
///
/// **UI thông thường (có BuildContext):** dùng `Theme.of(context).textTheme.X`
/// để hưởng responsive scale (mobile 1.0× / tablet 1.1× / desktop 1.2×).
///
/// Xem spec: `docs/superpowers/specs/2026-05-15-responsive-typography-design.md`.
```

- [ ] **Step 2: Verify analyze (dartdoc warnings)**

```bash
flutter analyze lib/core/constants/design_tokens.dart
```

Expected: 0 error.

- [ ] **Step 3: Commit task 3.3**

```bash
git add lib/core/constants/design_tokens.dart
git commit -m "docs(typography): add dartdoc hướng dẫn DesignTypography static usage"
```

---

### Task 3.4: Phase 3 final verify

- [ ] **Step 1: Run full lint + test + build**

```bash
bash scripts/lint_typography.sh
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

Expected: tất cả pass.

- [ ] **Step 2: Final review commit log**

```bash
git log --oneline 1ed9819..HEAD
```

Expected log:
- `feat(typography): add ResponsiveTypography engine`
- `feat(typography): inject ResponsiveTypography vào MaterialApp.builder`
- `fix(theme): remove .sp from app_theme textTheme`
- `feat(theme): add inputDecoration/bottomNav/tabBar sub-themes`
- `test(typography): regenerate golden baselines after engine wire-up` (nếu có golden)
- `refactor(typography): migrate Zone A — Dashboard`
- `refactor(typography): migrate Zone B — Assignment`
- `refactor(typography): migrate Zone C — Class & Profile`
- `refactor(typography): migrate Zone D — Shared Widgets + edge cases`
- `ci(typography): add lint guard`
- `docs(claude): update §9 typography rules`
- `docs(typography): add dartdoc DesignTypography static usage`

🛑 **PHASE 3 COMPLETE.**

---

## Rollback Procedures

### Rollback Phase 1 only (engine bị lỗi)
```bash
git revert <Task 1.5 commit hash>
git revert <Task 1.4 commit hash>
git revert <Task 1.3 commit hash>
git revert <Task 1.2 commit hash>
```

### Rollback một zone (vd Zone B bị vỡ visual)
```bash
git revert <Zone B commit hash>
```
Các zone khác không bị ảnh hưởng (mỗi zone độc lập).

### Rollback toàn bộ (worst case)
```bash
git revert 1ed9819..HEAD  # revert mọi commit kể từ spec
```

---

## Acceptance Checklist (Definition of Done)

- [ ] Phase 1: `ResponsiveTypography` class tạo, unit test pass, `MaterialApp.builder` wire xong, app build OK.
- [ ] Phase 2 Zone A-D: 79 file migrate xong, `rg "fontSize:\s*\d" lib` empty (trừ ignore-scale).
- [ ] Phase 2: Visual check 3 form factor (phone/tablet/desktop) — font hierarchy giữ nguyên, không vỡ layout.
- [ ] Phase 2: Dialog/Sheet test với OS textScaler 1.5× — không phình.
- [ ] Phase 2: RichText 13 file có root style explicit.
- [ ] Phase 3: Lint guard script chạy được, CI integrated (nếu có CI).
- [ ] Phase 3: `.claude/CLAUDE.md` §9 cập nhật.
- [ ] Phase 3: Dartdoc DesignTypography static có cảnh báo.
- [ ] `flutter analyze` 0 error, `flutter test` pass, `flutter build apk --debug` + `flutter build web` OK.
- [ ] User smoke test trên thiết bị thật (phone Android + iPad + browser desktop) — approve.

---

## Notes for the Executing Engineer

1. **DRY:** Workflow chuẩn (Phase 2 đầu) áp dụng identical cho mọi file. Không tạo abstraction mới.
2. **YAGNI:** Không tự thêm helper, không tạo `context.text.X` extension trừ khi user yêu cầu (xem Open Question §8 trong spec).
3. **TDD ở Phase 1:** Task 1.1 viết test trước Task 1.2 viết engine. Phase 2 không TDD (refactor pure, visual check thay test).
4. **Frequent commits:** mỗi task = 1 commit. Mỗi zone = 1 commit gộp các file cùng zone (KHÔNG commit per file trong Phase 2).
5. **Khi gặp file lạ:** nếu file có pattern bất thường (vd `TextStyle(fontFamily: 'CustomFont', fontSize: 14)`) — KHÔNG đoán, hỏi user. Snap rule chỉ cover size + weight.
6. **Khi gặp `flutter_quill` content style:** SKIP — đây là content do user nhập, không phải UI chrome.
7. **Performance:** `Theme.of(context)` rebuild khi MediaQuery đổi. Trên web resize liên tục — chấp nhận rebuild, Flutter đã optimize.

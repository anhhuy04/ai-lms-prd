# Responsive Typography System — Design Spec

**Date:** 2026-05-15
**Status:** Draft → Pending user review
**Author:** Anh Huy (huynosuke@gmail.com) + Claude (brainstorming session)
**Topic:** Đồng bộ font chữ toàn app, scale theo device tier, dọn tech debt hardcoded `fontSize`.

---

## 1. Bối cảnh & Vấn đề

### 1.1 Triệu chứng

User báo font chữ trong app **loạn xạ giữa phone và web**: nhiều màn hình chữ trông sai cỡ (quá nhỏ trên web, hoặc tràn trên phone), không nhất quán giữa các màn của cùng vai trò (teacher) và giữa các vai trò (teacher vs student).

### 1.2 Quét toàn `lib/` — số liệu thực

| Pattern | Số file | Đánh giá |
|---|---|---|
| Hardcoded `fontSize: <số>` | 78 | ❌ Sai — số tùy tiện (9, 10, 13...) ngoài typography scale |
| `TextStyle(...)` inline tự chế | 75 | ❌ Không nhất quán |
| `Theme.of(context).textTheme` | 8 | ⚠️ Chuẩn Flutter nhưng cô đơn |
| `DesignTypography.X` (token đã có) | ~10 | ✅ Đúng pattern nhưng cực ít file dùng |
| `ScreenUtil .sp` (responsive) | 8 | ⚠️ Không phổ biến — lý do font không scale phone↔web |

### 1.3 Root cause

Hệ thống có **`DesignTypography` static const** (displayLarge…labelSmall, scale 11→28dp) trong `lib/core/constants/design_tokens.dart`, **nhưng không được dùng**. Mỗi developer tự chọn cách riêng → 4 trường phái song song trong cùng codebase.

Hệ quả:
- Trên cùng dashboard, `teacher_home_content_screen.dart` dùng `fontSize: 14, 18, 20` hardcoded, còn `student_home_content_screen.dart` dùng `DesignTypography.bodyLargeSize, headlineMediumSize`. Hai phong cách font.
- Các giá trị "lạc loài" `fontSize: 9, 10, 13` không nằm trong scale Material → font trông lệch.
- Tất cả số đều **static** — không scale theo screen → web 1920px hiển thị chữ 14px nhỏ tí, iPad 768px hiển thị 28px tràn card.

### 1.4 Mục tiêu

1. Một entry point duy nhất cho mọi text style trong app.
2. Tự động scale theo 3 tier device (mobile / tablet / desktop).
3. Tôn trọng accessibility OS textScaler (clamp 0.9 – 1.3 để không vỡ layout).
4. Migrate sạch 78+ file hardcoded.
5. Chống tái phát (lint guard).

---

## 2. Kiến trúc

### 2.1 3-tầng (Decoupling theo Clean Architecture)

```
┌─────────────────────────────────────────────────────────┐
│  TẦNG UI (Presentation)                                 │
│  Text('Hello', style: Theme.of(context)                 │
│                          .textTheme.titleMedium)        │
│  → Code sạch, chuẩn Flutter, KHÔNG biết về device       │
└────────────────────────────┬────────────────────────────┘
                             │ inject
                             ▼
┌─────────────────────────────────────────────────────────┐
│  TẦNG CONFIG (app_theme.dart + main.dart)               │
│  MaterialApp.builder bọc lại TextTheme với scale động   │
│  → Bơm scale factor vào TextTheme chuẩn Flutter         │
└────────────────────────────┬────────────────────────────┘
                             │ uses
                             ▼
┌─────────────────────────────────────────────────────────┐
│  TẦNG CORE (design_tokens.dart)                         │
│  class ResponsiveTypography:                            │
│    - đọc base sizes từ DesignTypography const           │
│    - tính scale theo DesignBreakpoints                  │
│    - buildTextTheme(context) → TextTheme                │
│  → Engine tính toán, KHÔNG dùng .sp                     │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Tại sao KHÔNG dùng ScreenUtil .sp

`.sp` scale tuyến tính theo `designSize.width`. Phone 400px → Web 1920px = ×4.8. Chữ 28px trở thành 134px (cái chén ăn cơm). Tier-based scale tránh hoàn toàn rủi ro này: desktop chỉ scale ×1.2.

### 2.3 MaterialApp.builder pattern (chống chicken-and-egg)

Không thể tính `ResponsiveTypography` trong `main()` vì `MediaQuery` chưa tồn tại trước khi `MaterialApp` render lần đầu. Phải dùng `MaterialApp.builder` — chặn trên route gốc, lúc đó `context` đã có MediaQuery:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) {
    final responsiveTextTheme = ResponsiveTypography.buildTextTheme(context);
    final osTextScaler = MediaQuery.textScalerOf(context);
    final clampedTextScaler = osTextScaler.clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.3,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Theme(
        data: Theme.of(context).copyWith(textTheme: responsiveTextTheme),
        child: child!,
      ),
    );
  },
  home: const HomeScreen(),
)
```

### 2.4 Tách bạch trách nhiệm

`ResponsiveTypography` **chỉ scale `fontSize`**. Color, weight, letterSpacing, height giữ nguyên từ `DesignTypography`. Single Responsibility Principle.

---

## 3. Scale Matrix & TextTheme Mapping

### 3.1 Mapping 1-1 với Material 3 TextTheme

Base sizes (mobile baseline) — giữ nguyên từ `DesignTypography` hiện tại:

| Flutter slot | Size (mobile) | Weight | Use case |
|---|---|---|---|
| `displayLarge` | 28 | bold | Hero numbers, splash heading |
| `displayMedium` | 26 | bold | Onboarding title |
| `displaySmall` | 24 | bold | Large stat numbers |
| `headlineLarge` | 22 | bold | Page title hero |
| `headlineMedium` | 20 | semiBold | Screen header |
| `headlineSmall` | 18 | semiBold | Card section header |
| `titleLarge` | 18 | bold | Dialog title, card title |
| `titleMedium` | 16 | semiBold | List item title |
| `titleSmall` | 14 | semiBold | Subtitle, tab label |
| `bodyLarge` | 16 | regular | Long-form content |
| `bodyMedium` | 14 | regular | Default text fallback |
| `bodySmall` | 12 | regular | Helper text, timestamps |
| `labelLarge` | 14 | medium | Button text |
| `labelMedium` | 12 | medium | Chip, badge text |
| `labelSmall` | 11 | medium | Caption, micro-label |

### 3.2 Scale factor theo Breakpoint — Uniform 1.0 / 1.1 / 1.2

Dùng đúng `DesignBreakpoints` đã có:

| Tier | Width range | Scale | `bodyMedium` | `displayLarge` |
|---|---|---|---|---|
| Mobile | < 600 | 1.00× | 14.0 | 28.0 |
| Tablet | 600 – 1199 | 1.10× | 15.4 | 30.8 |
| Desktop | ≥ 1200 | 1.20× | 16.8 | 33.6 |

**Decision rationale (chốt qua thảo luận):**

1. **Uniform scale duy trì hierarchy.** Nếu chia 2 hệ số (display 1.1, body 1.2), `titleLarge` (18×1.2=21.6) sẽ vượt `headlineSmall` (18×1.1=19.8) → đảo ngược semantic của Material 3.
2. **bodyMedium 16.8px là con số sinh tử cho Web Reading Readability.** Tiêu chuẩn web body text ≥ 16-18px. Bóp về 15.8 (scale 1.13) hy sinh trải nghiệm đọc văn bản dài.
3. **displayLarge 33.6px trên Web 4K là chuẩn mực (~2.1rem CSS).** "Ballooning" là di chứng của `.sp`, không phải tier-scale.
4. **KHÔNG cap riêng cho display.** Đơn giản hóa hệ thống. Nếu sau này design team thêm slot 40+, mới tính chuyện clamp.

### 3.3 Accessibility — OS textScaler clamp

Người dùng tăng cỡ chữ trong OS settings (vd 1.5× cho mắt kém). Nếu cộng dồn với tier scale 1.2× → 1.8× → vỡ layout.

**Clamp 0.9 – 1.3** trong `MaterialApp.builder`:
- Tôn trọng accessibility (vẫn cho phép +30%).
- Bảo vệ layout (chặn ×1.5+ vô tội vạ).

Code mẫu xem mục 2.3.

---

## 4. Migration Strategy

### 4.1 Snap rules — chuyển hardcoded `fontSize` về slot

| Phát hiện trong code cũ | → TextTheme slot |
|---|---|
| `fontSize: 9` hoặc `10` | `labelSmall` (promote up) |
| `fontSize: 11` | `labelSmall` |
| `fontSize: 12` + `regular` | `bodySmall` |
| `fontSize: 12` + `medium`/`semiBold` | `labelMedium` |
| `fontSize: 13` | `bodySmall` (default), hoặc `labelSmall` theo context |
| `fontSize: 14` + `regular` | `bodyMedium` (default fallback) |
| `fontSize: 14` + `medium` | `labelLarge` |
| `fontSize: 14` + `semiBold`/`bold` | `titleSmall` |
| `fontSize: 16` + `regular` | `bodyLarge` |
| `fontSize: 16` + `semiBold`/`bold` | `titleMedium` |
| `fontSize: 18` + `semiBold` | `headlineSmall` |
| `fontSize: 18` + `bold` | `titleLarge` |
| `fontSize: 20` | `headlineMedium` |
| `fontSize: 22` | `headlineLarge` |
| `fontSize: 24` | `displaySmall` |
| `fontSize: 26` | `displayMedium` |
| `fontSize: 28` | `displayLarge` |
| `fontSize > 28` | `displayLarge` + rà soát thủ công (có thể là hero special) |

### 4.2 Override style: dùng `.copyWith()`

```dart
// Cần custom color/weight cho 1 chỗ
Theme.of(context).textTheme.titleMedium?.copyWith(
  color: DesignColors.primary,
  fontWeight: DesignTypography.bold,
)
```

### 4.3 Phasing — 3 giai đoạn

```
Phase 1 — ENGINE (an toàn nhất, không break gì)
   ├─ Tạo class ResponsiveTypography trong design_tokens.dart
   ├─ Wire vào MaterialApp.builder (clamp + Theme override)
   ├─ Update app_theme.dart sub-themes: inputDecorationTheme,
   │  bottomNavigationBarTheme, tabBarTheme dùng textTheme.X
   ├─ Re-generate golden test baselines
   └─ Verify: flutter analyze, flutter test, flutter build apk --debug

Phase 2 — MIGRATION (4 zone, mỗi zone 1 commit/PR độc lập)
   ├─ Zone A: Dashboard (~5 file)
   │           teacher/student home content, top bar, dashboard screens
   ├─ Zone B: Assignment (~12 file)
   │           teacher hub, student workspace, submission screens
   ├─ Zone C: Class & Profile (~15 file)
   │           class list/detail, profile, group screens
   └─ Zone D: Shared widgets (~25 file)
              cards, buttons, drawers, dialogs, list_items
   ⇒ Sau mỗi zone: visual regression check trên 3 form factor

Phase 3 — GUARD (chống tái phát)
   ├─ Thêm lint rule trong analysis_options.yaml
   ├─ Update CLAUDE.md §9 UI & Design System
   └─ Deprecate (KHÔNG xóa) static TextStyle cũ trong DesignTypography
```

### 4.4 Số phận của `DesignTypography` cũ

- **Giữ** các `static const double bodyMediumSize = 14.0` etc. — `ResponsiveTypography` đọc làm source of truth cho base size.
- **Giữ** các `static TextStyle bodyMedium = TextStyle(...)` hiện có làm **mobile baseline fallback cho context-less code** (vd: service layer, background isolate, global toast). Thêm dartdoc `/// Use ONLY when BuildContext is unavailable. Prefer Theme.of(context).textTheme.bodyMedium.`
- KHÔNG dùng `@Deprecated` annotation (sẽ spam warning cho code context-less hợp lệ). Thay vào đó, lint rule Phase 3 chỉ flag khi gọi `DesignTypography.bodyMedium` trong file có BuildContext khả dụng.

### 4.5 Verification per zone — bắt buộc

1. `flutter analyze` — 0 error mới.
2. `flutter test` — pass.
3. `flutter build apk --debug` — OK.
4. Visual check 3 form factor: phone (≤600), tablet (~768), web (≥1200).
5. Grep guard: `rg "fontSize:\s*\d" lib/<zone>/` = 0 trong zone đã migrate.

### 4.6 Rollback

Mỗi zone = 1 commit độc lập → `git revert <zone-commit>` lập tức. Engine ở Phase 1 không revert nếu chỉ zone bị lỗi.

---

## 5. Risk Register & Edge Cases

### 5.1 Output ra ngoài app: KHÔNG scale

| File / Use case | Verdict | Lý do |
|---|---|---|
| `lib/core/utils/excel_template_generator.dart` (5 `fontSize` literal) | GIỮ literal | Excel point, không phải logical pixel |
| PDF export tương lai | GIỮ literal | Đo bằng point in giấy |
| Email/notification HTML template | GIỮ literal | Render bên client user |

**Action:** thêm comment `// typography:ignore-scale` để Phase 3 lint bỏ qua.

### 5.2 Third-party widget không inherit Theme

| Widget | Hành động |
|---|---|
| `fl_chart` (axis, tooltip text) | Truyền `Theme.of(context).textTheme.labelSmall` qua prop (mapping injection) |
| `pretty_qr_code` overlay | Migrate như UI thường |
| `mobile_scanner` overlay | Check, migrate nếu có |
| `flutter_quill` editor | KHÔNG migrate (content do user, không phải UI chrome) |
| `flutter_math_fork` | Mapping injection nếu có expose style prop |
| `flutter_markdown` | Truyền `MarkdownStyleSheet.fromTheme(Theme.of(context))` |

### 5.3 DefaultTextStyle propagation — tử huyệt tiềm năng

Nếu code chỗ nào dùng `DefaultTextStyle(style: TextStyle(fontSize: ...), child: ...)` → chặn inheritance từ Theme. Grep `rg "DefaultTextStyle\(" lib --type dart`, sửa thành `DefaultTextStyle.merge(...)`.

### 5.4 Component sub-theme cần inject riêng (Phase 1)

| Component | Cần update trong `app_theme.dart`? |
|---|---|
| `AppBar.title` (`titleLarge`) | Auto, không cần |
| `AlertDialog.title` (`headlineSmall`) / `.content` (`bodyMedium`) | Auto |
| `SnackBar.content` (`bodyMedium`) | Auto |
| `ElevatedButton` (`labelLarge`) | Auto Material 3 |
| `Chip` (`labelLarge`) | Auto |
| `TextField` hint/label | **Cần update** `inputDecorationTheme` |
| `BottomNavigationBar` label | **Cần update** `bottomNavigationBarTheme.selectedLabelStyle` |
| `Tab` label | **Cần update** `tabBarTheme.labelStyle` |

### 5.5 Tử huyệt 1 — Context-less Void (User raised)

Code chạy ngoài widget tree (background isolate, global toast, service ở tầng Data/Domain) không có `BuildContext`. KHÔNG được truyền context xuống tầng dưới (memory leak: giữ widget tree không cho GC).

**Action:** giữ `DesignTypography.bodyMediumStatic` etc. (TextStyle static) như **mobile baseline fallback** (×1.0, không scale). Dùng cho:
- Global notification toasts gọi từ service layer
- Background isolate processing
- Error UI render trước khi MaterialApp khởi tạo

```dart
// DesignTypography.bodyMedium = static TextStyle (mobile baseline, không scale)
GlobalToast.show('Tải xong', style: DesignTypography.bodyMedium);
```

### 5.6 Tử huyệt 2 — RichText / TextSpan inheritance trap (User raised)

`RichText` và `Text.rich()` **không** auto-inherit từ Theme. TextSpan con fallback về Roboto 14px đen.

**Action:** BẮT BUỘC truyền explicit cho root TextSpan:

```dart
Text.rich(
  TextSpan(
    style: Theme.of(context).textTheme.bodyMedium, // root style
    children: [
      const TextSpan(text: 'Chấp nhận '),
      TextSpan(
        text: 'Điều khoản',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: DesignColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    ],
  ),
)
```

### 5.7 Tử huyệt 3 — Dialog/Overlay broken portal (User raised)

`showDialog`, `showModalBottomSheet`, `OverlayEntry` tạo route mới với context riêng. Đôi khi rớt `MediaQuery.textScaler` clamp đã set ở `MaterialApp.builder` → popup phình to bất thường theo OS scale.

**Action:** nếu dialog/sheet render text quan trọng, bọc nội dung lại:

```dart
showDialog(
  context: context,
  builder: (dialogContext) {
    return MediaQuery(
      data: MediaQuery.of(context), // mượn lại từ context gốc
      child: Theme(
        data: Theme.of(context),
        child: AlertDialog(
          title: Text(
            'Xác nhận',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Bạn có chắc?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  },
)
```

**Verify** Phase 2 Zone D: rà soát toàn bộ `showDialog` / `showModalBottomSheet` trong `lib/widgets/dialogs/`.

### 5.8 Tử huyệt 4 — Stubborn Guests (third-party libraries)

Tóm tắt mục 5.2 — không can thiệp source thư viện. Map giá trị động vào config tĩnh của chúng (mapping injection). Vd:

```dart
SfRadialGauge(
  axes: [
    RadialAxis(
      axisLabelStyle: GaugeTextStyle(
        fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
        color: Theme.of(context).textTheme.labelSmall!.color,
      ),
    ),
  ],
)
```

### 5.9 Tests

| Risk | Action |
|---|---|
| Golden test baseline ảnh sẽ vỡ | Re-generate `flutter test --update-goldens` trong commit Phase 1 |
| `expect(textStyle.fontSize, 14)` assertions | Grep `rg "fontSize, \d" test/` → fix thủ công |
| `find.text(...)` | An toàn — chỉ match nội dung |

### 5.10 Web-specific edge cases

| Case | Verdict |
|---|---|
| Window resize qua breakpoint | `MaterialApp.builder` rebuild → text tự scale ✅ |
| Browser zoom Ctrl + / − | OS-level, không đụng `textScaler` ✅ |
| Browser user font size setting | Vào `textScaler` → đã clamp 0.9–1.3 ✅ |
| `SelectableText` highlight copy | Cùng style như `Text` ✅ |

### 5.11 Locale Việt — dấu phụ

Dấu ô/ơ/ă/ư cắt nếu `fontSize ≤ 11` ở weight bold. `labelSmall = 11` đã chọn weight `medium` (không bold). Sau scale desktop 1.2× = 13.2px → an toàn. Line-height 1.25/1.4/1.5 có dư địa.

### 5.12 Bảng tổng kết Risk

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| R1 | Excel/PDF export bị scale | 🔴 | `typography:ignore-scale` comment + skip lint rule |
| R2 | Charts third-party không inherit theme | 🟡 | Mapping injection qua prop |
| R3 | `DefaultTextStyle` chặn inheritance | 🟡 | Grep + `.merge()` |
| R4 | Sub-theme chưa wire (TabBar, BottomNav, InputDecoration) | 🟡 | Update `app_theme.dart` Phase 1 |
| R5 | Golden test vỡ baseline | 🔴 | Re-generate goldens trong commit Phase 1 |
| R6 | Font lệch khi window resize giữa breakpoint | 🟢 | `MaterialApp.builder` rebuild — handled |
| R7 | OS textScaler nhân đôi với tier scale | 🔴 | Clamp 0.9–1.3 — handled |
| R8 | Context-less code (service/isolate/toast global) | 🟡 | `DesignTypography.bodyMediumStatic` fallback mobile baseline |
| R9 | RichText/TextSpan không inherit theme | 🔴 | Truyền root style explicit |
| R10 | Dialog/Overlay rớt textScaler clamp (user marked "tử huyệt") | 🔴 | Bọc lại `MediaQuery` + `Theme` từ caller context. Rà soát toàn `lib/widgets/dialogs/` ở Zone D |
| R11 | Third-party widget bỏ qua theme | 🟡 | Mapping injection (fl_chart, flutter_math_fork, flutter_markdown) |

---

## 6. Success Criteria

1. ✅ Tạo `ResponsiveTypography` class wire vào `MaterialApp.builder` với clamp 0.9–1.3.
2. ✅ Sub-themes (TabBar, BottomNav, InputDecoration) dùng `textTheme.X`.
3. ✅ Migrate hoàn tất 4 zone (Dashboard, Assignment, Class&Profile, Shared widgets).
4. ✅ `rg "fontSize:\s*\d" lib --type dart` = 0 (trừ file có `typography:ignore-scale`).
5. ✅ `flutter analyze` 0 error, `flutter test` pass.
6. ✅ Visual check 3 form factor (phone, tablet, web) — font hierarchy giữ nguyên, không vỡ layout.
7. ✅ Golden test baseline re-generated, committed.
8. ✅ Lint rule chống tái phát.
9. ✅ CLAUDE.md §9 updated.

---

## 7. Out of Scope

- Color tokens cleanup (đã có `DesignColors`, ổn định).
- Spacing tokens cleanup (đã có `ResponsiveSpacing`, ổn định).
- Custom font family loading (giữ font hệ thống/Roboto hiện tại).
- Dark mode typography (sẽ làm sau, color override không đụng font).
- i18n font-per-locale (giả định mọi locale dùng cùng family).
- Icon sizing (`DesignIcons` ổn định, không thuộc bài này).

---

## 8. Open Questions

(Sẽ trả lời trong Phase 1 implementation, không block design)

- Có nên expose `context.text.titleMedium` shortcut (extension trên `BuildContext`) song song với `Theme.of(context).textTheme.titleMedium`? Tiện hơn nhưng thêm 1 API. **Đề xuất:** chỉ thêm nếu sau Phase 2 thấy gọi `Theme.of(context).textTheme.X` quá dài/dày.
- Lint rule custom Dart có cần build `custom_lint` package không? **Đề xuất:** thử bash CI script trước (R1.7), nếu false positive nhiều mới build custom_lint.

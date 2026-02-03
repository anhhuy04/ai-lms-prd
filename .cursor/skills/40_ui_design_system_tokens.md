---
name: 40_ui_design_system_tokens
intent: Enforce Design Tokens + widget organization + UI refactoring rules
tags: [flutter, ui, design-system]
---

## Intent

UI nhất quán, responsive, không hardcode, dễ refactor.

## Triggers

- **file_globs**: `lib/presentation/views/**`, `lib/widgets/**`, `lib/core/constants/design_tokens.dart`
- **keywords**: `Color(`, `EdgeInsets.`, `TextStyle(`, `BorderRadius`, `BoxShadow`

## DO / DON'T

- **DO**: dùng `DesignColors.*`, `DesignSpacing.*`, `DesignTypography.*`, `DesignIcons.*`, `DesignRadius.*`, `DesignElevation.*`, `DesignComponents.*`.
- **DO**: dùng responsive spacing (`context.spacing.*`) nếu applicable.
- **DO**: tách widget nhỏ: method < 50 lines; widget reuse > 2 lần → tách file.
- **DON'T**: hardcode màu/spacing/font/icon/radius/shadow.

## Widget organization

`lib/widgets/` là reusable; feature-specific widgets nằm trong `lib/presentation/views/**/widgets/`.

## Links

- `memory-bank/DESIGN_SYSTEM_GUIDE.md`
- `memory-bank/systemPatterns.md` (Design System Specifications, Widget Component Patterns)
- `lib/core/constants/design_tokens.dart`
- `.clinerules` (UI rules, Flutter Refactoring)


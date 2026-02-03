---
name: 30_routing_gorouter_rbac_shellroute
intent: GoRouter v2 + RBAC + ShellRoute rules (no Navigator.push, no hardcode paths)
tags: [flutter, routing, gorouter, rbac]
---

## Intent

Giữ navigation type-safe, hỗ trợ deep link, và tránh loop/rebuild issues.

## Triggers

- **file_globs**: `lib/core/routes/**`, `lib/presentation/views/**`
- **keywords**: `GoRouter`, `ShellRoute`, `goNamed`, `pathParameters`, `AppRoute`

## DO / DON'T

- **DO**: dùng `context.goNamed()`/`context.pushNamed()` + `AppRoute` constants.
- **DO**: resource id → path parameter; filter/mode → query parameter; object phức tạp → `extra` (cẩn trọng).
- **DO**: deep links (reset-password/verify-email) phải đi qua public routes + RBAC redirect (xem `.clinerules`).
- **DO**: dùng `Navigator.pop` cho **UI overlay** (dialog, bottom sheet, wizard nhỏ trong modal) nếu thuận tiện.
- **DON'T**: `Navigator.push*` cho screen/app-level navigation (GoRouter chịu trách nhiệm).
- **DON'T**: dùng `Navigator.pop` để “đi route” (quay về màn chính) – thay vào đó dùng GoRouter.
- **DON'T**: hardcode `'/teacher/class/$id'`.

## Single Source of Truth (SoT)

- `lib/core/routes/route_constants.dart`
- `lib/core/routes/app_router.dart`
- `lib/core/routes/route_guards.dart`

## Links

- `.clinerules` (Router & Navigation GoRouter v2.0)
- `memory-bank/systemPatterns.md` (Router Architecture “Tứ Trụ”)


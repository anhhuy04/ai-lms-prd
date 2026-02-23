# 30 — Routing (GoRouter + RBAC + ShellRoute)

## Core Principles
- Use `context.goNamed()` / `context.go()` for ALL screen navigation
- Use `Navigator.pop()` ONLY for: dialog, bottom sheet, modal overlay
- NO `Navigator.push*()` for screen navigation
- NO hardcoded path strings — use `AppRoute` constants
- NO helper static class (e.g. `NavigationHelper.goTo...`)

## Source Files (Single Source of Truth)
- `lib/core/routes/route_constants.dart` — ALL route names, paths, RBAC helpers
- `lib/core/routes/app_router.dart` — GoRouter config, ShellRoute, RBAC redirect
- `lib/core/routes/route_guards.dart` — redirect callback, auth/role checks

**FORBIDDEN:** `app_routes.dart`, `routes_v2.dart`, `navigation_helper.dart`

## ⚠️ CRITICAL: Route Ordering
Specific routes MUST come BEFORE parameterized routes:
```dart
// ✅ CORRECT
GoRoute(path: '/student/class/search', ...),  // specific first
GoRoute(path: '/student/class/:classId', ...),  // param after

// ❌ WRONG — param will match 'search' first!
GoRoute(path: '/student/class/:classId', ...),
GoRoute(path: '/student/class/search', ...),
```
Order in `app_router.dart`: **specific → parameterized → catch-all**

## Navigation Patterns
```dart
// UI layer (BuildContext available)
context.goNamed(AppRoute.teacherEditClass, pathParameters: {'classId': id});
context.go(AppRoute.loginPath);

// Logic layer (no BuildContext — Riverpod notifier)
ref.read(routerProvider).goNamed(AppRoute.studentDashboard);
```

## RBAC Redirect Logic (3-Step)
1. **Public route?** (splash, login, register, reset-password, verify-email) → allow
2. **Authenticated?** → No → redirect `/login?redirect={path}`
3. **Role match?** → No → redirect to role's dashboard

## Route Categories
- **Public**: `/splash`, `/login`, `/register`, `/reset-password`, `/verify-email`
- **Student** (ShellRoute): `/student-dashboard`, `/student/classes`, `/student/class/:classId`, `/student/scores`
- **Student** (standalone): `/student/join-class`, `/student/qr-scan`
- **Teacher** (ShellRoute): `/teacher-dashboard`, `/teacher/classes`, `/teacher/class/:classId`
- **Teacher** (standalone): `/teacher/class/create`, `/teacher/class/:classId/edit`, `/teacher/class/:classId/students`
- **Admin** (ShellRoute): `/admin-dashboard`
- **Shared**: `/profile`, `/edit-profile`, `/settings`, `/403`

## Path Parameters — Golden Rule
- Resource ID → path parameter (supports deep linking)
- Optional filter → query parameter (`?mode=edit`)
- Complex object (no deep link) → `extra` (mobile-only, use sparingly)
- **NEVER use `extra` for IDs**

## Adding New Route (4 Steps)
1. Add constants to `route_constants.dart`
2. Add `GoRoute` to `app_router.dart` (respect ordering)
3. Update `canAccessRoute()` if role-restricted
4. Use `context.goNamed()` in UI

## Dashboard Screens
Accept `Widget? child` for ShellRoute integration:
```dart
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  final Widget? child;  // ShellRoute injects child
  ...
}
```

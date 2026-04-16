# Coding Conventions

**Analysis Date:** 2026-04-14

## Naming Patterns

**Files:**
- Screens: `[feature]_screen.dart` — e.g., `teacher_create_assignment_screen.dart`
- Notifiers: `[feature]_notifier.dart` — e.g., `auth_notifier.dart`, `class_notifier.dart`
- Providers: `[feature]_providers.dart` — e.g., `auth_providers.dart`, `class_providers.dart`
- DataSources: `[feature]_datasource.dart` — e.g., `submission_datasource.dart`
- Repository implementations: `[feature]_repository_impl.dart`
- Widgets (shared): `lib/widgets/[category]/[widget_name].dart`
- Widgets (feature-specific): `lib/presentation/views/[feature]/widgets/[widget_name].dart`
- Generated files: `.g.dart` suffix for Riverpod/JSON; `.freezed.dart` for Freezed

**Classes:**
- Screens: `[FeatureName]Screen` — e.g., `TeacherSubmissionDetailScreen`
- Notifiers: `[FeatureName]Notifier` — e.g., `AuthNotifier`, `ClassNotifier`
- Repository interfaces: `[Feature]Repository` — e.g., `SubmissionRepository`, `AuthRepository`
- DataSources: `[Feature]Datasource` or `[Feature]DataSource`
- Freezed entities/models: `[Feature]` — e.g., `Class`, `Submission`, `Profile`
- Utilities: `[Feature]Helper` or `[Feature]Utils` — e.g., `QrHelper`, `DateUtils`
- Design token containers: `DesignColors`, `DesignSpacing`, `DesignTypography`, etc.

**Providers (Riverpod):**
- Simple/functional providers: `[feature]Provider` — e.g., `authRepositoryProvider`, `analyticsDatasourceProvider`
- Class-based notifiers: auto-generated as `[featureName]NotifierProvider`
- Kept alive: `@Riverpod(keepAlive: true)` on session-critical providers (e.g., `AuthNotifier`)

**Functions/Methods:**
- Public: camelCase — `loadClassesByTeacher()`, `signIn()`, `submitAssignment()`
- Private widget builders: `_build[Name]()` — `_buildHeader()`, `_buildSubmissionList()`
- Private helpers: `_[name]()` — `_safeCheckCurrentUser()`, `_fetchAnalytics()`

**Variables:**
- camelCase throughout
- Concurrency guards: `bool _isUpdating = false`
- Private state holders: `_selectedClass`, `_detailErrorMessage`, `_isDetailLoading`

**Constants:**
- Route names/paths: `AppRoute` constants in `lib/core/routes/route_constants.dart`
- All design values: design token classes in `lib/core/constants/design_tokens.dart`

## Code Style

**Formatting:**
- Tool: `dart format` (standard Dart formatter)
- Single quotes enforced: `prefer_single_quotes: true` in `analysis_options.yaml`
- Line length: 80 characters (dart format default)

**Linting:**
- Base ruleset: `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`
- `avoid_print: true` enforced — never use `print()`
- `riverpod_lint` package installed (`^2.3.0`); full include temporarily disabled, rules applied manually
- Zero tolerance: ALL `flutter analyze` errors must be fixed before commit

**Size limits:**
- `build()` method in widgets: max 50 lines → extract `_buildXxx()` sub-builders
- Widget/provider class: max 300 lines
- Any function: max 50 lines
- No hardcoded magic values — all constants go in `lib/core/constants/`

## Riverpod Patterns

**Generator-based only — never StateNotifierProvider or ChangeNotifier:**
```dart
// Stateful notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<Profile?> build() async { ... }
}

// Kept-alive provider
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier { ... }

// Simple functional provider
@riverpod
AnalyticsDatasource analyticsDatasource(Ref ref) {
  return AnalyticsDatasource();
}
```

**Accessing providers:**
```dart
// In build() / widget context: ref.watch()
final authState = ref.watch(authNotifierProvider);

// In callbacks and event handlers: ref.read()
ref.read(authNotifierProvider.notifier).signIn(email, password);
```

**Async state pattern (standard):**
```dart
state = const AsyncValue.loading();
try {
  final result = await _repo.loadSomething();
  state = AsyncValue.data(result);
} catch (e, stackTrace) {
  AppLogger.error('🔴 [MODULE] Operation failed: $e', error: e, stackTrace: stackTrace);
  state = AsyncValue.error(e, stackTrace);
}
```

**Concurrency guard (required for all mutating actions):**
```dart
bool _isUpdating = false;

Future<void> updateSomething() async {
  if (_isUpdating) return;
  _isUpdating = true;
  try {
    await _repo.update(params);
  } finally {
    _isUpdating = false;
  }
}
```

**Parameterized build():**
```dart
@riverpod
class StudentAnalyticsNotifier extends _$StudentAnalyticsNotifier {
  @override
  Future<StudentAnalytics> build({
    String? classId,
    AnalyticsTimeRange timeRange = const AnalyticsTimeRangeAll(),
  }) async { ... }
}
```

**NEVER `ref.invalidate(authNotifierProvider)`** — causes router redirect to login screen.

**Part files required for code generation:**
```dart
part 'auth_notifier.g.dart';
part 'distribute_assignment_notifier.freezed.dart';
part 'distribute_assignment_notifier.g.dart';
```

## Design System Usage

**Mandatory — never use raw values:**

| Token Class | Use | Never |
|---|---|---|
| `DesignColors.*` | `DesignColors.primary` | `Color(0xFF4A90E2)`, `Colors.blue` |
| `DesignSpacing.*` | `DesignSpacing.md` | `EdgeInsets.all(16)` raw |
| `DesignTypography.*` | `DesignTypography.bodyMedium` | `TextStyle(fontSize: 14)` |
| `DesignRadius.*` | `DesignRadius.md` | `BorderRadius.circular(8)` raw |
| `DesignElevation.level*` | `DesignElevation.level1` | `BoxShadow(...)` raw |

**Color palette highlights (`lib/core/constants/design_tokens.dart`):**
- Brand: `DesignColors.primary` (#4A90E2 blue), `DesignColors.tealPrimary` (#0EA5A4)
- Backgrounds: `DesignColors.moonLight`, `moonMedium`, `moonDark`
- Text: `DesignColors.textPrimary`, `textSecondary`, `textTertiary`
- Semantic: `DesignColors.success`, `warning`, `error`, `info`

**Spacing scale:**
- `DesignSpacing.xs`=4dp, `sm`=8dp, `md`=12dp, `lg`=16dp, `xl`=18dp, `xxl`=22dp, `xxxl`=28dp
- `DesignSpacing.screenPadding`=16dp (screen edges), `DesignSpacing.cardPadding`=16dp

**Responsive sizing (flutter_screenutil):**
```dart
width: 200.w    // responsive width
height: 50.h    // responsive height
fontSize: 14.sp // responsive font size
borderRadius: 8.r // responsive radius
```

**Responsive spacing:**
```dart
final spacing = DesignSpacing.responsive(context);
padding: EdgeInsets.all(spacing.md);
// via extension:
padding: EdgeInsets.all(context.spacing.md);
```

**Loading state components:**
- List skeleton: `ShimmerListTileLoading`
- Page skeleton: `ShimmerLoading`
- Dashboard skeleton: `ShimmerDashboardLoading`
- Inline: `CircularProgressIndicator`

**Const constructors:** Use `const` wherever possible for widgets.

## Import Organization

**Order:**
1. `dart:` core libraries (`dart:async`, `dart:io`, etc.)
2. `package:flutter/` framework
3. Third-party packages (`package:riverpod_annotation/`, `package:freezed_annotation/`, `package:go_router/`, etc.)
4. Internal project imports (`package:ai_mls/...`)
5. Relative part declarations (`part '...g.dart'`)

**Package name:** `ai_mls` (always use `package:ai_mls/...` for cross-directory imports, not relative paths)

## Error Handling

**AppLogger (mandatory — NEVER `print()`):**
```dart
AppLogger.debug('Debug details');
AppLogger.info('[MODULE] Operation completed');
AppLogger.warning('⚠️ [MODULE] Unexpected state', error: e, stackTrace: st);
AppLogger.error('🔴 [MODULE] Operation failed: $e', error: e, stackTrace: st);
AppLogger.fatal('Critical crash', error: e, stackTrace: st);
```

**Log prefix convention:**
- Module tag uppercase in brackets: `[AUTH]`, `[CLASS]`, `[SUBMIT]`, `[AI]`
- Warnings: `⚠️ [MODULE]`
- Errors: `🔴 [MODULE]`

**AppLogger behavior (`lib/core/utils/app_logger.dart`):**
- Debug mode: all levels with PrettyPrinter (colors, emojis, timestamps)
- Production: `error` and above only
- `AppLogger.error/fatal` auto-reports to Sentry via `ErrorReportingService`
- `info/warning` add breadcrumbs to Sentry

**Timeout pattern for Supabase/network calls:**
```dart
final result = await _repo.method().timeout(
  const Duration(seconds: 5),
  onTimeout: () {
    AppLogger.warning('⚠️ [MODULE] Timeout after 5s — treating as unauthenticated');
    return null;
  },
);
```

## Routing

**Navigation methods:**
- `context.pushNamed(AppRoute.xxx)` — default for screens with back button
- `context.goNamed(AppRoute.xxx)` — replace stack (login→home, bottom nav switches)
- `context.pop()` — back navigation from screens
- `Navigator.pop(context)` — ONLY for dialog, bottom sheet, modal

**Route name constants:** `AppRoute` class in `lib/core/routes/route_constants.dart` — never hardcode strings.

**Critical ordering rule in GoRouter config:**
```dart
// CORRECT: specific before parameterized
'/student/class/search'
'/student/class/:classId'

// BUG: :classId swallows 'search'
'/student/class/:classId'
'/student/class/search'
```

**Source files:**
- `lib/core/routes/route_constants.dart` — route names, paths, RBAC roles
- `lib/core/routes/app_router.dart` — GoRouter config
- `lib/core/routes/route_guards.dart` — redirect callbacks

## Comments

**Style:**
- Public API and non-obvious logic: DartDoc `///` format
- Section dividers: `// === SECTION NAME ===`
- Inline Vietnamese: Vietnamese comments used for clarifying business logic and state contracts

**State contracts (document in notifier):**
```dart
/// State: AsyncValue<Profile?>
/// - data(null): not logged in / no session
/// - data(Profile): logged in
/// - loading: processing (login / check session / signout)
/// - error: has error
```

## Code Generation

**Run after any annotation change (Freezed/JsonSerializable/Riverpod):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Never edit `.g.dart` or `.freezed.dart` files manually.**

---

*Convention analysis: 2026-04-14*

# Architecture

**Analysis Date:** 2026-04-14

## Pattern Overview

**Overall:** Clean Architecture with Riverpod-driven state management

**Key Characteristics:**
- Strict layer separation: domain → data → presentation → core
- Dependency inversion: domain defines interfaces, data implements them
- Repository pattern bridging data sources to domain logic
- `@riverpod` code-generation for all state providers
- GoRouter v14 with ShellRoute for role-based navigation shells

## Layers

**Domain Layer:**
- Purpose: Business rules, entity definitions, repository contracts
- Location: `lib/domain/`
- Contains: Freezed entities, abstract repository interfaces, use-cases
- Depends on: Nothing (pure Dart, no Flutter or external packages)
- Used by: Data layer (implementations), Presentation layer (entities)

**Data Layer:**
- Purpose: Data fetching, persistence, and repository implementations
- Location: `lib/data/`
- Contains: DataSources (Supabase RPC/table queries), RepositoryImpl classes, mock data
- Depends on: Domain interfaces, `supabase_flutter`, `drift`
- Used by: Presentation layer via Riverpod provider overrides

**Presentation Layer:**
- Purpose: UI rendering and state management
- Location: `lib/presentation/`
- Contains: `views/` (screens + local widgets), `providers/` (Riverpod), `viewmodels/`, `fetchers/`, `mappers/`
- Depends on: Domain entities, Data repositories (injected via providers)
- Used by: Nothing (top of UI stack)

**Core Layer:**
- Purpose: Cross-cutting utilities, configuration, services
- Location: `lib/core/`
- Contains: `routes/`, `services/`, `constants/`, `theme/`, `utils/`, `env/`
- Depends on: External packages only
- Used by: All other layers

**Shared Widgets:**
- Purpose: Reusable UI components not tied to a feature
- Location: `lib/widgets/`
- Contains: Buttons, cards, dialogs, forms, loading states, rubric builders, search widgets
- Depends on: Core (design tokens, theme)
- Used by: Presentation views

## Data Flow

**Read/Display Flow:**

1. Screen calls `ref.watch(someProvider)` to subscribe to state
2. Provider instantiates or delegates to a Repository interface
3. RepositoryImpl calls the appropriate DataSource method
4. DataSource executes a Supabase query (`.select()`, `.rpc()`, `.stream()`)
5. Result is mapped to a Freezed domain entity and returned as `AsyncValue<T>`
6. Screen renders from `AsyncValue` using `.when(data:, loading:, error:)`

**Write/Mutation Flow:**

1. UI calls `ref.read(notifierProvider.notifier).someAction()`
2. Notifier guards concurrency with `bool _isUpdating = false`
3. Notifier calls Repository method, wraps with `AsyncValue.guard()`
4. On success, `ref.invalidateSelf()` or explicit state update triggers UI rebuild
5. Optimistic updates applied via `lib/core/utils/optimistic_update_utils.dart`

**State Management:**
- All providers use `@riverpod` generator — never `StateNotifierProvider`
- `ref.watch()` in `build()` methods; `ref.read()` in callbacks only
- Repository instances injected at app boot via `ProviderScope.overrides` in `lib/main.dart`
- Auth state drives router redirects via `currentUserProvider` (`lib/presentation/providers/auth_providers.dart`)

## Key Abstractions

**Repository Interfaces:**
- Purpose: Decouple UI from data implementation details
- Examples: `lib/domain/repositories/assignment_repository.dart`, `lib/domain/repositories/school_class_repository.dart`, `lib/domain/repositories/submission_repository.dart`, `lib/domain/repositories/ai_repository.dart`
- Pattern: Abstract class with async methods returning `Future<T>` or `Stream<T>`

**DataSources:**
- Purpose: Encapsulate all Supabase query logic
- Examples: `lib/data/datasources/assignment_datasource.dart`, `lib/data/datasources/submission_datasource.dart`, `lib/data/datasources/analytics_datasource.dart`
- Pattern: Constructor receives `SupabaseClient`; methods return raw JSON or mapped entities

**Freezed Entities:**
- Purpose: Immutable value objects for domain data
- Examples: `lib/domain/entities/assignment.dart`, `lib/domain/entities/submission.dart`, `lib/domain/entities/profile.dart`, `lib/domain/entities/analytics/student_analytics.dart`
- Pattern: `@freezed` class with `factory` constructor + `fromJson`; generated `.freezed.dart` and `.g.dart` siblings alongside source file

**Riverpod Notifiers:**
- Purpose: Encapsulate mutation logic and complex async state
- Examples: `lib/presentation/providers/assignment_builder_notifier.dart`, `lib/presentation/providers/workspace_provider.dart`, `lib/presentation/providers/distribute_assignment_notifier.dart`
- Pattern: `@riverpod` class extending `AutoDisposeAsyncNotifier<T>` or `AutoDisposeNotifier<T>`

## Entry Points

**App Bootstrap:**
- Location: `lib/main.dart`
- Triggers: Flutter engine startup
- Responsibilities: Sentry init, Supabase init, DeepLinkService init, construct all DataSources + Repositories, inject via `ProviderScope.overrides`, run `MyApp`

**Router:**
- Location: `lib/core/routes/app_router.dart` (`appRouterProvider`)
- Triggers: Auth state changes via `ValueNotifier` listener on `currentUserProvider`
- Responsibilities: RBAC redirect logic, ShellRoute role shells, named route definitions, `FadeTransitionPage` for shell tab transitions

**Root Widget:**
- Location: `lib/main.dart` (`MyApp`)
- Responsibilities: `ScreenUtilInit` setup (design size 375x812), `MaterialApp.router` with GoRouter, global tap-to-dismiss keyboard, `DeepLinkService.applyPendingDeepLink` post-frame

## Error Handling

**Strategy:** Layered — datasource throws, repository propagates, Riverpod catches

**Patterns:**
- `AsyncValue.guard(() => repository.method())` in Notifiers — auto-wraps exceptions into `AsyncValue.error`
- `ErrorReportingService` (Sentry) initialized before all app code in `lib/main.dart`
- `AppLogger` (`lib/core/utils/app_logger.dart`) for structured logging — never `print()`
- `error_translation_utils.dart` (`lib/core/utils/error_translation_utils.dart`) maps Supabase/network errors to user-facing Vietnamese strings
- No-internet redirect via `NetworkService.hasInternetConnection()` at boot; runtime connectivity tracked via `lib/presentation/providers/connectivity_providers.dart`

## Cross-Cutting Concerns

**Logging:** `AppLogger` wraps `logger` package. Use `AppLogger.info/debug/error()`. Never `print()`.

**Validation:** `lib/core/utils/validation_utils.dart` for form field validators.

**Authentication:** Supabase Auth + `currentUserProvider` in `lib/presentation/providers/auth_providers.dart`. GoRouter redirect enforces RBAC via `AppRoute.canAccessRoute()` in `lib/core/routes/route_constants.dart`.

**Responsive UI:** `flutter_screenutil` — all sizing via `.w`, `.h`, `.sp`, `.r`. Design size `375x812`.

**Design System:** Design tokens in `lib/core/constants/design_tokens.dart`. Use `DesignColors.*`, `DesignSpacing.*`, `DesignTypography.*`, `DesignRadius.*`, `DesignElevation.*` — never raw `Color()` or `EdgeInsets`.

**Deep Linking:** `lib/core/services/deep_link_service.dart` — handles Supabase Auth deep links (reset password, email verify). Applied post-router-init via `addPostFrameCallback`.

**AI Services:** `lib/core/services/ai_service.dart` and `lib/core/services/api_key_service.dart` for Gemini/AI grading calls. Queue management via `lib/core/services/teacher_ai_queue_processor.dart` and `lib/presentation/providers/teacher_ai_queue_provider.dart`.

**Secure Storage:** `lib/core/services/secure_storage_service.dart` wraps `flutter_secure_storage` for tokens and API keys.

---

*Architecture analysis: 2026-04-14*

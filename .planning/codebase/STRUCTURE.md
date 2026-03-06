# Codebase Structure

**Analysis Date:** 2026-03-05

## Directory Layout

```
lib/
├── core/              # Shared infrastructure, routing, services
├── data/              # Repository implementations, datasources
├── domain/            # Entities, repository interfaces, use-cases
├── presentation/      # UI (views, providers, widgets)
├── widgets/           # Shared reusable widgets
└── main.dart          # Entry point
```

## Directory Purposes

**lib/core/:**
- Purpose: Infrastructure, routing, theming, utilities
- Contains: `routes/`, `services/`, `utils/`, `constants/`, `theme/`
- Key files: `lib/core/routes/app_router.dart`, `lib/core/routes/route_constants.dart`

**lib/domain/:**
- Purpose: Business logic layer (pure Dart)
- Contains: `entities/`, `repositories/`, `usecases/`
- Key files: `lib/domain/entities/class.dart`, `lib/domain/repositories/school_class_repository.dart`

**lib/data/:**
- Purpose: Data access layer implementations
- Contains: `datasources/`, `repositories/`, `scripts/`, `mock/`
- Key files: `lib/data/datasources/supabase_datasource.dart`, `lib/data/repositories/school_class_repository_impl.dart`

**lib/presentation/:**
- Purpose: UI layer with state management
- Contains: `views/`, `providers/`, `mappers/`, `utils/`, `viewmodels/`
- Key files: `lib/presentation/providers/auth_providers.dart`, `lib/presentation/views/class/teacher/teacher_class_list_screen.dart`

**lib/widgets/:**
- Purpose: Shared reusable UI components
- Contains: `dialogs/`, `drawers/`, `responsive/`, `loading/`, `list_item/`, `text/`, `search/`, `navigation/`

**lib/splash/:**
- Purpose: Splash screen logic
- Contains: `lib/splash/splash.dart`

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, ProviderScope

**Configuration:**
- `lib/core/routes/route_constants.dart`: All route names and paths
- `lib/core/routes/app_router.dart`: GoRouter config with RBAC
- `lib/core/theme/app_theme.dart`: Theme configuration

**Core Logic:**
- `lib/core/services/supabase_service.dart`: Supabase client
- `lib/core/services/secure_storage_service.dart`: Secure token storage
- `lib/core/services/error_reporting_service.dart`: Sentry integration

**State Management:**
- `lib/presentation/providers/auth_providers.dart`: Auth state
- `lib/presentation/providers/class_providers.dart`: Class-related providers
- `lib/presentation/providers/assignment_providers.dart`: Assignment providers

## Naming Conventions

**Files:**
- Screens: `[Feature]Screen` - e.g., `TeacherClassListScreen`
- Widgets: `[Feature]Widget` - e.g., `ClassItemWidget`
- Providers: `[Feature]Provider` / `[Feature]NotifierProvider`
- Repositories: `[Feature]Repository` / `[Feature]RepositoryImpl`
- Entities: `snake_case.dart` with Freezed classes

**Directories:**
- Feature folders: `snake_case` - e.g., `teacher_class_detail_screen.dart`
- Screen folders: lowercase - e.g., `views/class/teacher/`

**Classes:**
- Screens: `XxxScreen` - e.g., `LoginScreen`
- Widgets: `XxxWidget` - e.g., `ClassPrimaryActionCard`
- Providers: `XxxNotifier` - e.g., `AuthNotifier`
- Entities: `XxxEntity` (implicit via Freezed)

## Where to Add New Code

**New Feature:**
- Primary code: `lib/presentation/views/[feature]/`
- Providers: `lib/presentation/providers/`
- Tests: `test/presentation/`

**New Entity:**
- Entity definition: `lib/domain/entities/xxx.dart`
- Repository interface: `lib/domain/repositories/xxx_repository.dart`
- Repository impl: `lib/data/repositories/xxx_repository_impl.dart`
- Datasource: `lib/data/datasources/xxx_datasource.dart`

**New Screen:**
- View: `lib/presentation/views/[role]/[feature]_screen.dart`
- Route: Add to `lib/core/routes/route_constants.dart` and `lib/core/routes/app_router.dart`

**New Provider:**
- Async data: `lib/presentation/providers/xxx_providers.dart` with `@riverpod`
- Complex state: `lib/presentation/providers/xxx_notifier.dart`

**Utilities:**
- Shared helpers: `lib/core/utils/`
- Feature-specific: co-located with feature

---

*Structure analysis: 2026-03-05*

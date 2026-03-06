# Architecture

**Analysis Date:** 2026-03-05

## Pattern Overview

**Overall:** Clean Architecture with Riverpod state management

**Key Characteristics:**
- Three-layer separation: presentation, domain, data
- Riverpod for reactive state management with code generation
- GoRouter for declarative routing with RBAC guards
- Supabase backend with repository pattern

## Layers

**Presentation Layer:**
- Purpose: UI screens, widgets, and state providers
- Location: `lib/presentation/`
- Contains: `views/`, `providers/`, `mappers/`, `viewmodels/`, `utils/`
- Depends on: Domain layer (entities, repositories interfaces)
- Used by: GoRouter, main.dart

**Domain Layer:**
- Purpose: Business logic, entities, repository interfaces
- Location: `lib/domain/`
- Contains: `entities/`, `repositories/`, `usecases/`
- Depends on: None (pure Dart)
- Used by: Presentation layer

**Data Layer:**
- Purpose: Data access, repository implementations, datasources
- Location: `lib/data/`
- Contains: `datasources/`, `repositories/`, `scripts/`, `mock/`
- Depends on: Domain layer, Supabase client
- Used by: Presentation providers

**Core Layer:**
- Purpose: Shared utilities, routing, theming, services
- Location: `lib/core/`
- Contains: `routes/`, `services/`, `utils/`, `constants/`, `theme/`
- Used by: All layers

## Data Flow

**Standard Flow:**

1. UI calls `ref.watch(provider)` or `ref.read(provider)`
2. Provider calls repository method
3. Repository implementation calls datasource
4. Datasource queries Supabase
5. Response flows back: datasource -> repository -> provider -> UI

**Auth Flow:**
1. SplashScreen -> checks auth state via `currentUserProvider`
2. GoRouter redirect evaluates `isAuth` + user role
3. Unauthenticated -> redirect to `/login`
4. Authenticated wrong role -> redirect to role dashboard

**State Management:**
- Riverpod with `@riverpod` annotation for code generation
- AsyncNotifier for async operations (data fetching)
- Notifier for sync operations
- StateNotifier for complex state (legacy pattern)

## Key Abstractions

**Repository Pattern:**
- Purpose: Abstract data source from presentation
- Examples: `lib/domain/repositories/school_class_repository.dart`
- Pattern: Interface in domain, implementation in data

**Entity (Freezed):**
- Purpose: Immutable data models with serialization
- Examples: `lib/domain/entities/class.dart`, `lib/domain/entities/assignment.dart`
- Pattern: Freezed classes with `copyWith`, `fromJson`, `toJson`

**Use Cases:**
- Purpose: Encapsulate business rules
- Examples: `lib/domain/usecases/delete_class_usecase.dart`
- Pattern: Single method classes (though less frequently used)

## Entry Points

**Main Entry:**
- Location: `lib/main.dart`
- Triggers: App launch
- Responsibilities: ProviderScope setup, theme init, router init

**Routing Entry:**
- Location: `lib/core/routes/app_router.dart`
- Triggers: Navigation events
- Responsibilities: GoRouter config, redirect logic, RBAC

**Auth Entry:**
- Location: `lib/presentation/providers/auth_providers.dart`
- Triggers: App start, login/logout
- Responsibilities: Auth state, user profile loading

## Error Handling

**Strategy:** Service layer with error translation

**Patterns:**
- `lib/core/services/error_reporting_service.dart` - Sentry integration
- `lib/core/utils/error_translation_utils.dart` - User-friendly messages
- Providers use `AsyncValue.guard()` for safe async operations

## Cross-Cutting Concerns

**Logging:** `lib/core/utils/app_logger.dart` - Structured logging wrapper

**Validation:** `lib/core/utils/validation_utils.dart` - Form/input validation

**Authentication:** RBAC in GoRouter redirect - `lib/core/routes/route_guards.dart`

---

*Architecture analysis: 2026-03-05*

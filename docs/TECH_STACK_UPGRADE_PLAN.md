# Tech Stack Upgrade Plan
## AI LMS - Production-Ready Flutter App

**Date:** January 2026  
**Architecture:** Clean Architecture + MVVM  
**State Management:** Riverpod (with Provider for ViewModels)

---

## Executive Summary

This document outlines a comprehensive upgrade plan to transform the AI LMS Flutter application into a production-ready, enterprise-grade solution. The plan addresses missing components, recommends best-in-class packages for 2025-2026, and provides a step-by-step implementation strategy that maintains compatibility with the existing Clean Architecture + Riverpod setup.

---

## Phase 1: Current State Analysis

### ✅ What We Have

| Component | Current Implementation | Status |
|-----------|----------------------|--------|
| **Architecture** | Clean Architecture (Domain/Data/Presentation) | ✅ Solid |
| **State Management** | Riverpod (providers) + Provider (ViewModels) | ⚠️ Mixed approach |
| **Backend** | Supabase (Auth, Database, Storage) | ✅ Good |
| **Routing** | Basic `MaterialPageRoute` with `AppRoutes` | ⚠️ Needs upgrade |
| **Local Storage** | SharedPreferences (mentioned) | ⚠️ Limited |
| **Error Handling** | Basic try-catch with print statements | ❌ Not production-ready |
| **Logging** | `print()` statements | ❌ Not structured |
| **Environment Config** | Hardcoded Supabase credentials | ❌ Security risk |
| **Deep Linking** | Not implemented | ❌ Missing |
| **Dependency Injection** | Manual DI via constructors | ⚠️ Works but not scalable |
| **Code Quality** | Basic `flutter_lints` | ⚠️ Can be enhanced |
pretty_qr_code


### ❌ Critical Gaps Identified

1. **Environment Management** - Hardcoded API keys and URLs
2. **Structured Logging** - No log levels, filtering, or remote logging
3. **Error Reporting** - No crash tracking or error aggregation
4. **Local Database** - Only SharedPreferences (no relational/NoSQL option)
5. **Deep Linking** - No support for universal links or deferred deep links
6. **Routing** - Basic routing without type safety or deep link support
7. **Secure Storage** - No secure storage for tokens/credentials
8. **Code Generation** - No use of freezed, json_serializable for models

---

## Phase 2: Research & Package Selection

### Selection Criteria

- ✅ **Dart 3+ Compatible** - Full support for Dart 3.x features
- ✅ **Null Safety** - Sound null safety throughout
- ✅ **High Pub Points** - Well-maintained, actively developed
- ✅ **Riverpod Integration** - Works seamlessly with Riverpod
- ✅ **Clean Architecture Friendly** - Doesn't violate layer boundaries
- ✅ **Production Ready** - Battle-tested in production apps

---

## Phase 3: Core Libraries & Justifications

### 1. Routing & Deep Linking

#### **GoRouter** (v14.0.0+)

**Why GoRouter over AutoRoute?**
- ✅ **Official Flutter Support** - Recommended by Flutter team
- ✅ **Simpler Setup** - Less code generation, more declarative
- ✅ **Deep Linking Built-in** - First-class support for URL-based routing
- ✅ **Type Safety** - Can achieve type safety without code generation overhead
- ✅ **Better Riverpod Integration** - Works naturally with Riverpod providers
- ✅ **Web Support** - Excellent web routing support
- ✅ **Maintenance** - Actively maintained, large community

**Alternatives Considered:**
- **AutoRoute**: More code generation, steeper learning curve, but excellent type safety
- **Navigator 2.0**: Too low-level, requires more boilerplate

**Integration:** Replace `AppRoutes.generateRoute` with GoRouter configuration. Use Riverpod providers for auth state in route guards.

---

#### **app_links** (v7.0.0+)

**Why app_links?**
- ✅ **Universal Links Support** - iOS App Links + Android App Links
- ✅ **Custom Schemes** - Handles custom URL schemes
- ✅ **Cross-Platform** - Works on mobile, web, desktop
- ✅ **Null Safe** - Full Dart 3 compatibility
- ✅ **Active Maintenance** - Regular updates
- ✅ **Firebase Dynamic Links Replacement** - Since Firebase Dynamic Links is deprecated (Aug 2025)

**Alternatives Considered:**
- **uni_links**: Older, less maintained
- **firebase_dynamic_links**: Deprecated

**Integration:** Listen for incoming links in `main.dart`, forward to GoRouter for navigation.

---

### 2. Local Database & Persistence

#### **Drift** (v2.30.0+) - Primary Choice for Relational Data

**Why Drift over Hive/Isar?**
- ✅ **SQL Power** - Full SQLite with type-safe Dart queries
- ✅ **Migrations** - Robust migration system
- ✅ **Reactive Streams** - Built-in reactive queries
- ✅ **Cross-Platform** - Works on all platforms including web
- ✅ **Active Maintenance** - Very active development
- ✅ **Community Trust** - High pub points, widely adopted
- ✅ **Testability** - Easy to mock and test

**Why Not Hive?**
- ⚠️ **Limited Queries** - No complex relational queries
- ⚠️ **Maintenance Concerns** - Community reports of slower updates
- ⚠️ **No SQL** - Can't leverage SQL knowledge

**Why Not Isar?**
- ⚠️ **Maintenance Issues** - Community reports of maintenance lag
- ⚠️ **NoSQL Only** - Less suitable for relational data
- ⚠️ **Learning Curve** - Different query model

**Use Case:** Store cached assignments, submissions, user preferences, offline queue.

---

#### **flutter_secure_storage** (v9.0.0+) - For Sensitive Data

**Why flutter_secure_storage?**
- ✅ **Platform Native** - Uses Keychain (iOS) and Keystore (Android)
- ✅ **Encryption** - Automatic encryption at rest
- ✅ **Token Storage** - Perfect for JWT tokens, API keys
- ✅ **Production Ready** - Battle-tested, widely used

**Integration:** Replace any SharedPreferences usage for tokens/credentials with secure storage.

---

### 3. Error Reporting & Logging

#### **sentry_flutter** (v9.10.0+)

**Why Sentry over Firebase Crashlytics?**
- ✅ **Cross-Platform** - Full web support (Crashlytics is mobile-only)
- ✅ **Non-Fatal Errors** - Better handling of handled exceptions
- ✅ **Performance Monitoring** - Built-in performance tracing
- ✅ **Better Context** - Richer error context and breadcrumbs
- ✅ **Flexibility** - More control over error grouping and reporting
- ✅ **Free Tier** - Generous free tier for small teams

**Alternatives Considered:**
- **Firebase Crashlytics**: Good but limited web support, less flexible

**Integration:** Initialize in `main.dart` with `runZonedGuarded`. Wrap app with Sentry error boundaries.

---

#### **logger** (v2.0.0+) - Structured Logging

**Why logger package?**
- ✅ **Log Levels** - Debug, Info, Warning, Error
- ✅ **Pretty Printing** - Beautiful console output
- ✅ **Customizable** - Easy to add custom outputs (file, remote)
- ✅ **Lightweight** - Minimal overhead
- ✅ **Production Ready** - Can disable verbose logs in production

**Integration:** Create `AppLogger` wrapper in `core/utils/`. Replace all `print()` statements with structured logging.

---

### 4. Environment & Configuration

#### **envied** (v0.4.0+) - Compile-Time Environment Variables

**Why envied over flutter_dotenv?**
- ✅ **Type Safety** - Compile-time type checking
- ✅ **No Runtime Parsing** - Generated code, no runtime overhead
- ✅ **Security** - Secrets can be encrypted at compile time
- ✅ **Build-Time Validation** - Catches errors at build time
- ✅ **Code Generation** - Uses build_runner (already needed for other packages)

**Why Not flutter_dotenv?**
- ⚠️ **Runtime Parsing** - Slight overhead, less type-safe
- ⚠️ **No Encryption** - Secrets visible in .env files

**Integration:** Generate environment classes per flavor (dev/staging/prod). Use `--dart-define` for CI/CD secrets.

---

#### **flutter_dotenv** (v5.1.0+) - Runtime Configuration (Optional)

**Use Case:** For runtime feature flags or non-sensitive configuration that can change without rebuild.

**Integration:** Load `.env` files per flavor, use for non-sensitive config.

---

### 5. Dependency Injection

#### **Keep Riverpod** - Primary DI Solution

**Why Keep Riverpod?**
- ✅ **Already Integrated** - Already using Riverpod providers
- ✅ **State + DI** - Handles both state management and DI
- ✅ **Code Generation** - `@riverpod` annotation for code generation
- ✅ **Testability** - Easy to override providers in tests
- ✅ **Scoping** - Excellent provider scoping

**Enhancement:** Use `@riverpod` code generation for cleaner provider definitions.

---

#### **get_it** (v8.0.0+) - Optional Service Locator

**Why get_it (Optional)?**
- ✅ **Service Layer DI** - For non-UI services (logging, analytics)
- ✅ **Complementary** - Works alongside Riverpod
- ✅ **Simple** - Lightweight service locator pattern

**Use Case:** Only if you need service locator pattern for core services that don't need reactivity.

**Integration:** Use for core services (logger, analytics), expose via Riverpod providers if needed.

---

### 6. Code Generation & Data Models

#### **freezed** (v2.4.0+) - Immutable Data Classes

**Why freezed?**
- ✅ **Immutable Models** - Prevents accidental mutations
- ✅ **Union Types** - Excellent for state management (loading/error/success)
- ✅ **Code Generation** - Reduces boilerplate
- ✅ **Riverpod Integration** - Works perfectly with Riverpod state
- ✅ **JSON Serialization** - Built-in JSON support

**Integration:** Use for domain entities, state classes, API models.

---

#### **json_serializable** (v6.7.0+) - JSON Serialization

**Why json_serializable?**
- ✅ **Type Safe** - Compile-time JSON serialization
- ✅ **Performance** - Faster than runtime reflection
- ✅ **Maintainable** - Clear, generated code

**Integration:** Use with freezed for complete model generation.

---

### 7. Networking Enhancements

#### **dio** (v5.4.0+) - HTTP Client

**Why dio over http package?**
- ✅ **Interceptors** - Request/response interceptors
- ✅ **Retry Logic** - Built-in retry mechanisms
- ✅ **Timeout Control** - Better timeout handling
- ✅ **Form Data** - Easy file uploads
- ✅ **Cancel Tokens** - Request cancellation support

**Note:** Supabase already uses its own HTTP client, but Dio can be used for external API calls (AI grading, analytics).

**Integration:** Create Dio instance with interceptors for logging, error handling. Use for non-Supabase API calls.

---

### 8. Code Quality & Testing

#### **mocktail** (v1.0.0+) - Mocking for Tests

**Why mocktail over mockito?**
- ✅ **Null Safe** - Built for null safety
- ✅ **No Code Generation** - Pure Dart, no build_runner needed
- ✅ **Type Safe** - Better type safety

**Integration:** Use for mocking repositories, data sources in unit tests.

---

#### **riverpod_lint** (v2.3.0+) - Riverpod-Specific Lints

**Why riverpod_lint?**
- ✅ **Riverpod Best Practices** - Enforces Riverpod patterns
- ✅ **Catches Errors** - Prevents common Riverpod mistakes
- ✅ **Code Quality** - Improves provider definitions

**Integration:** Add to `analysis_options.yaml`.

---

## Phase 4: Integration Context

### How to Integrate Without Breaking Current Logic

#### 1. **Routing Migration Strategy**

**Current:** `AppRoutes.generateRoute` with `MaterialPageRoute`

**New:** GoRouter with declarative routes

**Migration Steps:**
1. Create `lib/core/routes/app_router.dart` with GoRouter configuration
2. Define routes matching current `AppRoutes` structure
3. Use Riverpod providers for auth state in route guards
4. Replace `MaterialApp` with `MaterialApp.router`
5. Test all navigation flows
6. Add deep linking support

**Example Structure:**
```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Auth guard logic
      if (authState == null && !state.matchedLocation.startsWith('/auth')) {
        return '/login';
      }
      return null;
    },
    routes: [
      // Define routes
    ],
  );
});
```

---

#### 2. **Environment Configuration**

**Current:** Hardcoded Supabase URL and key in `SupabaseService`

**New:** Environment-based configuration with envied

**Migration Steps:**
1. Create `.env.dev`, `.env.staging`, `.env.prod` files (gitignored)
2. Define `@Envied` class with environment variables
3. Generate environment classes with build_runner
4. Update `SupabaseService` to use environment config
5. Create flavor-specific entry points (`main_dev.dart`, `main_prod.dart`)

**Example:**
```dart
@Envied(path: '.env.dev')
class _Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _Env.supabaseUrl;
  
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _Env.supabaseAnonKey;
}
```

---

#### 3. **Logging Migration**

**Current:** `print()` statements throughout codebase

**New:** Structured logging with logger package

**Migration Steps:**
1. Create `lib/core/utils/app_logger.dart` wrapper
2. Replace `print()` with `AppLogger.debug()`, `AppLogger.error()`, etc.
3. Configure log levels per environment (verbose in dev, errors only in prod)
4. Add Sentry integration for error logs

**Example:**
```dart
class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(),
    level: kDebugMode ? Level.debug : Level.error,
  );
  
  static void debug(String message) => _logger.d(message);
  static void error(String message, [Object? error]) => _logger.e(message, error: error);
}
```

---

#### 4. **Local Database Integration**

**Current:** SharedPreferences (if used)

**New:** Drift for relational data, flutter_secure_storage for tokens

**Migration Steps:**
1. Define Drift database schema for entities (assignments, submissions cache)
2. Create DAOs for data access
3. Create repository interfaces in domain layer
4. Implement repositories using Drift in data layer
5. Expose via Riverpod providers
6. Migrate existing SharedPreferences data if needed

**Example Structure:**
```dart
// Domain layer
abstract class LocalAssignmentRepository {
  Future<List<Assignment>> getCachedAssignments();
  Future<void> cacheAssignments(List<Assignment> assignments);
}

// Data layer
class LocalAssignmentRepositoryImpl implements LocalAssignmentRepository {
  final AppDatabase _db;
  // Implementation using Drift
}
```

---

#### 5. **Error Reporting Integration**

**Current:** Basic try-catch with print

**New:** Sentry for crash reporting + structured error handling

**Migration Steps:**
1. Initialize Sentry in `main.dart` with `SentryFlutter.init()`
2. Wrap app with `runZonedGuarded` for uncaught errors
3. Add `Sentry.captureException()` in catch blocks
4. Configure release tracking and environment tags
5. Add breadcrumbs for better error context

**Example:**
```dart
void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kDebugMode ? 'development' : 'production';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

---

#### 6. **State Management Consolidation**

**Current:** Mixed Provider (ViewModels) + Riverpod (providers)

**Recommendation:** Gradually migrate to pure Riverpod

**Migration Strategy:**
1. Keep existing Provider ViewModels (no breaking changes)
2. For new features, use Riverpod `@riverpod` code generation
3. Gradually refactor ViewModels to Riverpod Notifiers if needed
4. Use Riverpod for all new state management

**Rationale:** Avoid breaking existing code. Riverpod can coexist with Provider.

---

## Phase 5: Implementation Checklist

### Priority 1: Critical Security & Production Readiness (Week 1-2)

- [ ] **1.1 Environment Configuration**
  - [ ] Add `envied` and `build_runner` to `pubspec.yaml`
  - [ ] Create `.env.dev`, `.env.staging`, `.env.prod` files
  - [ ] Define `@Envied` classes for each environment
  - [ ] Generate environment classes
  - [ ] Update `SupabaseService` to use environment config
  - [ ] Create flavor-specific entry points
  - [ ] Configure Android flavors and iOS schemes
  - [ ] Test environment switching

- [ ] **1.2 Secure Storage**
  - [ ] Add `flutter_secure_storage` to `pubspec.yaml`
  - [ ] Create `SecureStorageService` in `core/services/`
  - [ ] Migrate token storage from SharedPreferences to secure storage
  - [ ] Update auth repository to use secure storage
  - [ ] Test token persistence across app restarts

- [ ] **1.3 Error Reporting**
  - [ ] Add `sentry_flutter` to `pubspec.yaml`
  - [ ] Create Sentry account and get DSN
  - [ ] Initialize Sentry in `main.dart`
  - [ ] Wrap app with error boundaries
  - [ ] Add error capture in repository catch blocks
  - [ ] Configure release tracking
  - [ ] Test error reporting in dev environment

---

### Priority 2: Developer Experience & Code Quality (Week 3-4)

- [ ] **2.1 Structured Logging**
  - [ ] Add `logger` package to `pubspec.yaml`
  - [ ] Create `AppLogger` wrapper in `core/utils/`
  - [ ] Replace `print()` statements with `AppLogger` calls
  - [ ] Configure log levels per environment
  - [ ] Add Sentry integration for error logs
  - [ ] Document logging guidelines

- [ ] **2.2 Code Generation Setup**
  - [ ] Add `freezed`, `json_serializable`, `build_runner` to `pubspec.yaml`
  - [ ] Configure `build.yaml` for code generation
  - [ ] Migrate one entity to freezed (e.g., `Profile`)
  - [ ] Test JSON serialization/deserialization
  - [ ] Document code generation workflow

- [ ] **2.3 Enhanced Linting**
  - [ ] Add `riverpod_lint` to `dev_dependencies`
  - [ ] Update `analysis_options.yaml` with riverpod_lint
  - [ ] Add custom lint rules for Clean Architecture
  - [ ] Fix existing lint warnings
  - [ ] Set up pre-commit hooks (optional)

---

### Priority 3: Routing & Navigation (Week 5-6)

- [ ] **3.1 GoRouter Integration**
  - [ ] Add `go_router` to `pubspec.yaml`
  - [ ] Create `lib/core/routes/app_router.dart`
  - [ ] Define route configuration matching current routes
  - [ ] Implement auth guards using Riverpod providers
  - [ ] Replace `MaterialApp` with `MaterialApp.router`
  - [ ] Test all navigation flows
  - [ ] Update navigation calls throughout app

- [ ] **3.2 Deep Linking**
  - [ ] Add `app_links` to `pubspec.yaml`
  - [ ] Configure Android manifest for app links
  - [ ] Configure iOS Info.plist for universal links
  - [ ] Set up associated domains (if needed)
  - [ ] Implement deep link handler in `main.dart`
  - [ ] Integrate with GoRouter for navigation
  - [ ] Test deep links on iOS and Android

---

### Priority 4: Local Database (Week 7-8)

- [ ] **4.1 Drift Setup**
  - [ ] Add `drift` and `drift_flutter` to `pubspec.yaml`
  - [ ] Add `drift_dev` to `dev_dependencies`
  - [ ] Define database schema (tables for caching)
  - [ ] Create DAOs for data access
  - [ ] Generate database code
  - [ ] Create database provider (Riverpod)

- [ ] **4.2 Repository Integration**
  - [ ] Create `LocalAssignmentRepository` interface in domain
  - [ ] Implement using Drift in data layer
  - [ ] Create Riverpod providers for local repositories
  - [ ] Implement caching strategy
  - [ ] Add migration support
  - [ ] Test offline functionality

---

### Priority 5: Testing & CI/CD (Week 9-10)

- [ ] **5.1 Testing Setup**
  - [ ] Add `mocktail` to `dev_dependencies`
  - [ ] Write unit tests for repositories
  - [ ] Write unit tests for ViewModels/Notifiers
  - [ ] Write widget tests for key screens
  - [ ] Write integration tests for auth flow
  - [ ] Set up test coverage reporting

- [ ] **5.2 CI/CD Pipeline**
  - [ ] Set up GitHub Actions (or preferred CI)
  - [ ] Configure build workflows for each flavor
  - [ ] Add automated testing step
  - [ ] Add code quality checks (format, lint, analyze)
  - [ ] Configure code signing
  - [ ] Set up automated deployment (optional)

---

## Phase 6: Package Versions & Dependencies

### Recommended `pubspec.yaml` Additions

```yaml
dependencies:
  # Routing & Deep Linking
  go_router: ^14.0.0
  app_links: ^7.0.0
  
  # Local Database & Storage
  drift: ^2.30.0
  drift_flutter: ^2.30.0
  flutter_secure_storage: ^9.0.0
  
  # Error Reporting & Logging
  sentry_flutter: ^9.10.0
  logger: ^2.0.0
  
  # Environment Configuration
  envied: ^0.4.0
  
  # Code Generation (models)
  freezed_annotation: ^2.4.0
  json_annotation: ^6.7.0
  
  # Networking (for external APIs)
  dio: ^5.4.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.0
  drift_dev: ^2.30.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  envied_generator: ^0.4.0
  
  # Testing
  mocktail: ^1.0.0
  
  # Linting
  riverpod_lint: ^2.3.0
```

---

## Phase 7: Risk Assessment & Mitigation

### Potential Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Breaking Changes** | High | Medium | Gradual migration, feature flags, extensive testing |
| **Performance Impact** | Medium | Low | Benchmark before/after, optimize queries |
| **Team Learning Curve** | Medium | High | Documentation, code examples, pair programming |
| **Package Maintenance** | Medium | Low | Choose well-maintained packages, monitor updates |
| **Migration Time** | High | Medium | Phased approach, prioritize critical features |

---

## Phase 8: Success Metrics

### Key Performance Indicators

- ✅ **Zero Hardcoded Secrets** - All credentials in environment config
- ✅ **100% Error Coverage** - All errors reported to Sentry
- ✅ **Structured Logging** - Zero `print()` statements in production code
- ✅ **Type-Safe Routing** - All routes defined in GoRouter
- ✅ **Offline Support** - Local database caching working
- ✅ **Deep Linking** - Universal links working on iOS and Android
- ✅ **Test Coverage** - >70% code coverage for critical paths
- ✅ **CI/CD** - Automated builds and tests

---

## Phase 9: Documentation Updates

### Required Documentation

- [ ] Update `memory-bank/techContext.md` with new packages
- [ ] Create `docs/guides/development/routing-guide.md`
- [ ] Create `docs/guides/development/environment-setup.md`
- [ ] Create `docs/guides/development/logging-guide.md`
- [ ] Update `docs/ai/AI_INSTRUCTIONS.md` with new patterns
- [ ] Create migration guide for team

---

## Conclusion

This tech stack upgrade plan provides a comprehensive roadmap to transform the AI LMS app into a production-ready, enterprise-grade Flutter application. The phased approach ensures minimal disruption while systematically addressing critical gaps.

**Estimated Timeline:** 10 weeks for full implementation  
**Team Size:** 2-3 developers recommended  
**Priority:** Start with Phase 5 Priority 1 (Security & Production Readiness)

---

## Next Steps

1. **Review & Approve** - Team review of this plan
2. **Create Issues** - Break down into GitHub issues/tasks
3. **Set Up Environments** - Create dev/staging/prod configurations
4. **Begin Implementation** - Start with Priority 1 tasks
5. **Regular Reviews** - Weekly progress reviews and adjustments

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Author:** Senior Flutter Solutions Architect

1. Tối ưu hóa việc phối hợp Riverpod & GoRouter
Trong Phase 4 (Migration Strategy), bạn đề xuất dùng appRouterProvider.

Mẹo tối ưu: Hãy sử dụng Riverpod Generator cho chính GoRouter. Điều này giúp Router có thể lắng nghe (listen) trực tiếp các Provider về Auth mà không cần truyền ref thủ công, giúp logic chuyển hướng (redirect) khi login/logout trở nên cực kỳ mượt mà.

2. Bổ sung "Power Combo": Dio + Retrofit
Bạn đã liệt kê Dio, nhưng tôi khuyên bạn nên kết hợp nó với Retrofit.

Tại sao: Thay vì viết các hàm dio.get('/assignments') thủ công, Retrofit giúp bạn định nghĩa API như một Interface. Nó tự động generate code, giảm 90% lỗi typing và code thừa.

3. Tối ưu hóa Local Database (Drift vs Isar)
Bạn chọn Drift là rất chuẩn cho dữ liệu quan hệ (Relational).

Lưu ý: Nếu app của bạn có phần "Tìm kiếm Offline" cho hàng ngàn bài giảng, hãy cân nhắc dùng thêm Isar chỉ riêng cho phần Full-text Search vì tốc độ index của Isar nhanh hơn SQLite (Drift) đáng kể.

4. Bổ sung "Talker" cho Logging
Thay vì chỉ dùng logger, tôi đề xuất bạn cài thêm talker_flutter.

Lợi ích: Talker không chỉ log ra console mà còn cung cấp một UI Debug Screen ngay trong App. Bạn có thể xem toàn bộ lịch sử gọi API, lỗi, và thay đổi State của Riverpod ngay trên điện thoại mà không cần cắm cáp vào máy tính.
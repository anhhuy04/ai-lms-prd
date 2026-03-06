# Technology Stack

**Analysis Date:** 2026-03-05

## Languages

**Primary:**
- Dart 3.8.1 - All application code (lib/)

**Secondary:**
- None significant

## Runtime

**Environment:**
- Flutter SDK ^3.8.1 - Cross-platform UI framework
- Android SDK (for Android builds)
- iOS SDK (for iOS builds)

**Package Manager:**
- Flutter pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter 3.8.x - UI framework
- Riverpod 2.5.1 - State management (with `@riverpod` generator)
- GoRouter 14.0.0 - Declarative routing with type-safe navigation

**Testing:**
- flutter_test (SDK) - Unit and widget testing
- mocktail 1.0.0 - Mocking framework (dev dependency)

**Build/Dev:**
- build_runner 2.4.0 - Code generation (Freezed, Riverpod, Retrofit, JSON)
- flutter_lints 5.0.0 - Static analysis

## Key Dependencies

**State Management:**
- `flutter_riverpod: ^2.5.1` - Reactive state management
- `riverpod_annotation: ^2.6.1` - Code generation for Riverpod
- `provider: ^6.0.0` - Legacy support (being migrated away from)

**Data & Models:**
- `freezed_annotation: ^2.4.0` - Immutable data classes
- `json_annotation: ^4.9.0` - JSON serialization
- `drift: ^2.30.1` - Local SQLite database (ORM)
- `drift_flutter: ^0.2.8` - Flutter integration for Drift

**Networking:**
- `dio: ^5.4.0` - HTTP client
- `retrofit: >=4.8.0 <4.9.0` - Type-safe REST client generator
- `supabase_flutter: ^2.0.0` - Supabase client SDK

**Routing:**
- `go_router: ^14.0.0` - Declarative routing
- `app_links: ^6.4.1` - Deep linking support

**Storage & Security:**
- `flutter_secure_storage: ^9.0.0` - Encrypted key-value storage
- `shared_preferences: ^2.0.15` - Simple key-value storage

**UI & UX:**
- `flutter_screenutil: ^5.9.0` - Responsive design (scaling)
- `shimmer: ^3.0.0` - Loading placeholders
- `marquee: ^2.2.0` - Scrolling text
- `pretty_qr_code: ^3.5.0` - QR code generation
- `mobile_scanner: ^6.0.2` - QR code scanning
- `image_picker: ^1.0.7` - Image selection

**Error & Logging:**
- `sentry_flutter: ^9.10.0` - Error tracking and monitoring
- `logger: ^2.0.0` - Structured logging

**Utilities:**
- `infinite_scroll_pagination: ^4.0.0` - Paginated list views
- `easy_debounce: ^2.0.3` - Debounce utilities
- `html: ^0.15.4` - HTML parsing
- `connectivity_plus: ^6.0.0` - Network connectivity detection

**Environment:**
- `envied: ^1.3.2` - Compile-time environment variables

## Configuration

**Environment:**
- Environment files: `.env.dev`, `.env.staging`, `.env.prod`
- Configuration via `envied` package with compile-time variable injection
- Environment selection via `--dart-define=ENV_FILE=.env.dev`

**Build:**
- `pubspec.yaml` - Main dependency manifest
- `analysis_options.yaml` - Linting rules

**Code Generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Platform Requirements

**Development:**
- Flutter SDK 3.8.x
- Dart 3.8.x
- Android Studio / VS Code with Flutter extension

**Production:**
- Android APK/AAB
- iOS IPA
- Supabase backend (cloud)

---

*Stack analysis: 2026-03-05*

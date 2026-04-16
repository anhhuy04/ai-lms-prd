# Technology Stack

**Analysis Date:** 2026-04-14

## Languages

**Primary:**
- Dart 3.8.1+ — All application code, models, services, UI

**Secondary:**
- SQL — Database migrations in `db/migrations/`

## Runtime

**Environment:**
- Flutter SDK (requires Dart ^3.8.1)
- Android (primary mobile target)
- iOS (supported)

**Package Manager:**
- pub (Flutter/Dart built-in)
- Lockfile: `pubspec.lock` present

## Frameworks

**Core:**
- Flutter (uses-material-design: true) — UI framework
- `flutter_riverpod` ^2.5.1 — State management
- `go_router` ^14.0.0 — Declarative routing with type-safe navigation

**Code Generation:**
- `freezed` ^2.4.0 — Immutable model generation
- `json_serializable` ^6.9.5 — JSON serialization
- `riverpod_generator` ^2.3.0 — Provider code generation
- `retrofit_generator` ^9.7.0 — HTTP client code generation
- `envied_generator` ^1.1.1 — Compile-time environment variable injection

**Build/Dev:**
- `build_runner` ^2.4.0 — Code generation runner
  - Run: `flutter pub run build_runner build --delete-conflicting-outputs`
- `flutter_lints` ^5.0.0 — Flutter recommended lint rules
- `riverpod_lint` ^2.3.0 — Riverpod-specific lint rules
- `dependency_validator` ^5.0.3 — Unused/missing dependency checks
- `mocktail` ^1.0.0 — Mocking library for tests

## Key Dependencies

**Critical:**
- `supabase_flutter` ^2.0.0 — Backend-as-a-service (auth, database, realtime)
- `riverpod_annotation` ^2.6.1 — Annotations for `@riverpod` generator
- `freezed_annotation` ^2.4.0 — Annotations for Freezed models
- `envied` ^1.3.2 — Compile-time env var injection (obfuscated in binary)

**Networking:**
- `dio` ^5.4.0 — HTTP client for AI API calls
- `retrofit` >=4.8.0 <4.9.0 — Type-safe HTTP interfaces (pinned below 4.9.0 due to enum Parser.DartMappable incompatibility with retrofit_generator 9.x)
- `connectivity_plus` ^6.0.0 — Network connectivity detection

**UI:**
- `flutter_screenutil` ^5.9.0 — Responsive sizing (`.w`, `.h`, `.sp`, `.r`)
- `shimmer` ^3.0.0 — Loading placeholder animations
- `fl_chart` ^0.69.0 — Charts (radar, bar, line) for analytics screens
- `infinite_scroll_pagination` ^4.0.0 — Paginated list views
- `marquee` ^2.2.0 — Scrolling text for long titles
- `cupertino_icons` ^1.0.8 — iOS-style icons

**Storage:**
- `flutter_secure_storage` ^9.0.0 — Keychain/KeyStore for tokens and API keys
- `shared_preferences` ^2.0.15 — Non-sensitive user preferences
- `drift` ^2.30.1 + `drift_flutter` ^0.2.8 — Local SQLite relational database
  - Note: `drift_dev` is deferred due to dependency conflict with `retrofit_generator` (analyzer version mismatch)

**QR Code:**
- `pretty_qr_code` ^3.5.0 — QR code generation (via `QrHelper`)
- `mobile_scanner` ^6.0.2 — QR code scanning

**Other:**
- `app_links` ^6.4.1 — Deep link / universal link handling (compatible with supabase_flutter ^2.0.0)
- `sentry_flutter` ^9.10.0 — Crash and error reporting
- `logger` ^2.0.0 — Structured logging via `AppLogger`
- `image_picker` ^1.0.7 — Camera/gallery image selection
- `url_launcher` ^6.3.2 — Open URLs in browser/apps
- `html` ^0.15.4 — HTML parsing
- `easy_debounce` ^2.0.3 — Debounce for search/input
- `provider` ^6.0.0 — Legacy dependency; state management uses Riverpod exclusively
- `marionette_flutter` ^0.4.0 — AI agent MCP interaction (debug mode only)

## Configuration

**Environment:**
- Managed via `envied` + `.env.*` files (compile-time injection, values obfuscated in binary)
- Switch environment at build time: `--dart-define=ENV_FILE=.env.dev|.env.staging|.env.prod`
- Config class: `lib/core/env/env.dart` (generated: `lib/core/env/env.g.dart`)
- Required env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`, `AI_API_BASE_URL`, `AI_API_KEY`, `GEMINI_API_KEY`
- `.env.dev` is the default when `ENV_FILE` is not specified

**Build:**
- `analysis_options.yaml` — Lint config, extends `package:flutter_lints/flutter.yaml`
- `flutter_launcher_icons` ^0.13.1 — App icon from `assets/icon/logo_app.png`
- Dependency override: `analyzer_plugin: ^0.13.0` (keeps build_runner working with Dart 3.8.x analyzer APIs)

## Platform Requirements

**Development:**
- Dart SDK ^3.8.1
- `build_runner` must be run after any Freezed/Riverpod/Retrofit model change
- `.env.dev` file must exist at project root with valid Supabase and AI credentials

**Production:**
- Android (primary) — encrypted shared preferences via flutter_secure_storage
- iOS (supported) — Keychain access configured (`first_unlock_this_device`)
- Supabase cloud project (PostgreSQL + Auth + Realtime)

---

*Stack analysis: 2026-04-14*

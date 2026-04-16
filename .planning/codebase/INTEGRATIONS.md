# External Integrations

**Analysis Date:** 2026-04-14

## APIs & External Services

**AI / LLM:**
- Google Gemini API — AI question generation, answer feedback, analytics grading
  - SDK/Client: `dio` (direct HTTP, no SDK)
  - Base URL: `https://generativelanguage.googleapis.com/v1beta`
  - Endpoint pattern: `/models/{model}:generateContent`
  - Default model: `gemini-1.5-flash`
  - Auth: `GEMINI_API_KEY` (compile-time via `Env.geminiApiKey`; runtime override via `ApiKeyService`)
  - Service: `lib/core/services/ai_service.dart`

- Groq API — Alternative LLM provider (OpenAI-compatible chat completions)
  - SDK/Client: `dio` (direct HTTP)
  - Base URL: `https://api.groq.com/openai/v1/chat/completions`
  - Default model: `llama-3.1-8b-instant`
  - Auth: stored in `flutter_secure_storage` key `groq_api_key` (user-provided at runtime)
  - Service: `lib/core/services/api_key_service.dart`

- Ollama — Local LLM (self-hosted, teacher device)
  - Base URL: user-configured at runtime (no default; must enter manually)
  - Default model: `mistral`
  - Auth: none (local network)
  - Priority: Ollama first → fallback to Groq
  - Processor: `lib/core/services/teacher_ai_queue_processor.dart`

**Error Reporting:**
- Sentry — Crash reporting and error tracking
  - SDK: `sentry_flutter` ^9.10.0
  - Auth: `SENTRY_DSN` (compile-time via `Env.sentryDsn`, obfuscated)
  - Service: `lib/core/services/error_reporting_service.dart`
  - Skipped in dev if DSN is empty (app runs without Sentry)

## Data Storage

**Databases:**
- Supabase (PostgreSQL) — Primary remote database for all app data
  - Client: `supabase_flutter` ^2.0.0 (`SupabaseClient`)
  - Connection: `SUPABASE_URL` + `SUPABASE_ANON_KEY` (compile-time via `Env`)
  - Initialization: `lib/core/services/supabase_service.dart` → called in `main.dart`
  - Base datasource: `lib/data/datasources/supabase_datasource.dart` (`BaseTableDataSource`)
  - RLS enforced on all tables; uses `(select auth.uid())` pattern
  - Realtime subscriptions used for AI queue polling (`ai_queue` table)
  - Migrations: `db/migrations/` (SQL files numbered by phase, applied via Supabase MCP)

- Drift (SQLite) — Local relational database
  - Packages: `drift` ^2.30.1 + `drift_flutter` ^0.2.8
  - Note: `drift_dev` is deferred (dependency conflict with `retrofit_generator`)
  - Used for offline-capable local data storage

**Secure Storage:**
- `flutter_secure_storage` ^9.0.0 — API keys and auth tokens at rest
  - Android: `encryptedSharedPreferences: true`
  - iOS: `KeychainAccessibility.first_unlock_this_device`
  - Service: `lib/core/services/secure_storage_service.dart`
  - Also used directly in `lib/core/services/api_key_service.dart` for runtime AI keys

**File Storage:**
- `image_picker` ^1.0.7 — Local camera/gallery selection
- No cloud file storage integration detected (Supabase Storage not used)

**Caching:**
- `shared_preferences` ^2.0.15 — Non-sensitive user preferences
- In-memory cache in `ProfileMetadataService` (`lib/core/services/profile_metadata_service.dart`)

## Authentication & Identity

**Auth Provider:**
- Supabase Auth — Email/password authentication with JWT tokens
  - Implementation: built into `supabase_flutter`, accessed via `Supabase.instance.client.auth`
  - Session persistence: handled automatically by Supabase SDK
  - RBAC roles: `admin`, `teacher`, `student` — enforced via GoRouter guards
  - Route guards: `lib/core/routes/route_guards.dart`

**API Key Management (Runtime):**
- Users can supply their own AI API keys without rebuilding the app
- Keys stored in Supabase profile metadata (primary) or `flutter_secure_storage` (fallback)
- Service: `lib/core/services/api_key_service.dart`
- Supported providers: `gemini`, `groq`, `ollama`

## Monitoring & Observability

**Error Tracking:**
- Sentry (`sentry_flutter` ^9.10.0)
  - Captures Flutter framework errors and unhandled Dart exceptions
  - Breadcrumbs for user actions
  - User context (userId, email) attached to events
  - DSN: `SENTRY_DSN` env var

**Logs:**
- `logger` ^2.0.0 via `AppLogger` wrapper (`lib/core/utils/app_logger.dart`)
- Debug-mode agent logging writes to `d:\code\..\.cursor\debug.log` on Windows only (in `supabase_service.dart`)
- `AppLogger.info/error/warning` — use instead of `print()`

**Connectivity:**
- `connectivity_plus` ^6.0.0 — Pre-flight connectivity check before Supabase init
- Service: `lib/core/services/network_service.dart`

## CI/CD & Deployment

**Hosting:**
- Supabase cloud (database, auth, edge functions)
- Android APK (mobile app distribution — no Play Store automation detected)

**CI Pipeline:**
- Not detected in repository

## Environment Configuration

**Required env vars (in `.env.dev` / `.env.staging` / `.env.prod`):**
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Supabase anonymous/public key (obfuscated in binary)
- `SENTRY_DSN` — Sentry project DSN (obfuscated; empty string disables Sentry)
- `AI_API_BASE_URL` — Generic AI API base URL (legacy/fallback)
- `AI_API_KEY` — Generic AI API key (obfuscated)
- `GEMINI_API_KEY` — Google Gemini API key (obfuscated)

**Secrets location:**
- Compile-time: `.env.*` files at project root (not committed — gitignored)
- Runtime user keys: Supabase profile metadata table + `flutter_secure_storage` fallback

## Deep Links & Callbacks

**Incoming Deep Links:**
- Handled via `app_links` ^6.4.1
- Service: `lib/core/services/deep_link_service.dart`
- Routes parsed and forwarded to GoRouter after app is ready
- Used for Supabase Auth OAuth callbacks and custom URL scheme navigation

**Outgoing:**
- `url_launcher` ^6.3.2 — Opens external URLs in system browser

## AI Queue Architecture

**Background Processing:**
- `ai_queue` Supabase table — job queue for async AI grading/feedback tasks
- `lib/core/services/teacher_ai_queue_processor.dart` — polls and processes queue items
- Request types: `feedback` (per-answer AI feedback), `analysis` (session analytics), `score` (deferred)
- Provider: `TeacherAiQueueProvider` manages lifecycle
- Fallback chain: Ollama (local) → Groq (cloud) → error logged silently

---

*Integration audit: 2026-04-14*

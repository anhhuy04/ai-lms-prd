# External Integrations

**Analysis Date:** 2026-03-05

## APIs & External Services

**AI/LLM Providers:**
- **Google Gemini API** - AI question generation
  - SDK/Client: Direct HTTP via Dio (gemini-1.5-flash default)
  - API Key: `Env.geminiApiKey` + runtime storage via `ApiKeyService`
  - Default model: `gemini-1.5-flash`

- **Groq API** - Alternative AI provider (OpenAI-compatible)
  - SDK/Client: Direct HTTP via Dio (llama-3.1-8b-instant default)
  - API Key: Runtime storage via `ApiKeyService`
  - Default model: `llama-3.1-8b-instant`

**API Key Management:**
- Runtime storage via `ApiKeyService` with priority:
  1. Profile metadata (Supabase database with cache)
  2. Flutter Secure Storage (AES-256)
  3. Environment file (.env)

## Data Storage

**Database:**
- **Supabase (PostgreSQL)**
  - Connection: `Env.supabaseUrl` + `Env.supabaseAnonKey`
  - Client: `supabase_flutter` SDK
  - Tables: profiles, classes, questions, assignments, submissions, etc.
  - RLS: Enabled on all tables with role-based policies

**Local Database:**
- **Drift (SQLite)**
  - ORM: `drift` package
  - Purpose: Local caching and offline support

**Secure Storage:**
- **Flutter Secure Storage**
  - Platform: Android (EncryptedSharedPreferences), iOS (Keychain)
  - Purpose: API keys, auth tokens

**Simple Storage:**
- **SharedPreferences**
  - Purpose: App settings, non-sensitive flags

## Authentication & Identity

**Auth Provider:**
- **Supabase Auth** (built-in)
  - Implementation: Email/password, session management
  - Token storage: Flutter Secure Storage
  - Service: `lib/core/services/supabase_service.dart`

## Monitoring & Observability

**Error Tracking:**
- **Sentry Flutter** - `sentry_flutter: ^9.10.0`
  - DSN: `Env.sentryDsn`
  - Features: Crash reporting, breadcrumbs, user context
  - Sample rates: 100% dev, 10% prod

**Logging:**
- **Logger** package - Structured logging via `AppLogger`
- Debug logs: File-based on Windows desktop (`debug.log`)

**Connectivity:**
- **Connectivity Plus** - Network status detection

## CI/CD & Deployment

**Hosting:**
- **Supabase** - Cloud PostgreSQL + Auth + Storage + Edge Functions
- **Firebase** - (in progress) Push notifications, analytics

**Build:**
- Flutter build system (Android APK/AAB, iOS IPA)

## Environment Configuration

**Required env vars (via envied):**
| Variable | Purpose | Security |
|----------|---------|----------|
| `SUPABASE_URL` | Database URL | Public |
| `SUPABASE_ANON_KEY` | Anonymous key | Obfuscated |
| `SENTRY_DSN` | Error tracking | Obfuscated |
| `GEMINI_API_KEY` | AI generation | Obfuscated |
| `AI_API_KEY` | Generic AI API | Obfuscated |
| `AI_API_BASE_URL` | Custom AI endpoint | Public |

**Environment file selection:**
```bash
flutter run --dart-define=ENV_FILE=.env.dev
flutter run --dart-define=ENV_FILE=.env.staging
flutter run --dart-define=ENV_FILE=.env.prod
```

## Webhooks & Callbacks

**Incoming:**
- Deep links via `app_links` package
- Supabase Realtime subscriptions (future)

**Outgoing:**
- None currently configured

---

*Integration audit: 2026-03-05*

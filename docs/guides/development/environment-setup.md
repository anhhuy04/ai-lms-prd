# Environment Configuration Guide

This guide explains how to set up and use environment variables in the AI LMS project using `envied`.

## Overview

The project uses `envied` for compile-time type-safe environment variable management. This ensures:
- ✅ **Type Safety** - Compile-time validation of environment variables
- ✅ **Security** - Sensitive keys are obfuscated in the compiled binary
- ✅ **No Runtime Overhead** - Values are embedded at build time
- ✅ **Multiple Environments** - Support for dev, staging, and production

## Setup Instructions

### 1. Install Dependencies

Dependencies are already added to `pubspec.yaml`. Run:

```bash
flutter pub get
```

### 2. Create Environment Files

Create the following files in the project root (they are gitignored):

#### `.env.dev` (Development)
```env
SUPABASE_URL=https://vazhgunhcjdwlkbslroc.supabase.co
SUPABASE_ANON_KEY=your-dev-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-dev-service-role-key-here
SENTRY_DSN=your-dev-sentry-dsn-here
```

#### `.env.staging` (Staging)
```env
SUPABASE_URL=https://your-staging-project-id.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-staging-service-role-key-here
SENTRY_DSN=your-staging-sentry-dsn-here
```

#### `.env.prod` (Production)
```env
SUPABASE_URL=https://your-production-project-id.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key-here
SENTRY_DSN=your-production-sentry-dsn-here
```

**Important:** 
- Never commit these files to version control
- Use `.env.example` as a template (it's safe to commit)
- Replace placeholder values with your actual Supabase credentials

### 3. Generate Environment Classes

After creating your `.env` files, generate the Dart code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This creates `lib/core/env/env.g.dart` with the actual values.

### 4. Using Environment Variables

Access environment variables through the `Env` class:

```dart
import 'package:ai_mls/core/env/env.dart';

// Access Supabase URL
final url = Env.supabaseUrl;

// Access Supabase anon key
final anonKey = Env.supabaseAnonKey;
```

## Running with Different Environments

### Development (Default)
```bash
flutter run
# or explicitly:
flutter run --dart-define=ENV_FILE=.env.dev
```

### Staging
```bash
flutter run --dart-define=ENV_FILE=.env.staging
```

### Production
```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Building for Different Environments

### Android
```bash
# Development
flutter build apk --dart-define=ENV_FILE=.env.dev

# Staging
flutter build apk --dart-define=ENV_FILE=.env.staging

# Production
flutter build apk --dart-define=ENV_FILE=.env.prod
```

### iOS
```bash
# Development
flutter build ios --dart-define=ENV_FILE=.env.dev

# Staging
flutter build ios --dart-define=ENV_FILE=.env.staging

# Production
flutter build ios --dart-define=ENV_FILE=.env.prod
```

## CI/CD Integration

For CI/CD pipelines, you can pass environment variables directly:

```bash
flutter build apk \
  --dart-define=ENV_FILE=.env.prod \
  --dart-define-from-file=.env.prod
```

Or use environment variables from your CI system:

```yaml
# Example GitHub Actions
- name: Build APK
  run: |
    echo "${{ secrets.SUPABASE_URL }}" > .env.prod
    echo "${{ secrets.SUPABASE_ANON_KEY }}" >> .env.prod
    flutter build apk --dart-define=ENV_FILE=.env.prod
```

## Security Best Practices

1. **Never Commit Secrets**
   - All `.env*` files are in `.gitignore`
   - Only commit `.env.example` as a template

2. **Obfuscation**
   - Sensitive fields use `obfuscate: true` in the `Env` class
   - This makes keys harder to extract from the binary (not perfect security)

3. **Service Role Key**
   - The `SUPABASE_SERVICE_ROLE_KEY` should **NEVER** be used in client-side code
   - It's included in the env class for completeness but should only be used server-side
   - Client-side code should only use the anon key

4. **Environment Separation**
   - Use different Supabase projects for dev/staging/prod
   - Never use production keys in development

## Troubleshooting

### Error: "Failed to initialize Supabase"
- Check that your `.env` file exists and has correct values
- Verify the file path matches the `ENV_FILE` dart-define
- Run `flutter pub run build_runner build` to regenerate env.g.dart

### Error: "Undefined name '_Env'"
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Ensure your `.env` file exists and has all required variables

### Values Not Updating
- Delete `lib/core/env/env.g.dart`
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Ensure you're using the correct `--dart-define=ENV_FILE` flag

## File Structure

```
project_root/
├── .env.dev              # Development environment (gitignored)
├── .env.staging          # Staging environment (gitignored)
├── .env.prod             # Production environment (gitignored)
├── .env.example          # Template file (safe to commit)
└── lib/
    └── core/
        └── env/
            ├── env.dart          # Envied class definition
            └── env.g.dart        # Generated file (gitignored)
```

## Related Documentation

- [envied Package Documentation](https://pub.dev/packages/envied)
- [Tech Stack Upgrade Plan](../TECH_STACK_UPGRADE_PLAN.md)
- [Supabase Service](../lib/core/services/supabase_service.dart)

# Quick Setup Guide: Environment Configuration

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Create Environment Files

Create these files in the project root with your actual Supabase credentials:

### `.env.dev` (Development)
```env
SUPABASE_URL=https://vazhgunhcjdwlkbslroc.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhemhndW5oY2pkd2xrYnNscm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxMTI3NTksImV4cCI6MjA4MDY4ODc1OX0.D-O3FbXF46mVEga152RmumAkmqS54_A-L7tFa6UBi0c
SUPABASE_SERVICE_ROLE_KEY=your-dev-service-role-key-here
```

### `.env.staging` (Staging)
```env
SUPABASE_URL=https://your-staging-project-id.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-staging-service-role-key-here
```

### `.env.prod` (Production)
```env
SUPABASE_URL=https://your-production-project-id.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key-here
```

**Note:** These files are already in `.gitignore` and will NOT be committed.

## Step 3: Generate Environment Classes

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `lib/core/env/env.g.dart` with your environment variables.

## Step 4: Run the App

### Development (Default)
```bash
flutter run
```

### Staging
```bash
flutter run --dart-define=ENV_FILE=.env.staging
```

### Production
```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Verification

After setup, your `SupabaseService` will automatically use the environment variables from the `Env` class. The hardcoded credentials have been removed from the code.

## Troubleshooting

If you see errors about missing `envied` package or `env.g.dart`:
1. Run `flutter pub get` to install dependencies
2. Create your `.env.dev` file with actual values
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`

For more details, see: [docs/guides/development/environment-setup.md](docs/guides/development/environment-setup.md)

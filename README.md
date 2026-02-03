# AI LMS (Learning Management System)

Flutter application cho hệ thống quản lý học tập, sử dụng Supabase backend.

## Tech Stack

- **State Management:** Riverpod với `@riverpod` generator
- **Routing:** GoRouter 14+
- **Data Models:** Freezed + JsonSerializable (immutable)
- **Local Storage:** flutter_secure_storage (sensitive), SharedPreferences (non-sensitive)
- **Local Database:** Drift (deferred due to dependency conflicts)
- **Networking:** Dio + Retrofit
- **Environment:** Envied (compile-time secrets)
- **Error Reporting:** Sentry
- **Logging:** Logger (via AppLogger wrapper)
- **UI:** flutter_screenutil (responsive), Design Tokens
- **Code Generation:** build_runner

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1+
- Dart 3.8.1+

### Setup

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd AI_LMS_PRD
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Setup environment variables:**
   - Copy `.env.dev.example` to `.env.dev` (nếu có)
   - Hoặc tạo `.env.dev` với các biến môi trường cần thiết (xem `docs/guides/development/environment-setup.md`)

4. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   > Xem `docs/guides/development/code-generation-workflow.md` để biết thêm về code generation.

5. **Run app:**
   ```bash
   flutter run
   ```

## Code Generation

Project này sử dụng `build_runner` để generate code cho:
- Freezed entities (`.freezed.dart`, `.g.dart`)
- Riverpod providers (`.g.dart`)
- Envied environment config (`env.g.dart`)
- Retrofit API clients (nếu có)

**Lệnh cơ bản:**
```bash
# Build một lần
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (tự động generate khi có thay đổi)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**⚠️ Quan trọng:** Sau khi thêm/sửa entities, providers, hoặc env config, LUÔN chạy build_runner trước khi commit code.

Xem chi tiết tại: `docs/guides/development/code-generation-workflow.md`

## Documentation

- **Environment Setup:** `docs/guides/development/environment-setup.md`
- **Code Generation:** `docs/guides/development/code-generation-workflow.md`
- **Freezed Migration:** `docs/guides/development/freezed-migration-guide.md`
- **QR Code Usage:** `docs/guides/development/qr-code-usage.md`
- **Tech Stack Plan:** `docs/TECH_STACK_UPGRADE_PLAN.md`

## Project Structure

```
lib/
├── core/              # Core utilities, services, constants
│   ├── constants/     # Design tokens, constants
│   ├── env/           # Environment configuration (Envied)
│   ├── routes/        # GoRouter configuration
│   ├── services/      # Core services (AppLogger, Sentry, etc.)
│   └── utils/         # Utility functions
├── data/              # Data layer (Clean Architecture)
│   ├── datasources/   # Data sources (Supabase, API)
│   └── repositories/  # Repository implementations
├── domain/            # Domain layer (Clean Architecture)
│   ├── entities/      # Business entities (Freezed)
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Use cases
└── presentation/      # Presentation layer (Clean Architecture)
    ├── providers/     # Riverpod providers/notifiers
    ├── views/         # UI screens
    └── widgets/       # Reusable widgets
```

## Development Guidelines

- **State Management:** Chỉ dùng Riverpod với `@riverpod` generator (không dùng Provider/ChangeNotifier cho code mới)
- **Logging:** Dùng `AppLogger`, KHÔNG dùng `print()`
- **Routing:** Dùng GoRouter, không dùng Navigator.pushNamed
- **Models:** Dùng Freezed + JsonSerializable cho entities
- **Comments:** Viết comment bằng tiếng Việt
- **Code Style:** Tuân thủ `.cursor/.cursorrules` và `analysis_options.yaml`

## Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Build

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/documentation/go_router/latest/)
- [Freezed Documentation](https://pub.dev/packages/freezed)

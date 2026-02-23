# 10 — Tech Stack Standards

## Mandatory Libraries (Never substitute without approval)

| Category | Package | Notes |
|---|---|---|
| State | `riverpod` + `@riverpod` generator | Never use Provider/ChangeNotifier |
| Routing | `go_router` v14+ | Declarative, type-safe |
| Models | `freezed` + `json_serializable` | Always immutable |
| Local DB | `drift` | Relational |
| Secure storage | `flutter_secure_storage` | Tokens/sensitive data |
| Networking | `dio` + `retrofit` | Interface-based API |
| Env secrets | `envied` | Compile-time only |
| Responsive UI | `flutter_screenutil` | All sizing |
| Loading UI | `shimmer` | List/page loading states |
| QR generate | `pretty_qr_code` | Via `QrHelper` wrapper only |
| QR scan | `mobile_scanner` v6.0.2 | `MobileScannerController` |
| Image picker | `image_picker` v1.0.7 | For QR gallery scan |
| Error reporting | `sentry_flutter` | All critical flows |
| Logging | `logger` | Via `AppLogger` wrapper, never `print()` |

## Sentry — Mandatory Reporting Flows
Always report to Sentry on error in:
- Auth flows (login / register / logout / session restore)
- Data writes to Supabase (create / update / delete)
- Crash / unhandled exceptions
- DataSource/Repository boundary errors that block user

## MCP Auto-fetch Rule
Before implementing any feature using libs above: if knowledge may be outdated (>2025), use Fetch MCP to read latest docs:
- Riverpod: `https://riverpod.dev`
- GoRouter: `https://pub.dev/packages/go_router`
- Drift: `https://drift.simonbinder.eu`

## Code Generation
Run after modifying Freezed / JsonSerializable / Envied:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Adding New Libraries
1. Add to `pubspec.yaml` FIRST
2. Run `flutter pub get`
3. Use Fetch/Context7 MCP to read examples
4. Then write code
5. Do NOT self-add libraries not in this stack — ask user

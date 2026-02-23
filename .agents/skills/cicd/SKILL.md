---
name: cicd
description: "Kích hoạt khi viết cấu hình CI/CD, GitHub Actions, Fastlane, hoặc quy trình build/deploy tự động cho ứng dụng Flutter."
---

# Kỹ năng: CI/CD cho Flutter

## Ưu tiên: P1 (CAO)

Tự động hóa kiểm tra chất lượng code, testing và deployment để ngăn regression và tăng tốc delivery.

## Các bước Pipeline cốt lõi

1. **Cài đặt môi trường**: Dùng Flutter channel `stable`. Cache dependencies (`pub`, `gradle`, `cocoapods`).
2. **Static Analysis**: Bắt buộc `flutter analyze` và `dart format`. Fail nếu có warning ở strict mode.
3. **Testing**: Chạy unit, widget, integration tests. Upload coverage report (vd: Codecov).
4. **Build**:
   - **Android**: Build App Bundle (`.aab`) cho Play Store.
   - **iOS**: Sign và build `.ipa` (yêu cầu macOS runner).
5. **Deployment (CD)**: Upload tự động lên TestFlight/Play Console qua Fastlane hoặc Codemagic.

## Best Practices

- **Timeout**: Luôn đặt `timeout-minutes` (vd: 30 phút) để tránh tốn chi phí khi job bị treo.
- **Fail Fast**: Chạy Analyze/Format TRƯỚC Tests/Builds.
- **Secrets**: Không commit keys. Dùng GitHub Secrets hoặc secure vault cho `keystore.jks` và `.p8` certs.
- **Versioning**: Tự động bump version dựa trên git tags hoặc semantic version script.
- **Môi trường**: Dùng `envied` cho compile-time secrets, không dùng `.env` file trong CI.

## Ví dụ GitHub Actions cơ bản

```yaml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Format check
        run: dart format --output=none --set-exit-if-changed .

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4

  build-android:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true
      - name: Build AAB
        run: flutter build appbundle --release
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
```

## Quản lý Secrets

```bash
# Không bao giờ commit các file này
*.jks
*.p8
*.p12
.env
google-services.json   # Dùng GitHub Secret thay thế
GoogleService-Info.plist
```

## Liên quan

flutter/testing | dart/tooling | flutter/architecture

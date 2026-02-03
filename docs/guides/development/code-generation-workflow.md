# Code Generation Workflow Guide

> Hướng dẫn sử dụng build_runner để generate code cho các thư viện: Freezed, JsonSerializable, Riverpod Generator, Envied, Retrofit.

---

## Tổng quan

Dự án này sử dụng `build_runner` để generate code cho các thư viện:

- **Freezed** + **JsonSerializable**: Entities, Params (immutable models với JSON serialization)
- **Riverpod Generator** (`@riverpod`): Providers, Notifiers
- **Envied Generator**: Environment variables (compile-time secrets)
- **Retrofit Generator**: API clients (nếu dùng retrofit)

---

## Lệnh cơ bản

### Build một lần (clean build)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Khi nào dùng:**
- Sau khi thêm/sửa entities, providers, env config
- Khi cần clean và regenerate toàn bộ
- Sau khi merge code từ branch khác có thay đổi generated files

**Lưu ý:**
- `--delete-conflicting-outputs` sẽ tự động xóa và regenerate các file bị conflict
- Lệnh này có thể mất 20-40 giây tùy số lượng file cần generate

---

### Watch mode (tự động generate khi có thay đổi)

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Khi nào dùng:**
- Khi đang phát triển và thường xuyên sửa entities/providers
- Giúp tiết kiệm thời gian (không cần chạy lại lệnh mỗi lần sửa)

**Cách dừng:**
- Nhấn `Ctrl+C` trong terminal

---

### Clean build (xóa cache và rebuild)

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Khi nào dùng:**
- Khi gặp lỗi kỳ lạ với generated code
- Sau khi upgrade packages liên quan đến code generation
- Khi build_runner báo lỗi không rõ nguyên nhân

---

## Quy trình làm việc khuyến nghị

### 1. Sau khi thêm/sửa Entity (Freezed + JsonSerializable)

```bash
# 1. Sửa file entity (ví dụ: lib/domain/entities/profile.dart)
# 2. Chạy build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verify không có lỗi
flutter analyze lib/domain/entities/profile.dart
```

**File được generate:**
- `lib/domain/entities/profile.freezed.dart`
- `lib/domain/entities/profile.g.dart`

---

### 2. Sau khi thêm/sửa Provider (Riverpod Generator)

```bash
# 1. Sửa file provider (ví dụ: lib/presentation/providers/auth_notifier.dart)
# 2. Chạy build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verify không có lỗi
flutter analyze lib/presentation/providers/auth_notifier.dart
```

**File được generate:**
- `lib/presentation/providers/auth_notifier.g.dart`

---

### 3. Sau khi thêm/sửa Environment Config (Envied)

```bash
# 1. Sửa file env (lib/core/env/env.dart)
# 2. Chạy build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verify file env.g.dart được tạo/cập nhật
```

**File được generate:**
- `lib/core/env/env.g.dart`

---

## Các generators được sử dụng

### 1. Freezed + JsonSerializable

**Vị trí:** `lib/domain/entities/*.dart`

**Annotations:**
- `@freezed` cho class
- `@JsonSerializable()` cho JSON
- `@JsonKey()` cho field mapping

**Ví dụ:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
```

---

### 2. Riverpod Generator (`@riverpod`)

**Vị trí:** `lib/presentation/providers/*.dart`

**Annotations:**
- `@riverpod` cho class Notifier
- `@Riverpod()` cho function providers

**Ví dụ:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<Profile?> build() async {
    return null;
  }

  Future<void> signIn(String email, String password) async {
    // ...
  }
}
```

---

### 3. Envied Generator

**Vị trí:** `lib/core/env/env.dart`

**Annotations:**
- `@Envied()` cho class
- `@EnviedField()` cho field

**Ví dụ:**
```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _Env.supabaseUrl;
}
```

---

## Xử lý lỗi thường gặp

### Lỗi: "Conflicting outputs"

**Nguyên nhân:** File generated đã tồn tại và có conflict

**Giải pháp:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Lỗi: "Target of URI doesn't exist"

**Nguyên nhân:** File `.g.dart` hoặc `.freezed.dart` chưa được generate

**Giải pháp:**
1. Kiểm tra có import `part` statement chưa:
   ```dart
   part 'file_name.g.dart';
   part 'file_name.freezed.dart'; // nếu dùng Freezed
   ```
2. Chạy build_runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

### Lỗi: Analyzer version mismatch

**Nguyên nhân:** Conflict giữa các generators (ví dụ: retrofit_generator vs drift_dev)

**Giải pháp hiện tại:**
- Đã pin `retrofit: ">=4.8.0 <4.9.0"` trong `pubspec.yaml`
- Đã override `analyzer_plugin: ^0.13.0` trong `dependency_overrides`
- `drift_dev` đang được defer do conflict

**Lưu ý:** Khi upgrade packages, cần kiểm tra compatibility

---

### Lỗi: "Invalid annotation target"

**Nguyên nhân:** Thường là false positive với Freezed

**Giải pháp:**
- Thêm `// ignore_for_file: invalid_annotation_target` ở đầu file nếu cần
- Đảm bảo annotations đặt đúng vị trí (trên field, không phải param trong constructor Freezed)

---

## Best Practices

### 1. **KHÔNG** chỉnh sửa file generated trực tiếp

❌ **Sai:**
```dart
// lib/domain/entities/profile.g.dart (file generated)
// ĐỪNG sửa file này!
```

✅ **Đúng:**
- Chỉ sửa file gốc (`.dart`)
- Chạy build_runner để regenerate

---

### 2. **KHÔNG** commit file generated vào git (nếu có .gitignore đúng)

File generated nên được ignore (trừ một số trường hợp đặc biệt):

```gitignore
# File generated thường được ignore
*.g.dart
*.freezed.dart
env.g.dart
```

**Lưu ý:** Trong project này, một số file generated vẫn được commit để đảm bảo code compile được ngay. Hãy kiểm tra `.gitignore` trước khi commit.

---

### 3. **LUÔN** chạy build_runner sau khi:
- Thêm/sửa entity
- Thêm/sửa provider với `@riverpod`
- Thêm/sửa env config
- Pull code từ branch khác có thay đổi entities/providers
- Upgrade packages liên quan đến code generation

---

### 4. **KIỂM TRA** bằng `flutter analyze` sau khi generate

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Verify không có lỗi
flutter analyze
```

---

## Scripts tiện ích (nếu cần)

Có thể tạo script trong `package.json` hoặc batch file để tiện chạy:

### Windows (build_runner.bat)
```batch
@echo off
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

### Linux/Mac (build_runner.sh)
```bash
#!/bin/bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

---

## Tài liệu tham khảo

- [build_runner documentation](https://pub.dev/packages/build_runner)
- [Freezed documentation](https://pub.dev/packages/freezed)
- [Riverpod Generator documentation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Envied documentation](https://pub.dev/packages/envied)
- [JsonSerializable documentation](https://pub.dev/packages/json_serializable)

---

## Checklist khi gặp vấn đề

- [ ] Đã chạy `flutter pub get`?
- [ ] Đã chạy `flutter pub run build_runner clean`?
- [ ] File gốc có đúng annotations (`@freezed`, `@riverpod`, etc.)?
- [ ] File gốc có `part` statement?
- [ ] Đã dùng `--delete-conflicting-outputs`?
- [ ] Packages trong `pubspec.yaml` đã đúng version?
- [ ] `dependency_overrides` đã được set đúng?
- [ ] Đã chạy `flutter analyze` để kiểm tra lỗi?

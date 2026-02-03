# Freezed Migration Guide

**Ngày tạo:** 2026-01-17  
**Mục đích:** Hướng dẫn migration entities sang Freezed với json_serializable

---

## 📚 Tổng Quan Freezed

### Freezed là gì?
Freezed là một code generation package giúp tạo immutable classes với:
- **Immutability:** Tất cả fields đều `final`, không thể thay đổi sau khi tạo
- **copyWith:** Tự động generate method để tạo instance mới với một số fields thay đổi
- **toString, ==, hashCode:** Tự động generate
- **Union types:** Hỗ trợ sealed classes cho pattern matching
- **JSON serialization:** Tích hợp với `json_serializable` để generate `fromJson/toJson`

### Lợi ích:
1. **Type Safety:** Compile-time safety với immutable data
2. **Performance:** Không cần deep copy, chỉ tạo instance mới khi cần
3. **Maintainability:** Code generation giảm boilerplate code
4. **Testing:** Dễ test với immutable data

---

## 🔧 Setup

### Dependencies (đã có trong pubspec.yaml):
```yaml
dependencies:
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  freezed: ^2.4.0
  json_serializable: ^6.9.5
  build_runner: ^2.4.0
```

### Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Patterns & Best Practices

### 1. Basic Freezed Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? fullName,
    required String role,
    String? avatarUrl,
    String? bio,
    String? phone,
    String? gender,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
```

### 2. JSON Serialization với Custom Field Names

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    required String role,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? phone,
    String? gender,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
```

### 3. Default Values

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    @Default('student') String role, // Giá trị mặc định
    String? fullName,
  }) = _Profile;
}
```

### 4. Custom Methods

```dart
@freezed
class Profile with _$Profile {
  const Profile._(); // Private constructor cho custom methods
  
  const factory Profile({
    required String id,
    String? fullName,
  }) = _Profile;

  // Custom getter
  String get displayName => fullName ?? 'Người dùng';
  
  // Custom method
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}
```

### 5. Union Types (Sealed Classes)

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated(Profile user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
}
```

---

## 🔄 Migration Strategy

### Bước 1: Convert Entity Class
1. Thêm imports: `freezed_annotation`, `json_annotation`
2. Thêm `part` directives cho generated files
3. Chuyển class thành `@freezed` class với `const factory`
4. Thêm `@JsonKey` annotations cho field names khác nhau
5. Thêm `fromJson` factory constructor

### Bước 2: Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 3: Update Usages
1. Thay `Profile(...)` → `Profile(...)` (giữ nguyên syntax)
2. Thay `profile.copyWith(...)` → `profile.copyWith(...)` (syntax giống nhau)
3. Thay `Profile.fromJson(...)` → `Profile.fromJson(...)` (syntax giống nhau)
4. Xóa manual `toJson()` nếu có, dùng generated `toJson()`

### Bước 4: Test
1. Test serialization/deserialization
2. Test copyWith
3. Test equality và hashCode
4. Verify không có breaking changes

---

## ⚠️ Lưu Ý Quan Trọng

1. **Immutability:** Tất cả fields phải là `final`, không thể thay đổi trực tiếp
2. **copyWith:** Luôn tạo instance mới, không modify instance cũ
3. **JSON Keys:** Sử dụng `@JsonKey(name: 'snake_case')` cho database fields
4. **Null Safety:** Freezed hỗ trợ null safety đầy đủ
5. **Performance:** Freezed classes rất nhẹ, không có overhead

---

## 📖 Tài Liệu Tham Khảo

- [Freezed Documentation](https://pub.dev/packages/freezed)
- [json_serializable Documentation](https://pub.dev/packages/json_serializable)
- [Freezed Examples](https://github.com/rrousselGit/freezed/tree/master/packages/freezed/example)

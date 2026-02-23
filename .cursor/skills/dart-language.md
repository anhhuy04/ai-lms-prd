---
name: dart-language
description: "Kích hoạt khi có câu hỏi về ngôn ngữ Dart 3 (Records, Pattern Matching, Sealed classes), Best Practices viết code, Static Analysis và Lints."
---

# Kỹ năng: Dart Language Patterns & Tooling

## 1. Dart 3 Features

### Records
Dùng Records để trả về nhiều giá trị từ một hàm mà không cần tạo class:
```dart
// ✅ Thay vì tạo class wrapper
(String name, int age) getUser() => ('Huy', 30);

// Destructuring
final (name, age) = getUser();
```

### Pattern Matching & Exhaustive Switch
```dart
// ✅ Switch expression (gán vào biến)
final label = switch (userRole) {
  UserRole.admin => 'Quản trị viên',
  UserRole.teacher => 'Giáo viên',
  UserRole.student => 'Học sinh',
};

// ✅ Pattern matching với type check
switch (exception) {
  case NetworkException(:final message) => showNetworkError(message),
  case UnauthorizedException() => redirectToLogin(),
  case ServerException(:final statusCode) => showServerError(statusCode),
}
```

### Sealed Classes — Dùng cho State Modeling (Riverpod)
Dùng `sealed` thay vì `abstract` để compiler enforce exhaustive switch:

```dart
// ✅ Sealed class cho UI state (không phải Bloc — project dùng Riverpod)
sealed class UploadState {}
class UploadIdle extends UploadState {}
class UploadInProgress extends UploadState { final double progress; UploadInProgress(this.progress); }
class UploadSuccess extends UploadState { final String url; UploadSuccess(this.url); }
class UploadFailed extends UploadState { final String error; UploadFailed(this.error); }

// Compiler báo lỗi nếu thiếu case
Widget buildUploadStatus(UploadState state) => switch (state) {
  UploadIdle() => const SizedBox.shrink(),
  UploadInProgress(:final progress) => LinearProgressIndicator(value: progress),
  UploadSuccess(:final url) => SuccessWidget(url: url),
  UploadFailed(:final error) => ErrorWidget(error: error),
};
```

> **Lưu ý**: Project dùng **Riverpod + AsyncNotifier**, không dùng Bloc/Cubit. Sealed class dùng cho custom state objects, không phải Event/State của Bloc.

## 2. Dart Best Practices

- **Const first**: Gắn `const` cho mọi constructor, widget, object nếu có thể. Analyzer sẽ báo `prefer_const_constructors`.
- **Tuyệt đối cấm** `dynamic` khi khai báo JSON. Phải dùng `Map<String, dynamic>`.
- **Ưu tiên `final`**: Tránh mutability không cần thiết — `final user = User(...)`.
- **Null safety**: Dùng `?.`, `??`, `!` có chủ đích. Không dùng `!` bừa bãi.
- **Extension methods**: Dùng để thêm utility vào type có sẵn thay vì tạo static helper class:

```dart
extension StringX on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
```

## 3. Auto-Formatting & Static Analysis

Bắt buộc trước khi commit:
```bash
flutter analyze          # Không được có warning/error
dart format .            # Format toàn bộ code
```

Không vi phạm cảnh báo xanh trong editor. Nếu có exception hợp lý, phải comment `// ignore: rule_name — lý do`.

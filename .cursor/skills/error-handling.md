---
name: error-handling
description: "Kích hoạt khi xử lý lỗi, exceptions, Sentry reporting, hiển thị error state trên UI, hoặc thiết kế error boundary cho Flutter app."
---

# Kỹ năng: Error Handling

## 1. Typed Exception Hierarchy

Dùng `sealed class` để định nghĩa exception hierarchy — compiler enforce exhaustive handling:

```dart
// lib/core/errors/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Không có kết nối mạng']);
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Phiên đăng nhập hết hạn');
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.field});
  final String? field;
}
```

## 2. Repository Layer — Bắt và Map Exception

```dart
@override
Future<ClassEntity> getClass(String id) async {
  try {
    final dto = await _datasource.getClass(id);
    return dto.toDomain();
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') throw NotFoundException('Không tìm thấy lớp học');
    throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
  } on SocketException {
    throw const NetworkException();
  } on TimeoutException {
    throw const NetworkException('Kết nối quá chậm, thử lại sau');
  } catch (e, st) {
    AppLogger.e('Unexpected error in getClass', error: e, stackTrace: st);
    Sentry.captureException(e, stackTrace: st);
    throw ServerException(e.toString());
  }
}
```

## 3. Notifier Layer — AsyncValue.guard

```dart
Future<void> loadClass(String id) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(
    () => ref.read(classRepositoryProvider).getClass(id),
  );
  // Nếu có lỗi, state = AsyncError(exception, stackTrace) tự động
}
```

## 4. UI Layer — Hiển thị Error State

```dart
// ✅ Dùng when() để handle tất cả states
classAsync.when(
  data: (classEntity) => ClassDetailView(classEntity: classEntity),
  loading: () => const ShimmerLoading(),
  error: (error, stackTrace) => _buildErrorState(error),
)

Widget _buildErrorState(Object error) {
  final message = switch (error) {
    NetworkException() => 'Không có kết nối mạng. Kiểm tra WiFi/4G.',
    UnauthorizedException() => 'Phiên đăng nhập hết hạn.',
    NotFoundException(:final message) => message,
    ServerException(:final message) => 'Lỗi server: $message',
    _ => 'Đã có lỗi xảy ra. Thử lại sau.',
  };

  return ErrorStateWidget(
    message: message,
    onRetry: () => ref.invalidate(classProvider(classId)),
  );
}
```

## 5. Sentry — Mandatory Reporting

Báo cáo Sentry bắt buộc cho các luồng sau:

```dart
// Auth flows
try {
  await _supabase.auth.signInWithPassword(email: email, password: password);
} catch (e, st) {
  await Sentry.captureException(e, stackTrace: st, hint: Hint.withMap({
    'flow': 'login',
    'email': email.substring(0, 3) + '***', // Không log full email
  }));
  rethrow;
}

// Data writes
try {
  await _supabase.from('assignments').insert(data);
} catch (e, st) {
  await Sentry.captureException(e, stackTrace: st);
  rethrow;
}
```

Các luồng BẮT BUỘC báo Sentry:
- Auth (login / register / logout / session restore)
- Data writes (create / update / delete)
- Crash / unhandled exceptions
- DataSource/Repository errors block user

## 6. Global Error Handler (main.dart)

```dart
void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 0.2;
      options.environment = Env.environment;
    },
    appRunner: () async {
      FlutterError.onError = (details) {
        AppLogger.e('Flutter error', error: details.exception, stackTrace: details.stack);
        Sentry.captureException(details.exception, stackTrace: details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.e('Platform error', error: error, stackTrace: stack);
        Sentry.captureException(error, stackTrace: stack);
        return true;
      };

      runApp(const ProviderScope(child: MyApp()));
    },
  );
}
```

## 7. AppLogger — Không dùng print()

```dart
// ✅ ĐÚNG
AppLogger.d('Debug message');
AppLogger.i('User logged in: ${user.id}');
AppLogger.w('Cache miss for key: $key');
AppLogger.e('Failed to load data', error: e, stackTrace: st);

// ❌ SAI
print('Debug message');
debugPrint('User logged in');
```

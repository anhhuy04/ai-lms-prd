---
name: networking
description: "Kích hoạt khi xây dựng tầng Network, gọi API, cấu hình interceptors, chặn lỗi mạng, xử lý Refresh Token bằng Dio và Retrofit."
---

# Kỹ năng: Networking & Gọi API

Tuân thủ các chuẩn sau khi thiết lập tầng Networking:

## 1. Cấu hình Retrofit & Dio

- Các API client BẮT BUỘC định nghĩa thông qua interface `@RestApi()` của Retrofit.
- Chạy `dart run build_runner build -d` để sinh file `.g.dart` sau mỗi lần sửa.
- HTTP Client duy nhất sử dụng là `Dio`. Không dùng package `http` thuần.

```dart
@RestApi()
abstract class CourseApiClient {
  factory CourseApiClient(Dio dio, {String baseUrl}) = _CourseApiClient;

  @GET('/courses')
  Future<List<CourseDto>> getCourses();

  @GET('/courses/{id}')
  Future<CourseDto> getCourseById(@Path('id') String id);
}
```

## 2. Error Handling — Typed Exceptions (không dùng dartz)

Dùng **typed exceptions + AsyncValue** của Riverpod thay vì `Either` từ `dartz`:

```dart
// core/errors/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Phiên đăng nhập hết hạn');
}
```

Repository bắt lỗi và throw typed exception:

```dart
@override
Future<List<CourseEntity>> getCourses() async {
  try {
    final dtos = await _apiClient.getCourses();
    return dtos.map((d) => d.toDomain()).toList();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) throw const UnauthorizedException();
    if (e.type == DioExceptionType.connectionTimeout) {
      throw const NetworkException('Không có kết nối mạng');
    }
    throw ServerException(e.message ?? 'Lỗi server', statusCode: e.response?.statusCode);
  }
}
```

Notifier dùng `AsyncValue.guard()` để bắt exception:

```dart
Future<void> loadCourses() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() => ref.read(courseRepositoryProvider).getCourses());
}
```

## 3. Auth Interceptors & Refresh Token

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);
  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(authTokenProvider);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _ref.read(authNotifierProvider.notifier).refreshToken();
        // Retry request với token mới
        final newToken = _ref.read(authTokenProvider);
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        // Refresh thất bại → logout
        await _ref.read(authNotifierProvider.notifier).logout();
      }
    }
    handler.next(err);
  }
}
```

## 4. Bảo mật truyền tải mạng

- Cấm lưu trữ keys/tokens trong source code. Dùng `envied` (compile-time) cho API keys.
- Tokens nhạy cảm lưu trong `flutter_secure_storage`, không dùng SharedPreferences.
- Nếu app yêu cầu bảo mật cao (e-wallet, y tế), hỏi ý kiến user về SSL Pinning (`dio_certificate_pinning`).
- Dùng `CancelToken` trong Dio cho search/fast-switching UI để tránh race condition:

```dart
CancelToken? _cancelToken;

Future<void> search(String query) async {
  _cancelToken?.cancel();
  _cancelToken = CancelToken();
  try {
    final results = await _apiClient.search(query, cancelToken: _cancelToken);
    state = AsyncData(results);
  } on DioException catch (e) {
    if (!CancelToken.isCancel(e)) state = AsyncError(e, e.stackTrace ?? StackTrace.current);
  }
}
```

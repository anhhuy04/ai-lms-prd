---
name: dependency-injection
description: "Kích hoạt khi cấu hình Dependency Injection, đăng ký providers, repositories, datasources với Riverpod. KHÔNG dùng GetIt/Injectable trong project này."
---

# Kỹ năng: Dependency Injection với Riverpod

Project này dùng **Riverpod** làm DI container duy nhất. KHÔNG dùng GetIt, Injectable, hoặc service locator.

## 1. Repository DI — Provider Pattern

Mỗi repository được expose qua một `@riverpod` provider:

```dart
// domain/repositories/i_class_repository.dart
abstract class IClassRepository {
  Future<List<ClassEntity>> getClasses();
}

// data/repositories/class_repository_impl.dart
class ClassRepositoryImpl implements IClassRepository {
  ClassRepositoryImpl(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<List<ClassEntity>> getClasses() async { ... }
}

// presentation/providers/class_repository_provider.dart
@riverpod
IClassRepository classRepository(ClassRepositoryRef ref) {
  return ClassRepositoryImpl(ref.watch(supabaseClientProvider));
}
```

## 2. Third-Party Dependencies — Provider Module

Các dependencies ngoại lai (Supabase, Dio, SecureStorage) khai báo trong `lib/core/providers/`:

```dart
// lib/core/providers/supabase_provider.dart
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

// lib/core/providers/dio_provider.dart
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(ref.watch(authInterceptorProvider));
  return dio;
}
```

## 3. Scope & Lifetime

| Loại | Cách khai báo | Lifetime |
|---|---|---|
| Singleton (app-wide) | `@Riverpod(keepAlive: true)` | Suốt vòng đời app |
| Auto-dispose (default) | `@riverpod` | Dispose khi không còn listener |
| Scoped (per-feature) | `ProviderScope(overrides: [...])` | Theo widget tree |

```dart
// Singleton — dùng cho Supabase, Dio, SecureStorage
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) => Supabase.instance.client;

// Auto-dispose — dùng cho feature providers
@riverpod
Future<List<ClassEntity>> classList(ClassListRef ref) async { ... }
```

## 4. Override cho Testing

```dart
// Trong test: override provider bằng mock
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      classRepositoryProvider.overrideWithValue(MockClassRepository()),
    ],
    child: const MyApp(),
  ),
);
```

## 5. Quy tắc bắt buộc

- LUÔN chạy `dart run build_runner build -d` sau khi thêm/sửa `@riverpod` annotation.
- KHÔNG import `get_it` hoặc `injectable` — không có trong tech stack.
- Trước khi tạo provider mới: `grep -r "myFeatureProvider" lib/` để tránh duplicate.
- Khởi tạo Supabase trong `main.dart` trước `runApp()`, không trong provider.

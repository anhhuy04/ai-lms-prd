# Riverpod Migration Guide

> Hướng dẫn migrate từ Provider/ChangeNotifier sang Riverpod với `@riverpod` generator.

---

## Tổng quan

Project này đã migrate từ Provider/ChangeNotifier pattern sang Riverpod với code generation (`@riverpod`). Guide này giải thích patterns và best practices.

---

## Pattern Mới: Riverpod với @riverpod Generator

### Notifier Pattern (AsyncNotifier)

Thay vì `ChangeNotifier`, dùng `AsyncNotifier` với `AsyncValue`:

```dart
// lib/presentation/providers/auth_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<Profile?> build() async {
    return null; // Initial state
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.signIn(email, password);
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
```

**Key Points:**
- `@riverpod` annotation để codegen
- `build()` method trả về `FutureOr<T>` cho initial state
- `state` là `AsyncValue<T>` (loading/data/error states)
- Dùng `ref.read()` để access dependencies

### Provider Pattern (Function Provider)

Cho simple providers:

```dart
// lib/presentation/providers/auth_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  throw UnimplementedError('Must override authRepositoryProvider');
}
```

---

## Screen Migration Pattern

### Từ StatelessWidget → ConsumerWidget

**Trước (Provider):**
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.userProfile;
    
    return Scaffold(
      body: Text(user?.fullName ?? 'No user'),
    );
  }
}
```

**Sau (Riverpod):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    
    return Scaffold(
      body: Text(user?.fullName ?? 'No user'),
    );
  }
}
```

### Từ StatefulWidget → ConsumerStatefulWidget

**Trước (Provider):**
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) return LoadingWidget();
        return LoginForm(onSubmit: (email, pwd) {
          context.read<AuthViewModel>().signIn(email, pwd);
        });
      },
    );
  }
}
```

**Sau (Riverpod):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return authState.when(
      data: (profile) => LoginForm(
        onSubmit: (email, pwd) {
          ref.read(authNotifierProvider.notifier).signIn(email, pwd);
        },
      ),
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

---

## Key Differences

### 1. State Access

| Provider (cũ) | Riverpod (mới) |
|---------------|----------------|
| `context.watch<AuthViewModel>()` | `ref.watch(authNotifierProvider)` |
| `context.read<AuthViewModel>()` | `ref.read(authNotifierProvider.notifier)` |
| `Consumer<AuthViewModel>` | `ref.watch()` trong build method |

### 2. State Management

| Provider (cũ) | Riverpod (mới) |
|---------------|----------------|
| `ChangeNotifier` với `notifyListeners()` | `AsyncNotifier` với `AsyncValue` |
| Manual loading/error states | `AsyncValue.loading()` / `AsyncValue.error()` |
| Getters cho state | `state.value` (AsyncValue) |

### 3. Error Handling

**Provider (cũ):**
```dart
try {
  await _repository.signIn(email, password);
  _state = AuthState.success;
} catch (e) {
  _errorMessage = e.toString();
  _state = AuthState.error;
  notifyListeners();
}
```

**Riverpod (mới):**
```dart
state = await AsyncValue.guard(() async {
  final repo = ref.read(authRepositoryProvider);
  return await repo.signIn(email, password);
});
// Hoặc manually:
try {
  state = const AsyncValue.loading();
  final result = await _repo.signIn(email, password);
  state = AsyncValue.data(result);
} catch (e, stackTrace) {
  state = AsyncValue.error(e, stackTrace);
}
```

---

## AsyncValue.when() Pattern

Dùng `AsyncValue.when()` để handle loading/error/data states:

```dart
final authState = ref.watch(authNotifierProvider);

return authState.when(
  data: (profile) {
    if (profile == null) return LoginScreen();
    return DashboardScreen(user: profile);
  },
  loading: () => SplashScreen(),
  error: (error, stackTrace) => ErrorScreen(error: error),
);
```

---

## KeepAlive Pattern

Cho providers cần persist state (ví dụ: auth state):

```dart
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  // ...
}
```

**Khi nào dùng:**
- Auth state (cần persist giữa screens)
- User profile (cần access ở nhiều nơi)
- Settings (global state)

**Khi nào KHÔNG dùng:**
- Screen-specific state (auto-dispose tốt hơn)
- Temporary state (form inputs, etc.)

---

## Migration Checklist

Khi migrate một screen:

- [ ] Convert `StatelessWidget` → `ConsumerWidget` hoặc `StatefulWidget` → `ConsumerStatefulWidget`
- [ ] Import `flutter_riverpod`
- [ ] Thay `context.watch<T>()` → `ref.watch(provider)`
- [ ] Thay `context.read<T>()` → `ref.read(provider.notifier)`
- [ ] Thay `Consumer<T>` → `ref.watch()` trong build method
- [ ] Update error handling dùng `AsyncValue.when()` hoặc `AsyncValue.guard()`
- [ ] Chạy `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Test screen hoạt động đúng
- [ ] Remove Provider imports nếu không còn dùng

---

## Best Practices

### 1. Dùng AsyncValue.guard() cho error handling

```dart
// ✅ Good
state = await AsyncValue.guard(() async {
  return await _repo.fetchData();
});

// ❌ Bad (manual try-catch)
try {
  state = const AsyncValue.loading();
  final data = await _repo.fetchData();
  state = AsyncValue.data(data);
} catch (e, s) {
  state = AsyncValue.error(e, s);
}
```

### 2. Dùng ref.watch() cho reactive state

```dart
// ✅ Good - rebuild khi authState thay đổi
final authState = ref.watch(authNotifierProvider);

// ❌ Bad - chỉ đọc một lần
final authState = ref.read(authNotifierProvider);
```

### 3. Dùng ref.read() cho one-time access (callbacks)

```dart
// ✅ Good - chỉ đọc một lần trong callback
onPressed: () {
  ref.read(authNotifierProvider.notifier).signOut();
}

// ❌ Bad - dùng watch trong callback
onPressed: () {
  ref.watch(authNotifierProvider.notifier).signOut(); // Wrong!
}
```

### 4. Dùng keepAlive cho global state

```dart
// ✅ Good - auth state cần persist
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier { ... }

// ✅ Good - screen-specific state auto-dispose
@riverpod
class FormNotifier extends _$FormNotifier { ... }
```

---

## Common Patterns

### Pattern 1: Loading State

```dart
final classesState = ref.watch(classNotifierProvider);

if (classesState.isLoading) {
  return CircularProgressIndicator();
}

final classes = classesState.value ?? [];
return ListView.builder(
  itemCount: classes.length,
  itemBuilder: (context, index) => ClassItem(class: classes[index]),
);
```

### Pattern 2: Error State

```dart
final classesState = ref.watch(classNotifierProvider);

return classesState.when(
  data: (classes) => ClassList(classes: classes),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(
    error: error,
    onRetry: () => ref.read(classNotifierProvider.notifier).loadClasses(),
  ),
);
```

### Pattern 3: Refresh Pattern

```dart
Future<void> _onRefresh() async {
  await ref.read(classNotifierProvider.notifier).loadClasses();
}

RefreshIndicator(
  onRefresh: _onRefresh,
  child: ClassList(...),
)
```

---

## Tài liệu tham khảo

- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [AsyncNotifier Documentation](https://riverpod.dev/docs/concepts/reading#asyncnotifier-and-asyncvalue)
- Project pattern: `lib/presentation/providers/auth_notifier.dart`
- Project pattern: `lib/presentation/providers/class_notifier.dart`

---

## Migration Status

**Đã migrate:**
- ✅ `AuthNotifier`, `ClassNotifier`, `StudentDashboardNotifier`
- ✅ Login, Register, Splash screens
- ✅ Student/Teacher dashboard screens
- ✅ Class management screens (list, create, edit, detail, join)
- ✅ Profile screen

**Chưa migrate (có thể để sau):**
- ⏳ ClassSettingsDrawer (vẫn dùng ClassViewModel)
- ⏳ Một số screens đơn giản không dùng Provider/ViewModel

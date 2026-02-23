---
name: state
description: "Kích hoạt khi viết logic quản lý trạng thái, load dữ liệu bất đồng bộ, sử dụng Riverpod (Providers, Notifiers, AsyncNotifier)."
---

# Kỹ năng: Quản lý Trạng thái (Riverpod)

Tuân thủ các chuẩn sau khi viết Provider và Notifier bằng Riverpod:

## 1. Chuẩn Code Generation

BẮT BUỘC dùng `@riverpod` generator cho mọi providers mới. KHÔNG dùng cú pháp cũ (`StateNotifierProvider`, `ChangeNotifierProvider`).

```dart
@riverpod
class MyFeatureNotifier extends _$MyFeatureNotifier {
  @override
  FutureOr<MyData> build() async {
    return ref.watch(myRepositoryProvider).getData();
  }
}
```

## 2. AsyncNotifier Pattern & AsyncValue.guard

Dùng `AsyncValue.guard()` để bắt exception tự động — không cần try/catch thủ công:

```dart
@riverpod
class ClassListNotifier extends _$ClassListNotifier {
  @override
  FutureOr<List<ClassEntity>> build() async {
    return ref.watch(classRepositoryProvider).getClasses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(classRepositoryProvider).getClasses(),
    );
  }
}
```

## 3. Concurrency Guards (Cực kỳ quan trọng)

Ngăn "Future already completed" / double-state errors:

```dart
bool _isUpdating = false;

Future<void> toggleSetting(bool value) async {
  if (_isUpdating) return;
  _isUpdating = true;
  try {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(repoProvider).update(value));
  } finally {
    _isUpdating = false;
  }
}
```

## 4. Parallel Fetching (Bundle Loader Pattern)

Cho màn hình cần nhiều data sources độc lập — fetch song song, commit state 1 lần:

```dart
Future<void> loadClassBundle(String classId) async {
  state = const AsyncLoading();
  final results = await Future.wait([
    ref.read(classRepoProvider).getClass(classId),
    ref.read(memberRepoProvider).getMembers(classId),
    ref.read(assignmentRepoProvider).getAssignments(classId),
  ]);
  // Commit 1 lần → minimize rebuilds
  state = AsyncData(ClassBundle(
    classDetail: results[0] as ClassEntity,
    members: results[1] as List<MemberEntity>,
    assignments: results[2] as List<AssignmentEntity>,
  ));
}
```

## 5. Provider Lifetime & keepAlive

```dart
// Auto-dispose (default) — dispose khi không còn listener
@riverpod
Future<List<CourseEntity>> courseList(CourseListRef ref) async { ... }

// keepAlive — dùng cho data cần cache suốt app (auth, config)
@Riverpod(keepAlive: true)
AuthNotifier authNotifier(AuthNotifierRef ref) => AuthNotifier(ref);

// keepAlive có điều kiện — giữ cache trong thời gian nhất định
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref, String userId) async {
  ref.keepAlive(); // Giữ cache cho đến khi bị invalidate thủ công
  return ref.read(userRepoProvider).getProfile(userId);
}
```

## 6. Pull-To-Refresh an toàn

Refresh Dashboard CHỈ làm mới data providers, KHÔNG được `ref.invalidate(authProvider)`:

```dart
// ✅ ĐÚNG
Future<void> refresh() async {
  await loadClassBundle(classId);
}

// ❌ SAI — Router sẽ redirect về Login
ref.invalidate(authProvider);
```

## 7. Giao tiếp View với Notifier

```dart
// ✅ ConsumerWidget thay vì StatefulWidget khi có thể
class CourseListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseListProvider);

    return coursesAsync.when(
      data: (courses) => CourseListView(courses: courses),
      loading: () => const ShimmerListTileLoading(),
      error: (e, st) => ErrorStateWidget(error: e.toString()),
    );
  }
}

// ref.read() trong callback, KHÔNG dùng ref.watch()
ElevatedButton(
  onPressed: () => ref.read(courseListProvider.notifier).refresh(),
  child: const Text('Làm mới'),
)
```

## 8. State Preservation (Tabs)

```dart
// ShellRoute tabs: dùng widget.child, không rebuild full page
class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell, // ← giữ state tự động
      bottomNavigationBar: BottomNavBar(shell: navigationShell),
    );
  }
}

// Tránh heavy operations trong build()
// ❌ SAI
Widget build(BuildContext context, WidgetRef ref) {
  AppLogger.d('Building...'); // log trong build = spam
  final json = jsonEncode(data); // encode trong build = lag
}
```

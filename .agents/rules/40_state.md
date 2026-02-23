# 40 — State Management (Riverpod + AsyncNotifier)

## Core Rules
- ALWAYS use `@riverpod` generator annotation
- `ref.watch()` in UI (reactive rebuild)
- `ref.read()` in callbacks/events (one-time read)
- Avoid unnecessary rebuilds

## AsyncNotifier Pattern
```dart
@riverpod
class ClassListNotifier extends _$ClassListNotifier {
  @override
  FutureOr<List<ClassEntity>> build() async {
    return ref.watch(classRepositoryProvider).getClasses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(classRepositoryProvider).getClasses()
    );
  }
}
```

## ⚠️ CRITICAL: Concurrency Guards
Prevent "Future already completed" / double-state errors:
```dart
bool _isUpdating = false;

Future<void> toggleSetting(bool value) async {
  if (_isUpdating) return;  // guard
  _isUpdating = true;
  try {
    // ... update
  } finally {
    _isUpdating = false;
  }
}
```

## Parallel Fetching (Bundle Loader Pattern)
For screens needing multiple independent data sources:
```dart
Future<void> loadClassBundle(String classId) async {
  state = const AsyncLoading();
  final results = await Future.wait([
    ref.read(classRepoProvider).getClass(classId),
    ref.read(memberRepoProvider).getMembers(classId),
    ref.read(assignmentRepoProvider).getAssignments(classId),
  ]);
  // Commit state ONCE to minimize rebuilds
  state = AsyncData(ClassBundle(
    classDetail: results[0],
    members: results[1],
    assignments: results[2],
  ));
}
```
- Use `Future.wait([...])` for independent requests
- Commit `state = AsyncData(...)` **only once** with full bundle
- Secondary/non-blocking data: load separately with section-level shimmer

## Dashboard Refresh — No Auth Reset
Pull-to-refresh must NOT reset auth state:
```dart
// ✅ CORRECT: refresh only data
Future<void> refresh() async {
  // Do NOT call logout or re-auth
  await loadClassBundle(classId);
}

// ❌ WRONG: causes redirect to login
ref.invalidate(authProvider);  // forbidden in refresh
```

## State Preservation (Tabs)
- ShellRoute tabs: wrap with `widget.child`, do NOT rebuild full pages on tab switch
- Legacy IndexedStack: `pages` list should be `static final` + `const` widgets
- Avoid heavy operations in `build()` (logging, JSON encode, file IO)

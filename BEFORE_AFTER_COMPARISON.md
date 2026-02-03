# Before vs After: Splash Screen Architecture Refactor

## The Problem Visualized

### Old (Broken) Flow 🔴
```
START
  ↓
[ConsumerStatefulWidget SplashScreen]
  ↓ (initState)
_checkLoginStatus() 
  ↓ (after auth check)
context.go("/login")  ← MANUAL NAVIGATION
  ↓ (GoRouter rebuilds widget tree)
🔴 Splash DISPOSED (dispose called)
  ↓
🔴 Splash RECREATED (initState called)
  ↓ NEW INSTANCE, STATE LOST!
_navigationDone = false (default)
_isChecking = false (default)
  ↓
_checkLoginStatus() CALLED AGAIN ← LOOP RESTART
  ↓
context.go("/login") ← TRIGGERS ANOTHER RECREATION
  ↓
🔴 Splash DISPOSED
  ↓
🔴 Splash RECREATED
  ↓
INFINITE LOOP ∞∞∞
```

### New (Fixed) Flow 🟢
```
START
  ↓
[ConsumerWidget SplashScreen]
  ↓
ref.watch(authNotifierProvider)
  ↓
authState.when(
  loading: () => show loading,
  error: (e) => show error + retry,
  data: (_) => show redirecting
)
  ↓
Router watches same authNotifierProvider
  ↓ (when auth state changes to "has session")
Router redirects to /home (AUTOMATICALLY)
  ↓
(No manual context.go() call)
  ↓
🟢 No widget recreation
🟢 No state loss
🟢 CLEAN NAVIGATION
```

## Code Comparison

### Old Implementation (Broken)
```dart
// ❌ BAD: StatefulWidget doing manual navigation
class SplashScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late Timer _timeoutTimer;
  bool _hasTimedOut = false;
  bool _isChecking = false;
  bool _navigationDone = false;
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();  // ❌ Manual check
  }
  
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await ref
          .read(authNotifierProvider.notifier)
          .checkCurrentUser();
      
      // ❌ PROBLEM: Manual navigation triggers widget rebuild
      if (isLoggedIn) {
        context.go('/home');  // ❌ This destroys and recreates the widget!
      } else {
        context.go('/login');  // ❌ This destroys and recreates the widget!
      }
    } catch (e) {
      // Error handling
    }
  }
  
  @override
  void dispose() {
    _timeoutTimer.cancel();
    super.dispose();  // ❌ When widget is destroyed, all state is lost
  }
}
```

### New Implementation (Fixed)
```dart
// ✅ GOOD: Stateless widget watching provider state
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch auth state - when it changes, rebuild happens naturally
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Center(
        child: authState.when(
          // ✅ Show loading while auth is checking
          loading: () {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Đang khởi tạo ứng dụng...'),
              ],
            );
          },
          
          // ✅ Show error with retry button
          error: (error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                SizedBox(height: 24),
                Text('Lỗi Khởi Tạo'),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // ✅ Retry just invalidates provider, doesn't navigate
                    ref.invalidate(authNotifierProvider);
                  },
                  child: Text('Thử Lại'),
                ),
              ],
            );
          },
          
          // ✅ Auth check complete - show redirecting message
          // ✅ Router will automatically redirect based on auth state
          // ✅ We NEVER call context.go() manually!
          data: (_) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Đang chuyển hướng...'),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

## Key Differences

| Aspect | Old (Broken) | New (Fixed) |
|--------|-------------|-----------|
| **Widget Type** | ConsumerStatefulWidget | ConsumerWidget |
| **State Management** | Manual state variables | Riverpod provider watching |
| **Navigation** | Manual `context.go()` | Router redirects automatically |
| **Auth Checking** | Manual in `initState()` | Automatic by provider |
| **State Persistence** | ❌ Lost on widget recreation | ✅ Persisted by Riverpod |
| **Lifecycle Management** | ❌ Complex (initState, dispose) | ✅ None needed |
| **Lines of Code** | 238 lines | 101 lines |
| **Infinite Loops** | ❌ Yes | ✅ No |
| **Spam Logs** | ❌ Yes | ✅ No |
| **Error Handling** | ❌ Complex retry logic | ✅ Simple invalidate |

## Why the Old Code Failed

1. **StatefulWidget with Manual Navigation**
   - State stored in widget instance
   - Manual `context.go()` triggers widget rebuild
   - Old instance destroyed, new instance created
   - All state variables reset to defaults

2. **Timing Issue**
   - Flag `_navigationDone` meant to prevent re-checks
   - But widget destroyed before flag check happened
   - New instance created with fresh default values
   - Loop restarted

3. **No Reactive Pattern**
   - Code was imperative ("do this, then do that")
   - Didn't react to provider state changes properly
   - Router couldn't coordinate with manual navigation

## Why the New Code Works

1. **Stateless Widget**
   - No state variables to lose
   - Provider state is the single source of truth
   - Riverpod manages state lifecycle

2. **Reactive Pattern**
   - `ref.watch()` listens to provider changes
   - When auth state changes, widget rebuilds automatically
   - No manual navigation needed

3. **Router Integration**
   - Router also watches `authNotifierProvider`
   - When state changes, router redirects automatically
   - Splash screen just renders current state

4. **Clean Separation**
   - Splash screen: just displays state
   - Provider: manages auth logic
   - Router: handles navigation

## Lesson Learned

**Golden Rule:** In Riverpod + GoRouter apps, **never manually navigate from a widget that the router might recreate**.

Instead:
1. Update the provider state
2. Let Riverpod notify dependents
3. Let router watch the same provider
4. Let router handle navigation automatically

This is the **reactive architecture pattern** that makes Flutter state management work smoothly.

---

**Comparison created:** 2025-01-22  
**Status:** ✅ VERIFIED AND WORKING

# Visual Diagrams: The Splash Screen Fix

## 🔴 Problem Flow (Before Fix)

```
┌─────────────────────────────────────────────────────────────────┐
│ USER LAUNCHES APP                                               │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │ SplashScreen                │
        │ (ConsumerStatefulWidget)    │
        │                             │
        │  State vars:                │
        │  - _navigationDone = false  │
        │  - _isChecking = false      │
        │  - _hasTimedOut = false     │
        └─────────────┬───────────────┘
                      │
                      ▼ initState()
        ┌─────────────────────────────┐
        │ _checkLoginStatus()         │
        │ (Manual auth check)         │
        │                             │
        │ Calls: authRepo.check...()  │
        └─────────────┬───────────────┘
                      │
            ┌─────────┴────────┐
            │                  │
     (1 sec later)      (network ok)
            │                  │
            ▼                  ▼
    [timeout error]  ┌──────────────────┐
                     │ Check completes  │
                     │ isLoggedIn = false│
                     └────────┬─────────┘
                              │
                              ▼ MANUAL NAVIGATION
                    ┌─────────────────────┐
                    │ context.go('/login')│ ← PROBLEM HERE!
                    └────────┬────────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │  GoRouter rebuilds widget tree         │
        │                                        │
        ▼                                        ▼
    🔴 DISPOSE CALLED              🔴 NEW INSTANCE CREATED
    (Old widget destroyed)         (New SplashScreen)
    (State lost)
                                   State vars reset:
                                   - _navigationDone = false ← RESET!
                                   - _isChecking = false
                                   - _hasTimedOut = false
                                   
                                            │
                                            ▼ initState() called again!
                                   
                                   _checkLoginStatus() CALLED AGAIN
                                            │
                                            ▼ Same flow...
                                   
                                   context.go('/login')
                                            │
                                   ┌────────┴────────┐
                                   │                 │
                              🔴 DISPOSE       🔴 CREATE NEW
                                   
                                   ∞∞∞ INFINITE LOOP ∞∞∞
```

---

## 🟢 Solution Flow (After Fix)

```
┌─────────────────────────────────────────────────────────────────┐
│ USER LAUNCHES APP                                               │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ SplashScreen                 │
        │ (ConsumerWidget - stateless!)│
        │                              │
        │ No state vars to lose!       │
        └──────────────┬───────────────┘
                       │
                       ▼ build()
        ┌──────────────────────────────────┐
        │ ref.watch(authNotifierProvider)  │
        │                                  │
        │ Watching provider state!        │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │ authState.when(                │
        │   loading: () =>               │
        │     ShowLoadingScreen()        │
        │                                │
        │   data: (_) =>                 │
        │     ShowRedirectingScreen()    │
        │ )                              │
        └────────────┬─────────────────────┘
                     │
        ┌────────────┴─────────┐
        │                      │
        ▼ (1-2 seconds)        ▼ (Provider changes state)
    LoadingScreen         authNotifierProvider
    Showing spinner       Auth check completes
    "Đang khởi tạo..."    
                               │
                               ▼ PROVIDER NOTIFIES DEPENDENTS
                          
                          ✅ Widget is NOTIFIED (not destroyed)
                          
                               │
                ┌──────────────┬┴────────────────┐
                │              │                │
                ▼              ▼                ▼
            SplashScreen   GoRouter        OtherWidgets
            Rebuilds       Also watching   Depending on
            (same          same provider   authProvider
            instance!)     
                               │
                               ▼ Router sees auth state changed
                          
                          ✅ Router redirects to /home or /login
                               │
                               ▼ AUTOMATIC NAVIGATION
                        
                        (No context.go() called!)
                        (Widget never destroyed!)
                        (State never lost!)
                        
                        ✅ CLEAN NAVIGATION
```

---

## 🔄 State Flow Comparison

### ❌ BROKEN: Manual Navigation Pattern
```
Widget Created
    ↓
initState() 
    ↓
Check Auth
    ↓
context.go() ← Manual navigation
    ↓
Widget Destroyed
    ↓
Widget Recreated
    ↓
initState() ← AGAIN!
    ↓
Check Auth ← AGAIN!
    ↓
context.go() ← AGAIN!
    ↓
∞∞∞ LOOP ∞∞∞
```

### ✅ FIXED: Reactive Pattern
```
Widget Created
    ↓
Watching Provider State
    ↓ (Provider changes)
    ▼
Widget Rebuilds (same instance!)
    ↓
Provider still same
    ↓
Widget stays stable
    ↓
Router sees provider change
    ↓
Router redirects automatically
    ↓
✅ Done (one time only)
```

---

## 📊 Call Stack Visualization

### ❌ BROKEN: Repeated Calls
```
Frame 1 (0ms):
├── initState()
│   └── _checkLoginStatus()
│       └── authRepo.checkCurrentUser()
│           └── supabase.auth.currentSession

Frame 2 (500ms):
├── dispose()  ← DESTROY
├── initState() ← CREATE NEW ← BUG!
│   └── _checkLoginStatus()
│       └── authRepo.checkCurrentUser()
│           └── supabase.auth.currentSession

Frame 3 (1000ms):
├── dispose()  ← DESTROY
├── initState() ← CREATE NEW ← BUG AGAIN!
│   └── _checkLoginStatus()
│       └── authRepo.checkCurrentUser()
│           └── supabase.auth.currentSession

[Loop continues indefinitely...]
```

### ✅ FIXED: Single Call Path
```
Frame 1 (0ms):
├── build()
│   └── ref.watch(authNotifierProvider)
│       └── authProvider notifies: LOADING state
│           └── Show CircularProgressIndicator

Frame 2 (500ms):
├── build() ← REBUILD, SAME WIDGET INSTANCE
│   └── ref.watch(authNotifierProvider)
│       └── authProvider notifies: DATA state
│           └── Show "Redirecting..." message

Frame 3 (600ms):
├── Router sees provider changed
│   └── Redirect to /home or /login
│       └── Navigate away from splash

[Navigation complete, no loops]
```

---

## 🎯 Architecture Comparison

### ❌ BEFORE: Imperative (Manual)
```
┌────────────────┐
│  SplashScreen  │
│  StatefulWidget│
│                │
│  Methods:      │
│  • initState() │
│  • dispose()   │
│  • build()     │
│  • _checkLogin()
│  • _retry()    │
│                │
│  State:        │
│  • _navigationDone
│  • _isChecking │
│  • _hasTimedOut│
│  • _timeoutTimer
│  • _errorMsg   │
└────────────────┘
        │
        │ Calls
        ▼
┌────────────────┐
│  AuthRepository│
│  • checkAuth() │
└────────────────┘
        │
        │ Calls
        ▼
┌────────────────┐
│ Supabase Client│
└────────────────┘
        │
        │ Result goes back
        ▼
┌────────────────┐
│ Manual Navi:   │
│ context.go()   │ ← PROBLEM: Destroys widget!
└────────────────┘
```

### ✅ AFTER: Reactive (Smart)
```
┌────────────────────────────────┐
│  authNotifierProvider          │
│  (Riverpod Async Notifier)     │
│                                │
│  State: AsyncValue<Profile?>   │
│  • LOADING                     │
│  • ERROR                       │
│  • DATA(profile)               │
└────────┬───────────────────────┘
         │ Updates
         │
    ┌────┴────┬──────────┬────────┐
    │          │          │        │
    ▼          ▼          ▼        ▼
SplashScreen GoRouter OtherWidgets App
    │        │         │          │
    │ Watches│ Watches │ Watches  │
    └────────┴─────────┴──────────┘
         │
    All see same state!
    
    No manual navigation needed!
    No widget destruction!
    No state loss!
```

---

## 📱 User Experience Flow

### ❌ BEFORE: Freezing & Loops
```
User taps app icon
        │
        ▼
[Splash screen appears]
        │
        ▼
[Loading spinner]
        │
        ▼
[Spinner continues...]
        │
        ▼
[App FROZEN]  ← User sees nothing happening
        │
        ▼
[Still frozen...]
        │
        ▼
User force closes app
```

### ✅ AFTER: Smooth Experience
```
User taps app icon
        │
        ▼
[Splash screen appears] - clear feedback
        │
        ▼
[Loading spinner with text]
"Đang khởi tạo ứng dụng..."
        │
        ▼
[Spinner continues for 1-2 seconds]
        │
        ▼
[Show "Đang chuyển hướng..."]
        │
        ▼
[Navigate to login/home]
        │
        ▼
User sees main app in 2-3 seconds ✓
```

---

## 🔍 Key Differences at a Glance

| Aspect | Before ❌ | After ✅ |
|--------|-----------|----------|
| **Widget Type** | StatefulWidget | ConsumerWidget |
| **Navigation** | `context.go()` | Router auto-redirect |
| **State Handling** | Widget variables | Provider state |
| **Lifecycle** | initState/dispose | None (stateless) |
| **Loops** | Infinite | None |
| **Spam** | Heavy | None |
| **Code Size** | 238 lines | 101 lines |
| **Stability** | Crashes | Stable |

---

**Diagram created:** 2025-01-22  
**Status:** ✅ Ready for reference and documentation

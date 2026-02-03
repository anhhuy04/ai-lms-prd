# Splash Screen Debug Guide

## Log Patterns to Track

The splash screen now outputs detailed debug logs with color-coded prefixes to help track the initialization flow:

### 🔴 Critical Lifecycle Events
```
🔴 SPLASH INITSTATE CALLED - Build#0
🔴 SPLASH DISPOSE CALLED
```
**What to look for:**
- Should see `INITSTATE CALLED` exactly **once** at app startup
- Should NOT see it multiple times (if you do, it means ConsumerStatefulWidget is rebuilding)
- `DISPOSE` should only appear when leaving splash screen

---

### 🟢 Check Login Status Flow
```
🟢 _checkLoginStatus CALLED #1 | _isChecking=false | _hasTimedOut=false | _navigationDone=false
🟢 _checkLoginStatus SET _isChecking=true
🟢 _checkLoginStatus SET _isChecking=false (finally block)
```
**What to look for:**
- Should see `CALLED #1` exactly once
- If you see `CALLED #2`, `#3`, `#4`... it's looping! This is the bug
- `SET _isChecking=true` should happen once
- `SET _isChecking=false (finally)` should come after

**Common Bug Patterns:**
```
❌ SPAM (BAD):
🟢 _checkLoginStatus CALLED #1 | ...
🟢 _checkLoginStatus CALLED #2 | ...
🟢 _checkLoginStatus CALLED #3 | ...

✅ CORRECT (GOOD):
🟢 _checkLoginStatus CALLED #1 | ...
(no more calls)
```

---

### 🔵 Authentication Check
```
🔵 Splash: Checking authentication status...
🔵 Splash: Authentication check completed - isLoggedIn=false
```
**What to look for:**
- Should appear exactly once per app startup
- Shows whether user is logged in or not
- If spammed, it means navigation didn't complete

---

### 🟡 Navigation Events
```
🟡 Navigating to: /home
🟡 Navigation completed - SET _navigationDone=true
```
**What to look for:**
- After auth check completes, should navigate to `/home` or `/login`
- `_navigationDone=true` means navigation was called
- If you never see this, navigation is being blocked

---

### ⚠️ Early Returns (Safety Checks)
```
⚠️ _checkLoginStatus EARLY RETURN - _isChecking=true, _hasTimedOut=false, _navigationDone=false
⚠️ After delay - mounted=true, _hasTimedOut=false, _navigationDone=true
```
**What to look for:**
- These are normal and mean the safety guards are working
- Indicates why `_checkLoginStatus` didn't run again

---

### 🟣 Build Tracking
```
🟣 BUILD #1 - _navigationDone=false, _hasTimedOut=false, _isChecking=true
🟣 BUILD #2 - _navigationDone=true, _hasTimedOut=false, _isChecking=false
```
**What to look for:**
- Build counter on splash screen (shows at bottom of loading screen)
- If build count keeps increasing (1, 2, 3, 4, 5...), widget is rebuilding excessively
- Should stop after navigation completes

---

## Complete Expected Flow

### ✅ SUCCESS FLOW
```
🔴 SPLASH INITSTATE CALLED - Build#0
🟢 _checkLoginStatus CALLED #1 | _isChecking=false, _hasTimedOut=false, _navigationDone=false
🟢 _checkLoginStatus SET _isChecking=true
🟣 BUILD #1 - _navigationDone=false, _hasTimedOut=false, _isChecking=true
🔵 Splash: Checking authentication status...
[... auth check in repository ...]
🔵 Splash: Authentication check completed - isLoggedIn=false
🟡 Navigating to: /login
🟡 Navigation completed - SET _navigationDone=true
🟢 _checkLoginStatus SET _isChecking=false (finally block)
🟣 BUILD #2 - _navigationDone=true, _hasTimedOut=false, _isChecking=false
🔴 SPLASH DISPOSE CALLED
```
**Duration:** ~1-3 seconds total


### ❌ SPAM LOOP FLOW (BUG)
```
🔴 SPLASH INITSTATE CALLED - Build#0
🟢 _checkLoginStatus CALLED #1 | ...
🟢 _checkLoginStatus SET _isChecking=true
🟣 BUILD #1 - ...
🔵 Splash: Checking authentication status...
[auth check]
🔵 Splash: Authentication check completed - isLoggedIn=false
🟡 Navigating to: /login
🟣 BUILD #2 - _navigationDone=true
🟢 _checkLoginStatus CALLED #2 | ...  ← ❌ SECOND CALL! SHOULD NOT HAPPEN
🟢 _checkLoginStatus SET _isChecking=true
🟣 BUILD #3 - ...
🔵 Splash: Checking authentication status...
🔵 Splash: Authentication check completed - isLoggedIn=false
🟡 Navigating to: /login
🟣 BUILD #4 - ...
...
```
**This indicates:** Widget is rebuilding after navigation, calling `_checkLoginStatus()` again


---

## What to Check on Your Terminal

### Run app with logs filtered:
```bash
flutter run 2>&1 | grep -E "SPLASH|_checkLoginStatus|BUILD|Navigating"
```

### If you see spam:
1. **Check Build counter** - Does it keep increasing?
2. **Check CALLED #N** - Does it show #2, #3, #4?
3. **Check if _navigationDone** - Is it true after navigation?

### If everything looks good but navigation doesn't happen:
Look for:
- `🟡 Navigating to:` - Does this line appear?
- `context.go()` might be silently failing
- Check GoRouter configuration


---

## Debug UI on Screen

The splash screen now shows debug info at the bottom:
```
Build: X | Check: Y | Checking: Z | Done: W
```

- **Build:** Widget build count (should stop after ~2)
- **Check:** How many times _checkLoginStatus was called (should be 1)
- **Checking:** Is currently checking (_isChecking flag)
- **Done:** Has navigation completed (_navigationDone flag)

**Good state:** `Build: 2 | Check: 1 | Checking: false | Done: true`

**Bad state:** `Build: 10 | Check: 5 | Checking: false | Done: false`

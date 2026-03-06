---
name: code_review
description: Workflow cho code review: kiểm tra code quality, security, best practices trước khi commit.
trigger: /review
---

# Workflow: Code Review

## 1. Pre-Review Checklist

### ✅ Chạy Analysis
```bash
flutter analyze
```

### ✅ Format Code
```bash
dart format .
```

### ✅ Run Tests
```bash
flutter test
```

---

## 2. Review Categories

### Architecture (Clean Architecture)
- [ ] **Domain/Data/Presentation** tách biệt đúng?
- [ ] Repository implement interface?
- [ ] KHÔNG import Data từ Presentation?

### State Management (Riverpod)
- [ ] Dùng `@riverpod` annotation?
- [ ] `ref.watch()` trong UI, `ref.read()` trong callbacks?
- [ ] Concurrency guard cho async operations?
- [ ] KHÔNG `ref.invalidate(authProvider)` trong refresh?

### Routing (GoRouter)
- [ ] Specific routes trước parameterized?
- [ ] Dùng `context.goNamed()` thay vì `Navigator.push()`?
- [ ] Route constants trong `route_constants.dart`?

### UI/Design
- [ ] Design Tokens (KHÔNG hardcode colors/spacing)?
- [ ] Shimmer loading cho async content?
- [ ] Responsive với `flutter_screenutil`?
- [ ] `build()` ≤ 50 lines?

### Supabase
- [ ] RLS enabled trên mọi table?
- [ ] Dùng `(select auth.uid())` thay vì `auth.uid()`?
- [ ] DataSource pattern (KHÔNG gọi Supabase trực tiếp từ UI)?

### Error Handling
- [ ] Typed exceptions (sealed class)?
- [ ] Sentry reporting cho critical flows?
- [ ] AppLogger (KHÔNG `print()`)?

---

## 3. Security Check

### ✅ KHÔNG có
- Hardcoded API keys / tokens
- Credentials trong source code
- Sensitive data log

### ✅ Nên có
- `envied` cho secrets
- `flutter_secure_storage` cho tokens

---

## 4. Performance Check

### ✅ Check
- [ ] List > 100 items parse trong isolate?
- [ ] Images cached?
- [ ] KHÔNG heavy operations trong `build()`?
- [ ] `const` constructors where possible?

---

## 5. Report

### Tóm tắt Review
```
## Code Review Summary

### ✅ Passed
- Architecture: Clean Architecture đúng
- State: Riverpod patterns đúng
- UI: Design tokens sử dụng

### ⚠️ Issues
- [ ] Line 42: Missing null check
- [ ] Line 88: Use const constructor

### 🎯 Recommendations
- Consider extracting _buildHeader() method
```

---

## 6. Fix (nếu có issues)

### Thực hiện fixes
```bash
# Sau khi fix
flutter analyze
dart format .
flutter test
```

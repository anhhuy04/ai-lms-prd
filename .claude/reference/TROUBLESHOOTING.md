# Troubleshooting Guide

> Common issues and solutions. Read when something breaks.

---

## Agent Behavior Issues

### Issue: Agent Asks Permission for Bug Fix

**Problem:** User reports bug, agent asks "Should I fix this?"

**Fix:** Path A = 100% autonomy. Fix immediately without asking.

---

### Issue: Agent Codes Without Clarifying

**Problem:** User says "make it faster", agent immediately optimizes

**Fix:** Path B = Clarify first. Ask questions before coding.

---

## Flutter Issues

### Tests Failing

```bash
# Run specific test
flutter test test/features/expense/expense_test.dart -v

# Common fixes:
# - Add await for async operations
# - Configure mocks properly
# - Check test data
```

### Build Fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### Analyzer Warnings

```bash
# Check warnings
flutter analyze

# Auto-fix
dart fix --apply
```

---

## Database Issues

### SQLite Error

```bash
# Clear app data
flutter clean

# Reinstall
flutter run
```

---

## Performance Issues

### App Slow

```bash
# Profile
flutter run --profile

# Common fixes:
# - Lazy load screens
# - Use ListView.builder
# - Avoid rebuilds in build()
```

---

## When to Ask User

Ask user when:
- Unclear requirements (Path B)
- Architectural decisions needed
- Design choices

Don't ask when:
- Bug fixes (Path A - just fix it)
- Standard verification (just run checks)


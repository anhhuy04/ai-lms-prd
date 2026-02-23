# 70 — Code Quality & Error Prevention

## Pre-Implementation Checklist (Run in Order)
1. **Requirement** — clarify exact behavior (especially for delete/update ops)
2. **Dependencies** — add to `pubspec.yaml` + `flutter pub get` BEFORE import
3. **Duplicate check** — `grep` provider/function name before creating
4. **Route order** — specific routes before parameterized in `app_router.dart`
5. **Null safety** — plan null checks for ALL API call return values
6. **API docs** — read lib docs for return types before using
7. **Code gen** — run build_runner if Freezed/JsonSerializable changed
8. **Lint** — `flutter analyze` + fix all errors
9. **Testing** — cover happy path, error cases, edge cases

## Common Bugs to Avoid

### GoRouter — Route Ordering
```dart
// ✅ specific first
GoRoute(path: '/student/class/search', ...),
GoRoute(path: '/student/class/:classId', ...),
```

### Provider Duplication
```bash
# ALWAYS grep before defining a new provider
grep -r "myFeatureProvider" lib/
```

### Null Safety
```dart
// ✅ Always guard collections
if (capture == null || capture.barcodes.isEmpty) return;
final first = capture.barcodes.firstWhere((b) => b.rawValue != null);
```

### Missing Dependencies
```
pubspec.yaml → flutter pub get → THEN import
```

## Code Style
- Functions: max **50 lines** → split
- Classes: max **300 lines** → refactor
- `const` constructors: always when possible
- No hardcoded values → use `core/constants/`
- All `flutter analyze` warnings fixed (exceptions need written justification)
- Format: `dart format` before commit
- No `print()` → `AppLogger`

## Dart MCP — When to Use
✅ Use for: format code, analyze lint errors, code quality checks
❌ Don't use for: reading files (`read_file`), text search (`grep`), semantic search (`codebase_search`)

## Import Management
After writing code: run `mcp_dart_analyze_files` to detect missing imports.

## Testing Strategy
After implementation:
- [ ] Happy path (normal flow)
- [ ] Error cases (null, empty, invalid data)
- [ ] Edge cases (boundary conditions)
- [ ] Navigation flows

## Naming Conventions (Quick Ref)
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (or `SCREAMING_SNAKE` for truly constant app-wide values)
- Private widget builders: `_buildXxx()`

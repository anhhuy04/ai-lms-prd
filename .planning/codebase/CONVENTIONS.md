# Coding Conventions

**Analysis Date:** 2026-03-05

## Naming Patterns

**Files:**
- Screens: `*_screen.dart` (e.g., `login_screen.dart`)
- ViewModels: `*_viewmodel.dart` (e.g., `auth_viewmodel.dart`)
- Entities: lowercase (e.g., `profile.dart`)
- Repository interfaces: `*_repository.dart`
- Repository implementations: `*_repository_impl.dart`
- DataSources: `*_datasource.dart`
- Providers: `[feature]Provider` / `[feature]NotifierProvider`

**Functions:**
- Private builders: `_build[Name]()` (e.g., `_buildHeader()`)
- Providers: use `@riverpod` annotation with class naming

**Variables:**
- camelCase for variables and parameters

**Types:**
- Entities: Use Freezed for immutable models
- Enums: PascalCase (e.g., `StudentClassMemberStatus`)

## Code Style

**Formatting:**
- Tool: `dart format` (Flutter default)
- Single quotes: `prefer_single_quotes: true` in `analysis_options.yaml`

**Linting:**
- Tool: `flutter analyze`
- Config: `analysis_options.yaml`
- Key rules:
  - `avoid_print: true` - Use AppLogger instead
  - `prefer_single_quotes: true`
  - Includes `package:flutter_lints/flutter.yaml`

**Code Quality Limits:**
- Functions: max **50 lines** - split into `_buildXxx()` methods
- Classes: max **300 lines** - refactor or split
- Always use `const` constructors when possible
- No hardcoded values - use constants from `core/constants/`

## Design Tokens (MANDATORY)

**All UI code MUST use DesignTokens from `lib/core/constants/design_tokens.dart`:**

**Colors:**
```dart
DesignColors.moonLight, DesignColors.moonMedium, DesignColors.moonDark
DesignColors.tealPrimary, DesignColors.tealDark, DesignColors.tealLight
DesignColors.success, DesignColors.warning, DesignColors.error
DesignColors.textPrimary, DesignColors.textSecondary, DesignColors.textTertiary
```

**Spacing:**
```dart
DesignSpacing.xs, sm, md, lg, xl, xxl, xxxxl, xxxxxl
```

**Typography:**
```dart
DesignTypography.display, headline, titleLarge, bodyMedium, label, caption, overline
```

**Icons:**
```dart
DesignIcons.xsSize, smSize, mdSize, lgSize, xlSize, xxlSize
```

**Border Radius:**
```dart
DesignRadius.none, xs, sm, md, lg, full
```

**Elevation:**
```dart
DesignElevation.level0, level1, level2, level3, level4, level5
```

**Components:**
```dart
DesignComponents.buttonHeight, inputFieldHeight, cardMinHeight, appBarHeight
```

**Responsive:**
```dart
DesignBreakpoints.isMobile(width), isTablet(width), isDesktop(width)
```

## Import Organization

**Order:**
1. Flutter/Dart SDK imports
2. External packages (Riverpod, GoRouter, Supabase, etc.)
3. Internal packages (ai_mls core, widgets)
4. Relative imports

**Path Aliases:**
- Use package imports: `import 'package:ai_mls/core/constants/design_tokens.dart';`

## Error Handling

**Pattern (from systemPatterns.md):**
```dart
// DataSource catches Supabase/network errors -> throws CustomException
// Repository catches CustomException -> translates to Vietnamese -> re-throws
// ViewModel catches exception -> stores error message -> updates state to error
// View reads error message -> displays to user in Vietnamese
```

**CustomException:**
- Defined in domain layer
- Used for domain-level errors
- Messages in Vietnamese for user-facing errors

## Logging

**Framework:** Use `AppLogger` wrapper (not `print()`)

**Pattern:**
- Avoid `print()` statements
- Use logger for debug/info/warning/error levels

## Comments

**When to Comment:**
- Business logic: Vietnamese comments
- Technical decisions: English comments
- Public APIs: JSDoc/TSDoc format

**Error Messages:**
- Always in Vietnamese (user-facing)

## Function Design

**Size:** Max 50 lines per function

**Parameters:** Clear, typed parameters

**Return Values:** Always handle null safety

## Module Design

**Exports:** Use barrel files if multiple related exports

**Clean Architecture Layers:**
```
presentation/  (views, providers)
  ↓ depends on
domain/        (entities, repository interfaces)
  ↓ depends on
data/          (repositories impl, datasources)
```

---

*Convention analysis: 2026-03-05*

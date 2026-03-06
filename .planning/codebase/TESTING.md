# Testing Patterns

**Analysis Date:** 2026-03-05

## Test Framework

**Runner:**
- Flutter test framework
- Config: Standard Flutter test setup

**Assertion Library:**
- Flutter built-in `test` package

**Run Commands:**
```bash
flutter test                 # Run all tests
flutter test --watch        # Watch mode (if available)
```

## Test File Organization

**Location:**
- Tests in `test/` directory at project root
- Co-located pattern for presentation tests: `test/presentation/views/`

**Naming:**
- `*_test.dart` for test files
- Example: `recipient_tree_selector_modal_test.dart`

**Structure:**
```
test/
├── registration_integration_test.dart
├── password_toggle_test.dart
├── widget_test.dart
├── supabase_connection_test.dart
├── temp_test_save_assignment_draft.dart
└── presentation/
    └── views/
        └── assignment/
            └── teacher/
                └── widgets/
                    └── recipient_tree_selector_modal_test.dart
```

## Test Structure

**Basic Pattern:**
```dart
import 'package:flutter_test/flutter_test';

void main() {
  group('Feature Name', () {
    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## Mocking

**Framework:** Flutter's built-in mocking capabilities

**Patterns:**
- Use `setUp()` for common test setup
- Mock dependencies via constructor injection
- Test widget rendering with `WidgetTester`

**What to Mock:**
- Repository implementations
- Data sources
- External services

**What NOT to Mock:**
- Simple utility functions
- Domain entities

## Fixtures and Factories

**Test Data:**
- Create test data manually in test files
- Use simple data classes for test fixtures

**Location:**
- Defined inline within test files

## Coverage

**Requirements:** Not explicitly enforced in project

**View Coverage:**
```bash
flutter test --coverage
```

## Test Types

**Unit Tests:**
- Repository tests
- Utility function tests
- Provider/notifier tests

**Widget Tests:**
- Screen rendering tests
- Component interaction tests

**Integration Tests:**
- Example: `registration_integration_test.dart`
- Tests across multiple components

## Common Patterns

**Async Testing:**
```dart
testWidgets('should load data', (WidgetTester tester) async {
  // Build widget
  // Pump and settle
  // Verify results
});
```

**Error Testing:**
```dart
test('should handle error', () async {
  // Setup mock to throw
  // Call function
  // Verify error handling
});
```

---

*Testing analysis: 2026-03-05*

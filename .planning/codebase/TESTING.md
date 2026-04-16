# Testing Patterns

**Analysis Date:** 2026-04-14

## Test Framework

**Runner:**
- `flutter_test` (Flutter SDK built-in)
- No separate test runner config file — runs via `flutter test`

**Assertion Library:**
- Flutter's built-in `expect()` / `find.*` matchers

**Mocking:**
- `mocktail` ^1.0.0 — preferred mock library
- `Mock` base class for repository/datasource mocks
- `ProviderContainer` overrides for Riverpod provider mocking

**Run Commands:**
```bash
flutter test                    # Run all tests
flutter test test/unit/         # Run unit tests only
flutter test test/widget/       # Run widget tests only
flutter test test/integration/  # Run integration tests only
flutter test --coverage         # Run with coverage
```

## Test File Organization

**Location:** Mirrors `lib/` structure under `test/`

**Directory layout:**
```
test/
├── unit/
│   ├── entities/           # Domain entity tests
│   │   ├── assignment_distribution_test.dart
│   │   └── class_analytics_test.dart
│   └── providers/          # Provider/notifier unit tests
│       ├── workspace_provider_test.dart
│       └── teacher_submission_providers_test.dart
├── widget/
│   ├── screens/            # Screen widget tests
│   │   └── scores_screen_test.dart
│   └── widgets/            # Individual widget tests
│       └── shimmer_loading_test.dart
├── integration/            # Repository + datasource flow tests
│   ├── submission_flow_test.dart
│   └── grading_flow_test.dart
├── presentation/
│   ├── views/              # View-level widget tests
│   │   └── assignment/teacher/widgets/
│   │       └── recipient_tree_selector_modal_test.dart
│   └── providers/          # Provider smoke tests
│       └── recommendation_providers_test.dart
├── data/
│   └── datasources/        # DataSource tests
│       └── recommendation_datasource_test.dart
├── domain/
│   └── entities/           # Entity unit tests
│       └── recommendation_test.dart
├── widget_test.dart         # App smoke test (root level)
├── manual_test_assignment_creation.md   # Manual test script (not automated)
├── temp_test_save_assignment_draft.dart # Temporary/scratch tests
└── registration_integration_test.dart
```

**Naming:** `[subject]_test.dart` — mirrors the source file name.

## Test Structure

**Unit test suite pattern:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmissionRepository extends Mock implements SubmissionRepository {}

void main() {
  group('TeacherSubmissionItem', () {
    test('should create with all required fields', () {
      final item = TeacherSubmissionItem(
        submissionId: 'sub-001',
        studentName: 'Nguyen Van A',
        submittedAt: DateTime(2026, 3, 20, 10, 30),
        isLate: false,
        status: 'submitted',
      );

      expect(item.submissionId, 'sub-001');
      expect(item.totalScore, isNull);
    });
  });
}
```

**Widget test pattern:**
```dart
testWidgets('should render scaffold with app bar', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: ScoresScreen(),
      ),
    ),
  );

  expect(find.byType(Scaffold), findsOneWidget);
  expect(find.text('Điểm số'), findsOneWidget);
});
```

**Setup/teardown pattern:**
```dart
group('Submission Flow Integration', () {
  late MockSubmissionDataSource mockDataSource;
  late SubmissionRepository repository;

  setUp(() {
    mockDataSource = MockSubmissionDataSource();
    repository = SubmissionRepositoryImpl(mockDataSource);
  });

  // tests...
});
```

**ProviderContainer teardown:**
```dart
test('provider can be created', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);  // Always dispose

  final result = container.read(someProvider);
  expect(result, isNotNull);
});
```

## Mocking

**Framework:** `mocktail` ^1.0.0

**Repository mock pattern:**
```dart
class MockSubmissionRepository extends Mock implements SubmissionRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSubmissionDataSource extends Mock implements SubmissionDataSource {}
```

**Stub behavior:**
```dart
// Return value
when(() => mockDataSource.getOrCreateSubmission(any(), any()))
    .thenAnswer((_) async => {
      'id': 'sub-001',
      'status': 'draft',
    });

// Throw error
when(() => mockDataSource.getOrCreateSubmission(any(), any()))
    .thenThrow(Exception('Database error'));

// Named parameters
when(() => mockDataSource.updateSubmissionGrade(
  any(),
  score: any(named: 'score'),
  feedback: any(named: 'feedback'),
)).thenAnswer((_) async {});
```

**Verify calls:**
```dart
verify(() => mockDataSource.saveDraft(
  'dist-001',
  'student-001',
  {'q1': 'answer 1'},
  ['file1.pdf'],
)).called(1);
```

**Riverpod provider overrides:**
```dart
final container = ProviderContainer(
  overrides: [
    submissionRepositoryProvider.overrideWith(
      (ref) => MockSubmissionRepository(),
    ),
  ],
);
```

**App-level mock injection (widget_test.dart):**
```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
      schoolClassRepositoryProvider.overrideWithValue(mockSchoolClassRepository),
    ],
    child: const MyApp(),
  ),
);
```

**What to mock:**
- External repositories (Supabase-backed)
- DataSources that call Supabase
- Network-dependent services

**What NOT to mock:**
- Pure domain entities and logic
- Enum comparisons and value objects
- In-memory implementations

## Test Types

**Unit Tests (`test/unit/`):**
- Scope: single class/function in isolation
- Focus: entities, enums, provider state models, concurrency guard logic
- No Flutter dependency — plain `dart:test`
- Example: `workspace_provider_test.dart` tests enum values and equality

**Integration Tests (`test/integration/`):**
- Scope: repository + mocked datasource
- Focus: data transformation, error propagation, status transitions
- Uses `mocktail` to mock datasource layer, tests real repository impl
- Example: `submission_flow_test.dart` tests full CRUD flow through `SubmissionRepositoryImpl`

**Widget Tests (`test/widget/`, `test/presentation/`):**
- Scope: single widget/screen rendering and interaction
- Uses `ProviderScope` wrapping `MaterialApp`
- Verifies: render without crash, loading states, widget properties (elevation, backgroundColor, text)
- Complex interactions: `recipient_tree_selector_modal_test.dart` tests checkbox tree selection with cross-class leak prevention

**Smoke Tests:**
- `test/widget_test.dart` — verifies `MyApp` renders without error with mocked repositories
- Provider smoke tests — verify providers can be instantiated (`recommendation_providers_test.dart`)

**Manual Tests:**
- `test/manual_test_assignment_creation.md` — manual test scripts (not automated)
- `test/temp_test_save_assignment_draft.dart` — scratch/temp tests (not part of CI suite)

## Coverage

**Requirements:** No enforced coverage threshold detected.

**View coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Common Patterns

**Async testing:**
```dart
test('returns submission on success', () async {
  when(() => mockDataSource.submitAssignment(any(), any()))
      .thenAnswer((_) async => {'id': 'sub-001', 'status': 'submitted'});

  final result = await repository.submitAssignment('dist-001', 'student-001');
  expect(result.status, SubmissionStatus.submitted);
});
```

**Error propagation testing:**
```dart
test('error propagation - repository throws on datasource errors', () async {
  when(() => mockDataSource.getOrCreateSubmission(any(), any()))
      .thenThrow(Exception('Database error'));

  expect(
    () => repository.getOrCreateSubmission('dist-001', 'student-001'),
    throwsA(anything),
  );
});
```

**Widget settle pattern:**
```dart
await tester.pumpWidget(...);
await tester.pumpAndSettle();  // Wait for animations/async to complete

// Or check immediately after pump (for loading states):
await tester.pump();
expect(find.byType(CircularProgressIndicator), findsOneWidget);
```

**Widget interaction + verify pattern (from recipient_tree_selector_modal_test.dart):**
```dart
// Tap to open modal
await tester.tap(find.text('Open Modal'));
await tester.pumpAndSettle();

// Find descendant widget
final checkbox = find.descendant(
  of: find.ancestor(of: find.text('Class 10A'), matching: find.byType(InkWell)).first,
  matching: find.byType(Checkbox),
);
await tester.tap(checkbox);
await tester.pumpAndSettle();

// Verify widget state
final widget = tester.widget<Checkbox>(find.byKey(...));
expect(widget.value, isFalse);
```

**Enum completeness testing:**
```dart
test('should have all expected values', () {
  expect(SavingStatus.values.length, 4);
  expect(SavingStatus.values, contains(SavingStatus.idle));
  expect(SavingStatus.values, contains(SavingStatus.saved));
});
```

## Coverage Gaps

**Areas with minimal or stub-only tests:**
- `test/data/datasources/recommendation_datasource_test.dart` — compile-time instantiation check only; no behavior tested
- `test/presentation/providers/recommendation_providers_test.dart` — stub; marked "requires Supabase mock setup"
- AI providers (`lib/presentation/providers/ai_providers.dart`) — no dedicated test file found
- Analytics providers (`lib/presentation/providers/analytics_providers.dart`) — no dedicated test file found
- Auth notifier (`lib/presentation/providers/auth_notifier.dart`) — no dedicated test file; only covered indirectly via smoke test
- `supabase_connection_test.dart` / `registration_integration_test.dart` — likely require live Supabase; excluded from standard CI

**Note on Supabase:** Tests requiring real Supabase connections are marked as stubs or excluded. The project does not have a Supabase test double/mock setup at the integration layer.

---

*Testing analysis: 2026-04-14*

import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/main.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock repositories cho test smoke.
///
/// Lưu ý: Dùng `Mock` để không phải implement đầy đủ interface (interface thay đổi sẽ
/// không làm test fail vì signature mismatch).
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSchoolClassRepository extends Mock implements SchoolClassRepository {}

void main() {
  testWidgets('MyApp renders without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final mockAuthRepository = MockAuthRepository();
    final mockSchoolClassRepository = MockSchoolClassRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          schoolClassRepositoryProvider.overrideWithValue(mockSchoolClassRepository),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that app has been built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

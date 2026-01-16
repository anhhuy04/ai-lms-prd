// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mls/main.dart';

// Mock implementation của AuthRepository cho testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<Profile> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return Profile(
      id: '1',
      fullName: 'Test User',
      role: 'student',
      avatarUrl: null,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String role,
    String phone,
    String? gender,
  ) async {
    return 'Đăng ký thành công!';
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<Profile?> checkCurrentUser() async {
    return null;
  }
}

void main() {
  testWidgets('MyApp renders without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final mockAuthRepository = MockAuthRepository();
    await tester.pumpWidget(MyApp(authRepository: mockAuthRepository));

    // Verify that app has been built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

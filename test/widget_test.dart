// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

// Mock implementation của SchoolClassRepository cho testing
class MockSchoolClassRepository implements SchoolClassRepository {
  @override
  Future<List<dynamic>> getClasses(String teacherId) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> createClass(
    Map<String, dynamic> classData,
  ) async {
    return {'id': '1', 'name': 'Test Class'};
  }

  @override
  Future<Map<String, dynamic>> updateClass(
    String classId,
    Map<String, dynamic> updates,
  ) async {
    return {'id': classId, 'name': 'Updated Class'};
  }

  @override
  Future<void> deleteClass(String classId) async {}

  @override
  Future<List<dynamic>> getClassMembers(String classId) async {
    return [];
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {}

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {}

  @override
  Future<Map<String, dynamic>> getClassDetails(String classId) async {
    return {'id': classId, 'name': 'Test Class'};
  }

  @override
  Future<void> requestJoinClass(String classId, String studentId) async {}

  @override
  Future<void> approveJoinRequest(String classId, String studentId) async {}

  @override
  Future<void> rejectJoinRequest(String classId, String studentId) async {}

  @override
  Future<void> updateClassSetting(
    String classId,
    String key,
    dynamic value,
  ) async {}
}

void main() {
  testWidgets('MyApp renders without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final mockAuthRepository = MockAuthRepository();
    final mockSchoolClassRepository = MockSchoolClassRepository();
    await tester.pumpWidget(
      MyApp(
        authRepository: mockAuthRepository,
        schoolClassRepository: mockSchoolClassRepository,
      ),
    );

    // Verify that app has been built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_question_bank_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'question_bank_robot.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockQuestionRepository repo;

  setUp(() {
    repo = MockQuestionRepository();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        questionRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWith(() => FakeAuthNotifier(makeProfile())),
      ],
      child: const MaterialApp(home: TeacherQuestionBankScreen()),
    );
  }

  group('TeacherQuestionBankScreen', () {
    testWidgets('renders AppBar title', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Ngân hàng câu hỏi'), findsOneWidget);
    });

    testWidgets('renders empty state when no questions', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Kho câu hỏi trống'), findsOneWidget);
    });

    testWidgets('renders question previews when data', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer(
        (_) async => [
          makeQuestion(id: 'q1', text: 'First question'),
          makeQuestion(id: 'q2', text: 'Second question'),
        ],
      );
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('First question'), findsOneWidget);
      expect(find.text('Second question'), findsOneWidget);
    });

    testWidgets('shows error state with retry button on failure',
        (tester) async {
      when(() => repo.getQuestions(any())).thenThrow(Exception('boom'));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('FAB visible với label "Tạo câu hỏi mới"', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tạo câu hỏi mới'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('renders search field with placeholder', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tìm câu hỏi...'), findsOneWidget);
    });
  });
}

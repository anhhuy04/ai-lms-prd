import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/widgets/question_bank/question_bank_picker_sheet.dart';
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

  Widget host(Widget child) => ProviderScope(
        overrides: [
          questionRepositoryProvider.overrideWithValue(repo),
          currentUserProvider
              .overrideWith(() => FakeAuthNotifier(makeProfile())),
        ],
        child: MaterialApp(home: child),
      );

  /// Helper: build Scaffold with "open" button that shows the picker.
  Widget openHost({void Function(List<Question>?)? onResult}) {
    return host(
      Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await QuestionBankPickerSheet.show(ctx);
                onResult?.call(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  group('QuestionBankPickerSheet', () {
    testWidgets('opens with header title visible', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(openHost());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Chọn câu hỏi từ kho'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });

    testWidgets('empty state shown when no questions', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      await tester.pumpWidget(openHost());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Kho câu hỏi trống'), findsOneWidget);
    });

    testWidgets('renders question items from repo', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer(
        (_) async => [
          makeQuestion(id: 'q1', text: 'Picker question 1'),
          makeQuestion(id: 'q2', text: 'Picker question 2'),
        ],
      );
      await tester.pumpWidget(openHost());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Picker question 1'), findsOneWidget);
      expect(find.text('Picker question 2'), findsOneWidget);
    });

    testWidgets('Hủy button closes sheet with null result', (tester) async {
      when(() => repo.getQuestions(any())).thenAnswer((_) async => []);
      List<Question>? captured;
      var resolved = false;
      await tester.pumpWidget(openHost(onResult: (r) {
        captured = r;
        resolved = true;
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(resolved, isTrue);
      expect(captured, isNull);
    });
  });
}

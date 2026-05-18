import 'package:ai_mls/domain/entities/ghost_report.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ghost_questions_banner.dart';
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
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );

  group('GhostQuestionsBanner', () {
    testWidgets('hidden when ghostCount = 0', (tester) async {
      when(() => repo.detectGhostQuestions(any())).thenAnswer(
        (_) async => const GhostReport(ghostCount: 0, totalCount: 10),
      );
      await tester.pumpWidget(host(
        const GhostQuestionsBanner(assignmentId: 'a1', isDraft: true),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.text('Đồng bộ ngay'), findsNothing);
    });

    testWidgets('shows banner when ghosts present', (tester) async {
      when(() => repo.detectGhostQuestions(any())).thenAnswer(
        (_) async => const GhostReport(ghostCount: 5, totalCount: 10),
      );
      await tester.pumpWidget(host(
        const GhostQuestionsBanner(assignmentId: 'a1', isDraft: true),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text('Phát hiện 5 câu chưa đồng bộ vào kho'),
        findsOneWidget,
      );
      expect(find.text('Đồng bộ ngay'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('hidden when isDraft = false (published)', (tester) async {
      // Repo có thể không bị gọi (banner short-circuit), nhưng vẫn stub
      // để tránh MissingStubError nếu provider được watch sớm.
      when(() => repo.detectGhostQuestions(any())).thenAnswer(
        (_) async => const GhostReport(ghostCount: 5, totalCount: 10),
      );
      await tester.pumpWidget(host(
        const GhostQuestionsBanner(assignmentId: 'a1', isDraft: false),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.text('Đồng bộ ngay'), findsNothing);
    });
  });
}

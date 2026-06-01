import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/batch_grade_by_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const distributionId = 'dist-1';

  final question = AssignmentQuestion(
    id: 'aq-1',
    assignmentId: 'assign-1',
    customContent: const {
      'type': 'essay',
      'text': 'Giải thích quá trình quang hợp',
    },
    points: 2,
    orderIdx: 0,
  );

  final answers = <Map<String, dynamic>>[
    {
      'answer_id': 'ans-1',
      'session_id': 's1',
      'student_id': 'st1',
      'student_name': 'Nguyễn Văn A',
      'answer': {'text': 'Quang hợp là...'},
      'ai_score': 1.5,
      'ai_confidence': 0.85,
      'final_score': null,
    },
    {
      'answer_id': 'ans-2',
      'session_id': 's2',
      'student_id': 'st2',
      'student_name': 'Trần Thị B',
      'answer': {'text': 'Cây xanh hấp thụ...'},
      'ai_score': 2.0,
      'ai_confidence': 0.9,
      'final_score': 2.0,
    },
  ];

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          batchGradeAssignmentQuestionsProvider(distributionId: distributionId)
              .overrideWith((ref) async => [question]),
          distributionAnswersByQuestionProvider(
            distributionId: distributionId,
            assignmentQuestionId: 'aq-1',
          ).overrideWith((ref) async => answers),
        ],
        child: const MaterialApp(
          home: BatchGradeByQuestionScreen(
            distributionId: distributionId,
            assignmentTitle: 'Bài tập Sinh học',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hiển thị tiêu đề màn hình', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Chấm theo câu'), findsOneWidget);
  });

  testWidgets('render các dòng học sinh', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Trần Thị B'), findsOneWidget);
    expect(find.byKey(const ValueKey('answer_row_ans-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('answer_row_ans-2')), findsOneWidget);
  });

  testWidgets('có nút "Duyệt tất cả điểm AI"', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Duyệt tất cả điểm AI'), findsOneWidget);
    expect(find.byKey(const ValueKey('approve_all_ai_button')), findsOneWidget);
  });

  testWidgets('hiển thị nội dung câu hỏi', (tester) async {
    await pumpScreen(tester);
    expect(find.textContaining('quang hợp'), findsWidgets);
  });

  // Bug 1 — câu reuse từ kho (question_id != null): datasource ForGrading đã
  // resolve type/text/choices từ bank vào custom_content. Màn phải render đúng
  // MCQ (không hiển nhầm thành essay "không có câu trả lời") và highlight
  // đáp án HS chọn qua key 'selected' (mảng index số nguyên).
  testWidgets('render câu MCQ reuse từ kho + selected index', (tester) async {
    const bankDistId = 'dist-bank';
    final bankQuestion = AssignmentQuestion(
      id: 'aq-bank',
      assignmentId: 'assign-1',
      questionId: 'q-bank-1',
      // Shape do getAssignmentQuestionsForGrading sản xuất: type snake_case,
      // text từ bank content, choices đã normalize {id, text, isCorrect}.
      customContent: const {
        'type': 'multiple_choice',
        'text': 'Thủ đô của Việt Nam là?',
        'choices': [
          {'id': 0, 'text': 'Hà Nội', 'isCorrect': true},
          {'id': 1, 'text': 'Đà Nẵng', 'isCorrect': false},
        ],
      },
      points: 1,
      orderIdx: 0,
    );

    final bankAnswers = <Map<String, dynamic>>[
      {
        'answer_id': 'ans-b1',
        'session_id': 'sb1',
        'student_id': 'stb1',
        'student_name': 'Lê Văn C',
        'answer': {'selected': [1]}, // chọn "Đà Nẵng" (sai)
        'ai_score': null,
        'ai_confidence': null,
        'final_score': null,
      },
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          batchGradeAssignmentQuestionsProvider(distributionId: bankDistId)
              .overrideWith((ref) async => [bankQuestion]),
          distributionAnswersByQuestionProvider(
            distributionId: bankDistId,
            assignmentQuestionId: 'aq-bank',
          ).overrideWith((ref) async => bankAnswers),
        ],
        child: const MaterialApp(
          home: BatchGradeByQuestionScreen(distributionId: bankDistId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Câu hỏi (text từ bank) hiển thị.
    expect(find.textContaining('Thủ đô'), findsWidgets);
    // Render dưới dạng MCQ: cả 2 lựa chọn hiện ra (KHÔNG phải essay
    // "Học sinh không có câu trả lời"). Choices render qua MathText (RichText)
    // → dùng textContaining/findsWidgets giống test có sẵn (line ~88).
    expect(find.textContaining('Hà Nội'), findsWidgets);
    expect(find.textContaining('Đà Nẵng'), findsWidgets);
    expect(find.text('Học sinh không có câu trả lời'), findsNothing);
  });
}

// ignore_for_file: depend_on_referenced_packages
import 'package:ai_mls/data/models/question_dto.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/staging_area_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helper — wraps StagingAreaWidget in a minimal test harness.
// ProviderScope needed because StagingAreaWidget is ConsumerStatefulWidget.
// ---------------------------------------------------------------------------
Widget _buildStagingArea({
  required List<QuestionDTO> questions,
  String? assignmentId,
  VoidCallback? onComplete,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: StagingAreaWidget(
          questions: questions,
          assignmentId: assignmentId,
          onComplete: onComplete ?? () {},
          scrollController: ScrollController(),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
final _sampleQuestion = QuestionDTO(
  type: 'multiple_choice',
  content: const {'text': 'Câu hỏi mẫu?'},
  choices: const [
    ChoiceDTO(id: 0, text: 'Đáp án A', isCorrect: false),
    ChoiceDTO(id: 1, text: 'Đáp án B', isCorrect: true),
  ],
  answer: const {'correct_index': 1},
  difficulty: 3,
);

void main() {
  group('StagingAreaWidget', () {
    // -----------------------------------------------------------------------
    // Display
    // -----------------------------------------------------------------------
    group('Display', () {
      testWidgets('hiển thị header với số câu hỏi', (tester) async {
        await tester.pumpWidget(_buildStagingArea(
          questions: [_sampleQuestion, _sampleQuestion],
        ));
        await tester.pump();
        expect(find.textContaining('2 câu'), findsOneWidget);
      });

      testWidgets('hiển thị nội dung câu hỏi', (tester) async {
        await tester.pumpWidget(_buildStagingArea(questions: [_sampleQuestion]));
        await tester.pumpAndSettle();
        expect(find.text('Câu hỏi mẫu?'), findsOneWidget);
      });

      testWidgets('hiển thị choices A và B', (tester) async {
        await tester.pumpWidget(_buildStagingArea(questions: [_sampleQuestion]));
        await tester.pumpAndSettle();
        expect(find.text('Đáp án A'), findsOneWidget);
        expect(find.text('Đáp án B'), findsOneWidget);
      });

      testWidgets('đánh dấu đáp án đúng — Đáp án B được highlight', (tester) async {
        // Choice index 1 has isCorrect=true AND answer.correct_index=1.
        // Widget renders text in DesignColors.success when isCorrect.
        // We verify the text itself is rendered (style verification is non-trivial).
        await tester.pumpWidget(_buildStagingArea(questions: [_sampleQuestion]));
        await tester.pump();
        final correctText = tester.widget<Text>(find.text('Đáp án B'));
        // Color should be DesignColors.success (Color(0xFF4CAF50))
        expect(correctText.style?.color, const Color(0xFF4CAF50));
      });

      testWidgets('hiển thị empty state khi questions rỗng', (tester) async {
        await tester.pumpWidget(_buildStagingArea(questions: []));
        await tester.pump();
        expect(find.text('Không có câu hỏi nào'), findsOneWidget);
      });

      testWidgets('hiển thị nhãn Câu 1, Câu 2', (tester) async {
        await tester.pumpWidget(_buildStagingArea(
          questions: [_sampleQuestion, _sampleQuestion],
        ));
        await tester.pump();
        expect(find.text('Câu 1'), findsOneWidget);
        expect(find.text('Câu 2'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Action buttons visibility (no Supabase calls triggered)
    // -----------------------------------------------------------------------
    group('Action buttons', () {
      testWidgets('nút Lưu vào Ngân hàng luôn visible', (tester) async {
        await tester.pumpWidget(_buildStagingArea(
          questions: [_sampleQuestion],
          assignmentId: null,
        ));
        await tester.pump();
        expect(find.text('Lưu vào Ngân hàng'), findsOneWidget);
      });

      testWidgets(
        'nút Lưu & Thêm vào Đề thi visible khi có assignmentId',
        (tester) async {
          await tester.pumpWidget(_buildStagingArea(
            questions: [_sampleQuestion],
            assignmentId: 'assignment-123',
          ));
          await tester.pump();
          expect(find.text('Lưu & Thêm vào Đề thi'), findsOneWidget);
        },
      );

      testWidgets(
        'nút Lưu & Thêm vào Đề thi KHÔNG hiện khi assignmentId null',
        (tester) async {
          await tester.pumpWidget(_buildStagingArea(
            questions: [_sampleQuestion],
            assignmentId: null,
          ));
          await tester.pump();
          expect(find.text('Lưu & Thêm vào Đề thi'), findsNothing);
        },
      );

      testWidgets(
        'tap Lưu vào Ngân hàng throw StateError — Supabase.instance không khởi tạo',
        (tester) async {
          markTestSkipped(
            'StagingAreaWidget gọi Supabase.instance.client.rpc() trực tiếp — '
            'cần refactor sang injectable provider trước khi test được save actions',
          );
        },
      );

      testWidgets(
        'double-tap guard — _isSaving ngăn gọi RPC lần hai',
        (tester) async {
          markTestSkipped(
            'StagingAreaWidget gọi Supabase.instance.client.rpc() trực tiếp — '
            'cần refactor sang injectable provider trước khi test được save guard',
          );
        },
      );

      testWidgets(
        'hiển thị CircularProgressIndicator trong nút khi đang saving',
        (tester) async {
          markTestSkipped(
            'StagingAreaWidget gọi Supabase.instance.client.rpc() trực tiếp — '
            'không thể trigger _isSaving=true mà không khởi tạo Supabase',
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // Question type labels
    // -----------------------------------------------------------------------
    group('Question type labels', () {
      testWidgets('multiple_choice hiển thị Trắc nghiệm', (tester) async {
        final q = QuestionDTO(
          type: 'multiple_choice',
          content: const {'text': 'Q'},
          answer: const {'correct_index': 0},
        );
        await tester.pumpWidget(_buildStagingArea(questions: [q]));
        await tester.pump();
        expect(find.text('Trắc nghiệm'), findsOneWidget);
      });

      testWidgets('true_false hiển thị Đúng/Sai', (tester) async {
        final q = QuestionDTO(
          type: 'true_false',
          content: const {'text': 'Q'},
          answer: const {'correct_text': 'true'},
        );
        await tester.pumpWidget(_buildStagingArea(questions: [q]));
        await tester.pump();
        expect(find.text('Đúng/Sai'), findsOneWidget);
      });

      testWidgets('short_answer hiển thị Trả lời ngắn', (tester) async {
        final q = QuestionDTO(
          type: 'short_answer',
          content: const {'text': 'Q'},
          answer: const {'correct_text': 'answer'},
        );
        await tester.pumpWidget(_buildStagingArea(questions: [q]));
        await tester.pump();
        expect(find.text('Trả lời ngắn'), findsOneWidget);
      });

      testWidgets('essay hiển thị Tự luận', (tester) async {
        final q = QuestionDTO(
          type: 'essay',
          content: const {'text': 'Q'},
          answer: const {},
        );
        await tester.pumpWidget(_buildStagingArea(questions: [q]));
        await tester.pump();
        expect(find.text('Tự luận'), findsOneWidget);
      });

      testWidgets('type lạ hiển thị chính type đó', (tester) async {
        final q = QuestionDTO(
          type: 'fill_blank',
          content: const {'text': 'Q'},
          answer: const {},
        );
        await tester.pumpWidget(_buildStagingArea(questions: [q]));
        await tester.pump();
        expect(find.text('fill_blank'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Difficulty label
    // -----------------------------------------------------------------------
    group('Difficulty', () {
      testWidgets('hiển thị Độ khó: 3/5 cho difficulty=3', (tester) async {
        await tester.pumpWidget(_buildStagingArea(questions: [_sampleQuestion]));
        await tester.pump();
        expect(find.text('Độ khó: 3/5'), findsOneWidget);
      });
    });
  });
}

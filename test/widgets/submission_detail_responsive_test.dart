// ignore_for_file: depend_on_referenced_packages
//
// Widget test cho bố trí responsive của Teacher Submission Detail Screen.
//
// CÁCH TIẾP CẬN (đã chọn):
// Màn hình thật (`TeacherSubmissionDetailScreen`) phụ thuộc rất nhiều provider
// (Supabase auth, teacherSubmissionDetailProvider, gradeOverrideHistoryProvider...),
// nên pump toàn bộ màn rất tốn công mock và dễ vỡ. Thay vào đó ta tách quyết định
// bố trí ra hàm top-level public `buildResponsiveQuestionBody(...)` trong chính
// file màn hình và test trực tiếp hàm đó với width giả lập — KHÔNG cần mock provider.
//
// Hàm này chính là thứ production gọi bên trong `LayoutBuilder`
// (`availableWidth: constraints.maxWidth`), nên test phản ánh đúng hành vi thật:
// - width >= 900  → Row có ValueKey('side_by_side_<index>')  (side-by-side)
// - width <  900  → Column, KHÔNG có Row key đó                (xếp dọc fallback)
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bọc widget cần test trong harness tối thiểu.
Widget _harness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  const index = 2;
  final questionPanel = Container(
    key: const ValueKey('test_question_content'),
    child: const Text('Nội dung câu hỏi'),
  );
  final gradingPanel = Container(
    key: const ValueKey('test_grading_content'),
    child: const Text('Khu vực chấm điểm'),
  );

  group('buildResponsiveQuestionBody', () {
    testWidgets('màn rộng (>=900, ~1200) dùng Row side-by-side với cả hai panel',
        (tester) async {
      await tester.pumpWidget(_harness(
        buildResponsiveQuestionBody(
          index: index,
          availableWidth: 1200,
          questionPanel: questionPanel,
          gradingPanel: gradingPanel,
        ),
      ));

      // Row side-by-side phải tồn tại.
      final sideBySide = find.byKey(const ValueKey('side_by_side_$index'));
      expect(sideBySide, findsOneWidget);

      // Widget gắn key đó phải là một Row.
      expect(tester.widget(sideBySide), isA<Row>());

      // Cả hai panel (đã bọc KeyedSubtree) đều có mặt bên trong.
      expect(find.byKey(const ValueKey('question_panel_$index')), findsOneWidget);
      expect(find.byKey(const ValueKey('grading_panel_$index')), findsOneWidget);

      // Hai panel nằm CÙNG trong Row side-by-side.
      expect(
        find.descendant(
          of: sideBySide,
          matching: find.byKey(const ValueKey('question_panel_$index')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sideBySide,
          matching: find.byKey(const ValueKey('grading_panel_$index')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('màn hẹp (<900, ~500) KHÔNG có Row side-by-side (xếp dọc)',
        (tester) async {
      await tester.pumpWidget(_harness(
        buildResponsiveQuestionBody(
          index: index,
          availableWidth: 500,
          questionPanel: questionPanel,
          gradingPanel: gradingPanel,
        ),
      ));

      // Row side-by-side phải VẮNG MẶT.
      expect(find.byKey(const ValueKey('side_by_side_$index')), findsNothing);

      // Nhưng hai panel vẫn render (xếp dọc), nội dung không mất.
      expect(find.byKey(const ValueKey('question_panel_$index')), findsOneWidget);
      expect(find.byKey(const ValueKey('grading_panel_$index')), findsOneWidget);
      expect(find.text('Nội dung câu hỏi'), findsOneWidget);
      expect(find.text('Khu vực chấm điểm'), findsOneWidget);
    });

    testWidgets('ngưỡng đúng 900 vẫn dùng side-by-side (>=)', (tester) async {
      await tester.pumpWidget(_harness(
        buildResponsiveQuestionBody(
          index: index,
          availableWidth: kSubmissionDetailSideBySideBreakpoint,
          questionPanel: questionPanel,
          gradingPanel: gradingPanel,
        ),
      ));

      expect(find.byKey(const ValueKey('side_by_side_$index')), findsOneWidget);
    });

    testWidgets('ngay dưới ngưỡng (899) xếp dọc', (tester) async {
      await tester.pumpWidget(_harness(
        buildResponsiveQuestionBody(
          index: index,
          availableWidth: kSubmissionDetailSideBySideBreakpoint - 1,
          questionPanel: questionPanel,
          gradingPanel: gradingPanel,
        ),
      ));

      expect(find.byKey(const ValueKey('side_by_side_$index')), findsNothing);
    });
  });
}

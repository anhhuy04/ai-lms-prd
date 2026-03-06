import 'package:ai_mls/domain/entities/recipient_tree_node.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Setup mock data based on the Matrix in walkthrough
  // s1 is in both Class 10A and Class 10B to test cross-class referencing

  const s1 = StudentNode(id: 's1', name: 'Student 1');
  const s2 = StudentNode(id: 's2', name: 'Student 2');
  const s3 = StudentNode(id: 's3', name: 'Student 3');
  const s4 = StudentNode(id: 's4', name: 'Student 4');

  final class10A = ClassNode(
    id: 'class_10A',
    name: 'Class 10A',
    totalStudents: 3,
    independentStudents: [s3], // s1, s2 in group, s3 is independent
    groups: [
      const GroupNode(id: 'group_gioi', name: 'Nhóm Giỏi', students: [s1, s2]),
    ],
  );

  final class10B = ClassNode(
    id: 'class_10B',
    name: 'Class 10B',
    totalStudents: 2,
    independentStudents: [s4], // s1 overlaps! s4 is independent
    groups: [
      const GroupNode(id: 'group_alpha', name: 'Nhóm Alpha', students: [s1]),
    ],
  );

  final class10C = ClassNode(
    id: 'class_10C',
    name: 'Class 10C',
    totalStudents: 2,
    independentStudents: [s3, s4], // No groups
    groups: const [],
  );

  final mockClasses = [class10A, class10B, class10C];

  Widget buildTestWidget({
    RecipientSelectionResult? intialSelection,
    required Function(RecipientSelectionResult) onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final result =
                    await showModalBottomSheet<RecipientSelectionResult>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => RecipientTreeSelectorModal(
                        initialSelection:
                            intialSelection ??
                            RecipientSelectionResult(
                              fullySelectedClassIds: {},
                              selectedGroupIdsByClass: {},
                              selectedStudentIdsByClass: {},
                            ),
                        data: mockClasses,
                        confirmText: 'Giao bài',
                      ),
                    );
                if (result != null) {
                  onConfirm(result);
                }
              },
              child: const Text('Open Modal'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('Test T1: Select fully Class 10A', (WidgetTester tester) async {
    RecipientSelectionResult? result;

    await tester.pumpWidget(buildTestWidget(onConfirm: (res) => result = res));

    // Mở modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Check (tick) Class 10A
    // Cần tìm Checkbox của Class 10A. Trong UI, nó là Checkbox ngay cạnh Tên lớp
    final class10ACheckbox = find.descendant(
      of: find
          .ancestor(of: find.text('Class 10A'), matching: find.byType(InkWell))
          .first,
      matching: find.byType(Checkbox),
    );
    await tester.tap(class10ACheckbox);
    await tester.pumpAndSettle();

    // Xác nhận giao bài
    await tester.tap(find.textContaining('Giao bài'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.fullySelectedClassIds, contains('class_10A'));
    expect(result!.selectedGroupIdsByClass, isEmpty);
    expect(result!.selectedStudentIdsByClass, isEmpty);
  });

  testWidgets(
    'Test Cross-Class Leak: Select s1 in 10A should NOT select s1 in 10B',
    (WidgetTester tester) async {
      RecipientSelectionResult? result;

      await tester.pumpWidget(
        buildTestWidget(onConfirm: (res) => result = res),
      );

      // Mở modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Mở rộng Class 10A và Class 10B
      await tester.tap(find.text('Class 10A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Class 10B'));
      await tester.pumpAndSettle();

      // Mở rộng Nhóm Giỏi (10A)
      await tester.tap(find.text('Nhóm Giỏi'));
      await tester.pumpAndSettle();

      // Mở rộng Nhóm Alpha (10B)
      await tester.tap(find.text('Nhóm Alpha'));
      await tester.pumpAndSettle();

      // Tìm Student 1 trong nhánh của Nhóm Giỏi (Class 10A)
      // Sẽ có 2 'Student 1' trên màn hình: một dưới Nhóm Giỏi, một dưới Nhóm Alpha
      // Test: click vào cái đầu tiên (thuộc 10A)
      final student1Checkboxes = find.descendant(
        of: find.ancestor(
          of: find.text('Student 1'),
          matching: find.byType(InkWell),
        ),
        matching: find.byType(Checkbox),
      );

      expect(student1Checkboxes, findsNWidgets(2));

      // Tick cái đầu tiên (s1 trong 10A)
      await tester.tap(student1Checkboxes.first);
      await tester.pumpAndSettle();

      // Chắc chắn cái thứ 2 (s1 trong 10B) KHÔNG BỊ TICK
      final secondCheckboxWidget = tester.widget<Checkbox>(
        student1Checkboxes.last,
      );
      expect(
        secondCheckboxWidget.value,
        isFalse,
      ); // <--- MUST BE FALSE, THIS PROVES NO LEAK

      // Xác nhận
      await tester.tap(find.textContaining('Giao bài'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.fullySelectedClassIds, isEmpty);
      expect(result!.selectedGroupIdsByClass, isEmpty);
      // Vì chỉ tick s1, không tick cả nhóm
      expect(result!.selectedStudentIdsByClass['class_10A'], contains('s1'));
      // Lớp 10B KHÔNG có s1 trong kết quả
      expect(
        result!.selectedStudentIdsByClass.containsKey('class_10B'),
        isFalse,
      );
    },
  );
}

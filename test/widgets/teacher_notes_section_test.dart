// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:ai_mls/domain/repositories/teacher_notes_repository.dart';
import 'package:ai_mls/presentation/providers/teacher_notes_provider.dart';
import 'package:ai_mls/presentation/views/grading/widgets/teacher_notes_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _studentId = 'student-1';

/// Repository giả luôn ném lỗi khi addNote — dùng cho test error path.
class _ThrowingTeacherNotesRepository implements TeacherNotesRepository {
  @override
  Future<List<TeacherNote>> getNotes(String studentId) async => [];

  @override
  Future<TeacherNote> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  }) async {
    throw Exception('add failed');
  }

  @override
  Future<TeacherNote> updateNote({
    required String id,
    required String content,
    bool? isPrivate,
  }) async {
    throw Exception('update failed');
  }

  @override
  Future<void> deleteNote(String id) async {
    throw Exception('delete failed');
  }
}

TeacherNote _makeNote({
  String id = 'n1',
  String content = 'Ghi chú mẫu',
  bool isPrivate = true,
}) {
  return TeacherNote(
    id: id,
    teacherId: 'teacher-1',
    studentId: _studentId,
    content: content,
    isPrivate: isPrivate,
    createdAt: DateTime(2026, 6, 1, 8),
    updatedAt: DateTime(2026, 6, 1, 9),
  );
}

/// Pump widget với override provider family teacherNotes.
/// [notes] == null → giữ trạng thái loading (Future không hoàn thành).
Widget _buildSection({List<TeacherNote>? notes}) {
  return ProviderScope(
    overrides: [
      teacherNotesProvider(studentId: _studentId).overrideWith(
        (ref) => notes == null
            ? Completer<List<TeacherNote>>().future
            : Future.value(notes),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TeacherNotesSection(studentId: _studentId),
        ),
      ),
    ),
  );
}

void main() {
  group('TeacherNotesSection', () {
    testWidgets('hiển thị tiêu đề Ghi chú của giáo viên', (tester) async {
      await tester.pumpWidget(_buildSection(notes: const []));
      await tester.pumpAndSettle();
      expect(find.text('Ghi chú của giáo viên'), findsOneWidget);
    });

    testWidgets('hiển thị nút Thêm ghi chú', (tester) async {
      await tester.pumpWidget(_buildSection(notes: const []));
      await tester.pumpAndSettle();
      expect(find.text('Thêm ghi chú'), findsOneWidget);
    });

    testWidgets('hiển thị empty state khi không có ghi chú', (tester) async {
      await tester.pumpWidget(_buildSection(notes: const []));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có ghi chú'), findsOneWidget);
    });

    testWidgets('hiển thị nội dung các ghi chú', (tester) async {
      final notes = [
        _makeNote(id: 'n1', content: 'Ghi chú một'),
        _makeNote(id: 'n2', content: 'Ghi chú hai'),
      ];
      await tester.pumpWidget(_buildSection(notes: notes));
      await tester.pumpAndSettle();

      expect(find.text('Ghi chú một'), findsOneWidget);
      expect(find.text('Ghi chú hai'), findsOneWidget);
      // Empty state không xuất hiện khi có ghi chú
      expect(find.text('Chưa có ghi chú'), findsNothing);
    });

    testWidgets('hiển thị badge Riêng tư cho ghi chú private', (tester) async {
      final notes = [_makeNote(id: 'n1', content: 'A', isPrivate: true)];
      await tester.pumpWidget(_buildSection(notes: notes));
      await tester.pumpAndSettle();
      expect(find.text('Riêng tư'), findsOneWidget);
    });

    testWidgets('KHÔNG hiển thị badge Riêng tư cho ghi chú công khai',
        (tester) async {
      final notes = [_makeNote(id: 'n1', content: 'A', isPrivate: false)];
      await tester.pumpWidget(_buildSection(notes: notes));
      await tester.pumpAndSettle();
      expect(find.text('Riêng tư'), findsNothing);
    });

    testWidgets('mở dialog khi nhấn Thêm ghi chú', (tester) async {
      await tester.pumpWidget(_buildSection(notes: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thêm ghi chú'));
      await tester.pumpAndSettle();

      // Dialog hiện với tiêu đề và hint của TextField
      expect(find.text('Thêm ghi chú'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });

    testWidgets('hiện SnackBar lỗi khi lưu ghi chú thất bại', (tester) async {
      // Override repository (đường đi mutation đi qua provider này) để ném lỗi.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teacherNotesProvider(studentId: _studentId)
                .overrideWith((ref) => Future.value(const <TeacherNote>[])),
            teacherNotesRepositoryProvider
                .overrideWith((ref) => _ThrowingTeacherNotesRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TeacherNotesSection(studentId: _studentId),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mở dialog thêm ghi chú.
      await tester.tap(find.text('Thêm ghi chú'));
      await tester.pumpAndSettle();

      // Nhập nội dung rồi nhấn Thêm.
      await tester.enterText(find.byType(TextField), 'Nội dung test');
      await tester.tap(find.text('Thêm'));
      await tester.pumpAndSettle();

      // SnackBar lỗi xuất hiện, không giả vờ thành công.
      expect(find.text('Không thể lưu ghi chú'), findsOneWidget);
      expect(find.text('Đã lưu ghi chú'), findsNothing);
    });
  });
}

// ignore_for_file: depend_on_referenced_packages
import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:ai_mls/domain/repositories/teacher_notes_repository.dart';
import 'package:ai_mls/presentation/providers/teacher_notes_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

/// Fake repository giữ state in-memory để kiểm tra reload sau mutation.
class _FakeTeacherNotesRepository implements TeacherNotesRepository {
  final List<TeacherNote> _notes;
  int getNotesCallCount = 0;

  _FakeTeacherNotesRepository(this._notes);

  @override
  Future<List<TeacherNote>> getNotes(String studentId) async {
    getNotesCallCount++;
    return _notes.where((n) => n.studentId == studentId).toList();
  }

  @override
  Future<TeacherNote> addNote({
    required String studentId,
    required String content,
    bool isPrivate = true,
  }) async {
    final note = TeacherNote(
      id: 'note-${_notes.length + 1}',
      teacherId: 'teacher-1',
      studentId: studentId,
      content: content,
      isPrivate: isPrivate,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<TeacherNote> updateNote({
    required String id,
    required String content,
    bool? isPrivate,
  }) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    final updated = _notes[idx].copyWith(content: content);
    _notes[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }
}

/// Fake repository luôn ném lỗi — dùng để kiểm tra error path của mutation.
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
  String studentId = 'student-1',
  String content = 'Ghi chú mẫu',
  bool isPrivate = true,
}) {
  return TeacherNote(
    id: id,
    teacherId: 'teacher-1',
    studentId: studentId,
    content: content,
    isPrivate: isPrivate,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 1),
  );
}

void main() {
  const studentId = 'student-1';

  ProviderContainer makeContainer(TeacherNotesRepository fake) {
    final container = ProviderContainer(
      overrides: [
        // autoDispose @riverpod provider → dùng overrideWith (không overrideWithValue)
        teacherNotesRepositoryProvider.overrideWith((ref) => fake),
      ],
    );
    addTearDown(container.dispose);
    // Giữ subscription để autoDispose không dispose notifier/provider giữa chừng await
    container.listen(teacherNotesNotifierProvider, (_, __) {});
    container.listen(
      teacherNotesProvider(studentId: studentId),
      (_, __) {},
    );
    return container;
  }

  group('teacherNotesProvider', () {
    test('load danh sách ghi chú từ repository', () async {
      final fake = _FakeTeacherNotesRepository([
        _makeNote(id: 'n1', content: 'A'),
        _makeNote(id: 'n2', content: 'B'),
      ]);
      final container = makeContainer(fake);

      final notes = await container
          .read(teacherNotesProvider(studentId: studentId).future);

      expect(notes.length, equals(2));
      expect(notes.map((n) => n.content), containsAll(['A', 'B']));
    });

    test('trả danh sách rỗng khi không có ghi chú', () async {
      final fake = _FakeTeacherNotesRepository([]);
      final container = makeContainer(fake);

      final notes = await container
          .read(teacherNotesProvider(studentId: studentId).future);

      expect(notes, isEmpty);
    });
  });

  group('TeacherNotesNotifier', () {
    test('addNote thêm ghi chú và trigger reload', () async {
      final fake = _FakeTeacherNotesRepository([_makeNote(id: 'n1')]);
      final container = makeContainer(fake);

      // Load lần đầu
      final before = await container
          .read(teacherNotesProvider(studentId: studentId).future);
      expect(before.length, equals(1));

      // Thêm ghi chú (notifier KHÔNG còn tự invalidate — widget mới làm việc đó)
      await container
          .read(teacherNotesNotifierProvider.notifier)
          .addNote(studentId: studentId, content: 'Mới');

      // Giả lập việc widget invalidate read-provider bằng ref còn sống của nó.
      container.invalidate(teacherNotesProvider(studentId: studentId));

      // Sau invalidate, đọc lại provider → danh sách reload từ repository
      final after = await container
          .read(teacherNotesProvider(studentId: studentId).future);
      expect(after.length, equals(2));
      expect(after.map((n) => n.content), contains('Mới'));
      // getNotes được gọi lại (reload) sau mutation
      expect(fake.getNotesCallCount, greaterThanOrEqualTo(2));
    });

    test('deleteNote xóa ghi chú và reload', () async {
      final fake = _FakeTeacherNotesRepository([
        _makeNote(id: 'n1'),
        _makeNote(id: 'n2'),
      ]);
      final container = makeContainer(fake);

      await container
          .read(teacherNotesProvider(studentId: studentId).future);

      await container
          .read(teacherNotesNotifierProvider.notifier)
          .deleteNote(id: 'n1', studentId: studentId);

      // Giả lập việc widget invalidate read-provider sau mutation.
      container.invalidate(teacherNotesProvider(studentId: studentId));

      final after = await container
          .read(teacherNotesProvider(studentId: studentId).future);
      expect(after.length, equals(1));
      expect(after.first.id, equals('n2'));
    });

    test('addNote ném exception khi repository thất bại', () async {
      final fake = _ThrowingTeacherNotesRepository();
      final container = makeContainer(fake);

      await expectLater(
        container
            .read(teacherNotesNotifierProvider.notifier)
            .addNote(studentId: studentId, content: 'Mới'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

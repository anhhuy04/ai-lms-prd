// ignore_for_file: depend_on_referenced_packages
import 'package:ai_mls/data/datasources/teacher_notes_datasource.dart';
import 'package:ai_mls/data/models/teacher_note_dto.dart';
import 'package:flutter_test/flutter_test.dart';

// Theo precedent của repo (teacher_file_datasource_test, recommendation_datasource_test):
// các method gọi Supabase fluent chain KHÔNG được mock (brittle) — chỉ skip-stub.
// Phần pure-Dart (DTO fromJson/toJson/toEntity/toInsertJson) được test đầy đủ.

void main() {
  group('TeacherNoteDto', () {
    final sampleJson = {
      'id': 'note-uuid-001',
      'teacher_id': 'teacher-id',
      'student_id': 'student-id',
      'content': 'Học sinh tiến bộ rõ rệt ở phần đại số.',
      'is_private': true,
      'created_at': '2026-06-01T08:00:00Z',
      'updated_at': '2026-06-01T09:30:00Z',
    };

    test('fromJson parse đúng tất cả field (snake_case → camelCase)', () {
      final dto = TeacherNoteDto.fromJson(sampleJson);

      expect(dto.id, equals('note-uuid-001'));
      expect(dto.teacherId, equals('teacher-id'));
      expect(dto.studentId, equals('student-id'));
      expect(dto.content, equals('Học sinh tiến bộ rõ rệt ở phần đại số.'));
      expect(dto.isPrivate, isTrue);
      expect(dto.createdAt, equals(DateTime.parse('2026-06-01T08:00:00Z')));
      expect(dto.updatedAt, equals(DateTime.parse('2026-06-01T09:30:00Z')));
    });

    test('fromJson dùng default is_private=true khi field absent', () {
      final jsonWithoutPrivate = Map<String, dynamic>.from(sampleJson)
        ..remove('is_private');
      final dto = TeacherNoteDto.fromJson(jsonWithoutPrivate);
      expect(dto.isPrivate, isTrue);
    });

    test('toEntity map đúng sang domain entity', () {
      final dto = TeacherNoteDto.fromJson(sampleJson);
      final entity = dto.toEntity();

      expect(entity.id, equals(dto.id));
      expect(entity.teacherId, equals(dto.teacherId));
      expect(entity.studentId, equals(dto.studentId));
      expect(entity.content, equals(dto.content));
      expect(entity.isPrivate, equals(dto.isPrivate));
      expect(entity.createdAt, equals(dto.createdAt));
      expect(entity.updatedAt, equals(dto.updatedAt));
    });

    test('toInsertJson chỉ chứa content, student_id, is_private', () {
      final dto = TeacherNoteDto.fromJson(sampleJson);
      final insert = dto.toInsertJson();

      expect(insert.keys.toSet(),
          equals({'content', 'student_id', 'is_private'}));
      expect(insert['content'], equals(dto.content));
      expect(insert['student_id'], equals(dto.studentId));
      expect(insert['is_private'], equals(dto.isPrivate));
      // Không leak id / teacher_id / created_at / updated_at (DB / server-side set)
      expect(insert.containsKey('id'), isFalse);
      expect(insert.containsKey('teacher_id'), isFalse);
      expect(insert.containsKey('created_at'), isFalse);
      expect(insert.containsKey('updated_at'), isFalse);
    });

    test('toJson produces snake_case keys', () {
      final dto = TeacherNoteDto.fromJson(sampleJson);
      final json = dto.toJson();

      expect(json.containsKey('teacher_id'), isTrue);
      expect(json.containsKey('student_id'), isTrue);
      expect(json.containsKey('is_private'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('updated_at'), isTrue);
      // camelCase keys không xuất hiện
      expect(json.containsKey('teacherId'), isFalse);
      expect(json.containsKey('studentId'), isFalse);
    });

    test('copyWith thay đổi field immutably', () {
      final dto = TeacherNoteDto.fromJson(sampleJson);
      final updated = dto.copyWith(content: 'Nội dung mới');

      expect(updated.content, equals('Nội dung mới'));
      expect(dto.content, equals('Học sinh tiến bộ rõ rệt ở phần đại số.'));
    });

    test('equality: hai DTO cùng data là equal (Freezed ==)', () {
      final a = TeacherNoteDto.fromJson(sampleJson);
      final b = TeacherNoteDto.fromJson(Map<String, dynamic>.from(sampleJson));
      expect(a, equals(b));
    });
  });

  // ---------------------------------------------------------------------------
  // Datasource Supabase integration — skip stubs (cần live Supabase)
  // ---------------------------------------------------------------------------
  group('TeacherNotesDataSource', () {
    test('có thể khởi tạo (compile-time check)', () {
      final ds = TeacherNotesDataSource();
      expect(ds, isNotNull);
    });

    test(
      'getNotes select theo student_id, order updated_at desc',
      skip: 'Requires live Supabase — kept as stub',
      () async {},
    );
    test(
      'addNote insert với teacher_id = auth user id, trả row mới',
      skip: 'Requires live Supabase — kept as stub',
      () async {},
    );
    test(
      'updateNote update content/is_private theo id, trả row mới',
      skip: 'Requires live Supabase — kept as stub',
      () async {},
    );
    test(
      'deleteNote xóa theo id',
      skip: 'Requires live Supabase — kept as stub',
      () async {},
    );
  });
}

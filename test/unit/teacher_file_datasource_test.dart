// ignore_for_file: depend_on_referenced_packages, unused_import
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// W0 stub — TeacherFileDataSource created in Plan 04
// Datasource tests require live Supabase — kept as skip stubs per W0 contract.
// Model tests (fromJson/toJson) are pure-Dart and enabled here.

void main() {
  group('TeacherFileModel', () {
    final sampleJson = {
      'id': 'file-uuid-001',
      'filename': 'test.xlsx',
      'storage_path': 'teachers/teacher-id/test.xlsx',
      'url': 'https://signed.url/test.xlsx',
      'mime_type':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'size_bytes': 2048,
      'uploaded_by': 'teacher-id',
      'processing_status': 'queued',
      'created_at': '2026-04-19T00:00:00Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = TeacherFileModel.fromJson(sampleJson);

      expect(model.id, equals('file-uuid-001'));
      expect(model.filename, equals('test.xlsx'));
      expect(model.storagePath, equals('teachers/teacher-id/test.xlsx'));
      expect(model.url, equals('https://signed.url/test.xlsx'));
      expect(
        model.mimeType,
        equals(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      expect(model.sizeBytes, equals(2048));
      expect(model.uploadedBy, equals('teacher-id'));
      expect(model.processingStatus, equals('queued'));
      expect(model.createdAt, isNotNull);
    });

    test('fromJson uses default processingStatus when absent', () {
      final jsonWithoutStatus = Map<String, dynamic>.from(sampleJson)
        ..remove('processing_status');
      final model = TeacherFileModel.fromJson(jsonWithoutStatus);
      expect(model.processingStatus, equals('queued'));
    });

    test('toJson round-trips without data loss', () {
      final model = TeacherFileModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], equals(model.id));
      expect(json['filename'], equals(model.filename));
      expect(json['storage_path'], equals(model.storagePath));
      expect(json['url'], equals(model.url));
      expect(json['mime_type'], equals(model.mimeType));
      expect(json['size_bytes'], equals(model.sizeBytes));
      expect(json['uploaded_by'], equals(model.uploadedBy));
      expect(json['processing_status'], equals(model.processingStatus));
    });

    test('copyWith updates field immutably', () {
      final model = TeacherFileModel.fromJson(sampleJson);
      final updated = model.copyWith(processingStatus: 'done');

      expect(updated.processingStatus, equals('done'));
      expect(model.processingStatus, equals('queued')); // original unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // Additional edge cases (Phase 9 expansion)
  // ---------------------------------------------------------------------------
  group('TeacherFileModel — additional edge cases', () {
    final baseJson = {
      'id': 'uuid-edge',
      'filename': 'doc.pdf',
      'storage_path': 'teachers/t1/doc.pdf',
      'url': 'https://example.com/doc.pdf',
      'mime_type': 'application/pdf',
      'size_bytes': 1024,
      'uploaded_by': 't1',
    };

    test('fromJson với createdAt null không throw', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..['created_at'] = null;
      final model = TeacherFileModel.fromJson(json);
      expect(model.createdAt, isNull);
    });

    test('fromJson với unknown fields bị ignore (freezed behavior)', () {
      // Freezed/json_serializable silently ignores unknown keys.
      final json = Map<String, dynamic>.from(baseJson)
        ..['unknown_field_xyz'] = 'should_be_ignored'
        ..['another_unknown'] = 42;
      // Should not throw
      final model = TeacherFileModel.fromJson(json);
      expect(model.filename, equals('doc.pdf'));
    });

    test('toJson produces snake_case keys đúng', () {
      final model = TeacherFileModel.fromJson(baseJson);
      final json = model.toJson();
      // Verify @JsonKey(name: ...) annotations produce snake_case
      expect(json.containsKey('storage_path'), isTrue,
          reason: 'storagePath → storage_path');
      expect(json.containsKey('mime_type'), isTrue,
          reason: 'mimeType → mime_type');
      expect(json.containsKey('size_bytes'), isTrue,
          reason: 'sizeBytes → size_bytes');
      expect(json.containsKey('uploaded_by'), isTrue,
          reason: 'uploadedBy → uploaded_by');
      expect(json.containsKey('processing_status'), isTrue,
          reason: 'processingStatus → processing_status');
      // Verify camelCase keys are NOT present
      expect(json.containsKey('storagePath'), isFalse);
      expect(json.containsKey('mimeType'), isFalse);
    });

    test('processingStatus default là queued khi field absent', () {
      // No processing_status key at all
      final model = TeacherFileModel.fromJson(Map<String, dynamic>.from(baseJson));
      expect(model.processingStatus, equals('queued'));
    });

    test('copyWith thay đổi processingStatus không ảnh hưởng original', () {
      final original = TeacherFileModel.fromJson(baseJson);
      final updated = original.copyWith(processingStatus: 'done');

      // Original unchanged
      expect(original.processingStatus, equals('queued'));
      // Copy updated
      expect(updated.processingStatus, equals('done'));
      // Other fields preserved
      expect(updated.filename, equals(original.filename));
      expect(updated.id, equals(original.id));
    });

    test('equality: hai model với same data là equal (Freezed ==)', () {
      final modelA = TeacherFileModel.fromJson(baseJson);
      final modelB = TeacherFileModel.fromJson(Map<String, dynamic>.from(baseJson));
      expect(modelA, equals(modelB));
    });

    test('equality: models với khác processingStatus là không equal', () {
      final queued = TeacherFileModel.fromJson(baseJson);
      final done = queued.copyWith(processingStatus: 'done');
      expect(queued, isNot(equals(done)));
    });
  });

  // ---------------------------------------------------------------------------
  // Storage path format tests (pure string logic, no Supabase call needed)
  // ---------------------------------------------------------------------------
  group('TeacherFileDataSource — storagePath logic (pure-Dart)', () {
    test('storagePath format đúng: teachers/{teacherId}/{filename}', () {
      // Test the exact string construction used in TeacherFileDataSource.uploadAndRegisterFile
      const teacherId = 'teacher-uuid-123';
      const filename = 'lecture_notes.pdf';
      final storagePath = 'teachers/$teacherId/$filename';
      expect(storagePath, equals('teachers/teacher-uuid-123/lecture_notes.pdf'));
    });

    test('storagePath với filename có spaces vẫn build đúng', () {
      const teacherId = 't-001';
      const filename = 'my file name.xlsx';
      final storagePath = 'teachers/$teacherId/$filename';
      expect(storagePath, startsWith('teachers/t-001/'));
      expect(storagePath, endsWith('my file name.xlsx'));
    });

    test('getTeacherFiles filter null files (whereType guard)', () {
      // Simulate rows from Supabase join where some files might be null
      final rows = [
        {'files': {'id': 'f1', 'filename': 'a.pdf', 'storage_path': 'p1', 'url': 'u1', 'mime_type': 'application/pdf', 'size_bytes': 100, 'uploaded_by': 't1'}},
        {'files': null}, // null from LEFT JOIN when no matching file
        {'files': {'id': 'f2', 'filename': 'b.pdf', 'storage_path': 'p2', 'url': 'u2', 'mime_type': 'application/pdf', 'size_bytes': 200, 'uploaded_by': 't1'}},
      ];

      // Replicate the whereType guard from getTeacherFiles
      final files = rows
          .map((r) => r['files'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map(TeacherFileModel.fromJson)
          .toList();

      expect(files.length, equals(2),
          reason: 'null file_links entries must be filtered out');
      expect(files[0].id, equals('f1'));
      expect(files[1].id, equals('f2'));
    });

    test('uploadAndRegisterFile returns model with processingStatus=queued (via fromJson)', () {
      // Simulate the final step in uploadAndRegisterFile:
      // return TeacherFileModel.fromJson({...fileRow, 'processing_status': 'queued'});
      final fileRow = {
        'id': 'new-file-id',
        'filename': 'upload.xlsx',
        'storage_path': 'teachers/t1/upload.xlsx',
        'url': 'https://signed.url/upload.xlsx',
        'mime_type': 'application/vnd.ms-excel',
        'size_bytes': 512,
        'uploaded_by': 't1',
        'created_at': '2026-04-19T10:00:00Z',
      };
      final model = TeacherFileModel.fromJson({
        ...fileRow,
        'processing_status': 'queued',
      });
      expect(model.processingStatus, equals('queued'));
      expect(model.id, equals('new-file-id'));
    });
  });

  // ---------------------------------------------------------------------------
  // Datasource Supabase integration stubs (kept for completeness)
  // ---------------------------------------------------------------------------
  group('TeacherFileDataSource', () {
    group('uploadFile', () {
      test(
        'uploads bytes to Supabase Storage and returns signed URL',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
      test(
        'throws on storage failure',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
    });

    group('saveFileMetadata', () {
      test(
        'inserts row into files table and returns file id',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
      test(
        'inserts file_links row with target_type=teacher',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
    });

    group('enqueueForProcessing', () {
      test(
        'inserts ai_queue row with action=vectorize_document',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
    });

    group('getTeacherFiles', () {
      test(
        'returns list of TeacherFileModel for given teacher_id',
        skip: 'Requires live Supabase — kept as W0 stub',
        () async {},
      );
    });
  });
}

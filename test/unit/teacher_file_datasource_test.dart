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

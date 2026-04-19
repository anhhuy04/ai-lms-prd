// ignore_for_file: depend_on_referenced_packages, unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// W0 stub — TeacherFileDataSource will be created in Plan 04
// import 'package:ai_mls/data/datasources/teacher_file_datasource.dart';

void main() {
  group('TeacherFileDataSource', () {
    group('uploadFile', () {
      test(
        'uploads bytes to Supabase Storage and returns public URL',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
      test(
        'throws FileUploadException on storage failure',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
    });

    group('saveFileMetadata', () {
      test(
        'inserts row into files table and returns file id',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
      test(
        'inserts file_links row with target_type=teacher',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
    });

    group('enqueueForProcessing', () {
      test(
        'inserts ai_queue row with action=vectorize_document',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
    });

    group('getTeacherFiles', () {
      test(
        'returns list of TeacherFileModel for given teacher_id',
        skip: 'W0 stub — implement when TeacherFileDataSource exists (Plan 04)',
        () async {},
      );
    });
  });
}

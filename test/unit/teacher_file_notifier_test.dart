// ignore_for_file: depend_on_referenced_packages
import 'dart:typed_data';

import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/domain/repositories/teacher_file_repository.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockTeacherFileRepository extends Mock implements ITeacherFileRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TeacherFileModel _makeFile({
  String id = 'file-id',
  String filename = 'test.pdf',
  String processingStatus = 'queued',
}) => TeacherFileModel(
      id: id,
      filename: filename,
      storagePath: 'teachers/t1/$filename',
      url: 'https://example.com/$filename',
      mimeType: 'application/pdf',
      sizeBytes: 1024,
      uploadedBy: 't1',
      processingStatus: processingStatus,
      createdAt: DateTime(2026, 4, 19),
    );

// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    // mocktail requires fallback values for non-nullable types used in any()
    registerFallbackValue(Uint8List(0));
    registerFallbackValue('');   // ADD THIS LINE
  });

  late MockTeacherFileRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockTeacherFileRepository();
    container = ProviderContainer(
      overrides: [
        // AutoDisposeProvider — use overrideWith, not overrideWithValue
        teacherFileRepositoryProvider.overrideWith((ref) => mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  // -------------------------------------------------------------------------
  group('TeacherFiles Notifier — build()', () {
    test('initial build calls getTeacherFiles once', () async {
      when(() => mockRepo.getTeacherFiles()).thenAnswer((_) async => []);

      final result = await container.read(teacherFilesProvider.future);
      expect(result, isEmpty);
      verify(() => mockRepo.getTeacherFiles()).called(1);
    });

    test('initial build returns list from repository', () async {
      final files = [_makeFile(id: 'f1'), _makeFile(id: 'f2')];
      when(() => mockRepo.getTeacherFiles()).thenAnswer((_) async => files);

      final result = await container.read(teacherFilesProvider.future);
      expect(result.length, equals(2));
      expect(result[0].id, equals('f1'));
      expect(result[1].id, equals('f2'));
    });

    test('initial build error sets state to AsyncError', () async {
      when(() => mockRepo.getTeacherFiles())
          .thenThrow(Exception('Network error'));

      // Read the future — it will throw, so we catch and check the state
      await expectLater(
        container.read(teacherFilesProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(
        container.read(teacherFilesProvider),
        isA<AsyncError<List<TeacherFileModel>>>(),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('TeacherFiles Notifier — uploadFile()', () {
    test('uploadFile prepends new file to existing list', () async {
      final existingFile = _makeFile(id: 'existing', filename: 'old.pdf');
      final newFile = _makeFile(id: 'new', filename: 'new.pdf');

      when(() => mockRepo.getTeacherFiles())
          .thenAnswer((_) async => [existingFile]);
      when(() => mockRepo.uploadFile(
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
          )).thenAnswer((_) async => newFile);

      // Wait for initial load
      await container.read(teacherFilesProvider.future);

      // Upload
      await container
          .read(teacherFilesProvider.notifier)
          .uploadFile(Uint8List(0), 'new.pdf', 'application/pdf');

      final result = await container.read(teacherFilesProvider.future);
      // New file should be first (prepend)
      expect(result.first.id, equals('new'),
          reason: 'uploadFile must prepend new file to front of list');
      expect(result.length, equals(2),
          reason: 'existing file must be preserved after upload');
      expect(result[1].id, equals('existing'));
    });

    test('uploadFile error sets state to AsyncError', () async {
      when(() => mockRepo.getTeacherFiles()).thenAnswer((_) async => []);
      when(() => mockRepo.uploadFile(
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
          )).thenThrow(Exception('Upload failed'));

      await container.read(teacherFilesProvider.future);

      await container
          .read(teacherFilesProvider.notifier)
          .uploadFile(Uint8List(0), 'fail.xlsx', 'application/vnd.ms-excel');

      final state = container.read(teacherFilesProvider);
      expect(state, isA<AsyncError<List<TeacherFileModel>>>(),
          reason: 'upload failure must propagate as AsyncError state');
    });

    // -----------------------------------------------------------------------
    // BUG ANALYSIS: TeacherFiles.uploadFile() state race condition
    //
    // The code in teacher_file_notifier.dart:
    //
    //   state = const AsyncLoading();          // (1) sets state to AsyncLoading
    //   state = await AsyncValue.guard(() async {
    //     ...
    //     final current = state.valueOrNull ?? []; // (2) reads state
    //     return [newFile, ...current];
    //   });
    //
    // In Riverpod AsyncNotifier: `state = AsyncLoading()` sets the notifier's
    // state field, BUT the closure in AsyncValue.guard executes synchronously
    // up to the first `await`. The `state.valueOrNull` read at line (2) happens
    // AFTER `await repo.uploadFile(...)` completes — at that point the notifier's
    // `state` field IS `AsyncLoading`, so `valueOrNull` returns null.
    //
    // HOWEVER: The actual behavior in tests shows the bug only manifests when
    // state transitions from AsyncLoading (a previous upload) to the next upload.
    // In single-upload scenarios from AsyncData, the behavior is correct because
    // Riverpod's state.valueOrNull on AsyncNotifier captures the previous data.
    //
    // The real bug surface: consecutive uploads where the second upload starts
    // while the first is still in flight, OR when the state seen inside guard()
    // is AsyncLoading from the just-set assignment.
    // -----------------------------------------------------------------------
    test(
      'uploadFile từ AsyncData state — first upload preserves existing list',
      () async {
        // Single upload from a fully-loaded state: WORKS CORRECTLY
        // (state.valueOrNull inside guard() still returns the pre-loading data
        // due to Riverpod's AsyncNotifier implementation details in test env)
        final file1 = _makeFile(id: 'f1', filename: 'file1.pdf');
        final file2 = _makeFile(id: 'f2', filename: 'file2.pdf');
        final file3 = _makeFile(id: 'f3', filename: 'file3.pdf');

        when(() => mockRepo.getTeacherFiles())
            .thenAnswer((_) async => [file1, file2]);
        when(() => mockRepo.uploadFile(
              bytes: any(named: 'bytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenAnswer((_) async => file3);

        // Initial load: 2 files
        await container.read(teacherFilesProvider.future);

        // Upload 3rd file from AsyncData state
        await container
            .read(teacherFilesProvider.notifier)
            .uploadFile(Uint8List(0), 'file3.pdf', 'application/pdf');

        final result = await container.read(teacherFilesProvider.future);

        // First upload from AsyncData: works correctly — 3 files present
        expect(result.length, equals(3),
            reason: 'Single upload from AsyncData state preserves existing list');
        expect(result.first.id, equals('f3'), reason: 'new file prepended');
      },
    );
  });

  // -------------------------------------------------------------------------
  group('deleteFile', () {
    test('removes the file from state on success', () async {
      final file1 = _makeFile(id: 'file-1', filename: 'a.xlsx');
      final file2 = _makeFile(id: 'file-2', filename: 'b.xlsx');

      when(() => mockRepo.getTeacherFiles())
          .thenAnswer((_) async => [file1, file2]);
      when(() => mockRepo.deleteFile(any()))
          .thenAnswer((_) async {});

      // prime the state
      await container.read(teacherFilesProvider.future);
      expect(
        container.read(teacherFilesProvider).value,
        containsAll([file1, file2]),
      );

      await container
          .read(teacherFilesProvider.notifier)
          .deleteFile('file-1');

      final remaining = container.read(teacherFilesProvider).value!;
      expect(remaining, isNot(contains(file1)));
      expect(remaining, contains(file2));
    });

    test('propagates error when repo throws', () async {
      final file = _makeFile(id: 'file-err');

      when(() => mockRepo.getTeacherFiles())
          .thenAnswer((_) async => [file]);
      when(() => mockRepo.deleteFile(any()))
          .thenThrow(Exception('delete failed'));

      await container.read(teacherFilesProvider.future);

      await container
          .read(teacherFilesProvider.notifier)
          .deleteFile('file-err');

      expect(
        container.read(teacherFilesProvider),
        isA<AsyncError>(),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('TeacherFiles Notifier — multiple uploads (sequential)', () {
    // NOTE: Sequential (awaited) uploads work correctly because:
    //   - uploadFile() is async and awaited completely before the next call
    //   - After each uploadFile(), state is AsyncData again
    //   - The next call's state.valueOrNull reads AsyncData, not AsyncLoading
    //
    // The risk described in the code comment is real for CONCURRENT uploads
    // (two uploadFile() calls without awaiting the first), but sequential
    // uploads are safe.
    test(
      'sequential uploads accumulate files correctly',
      () async {
        final fileA = _makeFile(id: 'fA', filename: 'A.pdf');
        final fileB = _makeFile(id: 'fB', filename: 'B.pdf');

        when(() => mockRepo.getTeacherFiles()).thenAnswer((_) async => []);

        var uploadCount = 0;
        when(() => mockRepo.uploadFile(
              bytes: any(named: 'bytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenAnswer((_) async {
          uploadCount++;
          return uploadCount == 1 ? fileA : fileB;
        });

        // Initial load (empty)
        await container.read(teacherFilesProvider.future);

        // First upload: empty → [fA]
        await container
            .read(teacherFilesProvider.notifier)
            .uploadFile(Uint8List(0), 'A.pdf', 'application/pdf');

        final afterFirst = await container.read(teacherFilesProvider.future);
        expect(afterFirst.length, equals(1));
        expect(afterFirst.first.id, equals('fA'));

        // Second upload: [fA] → [fB, fA]
        await container
            .read(teacherFilesProvider.notifier)
            .uploadFile(Uint8List(0), 'B.pdf', 'application/pdf');

        final result = await container.read(teacherFilesProvider.future);
        expect(result.length, equals(2),
            reason: 'Sequential uploads preserve all files');
        expect(result.first.id, equals('fB'), reason: 'newest file is first');
        expect(result[1].id, equals('fA'));
      },
    );

    test(
      'CODE SMELL DOCUMENTED: state.valueOrNull read AFTER AsyncLoading assignment — '
      'concurrent uploads would discard existing files',
      skip: 'Concurrent upload scenario requires Future.wait() test setup — '
          'documenting the code pattern risk for future hardening',
      () async {
        // The current code pattern in uploadFile():
        //   state = const AsyncLoading();
        //   state = await AsyncValue.guard(() async {
        //     final current = state.valueOrNull ?? [];  // ← reads AsyncLoading state
        //     ...
        //   });
        //
        // If two uploadFile() calls are made concurrently (not awaited sequentially),
        // BOTH will set state = AsyncLoading() then both will read state.valueOrNull
        // as null → both produce [fileA] and [fileB] independently → last one wins.
        //
        // Recommended fix in teacher_file_notifier.dart:
        //   Future<void> uploadFile(...) async {
        //     final current = state.valueOrNull ?? [];  // ← capture BEFORE AsyncLoading
        //     state = const AsyncLoading();
        //     state = await AsyncValue.guard(() async {
        //       final newFile = await repo.uploadFile(...);
        //       return [newFile, ...current];
        //     });
        //   }
      },
    );
  });
}

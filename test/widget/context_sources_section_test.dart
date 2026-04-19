// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/context_sources_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------------
// Fake notifier — must extend TeacherFiles (generated class) so the
// overrideWith type matches AutoDisposeAsyncNotifierProvider<TeacherFiles,...>
//
// For AsyncData/AsyncError presets, build() returns immediately.
// For AsyncLoading, build() never completes to hold the loading state.
// ---------------------------------------------------------------------------
class _FakeTeacherFiles extends TeacherFiles {
  final AsyncValue<List<TeacherFileModel>> _preset;
  _FakeTeacherFiles(this._preset);

  @override
  Future<List<TeacherFileModel>> build() async {
    switch (_preset) {
      case AsyncData(:final value):
        return value;
      case AsyncError(:final error, :final stackTrace):
        Error.throwWithStackTrace(error, stackTrace);
      default:
        // AsyncLoading — return a Future that never completes to hold loading state
        return Completer<List<TeacherFileModel>>().future;
    }
  }
}

// ---------------------------------------------------------------------------
// Helper — builds ContextSourcesSection with provider override.
// ---------------------------------------------------------------------------
Widget _buildSection({
  required AsyncValue<List<TeacherFileModel>> filesState,
  void Function(List<String>)? onSelectionChanged,
}) {
  return ProviderScope(
    overrides: [
      teacherFilesProvider.overrideWith(
        () => _FakeTeacherFiles(filesState),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ContextSourcesSection(
          onSelectionChanged: onSelectionChanged ?? (_) {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Sample file factories
// ---------------------------------------------------------------------------
TeacherFileModel _makeFile({
  String id = 'f1',
  String filename = 'lecture.xlsx',
  String status = 'done',
}) {
  return TeacherFileModel(
    id: id,
    filename: filename,
    storagePath: 'teachers/t1/$filename',
    url: 'https://example.com/$filename',
    mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    sizeBytes: 512,
    uploadedBy: 't1',
    processingStatus: status,
  );
}

void main() {
  group('ContextSourcesSection', () {
    // -----------------------------------------------------------------------
    // Section header
    // -----------------------------------------------------------------------
    group('Header', () {
      testWidgets('hiển thị tiêu đề Nguồn Dữ Liệu Tham Khảo', (tester) async {
        await tester.pumpWidget(_buildSection(filesState: const AsyncData([])));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Nguồn Dữ Liệu Tham Khảo'),
          findsOneWidget,
        );
      });
    });

    // -----------------------------------------------------------------------
    // Loading
    // -----------------------------------------------------------------------
    group('Loading state', () {
      testWidgets('hiển thị Shimmer khi provider đang loading', (tester) async {
        await tester.pumpWidget(
          _buildSection(filesState: const AsyncLoading()),
        );
        // Single pump keeps loading state. pumpAndSettle would loop on Shimmer animation.
        await tester.pump();
        expect(find.byType(Shimmer), findsWidgets);
      });
    });

    // -----------------------------------------------------------------------
    // Error state
    // -----------------------------------------------------------------------
    group('Error state', () {
      testWidgets(
        'hiển thị Không thể tải tài liệu khi provider throw error',
        (tester) async {
          await tester.pumpWidget(
            _buildSection(
              filesState:
                  AsyncError(Exception('network error'), StackTrace.empty),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Không thể tải tài liệu'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị nút Thử lại khi có error',
        (tester) async {
          await tester.pumpWidget(
            _buildSection(
              filesState:
                  AsyncError(Exception('err'), StackTrace.empty),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Thử lại'), findsOneWidget);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Data — chips
    // -----------------------------------------------------------------------
    group('Chip list', () {
      testWidgets(
        'hiển thị ActionChip Thêm tài liệu khi có files',
        (tester) async {
          final files = [_makeFile()];
          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          await tester.pumpAndSettle();
          expect(find.text('Thêm tài liệu'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị ActionChip Thêm tài liệu khi danh sách rỗng',
        (tester) async {
          await tester.pumpWidget(
            _buildSection(filesState: const AsyncData([])),
          );
          await tester.pumpAndSettle();
          expect(find.text('Thêm tài liệu'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị FilterChip với filename cho mỗi file',
        (tester) async {
          final files = [
            _makeFile(id: 'f1', filename: 'math.xlsx'),
            _makeFile(id: 'f2', filename: 'science.docx'),
          ];
          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          await tester.pumpAndSettle();
          expect(find.text('math.xlsx'), findsOneWidget);
          expect(find.text('science.docx'), findsOneWidget);
        },
      );

      testWidgets(
        'tap FilterChip toggle selection và gọi onSelectionChanged',
        (tester) async {
          final captured = <List<String>>[];
          final files = [_makeFile(id: 'f1', filename: 'math.xlsx')];

          await tester.pumpWidget(
            _buildSection(
              filesState: AsyncData(files),
              onSelectionChanged: captured.add,
            ),
          );
          await tester.pumpAndSettle();

          // First tap — select
          await tester.tap(find.text('math.xlsx'));
          await tester.pumpAndSettle();
          expect(captured.last, contains('f1'));

          // Second tap — deselect
          await tester.tap(find.text('math.xlsx'));
          await tester.pumpAndSettle();
          expect(captured.last, isEmpty);
        },
      );

      testWidgets(
        'hiển thị CircularProgressIndicator trên chip khi file đang processing',
        (tester) async {
          final files = [_makeFile(id: 'f1', filename: 'busy.xlsx', status: 'processing')];
          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          // Use pump with duration to avoid infinite loop on CircularProgressIndicator
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CircularProgressIndicator), findsWidgets);
        },
      );

      testWidgets(
        'hiển thị CircularProgressIndicator trên chip khi file status=queued',
        (tester) async {
          final files = [_makeFile(id: 'f1', filename: 'queued.xlsx', status: 'queued')];
          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          // Use pump with duration to avoid infinite loop on CircularProgressIndicator
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CircularProgressIndicator), findsWidgets);
        },
      );

      testWidgets(
        'tên file dài hơn 20 ký tự được truncate với dấu …',
        (tester) async {
          // 21-char filename → should be truncated to first 20 chars + '…'
          const longName = 'abcdefghijklmnopqrstu.xlsx'; // 26 chars
          final files = [_makeFile(id: 'f1', filename: longName)];

          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          await tester.pumpAndSettle();

          // Full filename should NOT appear; truncated version should
          expect(find.text(longName), findsNothing);
          // Chip label = first 20 chars + '…'
          final expected = '${longName.substring(0, 20)}…';
          expect(find.text(expected), findsOneWidget);
        },
      );

      testWidgets(
        'tên file 20 ký tự hoặc ít hơn KHÔNG bị truncate',
        (tester) async {
          // Exactly 20 chars — boundary: > 20 triggers truncation, == 20 does not
          const name20 = 'exactly20chars1.xlsx'; // 20 chars
          final files = [_makeFile(id: 'f1', filename: name20)];

          await tester.pumpWidget(
            _buildSection(filesState: AsyncData(files)),
          );
          await tester.pumpAndSettle();

          expect(find.text(name20), findsOneWidget);
        },
      );
    });
  });
}

// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:ai_mls/presentation/views/settings/ai_question_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------------
// Fake notifier — must extend TeacherFiles so overrideWith type matches
// AutoDisposeAsyncNotifierProvider<TeacherFiles, List<TeacherFileModel>>
//
// For AsyncData/AsyncError presets, build() returns immediately with the value.
// For AsyncLoading, build() never completes so the loading state is maintained.
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
// Build a GoRouter-backed test widget.
//
// The ProviderScope with overrides wraps the ENTIRE MaterialApp.router so
// the overridden providers are visible from all widgets in the tree including
// those rendered inside GoRouter routes.
//
// GoRoute at '/' renders AiQuestionSettingsScreen (no inner ProviderScope).
// GoRoute with name 'api-key-setup' provides a stub destination to satisfy
// context.pushNamed(AppRoute.apiKeySetup) calls inside the screen.
// ---------------------------------------------------------------------------
Widget _buildScreen(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const AiQuestionSettingsScreen(),
      ),
      GoRoute(
        name: 'api-key-setup',
        path: '/settings/api-keys',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('ApiKeySetupScreen'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Sample files
// ---------------------------------------------------------------------------
TeacherFileModel _makeFile({
  String id = 'f1',
  String filename = 'test.xlsx',
  String status = 'queued',
}) {
  return TeacherFileModel(
    id: id,
    filename: filename,
    storagePath: 'teachers/t1/$filename',
    url: 'https://example.com/$filename',
    mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    sizeBytes: 1024,
    uploadedBy: 't1',
    processingStatus: status,
  );
}

void main() {
  group('AiQuestionSettingsScreen', () {
    // -----------------------------------------------------------------------
    // Layout
    // -----------------------------------------------------------------------
    group('Layout', () {
      testWidgets('hiển thị AppBar với title Cài đặt AI', (tester) async {
        await tester.pumpWidget(
          _buildScreen([
            teacherFilesProvider.overrideWith(
              () => _FakeTeacherFiles(const AsyncData([])),
            ),
          ]),
        );
        await tester.pumpAndSettle();
        expect(find.text('Cài đặt AI'), findsOneWidget);
      });

      testWidgets('hiển thị section API Key', (tester) async {
        await tester.pumpWidget(
          _buildScreen([
            teacherFilesProvider.overrideWith(
              () => _FakeTeacherFiles(const AsyncData([])),
            ),
          ]),
        );
        await tester.pumpAndSettle();
        expect(find.text('API Key'), findsOneWidget);
        expect(find.text('Cài đặt API Key'), findsOneWidget);
      });

      testWidgets('hiển thị section Thư viện Tài liệu', (tester) async {
        await tester.pumpWidget(
          _buildScreen([
            teacherFilesProvider.overrideWith(
              () => _FakeTeacherFiles(const AsyncData([])),
            ),
          ]),
        );
        await tester.pumpAndSettle();
        expect(find.text('Thư viện Tài liệu'), findsOneWidget);
      });

      testWidgets('hiển thị section Công cụ với Xuất file mẫu Excel',
          (tester) async {
        await tester.pumpWidget(
          _buildScreen([
            teacherFilesProvider.overrideWith(
              () => _FakeTeacherFiles(const AsyncData([])),
            ),
          ]),
        );
        await tester.pumpAndSettle();
        expect(find.text('Công cụ'), findsOneWidget);
        expect(find.text('Xuất file mẫu Excel'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Thư viện Tài liệu section
    // -----------------------------------------------------------------------
    group('Thư viện Tài liệu section', () {
      testWidgets(
        'hiển thị Shimmer loading khi teacherFilesProvider đang load',
        (tester) async {
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(const AsyncLoading()),
              ),
            ]),
          );
          // Single pump — keep the widget in loading state without settling
          await tester.pump();
          expect(find.byType(Shimmer), findsWidgets);
        },
      );

      testWidgets(
        'hiển thị empty state khi không có file nào',
        (tester) async {
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(const AsyncData([])),
              ),
            ]),
          );
          await tester.pumpAndSettle();
          expect(find.text('Chưa có tài liệu nào'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị filename và Đang xử lý... khi status=queued',
        (tester) async {
          final files = [_makeFile(filename: 'test.xlsx', status: 'queued')];
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(AsyncData(files)),
              ),
            ]),
          );
          // pump with Duration to let the tree render without looping on animations
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.text('test.xlsx'), findsOneWidget);
          expect(find.text('Đang xử lý...'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị Sẵn sàng khi processingStatus=done',
        (tester) async {
          // NOTE: screen checks processingStatus == 'done' (NOT 'completed').
          // Edge Function may return 'completed' — this is a known bug to track.
          final files = [_makeFile(filename: 'done.xlsx', status: 'done')];
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(AsyncData(files)),
              ),
            ]),
          );
          await tester.pumpAndSettle();
          expect(find.text('Sẵn sàng'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị Lỗi xử lý khi processingStatus=completed (không phải done)',
        (tester) async {
          // 'completed' != 'done' → falls to error branch in the screen
          // This documents the known status mismatch bug
          final files = [_makeFile(filename: 'bad.xlsx', status: 'completed')];
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(AsyncData(files)),
              ),
            ]),
          );
          await tester.pumpAndSettle();
          expect(find.text('Lỗi xử lý'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị error state khi provider throw error',
        (tester) async {
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(
                  AsyncError(Exception('network error'), StackTrace.empty),
                ),
              ),
            ]),
          );
          await tester.pumpAndSettle();
          expect(find.text('Lỗi tải tài liệu'), findsOneWidget);
        },
      );

      testWidgets(
        'hiển thị CircularProgressIndicator trên file đang processing',
        (tester) async {
          final files = [
            _makeFile(filename: 'processing.xlsx', status: 'processing'),
          ];
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(AsyncData(files)),
              ),
            ]),
          );
          // pump with Duration to avoid infinite animation loop in pumpAndSettle
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CircularProgressIndicator), findsWidgets);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Công cụ section
    // -----------------------------------------------------------------------
    group('Công cụ section', () {
      testWidgets(
        'tap Xuất file mẫu Excel hiển thị SnackBar với URL đã copy',
        (tester) async {
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(const AsyncData([])),
              ),
            ]),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Xuất file mẫu Excel'));
          await tester.pump(); // trigger SnackBar display
          await tester.pump(const Duration(milliseconds: 100));

          // SnackBar body contains 'URL đã copy'
          expect(find.textContaining('URL đã copy'), findsOneWidget);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Navigation (GoRouter)
    // -----------------------------------------------------------------------
    group('Navigation', () {
      testWidgets(
        'tap Cài đặt API Key điều hướng đến ApiKeySetupScreen',
        (tester) async {
          await tester.pumpWidget(
            _buildScreen([
              teacherFilesProvider.overrideWith(
                () => _FakeTeacherFiles(const AsyncData([])),
              ),
            ]),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Cài đặt API Key'));
          await tester.pumpAndSettle();

          expect(find.text('ApiKeySetupScreen'), findsOneWidget);
        },
      );
    });
  });
}

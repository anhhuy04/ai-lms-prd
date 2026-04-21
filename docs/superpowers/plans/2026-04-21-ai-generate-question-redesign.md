# AI Generate Question — 3-Mode Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign TeacherAiGenerateQuestionScreen to expose 3 distinct modes (Nhập Prompt / Trích xuất / Từ Tài liệu) via inline tabs + EndDrawer settings, without touching any Mode 1 logic.

**Architecture:** B+C Hybrid — SegmentedButton mode tabs on the main screen body, `AiSettingsDrawer` (EndDrawer) replacing the settings navigate-away. Mode 2 & 3 show `ContextSourcesSection` inline. Mode 3 is UI-ready but shows "coming soon" SnackBar. Files are temporary and auto-deleted after extraction completes.

**Tech Stack:** Flutter Riverpod (`@riverpod`, `ConsumerStatefulWidget`), GoRouter, Supabase, DesignTokens (`DesignColors`, `DesignSpacing`, `DesignTypography`, `DesignRadius`, `DesignElevation`), `file_picker`, `shimmer`

---

## File Map

| Action | Path |
|--------|------|
| Modify | `lib/presentation/providers/ai_generation_settings_notifier.dart` |
| Modify | `lib/data/datasources/teacher_file_datasource.dart` |
| Modify | `lib/domain/repositories/teacher_file_repository.dart` |
| Modify | `lib/data/repositories/teacher_file_repository_impl.dart` |
| Modify | `lib/presentation/providers/teacher_file_notifier.dart` |
| **Create** | `lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart` |
| Modify | `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart` |
| Modify | `lib/presentation/views/settings/ai_question_settings_screen.dart` |
| Modify (test) | `test/unit/teacher_file_notifier_test.dart` |

---

## Task 1: ProcessingMode enum — rename + add ragGeneration

**Files:**
- Modify: `lib/presentation/providers/ai_generation_settings_notifier.dart`

- [ ] **Step 1: Update enum and default in notifier**

Replace the entire file content:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_generation_settings_notifier.g.dart';

enum ProcessingMode { promptOnly, extraction, ragGeneration }

class AiGenerationConfig {
  const AiGenerationConfig({
    this.processingMode = ProcessingMode.promptOnly,
    this.selectedFileIds = const [],
  });

  final ProcessingMode processingMode;
  final List<String> selectedFileIds;

  AiGenerationConfig copyWith({
    ProcessingMode? processingMode,
    List<String>? selectedFileIds,
  }) {
    return AiGenerationConfig(
      processingMode: processingMode ?? this.processingMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
    );
  }
}

/// Session-scoped AI generation settings (keepAlive = persists until app restart).
/// Shared between AiQuestionSettingsScreen and TeacherAiGenerateQuestionScreen.
@Riverpod(keepAlive: true)
class AiGenerationSettingsNotifier extends _$AiGenerationSettingsNotifier {
  @override
  AiGenerationConfig build() => const AiGenerationConfig();

  void setMode(ProcessingMode mode) =>
      state = state.copyWith(processingMode: mode);

  void setSelectedFileIds(List<String> ids) =>
      state = state.copyWith(selectedFileIds: ids);
}
```

- [ ] **Step 2: Run build_runner to regenerate .g.dart**

```bash
cd /mnt/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -5
```

Expected: `[INFO] Succeeded after Xs with Y outputs`

- [ ] **Step 3: Verify compile**

```bash
flutter analyze lib/presentation/providers/ai_generation_settings_notifier.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/ai_generation_settings_notifier.dart \
        lib/presentation/providers/ai_generation_settings_notifier.g.dart
git commit -m "refactor(ai): rename ProcessingMode.generation→promptOnly; add ragGeneration"
```

---

## Task 2: deleteFile() through data layer

**Files:**
- Modify: `lib/data/datasources/teacher_file_datasource.dart`
- Modify: `lib/domain/repositories/teacher_file_repository.dart`
- Modify: `lib/data/repositories/teacher_file_repository_impl.dart`
- Modify: `lib/presentation/providers/teacher_file_notifier.dart`
- Modify (test): `test/unit/teacher_file_notifier_test.dart`

- [ ] **Step 1: Write failing notifier test for deleteFile**

Append to `test/unit/teacher_file_notifier_test.dart` (inside `main()`, after existing tests):

```dart
  group('deleteFile', () {
    test('removes the file from state on success', () async {
      final file1 = _makeFile(id: 'file-1', filename: 'a.xlsx');
      final file2 = _makeFile(id: 'file-2', filename: 'b.xlsx');

      when(() => mockRepo.getTeacherFiles())
          .thenAnswer((_) async => [file1, file2]);
      when(() => mockRepo.deleteFile('file-1'))
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
      when(() => mockRepo.deleteFile('file-err'))
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
```

Also add the mock fallback for `deleteFile` in `setUpAll`:
```dart
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue('');
  });
```

- [ ] **Step 2: Run test — confirm FAIL**

```bash
flutter test test/unit/teacher_file_notifier_test.dart 2>&1 | tail -20
```

Expected: `FAILED` — `deleteFile` method not found on `ITeacherFileRepository`

- [ ] **Step 3: Add deleteFile to repository interface**

In `lib/domain/repositories/teacher_file_repository.dart`, add after `getTeacherFiles()`:

```dart
  /// Delete a file from Storage + files/file_links/ai_queue tables.
  Future<void> deleteFile(String fileId);
```

Full file after change:
```dart
import 'dart:typed_data';

import 'package:ai_mls/data/models/teacher_file_model.dart';

/// Contract för Teacher Knowledge Library (file upload + retrieval + deletion).
abstract class ITeacherFileRepository {
  Future<TeacherFileModel> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });

  Future<List<TeacherFileModel>> getTeacherFiles();

  Future<void> deleteFile(String fileId);
}
```

- [ ] **Step 4: Implement deleteFile in datasource**

In `lib/data/datasources/teacher_file_datasource.dart`, add after `getTeacherFiles()`:

```dart
  /// Delete a temp file: Storage object + ai_queue rows + file_links + files row.
  /// Deletion order respects FK constraints: ai_queue/file_links first, then files.
  Future<void> deleteFile(String fileId) async {
    AppLogger.info('[TeacherFile] deleteFile: start fileId=$fileId');

    // Read storage_path before deleting the files row
    final fileRow = await _supabase
        .from('files')
        .select('storage_path')
        .eq('id', fileId)
        .maybeSingle();

    if (fileRow == null) {
      AppLogger.warning('[TeacherFile] deleteFile: fileId=$fileId not found in files table — skipping');
      return;
    }

    final storagePath = fileRow['storage_path'] as String;

    // Delete from Storage bucket
    await _supabase.storage.from('teacher-documents').remove([storagePath]);
    AppLogger.info('[TeacherFile] deleteFile: storage removed path=$storagePath');

    // Delete ai_queue rows for this file (payload->file_id jsonb filter)
    await _supabase
        .from('ai_queue')
        .delete()
        .filter('payload->>file_id', 'eq', fileId);
    AppLogger.info('[TeacherFile] deleteFile: ai_queue rows deleted');

    // Delete file_links row
    await _supabase.from('file_links').delete().eq('file_id', fileId);
    AppLogger.info('[TeacherFile] deleteFile: file_links row deleted');

    // Delete files row
    await _supabase.from('files').delete().eq('id', fileId);
    AppLogger.info('[TeacherFile] deleteFile: files row deleted — done');
  }
```

- [ ] **Step 5: Implement deleteFile in repository impl**

In `lib/data/repositories/teacher_file_repository_impl.dart`, add after `getTeacherFiles()`:

```dart
  @override
  Future<void> deleteFile(String fileId) async {
    try {
      await _dataSource.deleteFile(fileId);
    } catch (e, st) {
      AppLogger.error(
        '[TeacherFileRepo] deleteFile failed: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
```

- [ ] **Step 6: Add deleteFile action to notifier**

In `lib/presentation/providers/teacher_file_notifier.dart`, add after `uploadFile()`:

```dart
  /// Remove a file from state + delete from Supabase.
  Future<void> deleteFile(String fileId) async {
    final current = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherFileRepositoryProvider).deleteFile(fileId);
      AppLogger.info('[TeacherFiles] deleteFile success: $fileId');
      return current.where((f) => f.id != fileId).toList();
    });
  }
```

- [ ] **Step 7: Run tests — confirm PASS**

```bash
flutter test test/unit/teacher_file_notifier_test.dart 2>&1 | tail -20
```

Expected: All tests pass

- [ ] **Step 8: Analyze**

```bash
flutter analyze lib/data/datasources/teacher_file_datasource.dart \
                lib/domain/repositories/teacher_file_repository.dart \
                lib/data/repositories/teacher_file_repository_impl.dart \
                lib/presentation/providers/teacher_file_notifier.dart
```

Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add lib/data/datasources/teacher_file_datasource.dart \
        lib/domain/repositories/teacher_file_repository.dart \
        lib/data/repositories/teacher_file_repository_impl.dart \
        lib/presentation/providers/teacher_file_notifier.dart \
        test/unit/teacher_file_notifier_test.dart
git commit -m "feat(teacher-files): add deleteFile through data layer + notifier"
```

---

## Task 3: AiSettingsDrawer — new EndDrawer widget

**Files:**
- Create: `lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart`

- [ ] **Step 1: Create the drawer widget file**

```dart
// lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart
import 'dart:typed_data';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/data/models/teacher_file_model.dart';
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
import 'package:ai_mls/presentation/views/settings/widgets/export_template_bottom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EndDrawer for TeacherAiGenerateQuestionScreen.
/// Contains: API Key → Document Library (temp files) → Tools.
class AiSettingsDrawer extends ConsumerWidget {
  const AiSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filesAsync = ref.watch(teacherFilesProvider);

    return Drawer(
      width: 340,
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    'Cài đặt AI',
                    style: DesignTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () => Scaffold.of(context).closeEndDrawer(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(DesignSpacing.lg),
                children: [
                  _ApiKeySection(isDark: isDark),
                  SizedBox(height: DesignSpacing.xl),
                  _DocumentLibrarySection(isDark: isDark, filesAsync: filesAsync, ref: ref),
                  SizedBox(height: DesignSpacing.xl),
                  _ToolsSection(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeySection extends StatelessWidget {
  const _ApiKeySection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _DrawerSectionCard(
      title: 'API Key',
      icon: Icons.vpn_key_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.vpn_key_outlined, color: DesignColors.primary, size: 20),
        title: Text(
          'Cài đặt API Key',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Quản lý Gemini API Key',
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        onTap: () {
          Scaffold.of(context).closeEndDrawer();
          context.pushNamed(AppRoute.apiKeySetup);
        },
      ),
    );
  }
}

class _DocumentLibrarySection extends StatelessWidget {
  const _DocumentLibrarySection({
    required this.isDark,
    required this.filesAsync,
    required this.ref,
  });

  final bool isDark;
  final AsyncValue<List<TeacherFileModel>> filesAsync;
  final WidgetRef ref;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;
    final mimeType = file.extension == 'docx'
        ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    await ref.read(teacherFilesProvider.notifier).uploadFile(bytes, file.name, mimeType);
  }

  @override
  Widget build(BuildContext context) {
    return _DrawerSectionCard(
      title: 'Thư viện tài liệu',
      icon: Icons.folder_outlined,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File tạm thời — tự xóa sau khi xử lý',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          filesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Text(
              'Lỗi tải danh sách: $e',
              style: TextStyle(color: DesignColors.error, fontSize: 12),
            ),
            data: (files) => files.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                    child: Text(
                      'Chưa có tài liệu nào',
                      style: DesignTypography.bodySmall.copyWith(
                        color: isDark ? Colors.grey[500] : DesignColors.textSecondary,
                      ),
                    ),
                  )
                : Column(
                    children: files.map((f) => _FileListTile(file: f, isDark: isDark, ref: ref)).toList(),
                  ),
          ),
          SizedBox(height: DesignSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickAndUploadFile,
              icon: const Icon(Icons.upload_file_outlined, size: 16),
              label: const Text('Tải file lên'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.primary,
                side: BorderSide(color: DesignColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileListTile extends StatelessWidget {
  const _FileListTile({required this.file, required this.isDark, required this.ref});

  final TeacherFileModel file;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isProcessing =
        file.processingStatus == 'pending' || file.processingStatus == 'processing';
    final isDone = file.processingStatus == 'completed';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      dense: true,
      leading: Icon(
        Icons.insert_drive_file_outlined,
        size: 18,
        color: isProcessing
            ? DesignColors.warning
            : isDone
                ? DesignColors.success
                : DesignColors.textSecondary,
      ),
      title: Text(
        file.filename,
        style: DesignTypography.bodySmall.copyWith(
          color: isDark ? Colors.white : DesignColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isProcessing ? 'Đang xử lý...' : isDone ? 'Sẵn sàng' : 'Đang xếp hàng',
        style: TextStyle(
          fontSize: 11,
          color: isProcessing
              ? DesignColors.warning
              : isDone
                  ? DesignColors.success
                  : DesignColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline_rounded, size: 18, color: DesignColors.error),
        tooltip: 'Xóa',
        onPressed: () => ref.read(teacherFilesProvider.notifier).deleteFile(file.id),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _DrawerSectionCard(
      title: 'Công cụ',
      icon: Icons.build_outlined,
      isDark: isDark,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.download_outlined, color: DesignColors.tealPrimary, size: 20),
        title: Text(
          'Xuất file mẫu Excel',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        onTap: () {
          Scaffold.of(context).closeEndDrawer();
          ExportTemplateBottomSheet.show(context);
        },
      ),
    );
  }
}

class _DrawerSectionCard extends StatelessWidget {
  const _DrawerSectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.child,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243040) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [DesignElevation.level1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: DesignColors.primary),
              SizedBox(width: DesignSpacing.xs),
              Text(
                title,
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          child,
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze the new file**

```bash
flutter analyze lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart
git commit -m "feat(ui): add AiSettingsDrawer — EndDrawer with API Key, Document Library, Tools"
```

---

## Task 4: Main screen — add EndDrawer + fix header button

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

Context: The screen uses a custom header (not AppBar). The `settings_rounded` button currently calls `context.pushNamed(AppRoute.aiQuestionSettings)`. We need it to open the EndDrawer instead. Since we need `Scaffold.of(context)` from inside the header, we add a `GlobalKey<ScaffoldState>` to the state and use `_scaffoldKey.currentState!.openEndDrawer()`.

- [ ] **Step 1: Add GlobalKey + import AiSettingsDrawer**

Add the import near the top of `teacher_ai_generate_question_screen.dart`:

```dart
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart';
```

In `_TeacherAiGenerateQuestionScreenState`, add the scaffold key after the existing field declarations (around line 45):

```dart
  final _scaffoldKey = GlobalKey<ScaffoldState>();
```

- [ ] **Step 2: Add endDrawer to Scaffold and wire GlobalKey**

Locate the `Scaffold(` in the `build()` method (around line ~1005). Add `key` and `endDrawer`:

**Old:**
```dart
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Stack(
```

**New:**
```dart
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DesignColors.moonLight,
      endDrawer: const AiSettingsDrawer(),
      body: Stack(
```

- [ ] **Step 3: Fix the header button to open EndDrawer**

Locate the settings button (around line 1062–1076):

**Old:**
```dart
                    // Nút cài đặt (navigate đến Settings)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pushNamed(AppRoute.aiQuestionSettings),
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.settings_rounded,
                            size: 24,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
```

**New:**
```dart
                    // Nút mở EndDrawer cài đặt
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.menu_rounded,
                            size: 24,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
```

- [ ] **Step 4: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart 2>&1 | head -30
```

Expected: No errors. If `AppRoute.aiQuestionSettings` is now unused in this file, the import for `route_constants.dart` may still be needed (it's used for other routes). Verify.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "feat(ui): add AiSettingsDrawer endDrawer + fix header to open drawer"
```

---

## Task 5: Mode tabs — SegmentedButton at top of body

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

- [ ] **Step 1: Add import for ProcessingMode (already imported) and add _buildModeTabsSection**

In the file, after the `_buildHeader()` call in the `Column`, we need to insert the mode tabs. First add the private method to the state class:

```dart
  Widget _buildModeTabsSection(BuildContext context, bool isDark) {
    final mode = ref.watch(aiGenerationSettingsNotifierProvider).processingMode;

    return Container(
      color: isDark ? const Color(0xFF1A2632) : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.sm,
      ),
      child: SegmentedButton<ProcessingMode>(
        segments: const [
          ButtonSegment(
            value: ProcessingMode.promptOnly,
            icon: Icon(Icons.edit_note_rounded, size: 16),
            label: Text('Nhập Prompt'),
          ),
          ButtonSegment(
            value: ProcessingMode.extraction,
            icon: Icon(Icons.content_paste_search_rounded, size: 16),
            label: Text('Trích xuất'),
          ),
          ButtonSegment(
            value: ProcessingMode.ragGeneration,
            icon: Icon(Icons.auto_stories_rounded, size: 16),
            label: Text('Từ Tài liệu'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selected) {
          ref
              .read(aiGenerationSettingsNotifierProvider.notifier)
              .setMode(selected.first);
        },
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            DesignTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 2: Insert mode tabs into the Column**

Locate the Column in the Scaffold body. Find where `_buildHeader(context, isDark)` is called and insert the tabs after it:

**Old (the Column's children list, around line 990):**
```dart
          Column(
            children: [
              _buildHeader(context, isDark, statusBarHeight),

              // Form Content
              Expanded(
```

**New:**
```dart
          Column(
            children: [
              _buildHeader(context, isDark, statusBarHeight),
              _buildModeTabsSection(context, isDark),

              // Form Content
              Expanded(
```

> Note: The exact method signature of `_buildHeader` — check the actual method definition to confirm the parameter list includes `statusBarHeight`. If not, adjust accordingly.

- [ ] **Step 3: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart 2>&1 | head -20
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "feat(ui): add 3-mode SegmentedButton tabs to AI generate question screen"
```

---

## Task 6: Context-aware body — mode-specific content

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

The existing body inside `Expanded > Form > SingleChildScrollView > Column` shows the Mode 1 content always. We need to make it mode-aware.

- [ ] **Step 1: Add state field for optional focus hint (Mode 3)**

In the state class fields section, add:

```dart
  final _focusHintController = TextEditingController();
```

And in `dispose()`:
```dart
    _focusHintController.dispose();
```

- [ ] **Step 2: Add _buildModeHintCard helper**

```dart
  Widget _buildModeHintCard(
    BuildContext context,
    ProcessingMode mode,
    bool isDark,
  ) {
    final isExtraction = mode == ProcessingMode.extraction;
    final icon = isExtraction
        ? Icons.content_paste_search_rounded
        : Icons.auto_stories_rounded;
    final color = isExtraction ? DesignColors.warning : DesignColors.success;
    final title = isExtraction ? 'Chế độ Trích xuất' : 'Chế độ Từ Tài liệu';
    final subtitle = isExtraction
        ? 'AI sẽ đọc file và trích xuất câu hỏi có sẵn. Không sáng tác thêm.'
        : 'AI sáng tác câu hỏi dựa trên nội dung tài liệu (RAG pipeline).';

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[300] : DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 3: Replace the static Column children with mode-aware children**

Locate the `Column` inside `SingleChildScrollView` (around line 1087). Replace its children with:

```dart
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode-specific content
                        if (mode != ProcessingMode.promptOnly) ...[
                          _buildModeHintCard(context, mode, isDark),
                          SizedBox(height: DesignSpacing.lg),
                          ContextSourcesSection(
                            initialSelectedIds: ref
                                .read(aiGenerationSettingsNotifierProvider)
                                .selectedFileIds,
                            onSelectionChanged: (ids) => ref
                                .read(aiGenerationSettingsNotifierProvider.notifier)
                                .setSelectedFileIds(ids),
                          ),
                          SizedBox(height: DesignSpacing.lg),
                        ],

                        // Mode 3 only: optional focus hint
                        if (mode == ProcessingMode.ragGeneration) ...[
                          Text(
                            'Hướng tập trung (tùy chọn)',
                            style: DesignTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : DesignColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: DesignSpacing.xs),
                          TextFormField(
                            controller: _focusHintController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'VD: Tập trung vào chương 3, phần lý thuyết...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF243040) : Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignRadius.md),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignRadius.md),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),
                          SizedBox(height: DesignSpacing.xl),
                        ],

                        // Mode 1 content (topic, difficulty, types)
                        if (mode == ProcessingMode.promptOnly) ...[
                          _buildTopicSection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                        ],

                        // Quantity — shown for modes 1 and 3 (not extraction)
                        if (mode != ProcessingMode.extraction) ...[
                          _buildQuantitySection(context, isDark),
                          SizedBox(height: DesignSpacing.md),

                          if (_selectedTypes.isNotEmpty && mode == ProcessingMode.promptOnly) ...[
                            _buildPerTypeQtySection(context, isDark),
                            SizedBox(height: DesignSpacing.xxl),
                          ] else
                            SizedBox(height: DesignSpacing.lg),
                        ],

                        // Difficulty + Type chips — Mode 1 only
                        if (mode == ProcessingMode.promptOnly) ...[
                          _buildDifficultySection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                          _buildQuestionTypeSection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                        ],

                        // AI Response (all modes — shows after generate)
                        if (_generatedQuestions != null) ...[
                          SizedBox(height: DesignSpacing.xxl),
                          _buildAiResponseSection(context, isDark),
                        ],

                        // Raw API debug (Mode 1 only, debug build)
                        if (kDebugMode &&
                            mode == ProcessingMode.promptOnly &&
                            (_rawApiResponse != null ||
                                _rawApiResponsePretty != null)) ...[
                          SizedBox(height: DesignSpacing.lg),
                          _buildRawApiResponseSection(context, isDark),
                        ],

                        SizedBox(height: 100),
                      ],
                    ),
```

- [ ] **Step 4: Add ContextSourcesSection import at top**

The import for `ContextSourcesSection` may already exist (it was in `ai_question_settings_screen.dart`). Check if it's in `teacher_ai_generate_question_screen.dart`. If not, add:

```dart
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/context_sources_section.dart';
```

- [ ] **Step 5: Update bottom action button label to be mode-aware**

Locate the `ElevatedButton` in the Positioned actions area (around line 1174). Update the button child to show mode-specific labels:

**Old (in the `child:` of ElevatedButton, the non-loading branch):**
```dart
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Tạo câu hỏi',
                                style: DesignTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
```

**New (add `final mode = ...` before the Positioned widget, or read it from provider):**

Before the ElevatedButton's `child:`, read the current mode. Since we're inside `build()`, `mode` should already be a local variable — add `final mode = ref.watch(aiGenerationSettingsNotifierProvider).processingMode;` near the top of `build()` if not already done. Then update the button label:

```dart
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mode == ProcessingMode.extraction
                                    ? Icons.content_paste_search_rounded
                                    : mode == ProcessingMode.ragGeneration
                                        ? Icons.auto_stories_rounded
                                        : Icons.auto_awesome,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mode == ProcessingMode.extraction
                                    ? 'Trích xuất câu hỏi'
                                    : mode == ProcessingMode.ragGeneration
                                        ? 'Sinh từ tài liệu'
                                        : 'Tạo câu hỏi',
                                style: DesignTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
```

At the top of `build()` (or wherever `isDark` is declared), also declare:
```dart
final mode = ref.watch(aiGenerationSettingsNotifierProvider).processingMode;
```

- [ ] **Step 6: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart 2>&1 | head -30
```

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "feat(ui): mode-aware body — file picker for modes 2&3, mode-labeled action button"
```

---

## Task 7: Validation fix + Mode 3 guard in _handleGenerate

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

- [ ] **Step 1: Restructure the top of _handleGenerate**

Locate `_handleGenerate()` (line 453). Replace the top portion (lines 454–488 — up to and including the `_isQtyMismatch` guard) with:

**Old top of `_handleGenerate` (lines 453–499):**
```dart
  Future<void> _handleGenerate() async {
    AppLogger.info('🔵 [Generate] _handleGenerate called');
    AppLogger.info('🔵 [Generate] topic="${_topicController.text.trim()}", '
        '_isGenerating=$_isGenerating, _isQtyMismatch=$_isQtyMismatch, '
        '_selectedTypes=$_selectedTypes, _totalTypedQty=$_totalTypedQty, _limitQty=$_limitQty');

    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      AppLogger.warning('🟡 [Generate] EXIT: topic empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập chủ đề câu hỏi'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Validate quantity
    final formState = _formKey.currentState;
    AppLogger.info('🔵 [Generate] formState=$formState');
    if (formState == null) {
      AppLogger.error('🔴 [Generate] EXIT: _formKey.currentState is NULL!');
      return;
    }
    final isValid = formState.validate();
    AppLogger.info('🔵 [Generate] form.validate()=$isValid');
    if (!isValid) {
      AppLogger.warning('🟡 [Generate] EXIT: form validation failed');
      return;
    }
    // Guard mismatch (button đã disable nhưng thêm guard để chắc chắn)
    if (_isQtyMismatch) {
      AppLogger.warning('🟡 [Generate] EXIT: _isQtyMismatch=true');
      return;
    }
```

**New top of `_handleGenerate`:**
```dart
  Future<void> _handleGenerate() async {
    AppLogger.info('🔵 [Generate] _handleGenerate called');

    // Read mode first — determines validation path
    final aiSettingsEarly = ref.read(aiGenerationSettingsNotifierProvider);
    final earlyMode = aiSettingsEarly.processingMode;

    // Mode 3 guard — RAG backend not yet ready
    if (earlyMode == ProcessingMode.ragGeneration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tính năng đang phát triển — sắp ra mắt'),
          backgroundColor: DesignColors.primary,
        ),
      );
      return;
    }

    // Mode 1 only: validate topic + form fields
    if (earlyMode == ProcessingMode.promptOnly) {
      final topic = _topicController.text.trim();
      AppLogger.info('🔵 [Generate] topic="$topic", _isQtyMismatch=$_isQtyMismatch');

      if (topic.isEmpty) {
        AppLogger.warning('🟡 [Generate] EXIT: topic empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập chủ đề câu hỏi'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      final formState = _formKey.currentState;
      if (formState == null) {
        AppLogger.error('🔴 [Generate] EXIT: _formKey.currentState is NULL!');
        return;
      }
      final isValid = formState.validate();
      AppLogger.info('🔵 [Generate] form.validate()=$isValid');
      if (!isValid) {
        AppLogger.warning('🟡 [Generate] EXIT: form validation failed');
        return;
      }
      if (_isQtyMismatch) {
        AppLogger.warning('🟡 [Generate] EXIT: _isQtyMismatch=true');
        return;
      }
    }
```

Note: The rest of `_handleGenerate()` (setState, then the try block with existing extraction & generation logic) remains **unchanged**.

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart 2>&1 | head -20
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "fix(ai): mode-aware validation — skip topic check in extraction; add ragGeneration coming-soon guard"
```

---

## Task 8: Auto-delete files after extraction completes

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`

- [ ] **Step 1: Add auto-delete in _pollForDocumentResults after status='completed'**

Locate `_pollForDocumentResults` (line 367). Find the `if (status == 'completed')` block. After the `AppLogger.info('[Poll] completed — extracted ${questions.length} question(s)');` line and BEFORE the `if (mounted) {` block, add:

**Add these lines:**
```dart
          // Auto-delete temp files after successful extraction
          final selectedIds =
              ref.read(aiGenerationSettingsNotifierProvider).selectedFileIds;
          for (final fileId in selectedIds) {
            try {
              await ref
                  .read(teacherFileRepositoryProvider)
                  .deleteFile(fileId);
              AppLogger.info('[Poll] auto-deleted temp fileId=$fileId');
            } catch (e) {
              AppLogger.warning(
                  '[Poll] auto-delete failed for fileId=$fileId: $e');
            }
          }
          if (selectedIds.isNotEmpty) {
            ref
                .read(aiGenerationSettingsNotifierProvider.notifier)
                .setSelectedFileIds([]);
            ref.invalidate(teacherFilesProvider);
          }
```

The final `if (status == 'completed')` block looks like:

```dart
        if (status == 'completed') {
          final result = row['result'] as Map<String, dynamic>?;
          final extraction = result?['extraction'] as Map<String, dynamic>?;
          final rawQuestions = extraction?['questions'] as List? ?? [];
          final questions = rawQuestions
              .map((q) => QuestionDTO.fromJson(q as Map<String, dynamic>))
              .toList();
          AppLogger.info('[Poll] completed — extracted ${questions.length} question(s)');

          // Auto-delete temp files after successful extraction
          final selectedIds =
              ref.read(aiGenerationSettingsNotifierProvider).selectedFileIds;
          for (final fileId in selectedIds) {
            try {
              await ref
                  .read(teacherFileRepositoryProvider)
                  .deleteFile(fileId);
              AppLogger.info('[Poll] auto-deleted temp fileId=$fileId');
            } catch (e) {
              AppLogger.warning(
                  '[Poll] auto-delete failed for fileId=$fileId: $e');
            }
          }
          if (selectedIds.isNotEmpty) {
            ref
                .read(aiGenerationSettingsNotifierProvider.notifier)
                .setSelectedFileIds([]);
            ref.invalidate(teacherFilesProvider);
          }

          if (mounted) {
            setState(() {
              _isPolling = false;
              _pollingStatus = null;
              _isGenerating = false;
            });
            showStagingArea(
              context,
              questions: questions,
              assignmentId: widget.assignmentId,
              onComplete: () {
                if (mounted) {
                  setState(() {
                    _generatedQuestions =
                        questions.map((q) => q.content).toList();
                  });
                }
              },
            );
          }
          return;
        }
```

- [ ] **Step 2: Ensure teacherFileRepositoryProvider is imported/accessible**

The provider is from `teacher_file_notifier.dart`. Add the import if not present:

```dart
import 'package:ai_mls/presentation/providers/teacher_file_notifier.dart';
```

- [ ] **Step 3: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart 2>&1 | head -20
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
git commit -m "feat(ai): auto-delete temp files after extraction completes"
```

---

## Task 9: Simplify AiQuestionSettingsScreen — remove mode toggle + ContextSourcesSection

**Files:**
- Modify: `lib/presentation/views/settings/ai_question_settings_screen.dart`

The `_buildAdvancedSection` method (lines 261–314) contains the mode SegmentedButton and ContextSourcesSection that are now on the main screen. Remove the entire section.

- [ ] **Step 1: Remove _buildAdvancedSection method and its call**

In `build()`, remove the line:
```dart
          _buildAdvancedSection(context, ref, isDark: isDark),
          SizedBox(height: DesignSpacing.xl),
```

Then delete the entire `_buildAdvancedSection` method (lines 261–314).

- [ ] **Step 2: Remove unused imports**

After the removal, the following imports are no longer needed in `ai_question_settings_screen.dart`:
- `import 'package:ai_mls/presentation/views/assignment/teacher/widgets/context_sources_section.dart';`
- `import 'package:ai_mls/presentation/providers/ai_generation_settings_notifier.dart';` (if `aiGenerationSettingsNotifierProvider` is no longer referenced elsewhere in the file — check first)

Run:
```bash
flutter analyze lib/presentation/views/settings/ai_question_settings_screen.dart 2>&1
```

Remove any imports flagged as unused.

- [ ] **Step 3: Analyze full project**

```bash
flutter analyze 2>&1 | grep -v "^Analyzing" | head -40
```

Expected: No errors. Fix any that appear.

- [ ] **Step 4: Run all tests**

```bash
flutter test 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/views/settings/ai_question_settings_screen.dart
git commit -m "refactor(settings): remove mode toggle + ContextSourcesSection from AiQuestionSettingsScreen"
```

---

## Self-Review

### Spec coverage check

| Spec requirement | Task |
|-----------------|------|
| 3-mode enum (promptOnly, extraction, ragGeneration) | Task 1 |
| deleteFile through data layer | Task 2 |
| EndDrawer with API Key, Doc Library, Tools | Task 3 |
| Header button → opens EndDrawer (not navigate) | Task 4 |
| Inline mode tabs (SegmentedButton) | Task 5 |
| Mode-aware body (file picker for modes 2&3) | Task 6 |
| topic validation only for Mode 1 | Task 7 |
| Mode 3 "coming soon" SnackBar | Task 7 |
| Auto-delete after extraction completes | Task 8 |
| Remove mode toggle from AiQuestionSettingsScreen | Task 9 |
| File lifecycle: auto-clear selectedFileIds after delete | Task 8 |
| Mode 1 logic completely untouched | Tasks 7–8 guard all Mode 1 paths |

### Placeholder scan — NONE found

### Type consistency check

- `ProcessingMode.promptOnly` — defined Task 1, used Tasks 5, 6, 7
- `ProcessingMode.extraction` — defined Task 1, used Tasks 6, 7 (existing check at line 513 unchanged)
- `ProcessingMode.ragGeneration` — defined Task 1, used Tasks 5, 6, 7
- `ITeacherFileRepository.deleteFile(String fileId)` — defined Task 2 Step 3, implemented Task 2 Step 4+5, called Task 2 Step 6, Task 8
- `teacherFileRepositoryProvider` — existing provider, used in Task 8
- `AiSettingsDrawer` — defined Task 3, used Task 4
- `_scaffoldKey` — defined Task 4 Step 1, used Task 4 Step 3
- `_focusHintController` — defined Task 6 Step 1, used Task 6 Step 3
- `DesignElevation.level1` — returns `BoxShadow`, used as `[DesignElevation.level1]` in `boxShadow` list ✓

---

**Plan complete and saved to `docs/superpowers/plans/2026-04-21-ai-generate-question-redesign.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** — Fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans skill, batch execution with checkpoints

**Which approach?**

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_file_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherFileRepositoryHash() =>
    r'ffe085a924048dd21cc3e18abb15a681d23d1fa0';

/// Repository provider — built with Supabase.instance (no supabaseClientProvider in codebase).
/// Class name: TeacherFileRepository → generates teacherFileRepositoryProvider
///
/// Copied from [teacherFileRepository].
@ProviderFor(teacherFileRepository)
final teacherFileRepositoryProvider =
    AutoDisposeProvider<ITeacherFileRepository>.internal(
      teacherFileRepository,
      name: r'teacherFileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherFileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherFileRepositoryRef =
    AutoDisposeProviderRef<ITeacherFileRepository>;
String _$teacherFilesHash() => r'fe57f54fa76eeb8806ebb5058a8d8f6c75d4a24a';

/// Async notifier for teacher's file library.
/// Class name `TeacherFiles` → generator produces `teacherFilesProvider`.
/// Plan 05 (ContextSourcesSection) uses: ref.watch(teacherFilesProvider)
///
/// Copied from [TeacherFiles].
@ProviderFor(TeacherFiles)
final teacherFilesProvider =
    AutoDisposeAsyncNotifierProvider<
      TeacherFiles,
      List<TeacherFileModel>
    >.internal(
      TeacherFiles.new,
      name: r'teacherFilesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherFilesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeacherFiles = AutoDisposeAsyncNotifier<List<TeacherFileModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

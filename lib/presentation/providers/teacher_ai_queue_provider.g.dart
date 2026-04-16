// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_ai_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherAiQueueWatcherHash() =>
    r'bcda097f4bf531954408f916bdc4610cf99aac5c';

/// Provider theo dõi và xử lý AI queue ngầm khi giáo viên đang dùng app.
///
/// - Tự động xử lý các pending items khi provider được khởi tạo
/// - Lắng nghe Realtime INSERT mới → xử lý ngay lập tức
/// - Hoàn toàn silent: không có UI state, không làm ảnh hưởng giao diện
/// - Ollama local trước → Groq fallback tự động
///
/// Usage: ref.watch(teacherAiQueueWatcherProvider) trong TeacherDashboardScreen
///
/// Copied from [TeacherAiQueueWatcher].
@ProviderFor(TeacherAiQueueWatcher)
final teacherAiQueueWatcherProvider =
    AutoDisposeNotifierProvider<TeacherAiQueueWatcher, void>.internal(
      TeacherAiQueueWatcher.new,
      name: r'teacherAiQueueWatcherProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherAiQueueWatcherHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeacherAiQueueWatcher = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

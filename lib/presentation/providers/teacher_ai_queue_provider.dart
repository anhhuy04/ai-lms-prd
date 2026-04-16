import 'package:ai_mls/core/services/teacher_ai_queue_processor.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'teacher_ai_queue_provider.g.dart';

/// Provider theo dõi và xử lý AI queue ngầm khi giáo viên đang dùng app.
///
/// - Tự động xử lý các pending items khi provider được khởi tạo
/// - Lắng nghe Realtime INSERT mới → xử lý ngay lập tức
/// - Hoàn toàn silent: không có UI state, không làm ảnh hưởng giao diện
/// - Ollama local trước → Groq fallback tự động
///
/// Usage: ref.watch(teacherAiQueueWatcherProvider) trong TeacherDashboardScreen
@riverpod
class TeacherAiQueueWatcher extends _$TeacherAiQueueWatcher {
  RealtimeChannel? _channel;
  bool _isRunning = false;
  final Set<String> _processingIds = {}; // tránh xử lý trùng

  @override
  void build() {
    ref.onDispose(_stop);
    _start();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void _start() {
    if (_isRunning) return;
    _isRunning = true;

    final supabase = Supabase.instance.client;
    final processor = TeacherAiQueueProcessor(supabase);

    // 1. Xử lý các pending items đang tồn tại (khi app mở lại)
    _processPendingOnStartup(supabase, processor);

    // 2. Lắng nghe insert mới qua Realtime
    _channel = supabase
        .channel('teacher-ai-queue-watcher')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ai_queue',
          callback: (payload) {
            final item = payload.newRecord;
            final status = item['status'] as String?;
            final type = item['request_type'] as String?;

            if (status == 'pending' && (type == 'feedback' || type == 'analysis')) {
              _processItemSilently(processor, item);
            }
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            AppLogger.info('[TeacherAI] Realtime subscribed — watching ai_queue');
          } else if (error != null) {
            AppLogger.warning('[TeacherAI] Realtime error: $error');
          }
        });
  }

  void _stop() {
    _channel?.unsubscribe();
    _channel = null;
    _isRunning = false;
    _processingIds.clear();
    AppLogger.info('[TeacherAI] Watcher stopped');
  }

  // ── Processing ─────────────────────────────────────────────────────────────

  Future<void> _processPendingOnStartup(
    SupabaseClient supabase,
    TeacherAiQueueProcessor processor,
  ) async {
    try {
      // Fetch pending + stuck processing (có thể do crash lần trước)
      final items = await supabase
          .from('ai_queue')
          .select()
          .inFilter('status', ['pending'])
          .inFilter('request_type', ['feedback', 'analysis'])
          .order('created_at')
          .limit(20);

      if (items.isEmpty) {
        AppLogger.info('[TeacherAI] No pending items on startup');
        return;
      }

      AppLogger.info('[TeacherAI] Processing ${items.length} pending items on startup');
      for (final item in items) {
        await _processItemSilently(processor, item);
      }
    } catch (e) {
      AppLogger.error('[TeacherAI] Startup fetch failed: $e');
    }
  }

  Future<void> _processItemSilently(
    TeacherAiQueueProcessor processor,
    Map<String, dynamic> item,
  ) async {
    final id = item['id'] as String?;
    if (id == null) return;

    // Guard: tránh xử lý trùng nếu Realtime + startup poll cùng nhận 1 item
    if (_processingIds.contains(id)) return;
    _processingIds.add(id);

    try {
      await processor.processItem(item);
    } finally {
      _processingIds.remove(id);
    }
  }
}

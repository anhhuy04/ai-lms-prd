/// Quyết định client-side: có cho phép học sinh nhấn nút "Làm lại" không.
///
/// Mirror logic của RPC `start_redo_session` để UI disable nút TRƯỚC khi
/// user nhấn (UX tốt hơn snackbar lỗi). Server vẫn là chốt cuối — KHÔNG
/// dựa vào hàm này để cho phép thực thi business.
///
/// Quy tắc (đồng bộ migration_22_redo_block_past_due):
///   • [allowRetake] = false → never (GV chưa bật).
///   • [maxAttempts] != null và [attemptCount] >= maxAttempts → never (hết lượt).
///   • [dueAt] != null và đã quá hạn → never (past_due luôn block redo,
///     bất kể allow_late vì allow_late chỉ áp cho lần đầu).
///   • Còn lại → cho phép.
///
/// [now] tuỳ chọn: dùng để test deterministic (clock injection).
bool canRedoNow({
  required bool allowRetake,
  required int attemptCount,
  int? maxAttempts,
  DateTime? dueAt,
  DateTime? now,
}) {
  if (!allowRetake) return false;
  if (maxAttempts != null && attemptCount >= maxAttempts) return false;
  if (dueAt != null) {
    final t = now ?? DateTime.now();
    if (t.isAfter(dueAt)) return false;
  }
  return true;
}

/// Lý do không cho redo — null nếu được phép. Dùng để hiển thị label phù
/// hợp trên nút (UX rõ hơn chỉ disable không thông báo gì).
RedoBlockedClient? whyCannotRedo({
  required bool allowRetake,
  required int attemptCount,
  int? maxAttempts,
  DateTime? dueAt,
  DateTime? now,
}) {
  if (!allowRetake) return RedoBlockedClient.notAllowed;
  if (maxAttempts != null && attemptCount >= maxAttempts) {
    return RedoBlockedClient.maxReached;
  }
  if (dueAt != null) {
    final t = now ?? DateTime.now();
    if (t.isAfter(dueAt)) return RedoBlockedClient.pastDue;
  }
  return null;
}

/// Lý do client-side ngăn redo (subset của RedoBlockReason server).
enum RedoBlockedClient { notAllowed, maxReached, pastDue }

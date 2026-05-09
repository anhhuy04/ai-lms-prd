import 'package:ai_mls/core/utils/redo_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests cho [canRedoNow] / [whyCannotRedo] — mirror logic của
/// `start_redo_session` RPC. Khoá business rule:
///   • allow_late chỉ áp cho LẦN ĐẦU làm bài (nhánh start session).
///   • REDO sau due_at luôn bị chặn — bất kể allow_late = true/false.
void main() {
  final clock = DateTime(2026, 1, 15, 10, 0, 0);

  group('canRedoNow — allow', () {
    test('cho phép khi đã bật retake, còn lượt, chưa đến hạn', () {
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 1,
          maxAttempts: 3,
          dueAt: clock.add(const Duration(hours: 2)),
          now: clock,
        ),
        isTrue,
      );
    });

    test('cho phép khi maxAttempts = null (unlimited)', () {
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 99,
          maxAttempts: null,
          dueAt: null,
          now: clock,
        ),
        isTrue,
      );
    });

    test('cho phép khi dueAt = null (không có hạn)', () {
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 0,
          maxAttempts: 5,
          dueAt: null,
          now: clock,
        ),
        isTrue,
      );
    });
  });

  group('canRedoNow — block', () {
    test('block khi GV chưa bật allow_retake', () {
      expect(
        canRedoNow(
          allowRetake: false,
          attemptCount: 1,
          maxAttempts: 3,
          dueAt: clock.add(const Duration(hours: 2)),
          now: clock,
        ),
        isFalse,
      );
    });

    test('block khi attemptCount >= maxAttempts', () {
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 3,
          maxAttempts: 3,
          dueAt: null,
          now: clock,
        ),
        isFalse,
      );
    });

    test('CORE RULE: past_due luôn block redo (allow_late không nới lỏng)',
        () {
      // Ngay cả khi allowRetake=true và còn lượt, hết hạn = chặn redo.
      // Đây là lock rule mà migration 22 đã áp ở server: allow_late chỉ
      // phục vụ lần đầu, KHÔNG bắc cầu sang redo.
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 1,
          maxAttempts: 5,
          dueAt: clock.subtract(const Duration(minutes: 1)),
          now: clock,
        ),
        isFalse,
      );
    });

    test('block đúng tại biên: now == dueAt+1ms → past_due', () {
      final due = clock;
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 1,
          maxAttempts: 5,
          dueAt: due,
          now: due.add(const Duration(milliseconds: 1)),
        ),
        isFalse,
      );
    });

    test('không block đúng tại biên: now == dueAt → vẫn cho redo', () {
      // isAfter() trả false khi bằng nhau → biên = chưa quá hạn.
      final due = clock;
      expect(
        canRedoNow(
          allowRetake: true,
          attemptCount: 1,
          maxAttempts: 5,
          dueAt: due,
          now: due,
        ),
        isTrue,
      );
    });
  });

  group('whyCannotRedo — phân loại lý do', () {
    test('null khi cho phép', () {
      expect(
        whyCannotRedo(
          allowRetake: true,
          attemptCount: 0,
          maxAttempts: 3,
          dueAt: clock.add(const Duration(hours: 1)),
          now: clock,
        ),
        isNull,
      );
    });

    test('notAllowed khi !allowRetake', () {
      expect(
        whyCannotRedo(
          allowRetake: false,
          attemptCount: 0,
          maxAttempts: 3,
          dueAt: null,
          now: clock,
        ),
        RedoBlockedClient.notAllowed,
      );
    });

    test('maxReached được ưu tiên trước pastDue khi cả hai đúng', () {
      // Ưu tiên: notAllowed > maxReached > pastDue. Test khoá thứ tự.
      expect(
        whyCannotRedo(
          allowRetake: true,
          attemptCount: 5,
          maxAttempts: 5,
          dueAt: clock.subtract(const Duration(hours: 1)),
          now: clock,
        ),
        RedoBlockedClient.maxReached,
      );
    });

    test('pastDue khi chỉ có hạn vi phạm', () {
      expect(
        whyCannotRedo(
          allowRetake: true,
          attemptCount: 1,
          maxAttempts: 5,
          dueAt: clock.subtract(const Duration(minutes: 5)),
          now: clock,
        ),
        RedoBlockedClient.pastDue,
      );
    });

    test('notAllowed ưu tiên cao nhất kể cả khi past_due', () {
      expect(
        whyCannotRedo(
          allowRetake: false,
          attemptCount: 5,
          maxAttempts: 5,
          dueAt: clock.subtract(const Duration(hours: 1)),
          now: clock,
        ),
        RedoBlockedClient.notAllowed,
      );
    });
  });

  group('Tách bạch start lần đầu vs redo (sanity check rule)', () {
    test('past_due + allow_late=true: helper redo block', () {
      // Helper này CHỈ dùng cho redo button. Nếu UI gọi cho start-lần-đầu
      // sẽ sai vì nó đã bao gồm past_due block. Test khẳng định:
      // helper KHÔNG được dùng cho start-lần-đầu (allow_late nới lỏng).
      final result = canRedoNow(
        allowRetake: true,
        attemptCount: 1,
        maxAttempts: 5,
        dueAt: clock.subtract(const Duration(hours: 1)),
        now: clock,
      );
      expect(result, isFalse,
          reason: 'redo block sau hạn kể cả allow_late=true');
    });
  });
}

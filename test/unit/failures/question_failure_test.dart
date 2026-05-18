import 'dart:io';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('QuestionFailure.fromPostgrest', () {
    test('23505 → DuplicateContentDetected', () {
      final e = const PostgrestException(message: 'dup', code: '23505');
      expect(QuestionFailure.fromPostgrest(e), isA<DuplicateContentDetected>());
    });
    test('42501 → PermissionDenied', () {
      final e = const PostgrestException(message: 'perm', code: '42501');
      expect(QuestionFailure.fromPostgrest(e), isA<PermissionDenied>());
    });
    test('PGRST116 → QuestionNotFound', () {
      final e = const PostgrestException(message: 'nf', code: 'PGRST116');
      expect(QuestionFailure.fromPostgrest(e), isA<QuestionNotFound>());
    });
    test('55P03 → RpcLockTimeout', () {
      final e = const PostgrestException(message: 'lock', code: '55P03');
      expect(QuestionFailure.fromPostgrest(e), isA<RpcLockTimeout>());
    });
    test('40001 → RpcLockTimeout', () {
      final e = const PostgrestException(message: 'serial', code: '40001');
      expect(QuestionFailure.fromPostgrest(e), isA<RpcLockTimeout>());
    });
    test('unknown code → UnknownQuestionFailure', () {
      final e = const PostgrestException(message: 'x', code: 'XXXXX');
      expect(QuestionFailure.fromPostgrest(e), isA<UnknownQuestionFailure>());
    });
  });

  group('QuestionFailure.fromAny', () {
    test('SocketException → NetworkFailure', () {
      const e = SocketException('no net');
      expect(QuestionFailure.fromAny(e), isA<NetworkFailure>());
    });
    test('passes through QuestionFailure unchanged', () {
      final orig = QuestionNotFound();
      expect(QuestionFailure.fromAny(orig), same(orig));
    });
    test('random Exception → UnknownQuestionFailure', () {
      expect(QuestionFailure.fromAny(StateError('x')), isA<UnknownQuestionFailure>());
    });
  });

  group('userMessage + shouldReportToSentry', () {
    test('userMessage is Vietnamese (Không / Lỗi / Bạn / Câu / Hệ thống / Có)', () {
      expect(QuestionNotFound().userMessage, contains('Không'));
      expect(NetworkFailure().userMessage, contains('Lỗi'));
      expect(PermissionDenied().userMessage, contains('Bạn'));
      expect(DuplicateContentDetected().userMessage, contains('Câu'));
      expect(RpcLockTimeout().userMessage, contains('Hệ thống'));
      expect(UnknownQuestionFailure(Exception('x')).userMessage, contains('Có'));
    });
    test('expected business errors skip sentry', () {
      expect(QuestionNotFound().shouldReportToSentry, false);
      expect(DuplicateContentDetected().shouldReportToSentry, false);
    });
    test('infrastructure/permission errors report sentry', () {
      expect(PermissionDenied().shouldReportToSentry, true);
      expect(NetworkFailure().shouldReportToSentry, true);
      expect(RpcLockTimeout().shouldReportToSentry, true);
      expect(SyncFailed(created: 0, linked: 0).shouldReportToSentry, true);
      expect(UnknownQuestionFailure(Exception('x')).shouldReportToSentry, true);
    });
  });

  group('DuplicateContentDetected.existingId', () {
    test('null when no details', () {
      final e = const PostgrestException(message: 'dup', code: '23505');
      final f = QuestionFailure.fromPostgrest(e) as DuplicateContentDetected;
      expect(f.existingId, isNull);
    });
  });
}

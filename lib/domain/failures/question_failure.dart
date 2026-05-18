import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sealed hierarchy of failures cho Question Bank feature.
///
/// Mapping nguồn lỗi (PostgrestException, SocketException, ...) sang
/// các loại failure cụ thể với userMessage tiếng Việt và flag
/// `shouldReportToSentry` để phân biệt business errors vs infrastructure errors.
sealed class QuestionFailure implements Exception {
  String get userMessage;
  bool get shouldReportToSentry;

  /// Map PostgrestException → QuestionFailure subtype theo SQLSTATE code.
  factory QuestionFailure.fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DuplicateContentDetected(
          existingId: _extractIdFromDetails(e.details),
        ),
      '42501' => PermissionDenied(),
      'PGRST116' => QuestionNotFound(),
      '40001' || '55P03' => RpcLockTimeout(),
      _ => UnknownQuestionFailure(e),
    };
  }

  /// Normalize bất kỳ object lỗi nào thành QuestionFailure.
  /// - Pass-through nếu đã là QuestionFailure
  /// - Delegate PostgrestException → fromPostgrest
  /// - SocketException / TimeoutException → NetworkFailure
  /// - Còn lại → UnknownQuestionFailure
  factory QuestionFailure.fromAny(Object e) {
    if (e is QuestionFailure) return e;
    if (e is PostgrestException) return QuestionFailure.fromPostgrest(e);
    if (e is SocketException || e is TimeoutException) return NetworkFailure();
    return UnknownQuestionFailure(e);
  }

  static String? _extractIdFromDetails(Object? details) {
    if (details is String) {
      final match = RegExp(r'\(([0-9a-f-]{36})\)').firstMatch(details);
      return match?.group(1);
    }
    return null;
  }
}

class QuestionNotFound implements QuestionFailure {
  @override
  String get userMessage => 'Không tìm thấy câu hỏi.';
  @override
  bool get shouldReportToSentry => false;
}

class DuplicateContentDetected implements QuestionFailure {
  final String? existingId;
  DuplicateContentDetected({this.existingId});
  @override
  String get userMessage => 'Câu hỏi tương tự đã tồn tại trong kho.';
  @override
  bool get shouldReportToSentry => false;
}

class PermissionDenied implements QuestionFailure {
  @override
  String get userMessage => 'Bạn không có quyền thực hiện thao tác này.';
  @override
  bool get shouldReportToSentry => true;
}

class NetworkFailure implements QuestionFailure {
  @override
  String get userMessage => 'Lỗi kết nối. Kiểm tra mạng và thử lại.';
  @override
  bool get shouldReportToSentry => true;
}

class RpcLockTimeout implements QuestionFailure {
  @override
  String get userMessage => 'Hệ thống đang bận. Vui lòng thử lại sau ít phút.';
  @override
  bool get shouldReportToSentry => true;
}

class SyncFailed implements QuestionFailure {
  final int created;
  final int linked;
  SyncFailed({required this.created, required this.linked});
  @override
  String get userMessage => 'Đồng bộ thất bại. Đã rollback toàn bộ.';
  @override
  bool get shouldReportToSentry => true;
}

class UnknownQuestionFailure implements QuestionFailure {
  final Object cause;
  UnknownQuestionFailure(this.cause);
  @override
  String get userMessage => 'Có lỗi xảy ra. Vui lòng thử lại.';
  @override
  bool get shouldReportToSentry => true;
}

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Dart port of SQL `compute_question_hash(jsonb)` function (migration 021).
///
/// Must produce IDENTICAL hashes to the Postgres function for client-side
/// duplicate pre-check to be reliable.
///
/// Algorithm:
///   1. Extract raw text:
///      - If `content.ops` is array → concatenate `insert` strings from each op
///      - Else if `content.text` is string → use it
///      - Else → `jsonEncode(content)` fallback
///   2. Normalize: lowercase + collapse `\s+` to single space + trim
///   3. SHA-256 hex encode UTF-8 bytes
class ContentHasher {
  static String compute(Map<String, dynamic>? content) {
    String rawText;

    if (content == null) {
      rawText = '';
    } else if (content['ops'] is List) {
      final ops = content['ops'] as List;
      rawText = ops
          .where((op) => op is Map && op['insert'] is String)
          .map((op) => (op as Map)['insert'] as String)
          .join();
    } else if (content['text'] is String) {
      rawText = content['text'] as String;
    } else {
      rawText = jsonEncode(content);
    }

    final normalized = rawText
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}

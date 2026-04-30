import 'package:flutter/foundation.dart';

/// Vai trò của file trong quá trình sinh câu hỏi AI.
///
/// - [template]: file được dùng làm mẫu cấu trúc (schema-only hoặc sameForm).
/// - [knowledgeSource]: file được dùng làm nguồn kiến thức (raw text).
///
/// Mặc định (null): auto-detect — template nếu có parsedQuestions, knowledge nếu không.
enum FileRole { template, knowledgeSource }

@immutable
class LocalTempFile {
  final String id;
  final String filename;
  final String mimeType;
  final Uint8List bytes;
  final String? extractedText; // null = chưa extract, '' = extract xong nhưng trống
  final List<Map<String, dynamic>>? parsedQuestions; // câu hỏi đã parse từ template
  final bool isExtracting;

  /// null = auto-detect (template nếu parsedQuestions != null, knowledge nếu không).
  final FileRole? fileRole;

  const LocalTempFile({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.bytes,
    this.extractedText,
    this.parsedQuestions,
    this.isExtracting = false,
    this.fileRole,
  });

  LocalTempFile copyWith({
    String? id,
    String? filename,
    String? mimeType,
    Uint8List? bytes,
    String? extractedText,
    List<Map<String, dynamic>>? parsedQuestions,
    bool? isExtracting,
    FileRole? fileRole,
  }) {
    return LocalTempFile(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      bytes: bytes ?? this.bytes,
      extractedText: extractedText ?? this.extractedText,
      parsedQuestions: parsedQuestions ?? this.parsedQuestions,
      isExtracting: isExtracting ?? this.isExtracting,
      fileRole: fileRole ?? this.fileRole,
    );
  }
}

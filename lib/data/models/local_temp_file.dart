import 'package:ai_mls/domain/entities/file_role.dart';
import 'package:flutter/foundation.dart';

export 'package:ai_mls/domain/entities/file_role.dart' show FileRole;

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

  /// Effective role: fileRole nếu được set thủ công, hoặc auto-detect.
  /// Single source of truth — dùng thay vì tính lại tại mỗi call site.
  FileRole get effectiveRole =>
      fileRole ?? (parsedQuestions?.isNotEmpty == true ? FileRole.template : FileRole.knowledgeSource);

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

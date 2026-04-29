import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/models/local_temp_file.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

class LocalTempFilesNotifier extends StateNotifier<List<LocalTempFile>> {
  LocalTempFilesNotifier() : super([]);

  /// Thêm file vào bộ nhớ tạm, extract text ngay lập tức. Trả về local ID.
  Future<String> addFile(Uint8List bytes, String filename, String mimeType) async {
    final id = 'local_${DateTime.now().microsecondsSinceEpoch}';

    // Thêm file vào state với isExtracting=true
    final tempFile = LocalTempFile(
      id: id,
      filename: filename,
      mimeType: mimeType,
      bytes: bytes,
      isExtracting: true,
    );
    state = [...state, tempFile];

    // Extract text hoặc parse template
    String? extracted;
    List<Map<String, dynamic>>? parsedQuestions;
    try {
      if (mimeType.contains('spreadsheetml') || filename.toLowerCase().endsWith('.xlsx')) {
        // Luôn extract raw text trước (để Mode 3 có thể dùng làm knowledge source)
        extracted = _extractFromXlsx(bytes);
        // Sau đó thử parse template — nếu có thì gán thêm parsedQuestions
        final templateQuestions = _parseXlsxAsTemplate(bytes);
        if (templateQuestions != null) parsedQuestions = templateQuestions;
      } else if (mimeType.contains('wordprocessingml') || filename.toLowerCase().endsWith('.docx')) {
        extracted = _extractFromDocx(bytes);
      } else if (mimeType.contains('pdf') || filename.toLowerCase().endsWith('.pdf')) {
        extracted = await _extractFromPdf(bytes);
      }
      if (parsedQuestions != null) {
        AppLogger.info('[LocalTempFile] Template Excel: ${parsedQuestions.length} câu hỏi + ${extracted?.length ?? 0} chars text từ $filename');
      } else {
        AppLogger.info('[LocalTempFile] Text extracted: ${extracted?.length ?? 0} chars từ $filename');
      }
    } catch (e) {
      AppLogger.warning('[LocalTempFile] Extraction failed for $filename: $e');
      extracted = '';
    }

    // Cập nhật state với text đã extract
    state = state.map((f) {
      if (f.id == id) {
        return f.copyWith(
          extractedText: extracted ?? '',
          parsedQuestions: parsedQuestions,
          isExtracting: false,
        );
      }
      return f;
    }).toList();
    return id;
  }

  /// Xóa file khỏi bộ nhớ tạm.
  void removeFile(String id) {
    state = state.where((f) => f.id != id).toList();
  }

  /// Lấy text đã extract của danh sách file IDs, ghép lại thành 1 chuỗi.
  String getExtractedTextForIds(List<String> ids) {
    final parts = state
        .where((f) => ids.contains(f.id) && (f.extractedText?.isNotEmpty == true))
        .map((f) => '=== ${f.filename} ===\n${f.extractedText}')
        .toList();
    return parts.join('\n\n---\n\n');
  }

  /// Xóa tất cả files.
  void clearAll() => state = [];

  /// Lấy knowledge context cho Mode 3 (Sinh từ tài liệu).
  ///
  /// Với Excel template: builder phụ thuộc [templateMode]:
  ///   • [TemplateMode.styleOnly] (default) → schema-only: chỉ tags + difficulty
  ///     + type. Tags được sanitize để loại bỏ số/đáp án/keyword leak. KHÔNG
  ///     gửi text/options. AI buộc phải tạo nội dung mới hoàn toàn.
  ///   • [TemplateMode.sameForm] → flow cũ: text + options shuffled (ẩn đáp án
  ///     đúng), dùng cho dạng math drill cần giữ cấu trúc/đổi giá trị.
  /// Với Word/PDF (parsedQuestions == null): lấy full extracted text — không
  /// phụ thuộc mode.
  String getKnowledgeContextForIds(
    List<String> ids, {
    TemplateMode templateMode = TemplateMode.styleOnly,
  }) {
    AppLogger.info('📄 [Context] getKnowledgeContextForIds: mode=${templateMode.name}, ids=${ids.length}');
    final parts = <String>[];
    for (final f in state.where((f) => ids.contains(f.id))) {
      if (f.parsedQuestions != null && f.parsedQuestions!.isNotEmpty) {
        final branch = templateMode == TemplateMode.styleOnly ? 'schema-only' : 'sameForm-full';
        AppLogger.info('📄 [Context] ${f.filename}: parsedQ=${f.parsedQuestions!.length} → $branch');
        final body = templateMode == TemplateMode.styleOnly
            ? _buildSchemaOnlyContext(f)
            : _buildTemplateStyleContext(f);
        AppLogger.info('📄 [Context] ${f.filename} output (${body.length} chars):\n${body.substring(0, body.length.clamp(0, 300))}…');
        parts.add('=== ${f.filename} ===\n$body');
      } else if (f.extractedText?.isNotEmpty == true) {
        AppLogger.info('📄 [Context] ${f.filename}: no parsedQ → raw text (${f.extractedText!.length} chars)');
        parts.add('=== ${f.filename} ===\n${f.extractedText}');
      }
    }
    final result = parts.join('\n\n---\n\n');
    AppLogger.info('📄 [Context] Total context: ${result.length} chars');
    return result;
  }

  /// Build context từ Excel template: hiển thị câu hỏi + lựa chọn (shuffle, ẩn đáp án đúng).
  String _buildTemplateStyleContext(LocalTempFile f) {
    final questions = f.parsedQuestions!;
    final sb = StringBuffer();
    sb.writeln(
      '[Tài liệu mẫu — ${questions.length} câu hỏi. '
      'Hãy tạo câu hỏi MỚI theo đúng cấu trúc/độ khó/văn phong này]',
    );
    sb.writeln();

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final text = (q['text'] as String? ?? '').trim();
      final difficulty = q['difficulty'] as int? ?? 3;
      final tags = (q['tags'] as List<dynamic>?)?.cast<String>().join(', ') ?? '';
      final options = q['options'] as List<dynamic>?;

      sb.write('${i + 1}. [Độ khó $difficulty/5');
      if (tags.isNotEmpty) sb.write(' | $tags');
      sb.writeln(']');
      sb.writeln('   $text');

      if (options != null && options.isNotEmpty) {
        // Chỉ gửi nội dung lựa chọn, KHÔNG đánh dấu đáp án đúng
        final texts = options
            .map((o) => (o['text'] as String? ?? '').trim())
            .where((t) => t.isNotEmpty)
            .toList()
          ..shuffle(); // Shuffle để AI không đoán được đáp án đúng qua vị trí
        sb.writeln('   Dạng lựa chọn: ${texts.join(' / ')}');
      }
      sb.writeln();
    }

    return sb.toString().trimRight();
  }

  /// Schema-only context: KHÔNG gửi text câu hỏi gốc, KHÔNG gửi options.
  /// Chỉ liệt kê metadata (type + difficulty + tags đã sanitize) cho mỗi câu.
  ///
  /// Format mỗi dòng: `Câu N: <type> độ khó X/5 — Tags: a, b`
  ///
  /// Tags sanitize: strip số/đơn vị/đáp án để chống leak gián tiếp khi giáo
  /// viên ghi tags như `"r=5, S=78.5"`, `"đáp án: A"`, `"correct=Hà Nội"`.
  String _buildSchemaOnlyContext(LocalTempFile f) {
    final questions = f.parsedQuestions!;
    final sb = StringBuffer();
    sb.writeln(
      '[Schema bài mẫu — ${questions.length} câu. AI CHỈ thấy metadata, '
      'KHÔNG có nội dung câu gốc. Hãy tạo câu MỚI hoàn toàn theo schema này.]',
    );
    sb.writeln();

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final type = q['type'];
      final typeStr = _formatTypeForSchema(type);
      final difficulty = q['difficulty'] as int? ?? 3;
      final rawTags = (q['tags'] as List<dynamic>?)?.cast<String>() ?? const [];
      final tags = _sanitizeTagsForSchema(rawTags).join(', ');

      sb.write('Câu ${i + 1}: $typeStr độ khó $difficulty/5');
      if (tags.isNotEmpty) sb.write(' — Tags: $tags');
      sb.writeln();
    }

    return sb.toString().trimRight();
  }

  /// Sanitize tags trước khi đưa vào schema-only context.
  ///
  /// Loại bỏ:
  /// - Số (đáp án numeric): `"r=5"`, `"78.5"`, `"3.14"`
  /// - Operator/equality: `"="`, `"→"`, `"≈"`, `"<"`, `">"`
  /// - Keyword leak: `"đáp án"`, `"correct"`, `"answer"`, `"key"`, `"sol"`
  /// - Tag rỗng sau strip
  List<String> _sanitizeTagsForSchema(List<String> tags) {
    final leakKeywords = RegExp(
      r'(đáp\s*án|correct|answer|key|solution|sol\b|=|→|≈)',
      caseSensitive: false,
    );
    final numberPattern = RegExp(r'\d+([.,]\d+)?');

    final out = <String>[];
    for (final raw in tags) {
      var t = raw.trim();
      if (t.isEmpty) continue;
      // Bỏ tag chứa keyword leak hoàn toàn (toàn bộ tag là cheat sheet).
      if (leakKeywords.hasMatch(t)) continue;
      // Strip số trong tag (giữ phần chữ).
      t = t.replaceAll(numberPattern, '').trim();
      // Strip kí tự thừa sau khi remove số.
      t = t.replaceAll(RegExp(r'[\s,;:.\-]+$'), '').trim();
      if (t.isEmpty) continue;
      out.add(t);
    }
    return out;
  }

  /// Format type cho schema. Hỗ trợ enum QuestionType + string.
  String _formatTypeForSchema(dynamic type) {
    if (type is QuestionType) {
      switch (type) {
        case QuestionType.multipleChoice:
          return 'MCQ 4 lựa chọn';
        case QuestionType.trueFalse:
          return 'Đúng/Sai';
        case QuestionType.essay:
          return 'Tự luận';
        case QuestionType.shortAnswer:
          return 'Trả lời ngắn';
        case QuestionType.fillBlank:
          return 'Điền chỗ trống';
        case QuestionType.matching:
          return 'Nối cặp';
        case QuestionType.math:
          return 'Toán';
        case QuestionType.problemSolving:
          return 'Bài toán giải';
        case QuestionType.fileUpload:
          return 'Nộp file';
      }
    }
    return type?.toString() ?? 'MCQ 4 lựa chọn';
  }

  /// Lấy questions đã parse từ Excel template cho các file IDs đã chọn.
  List<Map<String, dynamic>> getTemplateQuestionsForIds(List<String> ids) {
    return state
        .where((f) => ids.contains(f.id) && f.parsedQuestions != null)
        .expand((f) => f.parsedQuestions!)
        .toList();
  }

  Future<String> _extractFromPdf(Uint8List bytes) async {
    final doc = await PdfDocument.openData(bytes);
    final buffer = StringBuffer();
    try {
      for (final page in doc.pages) {
        final pageText = await page.loadText();
        final text = pageText.fullText.trim();
        if (text.isNotEmpty) {
          buffer.writeln(text);
          buffer.writeln();
        }
      }
    } finally {
      doc.dispose();
    }
    return buffer.toString().trim();
  }

  String _extractFromXlsx(Uint8List bytes) {
    final excel = ex.Excel.decodeBytes(bytes);
    final buffer = StringBuffer();
    for (final table in excel.tables.values) {
      for (final row in table.rows) {
        final rowText = row.map((cell) => cell?.value?.toString() ?? '').join('\t');
        if (rowText.trim().isNotEmpty) buffer.writeln(rowText);
      }
    }
    return buffer.toString();
  }

  String _extractFromDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentFile = archive.findFile('word/document.xml');
    if (documentFile == null) return '';
    final xmlContent = utf8.decode(documentFile.content as List<int>);
    // Strip XML tags, normalize whitespace
    return xmlContent
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Parse Excel theo format mẫu. Trả về null nếu không phải template.
  List<Map<String, dynamic>>? _parseXlsxAsTemplate(Uint8List bytes) {
    try {
      final excel = ex.Excel.decodeBytes(bytes);
      final tableNames = excel.tables.keys.toSet();

      // Kiểm tra có ít nhất 1 sheet đúng tên
      final hasTemplate = tableNames.contains('Trắc nghiệm') ||
          tableNames.contains('Tự luận') ||
          tableNames.contains('Đúng/Sai');
      if (!hasTemplate) return null;

      final questions = <Map<String, dynamic>>[];

      // ── Trắc nghiệm ──────────────────────────────────────────────────────────
      if (tableNames.contains('Trắc nghiệm')) {
        final sheet = excel.tables['Trắc nghiệm']!;
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final text = _cellStr(row, 1);
          if (text.isEmpty) continue;

          final a = _cellStr(row, 2);
          final b = _cellStr(row, 3);
          final c = _cellStr(row, 4);
          final d = _cellStr(row, 5);
          final correctLetter = _cellStr(row, 6).trim().toUpperCase();
          final difficulty = _cellInt(row, 7) ?? 3;
          final tags = _parseTags(_cellStr(row, 8));
          final correctIndex = const {'A': 0, 'B': 1, 'C': 2, 'D': 3}[correctLetter] ?? 0;

          questions.add({
            'type': QuestionType.multipleChoice,
            'text': text,
            'content': {'text': text, 'images': <dynamic>[]},
            'choices': [
              {'id': 0, 'content': {'text': a}, 'is_correct': correctIndex == 0},
              {'id': 1, 'content': {'text': b}, 'is_correct': correctIndex == 1},
              {'id': 2, 'content': {'text': c}, 'is_correct': correctIndex == 2},
              {'id': 3, 'content': {'text': d}, 'is_correct': correctIndex == 3},
            ],
            // Legacy format cho UI display (q['options'])
            'options': [
              {'text': a, 'isCorrect': correctIndex == 0},
              {'text': b, 'isCorrect': correctIndex == 1},
              {'text': c, 'isCorrect': correctIndex == 2},
              {'text': d, 'isCorrect': correctIndex == 3},
            ],
            'answer': {'correct_choice_ids': [correctIndex]},
            'difficulty': difficulty,
            'tags': tags,
          });
        }
      }

      // ── Tự luận ───────────────────────────────────────────────────────────────
      if (tableNames.contains('Tự luận')) {
        final sheet = excel.tables['Tự luận']!;
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final text = _cellStr(row, 1);
          if (text.isEmpty) continue;

          final expectedAnswer = _cellStr(row, 2);
          final difficulty = _cellInt(row, 3) ?? 3;
          final tags = _parseTags(_cellStr(row, 4));

          questions.add({
            'type': QuestionType.shortAnswer,
            'text': text,
            'content': {'text': text, 'images': <dynamic>[]},
            'answer': expectedAnswer.isNotEmpty
                ? {'expected_answer': expectedAnswer}
                : <String, dynamic>{},
            'difficulty': difficulty,
            'tags': tags,
          });
        }
      }

      // ── Đúng/Sai ──────────────────────────────────────────────────────────────
      if (tableNames.contains('Đúng/Sai')) {
        final sheet = excel.tables['Đúng/Sai']!;
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final text = _cellStr(row, 1);
          if (text.isEmpty) continue;

          final answerStr = _cellStr(row, 2).trim();
          final isTrue = answerStr == 'Đúng' || answerStr.toLowerCase() == 'true';
          final difficulty = _cellInt(row, 4) ?? 3;
          final tags = _parseTags(_cellStr(row, 5));

          questions.add({
            'type': QuestionType.trueFalse,
            'text': text,
            'content': {'text': text, 'images': <dynamic>[]},
            'choices': [
              {'id': 0, 'content': {'text': 'Đúng'}, 'is_correct': isTrue},
              {'id': 1, 'content': {'text': 'Sai'}, 'is_correct': !isTrue},
            ],
            // Legacy format cho UI display (q['options'])
            'options': [
              {'text': 'Đúng', 'isCorrect': isTrue},
              {'text': 'Sai', 'isCorrect': !isTrue},
            ],
            'answer': {'correct_choice_ids': [isTrue ? 0 : 1]},
            'difficulty': difficulty,
            'tags': tags,
          });
        }
      }

      if (questions.isEmpty) return null;
      AppLogger.info('[LocalTempFile] Parsed ${questions.length} questions from Excel template');
      return questions;
    } catch (e) {
      AppLogger.warning('[LocalTempFile] Excel template parse failed: $e');
      return null;
    }
  }

  String _cellStr(List<ex.Data?> row, int col) {
    if (col >= row.length) return '';
    return row[col]?.value?.toString().trim() ?? '';
  }

  int? _cellInt(List<ex.Data?> row, int col) {
    if (col >= row.length) return null;
    final v = row[col]?.value;
    if (v == null) return null;
    if (v is ex.IntCellValue) return v.value;
    if (v is ex.DoubleCellValue) return v.value.toInt();
    return int.tryParse(v.toString());
  }

  List<String> _parseTags(String raw) {
    if (raw.isEmpty) return [];
    return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }
}

/// Provider không autoDispose — giữ state xuyên suốt phiên làm việc.
final localTempFilesProvider =
    StateNotifierProvider<LocalTempFilesNotifier, List<LocalTempFile>>(
  (ref) => LocalTempFilesNotifier(),
);

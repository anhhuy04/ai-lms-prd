import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/document_parser.dart';
import 'package:ai_mls/data/models/local_temp_file.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:flutter/foundation.dart';
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

    // Extract text + parse template (CPU-heavy ops chạy trong background isolate).
    String? extracted;
    List<Map<String, dynamic>>? parsedQuestions;
    try {
      if (mimeType.contains('spreadsheetml') || filename.toLowerCase().endsWith('.xlsx')) {
        // CRITICAL E-1 fix: compute() để tránh block UI thread.
        final result = await compute(DocumentParser.processXlsx, bytes);
        extracted = result.text;
        parsedQuestions = result.questions;
      } else if (mimeType.contains('wordprocessingml') || filename.toLowerCase().endsWith('.docx')) {
        final result = await compute(DocumentParser.processDocx, bytes);
        extracted = result.text;
        parsedQuestions = result.questions;
      } else if (mimeType.contains('pdf') || filename.toLowerCase().endsWith('.pdf')) {
        // pdfrx đã async (native FFI) — không cần compute.
        extracted = await _extractFromPdf(bytes);
        if (extracted.isNotEmpty) {
          // parseDocxAsTemplate là regex thuần — fast trên main isolate.
          parsedQuestions = DocumentParser.parseDocxAsTemplate(extracted);
        }
      }
      if (parsedQuestions != null) {
        AppLogger.info('[LocalTempFile] Template parsed: ${parsedQuestions.length} câu hỏi + ${extracted?.length ?? 0} chars text từ $filename');
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

  /// T3-3: Đặt vai trò cho file (template / knowledgeSource).
  void updateFileRole(String id, FileRole role) {
    state = state.map((f) => f.id == id ? f.copyWith(fileRole: role) : f).toList();
  }

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
    // GAP-5: template schema TRƯỚC, KT raw text SAU — smartTruncate cắt từ cuối
    // nên chỉ KT bị cắt, schema mẫu luôn được giữ nguyên.
    final templateParts = <String>[];
    final ktParts = <String>[];
    for (final f in state.where((f) => ids.contains(f.id))) {
      // T3-3: dùng effectiveRole (single source of truth từ LocalTempFile.effectiveRole getter).
      final role = f.effectiveRole;
      final hasQuestions = f.parsedQuestions != null && f.parsedQuestions!.isNotEmpty;

      if (role == FileRole.template && hasQuestions) {
        final branch = templateMode == TemplateMode.styleOnly ? 'schema-only' : 'sameForm-full';
        AppLogger.info('📄 [Context] ${f.filename}: parsedQ=${f.parsedQuestions!.length} → $branch [role=template]');
        final body = templateMode == TemplateMode.styleOnly
            ? _buildSchemaOnlyContext(f)
            : _buildTemplateStyleContext(f);
        AppLogger.info('📄 [Context] ${f.filename} output (${body.length} chars):\n${body.substring(0, body.length.clamp(0, 300))}…');
        templateParts.add('=== ${f.filename} ===\n$body');
      } else if (f.extractedText?.isNotEmpty == true) {
        AppLogger.info('📄 [Context] ${f.filename}: → raw text (${f.extractedText!.length} chars) [role=${role.name}]');
        ktParts.add('=== ${f.filename} ===\n${f.extractedText}');
      }
    }
    final result = [...templateParts, ...ktParts].join('\n\n---\n\n');
    AppLogger.info('📄 [Context] Total context: ${result.length} chars (${templateParts.length} template, ${ktParts.length} KT parts)');
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
  /// Với template > 20 câu: cluster theo (type, difficulty) rồi sample đại diện
  /// tối đa 20 câu để tránh vượt token limit.
  ///
  /// T2-2: Nếu tags rỗng sau sanitize → fallback về topic từ tên file.
  String _buildSchemaOnlyContext(LocalTempFile f) {
    final allQuestions = f.parsedQuestions!;
    final questions = sampleQuestionsForSchema(allQuestions);
    final filenameTopic = filenameToTopic(f.filename);

    // P2-2: tính phân phối type từ toàn bộ allQuestions
    final typeCount = <String, int>{};
    for (final q in allQuestions) {
      final t = _formatTypeForSchema(q['type']);
      typeCount[t] = (typeCount[t] ?? 0) + 1;
    }
    final distStr = typeCount.entries
        .map((e) => '${e.value} ${e.key}')
        .join(' · ');

    final sb = StringBuffer();
    sb.writeln(
      '[Schema bài mẫu — ${allQuestions.length} câu tổng'
      '${questions.length < allQuestions.length ? " (hiển thị ${questions.length} mẫu đại diện)" : ""}. '
      'Phân phối: $distStr. '
      'AI CHỈ thấy metadata, KHÔNG có nội dung câu gốc. Hãy tạo câu MỚI hoàn toàn theo schema này.]',
    );
    sb.writeln();

    // FIX-B001: distinct subjects summary — chống AI domain drift.
    final distinctSubjects = allQuestions
        .map((q) => q['subject'] as String?)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .join(', ');
    if (distinctSubjects.isNotEmpty) {
      sb.writeln('CÁC MÔN HỌC TRONG MẪU: $distinctSubjects');
      sb.writeln('→ Tạo câu hỏi PHẢI thuộc các môn này, KHÔNG được lệch sang môn khác.');
      sb.writeln();
    }

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final type = q['type'];
      final typeStr = _formatTypeForSchema(type);
      final difficulty = q['difficulty'] as int? ?? 3;
      final rawTags = (q['tags'] as List<dynamic>?)?.cast<String>() ?? const [];
      final tags = _sanitizeTagsForSchema(rawTags).join(', ');
      final subject = q['subject'] as String?;

      sb.write('[Slot ${i + 1}] $typeStr độ khó $difficulty/5');
      // FIX-B001: ưu tiên subject (nguồn ground truth từ marker) trên tags/topic.
      if (subject != null && subject.isNotEmpty) {
        sb.write(' — Môn: $subject');
      } else if (tags.isNotEmpty) {
        sb.write(' — Tags: $tags');
      } else if (filenameTopic.isNotEmpty) {
        sb.write(' — Chủ đề: $filenameTopic');
      }
      sb.writeln();
    }

    return sb.toString().trimRight();
  }

  /// T2-1: Cluster questions by (type, difficulty) → sample evenly, max 20 total.
  @visibleForTesting
  List<Map<String, dynamic>> sampleQuestionsForSchema(
    List<Map<String, dynamic>> all,
  ) {
    const maxSample = 20;
    if (all.length <= maxSample) return all;

    final clusters = <String, List<Map<String, dynamic>>>{};
    for (final q in all) {
      final key = '${q['type']}_${q['difficulty'] ?? 3}';
      clusters.putIfAbsent(key, () => []).add(q);
    }

    final sampled = <Map<String, dynamic>>[];
    final clusterList = clusters.values.toList();
    final perCluster = (maxSample / clusterList.length).ceil().clamp(1, maxSample);

    for (final bucket in clusterList) {
      final take = bucket.length.clamp(0, perCluster);
      sampled.addAll(bucket.sublist(0, take));
      if (sampled.length >= maxSample) break;
    }

    AppLogger.info(
      '📄 [Context] _sampleQuestionsForSchema: ${all.length} → ${sampled.length} (${clusters.length} clusters)',
    );
    return sampled.sublist(0, sampled.length.clamp(0, maxSample));
  }

  /// T2-2: Derive topic hint from filename (strip ext, split camelCase/separators).
  @visibleForTesting
  String filenameToTopic(String filename) {
    var name = filename.replaceAll(RegExp(r'\.\w{1,5}$'), '');
    // Split camelCase: "QuizFlutter" → "Quiz Flutter"
    name = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );
    name = name.replaceAll(RegExp(r'[_\-.]'), ' ').trim().toLowerCase();
    // Strip trailing digits e.g. "so tay 01" → keep as-is (still meaningful)
    return name;
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

  /// Lấy questions đã parse từ template cho các file IDs đã chọn.
  /// T3-3: Chỉ lấy file có effectiveRole=template.
  List<Map<String, dynamic>> getTemplateQuestionsForIds(List<String> ids) {
    return state
        .where((f) => ids.contains(f.id) && f.parsedQuestions != null && f.effectiveRole == FileRole.template)
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


  // ── T3-2 delegates: parsing logic đã chuyển sang DocumentParser ──────────────

  /// @visibleForTesting wrapper — delegates sang DocumentParser.parseDocxAsTemplate.
  @visibleForTesting
  List<Map<String, dynamic>>? parseDocxAsTemplate(String text) =>
      DocumentParser.parseDocxAsTemplate(text);

}

/// Provider không autoDispose — giữ state xuyên suốt phiên làm việc.
final localTempFilesProvider =
    StateNotifierProvider<LocalTempFilesNotifier, List<LocalTempFile>>(
  (ref) => LocalTempFilesNotifier(),
);

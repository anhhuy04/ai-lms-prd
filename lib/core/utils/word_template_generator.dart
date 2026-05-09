import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_mls/core/utils/excel_template_generator.dart';
import 'package:ai_mls/core/utils/latex_to_omml.dart';
import 'package:archive/archive.dart';

enum WordDocType {
  questions('Câu hỏi', 'Template câu hỏi cho AI học văn phong'),
  knowledge('Kiến thức', 'Tài liệu kiến thức cho AI phân tích');

  const WordDocType(this.label, this.description);
  final String label;
  final String description;
}

class WordTemplateConfig {
  const WordTemplateConfig({
    this.type = WordDocType.questions,
    this.questionType = TemplateType.mixed,
    this.sampleCount = 5,
    this.includeGuide = true,
    this.includeExamples = true,
  });

  final WordDocType type;
  final TemplateType questionType;
  final int sampleCount;
  final bool includeGuide;
  final bool includeExamples;
}

/// Tạo file .docx (OOXML) cho 2 mục đích:
/// 1. [WordDocType.questions] — template câu hỏi, AI học văn phong → parse được qua DocumentParser.parseDocxAsTemplate().
/// 2. [WordDocType.knowledge] — scaffold tài liệu kiến thức, AI đọc raw text.
class WordTemplateGenerator {
  WordTemplateGenerator._();

  // ── OOXML boilerplate ──────────────────────────────────────────────────────

  static const _contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '</Types>';

  static const _rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="word/document.xml"/>'
      '</Relationships>';

  // ── Public API ─────────────────────────────────────────────────────────────

  static Uint8List generate(WordTemplateConfig config) {
    final xml = config.type == WordDocType.questions
        ? _buildQuestionsXml(config)
        : _buildKnowledgeXml(config);
    return _pack(xml);
  }

  /// Tạo file Word .docx từ danh sách câu hỏi đã được AI generate.
  ///
  /// Math LaTeX (`$...$`, `$$...$$`) trong question text + options + answer
  /// sẽ được convert sang OMML để Word render đúng dạng phân số, mũ, căn.
  ///
  /// Format output:
  /// - Title: "ĐỀ KIỂM TRA — {title}" (bold, center, size 14pt)
  /// - Mỗi câu: `Câu N: [text]` + 4 lựa chọn A/B/C/D + dòng `Đáp án: X` italic
  /// - Essay/short_answer: `Câu N: [text]` + `Đáp án mẫu: [expected]`
  /// - Fill blank: `Câu N: [text]` + `Đáp án: ô 1: ...`
  ///
  /// [questions] danh sách câu hỏi từ AI (`Map<String, dynamic>`)
  /// [title] tiêu đề đề kiểm tra (vd "Toán lớp 9 - Kiểm tra 15 phút")
  /// [includeAnswerKey] có in đáp án không (default true)
  static Uint8List generateFromQuestions(
    List<Map<String, dynamic>> questions, {
    String title = 'Đề kiểm tra',
    bool includeAnswerKey = true,
  }) {
    final buf = StringBuffer();
    buf.write(_docHead());

    buf.write(_p('ĐỀ KIỂM TRA — $title',
        bold: true, center: true, sizePt: 14, spaceAfter: true));
    buf.write(_blank);

    for (var i = 0; i < questions.length; i++) {
      buf.write(_buildQuestionParagraph(
        i + 1,
        questions[i],
        includeAnswerKey: includeAnswerKey,
      ));
    }

    buf.write(_docTail());
    return _pack(buf.toString());
  }

  // ── Question rendering (math-aware) ────────────────────────────────────────

  /// Build w:p paragraph chứa text có lẫn LaTeX math.
  /// Khác `_p()`: text được preprocess qua [LatexToOmml] (math → OMML),
  /// không escape thẳng. Nếu bold/italic/sizePt → inject rPr vào mọi `<w:r>`.
  static String _pMath(
    String text, {
    bool bold = false,
    bool italic = false,
    int? sizePt,
    bool center = false,
    bool spaceAfter = false,
  }) {
    final pPr = StringBuffer('<w:pPr>');
    if (center) pPr.write('<w:jc w:val="center"/>');
    if (spaceAfter) pPr.write('<w:spacing w:after="160"/>');
    pPr.write('</w:pPr>');

    final runs = LatexToOmml.convertParagraphContent(text);
    String formatted = runs;
    if (bold || italic || sizePt != null) {
      final rpr = _rpr(bold: bold, italic: italic, sizePt: sizePt);
      // Inject rPr ngay sau mỗi <w:r> (math `<m:r>` không bị ảnh hưởng).
      formatted = formatted.replaceAll('<w:r>', '<w:r>$rpr');
    }
    return '<w:p>${pPr.toString()}$formatted</w:p>';
  }

  /// Build full XML body cho 1 câu hỏi.
  static String _buildQuestionParagraph(
    int qNum,
    Map<String, dynamic> q, {
    required bool includeAnswerKey,
  }) {
    final buf = StringBuffer();
    final type = (q['type']?.toString() ?? '').toLowerCase();
    final text = _extractQuestionText(q);

    // Question text với "Câu N: " prefix.
    buf.write(_pMath('Câu $qNum: $text'));

    if (type == 'multiple_choice' || type == 'true_false' || type == 'math') {
      buf.write(_renderChoices(q, includeAnswerKey: includeAnswerKey));
    } else if (type == 'essay' || type == 'short_answer' || type == 'problem_solving') {
      final answer = q['answer'];
      if (includeAnswerKey && answer is Map && answer['expected_answer'] != null) {
        buf.write(_pMath(
          'Đáp án mẫu: ${answer['expected_answer']}',
          italic: true,
        ));
      }
    } else if (type == 'fill_blank') {
      final answer = q['answer'];
      if (includeAnswerKey && answer is Map && answer['blanks'] is List) {
        final blanks = answer['blanks'] as List;
        final lines = <String>[];
        for (var i = 0; i < blanks.length; i++) {
          final b = blanks[i];
          if (b is! Map) continue;
          final values = b['correct_values'];
          final vStr = values is List ? values.join(' / ') : values.toString();
          lines.add('Ô ${i + 1}: $vStr');
        }
        if (lines.isNotEmpty) {
          buf.write(_pMath('Đáp án: ${lines.join(', ')}', italic: true));
        }
      }
    }
    // matching: render text only (TODO mở rộng sau).

    buf.write(_blank);
    return buf.toString();
  }

  /// Render choices A/B/C/D + dòng đáp án cho MCQ / true_false / math.
  static String _renderChoices(
    Map<String, dynamic> q, {
    required bool includeAnswerKey,
  }) {
    final raw = (q['options'] as List?) ?? (q['choices'] as List?) ?? const [];
    final buf = StringBuffer();
    int correctIdx = -1;
    for (var i = 0; i < raw.length; i++) {
      final c = raw[i];
      if (c is! Map) continue;
      final cText = _extractChoiceText(c);
      final letter = String.fromCharCode(65 + i); // A, B, C, D
      buf.write(_pMath('$letter. $cText'));
      if (c['isCorrect'] == true || c['is_correct'] == true) correctIdx = i;
    }
    if (includeAnswerKey && correctIdx >= 0) {
      buf.write(_p(
        'Đáp án: ${String.fromCharCode(65 + correctIdx)}',
        italic: true,
      ));
    }
    return buf.toString();
  }

  /// Helper extract text từ question map
  /// (ưu tiên text > override_text > content.text).
  static String _extractQuestionText(Map<String, dynamic> q) {
    final t = q['text'];
    if (t is String && t.trim().isNotEmpty) return t;
    final ot = q['override_text'];
    if (ot is String && ot.trim().isNotEmpty) return ot;
    final c = q['content'];
    if (c is Map && c['text'] is String) return c['text'] as String;
    return '(câu hỏi không có nội dung)';
  }

  /// Helper extract text từ choice map (text > content.text).
  static String _extractChoiceText(Map c) {
    final t = c['text'];
    if (t is String && t.trim().isNotEmpty) return t;
    final ct = c['content'];
    if (ct is Map && ct['text'] is String) return ct['text'] as String;
    return '';
  }

  // ── ZIP packer ─────────────────────────────────────────────────────────────

  static Uint8List _pack(String documentXml) {
    final archive = Archive();

    void add(String path, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(path, bytes.length, bytes));
    }

    add('[Content_Types].xml', _contentTypes);
    add('_rels/.rels', _rootRels);
    add('word/document.xml', documentXml);

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  // ── XML helpers ────────────────────────────────────────────────────────────

  static String _e(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _rpr({bool bold = false, bool italic = false, int? sizePt}) {
    if (!bold && !italic && sizePt == null) return '';
    final buf = StringBuffer('<w:rPr>');
    if (bold) buf.write('<w:b/>');
    if (italic) buf.write('<w:i/>');
    if (sizePt != null) {
      final half = (sizePt * 2).toString();
      buf.write('<w:sz w:val="$half"/><w:szCs w:val="$half"/>');
    }
    buf.write('</w:rPr>');
    return buf.toString();
  }

  static String _p(
    String text, {
    bool bold = false,
    bool italic = false,
    bool center = false,
    int? sizePt,
    bool spaceAfter = false,
  }) {
    final pPr = StringBuffer('<w:pPr>');
    if (center) pPr.write('<w:jc w:val="center"/>');
    if (spaceAfter) pPr.write('<w:spacing w:after="160"/>');
    pPr.write('</w:pPr>');
    final rpr = _rpr(bold: bold, italic: italic, sizePt: sizePt);
    return '<w:p>${pPr.toString()}<w:r>$rpr'
        '<w:t xml:space="preserve">${_e(text)}</w:t></w:r></w:p>';
  }

  static const String _blank = '<w:p><w:pPr><w:spacing w:after="80"/></w:pPr></w:p>';

  static String _separator(String char, int count) =>
      _p(char * count, bold: false, spaceAfter: true);

  static String _docHead() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
      ' xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">'
      '<w:body>';

  static String _docTail() => '<w:sectPr>'
      '<w:pgSz w:w="12240" w:h="15840"/>'
      '<w:pgMar w:top="1440" w:right="1800" w:bottom="1440" w:left="1800"/>'
      '</w:sectPr>'
      '</w:body></w:document>';

  // ── Questions document ─────────────────────────────────────────────────────

  static String _buildQuestionsXml(WordTemplateConfig config) {
    final buf = StringBuffer();
    buf.write(_docHead());

    final qt = config.questionType;
    final isMcq = qt == TemplateType.multipleChoice;
    final isTf = qt == TemplateType.trueFalse;
    final isEssay = qt == TemplateType.essay;
    final isMixed = qt == TemplateType.mixed;

    // Title — phản ánh loại câu hỏi
    final typeLabel = switch (qt) {
      TemplateType.multipleChoice => 'TRẮC NGHIỆM',
      TemplateType.trueFalse => 'ĐÚNG / SAI',
      TemplateType.essay => 'TỰ LUẬN',
      TemplateType.mixed => 'HỖN HỢP',
    };
    buf.write(_p('NGÂN HÀNG CÂU HỎI — $typeLabel', bold: true, center: true, sizePt: 14, spaceAfter: true));
    buf.write(_blank);

    // Guide section
    if (config.includeGuide) {
      buf.write(_p('HƯỚNG DẪN SỬ DỤNG', bold: true, spaceAfter: true));
      buf.write(_p('• AI dùng file này để học văn phong và cấu trúc — AI sẽ tạo câu hỏi MỚI, không sao chép nguyên văn.'));
      buf.write(_p('• Điền câu hỏi của bạn theo đúng định dạng bên dưới. Giữ nguyên "Câu N:", "A.", "Đáp án:".'));
      if (isMcq || isMixed) buf.write(_p('• Trắc nghiệm: Ghi "Đáp án: B" (chữ cái A, B, C hoặc D).'));
      if (isTf || isMixed) buf.write(_p('• Đúng/Sai: Ghi "Đáp án: Đúng" hoặc "Đáp án: Sai".'));
      if (isEssay || isMixed) buf.write(_p('• Tự luận: Ghi "Đáp án: gợi ý trả lời ngắn gọn..." (có thể bỏ trống).'));
      buf.write(_p('• Lưu file định dạng .docx trước khi upload vào ứng dụng.'));
      buf.write(_p('• Tối đa 500 câu hỏi mỗi file.'));
      buf.write(_blank);
      buf.write(_separator('─', 60));
      buf.write(_blank);
    }

    int nextQ = 1;

    if (config.includeExamples) {
      buf.write(_p('VÍ DỤ ĐÃ ĐIỀN SẴN (xóa hoặc thay thế bằng câu hỏi của bạn)', bold: true, italic: true));
      buf.write(_blank);

      // MCQ examples
      if (isMcq || isMixed) {
        buf.write(_p('[ TRẮC NGHIỆM — Lịch sử ]', italic: true));
        buf.write(_p('Câu $nextQ: Chiến dịch Điện Biên Phủ kết thúc thắng lợi vào ngày tháng năm nào?'));
        buf.write(_p('A. 7 tháng 5 năm 1954'));
        buf.write(_p('B. 2 tháng 9 năm 1945'));
        buf.write(_p('C. 30 tháng 4 năm 1975'));
        buf.write(_p('D. 21 tháng 7 năm 1954'));
        buf.write(_p('Đáp án: A', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      if (isMcq || isMixed) {
        buf.write(_p('[ TRẮC NGHIỆM — Toán học ]', italic: true));
        buf.write(_p('Câu $nextQ: Giá trị của nghiệm phương trình 3x − 9 = 0 là:'));
        buf.write(_p('A. x = −9'));
        buf.write(_p('B. x = 9'));
        buf.write(_p('C. x = 3'));
        buf.write(_p('D. x = −3'));
        buf.write(_p('Đáp án: C', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      // Additional MCQ examples — only for pure MCQ mode (fill all 5 slots)
      if (isMcq && !isMixed) {
        buf.write(_p('[ TRẮC NGHIỆM — Vật lý ]', italic: true));
        buf.write(_p('Câu $nextQ: Đơn vị đo lực trong hệ đo lường quốc tế (SI) là:'));
        buf.write(_p('A. Joule (J)'));
        buf.write(_p('B. Newton (N)'));
        buf.write(_p('C. Pascal (Pa)'));
        buf.write(_p('D. Watt (W)'));
        buf.write(_p('Đáp án: B', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ TRẮC NGHIỆM — Hóa học ]', italic: true));
        buf.write(_p('Câu $nextQ: Công thức hóa học của nước là:'));
        buf.write(_p('A. H₂O₂'));
        buf.write(_p('B. HO'));
        buf.write(_p('C. H₂O'));
        buf.write(_p('D. H₃O'));
        buf.write(_p('Đáp án: C', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ TRẮC NGHIỆM — Sinh học ]', italic: true));
        buf.write(_p('Câu $nextQ: Bào quan nào trong tế bào thực vật thực hiện chức năng quang hợp?'));
        buf.write(_p('A. Ty thể'));
        buf.write(_p('B. Không bào'));
        buf.write(_p('C. Lục lạp'));
        buf.write(_p('D. Nhân tế bào'));
        buf.write(_p('Đáp án: C', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      // True/False examples
      if (isTf || isMixed) {
        buf.write(_p('[ ĐÚNG / SAI — Địa lý ]', italic: true));
        buf.write(_p('Câu $nextQ: Trái Đất là hành tinh thứ ba tính từ Mặt Trời trong Hệ Mặt Trời.'));
        buf.write(_p('Đáp án: Đúng', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      if (isTf || isMixed) {
        buf.write(_p('[ ĐÚNG / SAI — Hóa học ]', italic: true));
        buf.write(_p('Câu $nextQ: Nguyên tử cacbon (C) có 6 electron ở lớp ngoài cùng.'));
        buf.write(_p('Đáp án: Sai', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      // Additional TF examples — only for pure TF mode (fill all 5 slots)
      if (isTf && !isMixed) {
        buf.write(_p('[ ĐÚNG / SAI — Vật lý ]', italic: true));
        buf.write(_p('Câu $nextQ: Ánh sáng đi trong chân không nhanh hơn khi đi trong nước.'));
        buf.write(_p('Đáp án: Đúng', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ ĐÚNG / SAI — Sinh học ]', italic: true));
        buf.write(_p('Câu $nextQ: Quá trình quang hợp ở thực vật xảy ra trong lục lạp.'));
        buf.write(_p('Đáp án: Đúng', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ ĐÚNG / SAI — Lịch sử ]', italic: true));
        buf.write(_p('Câu $nextQ: Chiến dịch Điện Biên Phủ kết thúc vào ngày 7/5/1954, đánh dấu sự thất bại hoàn toàn của thực dân Pháp ở Đông Dương.'));
        buf.write(_p('Đáp án: Đúng', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      // Essay examples
      if (isEssay || isMixed) {
        buf.write(_p('[ TỰ LUẬN / NGẮN — Sinh học ]', italic: true));
        buf.write(_p('Câu $nextQ: Quá trình quang hợp ở thực vật diễn ra chủ yếu ở bộ phận nào? Tại sao?'));
        buf.write(_p('Đáp án: Diễn ra chủ yếu ở lá cây, nơi có diệp lục (chlorophyll) trong lục lạp để hấp thụ ánh sáng.', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      // Additional Essay examples — only for pure Essay mode (fill all 5 slots)
      if (isEssay && !isMixed) {
        buf.write(_p('[ TỰ LUẬN — Vật lý ]', italic: true));
        buf.write(_p('Câu $nextQ: Phát biểu định luật Ôm. Viết công thức và giải thích ý nghĩa các đại lượng.'));
        buf.write(_p('Đáp án: Cường độ dòng điện chạy qua dây dẫn tỉ lệ thuận với hiệu điện thế và tỉ lệ nghịch với điện trở: I = U/R (I: cường độ dòng điện A, U: hiệu điện thế V, R: điện trở Ω).', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ TỰ LUẬN — Hóa học ]', italic: true));
        buf.write(_p('Câu $nextQ: Giải thích tại sao dung dịch HCl có tính axit. Viết phương trình điện li.'));
        buf.write(_p('Đáp án: HCl là axit mạnh, điện li hoàn toàn trong nước tạo ion H⁺ gây tính axit. PTHH: HCl → H⁺ + Cl⁻.', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ TỰ LUẬN — Lịch sử ]', italic: true));
        buf.write(_p('Câu $nextQ: Nêu ý nghĩa lịch sử của Chiến dịch Điện Biên Phủ (1954) đối với phong trào giải phóng dân tộc thế giới.'));
        buf.write(_p('Đáp án: Đánh dấu sự sụp đổ của chủ nghĩa thực dân Pháp ở Đông Dương, cổ vũ phong trào giải phóng dân tộc ở châu Á, châu Phi, Mỹ La-tinh.', italic: true));
        buf.write(_blank);
        nextQ++;

        buf.write(_p('[ TỰ LUẬN — Toán học ]', italic: true));
        buf.write(_p('Câu $nextQ: Tìm giá trị của tham số m để phương trình x² − 2x + m = 0 có hai nghiệm phân biệt.'));
        buf.write(_p('Đáp án: Phương trình có hai nghiệm phân biệt khi Δ > 0 ⟺ 4 − 4m > 0 ⟺ m < 1.', italic: true));
        buf.write(_blank);
        nextQ++;
      }

      if (nextQ <= config.sampleCount) {
        buf.write(_separator('─', 60));
        buf.write(_p('CÂU HỎI CỦA BẠN (thêm câu từ đây trở đi)', bold: true));
        buf.write(_blank);
      }
    }

    // Blank slots — format khớp với loại đã chọn
    for (int i = nextQ; i <= config.sampleCount; i++) {
      if (isTf) {
        buf.write(_p('Câu $i: '));
        buf.write(_p('Đáp án: '));
      } else if (isEssay) {
        buf.write(_p('Câu $i: '));
        buf.write(_p('Đáp án: '));
      } else {
        // MCQ or mixed — default to MCQ blank
        buf.write(_p('Câu $i: '));
        buf.write(_p('A. '));
        buf.write(_p('B. '));
        buf.write(_p('C. '));
        buf.write(_p('D. '));
        buf.write(_p('Đáp án: '));
      }
      buf.write(_blank);
    }

    // Tip at bottom for mixed/no examples
    if (!config.includeExamples && isMixed) {
      buf.write(_separator('─', 60));
      buf.write(_p('Gợi ý định dạng câu Đúng/Sai:', italic: true));
      buf.write(_p('  Câu N: [Mệnh đề cần xác định]', italic: true));
      buf.write(_p('  Đáp án: Đúng', italic: true));
      buf.write(_blank);
      buf.write(_p('Gợi ý định dạng câu Tự luận:', italic: true));
      buf.write(_p('  Câu N: [Câu hỏi tự luận]', italic: true));
      buf.write(_p('  Đáp án: [Gợi ý trả lời]', italic: true));
    }

    buf.write(_docTail());
    return buf.toString();
  }

  // ── Knowledge document ─────────────────────────────────────────────────────

  static String _buildKnowledgeXml(WordTemplateConfig config) {
    final buf = StringBuffer();
    buf.write(_docHead());

    // Title
    buf.write(_p('TÀI LIỆU KIẾN THỨC — FILE MẪU', bold: true, center: true, sizePt: 14, spaceAfter: true));
    buf.write(_blank);

    // Guide section
    if (config.includeGuide) {
      buf.write(_p('HƯỚNG DẪN SỬ DỤNG', bold: true));
      buf.write(_p('• AI đọc toàn bộ nội dung tài liệu này và tạo câu hỏi dựa trên kiến thức.'));
      buf.write(_p('• KHÔNG cần viết câu hỏi trong file này — AI sẽ tự sinh câu hỏi từ nội dung bạn cung cấp.'));
      buf.write(_p('• Viết nội dung càng chi tiết, AI tạo câu hỏi càng chất lượng và đa dạng.'));
      buf.write(_p('• Có thể giữ hoặc xóa phần Hướng dẫn này — không ảnh hưởng đến kết quả.'));
      buf.write(_p('• Lưu file .docx trước khi upload vào ứng dụng.'));
      buf.write(_blank);
      buf.write(_separator('─', 60));
      buf.write(_blank);
    }

    // Metadata
    buf.write(_p('THÔNG TIN TÀI LIỆU', bold: true, spaceAfter: true));
    buf.write(_p('Chủ đề:    [Tên bài học / chủ đề]'));
    buf.write(_p('Môn học:   [Tên môn học — Toán, Lý, Hóa, Sử, Địa, Văn, ...]'));
    buf.write(_p('Khối lớp:  [Lớp — ví dụ: Lớp 10, Lớp 11, Lớp 12]'));
    buf.write(_p('Tuần học:  [Tuần và học kỳ (tùy chọn)]'));
    buf.write(_blank);
    buf.write(_separator('═', 56));
    buf.write(_blank);

    // Section I
    buf.write(_p('I. TỔNG QUAN', bold: true, spaceAfter: true));
    buf.write(_blank);
    buf.write(_p('[Viết 1–2 đoạn văn giới thiệu tổng quan về chủ đề: định nghĩa, tầm quan trọng, '
        'lịch sử hình thành hoặc liên hệ với bài đã học. Đây là phần mở đầu để AI hiểu '
        'ngữ cảnh của toàn bộ tài liệu.]', italic: true));
    buf.write(_blank);
    buf.write(_separator('═', 56));
    buf.write(_blank);

    // Section II
    buf.write(_p('II. NỘI DUNG CHÍNH', bold: true, spaceAfter: true));
    buf.write(_blank);

    for (final entry in [
      ('1', 'Tên khái niệm / mục tiêu học tập thứ nhất', 'Giải thích chi tiết khái niệm, định nghĩa, '
          'công thức, nguyên tắc. Nên có ví dụ minh họa cụ thể ngay trong phần này.'),
      ('2', 'Tên khái niệm / mục tiêu học tập thứ hai', 'Giải thích khái niệm thứ hai. '
          'Có thể so sánh, đối chiếu với khái niệm đã nêu ở phần 1.'),
      ('3', 'Tên khái niệm / mục tiêu học tập thứ ba', 'Giải thích khái niệm thứ ba. '
          'Có thể trình bày quá trình, cơ chế, bước thực hiện, hoặc ứng dụng thực tế.'),
    ]) {
      buf.write(_p('${entry.$1}. [${entry.$2}]', bold: true));
      buf.write(_p('[${entry.$3}]', italic: true));
      buf.write(_blank);
    }

    buf.write(_separator('═', 56));
    buf.write(_blank);

    // Section III
    buf.write(_p('III. VÍ DỤ VÀ ỨNG DỤNG THỰC TẾ', bold: true, spaceAfter: true));
    buf.write(_blank);
    buf.write(_p('Ví dụ 1: [Mô tả ví dụ, tình huống, bài toán, sự kiện hoặc thí nghiệm thứ nhất. '
        'Càng cụ thể càng tốt: có số liệu, ngày tháng, nhân vật, địa điểm...]', italic: true));
    buf.write(_blank);
    buf.write(_p('Ví dụ 2: [Mô tả ví dụ thứ hai...]', italic: true));
    buf.write(_blank);
    buf.write(_p('Ví dụ 3: [Mô tả ví dụ thứ ba...]', italic: true));
    buf.write(_blank);
    buf.write(_separator('═', 56));
    buf.write(_blank);

    // Section IV
    buf.write(_p('IV. ĐIỂM CỐT LÕI CẦN GHI NHỚ', bold: true, spaceAfter: true));
    buf.write(_blank);
    buf.write(_p('[Liệt kê 4–6 điểm then chốt: định nghĩa ngắn, công thức, mốc ngày tháng, số liệu quan trọng. '
        'AI sẽ ưu tiên tạo câu hỏi kiểm tra các điểm này.]', italic: true));
    buf.write(_blank);
    for (final pt in ['Điểm 1: ...', 'Điểm 2: ...', 'Điểm 3: ...', 'Điểm 4: ...']) {
      buf.write(_p('- [$pt]', italic: true));
    }
    buf.write(_blank);
    buf.write(_separator('═', 56));
    buf.write(_blank);

    // Section V
    buf.write(_p('V. TỪ KHÓA VÀ THUẬT NGỮ CHUYÊN MÔN', bold: true, spaceAfter: true));
    buf.write(_blank);
    buf.write(_p('[Liệt kê các thuật ngữ, khái niệm chuyên ngành có trong bài kèm định nghĩa ngắn. '
        'AI sẽ dùng các thuật ngữ này trong câu hỏi để đúng với văn phong môn học.]', italic: true));
    buf.write(_blank);
    for (final kw in [
      'Thuật ngữ 1: [định nghĩa ngắn]',
      'Thuật ngữ 2: [định nghĩa ngắn]',
      'Thuật ngữ 3: [định nghĩa ngắn]',
      'Thuật ngữ 4: [định nghĩa ngắn]',
    ]) {
      buf.write(_p('- [$kw]', italic: true));
    }
    buf.write(_blank);

    buf.write(_docTail());
    return buf.toString();
  }
}

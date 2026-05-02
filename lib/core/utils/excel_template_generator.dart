import 'package:excel/excel.dart';

enum TemplateType {
  mixed('Hỗn hợp', 'Trắc nghiệm + Tự luận + Đúng/Sai'),
  multipleChoice('Trắc nghiệm', 'Câu hỏi nhiều lựa chọn A/B/C/D'),
  essay('Tự luận', 'Câu hỏi tự luận / câu ngắn'),
  trueFalse('Đúng/Sai', 'Câu hỏi nhị phân Đúng/Sai');

  const TemplateType(this.label, this.description);

  final String label;
  final String description;

  List<String> get sheets {
    switch (this) {
      case TemplateType.mixed:
        return ['Trắc nghiệm', 'Tự luận', 'Đúng/Sai'];
      case TemplateType.multipleChoice:
        return ['Trắc nghiệm'];
      case TemplateType.essay:
        return ['Tự luận'];
      case TemplateType.trueFalse:
        return ['Đúng/Sai'];
    }
  }
}

class ExcelTemplateConfig {
  const ExcelTemplateConfig({
    this.type = TemplateType.mixed,
    this.sampleCount = 5,
    this.includeGuide = true,
    this.includeExamples = true,
    this.colorHeaders = true,
  });

  final TemplateType type;
  final int sampleCount;
  final bool includeGuide;
  final bool includeExamples;
  final bool colorHeaders;
}

class ExcelTemplateGenerator {
  static final _headerBg = ExcelColor.fromHexString('FF1A6FAB');
  static final _headerFg = ExcelColor.white;
  static final _sectionBg = ExcelColor.fromHexString('FFE8F5E9');

  static List<int>? generate(ExcelTemplateConfig config) {
    final excel = Excel.createExcel();

    if (config.includeGuide) _buildGuideSheet(excel);

    switch (config.type) {
      case TemplateType.mixed:
        _buildMultipleChoiceSheet(excel, config);
        _buildEssaySheet(excel, config);
        _buildTrueFalseSheet(excel, config);
      case TemplateType.multipleChoice:
        _buildMultipleChoiceSheet(excel, config);
      case TemplateType.essay:
        _buildEssaySheet(excel, config);
      case TemplateType.trueFalse:
        _buildTrueFalseSheet(excel, config);
    }

    excel.delete('Sheet1');
    return excel.save();
  }

  // ── Guide sheet ─────────────────────────────────────────────────────────────

  static void _buildGuideSheet(Excel excel) {
    final sheet = excel['Hướng dẫn'];
    final titleStyle = CellStyle(bold: true, fontSize: 14);
    final sectionStyle = CellStyle(bold: true, fontSize: 11);
    final noteStyle = CellStyle(italic: true, fontSize: 10);

    _writeCell(sheet, 'A1', 'HƯỚNG DẪN SỬ DỤNG FILE MẪU EXCEL', style: titleStyle);

    _writeCell(sheet, 'A3', '1. Cấu trúc file:', style: sectionStyle);
    _writeCell(sheet, 'A4', '  • Sheet "Trắc nghiệm" — Câu hỏi nhiều lựa chọn A/B/C/D');
    _writeCell(sheet, 'A5', '  • Sheet "Tự luận"      — Câu hỏi tự luận hoặc trả lời ngắn');
    _writeCell(sheet, 'A6', '  • Sheet "Đúng/Sai"     — Câu hỏi mệnh đề nhị phân');

    _writeCell(sheet, 'A8', '2. Quy tắc nhập liệu:', style: sectionStyle);
    _writeCell(sheet, 'A9',  '  • Độ khó: số nguyên từ 1 (rất dễ) đến 5 (rất khó)');
    _writeCell(sheet, 'A10', '  • Đáp án đúng (Trắc nghiệm): chữ cái A, B, C hoặc D');
    _writeCell(sheet, 'A11', '  • Đáp án đúng (Đúng/Sai): ghi đúng "Đúng" hoặc "Sai"');
    _writeCell(sheet, 'A12', '  • Tags / Từ khóa: phân cách bằng dấu phẩy. Ví dụ: chương3, đại số');
    _writeCell(sheet, 'A13', '  • Cột "Gợi ý trả lời" (Tự luận): điền gợi ý để AI biết độ khó, có thể để trống');

    _writeCell(sheet, 'A15', '3. Lưu ý quan trọng:', style: sectionStyle);
    _writeCell(sheet, 'A16', '  • KHÔNG xóa hoặc đổi tên hàng tiêu đề (hàng 1 của mỗi sheet)');
    _writeCell(sheet, 'A17', '  • Cột STT tự động tạo lại khi import — không cần điền chính xác');
    _writeCell(sheet, 'A18', '  • Tối đa 500 câu hỏi mỗi lần import');
    _writeCell(sheet, 'A19', '  • File mẫu này áp dụng cho MỌI môn học — xem ví dụ ở từng sheet');
    _writeCell(sheet, 'A20', '  • Lưu file dưới định dạng .xlsx trước khi import');

    _writeCell(sheet, 'A22', '4. AI hoạt động như thế nào:', style: sectionStyle);
    _writeCell(sheet, 'A23', '  • AI đọc file này làm MẪU VĂN PHONG — không sao chép câu hỏi gốc');
    _writeCell(sheet, 'A24', '  • AI học cấu trúc, độ khó, chủ đề từ file, rồi tạo câu hỏi MỚI');
    _writeCell(sheet, 'A25', '  • Câu hỏi mẫu càng đa dạng, AI tạo ra càng phong phú', style: noteStyle);

    sheet.setColumnWidth(0, 80);
  }

  // ── Multiple choice sheet ───────────────────────────────────────────────────

  static void _buildMultipleChoiceSheet(Excel excel, ExcelTemplateConfig config) {
    final sheet = excel['Trắc nghiệm'];
    const headers = [
      'STT', 'Nội dung câu hỏi', 'Đáp án A', 'Đáp án B', 'Đáp án C', 'Đáp án D',
      'Đáp án đúng (A/B/C/D)', 'Độ khó (1-5)', 'Tags / Từ khóa',
    ];
    const widths = [7.0, 55.0, 24.0, 24.0, 24.0, 24.0, 18.0, 13.0, 24.0];

    _writeHeaders(sheet, headers, config.colorHeaders, widths);

    int added = 0;
    if (config.includeExamples) {
      // Example 1 — Lịch sử
      if (config.sampleCount >= 1) {
        _writeExampleRow(sheet, config.colorHeaders);
        sheet.appendRow([
          IntCellValue(1),
          TextCellValue('Chiến dịch Điện Biên Phủ kết thúc thắng lợi vào ngày tháng năm nào?'),
          TextCellValue('7/5/1954'),
          TextCellValue('2/9/1945'),
          TextCellValue('30/4/1975'),
          TextCellValue('21/7/1954'),
          TextCellValue('A'),
          IntCellValue(2),
          TextCellValue('lịch sử, chiến tranh, Điện Biên Phủ'),
        ]);
        added++;
      }
      // Example 2 — Toán học
      if (config.sampleCount >= 2) {
        sheet.appendRow([
          IntCellValue(2),
          TextCellValue('Diện tích hình chữ nhật có chiều dài 12 cm và chiều rộng 8 cm là bao nhiêu?'),
          TextCellValue('20 cm²'),
          TextCellValue('96 cm²'),
          TextCellValue('40 cm²'),
          TextCellValue('192 cm²'),
          TextCellValue('B'),
          IntCellValue(1),
          TextCellValue('toán, hình học, diện tích'),
        ]);
        added++;
      }
      // Example 3 — Ngữ văn
      if (config.sampleCount >= 3) {
        sheet.appendRow([
          IntCellValue(3),
          TextCellValue('Tác phẩm "Truyện Kiều" được Nguyễn Du viết theo thể loại nào?'),
          TextCellValue('Thơ lục bát'),
          TextCellValue('Thơ thất ngôn tứ tuyệt'),
          TextCellValue('Truyện thơ Nôm'),
          TextCellValue('Thơ Đường luật'),
          TextCellValue('C'),
          IntCellValue(3),
          TextCellValue('ngữ văn, Nguyễn Du, truyện Kiều'),
        ]);
        added++;
      }
    }

    for (int i = added + 1; i <= config.sampleCount; i++) {
      sheet.appendRow([
        IntCellValue(i), TextCellValue(''), TextCellValue(''), TextCellValue(''),
        TextCellValue(''), TextCellValue(''), TextCellValue('A'), IntCellValue(3), TextCellValue(''),
      ]);
    }
  }

  // ── Essay sheet ─────────────────────────────────────────────────────────────

  static void _buildEssaySheet(Excel excel, ExcelTemplateConfig config) {
    final sheet = excel['Tự luận'];
    const headers = [
      'STT', 'Nội dung câu hỏi', 'Gợi ý trả lời / Đáp án tham khảo', 'Độ khó (1-5)', 'Tags / Từ khóa',
    ];
    const widths = [7.0, 58.0, 50.0, 13.0, 24.0];

    _writeHeaders(sheet, headers, config.colorHeaders, widths);

    int added = 0;
    if (config.includeExamples) {
      // Example 1 — Sinh học
      if (config.sampleCount >= 1) {
        _writeExampleRow(sheet, config.colorHeaders);
        sheet.appendRow([
          IntCellValue(1),
          TextCellValue('Trình bày khái niệm quang hợp ở thực vật và cho biết quá trình này diễn ra chủ yếu ở đâu.'),
          TextCellValue('Quang hợp là quá trình thực vật dùng ánh sáng, CO₂ và nước để tạo ra glucose và O₂. '
              'Diễn ra chủ yếu ở lá cây, trong lục lạp chứa diệp lục (chlorophyll).'),
          IntCellValue(3),
          TextCellValue('sinh học, quang hợp, thực vật'),
        ]);
        added++;
      }
      // Example 2 — Địa lý / GDCD
      if (config.sampleCount >= 2) {
        sheet.appendRow([
          IntCellValue(2),
          TextCellValue('Nêu hai đặc điểm chính phân biệt kinh tế thị trường với kinh tế kế hoạch hóa tập trung.'),
          TextCellValue('Kinh tế thị trường: giá cả do cung cầu quyết định, doanh nghiệp tự chủ sản xuất. '
              'Kinh tế kế hoạch hóa: Nhà nước kiểm soát giá và phân bổ nguồn lực theo kế hoạch.'),
          IntCellValue(4),
          TextCellValue('GDCD, kinh tế, thị trường'),
        ]);
        added++;
      }
    }

    for (int i = added + 1; i <= config.sampleCount; i++) {
      sheet.appendRow([
        IntCellValue(i), TextCellValue(''), TextCellValue(''), IntCellValue(3), TextCellValue(''),
      ]);
    }
  }

  // ── True/False sheet ────────────────────────────────────────────────────────

  static void _buildTrueFalseSheet(Excel excel, ExcelTemplateConfig config) {
    final sheet = excel['Đúng/Sai'];
    const headers = [
      'STT', 'Nội dung câu hỏi / Mệnh đề', 'Đáp án đúng (Đúng/Sai)',
      'Giải thích (tùy chọn)', 'Độ khó (1-5)', 'Tags / Từ khóa',
    ];
    const widths = [7.0, 58.0, 18.0, 44.0, 13.0, 24.0];

    _writeHeaders(sheet, headers, config.colorHeaders, widths);

    int added = 0;
    if (config.includeExamples) {
      // Example 1 — Địa lý
      if (config.sampleCount >= 1) {
        _writeExampleRow(sheet, config.colorHeaders);
        sheet.appendRow([
          IntCellValue(1),
          TextCellValue('Trái Đất là hành tinh thứ ba tính từ Mặt Trời trong Hệ Mặt Trời.'),
          TextCellValue('Đúng'),
          TextCellValue('Thứ tự từ Mặt Trời: Sao Thủy, Sao Kim, Trái Đất, Sao Hỏa...'),
          IntCellValue(1),
          TextCellValue('địa lý, vũ trụ, hệ mặt trời'),
        ]);
        added++;
      }
      // Example 2 — Hóa học
      if (config.sampleCount >= 2) {
        sheet.appendRow([
          IntCellValue(2),
          TextCellValue('Nguyên tử cacbon (C) có 6 electron ở lớp ngoài cùng.'),
          TextCellValue('Sai'),
          TextCellValue('Cacbon có số hiệu nguyên tử 6, cấu hình electron 2-4 → lớp ngoài cùng có 4 electron.'),
          IntCellValue(3),
          TextCellValue('hóa học, nguyên tử, cacbon'),
        ]);
        added++;
      }
      // Example 3 — Vật lý
      if (config.sampleCount >= 3) {
        sheet.appendRow([
          IntCellValue(3),
          TextCellValue('Ánh sáng đi trong chân không nhanh hơn khi đi trong nước.'),
          TextCellValue('Đúng'),
          TextCellValue('Vận tốc ánh sáng trong chân không ≈ 3×10⁸ m/s, trong nước ≈ 2,25×10⁸ m/s.'),
          IntCellValue(2),
          TextCellValue('vật lý, quang học, tốc độ ánh sáng'),
        ]);
        added++;
      }
    }

    for (int i = added + 1; i <= config.sampleCount; i++) {
      sheet.appendRow([
        IntCellValue(i), TextCellValue(''), TextCellValue('Đúng'), TextCellValue(''),
        IntCellValue(3), TextCellValue(''),
      ]);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static void _writeHeaders(
    Sheet sheet,
    List<String> headers,
    bool colored,
    List<double> widths,
  ) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = colored
          ? CellStyle(
              backgroundColorHex: _headerBg,
              fontColorHex: _headerFg,
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center,
            )
          : CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    }
    for (int i = 0; i < widths.length && i < headers.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
    sheet.setRowHeight(0, 36);
  }

  // Thêm 1 hàng section label "VÍ DỤ" trước khi điền câu đầu tiên
  static void _writeExampleRow(Sheet sheet, bool colored) {
    final row = sheet.rows.length;
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = TextCellValue('— VÍ DỤ MẪU (xóa hoặc thay thế bằng câu hỏi của bạn) —');
    cell.cellStyle = colored
        ? CellStyle(
            italic: true,
            fontSize: 9,
            backgroundColorHex: _sectionBg,
            fontColorHex: ExcelColor.fromHexString('FF555555'),
          )
        : CellStyle(
            italic: true,
            fontSize: 9,
            fontColorHex: ExcelColor.fromHexString('FF555555'),
          );
  }

  static void _writeCell(Sheet sheet, String cellRef, String value, {CellStyle? style}) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.value = TextCellValue(value);
    if (style != null) cell.cellStyle = style;
  }
}

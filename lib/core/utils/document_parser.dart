import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/foundation.dart' show visibleForTesting;

/// Kết quả parse xlsx: raw text + optional câu hỏi đã parse.
typedef XlsxParseResult = ({String text, List<Map<String, dynamic>>? questions});

/// Kết quả parse docx/pdf: raw text + optional câu hỏi đã parse.
typedef DocxParseResult = ({String text, List<Map<String, dynamic>>? questions});

/// Pure document parsing utilities — chỉ static methods, không có instance state.
///
/// An toàn để gọi từ background isolate qua Flutter's compute():
///   `await compute(DocumentParser.processXlsx, bytes)`
///   `await compute(DocumentParser.processDocx, bytes)`
class DocumentParser {
  DocumentParser._();

  // ── Entry points dùng với compute() ──────────────────────────────────────

  /// Process xlsx: extract text + try parse template. Dùng với compute().
  static XlsxParseResult processXlsx(Uint8List bytes) {
    final text = extractFromXlsx(bytes);
    final questions = parseXlsxAsTemplate(bytes);
    return (text: text, questions: questions);
  }

  /// Process docx: extract text + try parse template. Dùng với compute().
  static DocxParseResult processDocx(Uint8List bytes) {
    final text = extractFromDocx(bytes);
    final questions = text.isNotEmpty ? parseDocxAsTemplate(text) : null;
    return (text: text, questions: questions);
  }

  // ── Extraction ────────────────────────────────────────────────────────────

  static String extractFromXlsx(Uint8List bytes) {
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

  static String extractFromDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentFile = archive.findFile('word/document.xml');
    if (documentFile == null) return '';
    final xmlContent = utf8.decode(documentFile.content as List<int>);
    return xmlContent
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ── Template parsers ──────────────────────────────────────────────────────

  /// Parse xlsx theo format mẫu. Trả về null nếu không phải template.
  static List<Map<String, dynamic>>? parseXlsxAsTemplate(Uint8List bytes) {
    try {
      final excel = ex.Excel.decodeBytes(bytes);
      final tableNames = excel.tables.keys.toSet();

      final hasTemplate = tableNames.contains('Trắc nghiệm') ||
          tableNames.contains('Tự luận') ||
          tableNames.contains('Đúng/Sai');
      if (!hasTemplate) return null;

      final questions = <Map<String, dynamic>>[];

      // ── Trắc nghiệm ────────────────────────────────────────────────────────
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

      // ── Tự luận ────────────────────────────────────────────────────────────
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

      // ── Đúng/Sai ───────────────────────────────────────────────────────────
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
      return questions;
    } catch (_) {
      return null;
    }
  }

  /// Parse flat text (từ docx/pdf) thành câu hỏi. Trả về null nếu không có cấu trúc.
  ///
  /// BUG-FIX: normalize trước để handle cả docx (đã flat) và pdf (có newline).
  static List<Map<String, dynamic>>? parseDocxAsTemplate(String text) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final markerRe = RegExp(r'Câu\s+\d+\s*[:.)]', caseSensitive: false);
    final markers = markerRe.allMatches(flat).toList();
    if (markers.isEmpty) return null;

    final questions = <Map<String, dynamic>>[];
    for (int i = 0; i < markers.length; i++) {
      final blockStart = markers[i].end;
      final blockEnd = i + 1 < markers.length ? markers[i + 1].start : flat.length;
      final block = flat.substring(blockStart, blockEnd).trim();
      if (block.isEmpty) continue;
      final q = parseQuestionBlock(block);
      if (q != null) questions.add(q);
    }

    if (questions.isEmpty) return null;
    return questions;
  }

  /// Parse một block câu hỏi từ flat text.
  ///
  /// BUG-FIX A2-BUG3: dùng negative lookbehind thay vì `\s+` để detect option A
  /// ngay cả khi nó xuất hiện ngay sau dấu câu (e.g. "?A.") hoặc ở đầu block.
  @visibleForTesting
  static Map<String, dynamic>? parseQuestionBlock(String block) {
    // Negative lookbehind: option letter không được đứng sau chữ cái (ASCII hoặc Vietnamese).
    // Handles: " A. text", "?A. text", "A. text" at block start.
    final optRe = RegExp(
      r'(?<![a-zA-ZÀ-ỹ])([A-D])[.)]\s+',
      unicode: true,
    );
    final allOpts = optRe.allMatches(block).toList();

    // Thu thập options đúng thứ tự A→B→C→D
    final ordered = <RegExpMatch>[];
    const seq = ['A', 'B', 'C', 'D'];
    for (final m in allOpts) {
      final letter = m.group(1)!.toUpperCase();
      if (ordered.isEmpty && letter == 'A') {
        ordered.add(m);
      } else if (ordered.isNotEmpty && ordered.length < 4 && letter == seq[ordered.length]) {
        ordered.add(m);
      }
    }

    final answerRe = RegExp(r'Đáp án\s*[:.]\s*([A-D])', caseSensitive: false);

    // ── MCQ ────────────────────────────────────────────────────────────────
    if (ordered.length >= 2) {
      final qText = block.substring(0, ordered.first.start).trim();
      if (qText.isEmpty) return null;

      final optTexts = <String>[];
      for (int i = 0; i < ordered.length; i++) {
        final start = ordered[i].end;
        final end = i + 1 < ordered.length ? ordered[i + 1].start : block.length;
        var raw = block.substring(start, end).trim();
        raw = raw.replaceAll(RegExp(r'\s*Đáp án\s*[:.]\s*[A-D].*', caseSensitive: false), '').trim();
        optTexts.add(raw);
      }
      while (optTexts.length < 4) optTexts.add('');

      final answerMatch = answerRe.firstMatch(block);
      final correctLetter = answerMatch?.group(1)?.toUpperCase() ?? 'A';
      final correctIndex = const {'A': 0, 'B': 1, 'C': 2, 'D': 3}[correctLetter] ?? 0;

      return {
        'type': QuestionType.multipleChoice,
        'text': qText,
        'content': {'text': qText, 'images': <dynamic>[]},
        'choices': List.generate(4, (i) => {
          'id': i,
          'content': {'text': optTexts[i]},
          'is_correct': i == correctIndex,
        }),
        'options': List.generate(4, (i) => {
          'text': optTexts[i],
          'isCorrect': i == correctIndex,
        }),
        'answer': {'correct_choice_ids': [correctIndex]},
        'difficulty': 3,
        'tags': <String>[],
      };
    }

    // ── Đúng/Sai ───────────────────────────────────────────────────────────
    final tfAnsRe = RegExp(r'Đáp án\s*[:.]\s*(Đúng|Sai)', caseSensitive: false);
    final tfAns = tfAnsRe.firstMatch(block);
    if (tfAns != null) {
      final qText = block.substring(0, tfAns.start).trim();
      final isTrue = tfAns.group(1)!.toLowerCase() == 'đúng';

      return {
        'type': QuestionType.trueFalse,
        'text': qText.isNotEmpty ? qText : block.trim(),
        'content': {'text': qText.isNotEmpty ? qText : block.trim(), 'images': <dynamic>[]},
        'choices': [
          {'id': 0, 'content': {'text': 'Đúng'}, 'is_correct': isTrue},
          {'id': 1, 'content': {'text': 'Sai'}, 'is_correct': !isTrue},
        ],
        'options': [
          {'text': 'Đúng', 'isCorrect': isTrue},
          {'text': 'Sai', 'isCorrect': !isTrue},
        ],
        'answer': {'correct_choice_ids': [isTrue ? 0 : 1]},
        'difficulty': 3,
        'tags': <String>[],
      };
    }

    // ── Tự luận / Trả lời ngắn ─────────────────────────────────────────────
    final saAnsRe = RegExp(r'\s*Đáp án\s*[:.]\s*(.*)', caseSensitive: false, dotAll: true);
    final saAns = saAnsRe.firstMatch(block);
    final qText = saAns != null ? block.substring(0, saAns.start).trim() : block.trim();
    final expectedAnswer = saAns?.group(1)?.trim() ?? '';

    if (qText.isEmpty) return null;
    return {
      'type': QuestionType.shortAnswer,
      'text': qText,
      'content': {'text': qText, 'images': <dynamic>[]},
      'answer': expectedAnswer.isNotEmpty ? {'expected_answer': expectedAnswer} : <String, dynamic>{},
      'difficulty': 3,
      'tags': <String>[],
    };
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _cellStr(List<ex.Data?> row, int col) {
    if (col >= row.length) return '';
    return row[col]?.value?.toString().trim() ?? '';
  }

  static int? _cellInt(List<ex.Data?> row, int col) {
    if (col >= row.length) return null;
    final v = row[col]?.value;
    if (v == null) return null;
    if (v is ex.IntCellValue) return v.value;
    if (v is ex.DoubleCellValue) return v.value.toInt();
    return int.tryParse(v.toString());
  }

  static List<String> _parseTags(String raw) {
    if (raw.isEmpty) return [];
    return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }
}

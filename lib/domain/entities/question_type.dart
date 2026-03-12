import 'package:flutter/material.dart';

/// Loại câu hỏi
enum QuestionType {
  // Trắc nghiệm
  multipleChoice('Trắc nghiệm', Colors.blue, 'multiple_choice'),
  trueFalse('Đúng/Sai', Colors.cyan, 'true_false'),
  // Tự luận
  shortAnswer('Trả lời ngắn', Colors.green, 'short_answer'),
  essay('Tự luận', Colors.purple, 'essay'),
  // Đặc biệt
  fillBlank('Điền khuyết', Colors.teal, 'fill_blank'),
  matching('Nối khớp', Colors.indigo, 'matching'),
  // File/Problem
  math('Bài toán', Colors.orange, 'math'),
  problemSolving('Giải toán/Giải bài', Colors.deepOrange, 'problem_solving'),
  fileUpload('Tải file', Colors.brown, 'file_upload');

  final String label;
  final Color color;
  final String dbValue;
  const QuestionType(this.label, this.color, this.dbValue);
}

/// Helper class để convert từ DB string sang QuestionType
class QuestionTypeDb {
  static QuestionType fromDb(String? dbValue) {
    if (dbValue == null) return QuestionType.multipleChoice;

    switch (dbValue) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'essay':
        return QuestionType.essay;
      case 'fill_blank':
        return QuestionType.fillBlank;
      case 'matching':
        return QuestionType.matching;
      case 'math':
        return QuestionType.math;
      case 'problem_solving':
        return QuestionType.problemSolving;
      case 'file_upload':
        return QuestionType.fileUpload;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

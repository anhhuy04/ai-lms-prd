import 'package:flutter/material.dart';

/// Loại câu hỏi
enum QuestionType {
  multipleChoice('Trắc nghiệm', Colors.blue, 'multiple_choice'),
  shortAnswer('Trả lời ngắn', Colors.green, 'short_answer'),
  essay('Tự luận', Colors.purple, 'essay'),
  math('Bài toán', Colors.orange, 'math');

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
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'essay':
        return QuestionType.essay;
      case 'math':
        return QuestionType.math;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

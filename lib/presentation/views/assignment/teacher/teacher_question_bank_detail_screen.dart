import 'package:flutter/material.dart';

/// Placeholder for Question Bank detail screen.
///
/// Real implementation comes in Task 5.7 of the Question Bank phase.
class TeacherQuestionBankDetailScreen extends StatelessWidget {
  final String questionId;
  const TeacherQuestionBankDetailScreen({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Detail: $questionId — coming in Task 5.7'),
      ),
    );
  }
}

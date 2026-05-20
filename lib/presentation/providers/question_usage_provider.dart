import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'question_usage_provider.g.dart';

/// Usage item — bài tập đang dùng question này.
class QuestionUsageItem {
  final String assignmentId;
  final String title;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final String? className;

  const QuestionUsageItem({
    required this.assignmentId,
    required this.title,
    required this.isPublished,
    this.publishedAt,
    this.createdAt,
    this.className,
  });

  /// Parse từ row `assignment_questions` với nested `assignments(...)` select.
  /// Tolerant: nested `assignments` có thể là Map hoặc List (tuỳ Supabase client).
  factory QuestionUsageItem.fromJson(Map<String, dynamic> json) {
    final rawAssignment = json['assignments'];
    Map<String, dynamic>? assignment;
    if (rawAssignment is Map<String, dynamic>) {
      assignment = rawAssignment;
    } else if (rawAssignment is List && rawAssignment.isNotEmpty) {
      final first = rawAssignment.first;
      if (first is Map<String, dynamic>) assignment = first;
    }
    if (assignment == null) {
      return const QuestionUsageItem(
        assignmentId: '',
        title: '(unknown)',
        isPublished: false,
      );
    }

    // classes nested: cũng tolerant Map / List
    final rawClasses = assignment['classes'];
    Map<String, dynamic>? classes;
    if (rawClasses is Map<String, dynamic>) {
      classes = rawClasses;
    } else if (rawClasses is List && rawClasses.isNotEmpty) {
      final first = rawClasses.first;
      if (first is Map<String, dynamic>) classes = first;
    }

    return QuestionUsageItem(
      assignmentId: assignment['id'] as String? ?? '',
      title: assignment['title'] as String? ?? '(không tên)',
      isPublished: assignment['is_published'] as bool? ?? false,
      publishedAt: assignment['published_at'] == null
          ? null
          : DateTime.tryParse(assignment['published_at'] as String),
      createdAt: assignment['created_at'] == null
          ? null
          : DateTime.tryParse(assignment['created_at'] as String),
      className: classes?['name'] as String?,
    );
  }
}

/// Family provider — lấy danh sách assignments đang dùng question này.
@riverpod
Future<List<QuestionUsageItem>> questionUsage(
  Ref ref,
  String questionId,
) async {
  final client = Supabase.instance.client;
  final res = await client
      .from('assignment_questions')
      .select('''
        assignments!inner (
          id, title, is_published, published_at, created_at,
          classes ( id, name )
        )
      ''')
      .eq('question_id', questionId);

  return (res as List)
      .map((row) => QuestionUsageItem.fromJson(row as Map<String, dynamic>))
      .toList();
}

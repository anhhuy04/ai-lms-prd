import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho bảng `learning_objectives`.
class LearningObjectiveDataSource {
  final BaseTableDataSource _objectives;

  LearningObjectiveDataSource(SupabaseClient client)
      : _objectives = BaseTableDataSource(client, 'learning_objectives');

  Future<List<Map<String, dynamic>>> getObjectives({String? subjectCode}) async {
    if (subjectCode == null) {
      return _objectives.getAll(orderBy: 'subject_code', ascending: true);
    }
    return _objectives.getAll(
      column: 'subject_code',
      value: subjectCode,
      orderBy: 'code',
      ascending: true,
    );
  }

  Future<Map<String, dynamic>> insertObjective(Map<String, dynamic> payload) =>
      _objectives.insert(payload);
}


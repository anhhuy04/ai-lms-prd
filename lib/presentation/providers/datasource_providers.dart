import 'package:ai_mls/data/datasources/grade_override_datasource.dart';
import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/data/datasources/teacher_notes_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_providers.g.dart';

@riverpod
class SubmissionDataSourceProvider extends _$SubmissionDataSourceProvider {
  @override
  SubmissionDataSource build() => SubmissionDataSource();
}

@riverpod
class GradeOverrideDataSourceProvider extends _$GradeOverrideDataSourceProvider {
  @override
  GradeOverrideDataSource build() => GradeOverrideDataSource();
}

@riverpod
class TeacherNotesDataSourceProvider extends _$TeacherNotesDataSourceProvider {
  @override
  TeacherNotesDataSource build() => TeacherNotesDataSource();
}

enum QuestionSource {
  teacher,
  aiGenerated,
  library,
  imported,
  system,
  admin;

  String get dbValue => switch (this) {
        QuestionSource.teacher => 'teacher',
        QuestionSource.aiGenerated => 'ai_generated',
        QuestionSource.library => 'library',
        QuestionSource.imported => 'imported',
        QuestionSource.system => 'system',
        QuestionSource.admin => 'admin',
      };

  static QuestionSource fromDb(String value) => values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => QuestionSource.teacher,
      );
}

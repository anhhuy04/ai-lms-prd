/// Parameters để cập nhật lớp học.
class UpdateClassParams {
  final String? name;
  final String? subject;
  final String? academicYear;
  final String? description;
  final Map<String, dynamic>? classSettings;

  UpdateClassParams({
    this.name,
    this.subject,
    this.academicYear,
    this.description,
    this.classSettings,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (subject != null) json['subject'] = subject;
    if (academicYear != null) json['academic_year'] = academicYear;
    if (description != null) json['description'] = description;
    if (classSettings != null) json['class_settings'] = classSettings;
    return json;
  }

  bool get isEmpty => toJson().isEmpty;
}

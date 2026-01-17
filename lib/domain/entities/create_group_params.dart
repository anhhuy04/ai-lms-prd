/// Parameters để tạo nhóm học tập mới.
class CreateGroupParams {
  final String classId;
  final String name;
  final String? description;

  CreateGroupParams({
    required this.classId,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'name': name,
      'description': description,
    };
  }
}

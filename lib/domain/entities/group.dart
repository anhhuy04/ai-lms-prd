/// Entity đại diện cho nhóm học tập trong lớp học.
class Group {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validate dữ liệu của Group.
  /// Ném ra Exception nếu dữ liệu không hợp lệ.
  void validate() {
    if (id.trim().isEmpty) {
      throw Exception('ID nhóm không hợp lệ');
    }
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (name.trim().isEmpty) {
      throw Exception('Tên nhóm không được để trống');
    }
  }

  @override
  String toString() {
    return 'Group(\n'
        '  id: $id,\n'
        '  classId: $classId,\n'
        '  name: $name,\n'
        '  description: $description,\n'
        '  createdAt: ${createdAt.toIso8601String()},\n'
        ')';
  }
}

/// Entity đại diện cho giáo viên lớp học (hỗ trợ đồng giảng dạy).
class ClassTeacher {
  final String id;
  final String classId;
  final String teacherId;
  final String role;

  ClassTeacher({
    required this.id,
    required this.classId,
    required this.teacherId,
    this.role = 'teacher',
  });

  factory ClassTeacher.fromJson(Map<String, dynamic> json) {
    return ClassTeacher(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      teacherId: json['teacher_id'] as String,
      role: json['role'] as String? ?? 'teacher',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'role': role,
    };
  }

  /// Validate dữ liệu của ClassTeacher.
  /// Ném ra Exception nếu dữ liệu không hợp lệ.
  void validate() {
    if (id.trim().isEmpty) {
      throw Exception('ID không hợp lệ');
    }
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (teacherId.trim().isEmpty) {
      throw Exception('ID giáo viên không hợp lệ');
    }
    if (role.trim().isEmpty) {
      throw Exception('Vai trò không được để trống');
    }
  }

  @override
  String toString() {
    return 'ClassTeacher(\n'
        '  id: $id,\n'
        '  classId: $classId,\n'
        '  teacherId: $teacherId,\n'
        '  role: $role,\n'
        ')';
  }
}

/// Entity đại diện cho thành viên lớp học (học sinh trong lớp).
class ClassMember {
  final String classId;
  final String studentId;
  final String status; // 'pending', 'approved', 'rejected'
  final String? role;
  final DateTime? joinedAt;
  final DateTime? createdAt;

  ClassMember({
    required this.classId,
    required this.studentId,
    required this.status,
    this.role,
    this.joinedAt,
    this.createdAt,
  });

  factory ClassMember.fromJson(Map<String, dynamic> json) {
    return ClassMember(
      classId: json['class_id'] as String,
      studentId: json['student_id'] as String,
      status: json['status'] as String? ?? 'pending',
      role: json['role'] as String?,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'student_id': studentId,
      'status': status,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Validate dữ liệu của ClassMember.
  /// Ném ra Exception nếu dữ liệu không hợp lệ.
  void validate() {
    if (classId.trim().isEmpty) {
      throw Exception('ID lớp học không hợp lệ');
    }
    if (studentId.trim().isEmpty) {
      throw Exception('ID học sinh không hợp lệ');
    }
    if (!['pending', 'approved', 'rejected'].contains(status)) {
      throw Exception(
        'Trạng thái không hợp lệ. Phải là: pending, approved, hoặc rejected',
      );
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  String toString() {
    return 'ClassMember(\n'
        '  classId: $classId,\n'
        '  studentId: $studentId,\n'
        '  status: $status,\n'
        '  role: $role,\n'
        '  joinedAt: ${joinedAt?.toIso8601String()},\n'
        '  createdAt: ${createdAt?.toIso8601String()},\n'
        ')';
  }
}

/// Entity đại diện cho thành viên nhóm học tập.
class GroupMember {
  final String groupId;
  final String studentId;
  final DateTime? joinedAt;

  GroupMember({
    required this.groupId,
    required this.studentId,
    this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      groupId: json['group_id'] as String,
      studentId: json['student_id'] as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'student_id': studentId,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  /// Validate dữ liệu của GroupMember.
  /// Ném ra Exception nếu dữ liệu không hợp lệ.
  void validate() {
    if (groupId.trim().isEmpty) {
      throw Exception('ID nhóm không hợp lệ');
    }
    if (studentId.trim().isEmpty) {
      throw Exception('ID học sinh không hợp lệ');
    }
  }

  @override
  String toString() {
    return 'GroupMember(\n'
        '  groupId: $groupId,\n'
        '  studentId: $studentId,\n'
        '  joinedAt: ${joinedAt?.toIso8601String()},\n'
        ')';
  }
}

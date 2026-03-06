import 'package:ai_mls/domain/entities/recipient_tree_node.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để lấy class hierarchy cho màn hình phân phối bài tập
/// Tối ưu: Gọi song song tất cả API để giảm thời gian load
final classHierarchyForDistributeProvider = FutureProvider<List<ClassNode>>((ref) async {
  final repository = ref.watch(schoolClassRepositoryProvider);

  // Đợi currentUserProvider load xong trước
  final currentUserAsync = ref.watch(currentUserProvider);
  final teacherId = currentUserAsync.valueOrNull?.id;

  if (teacherId == null) {
    // Thử đợi một chút nếu user đang load
    await Future.delayed(const Duration(milliseconds: 500));
    final retryUser = ref.read(currentUserProvider).valueOrNull?.id;
    if (retryUser == null) {
      return [];
    }
  }

  final effectiveTeacherId = teacherId ?? ref.read(currentUserProvider).valueOrNull?.id;
  if (effectiveTeacherId == null) {
    return [];
  }

  try {
    // Bước 1: Lấy tất cả lớp của giáo viên
    final classes = await repository.getClassesByTeacher(effectiveTeacherId);

    if (classes.isEmpty) {
      return [];
    }

    // Bước 2: Gọi song song tất cả API cho TẤT CẢ các lớp
    // Thay vì gọi tuần tự từng lớp, ta gọi tất cả cùng lúc

    // Tạo danh sách futures cần gọi
    final memberFutures = classes.map((c) =>
      repository.getClassMembers(c.id, status: 'approved')
    ).toList();

    final groupFutures = classes.map((c) =>
      repository.getGroupsByClass(c.id)
    ).toList();

    // Gọi song song - TẤT CẢ các lớp cùng lúc
    final allMembersResults = await Future.wait(memberFutures);
    final allGroupsResults = await Future.wait(groupFutures);

    // Bước 3: Với mỗi lớp, gọi song song các group members
    final classNodes = <ClassNode>[];

    for (int i = 0; i < classes.length; i++) {
      final classEntity = classes[i];
      final members = allMembersResults[i];
      final groups = allGroupsResults[i];

      // Gọi song song tất cả group members cho lớp này
      final groupMemberFutures = groups.map((g) =>
        repository.getGroupMembers(g.id)
      ).toList();

      final allGroupMembers = groupMemberFutures.isEmpty
          ? <List<dynamic>>[]
          : await Future.wait(groupMemberFutures);

      // Xử lý dữ liệu
      final groupNodes = <GroupNode>[];
      final independentStudentIds = <String>{};

      for (int j = 0; j < groups.length; j++) {
        final group = groups[j];
        final groupMembers = allGroupMembers[j];

        final studentNodes = groupMembers.map((gm) => StudentNode(
          id: gm.studentId,
          name: 'HS ${gm.studentId.substring(0, 8)}',
        )).toList();

        groupNodes.add(GroupNode(
          id: group.id,
          name: group.name,
          students: studentNodes,
        ));

        independentStudentIds.addAll(groupMembers.map((gm) => gm.studentId));
      }

      // Lấy independent students (không thuộc nhóm nào)
      final independentStudents = members
          .where((m) => !independentStudentIds.contains(m.studentId))
          .map((m) => StudentNode(
                id: m.studentId,
                name: 'HS ${m.studentId.substring(0, 8)}',
              ))
          .toList();

      classNodes.add(ClassNode(
        id: classEntity.id,
        name: classEntity.name,
        totalStudents: members.length,
        groups: groupNodes,
        independentStudents: independentStudents,
      ));
    }

    return classNodes;
  } catch (e) {
    return [];
  }
});

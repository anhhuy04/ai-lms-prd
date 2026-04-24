import 'package:ai_mls/domain/entities/create_group_params.dart';
import 'package:ai_mls/domain/entities/group.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'class_providers.dart';

part 'group_providers.g.dart';

// ══════════════════════════════════════════════════════════════════════════
// Read-only providers
// ══════════════════════════════════════════════════════════════════════════

@riverpod
Future<List<Group>> groupsByClass(Ref ref, String classId) async {
  final repo = ref.watch(schoolClassRepositoryProvider);
  return repo.getGroupsByClass(classId);
}

/// Trả về Map[String, dynamic] chứa full_name, avatar_url kèm group_member fields
@riverpod
Future<List<Map<String, dynamic>>> groupMembersWithProfiles(
  Ref ref,
  String groupId,
) async {
  final repo = ref.watch(schoolClassRepositoryProvider);
  return repo.getGroupMembersWithProfiles(groupId);
}

/// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm
@riverpod
Future<List<Map<String, dynamic>>> classStudentsWithProfiles(
  Ref ref,
  String classId,
) async {
  final repo = ref.watch(schoolClassRepositoryProvider);
  return repo.getClassMembersWithProfiles(classId, status: 'approved');
}

/// Số thành viên của nhiều nhóm trong 1 lớp (batch, tránh N+1)
@riverpod
Future<Map<String, int>> groupMemberCounts(Ref ref, String classId) async {
  final repo = ref.watch(schoolClassRepositoryProvider);
  // Tái dụng cache từ groupsByClassProvider thay vì gọi DB lần 2
  final groups = await ref.watch(groupsByClassProvider(classId).future);
  return repo.getGroupMemberCounts(groups.map((g) => g.id).toList());
}

/// Bài tập đã giao cho nhóm kèm tiến độ nộp bài của thành viên
@riverpod
Future<List<Map<String, dynamic>>> groupAssignmentProgress(
  Ref ref,
  String groupId,
) async {
  final repo = ref.watch(schoolClassRepositoryProvider);
  return repo.getGroupAssignmentProgress(groupId);
}

// ══════════════════════════════════════════════════════════════════════════
// Notifier — mutations
// ══════════════════════════════════════════════════════════════════════════

@riverpod
class GroupNotifier extends _$GroupNotifier {
  SchoolClassRepository get _repo => ref.read(schoolClassRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Group?> createGroup(CreateGroupParams params) async {
    state = const AsyncLoading();
    try {
      final group = await _repo.createGroup(params);
      state = const AsyncData(null);
      ref.invalidate(groupsByClassProvider(params.classId));
      return group;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> deleteGroup(String groupId, String classId) async {
    state = const AsyncLoading();
    try {
      await _repo.deleteGroup(groupId);
      state = const AsyncData(null);
      ref.invalidate(groupsByClassProvider(classId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addMember(String groupId, String studentId, {required String classId}) async {
    state = const AsyncLoading();
    try {
      await _repo.addStudentToGroup(groupId, studentId);
      state = const AsyncData(null);
      ref.invalidate(groupMembersWithProfilesProvider(groupId));
      ref.invalidate(groupMemberCountsProvider(classId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> removeMember(String groupId, String studentId, {required String classId}) async {
    state = const AsyncLoading();
    try {
      await _repo.removeStudentFromGroup(groupId, studentId);
      state = const AsyncData(null);
      ref.invalidate(groupMembersWithProfilesProvider(groupId));
      ref.invalidate(groupMemberCountsProvider(classId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> setLeader(String groupId, String studentId, bool isLeader) async {
    state = const AsyncLoading();
    try {
      if (isLeader) {
        // Dùng DB function để unset leader cũ + set leader mới (atomic)
        await _repo.setGroupLeaderAtomic(groupId, studentId);
      } else {
        await _repo.setGroupMemberRole(groupId, studentId, 'member');
      }
      state = const AsyncData(null);
      ref.invalidate(groupMembersWithProfilesProvider(groupId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> autoAssignGroups({
    required String classId,
    required int numGroups,
    required String groupPrefix,
  }) async {
    if (numGroups <= 0) {
      state = AsyncError(
        ArgumentError('numGroups phải lớn hơn 0, nhận được: $numGroups'),
        StackTrace.current,
      );
      return false;
    }
    state = const AsyncLoading();
    try {
      await _repo.autoAssignStudentsToGroups(
        classId: classId,
        numGroups: numGroups,
        groupPrefix: groupPrefix,
      );
      state = const AsyncData(null);
      ref.invalidate(groupsByClassProvider(classId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

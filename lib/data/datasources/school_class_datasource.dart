import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho các bảng liên quan đến lớp học.
/// Sử dụng BaseTableDataSource cho CRUD cơ bản và thêm methods đặc biệt cho queries phức tạp.
class SchoolClassDataSource {
  final BaseTableDataSource _classesDataSource;
  final BaseTableDataSource _classMembersDataSource;
  final BaseTableDataSource _groupsDataSource;
  final BaseTableDataSource _groupMembersDataSource;
  final SupabaseClient _client;

  SchoolClassDataSource()
    : _client = Supabase.instance.client,
      _classesDataSource = BaseTableDataSource(
        Supabase.instance.client,
        'classes',
      ),
      _classMembersDataSource = BaseTableDataSource(
        Supabase.instance.client,
        'class_members',
      ),
      _groupsDataSource = BaseTableDataSource(
        Supabase.instance.client,
        'groups',
      ),
      _groupMembersDataSource = BaseTableDataSource(
        Supabase.instance.client,
        'group_members',
      );

  // ==================== Helper Methods ====================

  /// Tạo OR filter cho nhiều giá trị cùng một cột
  /// Ví dụ: ['id1', 'id2'] -> 'id.eq.id1,id.eq.id2'
  String _buildOrFilter(String column, List<String> values) {
    return values.map((value) => '$column.eq.$value').join(',');
  }

  /// Áp dụng OR filter vào query
  dynamic _applyOrFilter(dynamic query, String column, List<String> values) {
    if (values.isEmpty) return query;
    final filterString = _buildOrFilter(column, values);
    return query.or(filterString) as dynamic;
  }

  // ==================== Class CRUD ====================

  /// Tạo lớp học mới
  Future<Map<String, dynamic>> createClass(
    Map<String, dynamic> classData,
  ) async {
    return await _classesDataSource.insert(classData);
  }

  /// Lấy danh sách lớp học của giáo viên
  Future<List<Map<String, dynamic>>> getClassesByTeacher(
    String teacherId,
  ) async {
    return await _classesDataSource.getAll(
      column: 'teacher_id',
      value: teacherId,
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Lấy danh sách lớp học của giáo viên với pagination, search và sort
  Future<List<Map<String, dynamic>>> getClassesByTeacherPaginated({
    required String teacherId,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      // Dùng dynamic ngay từ đầu để tránh type mismatch
      dynamic query = _client
          .from('classes')
          .select()
          .eq('teacher_id', teacherId);

      // Áp dụng search filter (tìm kiếm trên name và subject)
      // Lưu ý: Phải apply search TRƯỚC sort vì .or() trả về PostgrestFilterBuilder
      // còn .order() trả về PostgrestTransformBuilder (không thể gọi filter methods)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchPattern = '%$searchQuery%';
        // Supabase PostgREST OR syntax: 'field1.ilike.pattern,field2.ilike.pattern'
        query = query.or(
          'name.ilike.$searchPattern,subject.ilike.$searchPattern',
        );
      }

      // Áp dụng sort (sau khi đã apply tất cả filters)
      if (sortBy != null) {
        query = query.order(sortBy, ascending: ascending);
      } else {
        // Default sort by created_at desc
        query = query.order('created_at', ascending: false);
      }

      // Áp dụng pagination
      final response = await query.range(from, to);
      final results = List<Map<String, dynamic>>.from(response);

      // Enrich dữ liệu: thêm student_count cho mỗi class
      if (results.isNotEmpty) {
        try {
          // Lấy danh sách class IDs
          final classIds = results
              .map((c) => c['id'])
              .where((id) => id is String && id.isNotEmpty)
              .cast<String>()
              .toList();

          if (classIds.isNotEmpty) {
            // Query class_members để đếm tổng số học sinh đã duyệt cho mỗi lớp
            Map<String, int> studentCountByClassId = {};

            var membersQuery = _client
                .from('class_members')
                .select('class_id')
                .eq('status', 'approved');

            // OR filter cho nhiều class_id
            membersQuery = _applyOrFilter(membersQuery, 'class_id', classIds);

            final membersResponse = await membersQuery;

            for (final m in membersResponse as List<dynamic>) {
              final map = m as Map<String, dynamic>;
              final id = map['class_id'] as String?;
              if (id == null) continue;
              studentCountByClassId[id] = (studentCountByClassId[id] ?? 0) + 1;
            }

            // Merge student_count vào từng class
            for (final classData in results) {
              final classId = classData['id'] as String?;
              if (classId != null) {
                classData['student_count'] =
                    studentCountByClassId[classId] ?? 0;
              } else {
                classData['student_count'] = 0;
              }
            }
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            '🔴 [DATASOURCE ERROR] getClassesByTeacherPaginated: Lỗi khi đếm số học sinh: $e',
            error: e,
            stackTrace: stackTrace,
          );
          // Không throw để không block luồng chính, chỉ bỏ qua student_count
          // Set default student_count = 0 cho tất cả classes
          for (final classData in results) {
            classData['student_count'] = 0;
          }
        }
      }

      return results;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassesByTeacherPaginated: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy danh sách lớp học: $e');
    }
  }

  /// Lấy danh sách lớp học mà học sinh đã tham gia.
  ///
  /// [approvedOnly] = true:  chỉ lớp đã duyệt (dùng cho analytics filter)
  /// [approvedOnly] = false: tất cả lớp đã gửi yêu cầu, kể cả pending (dùng cho student class list)
  Future<List<Map<String, dynamic>>> getClassesByStudent(
    String studentId, {
    bool approvedOnly = true,
  }) async {
    try {
      // 1. Lấy class_members
      List<dynamic> members;
      if (approvedOnly) {
        members = await _client
            .from('class_members')
            .select('class_id')
            .eq('student_id', studentId)
            .eq('status', 'approved');
      } else {
        members = await _client
            .from('class_members')
            .select('class_id, status')
            .eq('student_id', studentId)
            .or('status.eq.approved,status.eq.pending');
      }

      if (members.isEmpty) return [];

      // 2. Lấy class IDs + status (nếu không approvedOnly)
      final Map<String, String> memberStatusByClassId = {};
      final classIds = <String>[];
      for (final m in members) {
        final map = m as Map<String, dynamic>;
        final classId = map['class_id'] as String?;
        if (classId == null) continue;
        if (!classIds.contains(classId)) {
          classIds.add(classId);
          if (!approvedOnly) {
            memberStatusByClassId[classId] = (map['status']?.toString() ?? 'approved');
          }
        }
      }

      if (classIds.isEmpty) return [];

      // 3. Lấy thông tin lớp
      var query = _client.from('classes').select();
      query = _applyOrFilter(query, 'id', classIds);
      final classes = List<Map<String, dynamic>>.from(
        (await (query as dynamic).order('created_at', ascending: false)) as List<dynamic>,
      );

      if (classes.isEmpty) return [];

      // 4. Enrich: teacher_name + student_count (+ member_status nếu cần)
      final teacherIds = classes
          .map((c) => c['teacher_id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      Map<String, String> teacherNameById = {};
      if (teacherIds.isNotEmpty) {
        try {
          var profilesQuery = _client.from('profiles').select('id, full_name');
          profilesQuery = _applyOrFilter(profilesQuery, 'id', teacherIds);
          for (final p in await profilesQuery as List<dynamic>) {
            final id = p['id'] as String?;
            final fullName = p['full_name'] as String?;
            if (id != null && fullName != null && fullName.isNotEmpty) {
              teacherNameById[id] = fullName;
            }
          }
        } catch (_) {}
      }

      // Dùng RPC SECURITY DEFINER để đếm sĩ số — học sinh không có quyền đọc
      // class_members của người khác (RLS: student_id = auth.uid()), nên không thể
      // query trực tiếp. RPC chỉ trả về count, không expose thông tin cá nhân.
      Map<String, int> studentCountByClassId = {};
      try {
        final countResult = await _client.rpc(
          'get_class_member_counts',
          params: {'p_class_ids': classIds},
        ) as List<dynamic>;
        for (final row in countResult) {
          final map = row as Map<String, dynamic>;
          final id = map['class_id'] as String?;
          final count = map['member_count'];
          if (id != null && count != null) {
            studentCountByClassId[id] = (count is int)
                ? count
                : int.tryParse(count.toString()) ?? 0;
          }
        }
      } catch (e) {
        AppLogger.error(
          '🔴 [DATASOURCE] getClassesByStudent: lỗi đếm sĩ số qua RPC: $e',
        );
      }

      // 5. Tính not_started / in_progress / completed theo "Invisible Footprint" pattern:
      //    - Bắt đầu từ assignment_distributions (nguồn sự thật)
      //    - Distributions không có work_session nào = "Chưa làm"
      //    - Không tạo dữ liệu giả trong work_sessions
      Map<String, int> totalAssignmentsByClassId = {};
      Map<String, int> completedAssignmentsByClassId = {};
      Map<String, int> inProgressAssignmentsByClassId = {};
      Map<String, int> notStartedAssignmentsByClassId = {};
      try {
        // Lấy distributions đang active cho các lớp này
        var distQuery = _client
            .from('assignment_distributions')
            .select('id, class_id')
            .eq('status', 'active');
        distQuery = _applyOrFilter(distQuery, 'class_id', classIds);
        final distributions = await distQuery as List<dynamic>;

        final Map<String, String> classIdByDistId = {};
        for (final d in distributions) {
          final distId = d['id'] as String?;
          final cId = d['class_id'] as String?;
          if (distId == null || cId == null) continue;
          classIdByDistId[distId] = cId;
          totalAssignmentsByClassId[cId] =
              (totalAssignmentsByClassId[cId] ?? 0) + 1;
        }

        if (classIdByDistId.isNotEmpty) {
          final distIds = classIdByDistId.keys.toList();

          // 1 query duy nhất: tất cả work_sessions của student cho các distributions này
          var wsAllQuery = _client
              .from('work_sessions')
              .select('assignment_distribution_id, status')
              .eq('student_id', studentId);
          wsAllQuery = _applyOrFilter(wsAllQuery, 'assignment_distribution_id', distIds);
          final allSessions = await wsAllQuery as List<dynamic>;

          // Set các dist_id đã có work_session (bất kỳ status nào)
          final sessionedDistIds = <String>{};

          for (final ws in allSessions) {
            final distId = ws['assignment_distribution_id'] as String?;
            final wsStatus = ws['status'] as String?;
            if (distId == null) continue;
            sessionedDistIds.add(distId);

            final cId = classIdByDistId[distId];
            if (cId == null) continue;

            if (wsStatus == 'in_progress') {
              inProgressAssignmentsByClassId[cId] =
                  (inProgressAssignmentsByClassId[cId] ?? 0) + 1;
            } else if (wsStatus == 'submitted' ||
                wsStatus == 'graded' ||
                wsStatus == 'ai_processing' ||
                wsStatus == 'pending_review') {
              completedAssignmentsByClassId[cId] =
                  (completedAssignmentsByClassId[cId] ?? 0) + 1;
            }
          }

          // "Invisible Footprint": distributions không có bất kỳ work_session nào = chưa làm
          for (final entry in classIdByDistId.entries) {
            final distId = entry.key;
            final cId = entry.value;
            if (!sessionedDistIds.contains(distId)) {
              notStartedAssignmentsByClassId[cId] =
                  (notStartedAssignmentsByClassId[cId] ?? 0) + 1;
            }
          }
        }
      } catch (_) {}

      return classes.map((c) {
        final classId = c['id'] as String?;
        final teacherId = c['teacher_id'] as String?;
        final total =
            classId != null ? (totalAssignmentsByClassId[classId] ?? 0) : 0;
        final completed =
            classId != null ? (completedAssignmentsByClassId[classId] ?? 0) : 0;
        final inProgress =
            classId != null ? (inProgressAssignmentsByClassId[classId] ?? 0) : 0;
        final notStarted =
            classId != null ? (notStartedAssignmentsByClassId[classId] ?? 0) : 0;
        final result = <String, dynamic>{
          ...c,
          'teacher_name': teacherId != null ? teacherNameById[teacherId] : null,
          'student_count':
              classId != null ? (studentCountByClassId[classId] ?? 0) : 0,
          'total_assignment_count': total,
          'pending_assignment_count': (total - completed).clamp(0, total),
          'in_progress_assignment_count': inProgress,
          'not_started_assignment_count': notStarted,
        };
        if (!approvedOnly) {
          result['member_status'] =
              classId != null ? memberStatusByClassId[classId] : null;
        }
        return result;
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassesByStudent(studentId: $studentId, approvedOnly: $approvedOnly): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy danh sách lớp học của học sinh: $e');
    }
  }

  /// Lấy thông tin lớp học theo ID
  Future<Map<String, dynamic>?> getClassById(String classId) async {
    final classData = await _classesDataSource.getById(classId);
    if (classData == null) return null;

    try {
      final countResponse = await _client
          .from('class_members')
          .select('class_id')
          .eq('class_id', classId)
          .eq('status', 'approved');

      classData['student_count'] = (countResponse as List).length;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassById: Lỗi khi đếm số học sinh: $e',
        error: e,
        stackTrace: stackTrace,
      );
      classData['student_count'] = 0;
    }
    return classData;
  }

  /// Cập nhật lớp học
  Future<Map<String, dynamic>> updateClass(
    String classId,
    Map<String, dynamic> updateData,
  ) async {
    return await _classesDataSource.update(classId, updateData);
  }

  /// Xóa lớp học
  Future<void> deleteClass(String classId) async {
    return await _classesDataSource.delete(classId);
  }

  // ==================== Class Members ====================

  /// Tạo yêu cầu tham gia lớp học
  Future<Map<String, dynamic>> createClassMember(
    Map<String, dynamic> memberData,
  ) async {
    return await _classMembersDataSource.insert(memberData);
  }

  /// Lấy danh sách thành viên lớp học
  Future<List<Map<String, dynamic>>> getClassMembers(
    String classId, {
    String? status,
  }) async {
    try {
      var query = _client
          .from('class_members')
          .select()
          .eq('class_id', classId);

      if (status != null) {
        query = query.eq('status', status) as dynamic;
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassMembers(classId: $classId, status: $status): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy danh sách thành viên lớp học: $e');
    }
  }

  /// Tìm lớp học theo join_code trong class_settings.enrollment.qr_code.join_code.
  /// Đồng thời kiểm tra một số rule cơ bản: is_active, expires_at, manual_join_limit.
  Future<Map<String, dynamic>?> getClassByJoinCode(String joinCode) async {
    try {
      // Query tất cả classes để kiểm tra join_code trong class_settings
      final results = await _client
          .from('classes')
          .select('id, class_settings, *');

      for (final classData in results) {
        final classSettings =
            classData['class_settings'] as Map<String, dynamic>?;
        if (classSettings == null) continue;

        final enrollment = classSettings['enrollment'] as Map<String, dynamic>?;
        if (enrollment == null) continue;

        final qrCode = enrollment['qr_code'] as Map<String, dynamic>?;
        if (qrCode == null) continue;

        final existingCode = qrCode['join_code'] as String?;
        if (existingCode == null || existingCode != joinCode) {
          continue;
        }

        final classId = classData['id'] as String?;
        if (classId == null) continue;

        // Kiểm tra trạng thái kích hoạt mã
        final isActive = qrCode['is_active'] as bool? ?? false;
        if (!isActive) {
          throw Exception(
            'Mã lớp hiện đã được tắt, vui lòng liên hệ giáo viên.',
          );
        }

        // Kiểm tra thời hạn mã
        final expiresAtRaw = qrCode['expires_at'];
        if (expiresAtRaw != null) {
          try {
            final expiresAt = DateTime.parse(expiresAtRaw.toString());
            if (expiresAt.isBefore(DateTime.now().toUtc())) {
              throw Exception(
                'Mã lớp đã hết hạn, vui lòng yêu cầu giáo viên tạo mã mới.',
              );
            }
          } catch (_) {
            // Nếu parse lỗi thì bỏ qua check expires_at để không block user.
          }
        }

        // Kiểm tra giới hạn số lượng tham gia thủ công (nếu có)
        final manualJoinLimit = enrollment['manual_join_limit'] as int?;
        if (manualJoinLimit != null) {
          final members = await getClassMembers(classId);
          if (members.length >= manualJoinLimit) {
            throw Exception(
              'Lớp đã đạt giới hạn số lượng tham gia, không thể tham gia thêm.',
            );
          }
        }

        // Nếu qua được tất cả điều kiện, trả về classData hiện tại
        return Map<String, dynamic>.from(classData);
      }

      // Không tìm thấy lớp phù hợp với join_code
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassByJoinCode(joinCode: $joinCode): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi tìm lớp bằng mã tham gia: $e');
    }
  }

  /// Cập nhật trạng thái thành viên lớp học
  Future<Map<String, dynamic>> updateClassMemberStatus(
    String classId,
    String studentId,
    String status,
  ) async {
    try {
      final response = await _client
          .from('class_members')
          .update({'status': status})
          .eq('class_id', classId)
          .eq('student_id', studentId)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] updateClassMemberStatus(classId: $classId, studentId: $studentId, status: $status): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi cập nhật trạng thái thành viên: $e');
    }
  }

  /// Học sinh rời lớp học
  /// Xóa hoàn toàn record khỏi class_members
  Future<void> leaveClass(String classId, String studentId) async {
    try {
      await _client
          .from('class_members')
          .delete()
          .eq('class_id', classId)
          .eq('student_id', studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] leaveClass(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi rời lớp học: $e');
    }
  }

  // ==================== Groups ====================

  /// Tạo nhóm học tập mới
  Future<Map<String, dynamic>> createGroup(
    Map<String, dynamic> groupData,
  ) async {
    return await _groupsDataSource.insert(groupData);
  }

  /// Lấy danh sách nhóm học tập trong lớp
  Future<List<Map<String, dynamic>>> getGroupsByClass(String classId) async {
    return await _groupsDataSource.getAll(
      column: 'class_id',
      value: classId,
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Thêm học sinh vào nhóm
  Future<Map<String, dynamic>> addStudentToGroup(
    String groupId,
    String studentId,
  ) async {
    return await _groupMembersDataSource.insert({
      'group_id': groupId,
      'student_id': studentId,
    });
  }

  /// Xóa học sinh khỏi nhóm
  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    try {
      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('student_id', studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] removeStudentFromGroup(groupId: $groupId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi xóa học sinh khỏi nhóm: $e');
    }
  }

  /// Lấy danh sách thành viên nhóm
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    return await _groupMembersDataSource.getAll(
      column: 'group_id',
      value: groupId,
    );
  }

  /// Thành viên nhóm kèm profile (full_name, avatar_url)
  Future<List<Map<String, dynamic>>> getGroupMembersWithProfiles(
    String groupId,
  ) async {
    try {
      final response = await _client
          .from('group_members')
          .select('*, profiles!student_id(full_name, avatar_url)')
          .eq('group_id', groupId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getGroupMembersWithProfiles(groupId: $groupId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy thành viên nhóm kèm profile: $e');
    }
  }

  /// Thành viên lớp đã duyệt kèm profile — dùng trong sheet chọn thành viên nhóm.
  ///
  /// IMPORTANT: class_members.student_id FK references auth.users(id), NOT profiles.
  /// PostgREST embedded join `profiles!student_id` không hoạt động ở đây vì không có FK
  /// trực tiếp từ class_members → profiles. Thay vào đó dùng 2 queries riêng biệt.
  Future<List<Map<String, dynamic>>> getClassMembersWithProfiles(
    String classId, {
    String? status,
  }) async {
    try {
      // Step 1: lấy class_members
      var query = _client
          .from('class_members')
          .select()
          .eq('class_id', classId);
      if (status != null) {
        query = query.eq('status', status) as dynamic;
      }
      final members = List<Map<String, dynamic>>.from(await query);
      if (members.isEmpty) return [];

      // Step 2: lấy profiles theo student_id (profiles.id = auth.users.id)
      final studentIds = members
          .map((m) => m['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final profilesRes = await _client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', studentIds);
      final profileMap = <String, Map<String, dynamic>>{
        for (final p in List<Map<String, dynamic>>.from(profilesRes))
          (p['id'] as String): p,
      };

      // Step 3: merge profile vào mỗi member
      return members.map((m) {
        final sid = m['student_id'] as String?;
        return <String, dynamic>{
          ...m,
          'profiles': sid != null ? profileMap[sid] : null,
        };
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getClassMembersWithProfiles(classId: $classId, status: $status): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy thành viên lớp kèm profile: $e');
    }
  }

  /// Đếm số thành viên của nhiều nhóm cùng lúc (batch, tránh N+1)
  Future<Map<String, int>> getGroupMemberCounts(
    List<String> groupIds,
  ) async {
    if (groupIds.isEmpty) return {};
    try {
      final response = await _client
          .from('group_members')
          .select('group_id')
          .inFilter('group_id', groupIds);
      final counts = <String, int>{};
      for (final row in response) {
        final id = row['group_id'] as String?;
        if (id == null) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return counts;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getGroupMemberCounts: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi đếm thành viên nhóm: $e');
    }
  }

  /// Bài tập đã giao cho nhóm kèm tiến độ nộp bài
  Future<List<Map<String, dynamic>>> getGroupAssignmentProgress(
    String groupId,
  ) async {
    try {
      final response = await _client
          .from('assignment_distributions')
          .select('*, assignments(id, title, total_points)')
          .eq('group_id', groupId)
          .eq('distribution_type', 'group')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] getGroupAssignmentProgress(groupId: $groupId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi lấy tiến độ bài tập nhóm: $e');
    }
  }

  /// Xóa nhóm học tập
  Future<void> deleteGroup(String groupId) async {
    try {
      await _client.from('groups').delete().eq('id', groupId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] deleteGroup(groupId: $groupId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi xóa nhóm: $e');
    }
  }

  /// Set nhóm trưởng (2-step: unset leader cũ → set leader mới).
  ///
  /// WARNING: Đây KHÔNG thực sự atomic vì client Supabase không hỗ trợ transaction.
  /// Nếu step 1 thành công nhưng step 2 thất bại → mọi member trong nhóm sẽ bị
  /// giữ nguyên là 'member', không có leader. Để atomic thật sự, cần tạo DB function
  /// `set_group_leader(p_group_id uuid, p_student_id uuid)` với SECURITY DEFINER.
  Future<void> setGroupLeaderAtomic(String groupId, String studentId) async {
    try {
      // Step 1: reset tất cả về 'member'
      await _client
          .from('group_members')
          .update({'role': 'member'})
          .eq('group_id', groupId);
      // Step 2: set leader mới
      await _client
          .from('group_members')
          .update({'role': 'leader'})
          .eq('group_id', groupId)
          .eq('student_id', studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] setGroupLeaderAtomic(groupId: $groupId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi set nhóm trưởng: $e');
    }
  }

  /// Cập nhật vai trò thành viên nhóm
  Future<void> setGroupMemberRole(
    String groupId,
    String studentId,
    String role,
  ) async {
    try {
      await _client
          .from('group_members')
          .update({'role': role})
          .eq('group_id', groupId)
          .eq('student_id', studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] setGroupMemberRole(groupId: $groupId, studentId: $studentId, role: $role): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi cập nhật vai trò thành viên: $e');
    }
  }

  /// Tự động chia học sinh vào các nhóm mới (round-robin).
  ///
  /// WARNING: Không atomic — nếu thất bại giữa chừng (ví dụ sau khi tạo được 2/3 nhóm),
  /// các nhóm đã tạo sẽ tồn tại mà không có đầy đủ thành viên (partial state).
  /// Caller nên xử lý bằng cách hiển thị thông báo lỗi và cho phép retry hoặc xóa thủ công.
  Future<void> autoAssignStudentsToGroups({
    required String classId,
    required int numGroups,
    required String groupPrefix,
  }) async {
    try {
      // Lấy học sinh đã duyệt
      final members = await getClassMembers(classId, status: 'approved');
      if (members.isEmpty) return;

      // Tạo numGroups nhóm (sequential — không có bulk insert để giữ được id từng nhóm)
      final groupIds = <String>[];
      for (int i = 1; i <= numGroups; i++) {
        final result = await _client.from('groups').insert({
          'class_id': classId,
          'name': '$groupPrefix $i',
        }).select('id').single();
        groupIds.add(result['id'] as String);
      }

      // Phân chia học sinh round-robin
      for (int i = 0; i < members.length; i++) {
        final studentId = members[i]['student_id'] as String;
        final groupId = groupIds[i % numGroups];
        await _client.from('group_members').insert({
          'group_id': groupId,
          'student_id': studentId,
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] autoAssignStudentsToGroups(classId: $classId, numGroups: $numGroups): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Lỗi khi tự động chia nhóm: $e');
    }
  }

  // ==================== Join Code Validation ====================

  /// Kiểm tra xem join code đã tồn tại trong database chưa.
  /// Query tất cả classes và check trong class_settings.enrollment.qr_code.join_code.
  /// [joinCode] - Mã join cần kiểm tra.
  /// [excludeClassId] - Class ID cần loại trừ khỏi việc kiểm tra (class hiện tại).
  /// Trả về true nếu code đã tồn tại, false nếu chưa.
  Future<bool> checkJoinCodeExists(
    String joinCode, {
    String? excludeClassId,
  }) async {
    try {
      // Query tất cả classes
      var query = _client.from('classes').select('id, class_settings');

      // Exclude class hiện tại nếu có
      if (excludeClassId != null) {
        query = query.neq('id', excludeClassId) as dynamic;
      }

      final results = await query;

      // Check xem có class nào có join_code trùng không
      for (final classData in results) {
        final classSettings =
            classData['class_settings'] as Map<String, dynamic>?;
        if (classSettings == null) continue;

        final enrollment = classSettings['enrollment'] as Map<String, dynamic>?;
        if (enrollment == null) continue;

        final qrCode = enrollment['qr_code'] as Map<String, dynamic>?;
        if (qrCode == null) continue;

        final existingCode = qrCode['join_code'] as String?;
        if (existingCode != null && existingCode == joinCode) {
          return true; // Code đã tồn tại
        }
      }

      return false; // Code chưa tồn tại
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [DATASOURCE ERROR] checkJoinCodeExists(joinCode: $joinCode, excludeClassId: $excludeClassId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Nếu có lỗi, trả về false để không block user
      return false;
    }
  }
}

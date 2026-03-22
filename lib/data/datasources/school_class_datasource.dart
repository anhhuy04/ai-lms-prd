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

      Map<String, int> studentCountByClassId = {};
      try {
        var membersQuery = _client
            .from('class_members')
            .select('class_id')
            .eq('status', 'approved');
        membersQuery = _applyOrFilter(membersQuery, 'class_id', classIds);
        for (final m in await membersQuery as List<dynamic>) {
          final id = m['class_id'] as String?;
          if (id != null) {
            studentCountByClassId[id] = (studentCountByClassId[id] ?? 0) + 1;
          }
        }
      } catch (_) {}

      return classes.map((c) {
        final classId = c['id'] as String?;
        final teacherId = c['teacher_id'] as String?;
        final result = <String, dynamic>{
          ...c,
          'teacher_name': teacherId != null ? teacherNameById[teacherId] : null,
          'student_count': classId != null ? (studentCountByClassId[classId] ?? 0) : 0,
        };
        if (!approvedOnly) {
          result['member_status'] = classId != null ? memberStatusByClassId[classId] : null;
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

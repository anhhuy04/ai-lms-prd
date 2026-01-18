import 'dart:convert';
import 'dart:io';

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
        // #region agent log
        try {
          final logFile = File('d:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log');
          logFile.writeAsStringSync(
            '${jsonEncode({
              "id": "log_${DateTime.now().millisecondsSinceEpoch}",
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "location": "school_class_datasource.dart:75",
              "message": "Applying search filter",
              "data": {"searchQuery": searchQuery, "searchPattern": searchPattern, "teacherId": teacherId, "page": page},
              "sessionId": "debug-session",
              "runId": "run1",
              "hypothesisId": "A",
            })}\n',
            mode: FileMode.append,
          );
        } catch (_) {}
        // #endregion
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
      // #region agent log
      try {
        final logFile = File('d:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log');
        logFile.writeAsStringSync(
          '${jsonEncode({
            "id": "log_${DateTime.now().millisecondsSinceEpoch}",
            "timestamp": DateTime.now().millisecondsSinceEpoch,
            "location": "school_class_datasource.dart:89",
            "message": "Pagination query success",
            "data": {"page": page, "pageSize": pageSize, "from": from, "to": to, "resultCount": results.length, "hasSearchQuery": searchQuery != null && searchQuery.isNotEmpty},
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A",
          })}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion
      return results;
    } catch (e, stackTrace) {
      // #region agent log
      try {
        final logFile = File('d:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log');
        logFile.writeAsStringSync(
          '${jsonEncode({
            "id": "log_${DateTime.now().millisecondsSinceEpoch}",
            "timestamp": DateTime.now().millisecondsSinceEpoch,
            "location": "school_class_datasource.dart:95",
            "message": "Pagination query error",
            "data": {"error": e.toString(), "searchQuery": searchQuery, "page": page, "teacherId": teacherId},
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A",
          })}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion
      print('🔴 [DATASOURCE ERROR] getClassesByTeacherPaginated: $e');
      print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
      throw Exception('Lỗi khi lấy danh sách lớp học: $e');
    }
  }

  /// Lấy danh sách lớp học mà học sinh đã tham gia
  Future<List<Map<String, dynamic>>> getClassesByStudent(
    String studentId,
  ) async {
    try {
      // Lấy danh sách class_members với status = 'approved'
      final members = await _client
          .from('class_members')
          .select('class_id')
          .eq('student_id', studentId)
          .eq('status', 'approved');

      if (members.isEmpty) {
        return [];
      }

      // Lấy danh sách class IDs
      final classIds = (members as List)
          .map((m) => m['class_id'] as String)
          .toList();

      // Lấy thông tin các lớp học
      if (classIds.isEmpty) {
        return [];
      }

      // Sử dụng filter với nhiều giá trị
      var query = _client.from('classes').select();

      // Build filter string cho multiple IDs
      final filterString = classIds.map((id) => 'id.eq.$id').join(',');
      query = query.or(filterString) as dynamic;

      final classes = await (query as dynamic).order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(classes);
    } catch (e, stackTrace) {
      print(
        '🔴 [DATASOURCE ERROR] getClassesByStudent(studentId: $studentId): $e',
      );
      print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
      throw Exception('Lỗi khi lấy danh sách lớp học của học sinh: $e');
    }
  }

  /// Lấy thông tin lớp học theo ID
  Future<Map<String, dynamic>?> getClassById(String classId) async {
    return await _classesDataSource.getById(classId);
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
      print(
        '🔴 [DATASOURCE ERROR] getClassMembers(classId: $classId, status: $status): $e',
      );
      print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
      throw Exception('Lỗi khi lấy danh sách thành viên lớp học: $e');
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
      print(
        '🔴 [DATASOURCE ERROR] updateClassMemberStatus(classId: $classId, studentId: $studentId, status: $status): $e',
      );
      print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
      throw Exception('Lỗi khi cập nhật trạng thái thành viên: $e');
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
      print(
        '🔴 [DATASOURCE ERROR] removeStudentFromGroup(groupId: $groupId, studentId: $studentId): $e',
      );
      print('🔴 [DATASOURCE ERROR] StackTrace: $stackTrace');
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
}

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/school_class_datasource.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/domain/entities/create_group_params.dart';
import 'package:ai_mls/domain/entities/group.dart';
import 'package:ai_mls/domain/entities/group_member.dart';
import 'package:ai_mls/domain/entities/update_class_params.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';

/// Implementation của SchoolClassRepository.
/// Gộp TẤT CẢ methods vào 1 file, convert JSON → Entities và translate errors sang tiếng Việt.
class SchoolClassRepositoryImpl implements SchoolClassRepository {
  final SchoolClassDataSource _dataSource;

  SchoolClassRepositoryImpl(this._dataSource);

  // ==================== Class CRUD ====================

  @override
  Future<Class> createClass(CreateClassParams params) async {
    try {
      final classData = params.toPayloadJson();
      final result = await _dataSource.createClass(classData);
      return Class.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createClass: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo lớp học');
    }
  }

  @override
  Future<List<Class>> getClassesByTeacher(String teacherId) async {
    try {
      final results = await _dataSource.getClassesByTeacher(teacherId);
      return results.map((json) => Class.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassesByTeacher(teacherId: $teacherId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách lớp học');
    }
  }

  @override
  Future<List<Class>> getClassesByTeacherPaginated({
    required String teacherId,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final results = await _dataSource.getClassesByTeacherPaginated(
        teacherId: teacherId,
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        sortBy: sortBy,
        ascending: ascending,
      );
      return results.map((json) => Class.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassesByTeacherPaginated: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách lớp học');
    }
  }

  @override
  Future<List<Class>> getClassesByStudent(String studentId) async {
    try {
      final results = await _dataSource.getClassesByStudent(studentId);
      return results.map((json) => Class.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassesByStudent(studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách lớp học của học sinh');
    }
  }

  @override
  Future<Class?> getClassById(String classId) async {
    try {
      final result = await _dataSource.getClassById(classId);
      return result != null ? Class.fromJson(result) : null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassById(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy thông tin lớp học');
    }
  }

  @override
  Future<Class?> getClassByJoinCode(String joinCode) async {
    try {
      final result = await _dataSource.getClassByJoinCode(joinCode);
      return result != null ? Class.fromJson(result) : null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassByJoinCode(joinCode: $joinCode): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tìm lớp bằng mã tham gia');
    }
  }

  @override
  Future<Class> updateClass(String classId, UpdateClassParams params) async {
    try {
      if (params.isEmpty) {
        throw Exception('Không có dữ liệu để cập nhật');
      }

      final updateData = params.toJson();

      // Đảm bảo chỉ gửi các field không null
      // Loại bỏ các key có value null (nếu có)
      final cleanUpdateData = <String, dynamic>{};
      updateData.forEach((key, value) {
        if (value != null) {
          cleanUpdateData[key] = value;
        }
      });

      if (cleanUpdateData.isEmpty) {
        throw Exception('Không có dữ liệu hợp lệ để cập nhật');
      }

      final result = await _dataSource.updateClass(classId, cleanUpdateData);
      return Class.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateClass(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật lớp học');
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    try {
      AppLogger.debug('🟢 [REPO] deleteClass: Bắt đầu xóa lớp học $classId');
      AppLogger.debug('🟢 [REPO] deleteClass: Gọi datasource.deleteClass()');

      await _dataSource.deleteClass(classId);

      AppLogger.info('✅ [REPO] deleteClass: Xóa lớp học thành công $classId');
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] deleteClass(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );

      final errorString = e.toString();

      // Log chi tiết hơn về lỗi
      if (errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('JWT')) {
        AppLogger.warning(
          '⚠️ [REPO ERROR] deleteClass: Lỗi 401 - Có thể do RLS hoặc authentication',
        );
        AppLogger.warning('⚠️ [REPO ERROR] deleteClass: Kiểm tra:');
        AppLogger.warning('   - User đã đăng nhập chưa?');
        AppLogger.warning('   - JWT token có hợp lệ không?');
        AppLogger.warning('   - RLS policies có cho phép DELETE không?');
      } else if (errorString.contains('403') ||
          errorString.contains('forbidden')) {
        AppLogger.warning(
          '⚠️ [REPO ERROR] deleteClass: Lỗi 403 - Không có quyền xóa',
        );
        AppLogger.warning('⚠️ [REPO ERROR] deleteClass: Kiểm tra:');
        AppLogger.warning('   - User có phải là teacher của lớp không?');
        AppLogger.warning(
          '   - RLS policies có cho phép user này DELETE không?',
        );
      } else if (errorString.contains('foreign key') ||
          errorString.contains('23503')) {
        AppLogger.warning(
          '⚠️ [REPO ERROR] deleteClass: Lỗi foreign key - Có dữ liệu liên quan',
        );
        AppLogger.warning('⚠️ [REPO ERROR] deleteClass: Kiểm tra:');
        AppLogger.warning('   - Có class_members nào còn tồn tại không?');
        AppLogger.warning('   - Có groups nào còn tồn tại không?');
        AppLogger.warning('   - Foreign key constraints có đúng không?');
      } else if (errorString.contains('not found') ||
          errorString.contains('PGRST116')) {
        AppLogger.warning('⚠️ [REPO ERROR] deleteClass: Lớp học không tồn tại');
      } else {
        AppLogger.warning(
          '⚠️ [REPO ERROR] deleteClass: Lỗi không xác định - $errorString',
        );
      }

      // Re-throw với error đã được translate
      throw ErrorTranslationUtils.translateError(e, 'Xóa lớp học');
    }
  }

  // ==================== Class Members ====================

  @override
  Future<ClassMember> requestJoinClass(String classId, String studentId) async {
    try {
      // Kiểm tra xem học sinh đã tham gia lớp chưa
      final existingMembers = await _dataSource.getClassMembers(classId);
      final alreadyMember = existingMembers.any(
        (m) => m['student_id'] == studentId,
      );

      if (alreadyMember) {
        throw Exception('Bạn đã tham gia lớp học này rồi');
      }

      // Lấy thông tin class để quyết định có cần duyệt hay không
      final currentClass = await getClassById(classId);
      final classSettings =
          currentClass?.classSettings ?? Class.defaultClassSettings();
      final enrollment =
          classSettings['enrollment'] as Map<String, dynamic>? ?? {};
      final qrCode =
          enrollment['qr_code'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final requireApproval = qrCode['require_approval'] as bool? ?? true;

      final memberData = {
        'class_id': classId,
        'student_id': studentId,
        // Nếu lớp không yêu cầu duyệt học sinh thì cho vào thẳng với status = approved
        'status': requireApproval ? 'pending' : 'approved',
      };

      final result = await _dataSource.createClassMember(memberData);
      return ClassMember.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] requestJoinClass(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Yêu cầu tham gia lớp học');
    }
  }

  @override
  Future<void> approveStudent(String classId, String studentId) async {
    try {
      await _dataSource.updateClassMemberStatus(classId, studentId, 'approved');
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] approveStudent(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Duyệt học sinh');
    }
  }

  @override
  Future<void> rejectStudent(String classId, String studentId) async {
    try {
      await _dataSource.updateClassMemberStatus(classId, studentId, 'rejected');
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] rejectStudent(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Từ chối học sinh');
    }
  }

  @override
  Future<void> leaveClass(String classId, String studentId) async {
    try {
      await _dataSource.leaveClass(classId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] leaveClass(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Rời lớp học');
    }
  }

  @override
  Future<List<ClassMember>> getClassMembers(
    String classId, {
    String? status,
  }) async {
    try {
      final results = await _dataSource.getClassMembers(
        classId,
        status: status,
      );
      return results.map((json) => ClassMember.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getClassMembers(classId: $classId, status: $status): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách thành viên');
    }
  }

  // ==================== Groups ====================

  @override
  Future<Group> createGroup(CreateGroupParams params) async {
    try {
      final groupData = params.toJson();
      final result = await _dataSource.createGroup(groupData);
      return Group.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] createGroup: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo nhóm học tập');
    }
  }

  @override
  Future<List<Group>> getGroupsByClass(String classId) async {
    try {
      final results = await _dataSource.getGroupsByClass(classId);
      return results.map((json) => Group.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getGroupsByClass(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách nhóm học tập');
    }
  }

  @override
  Future<void> addStudentToGroup(String groupId, String studentId) async {
    try {
      // Kiểm tra xem học sinh đã ở trong nhóm chưa
      final existingMembers = await _dataSource.getGroupMembers(groupId);
      final alreadyMember = existingMembers.any(
        (m) => m['student_id'] == studentId,
      );

      if (alreadyMember) {
        throw Exception('Học sinh đã ở trong nhóm này rồi');
      }

      await _dataSource.addStudentToGroup(groupId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] addStudentToGroup(groupId: $groupId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Thêm học sinh vào nhóm');
    }
  }

  @override
  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    try {
      await _dataSource.removeStudentFromGroup(groupId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] removeStudentFromGroup(groupId: $groupId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xóa học sinh khỏi nhóm');
    }
  }

  @override
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final results = await _dataSource.getGroupMembers(groupId);
      return results.map((json) => GroupMember.fromJson(json)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getGroupMembers(groupId: $groupId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách thành viên nhóm');
    }
  }

  // ==================== Class Settings ====================

  @override
  Future<Class> updateClassSettings(
    String classId,
    Map<String, dynamic> settings,
  ) async {
    try {
      // Lấy class hiện tại để merge settings
      final currentClass = await getClassById(classId);
      if (currentClass == null) {
        throw Exception('Không tìm thấy lớp học');
      }

      // Merge settings mới với settings cũ
      final mergedSettings = _mergeNestedMap(
        currentClass.classSettings ?? Class.defaultClassSettings(),
        settings,
      );

      // Update class_settings trong database
      final updateData = {'class_settings': mergedSettings};
      final result = await _dataSource.updateClass(classId, updateData);
      return Class.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateClassSettings(classId: $classId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật cài đặt lớp học');
    }
  }

  @override
  Future<Class> updateClassSetting(
    String classId,
    String path,
    dynamic value,
  ) async {
    try {
      // Lấy class hiện tại
      final currentClass = await getClassById(classId);
      if (currentClass == null) {
        throw Exception('Không tìm thấy lớp học');
      }

      // Tạo map từ path (ví dụ: 'defaults.lock_class' -> {'defaults': {'lock_class': value}})
      final settingsToUpdate = _pathToNestedMap(path, value);

      // Merge với settings hiện tại
      final mergedSettings = _mergeNestedMap(
        currentClass.classSettings ?? Class.defaultClassSettings(),
        settingsToUpdate,
      );

      // Update class_settings trong database
      final updateData = {'class_settings': mergedSettings};
      final result = await _dataSource.updateClass(classId, updateData);
      return Class.fromJson(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateClassSetting(classId: $classId, path: $path): $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật cài đặt lớp học');
    }
  }

  @override
  Future<bool> checkJoinCodeExists(
    String joinCode, {
    String? excludeClassId,
  }) async {
    try {
      return await _dataSource.checkJoinCodeExists(
        joinCode,
        excludeClassId: excludeClassId,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] checkJoinCodeExists(joinCode: $joinCode, excludeClassId: $excludeClassId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Nếu có lỗi, trả về false để không block user
      return false;
    }
  }

  /// Merge nested map: merge settings mới vào settings cũ
  /// Không ghi đè toàn bộ, chỉ update các keys được chỉ định
  Map<String, dynamic> _mergeNestedMap(
    Map<String, dynamic> base,
    Map<String, dynamic> update,
  ) {
    final result = Map<String, dynamic>.from(base);

    for (final entry in update.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic> &&
          result[key] is Map<String, dynamic>) {
        // Nếu cả hai đều là Map, merge đệ quy
        result[key] = _mergeNestedMap(
          result[key] as Map<String, dynamic>,
          value,
        );
      } else {
        // Nếu không, ghi đè giá trị
        result[key] = value;
      }
    }

    return result;
  }

  /// Chuyển đổi path string thành nested map
  /// Ví dụ: 'defaults.lock_class' -> {'defaults': {'lock_class': value}}
  Map<String, dynamic> _pathToNestedMap(String path, dynamic value) {
    final parts = path.split('.');

    // Build nested map từ trong ra ngoài
    dynamic current = value;
    for (int i = parts.length - 1; i >= 0; i--) {
      current = {parts[i]: current};
    }

    return current as Map<String, dynamic>;
  }

}

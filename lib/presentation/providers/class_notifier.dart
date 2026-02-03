import 'dart:async';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/optimistic_update_utils.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/domain/entities/update_class_params.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'class_notifier.g.dart';

/// ClassNotifier (Riverpod) thay thế dần `ClassViewModel`.
///
/// Mục tiêu: tách logic khỏi UI, tối ưu theo Clean Architecture.
/// Lưu ý: ViewModel cũ vẫn còn để migrate UI từng bước.
@riverpod
class ClassNotifier extends _$ClassNotifier {
  SchoolClassRepository get _repo => ref.read(schoolClassRepositoryProvider);

  // Guard để tránh multiple concurrent updates
  bool _isUpdating = false;

  /// State chính: danh sách lớp (teacher/student tùy theo luồng gọi).
  @override
  FutureOr<List<Class>> build() async {
    // Mặc định trả list rỗng, UI sẽ tự gọi load theo ngữ cảnh.
    return <Class>[];
  }

  // ==================== LOAD LISTS ====================

  /// Load danh sách lớp của giáo viên.
  Future<void> loadClassesByTeacher(String teacherId) async {
    state = const AsyncValue.loading();
    try {
      final classes = await _repo.getClassesByTeacher(teacherId);
      state = AsyncValue.data(classes);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] loadClassesByTeacher lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Load danh sách lớp của học sinh.
  Future<void> loadClassesByStudent(String studentId) async {
    state = const AsyncValue.loading();
    try {
      final classes = await _repo.getClassesByStudent(studentId);
      state = AsyncValue.data(classes);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] loadClassesByStudent lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ==================== DETAIL ====================

  /// selectedClass giữ thông tin class hiện tại cho màn detail.
  Class? _selectedClass;
  Class? get selectedClass => _selectedClass;

  /// isDetailLoading phục vụ UI detail (tránh chặn list state).
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  /// detailErrorMessage dành cho màn detail.
  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  /// Load chi tiết lớp học.
  Future<void> loadClassDetails(String classId) async {
    _isDetailLoading = true;
    _detailErrorMessage = null;
    _selectedClass = null; // Clear previous selection
    // Trigger rebuild bằng cách tạo một AsyncValue mới với cùng data
    // Điều này sẽ notify listeners mà không làm mất state của list
    final currentState = state;
    if (currentState.hasValue) {
      state = AsyncValue.data(currentState.value!);
    } else {
      state = currentState;
    }

    try {
      final result = await _repo.getClassById(classId);
      _selectedClass = result;
      _isDetailLoading = false;
      _detailErrorMessage = null;

      // Trigger rebuild sau khi load thành công
      final newState = state;
      if (newState.hasValue) {
        state = AsyncValue.data(newState.value!);
      } else {
        state = newState;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] loadClassDetails lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _detailErrorMessage = e.toString();
      _isDetailLoading = false;
      _selectedClass = null;

      // Trigger rebuild sau khi có lỗi
      final errorState = state;
      if (errorState.hasValue) {
        state = AsyncValue.data(errorState.value!);
      } else {
        state = errorState;
      }
    }
  }

  void clearDetailError() {
    _detailErrorMessage = null;
    state = state;
  }

  // ==================== CRUD ====================

  Future<Class?> createClass(CreateClassParams params) async {
    final previous = state.value ?? const <Class>[];
    state = const AsyncValue.loading();
    try {
      final newClass = await _repo.createClass(params);
      state = AsyncValue.data([newClass, ...previous]);
      return newClass;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] createClass lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<bool> updateClass(String classId, UpdateClassParams params) async {
    // Guard: Tránh multiple concurrent updates
    if (_isUpdating) {
      AppLogger.warning(
        '🔴 [CLASS] updateClass: Already updating, skipping duplicate call',
      );
      return false;
    }

    _isUpdating = true;
    final previous = state.value ?? const <Class>[];

    try {
      // Chỉ set loading nếu state hiện tại không phải loading
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final updated = await _repo.updateClass(classId, params);
      final next = [
        for (final c in previous)
          if (c.id == classId) updated else c,
      ];
      // Nếu đang xem detail class này, cập nhật luôn selectedClass.
      if (_selectedClass?.id == classId) {
        _selectedClass = updated;
      }
      state = AsyncValue.data(next);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] updateClass lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Chỉ set error nếu state chưa bị thay đổi bởi operation khác
      if (_isUpdating) {
        state = AsyncValue.error(e, stackTrace);
      }
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  Future<bool> deleteClass(String classId) async {
    final previous = state.value ?? const <Class>[];
    state = const AsyncValue.loading();
    try {
      await _repo.deleteClass(classId);
      state = AsyncValue.data(previous.where((c) => c.id != classId).toList());
      if (_selectedClass?.id == classId) {
        _selectedClass = null;
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] deleteClass lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // ==================== MEMBERS ====================

  /// Lấy members (dùng cho màn hình chi tiết).
  Future<List<ClassMember>> getClassMembers(
    String classId, {
    String? status,
  }) async {
    try {
      return await _repo.getClassMembers(classId, status: status);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] getClassMembers lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Lấy số lượng thành viên theo status (pending/approved) bằng Future.wait.
  ///
  /// Dùng cho UI cần hiển thị badge/counter mà không muốn fetch tuần tự.
  /// NOTE: Tránh set state/loading ở đây để không gây side-effect lên router/UI.
  Future<({int pending, int approved})> getClassMemberCounts(
    String classId,
  ) async {
    try {
      final results = await Future.wait([
        _repo.getClassMembers(classId, status: 'pending'),
        _repo.getClassMembers(classId, status: 'approved'),
      ]);
      final pendingList = results[0];
      final approvedList = results[1];
      return (pending: pendingList.length, approved: approvedList.length);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] getClassMemberCounts lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Resolve lớp học từ join_code (mã tham gia lớp).
  /// Trả về Class nếu tìm thấy và mã còn hiệu lực, null nếu không tồn tại.
  /// Ném ra Exception nếu có lỗi nghiệp vụ (mã hết hạn, lớp bị khóa, vượt giới hạn...).
  Future<Class?> resolveClassByJoinCode(String joinCode) async {
    try {
      return await _repo.getClassByJoinCode(joinCode);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] resolveClassByJoinCode lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Giáo viên duyệt học sinh tham gia lớp.
  Future<void> approveStudent(String classId, String studentId) async {
    try {
      await _repo.approveStudent(classId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] approveStudent lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Giáo viên từ chối / loại học sinh khỏi lớp.
  Future<void> rejectStudent(String classId, String studentId) async {
    try {
      await _repo.rejectStudent(classId, studentId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] rejectStudent lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Yêu cầu tham gia lớp (học sinh).
  Future<ClassMember?> requestJoinClass(
    String classId,
    String studentId,
  ) async {
    try {
      final member = await _repo.requestJoinClass(classId, studentId);
      // Không thay đổi list state ngay (phụ thuộc backend flow), chỉ log.
      AppLogger.info('✅ [CLASS] requestJoinClass thành công classId=$classId');
      return member;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] requestJoinClass lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Học sinh rời lớp học.
  /// Trả về true nếu thành công, false nếu thất bại.
  Future<bool> leaveClass(String classId, String studentId) async {
    if (_isUpdating) {
      AppLogger.warning('⚠️ [CLASS] leaveClass: Đang xử lý request khác');
      return false;
    }

    _isUpdating = true;
    try {
      await _repo.leaveClass(classId, studentId);
      
      // Cập nhật state: xóa class khỏi danh sách
      final currentState = state;
      if (currentState.hasValue) {
        final updatedClasses = currentState.value!
            .where((c) => c.id != classId)
            .toList();
        state = AsyncValue.data(updatedClasses);
      }
      
      // Clear selected class nếu đang ở class này
      if (_selectedClass?.id == classId) {
        _selectedClass = null;
      }
      
      AppLogger.info('✅ [CLASS] leaveClass thành công classId=$classId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] leaveClass lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  /// Cập nhật một setting cụ thể trong classSettings
  /// Ví dụ: updateClassSetting(classId, 'defaults.lock_class', true)
  Future<bool> updateClassSetting(
    String classId,
    String settingPath,
    dynamic value,
  ) async {
    try {
      // Lấy class hiện tại
      final currentClass = _selectedClass?.id == classId
          ? _selectedClass!
          : (await _repo.getClassById(classId));

      if (currentClass == null) {
        AppLogger.error('🔴 [CLASS] updateClassSetting: Class not found');
        return false;
      }

      // Validate: Đảm bảo class có đầy đủ dữ liệu bắt buộc
      if (currentClass.name.isEmpty) {
        AppLogger.error(
          '🔴 [CLASS] updateClassSetting: Class has invalid name, cannot update',
        );
        return false;
      }

      // Parse setting path (ví dụ: 'defaults.lock_class' -> ['defaults', 'lock_class'])
      final pathParts = settingPath.split('.');

      // Deep copy classSettings
      final newSettings = Map<String, dynamic>.from(
        currentClass.classSettings ?? <String, dynamic>{},
      );

      // Navigate và update nested value
      Map<String, dynamic> current = newSettings;
      for (int i = 0; i < pathParts.length - 1; i++) {
        final key = pathParts[i];
        if (current[key] == null || current[key] is! Map) {
          current[key] = <String, dynamic>{};
        }
        current = current[key] as Map<String, dynamic>;
      }
      current[pathParts.last] = value;

      // Tạo UpdateClassParams CHỈ với classSettings
      // Không truyền các field khác để tránh làm mất dữ liệu
      final params = UpdateClassParams(classSettings: newSettings);

      // Cập nhật class
      return await updateClass(classId, params);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] updateClassSetting lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Optimistic update: Cập nhật UI ngay lập tức, sync với backend trong background
  /// Không hiển thị loading spinner, chỉ update local state
  /// Nếu fail, sẽ rollback và trả về false
  ///
  /// Sử dụng OptimisticUpdateUtils để có thể tái sử dụng pattern này
  Future<bool> updateClassSettingOptimistic(
    String classId,
    String settingPath,
    dynamic value,
  ) async {
    // Lưu state cũ để rollback nếu cần
    final previousSelectedClass = _selectedClass;
    final previousState = state.value ?? const <Class>[];

    return await OptimisticUpdateUtils.execute(
      optimisticUpdate: () async {
        // Lấy class hiện tại - ưu tiên từ selectedClass, sau đó từ list
        Class? currentClass;
        if (_selectedClass?.id == classId) {
          currentClass = _selectedClass!;
        } else {
          try {
            currentClass = previousState.firstWhere((c) => c.id == classId);
          } catch (_) {
            // Class không có trong list, chỉ có thể update nếu có trong selectedClass
            AppLogger.warning(
              '🔴 [CLASS] updateClassSettingOptimistic: Class not found in state',
            );
            return false;
          }
        }

        // Deep copy classSettings và update nested value
        final newSettings = OptimisticUpdateUtils.deepCopyMap(
          currentClass.classSettings,
        );
        OptimisticUpdateUtils.updateNestedValue(
          newSettings,
          settingPath,
          value,
        );

        // Tạo class mới với settings đã cập nhật
        final updatedClass = currentClass.copyWith(classSettings: newSettings);

        // Update selectedClass ngay lập tức (nếu đang xem detail)
        if (_selectedClass?.id == classId) {
          _selectedClass = updatedClass;
          // Trigger rebuild bằng cách update state (không set loading)
          final currentState = state;
          if (currentState.hasValue) {
            state = AsyncValue.data(currentState.value!);
          }
        }

        // Update trong list state nếu class có trong list (không trigger loading)
        final classInList = previousState.any((c) => c.id == classId);
        if (classInList) {
          final updatedList = [
            for (final c in previousState)
              if (c.id == classId) updatedClass else c,
          ];
          state = AsyncValue.data(updatedList);
        }

        return true;
      },
      syncToBackend: () => _syncClassSettingToBackend(
        classId,
        settingPath,
        value,
        previousSelectedClass,
        previousState,
      ),
      onError: (error, stackTrace) {
        // Rollback nếu có lỗi
        _selectedClass = previousSelectedClass;
        state = AsyncValue.data(previousState);
        AppLogger.error(
          '🔴 [CLASS] updateClassSettingOptimistic lỗi: $error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Sync setting với backend (chạy trong background)
  /// Không log thành công, chỉ log khi thất bại
  Future<void> _syncClassSettingToBackend(
    String classId,
    String settingPath,
    dynamic value,
    Class? previousSelectedClass,
    List<Class> previousState,
  ) async {
    // Lấy class hiện tại từ backend để đảm bảo có dữ liệu mới nhất
    final currentClass = await _repo.getClassById(classId);

    if (currentClass == null) {
      throw Exception('Class not found: $classId');
    }

    // Deep copy classSettings và update nested value
    final newSettings = OptimisticUpdateUtils.deepCopyMap(
      currentClass.classSettings,
    );
    OptimisticUpdateUtils.updateNestedValue(newSettings, settingPath, value);

    // Tạo UpdateClassParams
    final params = UpdateClassParams(classSettings: newSettings);

    // Gọi repository trực tiếp để update (không qua updateClass để tránh loading)
    final updated = await _repo.updateClass(classId, params);

    // Cập nhật lại state với dữ liệu từ backend
    final previous = state.value ?? const <Class>[];
    final next = [
      for (final c in previous)
        if (c.id == classId) updated else c,
    ];

    if (_selectedClass?.id == classId) {
      _selectedClass = updated;
      // Trigger rebuild cho selectedClass
      final currentState = state;
      if (currentState.hasValue) {
        state = AsyncValue.data(currentState.value!);
      }
    }

    // Chỉ update list nếu class có trong list
    final classInList = previous.any((c) => c.id == classId);
    if (classInList) {
      state = AsyncValue.data(next);
    }
  }

  /// Kiểm tra xem join code đã tồn tại trong database chưa.
  Future<bool> checkJoinCodeExists(
    String joinCode, {
    String? excludeClassId,
  }) async {
    try {
      return await _repo.checkJoinCodeExists(
        joinCode,
        excludeClassId: excludeClassId,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [CLASS] checkJoinCodeExists lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Nếu có lỗi, trả về false để không block user
      return false;
    }
  }
}

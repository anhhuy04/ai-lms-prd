import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/domain/entities/update_class_params.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/viewmodels/mixins/refreshable_view_model.dart';
import 'package:flutter/foundation.dart';

/// ViewModel cho chức năng quản lý lớp học, tuân thủ Clean Architecture.
/// Chỉ tương tác với `SchoolClassRepository` (tầng Domain).
/// Repository xử lý tất cả logic Supabase, error handling, và translation.
class ClassViewModel extends ChangeNotifier with RefreshableViewModel {
  final SchoolClassRepository _repository;

  // ==================== State Properties ====================

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  // Error state
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Data states
  List<Class> _classes = [];
  List<Class> get classes => _classes;

  Class? _selectedClass;
  Class? get selectedClass => _selectedClass;

  String? _teacherId;
  String? get teacherId => _teacherId;

  List<ClassMember> _classMembers = [];
  List<ClassMember> get classMembers => _classMembers;

  List<ClassMember> _pendingMembers = [];
  List<ClassMember> get pendingMembers => _pendingMembers;

  List<ClassMember> _approvedMembers = [];
  List<ClassMember> get approvedMembers => _approvedMembers;

  // ==================== Constructor ====================

  ClassViewModel(this._repository);

  // ==================== Private Helper Methods ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _updateClassMembers(List<ClassMember> members) {
    _classMembers = members;
    _pendingMembers = members.where((m) => m.isPending).toList();
    _approvedMembers = members.where((m) => m.isApproved).toList();
    notifyListeners();
  }

  // ==================== Public Methods ====================

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Chọn một lớp học để xem chi tiết
  void selectClass(Class? classItem) {
    _selectedClass = classItem;
    notifyListeners();
  }

  /// Thiết lập teacherId để sử dụng trong fetchData
  void setTeacherId(String teacherId) {
    _teacherId = teacherId;
  }

  /// Làm mới dữ liệu (override từ RefreshableViewModel)
  /// Sử dụng _teacherId đã được thiết lập qua setTeacherId()
  @override
  Future<void> fetchData() async {
    if (_isLoading) return;

    if (_teacherId == null) {
      _setError('Không tìm thấy thông tin giáo viên');
      _setLoading(false);
      notifyListeners();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _classes = await _repository.getClassesByTeacher(_teacherId!);
      // Clear error khi thành công (dù có dữ liệu hay không)
      _setError(null);
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] fetchData: $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy danh sách lớp học của giáo viên
  Future<void> loadClasses(String teacherId) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      _classes = await _repository.getClassesByTeacher(teacherId);
      // Clear error khi thành công (dù có dữ liệu hay không)
      _setError(null);
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] loadClasses(teacherId: $teacherId): $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy danh sách lớp học của học sinh
  Future<void> loadStudentClasses(String studentId) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      _classes = await _repository.getClassesByStudent(studentId);
      // Clear error khi thành công (dù có dữ liệu hay không)
      _setError(null);
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] loadStudentClasses(studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy thông tin chi tiết lớp học
  Future<void> loadClassDetails(String classId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedClass = await _repository.getClassById(classId);
      if (_selectedClass != null) {
        // Load members của lớp
        await loadClassMembers(classId);
      }
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] loadClassDetails(classId: $classId): $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy danh sách thành viên lớp học
  Future<void> loadClassMembers(String classId, {String? status}) async {
    _setLoading(true);
    _setError(null);

    try {
      final members = await _repository.getClassMembers(
        classId,
        status: status,
      );
      _updateClassMembers(members);
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] loadClassMembers(classId: $classId, status: $status): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Tạo lớp học mới
  Future<Class?> createClass(CreateClassParams params) async {
    _setCreating(true);
    _setError(null);

    try {
      final newClass = await _repository.createClass(params);
      _classes.insert(0, newClass); // Thêm vào đầu danh sách
      _setCreating(false);
      notifyListeners();
      return newClass;
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] createClass: $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setCreating(false);
      notifyListeners();
      return null;
    }
  }

  /// Cập nhật thông tin lớp học
  Future<bool> updateClass(String classId, UpdateClassParams params) async {
    _setUpdating(true);
    _setError(null);

    try {
      final updatedClass = await _repository.updateClass(classId, params);

      // Cập nhật trong danh sách
      final index = _classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        _classes[index] = updatedClass;
      }

      // Cập nhật selected class nếu đang được chọn
      if (_selectedClass?.id == classId) {
        _selectedClass = updatedClass;
      }

      _setUpdating(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] updateClass(classId: $classId): $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setUpdating(false);
      notifyListeners();
      return false;
    }
  }

  /// Xóa lớp học
  Future<bool> deleteClass(String classId) async {
    if (_isDeleting) {
      AppLogger.warning('⚠️ [VIEWMODEL] deleteClass: Đang xóa lớp khác, bỏ qua request');
      return false;
    }

    _setDeleting(true);
    _setError(null);

    try {
      AppLogger.debug('🟢 [VIEWMODEL] deleteClass: Bắt đầu xóa lớp học $classId');
      
      // Kiểm tra xem lớp có tồn tại trong danh sách không
      final classExists = _classes.any((c) => c.id == classId) || 
                         _selectedClass?.id == classId;
      if (!classExists) {
        AppLogger.warning('⚠️ [VIEWMODEL] deleteClass: Lớp học không tồn tại trong local state');
      }

      await _repository.deleteClass(classId);
      AppLogger.info(
        '✅ [VIEWMODEL] deleteClass: Repository xóa thành công, cập nhật local state',
      );

      // Xóa khỏi danh sách
      final beforeCount = _classes.length;
      _classes.removeWhere((c) => c.id == classId);
      final afterCount = _classes.length;
      AppLogger.debug(
        '🟢 [VIEWMODEL] deleteClass: Đã xóa ${beforeCount - afterCount} lớp khỏi danh sách (trước: $beforeCount, sau: $afterCount)',
      );

      // Xóa selected class nếu đang được chọn
      if (_selectedClass?.id == classId) {
        _selectedClass = null;
        AppLogger.debug('🟢 [VIEWMODEL] deleteClass: Đã clear selected class');
      }

      _setDeleting(false);
      _setError(null); // Clear error khi thành công
      notifyListeners();
      AppLogger.info('✅ [VIEWMODEL] deleteClass: Hoàn tất xóa lớp học $classId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] deleteClass(classId: $classId): $e', error: e, stackTrace: stackTrace);

      // Lưu error message chi tiết hơn
      String errorMsg;
      if (e is Exception) {
        errorMsg = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMsg = e.toString();
      }
      
      _setError(errorMsg);

      // Log thêm thông tin về loại lỗi
      if (errorMsg.contains('401') || 
          errorMsg.contains('unauthorized') ||
          errorMsg.contains('JWT')) {
        AppLogger.warning(
          '⚠️ [VIEWMODEL ERROR] deleteClass: Lỗi 401 - Kiểm tra authentication và RLS policies',
        );
        _setError('Lỗi xác thực: Bạn cần đăng nhập lại để thực hiện thao tác này');
      } else if (errorMsg.contains('403') || 
                 errorMsg.contains('forbidden') ||
                 errorMsg.contains('permission') ||
                 errorMsg.contains('42501')) {
        AppLogger.warning(
          '⚠️ [VIEWMODEL ERROR] deleteClass: Lỗi 403 - User không có quyền xóa lớp này',
        );
        _setError('Bạn không có quyền xóa lớp học này. Chỉ giáo viên chủ nhiệm mới có thể xóa.');
      } else if (errorMsg.contains('foreign key') ||
                 errorMsg.contains('23503')) {
        AppLogger.warning(
          '⚠️ [VIEWMODEL ERROR] deleteClass: Lỗi foreign key - Có dữ liệu liên quan chưa được xóa',
        );
        _setError('Không thể xóa lớp học vì còn dữ liệu liên quan. Vui lòng liên hệ quản trị viên.');
      } else if (errorMsg.contains('not found') ||
                 errorMsg.contains('PGRST116')) {
        AppLogger.warning(
          '⚠️ [VIEWMODEL ERROR] deleteClass: Lớp học không tồn tại',
        );
        _setError('Lớp học không tồn tại hoặc đã bị xóa.');
      } else {
        // Giữ nguyên error message từ repository
        AppLogger.warning('⚠️ [VIEWMODEL ERROR] deleteClass: Lỗi không xác định');
      }

      _setDeleting(false);
      notifyListeners();
      return false;
    }
  }

  /// Học sinh yêu cầu tham gia lớp
  Future<bool> requestJoinClass(String classId, String studentId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.requestJoinClass(classId, studentId);
      // Reload members để cập nhật danh sách
      await loadClassMembers(classId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] requestJoinClass(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Duyệt học sinh tham gia lớp
  Future<bool> approveStudent(String classId, String studentId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.approveStudent(classId, studentId);
      // Reload members để cập nhật danh sách
      await loadClassMembers(classId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] approveStudent(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Từ chối học sinh tham gia lớp
  Future<bool> rejectStudent(String classId, String studentId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.rejectStudent(classId, studentId);
      // Reload members để cập nhật danh sách
      await loadClassMembers(classId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] rejectStudent(classId: $classId, studentId: $studentId): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // ==================== Class Settings ====================

  /// Cập nhật toàn bộ class_settings
  Future<bool> updateClassSettings(
    String classId,
    Map<String, dynamic> settings,
  ) async {
    _setUpdating(true);
    _setError(null);

    try {
      final updatedClass = await _repository.updateClassSettings(
        classId,
        settings,
      );

      // Cập nhật trong danh sách
      final index = _classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        _classes[index] = updatedClass;
      }

      // Cập nhật selected class nếu đang được chọn
      if (_selectedClass?.id == classId) {
        _selectedClass = updatedClass;
      }

      _setUpdating(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [VIEWMODEL ERROR] updateClassSettings(classId: $classId): $e', error: e, stackTrace: stackTrace);
      _setError(e.toString());
      _setUpdating(false);
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật một setting cụ thể theo path
  /// Ví dụ: updateClassSetting(classId, 'defaults.lock_class', true)
  Future<bool> updateClassSetting(
    String classId,
    String path,
    dynamic value,
  ) async {
    _setUpdating(true);
    _setError(null);

    try {
      final updatedClass = await _repository.updateClassSetting(
        classId,
        path,
        value,
      );

      // Cập nhật trong danh sách
      final index = _classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        _classes[index] = updatedClass;
      }

      // Cập nhật selected class nếu đang được chọn
      if (_selectedClass?.id == classId) {
        _selectedClass = updatedClass;
      }

      _setUpdating(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [VIEWMODEL ERROR] updateClassSetting(classId: $classId, path: $path): $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      _setUpdating(false);
      notifyListeners();
      return false;
    }
  }

  /// Lấy class_settings hiện tại của lớp học
  Map<String, dynamic>? getClassSettings(String classId) {
    final classItem = _classes.firstWhere(
      (c) => c.id == classId,
      orElse: () => _selectedClass!,
    );
    return classItem.classSettings;
  }

  // ==================== Computed Properties ====================

  /// Số lượng lớp học
  int get classCount => _classes.length;

  /// Số lượng thành viên đang chờ duyệt
  int get pendingCount => _pendingMembers.length;

  /// Số lượng thành viên đã được duyệt
  int get approvedCount => _approvedMembers.length;

  /// Kiểm tra có đang xử lý gì không
  bool get isProcessing =>
      _isLoading || _isCreating || _isUpdating || _isDeleting;

  /// Kiểm tra có lỗi không
  bool get hasError => _errorMessage != null;
}

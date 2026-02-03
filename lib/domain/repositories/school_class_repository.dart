import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/domain/entities/create_group_params.dart';
import 'package:ai_mls/domain/entities/group.dart';
import 'package:ai_mls/domain/entities/group_member.dart';
import 'package:ai_mls/domain/entities/update_class_params.dart';

/// Abstract Repository định nghĩa các "hợp đồng" cho chức năng quản lý lớp học.
/// Tầng Presentation (ViewModel) sẽ phụ thuộc vào lớp này,
/// không phải vào lớp triển khai cụ thể.
abstract class SchoolClassRepository {
  // ==================== Class CRUD ====================

  /// Tạo lớp học mới.
  /// Trả về đối tượng Class nếu thành công.
  /// Ném ra Exception nếu thất bại.
  Future<Class> createClass(CreateClassParams params);

  /// Lấy danh sách lớp học của một giáo viên.
  /// Trả về danh sách Class, có thể rỗng nếu không có lớp nào.
  Future<List<Class>> getClassesByTeacher(String teacherId);

  /// Lấy danh sách lớp học của giáo viên với pagination, search và sort.
  /// Trả về danh sách Class, có thể rỗng nếu không có lớp nào.
  Future<List<Class>> getClassesByTeacherPaginated({
    required String teacherId,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  });

  /// Lấy danh sách lớp học mà học sinh đã tham gia (status = 'approved').
  /// Trả về danh sách Class, có thể rỗng nếu không có lớp nào.
  Future<List<Class>> getClassesByStudent(String studentId);

  /// Lấy thông tin lớp học theo ID.
  /// Trả về Class nếu tìm thấy, null nếu không tồn tại.
  Future<Class?> getClassById(String classId);

  /// Tìm lớp học theo join_code (mã tham gia lớp).
  /// Trả về Class nếu tìm thấy và mã còn hiệu lực, null nếu không tồn tại.
  /// Ném ra Exception nếu mã đã hết hạn, lớp bị khóa hoặc vi phạm giới hạn tham gia.
  Future<Class?> getClassByJoinCode(String joinCode);

  /// Cập nhật thông tin lớp học.
  /// Trả về Class đã được cập nhật.
  /// Ném ra Exception nếu lớp không tồn tại hoặc thất bại.
  Future<Class> updateClass(String classId, UpdateClassParams params);

  /// Xóa lớp học.
  /// Ném ra Exception nếu thất bại.
  Future<void> deleteClass(String classId);

  // ==================== Class Members ====================

  /// Học sinh yêu cầu tham gia lớp học.
  /// Tạo ClassMember với status = 'pending'.
  /// Trả về ClassMember đã được tạo.
  /// Ném ra Exception nếu đã tham gia lớp hoặc thất bại.
  Future<ClassMember> requestJoinClass(String classId, String studentId);

  /// Giáo viên duyệt học sinh tham gia lớp.
  /// Cập nhật status của ClassMember thành 'approved'.
  /// Ném ra Exception nếu không tìm thấy hoặc thất bại.
  Future<void> approveStudent(String classId, String studentId);

  /// Giáo viên từ chối học sinh tham gia lớp.
  /// Cập nhật status của ClassMember thành 'rejected'.
  /// Ném ra Exception nếu không tìm thấy hoặc thất bại.
  Future<void> rejectStudent(String classId, String studentId);

  /// Học sinh rời lớp học.
  /// Xóa hoàn toàn record khỏi class_members.
  /// Ném ra Exception nếu không tìm thấy hoặc thất bại.
  Future<void> leaveClass(String classId, String studentId);

  /// Lấy danh sách thành viên lớp học.
  /// [status] là optional filter: 'pending', 'approved', 'rejected'.
  /// Nếu null, trả về tất cả thành viên.
  /// Trả về danh sách ClassMember, có thể rỗng.
  Future<List<ClassMember>> getClassMembers(String classId, {String? status});

  // ==================== Groups ====================

  /// Tạo nhóm học tập mới trong lớp.
  /// Trả về Group đã được tạo.
  /// Ném ra Exception nếu thất bại.
  Future<Group> createGroup(CreateGroupParams params);

  /// Lấy danh sách nhóm học tập trong lớp.
  /// Trả về danh sách Group, có thể rỗng.
  Future<List<Group>> getGroupsByClass(String classId);

  /// Thêm học sinh vào nhóm.
  /// Ném ra Exception nếu học sinh đã ở trong nhóm hoặc thất bại.
  Future<void> addStudentToGroup(String groupId, String studentId);

  /// Xóa học sinh khỏi nhóm.
  /// Ném ra Exception nếu không tìm thấy hoặc thất bại.
  Future<void> removeStudentFromGroup(String groupId, String studentId);

  /// Lấy danh sách thành viên nhóm.
  /// Trả về danh sách GroupMember, có thể rỗng.
  Future<List<GroupMember>> getGroupMembers(String groupId);

  // ==================== Class Settings ====================

  /// Cập nhật toàn bộ class_settings.
  /// Merge settings mới với settings cũ (không ghi đè toàn bộ).
  /// Trả về Class đã được cập nhật.
  Future<Class> updateClassSettings(
    String classId,
    Map<String, dynamic> settings,
  );

  /// Cập nhật một setting cụ thể theo path (ví dụ: 'defaults.lock_class').
  /// Merge nested settings, không ghi đè toàn bộ.
  /// Trả về Class đã được cập nhật.
  Future<Class> updateClassSetting(String classId, String path, dynamic value);

  /// Kiểm tra xem join code đã tồn tại trong database chưa.
  /// [joinCode] - Mã join cần kiểm tra.
  /// [excludeClassId] - Class ID cần loại trừ khỏi việc kiểm tra (class hiện tại).
  /// Trả về true nếu code đã tồn tại, false nếu chưa.
  Future<bool> checkJoinCodeExists(String joinCode, {String? excludeClassId});
}

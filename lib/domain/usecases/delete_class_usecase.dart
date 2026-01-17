import 'package:ai_mls/domain/repositories/school_class_repository.dart';

/// Use case để xóa lớp học
/// Giảm coupling giữa UI và business logic
class DeleteClassUseCase {
  final SchoolClassRepository repository;

  DeleteClassUseCase({required this.repository});

  /// Xóa lớp học theo ID
  /// Throw exception nếu xóa thất bại
  Future<void> call(String classId) async {
    print('🟢 [UseCase] DeleteClassUseCase: Bắt đầu xóa lớp $classId');

    try {
      await repository.deleteClass(classId);
      print('✅ [UseCase] DeleteClassUseCase: Xóa thành công');
    } catch (e) {
      print('🔴 [UseCase] DeleteClassUseCase: Lỗi - $e');
      rethrow;
    }
  }
}

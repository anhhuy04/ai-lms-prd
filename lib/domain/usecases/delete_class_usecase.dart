import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';

/// Use case để xóa lớp học
/// Giảm coupling giữa UI và business logic
class DeleteClassUseCase {
  final SchoolClassRepository repository;

  DeleteClassUseCase({required this.repository});

  /// Xóa lớp học theo ID
  /// Throw exception nếu xóa thất bại
  Future<void> call(String classId) async {
    AppLogger.debug('🟢 [UseCase] DeleteClassUseCase: Bắt đầu xóa lớp $classId');

    try {
      await repository.deleteClass(classId);
      AppLogger.info('✅ [UseCase] DeleteClassUseCase: Xóa thành công');
    } catch (e) {
      AppLogger.error('🔴 [UseCase] DeleteClassUseCase: Lỗi - $e', error: e);
      rethrow;
    }
  }
}

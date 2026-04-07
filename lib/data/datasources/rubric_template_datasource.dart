import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';

/// Datasource cho rubric template CRUD.
///
/// Lưu trữ rubric templates trong `profiles.metadata['saved_rubrics']`
/// thông qua [ProfileMetadataService]. Không tạo bảng Supabase mới (per D-05).
///
/// Mỗi entry trong danh sách có format:
/// ```json
/// { "name": "Tên template", "rubric": { ... } }
/// ```
class RubricTemplateDatasource {
  RubricTemplateDatasource._();

  static const String _key = 'saved_rubrics';

  /// Lấy danh sách rubric templates đã lưu của giáo viên hiện tại.
  ///
  /// Returns: Danh sách entries `{ "name": "...", "rubric": {...} }`.
  /// Returns rỗng nếu chưa có template nào hoặc xảy ra lỗi.
  static Future<List<Map<String, dynamic>>> getSavedRubrics() async {
    try {
      final metadata = await ProfileMetadataService.getMetadata();
      if (metadata == null) return [];

      final savedRubrics = metadata[_key];
      if (savedRubrics == null || savedRubrics is! List) return [];

      return List<Map<String, dynamic>>.from(
        savedRubrics.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } catch (e) {
      AppLogger.error(
        '❌ [RubricTemplateDatasource] Error getting saved rubrics: $e',
        error: e,
      );
      return [];
    }
  }

  /// Lưu một rubric mới vào danh sách templates.
  ///
  /// [name] - Tên template (không được trống).
  /// [rubric] - JSON object chứa cấu trúc rubric.
  ///
  /// Returns: `true` nếu lưu thành công.
  static Future<bool> saveRubricTemplate(
    String name,
    Map<String, dynamic> rubric,
  ) async {
    if (name.trim().isEmpty) return false;

    try {
      final currentList = await getSavedRubrics();
      final newEntry = <String, dynamic>{
        'name': name.trim(),
        'rubric': rubric,
      };
      currentList.add(newEntry);

      final result = await ProfileMetadataService.set(_key, currentList);
      if (result) {
        AppLogger.info(
          '✅ [RubricTemplateDatasource] Saved rubric template: $name',
        );
      }
      return result;
    } catch (e) {
      AppLogger.error(
        '❌ [RubricTemplateDatasource] Error saving rubric template "$name": $e',
        error: e,
      );
      return false;
    }
  }

  /// Xóa rubric template tại vị trí [index] trong danh sách.
  ///
  /// [index] - Chỉ số trong danh sách (0-based).
  ///
  /// Returns: `true` nếu xóa thành công, `false` nếu index nằm ngoài phạm vi.
  static Future<bool> deleteRubricTemplate(int index) async {
    try {
      final currentList = await getSavedRubrics();
      if (index < 0 || index >= currentList.length) return false;

      currentList.removeAt(index);

      final result = await ProfileMetadataService.set(_key, currentList);
      if (result) {
        AppLogger.info(
          '✅ [RubricTemplateDatasource] Deleted rubric template at index $index',
        );
      }
      return result;
    } catch (e) {
      AppLogger.error(
        '❌ [RubricTemplateDatasource] Error deleting rubric template at index $index: $e',
        error: e,
      );
      return false;
    }
  }
}

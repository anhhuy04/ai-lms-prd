import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';

/// Script để lấy 5 bản ghi mới nhất trong bảng profiles
Future<void> main() async {
  try {
    // Khởi tạo Supabase
    await SupabaseService.initialize();
    AppLogger.info('✅ Đã kết nối Supabase thành công');

    // Tạo data source cho bảng profiles
    final profileDataSource = BaseTableDataSource(
      SupabaseService.client,
      'profiles',
    );

    // Lấy 5 bản ghi mới nhất (sắp xếp theo created_at giảm dần)
    final latestProfiles = await profileDataSource.getPaginated(
      page: 1,
      pageSize: 5,
      orderBy: 'created_at',
      ascending: false, // false = giảm dần (mới nhất trước)
    );

    AppLogger.info('\n📊 5 BẢN GHI MỚI NHẤT TRONG BẢNG PROFILES:');
    AppLogger.info('=' * 80);

    if (latestProfiles.isEmpty) {
      AppLogger.warning('❌ Không có dữ liệu trong bảng profiles');
      return;
    }

    for (int i = 0; i < latestProfiles.length; i++) {
      final profile = latestProfiles[i];
      AppLogger.info('\n${i + 1}. Profile ID: ${profile['id']}');
      AppLogger.info('   👤 Tên: ${profile['full_name'] ?? 'N/A'}');
      AppLogger.info('   📧 Email: ${profile['email'] ?? 'N/A'}');
      AppLogger.info('   🎭 Vai trò: ${profile['role'] ?? 'N/A'}');
      AppLogger.info('   📱 SĐT: ${profile['phone'] ?? 'N/A'}');
      AppLogger.info('   ⚧ Giới tính: ${profile['gender'] ?? 'N/A'}');
      AppLogger.info('   🖼️ Avatar: ${profile['avatar_url'] ?? 'N/A'}');
      AppLogger.info('   📅 Tạo lúc: ${profile['created_at'] ?? 'N/A'}');
      AppLogger.info('   🔄 Cập nhật: ${profile['updated_at'] ?? 'N/A'}');
      AppLogger.info('-' * 40);
    }

    AppLogger.info('\n✅ Hoàn thành! Đã lấy ${latestProfiles.length} bản ghi.');

  } catch (e) {
    AppLogger.error('❌ Lỗi khi lấy dữ liệu: $e', error: e);
    AppLogger.error('Chi tiết lỗi: ${e.toString()}');
  }
}

import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';

/// Script để lấy 5 bản ghi mới nhất trong bảng profiles
Future<void> main() async {
  try {
    // Khởi tạo Supabase
    await SupabaseService.initialize();
    print('✅ Đã kết nối Supabase thành công');

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

    print('\n📊 5 BẢN GHI MỚI NHẤT TRONG BẢNG PROFILES:');
    print('=' * 80);

    if (latestProfiles.isEmpty) {
      print('❌ Không có dữ liệu trong bảng profiles');
      return;
    }

    for (int i = 0; i < latestProfiles.length; i++) {
      final profile = latestProfiles[i];
      print('\n${i + 1}. Profile ID: ${profile['id']}');
      print('   👤 Tên: ${profile['full_name'] ?? 'N/A'}');
      print('   📧 Email: ${profile['email'] ?? 'N/A'}');
      print('   🎭 Vai trò: ${profile['role'] ?? 'N/A'}');
      print('   📱 SĐT: ${profile['phone'] ?? 'N/A'}');
      print('   ⚧ Giới tính: ${profile['gender'] ?? 'N/A'}');
      print('   🖼️ Avatar: ${profile['avatar_url'] ?? 'N/A'}');
      print('   📅 Tạo lúc: ${profile['created_at'] ?? 'N/A'}');
      print('   🔄 Cập nhật: ${profile['updated_at'] ?? 'N/A'}');
      print('-' * 40);
    }

    print('\n✅ Hoàn thành! Đã lấy ${latestProfiles.length} bản ghi.');

  } catch (e) {
    print('❌ Lỗi khi lấy dữ liệu: $e');
    print('Chi tiết lỗi: ${e.toString()}');
  }
}

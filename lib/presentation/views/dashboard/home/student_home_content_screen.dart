
import 'package:ai_mls/presentation/viewmodels/student_dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/ui_constants.dart';
import 'package:provider/provider.dart';

/// Widget này chỉ chứa phần nội dung có thể cuộn của trang chủ sinh viên.
class StudentHomeContentScreen extends StatelessWidget {
  const StudentHomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = Provider.of<StudentDashboardViewModel>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () => dashboardViewModel.refresh(),
      child: Stack(
        children: [
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, AppSizes.p32 + 80), // Thêm đệm dưới
            children: [
              // Header được hiển thị ở AppBar, nên phần này bắt đầu ngay với nội dung
              _buildProgressCard(context),
              const SizedBox(height: AppSizes.p24),
              _buildStatsRow(context),
              const SizedBox(height: AppSizes.p32),
              _buildSectionHeader('Sắp đến hạn', actionLabel: 'Xem tất cả'),
              const SizedBox(height: AppSizes.p12),
              _buildDueList(context),
              const SizedBox(height: AppSizes.p32),
              _buildSectionHeader('Điểm số mới nhất'),
              const SizedBox(height: AppSizes.p12),
              _buildScoresList(context),
            ],
          ),
          // Consumer chỉ để hiển thị trạng thái loading/error
          Consumer<StudentDashboardViewModel>(
            builder: (context, vm, _) {
              if (vm.isRefreshing) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.refreshError != null) {
                return Center(
                  child: Text('Lỗi: ${vm.refreshError}'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // --- Các hàm build giao diện con cho nội dung ---

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tiến độ tuần này', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rất tốt! 🚀', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const Text('85%', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: const LinearProgressIndicator(
            value: 0.85,
            minHeight: 12,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('Còn 3 bài tập để hoàn thành mục tiêu', style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.check_circle_outline, 'Đã nộp', '12', Colors.green)),
        const SizedBox(width: AppSizes.p16),
        Expanded(child: _buildStatCard(Icons.hourglass_top_outlined, 'Chờ chấm', '3', Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSizes.p12),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 2),
        SizedBox(
          height: 32,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: Text(actionLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildDueList(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: [
          _buildDueCard('Đại số Chương 3', 'Toán học • Cô Lan', 'Còn 2 giờ', const Color(0xFFE3F2FD)),
          const SizedBox(width: AppSizes.p16),
          _buildDueCard('Phân tích bài thơ', 'Văn học • Thầy Hùng', 'Hôm nay, 20:00', const Color(0xFFFFF3E0)),
          const SizedBox(width: AppSizes.p16),
          _buildDueCard('Thí nghiệm quang hợp', 'Sinh học • Cô Mai', 'Ngày mai', const Color(0xFFE8F5E9)),
        ],
      ),
    );
  }

  Widget _buildDueCard(String title, String subtitle, String time, Color color) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.timer_outlined, color: Colors.grey.shade600, size: 20),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.p12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Text(time, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildScoresList(BuildContext context) {
    return Column(
      children: [
        _buildScoreTile(Icons.history_edu_outlined, 'Lịch sử Thế giới', 'Kiểm tra 15 phút', '9.5'),
        const SizedBox(height: AppSizes.p12),
        _buildScoreTile(Icons.translate_outlined, 'Tiếng Anh', 'Bài tập Reading', '8.0'),
      ],
    );
  }

  Widget _buildScoreTile(IconData icon, String title, String subtitle, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.yellow.shade100.withOpacity(0.5), child: Icon(icon, color: Colors.orange.shade700)),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 22)),
              const Text('/10', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

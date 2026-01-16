
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/ui_constants.dart';

/// Widget này chỉ chứa phần nội dung có thể cuộn của trang chủ giáo viên.
class TeacherHomeContentScreen extends StatelessWidget {
  const TeacherHomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu - sau này sẽ được thay thế bằng ViewModel
    final quickStats = [
      {'icon': Icons.assignment_turned_in, 'label': 'Bài tập đang mở: 3', 'color': AppColors.primary},
      {'icon': Icons.groups, 'label': 'Tổng học sinh: 120', 'color': Colors.blue.shade500},
      {'icon': Icons.school, 'label': 'Lớp chủ nhiệm: 10A', 'color': Colors.indigo.shade500},
    ];

    return Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: AppSizes.p16), // Thêm khoảng trống ở trên
            _buildQuickStats(quickStats),
            const SizedBox(height: AppSizes.p16),
            _buildPriorityCard(context),
            const SizedBox(height: AppSizes.p24),
            _buildSectionHeader('Lớp học của tôi', 'Xem tất cả'),
            const SizedBox(height: AppSizes.p12),
            _buildClassList(),
            const SizedBox(height: AppSizes.p24),
            _buildSectionHeader('Bài tập sắp hết hạn', 'Xem lịch'),
            const SizedBox(height: AppSizes.p12),
            _buildUpcomingAssignments(),
            const SizedBox(height: 80), // Đệm dưới cùng
            ],
        ),
        ),
    );
    }

  // --- Các hàm build giao diện con cho nội dung ---

    Widget _buildQuickStats(List<Map<String, dynamic>> stats) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Để shadow không bị cắt
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Chip(
            avatar: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 18),
            label: Text(stat['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.p24),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
          );
        },
      ),
    );
  }

    Widget _buildPriorityCard(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(AppSizes.p20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Row(
            children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                                const SizedBox(width: 8),
                                const Text('ƯU TIÊN', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ]),
                            const SizedBox(height: 8),
                            const Text('Bài tập cần chấm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            RichText(
                                text: TextSpan(
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontFamily: 'Lexend'),
                                    children: const [
                                        TextSpan(text: 'Bạn có '),
                                        TextSpan(text: '12', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                        TextSpan(text: ' bài nộp đang chờ duyệt.'),
                                    ]
                                ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle, size: 20),
                                label: const Text('Chấm ngay'),
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    elevation: 5,
                                    shadowColor: AppColors.primary.withOpacity(0.3),
                                ),
                            )
                        ],
                    ),
                ),
                const SizedBox(width: 16),
                Container(
                    width: 120,
                    height: 140,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA45_xZRsDy6Jm2gT5nx3zmyuQzfpAULGoBH6EJrZwU9cHELNFm6-PrGgDHtDwiH_p_tvS1utjvKkEbTl8Md2Y1DkXwXmS4LnHuNK4Dmd320ix9yse19hA-jdpj3un6wbsVWMaOrjz5i6bzv0jDLTK_7RykfJqEmNWO0oMHM1rT_ZlRycefHkybScXcKD9Eqzj3iGuNq2mRdGLLGk9DzH9r-r2JMLk0Klg0r-IQ6I3mRC4ek65KqP-_MQAWdwLaeSTYhwsI_oCO2w'),
                            fit: BoxFit.cover,
                        )
                    ),
                )
            ],
        ),
    );
  }

    Widget _buildSectionHeader(String title, String actionText) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text(actionText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)))
            ],
        );
    }

    Widget _buildClassList() {
        return Column(
            children: [
                _buildClassTile('10A', 'Toán Học 10A', '35 Học sinh • Phòng B201', '5 bài chưa chấm', Colors.orange, const LinearGradient(colors: [Colors.orange, Colors.pink])),
                const SizedBox(height: 12),
                _buildClassTile('11B', 'Toán Học 11B', '32 Học sinh • Phòng A105', '2 bài chưa chấm', Colors.blue, const LinearGradient(colors: [Colors.blue, Colors.cyan])),
            ],
        );
    }

    Widget _buildClassTile(String grade, String name, String details, String status, Color statusColor, Gradient gradient) {
        return Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: Colors.grey.shade200), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]
            ),
            child: Row(
                children: [
                    Container(
                        width: 48, height: 48, 
                        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Center(child: Text(grade, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(details, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                const SizedBox(height: 8),
                                Chip(
                                    label: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)), 
                                    backgroundColor: statusColor.withOpacity(0.1), 
                                    side: BorderSide(color: statusColor.withOpacity(0.2)),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                )
                            ],
                        )
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400)
                ],
            ),
        );
    }
    
    Widget _buildUpcomingAssignments() {
      return Column(
        children: [
          _buildAssignmentTile('T6', '24', 'Kiểm tra 15 phút - Đại số', 'Lớp 10A', '30/35 đã nộp', 'Còn 2h', Colors.red),
          const SizedBox(height: 12),
          _buildAssignmentTile('T7', '25', 'Bài tập về nhà - Hình học', 'Lớp 11B', '12/32 đã nộp', 'Ngày mai', Colors.orange),
        ],
      );
    }

    Widget _buildAssignmentTile(String dayOfWeek, String day, String title, String className, String submissionStatus, String time, Color timeColor) {
        return Container(
            padding: const EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: Colors.grey.shade200), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]
            ),
            child: Row(
                children: [
                    Container(
                        width: 48, height: 48, 
                        decoration: BoxDecoration(color: timeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: timeColor.withOpacity(0.2))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayOfWeek, style: TextStyle(color: timeColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            Text(day, style: TextStyle(color: timeColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                          ],
                        )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                    Chip(label: Text(time, style: TextStyle(color: timeColor, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: timeColor.withOpacity(0.1), padding: EdgeInsets.zero, labelPadding: const EdgeInsets.symmetric(horizontal: 8)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(label: Text(className, style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Colors.grey.shade100, side: BorderSide.none, padding: EdgeInsets.zero, labelPadding: const EdgeInsets.symmetric(horizontal: 6)),
                                    const SizedBox(width: 4), 
                                    const Text('•', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(width: 4),
                                    Text(submissionStatus, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                )
                            ],
                        )
                    ),
                ],
            ),
        );
    }
}

import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/views/dashboard/home/teacher_home_content_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/views/assignment/assignment_list_screen.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../widgets/smart_marquee_text.dart';

/// Màn hình này đóng vai trò là "Layout" hoặc "Khung" chính cho Giáo viên.
class TeacherDashboardScreen extends StatefulWidget {
  final Profile userProfile;

  const TeacherDashboardScreen({super.key, required this.userProfile});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Trang 0: Nội dung trang chủ của giáo viên
      const TeacherHomeContentScreen(),
      // Trang 1: Placeholder cho trang Bài tập của giáo viên
      const AssignmentListScreen(),
      // Trang 2: Placeholder cho trang Lớp học của giáo viên
      const TeacherClassListScreen(),
      // Trang 3: Trang Hồ sơ cá nhân (tái sử dụng)
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // allow content to extend behind bottom bar for shadow
      backgroundColor: DesignColors.moonLight, // Nền xám nhẹ như yêu cầu
      // Show AppBar only on home tab (index 0) — match student layout
      appBar: _selectedIndex == 0
          ? AppBar(
              toolbarHeight: DesignComponents.appBarHeight,
              automaticallyImplyLeading: false,
              backgroundColor: DesignColors.moonLight, // Nền xám nhẹ
              elevation: 0,
              title: Consumer<AuthViewModel>(
                builder: (context, authViewModel, _) {
                  final latestProfile =
                      authViewModel.userProfile ?? widget.userProfile;
                  return _buildHeader(context, latestProfile);
                },
              ),
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: DesignColors.primary,
        child: const Icon(Icons.add, size: DesignIcons.mdSize),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context, Profile profile) {
    return Row(
      children: [
        _UserProfileAvatar(profile: profile),
        SizedBox(width: DesignSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chào giáo viên,',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: DesignSpacing.xs),
              SmartMarqueeText(
                text: profile.fullName ?? 'Giáo viên',
                style: DesignTypography.titleLarge,
              ),
            ],
          ),
        ),
        SizedBox(width: DesignSpacing.md),
        Container(
          width: DesignComponents.avatarMedium,
          height: DesignComponents.avatarMedium,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
            color: DesignColors.primary,
          ),
        ),
      ],
    );
  }

  // Replace bottom bar with student's style: flush, top-only shadow, FAB notch support

  Widget _buildBottomBar() {
    // Container cung cấp top-only shadow (offset y âm) để bóng chiếu lên trên
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // (tuỳ chọn) bo góc ở phía trên nếu muốn shadow mềm hơn
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [DesignElevation.level3],
      ),
      child: ClipRRect(
        // đảm bảo borderRadius cắt đúng cho nội dung
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          height: DesignComponents.bottomNavHeight,
          shape: const CircularNotchedRectangle(), // giữ notch nếu dùng FAB
          notchMargin: 8.0,
          elevation: 0, // tắt elevation gốc để chỉ dùng shadow của Container
          color: Colors.transparent,
          child: SizedBox(
            height: 65, // chỉnh chiều cao bar nếu cần
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 0,
                ),
                _buildBottomBarItem(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'Bài tập',
                  index: 1,
                ),
                const SizedBox(width: 40), // space for FAB (notch)
                _buildBottomBarItem(
                  icon: Icons.school_outlined,
                  label: 'Lớp học',
                  index: 2,
                ),
                _buildBottomBarItem(
                  icon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _selectedIndex == index;
    final Color color = isActive ? DesignColors.primary : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: DesignColors.primary.withAlpha((0.1 * 255).round()),
      highlightColor: DesignColors.primary.withAlpha((0.05 * 255).round()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  final Profile profile;
  const _UserProfileAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    // Build avatar safely: only load network image when URL is non-empty
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;
    final initials = (profile.fullName?.isNotEmpty ?? false)
        ? profile.fullName![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: DesignComponents.avatarMedium / 2, // 20 = 40dp diameter
      backgroundColor: DesignColors.primary.withOpacity(0.1),
      backgroundImage: hasAvatar ? NetworkImage(profile.avatarUrl!) : null,
      child: !hasAvatar
          ? Text(
              initials,
              style: const TextStyle(
                fontSize: 22,
                color: DesignColors.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/assignment/student/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/class/student/student_class_list_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/student_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/widgets/dashboard_top_bar.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/design_tokens.dart';
import '../../../core/routes/route_constants.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  final Profile userProfile;
  final Widget? child; // For ShellRoute support

  const StudentDashboardScreen({
    super.key,
    required this.userProfile,
    this.child,
  });

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Cache pages list
  static final List<Widget> _pages = [
    const StudentHomeContentScreen(), // 0
    const StudentClassListScreen(), // 1
    const AssignmentListScreen(), // 2
    const ScoresScreen(), // 3
    const ProfileScreen(), // 4
  ];

  // Cache routes map for ShellRoute navigation
  static final List<String> _routes = [
    AppRoute.studentDashboardPath, // 0: Home
    AppRoute.studentClassListPath, // 1: Classes
    AppRoute.studentAssignmentListPath, // 2: Assignments
    AppRoute.studentScoresPath, // 3: Scores
    AppRoute.studentProfilePath, // 4: Profile
  ];

  // Cache route-to-index map for faster lookup
  static final Map<String, int> _routeIndexMap = {
    AppRoute.studentDashboardPath: 0,
    AppRoute.studentClassListPath: 1,
    AppRoute.studentAssignmentListPath: 2,
    AppRoute.studentScoresPath: 3,
    AppRoute.studentProfilePath: 4,
  };

  int _getSelectedIndexFromRoute(BuildContext context) {
    if (widget.child == null) {
      return _selectedIndex; // Legacy mode
    }

    // ShellRoute mode: determine index from current route
    try {
      final location = GoRouterState.of(context).matchedLocation;
      return _routeIndexMap[location] ?? 0;
    } catch (_) {
      return _selectedIndex; // Fallback
    }
  }

  void _onItemTapped(int index) {
    if (widget.child != null) {
      // ShellRoute mode: navigate to route
      if (index < _routes.length) {
        context.go(_routes[index]);
      }
    } else {
      // Legacy mode: update state
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSelectedIndex = _getSelectedIndexFromRoute(context);
    final isShellRoute = widget.child != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide =
        MediaQuery.of(context).size.width >= DesignBreakpoints.tabletSmall;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: !isWide,
        body: isWide
            ? _buildWideLayout(currentSelectedIndex, isShellRoute)
            : _buildMobileLayout(currentSelectedIndex, isShellRoute),
        bottomNavigationBar:
            isWide ? null : _buildBottomBar(currentSelectedIndex),
      ),
    );
  }

  /// Layout mobile: tab Home (0) là content thuần nên shell cấp DashboardTopBar
  /// để đồng bộ tiêu đề với teacher. Các tab khác đã có AppBar riêng → chỉ bọc
  /// SafeArea, tránh double-header.
  Widget _buildMobileLayout(int currentIdx, bool isShellRoute) {
    final content = isShellRoute
        ? widget.child!
        : IndexedStack(index: _selectedIndex, children: _pages);

    if (currentIdx == 0) {
      return Column(
        children: [
          DashboardTopBar(
            title: 'Trang chủ',
            // Mobile không có sidebar (PC mới có) → nhúng tên vào lời chào để hiện tên.
            subtitle: (widget.userProfile.fullName?.isNotEmpty ?? false)
                ? 'Chào mừng trở lại, ${widget.userProfile.fullName}!'
                : 'Chào mừng trở lại!',
            profile: widget.userProfile,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () {},
                tooltip: 'Thông báo',
              ),
            ],
          ),
          Expanded(child: content),
        ],
      );
    }

    return SafeArea(
      top: true,
      bottom: false,
      minimum: EdgeInsets.zero,
      child: content,
    );
  }

  /// Layout màn rộng: sidebar điều hướng trái + nội dung phải. Mỗi màn content
  /// tự quản header (giữ hành vi như mobile, tránh double-header).
  Widget _buildWideLayout(int currentIdx, bool isShellRoute) {
    final content = isShellRoute
        ? widget.child!
        : IndexedStack(index: _selectedIndex, children: _pages);

    return Row(
      children: [
        _StudentWideNavSidebar(
          selectedIndex: currentIdx,
          onItemTapped: _onItemTapped,
          userProfile: widget.userProfile,
        ),
        Container(width: 1, color: DesignColors.dividerLight),
        // Tab Home (0) chưa có AppBar riêng → thêm DashboardTopBar (title +
        // subtitle). Các tab khác đã có AppBar riêng nên chỉ bọc SafeArea.
        Expanded(
          child: currentIdx == 0
              ? Column(
                  children: [
                    DashboardTopBar(
                      title: 'Trang chủ',
                      subtitle: 'Chào mừng trở lại!',
                      profile: widget.userProfile,
                      showAvatar: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              size: 22),
                          onPressed: () {},
                          tooltip: 'Thông báo',
                        ),
                      ],
                    ),
                    Expanded(child: content),
                  ],
                )
              : SafeArea(top: true, bottom: false, child: content),
        ),
      ],
    );
  }

  Widget _buildBottomBar(int currentSelectedIndex) {
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
            height: DesignComponents.bottomNavHeight, // 56dp
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarItem(
                  activeIcon: Icons.home,
                  inactiveIcon: Icons.home_outlined,
                  label: 'Trang chủ',
                  index: 0,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.class_,
                  inactiveIcon: Icons.class_outlined,
                  label: 'Lớp học',
                  index: 1,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.assignment,
                  inactiveIcon: Icons.assignment_outlined,
                  label: 'Bài tập',
                  index: 2,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.leaderboard,
                  inactiveIcon: Icons.leaderboard_outlined,
                  label: 'Điểm số',
                  index: 3,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.person,
                  inactiveIcon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 4,
                  currentSelectedIndex: currentSelectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int index,
    required int currentSelectedIndex,
  }) {
    final isActive = currentSelectedIndex == index;
    final color = isActive ? DesignColors.primary : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      splashColor: DesignColors.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? DesignColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wide Navigation Sidebar (màn rộng) ──────────────────────────────────────
/// Thanh menu điều hướng bên trái cho học sinh trên màn rộng (tablet/web/
/// desktop). Avatar header + 5 tab, highlight tab đang chọn bằng tint primary.
class _StudentWideNavSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Profile userProfile;

  const _StudentWideNavSidebar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.userProfile,
  });

  static const _items = [
    _SidebarItem(
      activeIcon: Icons.home,
      inactiveIcon: Icons.home_outlined,
      label: 'Trang chủ',
    ),
    _SidebarItem(
      activeIcon: Icons.class_,
      inactiveIcon: Icons.class_outlined,
      label: 'Lớp học',
    ),
    _SidebarItem(
      activeIcon: Icons.assignment,
      inactiveIcon: Icons.assignment_outlined,
      label: 'Bài tập',
    ),
    _SidebarItem(
      activeIcon: Icons.leaderboard,
      inactiveIcon: Icons.leaderboard_outlined,
      label: 'Điểm số',
    ),
    _SidebarItem(
      activeIcon: Icons.person,
      inactiveIcon: Icons.person_outline,
      label: 'Cá nhân',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final name = userProfile.fullName ?? 'Học sinh';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        DesignColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chào bạn,',
                          style: TextStyle(
                            color: DesignColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: DesignColors.dividerLight),
          const SizedBox(height: DesignSpacing.sm),
          for (int i = 0; i < _items.length; i++)
            _buildNavItem(context, _items[i], i),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _SidebarItem item, int index) {
    final isActive = selectedIndex == index;
    final color =
        isActive ? DesignColors.primary : DesignColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 2,
      ),
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? DesignColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.inactiveIcon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _SidebarItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

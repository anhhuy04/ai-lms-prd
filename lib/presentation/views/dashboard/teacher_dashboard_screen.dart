import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/providers/teacher_ai_queue_provider.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_list_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/teacher_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/widgets/dashboard_top_bar.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/design_tokens.dart';
import '../../../presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart';

/// Màn hình này đóng vai trò là "Layout" hoặc "Khung" chính cho Giáo viên.
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  final Profile userProfile;
  final int initialTab;
  final Widget? child; // For ShellRoute support

  const TeacherDashboardScreen({
    super.key,
    required this.userProfile,
    this.initialTab = 0,
    this.child,
  });

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  late int _selectedIndex;

  // Cache pages list
  static final List<Widget> _pages = [
    const TeacherHomeContentScreen(), // 0
    const TeacherAssignmentHubScreen(), // 1
    const TeacherClassListScreen(), // 2
    const ProfileScreen(), // 3
  ];

  // Cache routes for ShellRoute navigation
  static final List<String> _routes = [
    AppRoute.teacherDashboardPath, // 0: Home
    AppRoute.teacherAssignmentHubPath, // 1: Assignments
    AppRoute.teacherClassListPath, // 2: Classes
    AppRoute.teacherProfilePath, // 3: Profile
  ];

  // Cache route-to-index map for faster lookup
  static final Map<String, int> _routeIndexMap = {
    AppRoute.teacherDashboardPath: 0,
    AppRoute.teacherAssignmentHubPath: 1,
    AppRoute.teacherClassListPath: 2,
    AppRoute.teacherProfilePath: 3,
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    // Khởi động AI queue watcher ngầm (Ollama → Groq fallback)
    // Dùng addPostFrameCallback để tránh gọi ref trong initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherAiQueueWatcherProvider);
    });
    // Đặt status bar trong suốt hoàn toàn như FB, TikTok
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

  @override
  void dispose() {
    // Không cần reset vì sẽ áp dụng cho toàn app
    super.dispose();
  }

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

  static const _titles = [
    'Trang chủ',
    'Bài tập',
    'Lớp học',
    'Cá nhân',
  ];

  static const _subtitles = [
    'Chào mừng trở lại!',
    'Quản lý bài tập',
    'Lớp học của tôi',
    'Thông tin tài khoản',
  ];

  @override
  Widget build(BuildContext context) {
    final currentSelectedIndex = _getSelectedIndexFromRoute(context);
    final isShellRoute = widget.child != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= DesignBreakpoints.tabletSmall;

    // Trang Profile đã có AppBar riêng — không cần DashboardTopBar
    final showTopBar = !isWide && currentSelectedIndex != 3;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: DesignColors.moonLight,
        extendBody: !isWide,
        body: isWide
            ? _buildWideLayout(context, currentSelectedIndex, isShellRoute)
            : _buildMobileLayout(
                context, currentSelectedIndex, isShellRoute, showTopBar),
        bottomNavigationBar:
            isWide ? null : _buildBottomBar(currentSelectedIndex),
      ),
    );
  }

  /// Layout mobile: SafeArea + DashboardTopBar + content
  Widget _buildMobileLayout(
    BuildContext context,
    int currentIdx,
    bool isShellRoute,
    bool showTopBar,
  ) {
    final content = isShellRoute
        ? widget.child!
        : IndexedStack(index: _selectedIndex, children: _pages);

    if (!showTopBar) {
      return SafeArea(
        top: false,
        bottom: false,
        child: content,
      );
    }

    return Column(
      children: [
        // Shared top bar — tự handle topPadding bên trong
        DashboardTopBar(
          title: _titles[currentIdx],
          // Mobile không có sidebar (PC mới có) → tab Home nhúng tên vào lời chào.
          subtitle: currentIdx == 0 &&
                  (widget.userProfile.fullName?.isNotEmpty ?? false)
              ? 'Chào mừng trở lại, ${widget.userProfile.fullName}!'
              : _subtitles[currentIdx],
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

  /// Layout 2 cột: sidebar cố định bên trái + content area bên phải.
  Widget _buildWideLayout(
      BuildContext context, int currentIdx, bool isShellRoute) {
    
    Widget content = isShellRoute
        ? widget.child!
        : IndexedStack(index: _selectedIndex, children: _pages);

    return Row(
      children: [
        // ── Sidebar ────────────────────────────────────────────────────────
        _WideNavSidebar(
          selectedIndex: currentIdx,
          onItemTapped: _onItemTapped,
          userProfile: widget.userProfile,
        ),

        // ── Divider ────────────────────────────────────────────────────────
        Container(width: 1, color: DesignColors.dividerLight),

        // ── Main Content ───────────────────────────────────────────────────
        Expanded(
          child: currentIdx != 3
              ? Column(
                  children: [
                    DashboardTopBar(
                      title: _titles[currentIdx],
                      subtitle: _subtitles[currentIdx],
                      profile: widget.userProfile,
                      showAvatar: false, // Sidebar đã có avatar
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
                )
              : content, // ProfileScreen tự render TopBar của nó
        ),
      ],
    );
  }


  Widget _buildBottomBar(int currentSelectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [DesignElevation.level3],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          height: DesignComponents.bottomNavHeight,
          elevation: 0,
          color: Colors.transparent,
          child: SizedBox(
            height: DesignComponents.bottomNavHeight,
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
                  activeIcon: Icons.assignment_turned_in,
                  inactiveIcon: Icons.assignment_turned_in_outlined,
                  label: 'Bài tập',
                  index: 1,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.school,
                  inactiveIcon: Icons.school_outlined,
                  label: 'Lớp học',
                  index: 2,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  activeIcon: Icons.person,
                  inactiveIcon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 3,
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

// ── Wide Navigation Sidebar ───────────────────────────────────────────────────
class _WideNavSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Profile userProfile;

  const _WideNavSidebar({
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
      activeIcon: Icons.assignment_turned_in,
      inactiveIcon: Icons.assignment_turned_in_outlined,
      label: 'Bài tập',
    ),
    _SidebarItem(
      activeIcon: Icons.school,
      inactiveIcon: Icons.school_outlined,
      label: 'Lớp học',
    ),
    _SidebarItem(
      activeIcon: Icons.person,
      inactiveIcon: Icons.person_outline,
      label: 'Cá nhân',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final name = userProfile.fullName ?? 'Giáo viên';
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile header ────────────────────────────────────────────
          Padding(
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
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chào giáo viên,',
                          style: TextStyle(
                              color: DesignColors.textSecondary,
                              fontSize: 11)),
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: DesignColors.dividerLight),
          const SizedBox(height: DesignSpacing.sm),

          // ── Nav items ─────────────────────────────────────────────────
          for (int i = 0; i < _items.length; i++)
            _buildNavItem(context, _items[i], i),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, _SidebarItem item, int index) {
    final isActive = selectedIndex == index;
    final color =
        isActive ? DesignColors.primary : DesignColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm, vertical: 2),
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
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
                    fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.w500,
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

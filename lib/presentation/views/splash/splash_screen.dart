import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash screen using reactive Riverpod state with animated logo
///
/// Instead of manually checking auth and navigating, this screen watches the
/// authNotifierProvider. The router automatically redirects based on auth state.
/// This prevents the infinite loop caused by manual navigation attempts.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  bool _isTimeoutExceeded = false;
  late DateTime _startTime;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // 3 giây animation mặc định
    _scheduleMinAnimation();

    // 10 giây timeout cho network
    _scheduleNetworkTimeout();
  }

  /// Đợi tối thiểu 3 giây để animation hoàn thành
  void _scheduleMinAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (kDebugMode) {
        AppLogger.info('🟢 Animation complete - Ready to navigate');
      }
      _navigateIfReady();
    });
  }

  /// Nếu sau 10 giây vẫn không kết nối được, hiển thị no internet
  void _scheduleNetworkTimeout() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (kDebugMode) {
        AppLogger.error('🔴 Network timeout - No internet after 10s');
      }
      if (mounted) {
        setState(() {
          _isTimeoutExceeded = true;
        });
      }
    });
  }

  /// Điều hướng khi đủ điều kiện
  void _navigateIfReady() {
    if (!mounted || _didNavigate) return;

    final authState = ref.read(authNotifierProvider);
    authState.whenData((profile) {
      if (!mounted || _didNavigate) return;
      _didNavigate = true;

      if (profile == null) {
        if (kDebugMode) {
          AppLogger.info('🟡 Navigating to LOGIN (no profile)');
        }
        context.goNamed(AppRoute.login);
      } else {
        if (kDebugMode) {
          AppLogger.info('🟡 Navigating to dashboard (role: ${profile.role})');
        }
        context.go(AppRoute.getDashboardPathForRole(profile.role));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Log trong build() dễ gây jank (đặc biệt lúc startup), chỉ bật khi debug.
    if (kDebugMode) {
      AppLogger.info('🟣 SPLASH BUILD - Watching auth state');
    }

    // Watch auth state - when this changes, Riverpod notifies router to redirect
    final authState = ref.watch(authNotifierProvider);

    // Nếu timeout vượt quá 10 giây, hiển thị no internet
    if (_isTimeoutExceeded) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  'Không có kết nối',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vui lòng kiểm tra kết nối Internet của bạn',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    AppLogger.info('🟢 RETRY: Refreshing auth state');
                    setState(() {
                      _isTimeoutExceeded = false;
                      _startTime = DateTime.now();
                    });
                    ref.invalidate(authNotifierProvider);
                    _scheduleMinAnimation();
                    _scheduleNetworkTimeout();
                  },
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: authState.when(
            // Auth state is still loading
            loading: () {
              if (kDebugMode) {
                AppLogger.info('🔵 Auth state: LOADING');
              }
              return _buildAnimatedLogo();
            },

            // Auth state resolved with error
            error: (error, stackTrace) {
              if (kDebugMode) {
                AppLogger.error('🔴 Auth state ERROR: $error');
              }
              
              // Khi có lỗi, điều hướng đến login sau khi đủ thời gian animation
              if (!_didNavigate) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final elapsedSeconds = DateTime.now()
                      .difference(_startTime)
                      .inSeconds;
                  if (elapsedSeconds >= 2) {
                    // Đã đủ thời gian animation, điều hướng ngay
                    if (!_didNavigate && mounted) {
                      _didNavigate = true;
                      if (kDebugMode) {
                        AppLogger.info('🟡 Navigating to LOGIN (auth error)');
                      }
                      context.goNamed(AppRoute.login);
                    }
                  } else {
                    // Đợi đến 2 giây rồi điều hướng
                    Future.delayed(
                      Duration(seconds: 2 - elapsedSeconds),
                      () {
                        if (!_didNavigate && mounted) {
                          _didNavigate = true;
                          if (kDebugMode) {
                            AppLogger.info('🟡 Navigating to LOGIN (auth error after delay)');
                          }
                          context.goNamed(AppRoute.login);
                        }
                      },
                    );
                  }
                });
              }
              
              return _buildAnimatedLogo();
            },

            // Auth state resolved successfully (user data loaded)
            // Navigate to appropriate screen based on auth status
            data: (profile) {
              if (kDebugMode) {
                AppLogger.info(
                  '🟡 Auth state: DATA RESOLVED - Profile: ${profile?.id ?? 'null'}',
                );
              }

              // Schedule navigation after minimum 3s animation
              if (!_didNavigate) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                final elapsedSeconds = DateTime.now()
                    .difference(_startTime)
                    .inSeconds;
                if (elapsedSeconds >= 3) {
                  _navigateIfReady();
                } else {
                  // Đợi đến 3 giây
                  Future.delayed(
                    Duration(seconds: 3 - elapsedSeconds),
                    _navigateIfReady,
                  );
                }
                });
              }

              return _buildAnimatedLogo();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'AI LMS',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

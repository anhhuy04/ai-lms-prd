import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash screen - CHỈ chạy 1 lần khi mở app.
///
/// Sử dụng ref.listen (không rebuild) thay vì ref.watch (gây rebuild).
/// Sau khi navigate xong, splash hoàn toàn bất hoạt,
/// tránh xung đột với luồng login/register.
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

  bool _isTimeoutExceeded = false;
  bool _didNavigate = false;
  bool _isMinAnimationDone = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _scheduleMinAnimation();
    _scheduleNetworkTimeout();
  }

  void _scheduleMinAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (kDebugMode) {
        AppLogger.info('🟢 Animation complete - Ready to navigate');
      }
      _isMinAnimationDone = true;
      _tryNavigate();
    });
  }

  void _scheduleNetworkTimeout() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || _didNavigate) return;
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

  void _tryNavigate() {
    if (!mounted || _didNavigate || !_isMinAnimationDone) return;

    final authState = ref.read(authNotifierProvider);
    if (authState.isLoading) return;

    _didNavigate = true;

    authState.when(
      data: (profile) {
        if (profile != null) {
          if (kDebugMode) {
            AppLogger.info(
              '🟡 Navigating to dashboard (role: ${profile.role})',
            );
          }
          context.go(AppRoute.getDashboardPathForRole(profile.role));
        } else {
          if (kDebugMode) {
            AppLogger.info('🟡 Navigating to LOGIN (no profile)');
          }
          context.goNamed(AppRoute.login);
        }
      },
      error: (error, _) {
        if (kDebugMode) {
          AppLogger.info('🟡 Navigating to LOGIN (auth error at startup)');
        }
        context.goNamed(AppRoute.login);
      },
      loading: () {
        _didNavigate = false;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (_didNavigate) return;
      if (kDebugMode) {
        AppLogger.info('🔵 [Splash listener] Auth state changed');
      }
      _tryNavigate();
    });

    if (_isTimeoutExceeded) {
      return _buildTimeoutScreen();
    }

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Center(child: _buildAnimatedLogo()),
    );
  }

  Widget _buildTimeoutScreen() {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DesignColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: DesignColors.error,
                ),
              ),
              const SizedBox(height: DesignSpacing.xxl),
              Text('Không có kết nối', style: DesignTypography.headlineLarge),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                'Vui lòng kiểm tra kết nối Internet\ncủa bạn và thử lại',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                height: DesignComponents.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isTimeoutExceeded = false;
                      _didNavigate = false;
                      _isMinAnimationDone = false;
                    });
                    ref.invalidate(authNotifierProvider);
                    _scheduleMinAnimation();
                    _scheduleNetworkTimeout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: DesignColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignRadius.buttonRadius,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(
                      fontSize: DesignTypography.bodyLargeSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DesignColors.primary, DesignColors.primaryLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignColors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.school_rounded,
                  color: DesignColors.white,
                  size: 44,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignSpacing.xxl),
        Text(
          'AI LMS',
          style: DesignTypography.displayLarge.copyWith(
            color: DesignColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: DesignSpacing.sm),
        Text(
          'Nền tảng học tập thông minh',
          style: DesignTypography.bodyMedium.copyWith(
            color: DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

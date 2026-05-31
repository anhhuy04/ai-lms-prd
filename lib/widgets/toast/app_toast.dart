// lib/widgets/toast/app_toast.dart
//
// Hệ thống thông báo thay thế SnackBar:
//  • Mobile  : card trượt từ trên xuống, có thể swipe hoặc nhấn ×
//  • Desktop : card nhỏ gọn ở góc phải dưới cùng (max-width 380 px)
//
// Cách dùng (3 bước):
//  1. Bọc MaterialApp / GoRouter trong AppToastOverlay
//  2. Gọi AppToast.show(context, ...) từ bất kỳ nơi nào
//  3. Dùng AppToast.success / .error / .warning / .info để tiện hơn

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

// ---------------------------------------------------------------------------
// Toast type & metadata
// ---------------------------------------------------------------------------

/// Loại thông báo — quyết định màu, icon và viền accent
enum AppToastType { success, error, warning, info }

extension _AppToastTypeX on AppToastType {
  Color get accentColor => switch (this) {
        AppToastType.success => DesignColors.success,
        AppToastType.error   => DesignColors.error,
        AppToastType.warning => DesignColors.warning,
        AppToastType.info    => DesignColors.info,
      };

  Color get bgColor => switch (this) {
        AppToastType.success => const Color(0xFFF0FDF4),
        AppToastType.error   => const Color(0xFFFFF1F2),
        AppToastType.warning => const Color(0xFFFFFBEB),
        AppToastType.info    => const Color(0xFFF0F9FF),
      };

  Color get bgColorDark => switch (this) {
        AppToastType.success => const Color(0xFF14532D),
        AppToastType.error   => const Color(0xFF7F1D1D),
        AppToastType.warning => const Color(0xFF78350F),
        AppToastType.info    => const Color(0xFF0C4A6E),
      };

  IconData get icon => switch (this) {
        AppToastType.success => Icons.check_circle_rounded,
        AppToastType.error   => Icons.error_rounded,
        AppToastType.warning => Icons.warning_amber_rounded,
        AppToastType.info    => Icons.info_rounded,
      };

  String get defaultTitle => switch (this) {
        AppToastType.success => 'Thành công',
        AppToastType.error   => 'Lỗi',
        AppToastType.warning => 'Cảnh báo',
        AppToastType.info    => 'Thông tin',
      };
}

// ---------------------------------------------------------------------------
// Toast data model
// ---------------------------------------------------------------------------

class _ToastEntry {
  final String? title;
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback? action;
  final String? actionLabel;

  const _ToastEntry({
    this.title,
    required this.message,
    required this.type,
    required this.duration,
    this.action,
    this.actionLabel,
  });
}

// ---------------------------------------------------------------------------
// Global overlay controller
// ---------------------------------------------------------------------------

class _AppToastController extends ChangeNotifier {
  static final _AppToastController instance = _AppToastController._();
  _AppToastController._();

  final List<_ToastEntry> _queue = [];
  _ToastEntry? current;

  void push(_ToastEntry entry) {
    _queue.add(entry);
    _next();
  }

  void _next() {
    if (current != null) return;
    if (_queue.isEmpty) return;
    current = _queue.removeAt(0);
    notifyListeners();
  }

  void dismiss() {
    current = null;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 80), _next);
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Hệ thống thông báo chính — gọi static methods để hiển thị
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    String? title,
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? action,
    String? actionLabel,
  }) {
    _AppToastController.instance.push(_ToastEntry(
      title: title,
      message: message,
      type: type,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    ));
  }

  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) =>
      show(context, title: title, message: message, type: AppToastType.success,
          duration: duration, action: action, actionLabel: actionLabel);

  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? action,
    String? actionLabel,
  }) =>
      show(context, title: title, message: message, type: AppToastType.error,
          duration: duration, action: action, actionLabel: actionLabel);

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? action,
    String? actionLabel,
  }) =>
      show(context, title: title, message: message, type: AppToastType.warning,
          duration: duration, action: action, actionLabel: actionLabel);

  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) =>
      show(context, title: title, message: message, type: AppToastType.info,
          duration: duration, action: action, actionLabel: actionLabel);
}

// ---------------------------------------------------------------------------
// Overlay wrapper — bọc ngoài MaterialApp / child widget
// ---------------------------------------------------------------------------

/// Bọc widget cần hiển thị toast. Thường đặt ở tầng ngoài cùng (trong main.dart).
///
/// ```dart
/// AppToastOverlay(
///   child: MaterialApp.router(routerConfig: router),
/// )
/// ```
class AppToastOverlay extends StatefulWidget {
  final Widget child;
  const AppToastOverlay({super.key, required this.child});

  @override
  State<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<AppToastOverlay> {
  final _controller = _AppToastController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final entry = _controller.current;
    return Stack(
      children: [
        widget.child,
        if (entry != null)
          _ToastPresenter(
            key: ValueKey(entry),
            entry: entry,
            onDismiss: _controller.dismiss,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Toast Presenter — chứa animation + layout responsive
// ---------------------------------------------------------------------------

class _ToastPresenter extends StatefulWidget {
  final _ToastEntry entry;
  final VoidCallback onDismiss;

  const _ToastPresenter({
    super.key,
    required this.entry,
    required this.onDismiss,
  });

  @override
  State<_ToastPresenter> createState() => _ToastPresenterState();
}

class _ToastPresenterState extends State<_ToastPresenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  Timer? _timer;

  bool get _isDesktop =>
      MediaQuery.of(context).size.width >= DesignBreakpoints.tabletSmall;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    _anim.forward();

    _timer = Timer(widget.entry.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    await _anim.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: isDesktop ? _buildDesktop() : _buildMobile(),
      ),
    );
  }

  // ── Mobile: trượt từ trên xuống ─────────────────────────────────────────
  Widget _buildMobile() {
    return Align(
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
          child: SafeArea(
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! < -100) {
                  _dismiss();
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: _ToastCard(
                  entry: widget.entry,
                  onDismiss: _dismiss,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop: card nhỏ góc phải dưới ─────────────────────────────────────
  Widget _buildDesktop() {
    return Align(
      alignment: Alignment.bottomRight,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.2, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
            child: _ToastCard(
              entry: widget.entry,
              onDismiss: _dismiss,
              width: 360,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toast Card UI
// ---------------------------------------------------------------------------

class _ToastCard extends StatelessWidget {
  final _ToastEntry entry;
  final VoidCallback onDismiss;
  final double width;

  const _ToastCard({
    required this.entry,
    required this.onDismiss,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final type = entry.type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? type.bgColorDark : type.bgColor;
    final accent = type.accentColor;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar kẻ dọc bên trái
                Container(width: 4, color: accent),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSpacing.md,
                      vertical: DesignSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Icon(type.icon, color: accent, size: 22),
                        ),
                        const SizedBox(width: DesignSpacing.sm),

                        // Text block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                entry.title ?? type.defaultTitle,
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : DesignColors.textPrimary,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Message
                              Text(
                                entry.message,
                                style: DesignTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : DesignColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              // Action button
                              if (entry.action != null &&
                                  entry.actionLabel != null) ...[
                                const SizedBox(height: DesignSpacing.xs),
                                GestureDetector(
                                  onTap: () {
                                    entry.action!();
                                    onDismiss();
                                  },
                                  child: Text(
                                    entry.actionLabel!,
                                    style: DesignTypography.labelMedium.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: DesignSpacing.xs),

                        // Close button
                        GestureDetector(
                          onTap: onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark
                                  ? Colors.white54
                                  : DesignColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

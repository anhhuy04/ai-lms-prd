import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/responsive_utils.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/student_dashboard_notifier.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/responsive/responsive_card.dart';
import 'package:ai_mls/widgets/responsive/responsive_row.dart';
import 'package:ai_mls/widgets/responsive/responsive_text.dart';
import 'package:ai_mls/widgets/text/smart_marquee_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget này chỉ chứa phần nội dung có thể cuộn của trang chủ sinh viên.
class StudentHomeContentScreen extends ConsumerWidget {
  const StudentHomeContentScreen({super.key});

  // #region agent log
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.fromEntries(
        data.entries.map(
          (e) => MapEntry(e.key.toString(), _sanitizeData(e.value)),
        ),
      );
    } else if (data is List) {
      return data.map((e) => _sanitizeData(e)).toList();
    } else if (data is double) {
      if (data.isInfinite) return 'Infinity';
      if (data.isNaN) return 'NaN';
      return data;
    } else if (data is num && !data.isFinite) {
      return 'Infinity';
    }
    return data;
  }

  static void _log(
    String location,
    String message,
    Map<String, dynamic> data,
    String hypothesisId,
  ) {
    // Widget này rebuild khá thường xuyên; logging sync sẽ gây jank.
    if (!kDebugMode) return;
    try {
      // Chỉ ghi log ra file trên Windows host để tránh I/O + jank trên mobile.
      if (!Platform.isWindows) return;
      final logPath = r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log';
      final logFile = File(logPath);

      try {
        // Tránh I/O sync trong runtime UI loop
        // ignore: discarded_futures
        logFile.parent.create(recursive: true);
      } catch (_) {
        AppLogger.debug('Log: $location - $message - ${_sanitizeData(data)}');
        return;
      }

      final sanitizedData = _sanitizeData(data);
      final logEntry = {
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': sanitizedData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(logEntry);
      // Append async, không đọc/ghi sync.
      // ignore: discarded_futures
      logFile
          .writeAsString('$jsonString\n', mode: FileMode.append, flush: false)
          .catchError((_) => logFile);
    } catch (e) {
      AppLogger.debug('Log: $location - $message - ${_sanitizeData(data)}');
      AppLogger.error('Logging error: $e', error: e);
    }
  }
  // #endregion

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #region agent log
    _log(
      'student_home_content_screen.dart:15',
      'StudentHomeContentScreen build called',
      {},
      'G',
    );
    // #endregion
    final dashboardState = ref.watch(studentDashboardNotifierProvider);
    final config = ResponsiveUtils.getLayoutConfig(context);
    // #region agent log
    _log('student_home_content_screen.dart:22', 'Layout config retrieved', {
      'screenPadding': config.screenPadding,
      'sectionSpacing': config.sectionSpacing,
      'itemSpacing': config.itemSpacing,
    }, 'E');
    // #endregion

    return dashboardState.when(
      loading: () => const ShimmerDashboardLoading(),
      error: (error, _) =>
          Center(child: ResponsiveText('Lỗi: ${error.toString()}')),
      data: (_) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(studentDashboardNotifierProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              config.screenPadding,
              config.sectionSpacing,
              config.screenPadding,
              config.sectionSpacing + 80,
            ),
            children: [
              _buildHeader(context, ref),
              SizedBox(height: config.sectionSpacing),
              _buildProgressCard(context),
              SizedBox(height: config.sectionSpacing),
              _buildStatsRow(context),
              SizedBox(height: config.sectionSpacing),
              _buildSectionHeader(
                context,
                'Sắp đến hạn',
                actionLabel: 'Xem tất cả',
              ),
              SizedBox(height: config.itemSpacing),
              _buildDueList(context),
              SizedBox(height: config.sectionSpacing),
              _buildSectionHeader(context, 'Điểm số mới nhất'),
              SizedBox(height: config.itemSpacing),
              _buildScoresList(context),
            ],
          ),
        );
      },
    );
  }

  // --- Các hàm build giao diện con cho nội dung ---

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.value;
    final config = ResponsiveUtils.getLayoutConfig(context);

    return ResponsiveRow(
      children: [
        CircleAvatar(
          radius: DesignComponents.avatarMedium / 2,
          backgroundColor: DesignColors.primary.withValues(alpha: 0.1),
          child: ResponsiveText(
            (profile?.fullName?.isNotEmpty ?? false)
                ? profile!.fullName![0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: DesignColors.primary,
              fontWeight: FontWeight.bold,
            ),
            fontSize: 22,
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText(
                'Chào buổi sáng,',
                style: const TextStyle(color: Colors.grey),
                fontSize: DesignTypography.bodySmallSize,
              ),
              SizedBox(height: DesignSpacing.xs),
              SmartMarqueeText(
                text: profile?.fullName ?? 'Học sinh',
                style: DesignTypography.titleLarge,
              ),
            ],
          ),
        ),
        SizedBox(width: config.itemSpacing),
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

  Widget _buildProgressCard(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveCard(
      padding: EdgeInsets.all(config.cardPadding + 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), DesignColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Tiến độ tuần này',
            style: const TextStyle(color: Colors.white70),
            fontSize: DesignTypography.bodySmallSize,
          ),
          SizedBox(height: DesignSpacing.sm),
          ResponsiveRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'Rất tốt! 🚀',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ResponsiveText(
                '85%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                fontSize: DesignTypography.displayLargeSize,
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          const Align(
            alignment: Alignment.centerRight,
            child: ResponsiveText(
              'Còn 3 bài tập để hoàn thành mục tiêu',
              style: TextStyle(color: Colors.white),
              fontSize: DesignTypography.bodySmallSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveRow(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.check_circle_outline,
            'Đã nộp',
            '12',
            Colors.green,
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.hourglass_top_outlined,
            'Chờ chấm',
            '3',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveCard(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, color: color, size: DesignIcons.smSize),
          ),
          SizedBox(height: config.itemSpacing),
          ResponsiveText(
            title,
            style: const TextStyle(color: Colors.grey),
            fontSize: DesignTypography.bodySmallSize,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: DesignComponents.avatarSmall,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ResponsiveText(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                fontSize: DesignTypography.displaySmallSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? actionLabel,
  }) {
    return ResponsiveRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          fontSize: DesignTypography.headlineMediumSize,
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: ResponsiveText(
              actionLabel,
              style: const TextStyle(
                color: DesignColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDueList(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    // Responsive height: mobile 150, tablet 180, desktop 200
    final cardHeight = ResponsiveUtils.responsiveValue(
      context,
      mobile: 150.0,
      tablet: 180.0,
      desktop: 200.0,
    );
    return SizedBox(
      height: cardHeight,
      child: ListView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: [
          _buildDueCard(
            context,
            'Đại số Chương 3',
            'Toán học • Cô Lan',
            'Còn 2 giờ',
            const Color(0xFFE3F2FD),
          ),
          SizedBox(width: config.itemSpacing),
          _buildDueCard(
            context,
            'Phân tích bài thơ',
            'Văn học • Thầy Hùng',
            'Hôm nay, 20:00',
            const Color(0xFFFFF3E0),
          ),
          SizedBox(width: config.itemSpacing),
          _buildDueCard(
            context,
            'Thí nghiệm quang hợp',
            'Sinh học • Cô Mai',
            'Ngày mai',
            const Color(0xFFE8F5E9),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCard(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveCard(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        // Responsive width: mobile 240, tablet 280, desktop 320
        width: ResponsiveUtils.responsiveValue(
          context,
          mobile: 240.0,
          tablet: 280.0,
          desktop: 320.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Colors.grey.shade600,
                  size: DesignIcons.smSize,
                ),
              ],
            ),
            const Spacer(),
            ResponsiveText(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              fontSize: DesignTypography.bodyLargeSize,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            ResponsiveText(
              subtitle,
              style: TextStyle(color: Colors.grey[700]),
              fontSize: DesignTypography.bodySmallSize,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: config.itemSpacing),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: config.itemSpacing,
                vertical: DesignSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ResponsiveText(
                time,
                style: const TextStyle(
                  color: DesignColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                fontSize: DesignTypography.labelSmallSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresList(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return Column(
      children: [
        _buildScoreTile(
          context,
          Icons.history_edu_outlined,
          'Lịch sử Thế giới',
          'Kiểm tra 15 phút',
          '9.5',
        ),
        SizedBox(height: config.itemSpacing),
        _buildScoreTile(
          context,
          Icons.translate_outlined,
          'Tiếng Anh',
          'Bài tập Reading',
          '8.0',
        ),
      ],
    );
  }

  Widget _buildScoreTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String score,
  ) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveCard(
      padding: EdgeInsets.symmetric(
        horizontal: config.itemSpacing,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ResponsiveRow(
        children: [
          CircleAvatar(
            backgroundColor: Colors.yellow.shade100.withValues(alpha: 0.5),
            child: Icon(icon, color: Colors.orange.shade700),
          ),
          SizedBox(width: config.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  fontSize: DesignTypography.bodyLargeSize,
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                  fontSize: DesignTypography.bodySmallSize,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ResponsiveText(
                score,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                fontSize: DesignTypography.headlineMediumSize,
              ),
              ResponsiveText(
                '/10',
                style: const TextStyle(color: Colors.grey),
                fontSize: DesignTypography.labelSmallSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

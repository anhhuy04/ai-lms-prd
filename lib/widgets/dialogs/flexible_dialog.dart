import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Enum định nghĩa các loại dialog
enum DialogType {
  success, // Dialog thành công
  warning, // Dialog cảnh báo
  error, // Dialog lỗi
  info, // Dialog thông tin
  confirm, // Dialog xác nhận
}

/// Enum định nghĩa các loại hành động trong dialog
enum DialogActionType {
  primary, // Nút chính (màu sắc nổi bật)
  secondary, // Nút phụ (màu sắc trung tính)
  tertiary, // Nút thứ ba (màu sắc nhẹ)
}

/// Model cho hành động trong dialog
class DialogAction {
  final String text;
  final VoidCallback onPressed;
  final DialogActionType type;
  final bool isDestructive; // Cho hành động nguy hiểm (xóa, hủy)

  const DialogAction({
    required this.text,
    required this.onPressed,
    this.type = DialogActionType.secondary,
    this.isDestructive = false,
  });
}

/// Widget dialog linh hoạt có thể tái sử dụng
/// Hỗ trợ nhiều loại dialog và kích thước responsive
class FlexibleDialog extends StatelessWidget {
  /// Tiêu đề dialog
  final String title;

  /// Nội dung thông báo
  final String message;

  /// Loại dialog
  final DialogType type;

  /// Danh sách các hành động
  final List<DialogAction> actions;

  /// Icon tùy chỉnh (nếu không sử dụng icon mặc định theo loại)
  final IconData? customIcon;

  /// Có hiển thị nút đóng hay không
  final bool showCloseButton;

  /// Kích thước tối đa của dialog (mặc định: 560px)
  final double maxWidth;

  /// Phần trăm chiều rộng so với màn hình (mặc định: 0.8 cho mobile)
  final double widthPercentage;

  /// Constructor chính
  const FlexibleDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.actions = const [],
    this.customIcon,
    this.showCloseButton = false,
    this.maxWidth = 560.0,
    this.widthPercentage = 0.8,
  });

  /// Hiển thị dialog với animation
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    DialogType type = DialogType.info,
    List<DialogAction> actions = const [],
    IconData? customIcon,
    bool showCloseButton = false,
    double maxWidth = 560.0,
    double widthPercentage = 0.8,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: DesignAnimations.durationNormal,
      // Khi bấm ra ngoài dialog (barrierDismissible = true), dialog sẽ tự động đóng và trả về null
      // Sử dụng Stack với barrier area ở dưới và dialog content ở trên
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Barrier area - bắt tap để dismiss dialog
              // Positioned.fill đảm bảo barrier chiếm toàn màn hình và ở dưới dialog
              if (barrierDismissible)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // Khi bấm vào barrier area, đóng dialog và trả về null
                      Navigator.of(context).pop<T?>(null);
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              // Dialog content - sử dụng Align thay vì Center để tránh mở rộng
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.screenPadding,
                  ),
                  child: FlexibleDialog(
                    title: title,
                    message: message,
                    type: type,
                    actions: actions,
                    customIcon: customIcon,
                    showCloseButton: showCloseButton,
                    maxWidth: maxWidth,
                    widthPercentage: widthPercentage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: DesignAnimations.curveEaseOut,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: DesignAnimations.curveEaseOut,
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Lấy màu sắc chính theo loại dialog
  Color _getPrimaryColor(BuildContext context) {
    switch (type) {
      case DialogType.success:
        return DesignColors.success;
      case DialogType.warning:
        return DesignColors.warning;
      case DialogType.error:
        return DesignColors.error;
      case DialogType.info:
        return DesignColors.primary;
      case DialogType.confirm:
        return DesignColors.primary;
    }
  }

  /// Lấy icon mặc định theo loại dialog
  IconData _getDefaultIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outlined;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.confirm:
        return Icons.help_outline;
    }
  }

  /// Lấy màu nền cho nút theo loại
  Color _getButtonBackgroundColor(
    DialogActionType actionType,
    BuildContext context,
  ) {
    final primaryColor = _getPrimaryColor(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (actionType) {
      case DialogActionType.primary:
        return primaryColor;
      case DialogActionType.secondary:
        return isDarkMode ? const Color(0xFF2a3642) : const Color(0xFFf0f2f4);
      case DialogActionType.tertiary:
        return Colors.transparent;
    }
  }

  /// Lấy màu text cho nút theo loại
  Color _getButtonTextColor(DialogActionType actionType, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (actionType) {
      case DialogActionType.primary:
        return Colors.white;
      case DialogActionType.secondary:
        return isDarkMode ? Colors.white : DesignColors.textPrimary;
      case DialogActionType.tertiary:
        return isDarkMode ? Colors.white : DesignColors.textSecondary;
    }
  }

  /// Build message với hỗ trợ rich text (bold, highlight)
  Widget _buildMessageWithRichText(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      message,
      style: DesignTypography.bodyMedium.copyWith(
        color: isDarkMode
            ? const Color(0xFF9ba8b8)
            : DesignColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build nút hành động
  Widget _buildActionButton(
    BuildContext context,
    DialogAction action, {
    bool isRowLayout = false,
  }) {
    final backgroundColor = _getButtonBackgroundColor(action.type, context);
    final textColor = _getButtonTextColor(action.type, context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Nếu là layout dòng (2 nút trên cùng 1 dòng)
    if (isRowLayout) {
      // Nút primary (đồng ý) - có màu nền, bên trái
      if (action.type == DialogActionType.primary) {
        return Expanded(
          child: ElevatedButton(
            onPressed: action.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                side: action.isDestructive
                    ? BorderSide(color: DesignColors.error, width: 1)
                    : BorderSide.none,
              ),
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
              elevation: 0,
              textStyle: DesignTypography.labelMedium.copyWith(
                fontWeight: DesignTypography.semiBold,
              ),
            ),
            child: Text(action.text),
          ),
        );
      }

      // Nút secondary (không đồng ý) - không màu nền, có border, chỉ chữ có màu, bên phải
      return Expanded(
        child: OutlinedButton(
          onPressed: action.onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isDarkMode
                ? Colors.white
                : DesignColors.textPrimary,
            side: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3)
                  : DesignColors.dividerLight,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
            textStyle: DesignTypography.labelMedium.copyWith(
              fontWeight: DesignTypography.semiBold,
            ),
          ),
          child: Text(action.text),
        ),
      );
    }

    // Layout dọc (nhiều hơn 2 nút hoặc 1 nút)
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            side: action.isDestructive
                ? BorderSide(color: DesignColors.error, width: 1)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          elevation: 0,
          textStyle: DesignTypography.labelMedium.copyWith(
            fontWeight: DesignTypography.semiBold,
          ),
        ),
        child: Text(action.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = DesignBreakpoints.isMobile(screenWidth);
    final isTablet = DesignBreakpoints.isTablet(screenWidth);

    // Tính toán chiều rộng responsive
    double dialogWidth = maxWidth;
    double percentage = widthPercentage;

    if (isMobile) {
      percentage =
          widthPercentage; // Sử dụng widthPercentage được truyền vào (mặc định 80%)
    } else if (isTablet) {
      percentage = 0.7; // 70% cho tablet
    } else {
      percentage = 0.5; // 50% cho desktop
    }

    dialogWidth = screenWidth * percentage;
    dialogWidth = dialogWidth.clamp(DesignComponents.dialogMinWidth, maxWidth);

    final primaryColor = _getPrimaryColor(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconData = customIcon ?? _getDefaultIcon();

    // Không dùng Material và Center ở đây vì đã có trong pageBuilder
    // Chỉ trả về Container với kích thước cố định để không chặn barrier
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: dialogWidth),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1a2632) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [DesignElevation.level3],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative line at top
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    primaryColor.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Dialog content
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      iconData,
                      size: DesignIcons.xlSize,
                      color: primaryColor,
                    ),
                  ),

                  SizedBox(height: DesignSpacing.lg),

                  // Title
                  Text(
                    title,
                    style: DesignTypography.titleLarge.copyWith(
                      fontWeight: DesignTypography.bold,
                      color: isDarkMode
                          ? Colors.white
                          : DesignColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Message with rich text support
                  _buildMessageWithRichText(context),

                  SizedBox(height: DesignSpacing.xxl),

                  // Actions
                  if (actions.isNotEmpty)
                    // Nếu có 2 actions, hiển thị trên cùng 1 dòng
                    actions.length == 2
                        ? Row(
                            children: [
                              // Nút đầu tiên (confirm/primary) - bên trái, có màu
                              _buildActionButton(
                                context,
                                actions[0],
                                isRowLayout: true,
                              ),
                              SizedBox(width: DesignSpacing.md),
                              // Nút thứ hai (cancel/secondary) - bên phải, không màu
                              _buildActionButton(
                                context,
                                actions[1],
                                isRowLayout: true,
                              ),
                            ],
                          )
                        : // Nếu có nhiều hơn 2 actions, hiển thị dọc
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: actions.map((action) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: DesignSpacing.md,
                                ),
                                child: _buildActionButton(
                                  context,
                                  action,
                                  isRowLayout: false,
                                ),
                              );
                            }).toList(),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

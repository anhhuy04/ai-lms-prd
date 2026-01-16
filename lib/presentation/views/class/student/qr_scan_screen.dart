import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'dart:ui';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: DesignAnimations.durationSlow,
      vsync: this,
    )..repeat();

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.textPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            _buildOverlay(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DesignColors.textPrimary,
              DesignColors.textPrimary.withOpacity(0.95),
              DesignColors.textPrimary,
            ],
          ),
          image: DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB_DBV7KMe-5WaC9ZfGFHrMWkQ3gSuhqG_UKwesP7D2qZu2zQov1O527tkRNLkGIANIYYNpCtvU9ZHa_kMOMvElesXHUwPJmu-60PMNVcX7OjbT-CGCDyUFWY71aqz_qYlTv-a-pG3jjS2EdAifSYNQgnQ4FO6zm73_mjUJU7gTPYyu6m4UFHeihDiAOYMlvoWSVjF38YSh3yuJIwFrlHPW7O5ZJIWhd3DQR2FJQ9qSWo6mzobrxXOoQ6MVO0tLQAXH1R52vBaZTA',
            ),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DesignColors.textPrimary.withOpacity(0.7),
                DesignColors.textPrimary.withOpacity(0.8),
                DesignColors.textPrimary.withOpacity(0.75),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScanFrame(),
              SizedBox(height: DesignSpacing.xxl),
              _buildInstructionText(),
              const Spacer(),
              _buildUploadButton(context),
              SizedBox(height: DesignSpacing.xxxxxl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Row(
        children: [
          _buildAppBarButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: _buildAppBarTitle(),
            ),
          ),
          _buildAppBarButton(
            icon: Icons.flash_on,
            onPressed: () {
              // TODO: Toggle flashlight
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: DesignComponents.buttonHeightLarge,
      height: DesignComponents.buttonHeightLarge,
      decoration: BoxDecoration(
        color: DesignColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: DesignColors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DesignRadius.full),
          child: Icon(
            icon,
            color: DesignColors.white,
            size: DesignIcons.mdSize,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: DesignColors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textPrimary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Quét mã QR',
        style: DesignTypography.labelMedium.copyWith(
          color: DesignColors.white,
          fontWeight: DesignTypography.semiBold,
          letterSpacing: DesignTypography.letterSpacingLoose,
          fontSize: DesignTypography.labelLargeSize,
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    const double frameSize = 280.0;
    const double cornerSize = 48.0;
    const double cornerThickness = 4.0;

    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            // Outer glow effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                  border: Border.all(
                    color: DesignColors.tealPrimary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignColors.tealPrimary.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

            // Scan frame corners
            _buildScanCorner(
              Alignment.topLeft,
              cornerSize,
              cornerThickness,
            ),
            _buildScanCorner(
              Alignment.topRight,
              cornerSize,
              cornerThickness,
            ),
            _buildScanCorner(
              Alignment.bottomLeft,
              cornerSize,
              cornerThickness,
            ),
            _buildScanCorner(
              Alignment.bottomRight,
              cornerSize,
              cornerThickness,
            ),

            // Animated scan line
            _buildAnimatedScanLine(frameSize, cornerSize),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCorner(
    Alignment alignment,
    double size,
    double thickness,
  ) {
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(
                    color: DesignColors.tealPrimary,
                    width: thickness,
                  )
                : BorderSide.none,
            bottom: isTop
                ? BorderSide.none
                : BorderSide(
                    color: DesignColors.tealPrimary,
                    width: thickness,
                  ),
            left: isLeft
                ? BorderSide(
                    color: DesignColors.tealPrimary,
                    width: thickness,
                  )
                : BorderSide.none,
            right: isLeft
                ? BorderSide.none
                : BorderSide(
                    color: DesignColors.tealPrimary,
                    width: thickness,
                  ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft
                ? Radius.circular(DesignRadius.lg)
                : Radius.zero,
            topRight: isTop && !isLeft
                ? Radius.circular(DesignRadius.lg)
                : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? Radius.circular(DesignRadius.lg)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? Radius.circular(DesignRadius.lg)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedScanLine(double frameSize, double cornerSize) {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        final scanLinePosition = _scanLineAnimation.value *
            (frameSize - cornerSize * 2 - DesignSpacing.lg);
        return Positioned(
          left: DesignSpacing.lg,
          right: DesignSpacing.lg,
          top: cornerSize + scanLinePosition,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignColors.tealPrimary.withOpacity(0.0),
                  DesignColors.tealPrimary,
                  DesignColors.tealPrimary.withOpacity(0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.tealPrimary.withOpacity(0.8),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xxxxl),
      child: Text(
        'Căn chỉnh mã QR vào bên trong khung hình để quét',
        textAlign: TextAlign.center,
        style: DesignTypography.bodyMedium.copyWith(
          color: DesignColors.white,
          fontWeight: DesignTypography.medium,
          letterSpacing: DesignTypography.letterSpacingLoose,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: DesignColors.textPrimary.withOpacity(0.6),
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xxxxl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: [
            BoxShadow(
              color: DesignColors.tealPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement image upload functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.tealPrimary,
            foregroundColor: DesignColors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            padding: EdgeInsets.symmetric(
              vertical: DesignSpacing.lg,
              horizontal: DesignSpacing.xl,
            ),
            minimumSize: Size(
              double.infinity,
              DesignComponents.buttonHeightLarge,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: DesignIcons.mdSize,
              ),
              SizedBox(width: DesignSpacing.md),
              Text(
                'Tải ảnh lên từ thư viện',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.white,
                  fontWeight: DesignTypography.semiBold,
                  fontSize: DesignTypography.labelLargeSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

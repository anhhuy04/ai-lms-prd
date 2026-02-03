import 'dart:io';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends ConsumerStatefulWidget {
  const QRScanScreen({super.key});

  @override
  ConsumerState<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends ConsumerState<QRScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraView(),
            _buildOverlayWithCutout(),
            _buildContent(context),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Positioned.fill(
      child: MobileScanner(controller: _scannerController, onDetect: _onDetect),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    Barcode? firstValid;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        firstValid = barcode;
        break;
      }
    }

    if (firstValid == null) return;

    _isProcessing = true;
    final rawValue = firstValid.rawValue!;
    final joinCode = _extractJoinCode(rawValue);

    if (!mounted) return;

    final auth = ref.read(authNotifierProvider);
    final studentId = auth.value?.id;
    if (studentId == null) {
      _isProcessing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin học sinh'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    try {
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final targetClass = await classNotifier.resolveClassByJoinCode(
        joinCode.toUpperCase(),
      );

      if (!mounted) return;

      if (targetClass == null) {
        _isProcessing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã QR không hợp lệ hoặc lớp không tồn tại'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Hỏi xác nhận trước khi tham gia lớp qua QR
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
          ),
          title: const Text('Xác nhận tham gia lớp'),
          content: Text('Bạn có chắc muốn tham gia lớp "${targetClass.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirmed != true) {
        _isProcessing = false;
        return;
      }

      final member = await classNotifier.requestJoinClass(
        targetClass.id,
        studentId,
      );

      if (!mounted) return;
      _isProcessing = false;

      if (member != null) {
        // Trả result về JoinClassScreen để propagate tiếp về StudentClassListScreen
        context.pop({
          'status': member.status,
          'classId': targetClass.id,
          'className': targetClass.name,
          'academicYear': targetClass.academicYear,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể tham gia lớp học từ mã QR này'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _isProcessing = false;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? 'Không thể tham gia lớp học từ mã QR này'
                : message,
          ),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  String _extractJoinCode(String data) {
    // Định dạng hiện tại từ phía giáo viên: '<classId>:<joinCode>'
    if (data.contains(':')) {
      final parts = data.split(':');
      if (parts.length >= 2 && parts.last.trim().isNotEmpty) {
        return parts.last.trim();
      }
    }
    // Fallback: dùng toàn bộ string làm joinCode
    return data.trim();
  }

  /// Overlay với cutout (khoét lỗ) ở giữa - phong cách app ngân hàng
  Widget _buildOverlayWithCutout() {
    return Positioned.fill(child: CustomPaint(painter: QRScanOverlayPainter()));
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
              _buildActionButtons(context),
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
            icon: Icons.arrow_back_ios_new,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Quét mã QR',
                style: DesignTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildAppBarButton(
            icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
            onPressed: _toggleFlash,
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _scannerController.toggleTorch();
    });
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    const double frameSize = 280.0;
    const double cornerSize = 32.0;
    const double cornerThickness = 3.0;

    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            // Scan frame corners với style app ngân hàng
            _buildScanCorner(Alignment.topLeft, cornerSize, cornerThickness),
            _buildScanCorner(Alignment.topRight, cornerSize, cornerThickness),
            _buildScanCorner(Alignment.bottomLeft, cornerSize, cornerThickness),
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

  Widget _buildScanCorner(Alignment alignment, double size, double thickness) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Corner line - horizontal
            Positioned(
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              width: size,
              height: thickness,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: isTop && isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    topRight: isTop && !isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    bottomLeft: !isTop && isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    bottomRight: !isTop && !isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
            // Corner line - vertical
            Positioned(
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              width: thickness,
              height: size,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: isTop && isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    topRight: isTop && !isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    bottomLeft: !isTop && isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                    bottomRight: !isTop && !isLeft
                        ? const Radius.circular(2)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedScanLine(double frameSize, double cornerSize) {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        final scanLinePosition =
            _scanLineAnimation.value * (frameSize - cornerSize * 2);
        return Positioned(
          left: cornerSize,
          right: cornerSize,
          top: cornerSize + scanLinePosition,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  DesignColors.primary,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.primary.withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: 1,
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
      child: Column(
        children: [
          Text(
            'Đặt mã QR vào khung hình',
            textAlign: TextAlign.center,
            style: DesignTypography.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Đảm bảo mã QR nằm trong khung và đủ ánh sáng',
            textAlign: TextAlign.center,
            style: DesignTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xxxxl),
      child: Column(
        children: [
          // Nút tải ảnh từ thư viện
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _pickImageFromGallery(),
              icon: Icon(
                Icons.photo_library_outlined,
                size: DesignIcons.mdSize,
              ),
              label: Text(
                'Chọn ảnh từ thư viện',
                style: DesignTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: DesignColors.primary,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null || !mounted) return;

      _isProcessing = true;
      if (mounted) {
        setState(() {});
      }

      // Scan QR từ file ảnh
      final file = File(image.path);
      final capture = await _scannerController.analyzeImage(file.path);

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (capture == null || capture.barcodes.isEmpty) {
        _isProcessing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không tìm thấy mã QR trong ảnh'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Tìm barcode hợp lệ đầu tiên
      Barcode? firstValid;
      for (final barcode in capture.barcodes) {
        final value = barcode.rawValue;
        if (value != null && value.isNotEmpty) {
          firstValid = barcode;
          break;
        }
      }

      if (firstValid == null) {
        _isProcessing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không tìm thấy mã QR trong ảnh'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Xử lý QR code tìm được
      final rawValue = firstValid.rawValue!;
      final joinCode = _extractJoinCode(rawValue);

      final auth = ref.read(authNotifierProvider);
      final studentId = auth.value?.id;
      if (studentId == null) {
        _isProcessing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không tìm thấy thông tin học sinh'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      final classNotifier = ref.read(classNotifierProvider.notifier);
      final targetClass = await classNotifier.resolveClassByJoinCode(
        joinCode.toUpperCase(),
      );

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (targetClass == null) {
        _isProcessing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã QR không hợp lệ hoặc lớp không tồn tại'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Hỏi xác nhận
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
          ),
          title: const Text('Xác nhận tham gia lớp'),
          content: Text('Bạn có chắc muốn tham gia lớp "${targetClass.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (confirmed != true) {
        _isProcessing = false;
        return;
      }

      final member = await classNotifier.requestJoinClass(
        targetClass.id,
        studentId,
      );

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      _isProcessing = false;

      if (member != null) {
        context.pop({
          'status': member.status,
          'classId': targetClass.id,
          'className': targetClass.name,
          'academicYear': targetClass.academicYear,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể tham gia lớp học từ mã QR này'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _isProcessing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(DesignColors.primary),
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Đang xử lý...',
                style: DesignTypography.bodyLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Painter để vẽ overlay với cutout ở giữa
class QRScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cutout ở giữa màn hình (khu vực scan)
    const double frameSize = 280.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: frameSize,
        height: frameSize,
      ),
      const Radius.circular(DesignRadius.lg),
    );

    // Tạo path với cutout
    final cutoutPath = Path()
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    path.addPath(cutoutPath, Offset.zero);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

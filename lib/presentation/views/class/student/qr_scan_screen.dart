import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
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

class _QRScanScreenState extends ConsumerState<QRScanScreen> {
  late final MobileScannerController _scannerController;

  bool _isProcessing = false;
  bool _isFlashOn = false;
  String? _lastScannedValue;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= DesignBreakpoints.tabletSmall;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: isWide ? _buildWideLayout(context) : _buildMobileLayout(),
            ),
            _buildTopBar(context),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(child: _buildScanner()),
        Positioned.fill(child: CustomPaint(painter: QRScanOverlayPainter())),
        _buildMobileInstructionPanel(),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              Positioned.fill(child: _buildScanner()),
              Positioned.fill(
                child: CustomPaint(painter: QRScanOverlayPainter()),
              ),
            ],
          ),
        ),
        Container(
          width: 380,
          color: DesignColors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DesignSpacing.xxxxxl),
                  _buildPanelHeader(dark: false),
                  const SizedBox(height: DesignSpacing.xxl),
                  _buildTipsCard(),
                  const Spacer(),
                  _buildGalleryButton(expanded: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: _scannerController,
      onDetect: _onDetect,
      errorBuilder: (context, error, child) => _buildScannerError(),
    );
  }

  Widget _buildScannerError() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(DesignSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white,
                size: DesignIcons.xlSize,
              ),
              const SizedBox(height: DesignSpacing.lg),
              Text(
                'Không thể mở camera',
                style: DesignTypography.titleLarge.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                'Hãy kiểm tra quyền camera hoặc chọn ảnh QR từ thư viện.',
                style: DesignTypography.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignSpacing.md,
          DesignSpacing.sm,
          DesignSpacing.md,
          DesignSpacing.sm,
        ),
        child: Row(
          children: [
            _buildCircleButton(
              tooltip: 'Quay lại',
              icon: Icons.arrow_back_rounded,
              onPressed: () => context.pop(),
            ),
            const Spacer(),
            Text(
              'Quét mã QR',
              style: DesignTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _buildCircleButton(
              tooltip: _isFlashOn ? 'Tắt đèn flash' : 'Bật đèn flash',
              icon: _isFlashOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              onPressed: _toggleFlash,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.36),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: DesignAccessibility.minTouchTargetSize,
              height: DesignAccessibility.minTouchTargetSize,
              child: Icon(icon, color: Colors.white, size: DesignIcons.mdSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInstructionPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignSpacing.lg,
          DesignSpacing.lg,
          DesignSpacing.lg,
          DesignSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPanelHeader(dark: true),
              const SizedBox(height: DesignSpacing.lg),
              _buildGalleryButton(expanded: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader({required bool dark}) {
    final titleColor = dark ? Colors.white : DesignColors.textPrimary;
    final bodyColor = dark ? Colors.white70 : DesignColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đặt mã QR vào khung quét',
          style: DesignTypography.titleLarge.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: DesignSpacing.sm),
        Text(
          'Mã sẽ được kiểm tra trước khi gửi yêu cầu tham gia lớp. Bạn cũng có thể chọn ảnh QR có sẵn trong máy.',
          style: DesignTypography.bodyMedium.copyWith(color: bodyColor),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: const Column(
        children: [
          _ScanTip(
            icon: Icons.center_focus_strong_rounded,
            text: 'Giữ mã QR nằm trọn trong vùng quét.',
          ),
          SizedBox(height: DesignSpacing.md),
          _ScanTip(
            icon: Icons.light_mode_outlined,
            text: 'Tăng sáng nếu ảnh bị mờ hoặc thiếu sáng.',
          ),
          SizedBox(height: DesignSpacing.md),
          _ScanTip(
            icon: Icons.verified_user_outlined,
            text: 'Luôn xác nhận tên lớp trước khi tham gia.',
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryButton({required bool expanded}) {
    final button = ElevatedButton.icon(
      onPressed: _isProcessing ? null : _pickImageFromGallery,
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text('Chọn ảnh QR từ thư viện'),
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignColors.white,
        foregroundColor: DesignColors.primary,
        disabledBackgroundColor: DesignColors.disabledMedium,
        disabledForegroundColor: DesignColors.textTertiary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        minimumSize: const Size(
          DesignAccessibility.minTouchTargetSize,
          DesignComponents.buttonHeightLarge,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.64),
        child: Center(
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(DesignSpacing.xxl),
            decoration: BoxDecoration(
              color: DesignColors.white,
              borderRadius: BorderRadius.circular(DesignRadius.md),
              boxShadow: [DesignElevation.modalShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignColors.primary,
                  ),
                ),
                const SizedBox(height: DesignSpacing.lg),
                Text(
                  'Đang xử lý mã...',
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final rawValue = _firstBarcodeValue(capture);
    if (rawValue == null || rawValue == _lastScannedValue) return;

    _lastScannedValue = rawValue;
    await _processRawCode(rawValue);
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null || !mounted) return;

      _setProcessing(true);
      final capture = await _scannerController.analyzeImage(image.path);

      if (!mounted) return;

      final rawValue = capture == null ? null : _firstBarcodeValue(capture);
      if (rawValue == null) {
        _setProcessing(false);
        AppToast.error(context, 'Không tìm thấy mã QR trong ảnh.');
        return;
      }

      await _processRawCode(rawValue, processingAlreadySet: true);
    } catch (e) {
      if (!mounted) return;
      _setProcessing(false);
      AppToast.error(context, _cleanErrorMessage(e));
    }
  }

  Future<void> _processRawCode(
    String rawValue, {
    bool processingAlreadySet = false,
  }) async {
    if (!processingAlreadySet) {
      _setProcessing(true);
    }

    final joinCode = _extractJoinCode(rawValue).toUpperCase();
    if (joinCode.isEmpty) {
      _setProcessing(false);
      if (mounted) {
        AppToast.error(context, 'Mã QR không chứa mã lớp hợp lệ.');
      }
      return;
    }

    try {
      final studentId = ref.read(authNotifierProvider).value?.id;
      if (studentId == null) {
        throw Exception('Không tìm thấy thông tin học sinh.');
      }

      final classNotifier = ref.read(classNotifierProvider.notifier);
      final targetClass = await classNotifier.resolveClassByJoinCode(joinCode);

      if (!mounted) return;

      if (targetClass == null) {
        _setProcessing(false);
        AppToast.error(context, 'Mã QR không hợp lệ hoặc lớp không tồn tại.');
        return;
      }

      final confirmed = await _confirmJoin(targetClass);
      if (!mounted) return;

      if (confirmed != true) {
        _setProcessing(false);
        _lastScannedValue = null;
        return;
      }

      final member =
          await classNotifier.requestJoinClass(targetClass.id, studentId)
              as ClassMember?;

      if (!mounted) return;

      _setProcessing(false);
      if (member == null) {
        AppToast.error(context, 'Không thể tham gia lớp học từ mã QR này.');
        return;
      }
      _popWithResult(member, targetClass);
    } catch (e) {
      if (!mounted) return;
      _setProcessing(false);
      _lastScannedValue = null;
      AppToast.error(context, _cleanErrorMessage(e));
    }
  }

  Future<bool?> _confirmJoin(Class targetClass) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !_isProcessing,
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
              foregroundColor: DesignColors.white,
            ),
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  void _popWithResult(ClassMember member, Class targetClass) {
    context.pop({
      'status': member.status,
      'classId': targetClass.id,
      'className': targetClass.name,
      'academicYear': targetClass.academicYear,
    });
  }

  String? _firstBarcodeValue(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String _extractJoinCode(String data) {
    final uri = Uri.tryParse(data);
    final queryCode =
        uri?.queryParameters['joinCode'] ??
        uri?.queryParameters['code'] ??
        uri?.queryParameters['classCode'];
    if (queryCode != null && queryCode.trim().isNotEmpty) {
      return queryCode.trim();
    }

    if (data.contains(':')) {
      final parts = data.split(':');
      final last = parts.last.trim();
      if (last.isNotEmpty) return last;
    }

    return data.trim();
  }

  Future<void> _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
      if (!mounted) return;
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {
      if (!mounted) return;
      AppToast.warning(context, 'Thiết bị này không hỗ trợ đèn flash.');
    }
  }

  void _setProcessing(bool value) {
    if (_isProcessing == value) return;
    if (!mounted) {
      _isProcessing = value;
      return;
    }
    setState(() => _isProcessing = value);
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể xử lý mã QR. Vui lòng thử lại.';
    }
    return message;
  }
}

class _ScanTip extends StatelessWidget {
  const _ScanTip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: DesignIcons.smSize, color: DesignColors.primary),
        const SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class QRScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Offset.zero & size);

    final frameSize = size.shortestSide < 360
        ? size.shortestSide * 0.72
        : 280.0;
    final center = Offset(size.width / 2, size.height / 2);
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: frameSize, height: frameSize),
      const Radius.circular(DesignRadius.lg),
    );

    path.addRRect(cutout);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..color = DesignColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = cutout.outerRect;
    const corner = 34.0;

    canvas
      ..drawLine(
        rect.topLeft,
        rect.topLeft + const Offset(corner, 0),
        borderPaint,
      )
      ..drawLine(
        rect.topLeft,
        rect.topLeft + const Offset(0, corner),
        borderPaint,
      )
      ..drawLine(
        rect.topRight,
        rect.topRight + const Offset(-corner, 0),
        borderPaint,
      )
      ..drawLine(
        rect.topRight,
        rect.topRight + const Offset(0, corner),
        borderPaint,
      )
      ..drawLine(
        rect.bottomLeft,
        rect.bottomLeft + const Offset(corner, 0),
        borderPaint,
      )
      ..drawLine(
        rect.bottomLeft,
        rect.bottomLeft + const Offset(0, -corner),
        borderPaint,
      )
      ..drawLine(
        rect.bottomRight,
        rect.bottomRight + const Offset(-corner, 0),
        borderPaint,
      )
      ..drawLine(
        rect.bottomRight,
        rect.bottomRight + const Offset(0, -corner),
        borderPaint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  final _classCodeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                  child: Column(
                    children: [
                      SizedBox(height: DesignSpacing.xl),
                      _buildInstructionText(),
                      SizedBox(height: DesignSpacing.xl),
                      _buildClassCodeInput(),
                      SizedBox(height: DesignSpacing.xl),
                      _buildDividerWithText(),
                      SizedBox(height: DesignSpacing.xl),
                      _buildQRScanButton(context),
                      SizedBox(height: DesignSpacing.xl * 2),
                    ],
                  ),
                ),
              ),
            ),
            _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignColors.moonLight.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: DesignColors.dividerLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: DesignColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Tham gia lớp học',
                style: DesignTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 48), // Placeholder for alignment
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Text(
      'Yêu cầu giáo viên cung cấp mã lớp hoặc mã QR để tham gia vào không gian học tập.',
      textAlign: TextAlign.center,
      style: DesignTypography.bodySmall.copyWith(
        color: DesignColors.textSecondary,
      ),
    );
  }

  Widget _buildClassCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập mã lớp học',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        TextFormField(
          controller: _classCodeController,
          textAlign: TextAlign.center,
          style: DesignTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: DesignColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'XY78ZQ',
            hintStyle: DesignTypography.displayMedium.copyWith(
              color: DesignColors.textTertiary,
              letterSpacing: 2,
            ),
            filled: true,
            fillColor: DesignColors.disabledLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(
                color: DesignColors.dividerLight,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(
                color: DesignColors.dividerLight,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(color: DesignColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: DesignSpacing.xl,
              horizontal: DesignSpacing.md,
            ),
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            _UpperCaseTextFormatter(),
          ],
        ),
      ],
    );
  }

  Widget _buildDividerWithText() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: DesignColors.dividerLight, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
          child: Text(
            'HOẶC',
            style: DesignTypography.caption.copyWith(
              color: DesignColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: DesignColors.dividerLight, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildQRScanButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Navigate to QR scan screen (GoRouter)
        final result = await context.pushNamed(AppRoute.studentQrScan);
        if (!context.mounted) return;
        if (result != null) {
          // Propagate result về màn trước (StudentClassListScreen) để refresh & navigate
          context.pop(result);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignColors.white,
        foregroundColor: DesignColors.textPrimary,
        surfaceTintColor: DesignColors.white,
        elevation: 1,
        shadowColor: DesignColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        minimumSize: Size(double.infinity, DesignComponents.buttonHeightLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: DesignColors.primary,
              size: 32,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quét mã QR',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Để tham gia nhanh chóng',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: DesignColors.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        border: Border(
          top: BorderSide(color: DesignColors.dividerLight, width: 1),
        ),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () {
                _joinClass(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.primary,
          foregroundColor: DesignColors.white,
          elevation: 3,
          shadowColor: DesignColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
          ),
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          minimumSize: Size(
            double.infinity,
            DesignComponents.buttonHeightMedium,
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(DesignColors.white),
                ),
              )
            : Text(
                'Tham gia',
                style: DesignTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _joinClass(BuildContext context) async {
    final classCode = _classCodeController.text.trim().toUpperCase();

    if (classCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập mã lớp học'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    final auth = ref.read(authNotifierProvider);
    final studentId = auth.value?.id;
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin học sinh'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // B1: Resolve lớp học từ join_code (classCode)
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final targetClass = await classNotifier.resolveClassByJoinCode(classCode);

      if (!context.mounted) return;

      if (targetClass == null) {
        // Không tìm thấy lớp tương ứng với mã
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã lớp không hợp lệ hoặc lớp không tồn tại'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Hỏi xác nhận trước khi tham gia
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận tham gia lớp'),
          content: Text('Bạn có chắc muốn tham gia lớp "${targetClass.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      if (confirmed != true) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // B2: Gửi yêu cầu tham gia lớp với classId thực
      final ClassMember? member = await classNotifier.requestJoinClass(
        targetClass.id,
        studentId,
      );

      // Tránh dùng BuildContext sau async gap nếu widget đã bị dispose
      if (!context.mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      if (member != null) {
        // Trả result về màn trước để:
        // - show snackbar đúng màu
        // - refresh list classes
        // - nếu approved thì navigate vào class detail
        context.pop({
          'status': member.status,
          'classId': targetClass.id,
          'className': targetClass.name,
          'academicYear': targetClass.academicYear,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể tham gia lớp học'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'Không thể tham gia lớp học' : message,
          ),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }
}

/// Formatter để luôn chuyển text sang chữ hoa khi nhập
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

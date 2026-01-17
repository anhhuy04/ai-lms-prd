import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'qr_scan_screen.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _classCodeController = TextEditingController();

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
        color: DesignColors.moonLight.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: DesignColors.dividerLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: DesignColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: DesignColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'XY78ZQ',
            hintStyle: TextStyle(
              fontSize: 24,
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
            style: TextStyle(
              fontSize: 11,
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
      onPressed: () {
        // Navigate to QR scan screen
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const QRScanScreen()));
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
        minimumSize: Size(double.infinity, 80),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DesignColors.primary.withOpacity(0.1),
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
    return Consumer<ClassViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          padding: EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: DesignColors.white,
            border: Border(
              top: BorderSide(color: DesignColors.dividerLight, width: 1),
            ),
          ),
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () {
                    _joinClass(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: DesignColors.white,
              elevation: 3,
              shadowColor: DesignColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
              minimumSize: Size(double.infinity, 30),
            ),
            child: viewModel.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DesignColors.white,
                      ),
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
      },
    );
  }

  Future<void> _joinClass(BuildContext context) async {
    final classCode = _classCodeController.text.trim().toUpperCase();

    if (classCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập mã lớp học'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    final classViewModel = context.read<ClassViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final studentId = authViewModel.userProfile?.id;
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin học sinh'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    // TODO: Tìm classId từ classCode (cần thêm method trong repository)
    // Tạm thời sử dụng classCode như classId
    final success = await classViewModel.requestJoinClass(classCode, studentId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã gửi yêu cầu tham gia lớp học'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              classViewModel.errorMessage ?? 'Không thể tham gia lớp học',
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}

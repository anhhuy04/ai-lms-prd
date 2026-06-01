import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
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
  final _formKey = GlobalKey<FormState>();

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
      appBar: AppBar(
        backgroundColor: DesignColors.white,
        foregroundColor: DesignColors.textPrimary,
        elevation: 0,
        surfaceTintColor: DesignColors.white,
        title: const Text('Tham gia lớp học'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth >= DesignBreakpoints.tabletSmall;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 980 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    DesignBreakpoints.getScreenPadding(constraints.maxWidth),
                  ),
                  child: isWide ? _buildWideContent() : _buildMobileContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroPanel(),
                const SizedBox(height: DesignSpacing.lg),
                _buildJoinCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildHeroPanel()),
        const SizedBox(width: DesignSpacing.xxl),
        SizedBox(width: 430, child: _buildJoinCard()),
      ],
    );
  }

  Widget _buildHeroPanel() {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.xxl),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [DesignElevation.level1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DesignColors.tealAccent,
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: DesignColors.tealPrimary,
              size: DesignIcons.lgSize,
            ),
          ),
          const SizedBox(height: DesignSpacing.lg),
          Text(
            'Nhập mã hoặc quét QR do giáo viên cung cấp',
            style: DesignTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Hệ thống sẽ kiểm tra mã lớp, hiển thị tên lớp để xác nhận và gửi yêu cầu tham gia theo cấu hình của giáo viên.',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSpacing.xl),
          const _InfoRow(
            icon: Icons.verified_outlined,
            text: 'Luôn xác nhận đúng tên lớp trước khi tham gia.',
          ),
          const SizedBox(height: DesignSpacing.md),
          const _InfoRow(
            icon: Icons.pending_actions_outlined,
            text: 'Một số lớp cần giáo viên duyệt trước khi bạn vào học.',
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.xxl),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: [DesignElevation.cardShadow],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mã lớp học',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            TextFormField(
              controller: _classCodeController,
              enabled: !_isSubmitting,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                LengthLimitingTextInputFormatter(12),
                _UpperCaseTextFormatter(),
              ],
              validator: (value) {
                final code = value?.trim() ?? '';
                if (code.isEmpty) return 'Vui lòng nhập mã lớp.';
                if (code.length < 4) return 'Mã lớp quá ngắn.';
                return null;
              },
              style: DesignTypography.displayMedium.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'XY78ZQ',
                hintStyle: DesignTypography.displayMedium.copyWith(
                  color: DesignColors.textTertiary,
                  letterSpacing: 2,
                ),
                filled: true,
                fillColor: DesignColors.disabledLight,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: DesignSpacing.xl,
                  horizontal: DesignSpacing.lg,
                ),
                border: _inputBorder(DesignColors.dividerLight),
                enabledBorder: _inputBorder(DesignColors.dividerLight),
                focusedBorder: _inputBorder(DesignColors.primary, width: 2),
                errorBorder: _inputBorder(DesignColors.error),
                focusedErrorBorder: _inputBorder(DesignColors.error, width: 2),
              ),
              onFieldSubmitted: (_) => _joinClass(),
            ),
            const SizedBox(height: DesignSpacing.lg),
            _buildDivider(),
            const SizedBox(height: DesignSpacing.lg),
            _buildQrScanButton(),
            const SizedBox(height: DesignSpacing.xl),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignRadius.sm),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: DesignColors.dividerLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
          child: Text(
            'HOẶC',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.textTertiary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: DesignColors.dividerLight)),
      ],
    );
  }

  Widget _buildQrScanButton() {
    return OutlinedButton.icon(
      onPressed: _isSubmitting ? null : _openQrScanner,
      icon: const Icon(Icons.qr_code_scanner_rounded),
      label: const Text('Quét mã QR'),
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignColors.primary,
        side: const BorderSide(color: DesignColors.primary),
        minimumSize: const Size(
          DesignAccessibility.minTouchTargetSize,
          DesignComponents.buttonHeightLarge,
        ),
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _joinClass,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.primary,
          foregroundColor: DesignColors.white,
          disabledBackgroundColor: DesignColors.disabledMedium,
          disabledForegroundColor: DesignColors.textTertiary,
          minimumSize: const Size(
            DesignAccessibility.minTouchTargetSize,
            DesignComponents.buttonHeightLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(DesignColors.white),
                ),
              )
            : const Text('Tham gia lớp'),
      ),
    );
  }

  Future<void> _openQrScanner() async {
    final result = await context.pushNamed(AppRoute.studentQrScan);
    if (!mounted || result == null) return;
    context.pop(result);
  }

  Future<void> _joinClass() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final classCode = _classCodeController.text.trim().toUpperCase();
    final studentId = ref.read(authNotifierProvider).value?.id;
    if (studentId == null) {
      AppToast.error(context, 'Không tìm thấy thông tin học sinh.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final targetClass = await classNotifier.resolveClassByJoinCode(classCode);

      if (!mounted) return;

      if (targetClass == null) {
        setState(() => _isSubmitting = false);
        AppToast.error(context, 'Mã lớp không hợp lệ hoặc lớp không tồn tại.');
        return;
      }

      final confirmed = await _confirmJoin(targetClass);
      if (!mounted) return;

      if (confirmed != true) {
        setState(() => _isSubmitting = false);
        return;
      }

      final member =
          await classNotifier.requestJoinClass(targetClass.id, studentId)
              as ClassMember?;

      if (!mounted) return;

      setState(() => _isSubmitting = false);
      if (member == null) {
        AppToast.error(context, 'Không thể tham gia lớp học.');
        return;
      }
      context.pop({
        'status': member.status,
        'classId': targetClass.id,
        'className': targetClass.name,
        'academicYear': targetClass.academicYear,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.error(context, _cleanErrorMessage(e));
    }
  }

  Future<bool?> _confirmJoin(Class targetClass) {
    return showDialog<bool>(
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
              foregroundColor: DesignColors.white,
            ),
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể tham gia lớp. Vui lòng thử lại.';
    }
    return message;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: DesignIcons.smSize, color: DesignColors.tealPrimary),
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

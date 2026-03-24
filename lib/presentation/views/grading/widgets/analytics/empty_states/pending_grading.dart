import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/design_tokens.dart';

class PendingGradingState extends StatelessWidget {
  const PendingGradingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Đang chờ AI chấm điểm...',
              style: DesignTypography.titleMedium,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'AI đang phân tích bài làm của bạn',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

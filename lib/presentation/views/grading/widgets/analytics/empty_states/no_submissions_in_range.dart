import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/design_tokens.dart';

/// Empty state shown when student has submissions but none fall
/// within the selected time range filter.
class NoSubmissionsInRangeState extends StatelessWidget {
  final VoidCallback? onClearFilter;

  const NoSubmissionsInRangeState({super.key, this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 64,
              color: DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Khong co bai nop trong khoang thoi gian nay',
              style: DesignTypography.titleMedium,
            ),
            SizedBox(height: DesignSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
              child: Text(
                'Thay doi khoang thoi gian hoac chon "Tat ca" de xem tat ca bai nop.',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onClearFilter != null) ...[
              SizedBox(height: DesignSpacing.lg),
              TextButton(
                onPressed: onClearFilter,
                child: const Text('Xoa bo loc'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

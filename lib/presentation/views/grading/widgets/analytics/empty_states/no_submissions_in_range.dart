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
              'Không có bài nộp trong khoảng thời gian này',
              style: DesignTypography.titleMedium,
            ),
            SizedBox(height: DesignSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
              child: Text(
                'Thay đổi khoảng thời gian hoặc chọn "Tất cả" để xem tất cả bài nộp.',
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
                child: const Text('Xóa bộ lọc'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';

class NoSkillDataState extends StatelessWidget {
  final VoidCallback? onCompleteAssignment;

  const NoSkillDataState({super.key, this.onCompleteAssignment});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Không đủ dữ liệu',
              style: DesignTypography.titleMedium,
            ),
            SizedBox(height: DesignSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
              child: Text(
                'Not enough data for analysis.\nComplete more assignments to see insights.',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

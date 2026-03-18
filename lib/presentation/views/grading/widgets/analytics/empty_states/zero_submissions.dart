import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/design_tokens.dart';

class ZeroSubmissionsState extends StatelessWidget {
  final VoidCallback? onTakeDiagnostic;

  const ZeroSubmissionsState({super.key, this.onTakeDiagnostic});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h, // Match radar chart height
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Chưa có bài nộp',
              style: DesignTypography.titleMedium,
            ),
            SizedBox(height: DesignSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
              child: Text(
                'Take Diagnostic Test to map your skills',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onTakeDiagnostic != null) ...[
              SizedBox(height: DesignSpacing.lg),
              ElevatedButton(
                onPressed: onTakeDiagnostic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: DesignColors.white,
                ),
                child: const Text('Start Diagnostic'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/refresh/app_refresh_indicator.dart';
import 'package:flutter/material.dart';

/// Reusable error state widget cho assignment list
class AssignmentErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AssignmentErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: () async => onRetry(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.xxxxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: DesignIcons.xxlSize,
                    color: DesignColors.error,
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Text(
                    'Có lỗi xảy ra',
                    style: DesignTypography.titleMedium,
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  Text(
                    error,
                    style: DesignTypography.bodyMedium.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSpacing.xl),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

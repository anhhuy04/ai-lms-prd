import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// AI Confidence Indicator - Skepticism Thermometer
/// Hiển thị độ tin cậy của AI
/// Nếu confidence < 0.7 → nền vàng + cảnh báo
class AiConfidenceIndicator extends StatelessWidget {
  final double? confidence;

  const AiConfidenceIndicator({
    super.key,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    if (confidence == null) {
      return const SizedBox.shrink();
    }

    final isLowConfidence = confidence! < 0.7;
    final confidencePercent = (confidence! * 100).round();

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: isLowConfidence
            ? DesignColors.warning.withValues(alpha: 0.1)
            : DesignColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: isLowConfidence
              ? DesignColors.warning.withValues(alpha: 0.5)
              : DesignColors.success.withValues(alpha: 0.5),
          width: isLowConfidence ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLowConfidence ? Icons.warning_amber : Icons.verified,
                color: isLowConfidence
                    ? DesignColors.warning
                    : DesignColors.success,
                size: 20,
              ),
              const SizedBox(width: DesignSpacing.sm),
              Text(
                'AI Confidence',
                style: DesignTypography.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLowConfidence
                      ? DesignColors.warning
                      : DesignColors.success,
                ),
              ),
              const Spacer(),
              Text(
                '$confidencePercent%',
                style: DesignTypography.titleMedium?.copyWith(
                  color: isLowConfidence
                      ? DesignColors.warning
                      : DesignColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.sm),

          // Confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            child: LinearProgressIndicator(
              value: confidence!,
              backgroundColor: DesignColors.disabledLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowConfidence
                    ? DesignColors.warning
                    : DesignColors.success,
              ),
              minHeight: 8,
            ),
          ),

          // Warning text for low confidence
          if (isLowConfidence) ...[
            const SizedBox(height: DesignSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DesignSpacing.sm),
              decoration: BoxDecoration(
                color: DesignColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: DesignColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: DesignSpacing.xs),
                  Expanded(
                    child: Text(
                      'AI phân vân (Độ tin cậy thấp) - Yêu cầu giáo viên kiểm tra kỹ',
                      style: DesignTypography.bodySmall?.copyWith(
                        color: DesignColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

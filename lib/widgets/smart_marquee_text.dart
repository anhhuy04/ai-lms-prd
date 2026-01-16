import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class SmartMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double height;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;

  const SmartMarqueeText({
    super.key,
    required this.text,
    this.style,
    this.height = 24.0,
    this.velocity = 30.0,
    this.blankSpace = 50.0,
    this.pauseAfterRound = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Lấy style mặc định nếu không truyền vào
        final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

        // 2. Đo độ dài thực tế của chữ
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        // 3. Kiểm tra xem có vượt quá chiều ngang cho phép không
        final bool isOverflowing = textPainter.width > constraints.maxWidth;

        return SizedBox(
          height: height,
          child: isOverflowing
              ? Marquee(
            text: text,
            style: effectiveStyle,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: blankSpace,
            velocity: velocity,
            pauseAfterRound: pauseAfterRound,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          )
              : Text(
            text,
            style: effectiveStyle,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

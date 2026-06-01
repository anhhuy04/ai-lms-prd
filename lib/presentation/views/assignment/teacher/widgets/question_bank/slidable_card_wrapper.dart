import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';

/// Compact action button cho Slidable — icon + label nhỏ gọn.
///
/// Khác với `SlidableAction` mặc định: padding tight hơn, icon 18px, label
/// 11sp → 2-3 nút vẫn fit gọn trong action pane ~180px.
class CompactSlidableAction extends StatelessWidget {
  final VoidCallback onPressed;
  final Color bg;
  final IconData icon;
  final String label;

  const CompactSlidableAction({
    super.key,
    required this.onPressed,
    required this.bg,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrap 1 Slidable trong Padding + ClipRRect để:
/// - Action pane khớp border radius card ngoài.
/// - Margin nằm ngoài ClipRRect (action pane không tràn ra margin).
class SlidableCardWrapper extends StatelessWidget {
  final Key slidableKey;
  final String groupTag;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final double extentRatio;
  final List<Widget> actions;
  final Widget child;

  const SlidableCardWrapper({
    super.key,
    required this.slidableKey,
    required this.groupTag,
    required this.borderRadius,
    required this.margin,
    required this.extentRatio,
    required this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Slidable(
          key: slidableKey,
          groupTag: groupTag,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: extentRatio,
            children: actions,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Helper compute extentRatio dynamic theo width — target action pane ~180px.
double computeSlidableRatio(double width, {double target = 180}) {
  return (target / width).clamp(0.22, 0.55);
}

// Re-export DesignRadius cho convenience.
double get slidableRadiusMd => DesignRadius.md;
double get slidableRadiusLg => DesignRadius.lg;
